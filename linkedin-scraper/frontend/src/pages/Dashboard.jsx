import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { postsAPI, scraperAPI } from '../services/api';
import { format } from 'date-fns';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalPosts: 0,
    recentPosts: 0,
    scraperStatus: { initialized: false, loggedIn: false }
  });
  const [recentPosts, setRecentPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);

      // Fetch posts and scraper status in parallel
      const [postsResponse, statusResponse] = await Promise.all([
        postsAPI.getAll(1, 5),
        scraperAPI.getStatus().catch(() => ({ data: { initialized: false, loggedIn: false } }))
      ]);

      setStats({
        totalPosts: postsResponse.total || 0,
        recentPosts: postsResponse.count || 0,
        scraperStatus: statusResponse.data
      });

      setRecentPosts(postsResponse.data || []);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="container">
        <div className="loading-container">
          <div className="spinner"></div>
          <p>Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container page">
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
        <p className="page-subtitle">Overview of your LinkedIn scraping activity</p>
      </div>

      <div className="dashboard-grid">
        <div className="stat-card">
          <h3>Total Posts</h3>
          <div className="stat-value">{stats.totalPosts}</div>
        </div>

        <div className="stat-card">
          <h3>Scraper Status</h3>
          <div className="stat-value" style={{ fontSize: '20px' }}>
            {stats.scraperStatus.loggedIn ? (
              <span style={{ color: 'var(--success-color)' }}>✓ Active</span>
            ) : (
              <span style={{ color: 'var(--text-secondary)' }}>○ Inactive</span>
            )}
          </div>
          <Link to="/scraper" className="btn btn-primary mt-2">
            Go to Scraper
          </Link>
        </div>

        <div className="stat-card">
          <h3>Quick Actions</h3>
          <div className="flex flex-col gap-2 mt-2">
            <Link to="/scraper" className="btn btn-primary">
              Start Scraping
            </Link>
            <Link to="/posts" className="btn btn-secondary">
              View All Posts
            </Link>
          </div>
        </div>
      </div>

      <div className="mt-3">
        <h2 style={{ fontSize: '24px', marginBottom: '16px' }}>Recent Posts</h2>

        {recentPosts.length === 0 ? (
          <div className="empty-state">
            <div className="empty-state-icon">📝</div>
            <h3 className="empty-state-title">No posts yet</h3>
            <p className="empty-state-text">
              Start scraping LinkedIn profiles to see posts here
            </p>
            <Link to="/scraper" className="btn btn-primary">
              Start Scraping
            </Link>
          </div>
        ) : (
          <div className="posts-grid">
            {recentPosts.map((post) => (
              <div key={post._id} className="post-card">
                <div className="post-header">
                  <div className="post-author">
                    <div className="post-author-name">{post.profileName}</div>
                    <div className="post-date">
                      {format(new Date(post.publishedDate), 'MMM d, yyyy')}
                    </div>
                  </div>
                  <a
                    href={post.postUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="btn btn-secondary btn-sm"
                  >
                    View on LinkedIn
                  </a>
                </div>

                <div className="post-content">
                  {post.content.length > 300
                    ? `${post.content.substring(0, 300)}...`
                    : post.content}
                </div>

                {post.hashtags && post.hashtags.length > 0 && (
                  <div className="hashtags">
                    {post.hashtags.map((tag, index) => (
                      <span key={index} className="hashtag">
                        #{tag}
                      </span>
                    ))}
                  </div>
                )}

                <div className="post-stats">
                  <div className="post-stat">
                    <span>👍</span>
                    <span className="post-stat-value">{post.likes || 0}</span>
                  </div>
                  <div className="post-stat">
                    <span>💬</span>
                    <span className="post-stat-value">{post.comments || 0}</span>
                  </div>
                  <div className="post-stat">
                    <span>🔄</span>
                    <span className="post-stat-value">{post.shares || 0}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {recentPosts.length > 0 && (
          <div className="text-center mt-3">
            <Link to="/posts" className="btn btn-primary">
              View All Posts
            </Link>
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
