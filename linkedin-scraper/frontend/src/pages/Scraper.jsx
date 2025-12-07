import React, { useState, useEffect } from 'react';
import { scraperAPI } from '../services/api';

const Scraper = () => {
  const [scraperStatus, setScraperStatus] = useState({
    initialized: false,
    loggedIn: false
  });
  const [loginForm, setLoginForm] = useState({
    email: '',
    password: ''
  });
  const [scrapeForm, setScrapeForm] = useState({
    profileUrl: '',
    maxPosts: 50
  });
  const [loading, setLoading] = useState(false);
  const [scraping, setScraping] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });
  const [scrapedPosts, setScrapedPosts] = useState([]);

  useEffect(() => {
    checkScraperStatus();
  }, []);

  const checkScraperStatus = async () => {
    try {
      const response = await scraperAPI.getStatus();
      setScraperStatus(response.data);
    } catch (error) {
      console.error('Failed to check scraper status:', error);
    }
  };

  const handleLoginChange = (e) => {
    setLoginForm({
      ...loginForm,
      [e.target.name]: e.target.value
    });
  };

  const handleScrapeChange = (e) => {
    setScrapeForm({
      ...scrapeForm,
      [e.target.name]: e.target.value
    });
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      await scraperAPI.login(loginForm);
      setMessage({
        type: 'success',
        text: 'Successfully logged in to LinkedIn scraper!'
      });
      setScraperStatus({ initialized: true, loggedIn: true });
      setLoginForm({ email: '', password: '' });
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || 'Failed to login to LinkedIn'
      });
    } finally {
      setLoading(false);
    }
  };

  const handleScrape = async (e) => {
    e.preventDefault();
    setScraping(true);
    setMessage({ type: '', text: '' });
    setScrapedPosts([]);

    try {
      const response = await scraperAPI.scrape(
        scrapeForm.profileUrl,
        scrapeForm.maxPosts
      );
      setMessage({
        type: 'success',
        text: `Successfully scraped ${response.count} posts!`
      });
      setScrapedPosts(response.data);
    } catch (error) {
      setMessage({
        type: 'error',
        text: error.response?.data?.error || 'Failed to scrape posts'
      });
    } finally {
      setScraping(false);
    }
  };

  const handleLogout = async () => {
    try {
      await scraperAPI.logout();
      setScraperStatus({ initialized: false, loggedIn: false });
      setMessage({
        type: 'success',
        text: 'Logged out from LinkedIn scraper'
      });
    } catch (error) {
      setMessage({
        type: 'error',
        text: 'Failed to logout'
      });
    }
  };

  return (
    <div className="container page">
      <div className="page-header">
        <h1 className="page-title">LinkedIn Scraper</h1>
        <p className="page-subtitle">
          Scrape posts from LinkedIn profiles and store them in the database
        </p>
      </div>

      {message.text && (
        <div className={`alert alert-${message.type}`}>
          {message.text}
        </div>
      )}

      {/* Scraper Login Section */}
      {!scraperStatus.loggedIn ? (
        <div className="card">
          <h2 style={{ fontSize: '20px', marginBottom: '16px' }}>
            Step 1: Login to LinkedIn
          </h2>
          <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>
            Provide your LinkedIn credentials to initialize the scraper.
            Your credentials are used only for scraping and are not stored.
          </p>

          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label htmlFor="email" className="form-label">
                LinkedIn Email
              </label>
              <input
                type="email"
                id="email"
                name="email"
                className="form-input"
                value={loginForm.email}
                onChange={handleLoginChange}
                required
                placeholder="your-linkedin-email@example.com"
              />
            </div>

            <div className="form-group">
              <label htmlFor="password" className="form-label">
                LinkedIn Password
              </label>
              <input
                type="password"
                id="password"
                name="password"
                className="form-input"
                value={loginForm.password}
                onChange={handleLoginChange}
                required
                placeholder="Your LinkedIn password"
              />
            </div>

            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? 'Logging in...' : 'Login to LinkedIn'}
            </button>
          </form>
        </div>
      ) : (
        <>
          {/* Scraper Status */}
          <div className="card" style={{ backgroundColor: '#d1f2eb', borderColor: 'var(--success-color)' }}>
            <div className="flex justify-between items-center">
              <div>
                <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '4px' }}>
                  ✓ Scraper Active
                </h3>
                <p style={{ color: 'var(--text-secondary)' }}>
                  You're logged in and ready to scrape posts
                </p>
              </div>
              <button
                onClick={handleLogout}
                className="btn btn-danger"
              >
                Logout
              </button>
            </div>
          </div>

          {/* Scrape Form */}
          <div className="card">
            <h2 style={{ fontSize: '20px', marginBottom: '16px' }}>
              Step 2: Scrape Profile Posts
            </h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>
              Enter a LinkedIn profile URL to scrape their recent posts.
            </p>

            <form onSubmit={handleScrape}>
              <div className="form-group">
                <label htmlFor="profileUrl" className="form-label">
                  LinkedIn Profile URL
                </label>
                <input
                  type="url"
                  id="profileUrl"
                  name="profileUrl"
                  className="form-input"
                  value={scrapeForm.profileUrl}
                  onChange={handleScrapeChange}
                  required
                  placeholder="https://www.linkedin.com/in/username"
                  pattern="https?://(www\.)?linkedin\.com/in/[\w-]+/?"
                  title="Please enter a valid LinkedIn profile URL"
                />
                <small style={{ color: 'var(--text-secondary)', display: 'block', marginTop: '4px' }}>
                  Example: https://www.linkedin.com/in/john-doe
                </small>
              </div>

              <div className="form-group">
                <label htmlFor="maxPosts" className="form-label">
                  Maximum Posts to Scrape
                </label>
                <input
                  type="number"
                  id="maxPosts"
                  name="maxPosts"
                  className="form-input"
                  value={scrapeForm.maxPosts}
                  onChange={handleScrapeChange}
                  min="1"
                  max="100"
                  required
                />
                <small style={{ color: 'var(--text-secondary)', display: 'block', marginTop: '4px' }}>
                  Choose between 1 and 100 posts
                </small>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                disabled={scraping}
              >
                {scraping ? 'Scraping... This may take a while' : 'Start Scraping'}
              </button>
            </form>
          </div>

          {/* Scraped Posts Results */}
          {scrapedPosts.length > 0 && (
            <div className="card">
              <h2 style={{ fontSize: '20px', marginBottom: '16px' }}>
                Scraped Posts ({scrapedPosts.length})
              </h2>
              <div className="posts-grid">
                {scrapedPosts.map((post) => (
                  <div key={post._id} className="card" style={{ padding: '16px' }}>
                    <div className="post-content" style={{ marginBottom: '12px' }}>
                      {post.content.substring(0, 200)}
                      {post.content.length > 200 && '...'}
                    </div>
                    <div className="post-stats">
                      <div className="post-stat">
                        <span>👍</span>
                        <span className="post-stat-value">{post.likes || 0}</span>
                      </div>
                      <div className="post-stat">
                        <span>💬</span>
                        <span className="post-stat-value">{post.comments || 0}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </>
      )}

      {/* Information Section */}
      <div className="card" style={{ backgroundColor: 'var(--bg-secondary)' }}>
        <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '12px' }}>
          ℹ️ Important Information
        </h3>
        <ul style={{ paddingLeft: '20px', color: 'var(--text-secondary)' }}>
          <li>Scraping respects LinkedIn's rate limits with automatic delays</li>
          <li>Your LinkedIn credentials are used only for authentication</li>
          <li>Posts are stored securely in MongoDB</li>
          <li>Duplicate posts are automatically handled</li>
          <li>Scraping large numbers of posts may take several minutes</li>
        </ul>
      </div>
    </div>
  );
};

export default Scraper;
