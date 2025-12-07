import puppeteer from 'puppeteer';
import LinkedInPost from '../models/LinkedInPost.js';
import { logger } from '../utils/logger.js';

class LinkedInScraper {
  constructor() {
    this.browser = null;
    this.page = null;
    this.isLoggedIn = false;
  }

  /**
   * Initialize browser with security settings
   */
  async initialize() {
    try {
      this.browser = await puppeteer.launch({
        headless: 'new',
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-accelerated-2d-canvas',
          '--no-first-run',
          '--no-zygote',
          '--disable-gpu',
          '--disable-web-security',
          '--disable-features=IsolateOrigins,site-per-process'
        ],
        timeout: 60000
      });

      this.page = await this.browser.newPage();

      // Set user agent to avoid detection
      await this.page.setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
      );

      // Set viewport
      await this.page.setViewport({ width: 1920, height: 1080 });

      // Set extra headers
      await this.page.setExtraHTTPHeaders({
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      });

      logger.info('Browser initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize browser:', error);
      throw new Error('Browser initialization failed');
    }
  }

  /**
   * Login to LinkedIn
   */
  async login(email, password) {
    try {
      if (!email || !password) {
        throw new Error('LinkedIn credentials not provided');
      }

      await this.page.goto('https://www.linkedin.com/login', {
        waitUntil: 'networkidle2',
        timeout: 30000
      });

      // Wait for login form
      await this.page.waitForSelector('#username', { timeout: 10000 });

      // Fill in credentials
      await this.page.type('#username', email, { delay: 100 });
      await this.page.type('#password', password, { delay: 100 });

      // Click sign in button
      await Promise.all([
        this.page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 30000 }),
        this.page.click('button[type="submit"]')
      ]);

      // Check if login was successful
      const currentUrl = this.page.url();
      if (currentUrl.includes('/feed') || currentUrl.includes('/checkpoint')) {
        this.isLoggedIn = true;
        logger.info('Successfully logged in to LinkedIn');

        // Handle checkpoint/challenge if present
        if (currentUrl.includes('/checkpoint')) {
          logger.warn('LinkedIn checkpoint detected - manual intervention may be required');
          throw new Error('LinkedIn security checkpoint detected. Please verify your account manually.');
        }
      } else {
        throw new Error('Login failed - unexpected redirect');
      }
    } catch (error) {
      logger.error('LinkedIn login failed:', error);
      throw error;
    }
  }

  /**
   * Scrape posts from a LinkedIn profile
   */
  async scrapePosts(profileUrl, maxPosts = 50) {
    try {
      if (!this.isLoggedIn) {
        throw new Error('Not logged in to LinkedIn');
      }

      // Validate and normalize profile URL
      const normalizedUrl = this.normalizeProfileUrl(profileUrl);
      if (!normalizedUrl) {
        throw new Error('Invalid LinkedIn profile URL');
      }

      // Navigate to profile activity page
      const activityUrl = `${normalizedUrl}/recent-activity/all/`;
      await this.page.goto(activityUrl, {
        waitUntil: 'networkidle2',
        timeout: 30000
      });

      // Wait for content to load
      await this.delay(3000);

      // Get profile name
      const profileName = await this.getProfileName();

      // Scroll and collect posts
      const posts = await this.scrollAndCollectPosts(maxPosts);

      // Parse and save posts
      const savedPosts = [];
      for (const postData of posts) {
        try {
          const parsedPost = await this.parsePost(postData, profileUrl, profileName);
          if (parsedPost) {
            // Save or update in database
            const saved = await LinkedInPost.findOneAndUpdate(
              { postId: parsedPost.postId },
              parsedPost,
              { upsert: true, new: true, setDefaultsOnInsert: true }
            );
            savedPosts.push(saved);
          }
        } catch (parseError) {
          logger.warn('Failed to parse post:', parseError.message);
          continue;
        }
      }

      logger.info(`Successfully scraped ${savedPosts.length} posts from ${profileUrl}`);
      return savedPosts;

    } catch (error) {
      logger.error('Failed to scrape posts:', error);
      throw error;
    }
  }

  /**
   * Scroll page and collect post elements
   */
  async scrollAndCollectPosts(maxPosts) {
    const posts = [];
    let previousHeight = 0;
    let scrollAttempts = 0;
    const maxScrollAttempts = 10;

    while (posts.length < maxPosts && scrollAttempts < maxScrollAttempts) {
      // Collect visible posts
      const newPosts = await this.page.evaluate(() => {
        const postElements = document.querySelectorAll('li.profile-creator-shared-feed-update__container');
        const postsData = [];

        postElements.forEach(element => {
          try {
            const postContent = element.querySelector('.feed-shared-update-v2__description')?.innerText || '';
            const postLink = element.querySelector('a.app-aware-link[href*="/activity/"]')?.href || '';
            const timestamp = element.querySelector('time')?.getAttribute('datetime') || '';
            const reactions = element.querySelector('.social-details-social-counts__reactions-count')?.innerText || '0';
            const commentsCount = element.querySelector('.social-details-social-counts__comments')?.innerText || '0';

            if (postContent || postLink) {
              postsData.push({
                content: postContent,
                url: postLink,
                timestamp: timestamp,
                reactions: reactions,
                comments: commentsCount
              });
            }
          } catch (err) {
            // Skip invalid posts
          }
        });

        return postsData;
      });

      // Add new unique posts
      newPosts.forEach(post => {
        if (post.url && !posts.find(p => p.url === post.url)) {
          posts.push(post);
        }
      });

      // Scroll down
      await this.page.evaluate(() => {
        window.scrollTo(0, document.body.scrollHeight);
      });

      await this.delay(2000);

      // Check if we've reached the bottom
      const currentHeight = await this.page.evaluate(() => document.body.scrollHeight);
      if (currentHeight === previousHeight) {
        scrollAttempts++;
      } else {
        scrollAttempts = 0;
      }
      previousHeight = currentHeight;
    }

    return posts.slice(0, maxPosts);
  }

  /**
   * Parse post data into schema format
   */
  async parsePost(postData, profileUrl, profileName) {
    try {
      // Extract post ID from URL
      const postIdMatch = postData.url.match(/activity[:-](\d+)/);
      if (!postIdMatch) {
        return null;
      }

      const postId = postIdMatch[1];

      // Parse reactions
      const likes = this.parseNumber(postData.reactions);
      const comments = this.parseNumber(postData.comments);

      // Extract hashtags
      const hashtags = this.extractHashtags(postData.content);

      // Determine media type
      const mediaType = this.detectMediaType(postData.content);

      return {
        profileUrl: profileUrl,
        profileName: profileName,
        postId: postId,
        postUrl: postData.url,
        content: postData.content.trim().substring(0, 10000),
        publishedDate: postData.timestamp ? new Date(postData.timestamp) : new Date(),
        likes: likes,
        comments: comments,
        shares: 0,
        mediaType: mediaType,
        hashtags: hashtags,
        scrapedAt: new Date()
      };
    } catch (error) {
      logger.error('Failed to parse post:', error);
      return null;
    }
  }

  /**
   * Get profile name from page
   */
  async getProfileName() {
    try {
      return await this.page.evaluate(() => {
        const nameElement = document.querySelector('h1.text-heading-xlarge');
        return nameElement ? nameElement.innerText.trim() : 'Unknown Profile';
      });
    } catch (error) {
      return 'Unknown Profile';
    }
  }

  /**
   * Normalize LinkedIn profile URL
   */
  normalizeProfileUrl(url) {
    try {
      const match = url.match(/linkedin\.com\/in\/([\w-]+)/);
      if (match) {
        return `https://www.linkedin.com/in/${match[1]}`;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Extract hashtags from content
   */
  extractHashtags(content) {
    const hashtagRegex = /#[\w]+/g;
    const matches = content.match(hashtagRegex);
    return matches ? matches.map(tag => tag.substring(1)) : [];
  }

  /**
   * Detect media type from content
   */
  detectMediaType(content) {
    if (content.includes('📹') || content.includes('video')) return 'video';
    if (content.includes('📷') || content.includes('photo')) return 'image';
    if (content.includes('📄') || content.includes('document')) return 'document';
    if (content.includes('poll')) return 'poll';
    return 'none';
  }

  /**
   * Parse string number to integer
   */
  parseNumber(str) {
    if (!str) return 0;
    const cleaned = str.replace(/[^0-9.KM]/gi, '');
    if (cleaned.includes('K')) {
      return Math.round(parseFloat(cleaned) * 1000);
    }
    if (cleaned.includes('M')) {
      return Math.round(parseFloat(cleaned) * 1000000);
    }
    return parseInt(cleaned) || 0;
  }

  /**
   * Delay helper
   */
  async delay(ms) {
    const minDelay = parseInt(process.env.SCRAPER_DELAY_MIN) || 2000;
    const maxDelay = parseInt(process.env.SCRAPER_DELAY_MAX) || 5000;
    const randomDelay = Math.random() * (maxDelay - minDelay) + minDelay;
    return new Promise(resolve => setTimeout(resolve, Math.max(ms, randomDelay)));
  }

  /**
   * Close browser
   */
  async close() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
      this.page = null;
      this.isLoggedIn = false;
      logger.info('Browser closed');
    }
  }
}

export default LinkedInScraper;
