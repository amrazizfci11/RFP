import LinkedInScraper from '../services/linkedinScraper.js';
import LinkedInPost from '../models/LinkedInPost.js';
import { logger } from '../utils/logger.js';

// Store active scraper instances (in production, use Redis)
const scraperInstances = new Map();

/**
 * Initialize scraper and login
 * @route POST /api/v1/scraper/login
 * @access Private
 */
export const initializeScraper = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const userId = req.user.id;

    // Check if user already has an active scraper
    if (scraperInstances.has(userId)) {
      const existingScraper = scraperInstances.get(userId);
      if (existingScraper.isLoggedIn) {
        return res.status(200).json({
          success: true,
          message: 'Scraper already initialized and logged in'
        });
      }
    }

    // Create new scraper instance
    const scraper = new LinkedInScraper();
    await scraper.initialize();

    // Login to LinkedIn
    await scraper.login(email, password);

    // Store scraper instance
    scraperInstances.set(userId, scraper);

    logger.info(`Scraper initialized for user: ${req.user.username}`);

    res.status(200).json({
      success: true,
      message: 'Scraper initialized and logged in successfully'
    });

  } catch (error) {
    logger.error('Scraper initialization error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to initialize scraper'
    });
  }
};

/**
 * Scrape posts from a LinkedIn profile
 * @route POST /api/v1/scraper/scrape
 * @access Private
 */
export const scrapePosts = async (req, res, next) => {
  try {
    const { profileUrl, maxPosts = 50 } = req.body;
    const userId = req.user.id;

    // Get scraper instance
    const scraper = scraperInstances.get(userId);

    if (!scraper || !scraper.isLoggedIn) {
      return res.status(400).json({
        success: false,
        error: 'Scraper not initialized. Please login first.'
      });
    }

    logger.info(`Starting scrape for profile: ${profileUrl}`);

    // Scrape posts
    const posts = await scraper.scrapePosts(profileUrl, maxPosts);

    res.status(200).json({
      success: true,
      count: posts.length,
      data: posts
    });

  } catch (error) {
    logger.error('Scraping error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to scrape posts'
    });
  }
};

/**
 * Close scraper session
 * @route POST /api/v1/scraper/logout
 * @access Private
 */
export const closeScraper = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const scraper = scraperInstances.get(userId);

    if (scraper) {
      await scraper.close();
      scraperInstances.delete(userId);
      logger.info(`Scraper closed for user: ${req.user.username}`);
    }

    res.status(200).json({
      success: true,
      message: 'Scraper session closed'
    });

  } catch (error) {
    logger.error('Close scraper error:', error);
    next(error);
  }
};

/**
 * Get all posts
 * @route GET /api/v1/posts
 * @access Private
 */
export const getAllPosts = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await LinkedInPost.find()
      .sort({ scrapedAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('-__v');

    const total = await LinkedInPost.countDocuments();

    res.status(200).json({
      success: true,
      count: posts.length,
      total,
      page,
      pages: Math.ceil(total / limit),
      data: posts
    });

  } catch (error) {
    logger.error('Get all posts error:', error);
    next(error);
  }
};

/**
 * Get posts by profile URL
 * @route GET /api/v1/posts/profile
 * @access Private
 */
export const getPostsByProfile = async (req, res, next) => {
  try {
    const { profileUrl } = req.query;
    const limit = parseInt(req.query.limit) || 50;

    if (!profileUrl) {
      return res.status(400).json({
        success: false,
        error: 'Profile URL is required'
      });
    }

    const posts = await LinkedInPost.getByProfile(profileUrl, limit);

    res.status(200).json({
      success: true,
      count: posts.length,
      profileUrl,
      data: posts
    });

  } catch (error) {
    logger.error('Get posts by profile error:', error);
    next(error);
  }
};

/**
 * Get single post by ID
 * @route GET /api/v1/posts/:id
 * @access Private
 */
export const getPostById = async (req, res, next) => {
  try {
    const post = await LinkedInPost.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        error: 'Post not found'
      });
    }

    res.status(200).json({
      success: true,
      data: post
    });

  } catch (error) {
    logger.error('Get post by ID error:', error);
    next(error);
  }
};

/**
 * Delete post by ID
 * @route DELETE /api/v1/posts/:id
 * @access Private (Admin only)
 */
export const deletePost = async (req, res, next) => {
  try {
    const post = await LinkedInPost.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        error: 'Post not found'
      });
    }

    await post.deleteOne();

    logger.info(`Post deleted: ${req.params.id} by user: ${req.user.username}`);

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully'
    });

  } catch (error) {
    logger.error('Delete post error:', error);
    next(error);
  }
};

/**
 * Get scraper status
 * @route GET /api/v1/scraper/status
 * @access Private
 */
export const getScraperStatus = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const scraper = scraperInstances.get(userId);

    const status = {
      initialized: !!scraper,
      loggedIn: scraper?.isLoggedIn || false
    };

    res.status(200).json({
      success: true,
      data: status
    });

  } catch (error) {
    logger.error('Get scraper status error:', error);
    next(error);
  }
};
