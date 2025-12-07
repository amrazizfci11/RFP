import React, { useEffect, useState } from 'react';
import { postsAPI } from '../services/api';
import { format } from 'date-fns';

const Posts = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 10,
    total: 0,
    pages: 0
  });
  const [filterUrl, setFilterUrl] = useState('');

  useEffect(() => {
    fetchPosts();
  }, [pagination.page]);

  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await postsAPI.getAll(pagination.page, pagination.limit);

      setPosts(response.data || []);
      setPagination({
        ...pagination,
        total: response.total || 0,
        pages: response.pages || 0
      });
    } catch (error) {
      console.error('Failed to fetch posts:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilter = async (e) => {
    e.preventDefault();
    if (!filterUrl) {
      fetchPosts();
      return;
    }

    try {
      setLoading(true);
      const response = await postsAPI.getByProfile(filterUrl, 50);
      setPosts(response.data || []);
      setPagination({
        page: 1,
        limit: 50,
        total: response.count || 0,
        pages: 1
      });
    } catch (error) {
      console.error('Failed to filter posts:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleClearFilter = () => {
    setFilterUrl('');
    setPagination({ ...pagination, page: 1 });
    fetchPosts();
  };

  const handlePageChange = (newPage) => {
    setPagination({ ...pagination, page: newPage });
  };

  if (loading && posts.length === 0) {
    return (
      <div className="container">
        <div className="loading-container">
          <div className="spinner"></div>
          <p>Loading posts...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container page">
      <div className="page-header">
        <h1 className="page-title">All Posts</h1>
        <p className="page-subtitle">
          Browse and search through all scraped LinkedIn posts
        </p>
      </div>

      {/* Filter Form */}
      <div className="card">
        <form onSubmit={handleFilter} className="flex gap-2">
          <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
            <input
              type="text"
              className="form-input"
              value={filterUrl}
              onChange={(e) => setFilterUrl(e.target.value)}
              placeholder="Filter by profile URL (e.g., https://www.linkedin.com/in/username)"
            />
          </div>
          <button type="submit" className="btn btn-primary">
            Filter
          </button>
          {filterUrl && (
            <button
              type="button"
              onClick={handleClearFilter}
              className="btn btn-secondary"
            >
              Clear
            </button>
          )}
        </form>
      </div>

      {/* Posts List */}
      {posts.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">📭</div>
          <h3 className="empty-state-title">No posts found</h3>
          <p className="empty-state-text">
            {filterUrl
              ? 'No posts found for this profile URL'
              : 'Start scraping to see posts here'}
          </p>
        </div>
      ) : (
        <>
          <div className="posts-grid">
            {posts.map((post) => (
              <div key={post._id} className="post-card">
                <div className="post-header">
                  <div className="post-author">
                    <div className="post-author-name">{post.profileName}</div>
                    <div className="post-date">
                      {format(new Date(post.publishedDate), 'MMMM d, yyyy')} •{' '}
                      Scraped {format(new Date(post.scrapedAt), 'MMM d, yyyy')}
                    </div>
                  </div>
                  <a
                    href={post.postUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="btn btn-secondary btn-sm"
                  >
                    View on LinkedIn →
                  </a>
                </div>

                <div className="post-content">{post.content}</div>

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
                    <span>👍 Likes:</span>
                    <span className="post-stat-value">{post.likes || 0}</span>
                  </div>
                  <div className="post-stat">
                    <span>💬 Comments:</span>
                    <span className="post-stat-value">{post.comments || 0}</span>
                  </div>
                  <div className="post-stat">
                    <span>🔄 Shares:</span>
                    <span className="post-stat-value">{post.shares || 0}</span>
                  </div>
                  {post.mediaType !== 'none' && (
                    <div className="post-stat">
                      <span>📎 Media:</span>
                      <span className="post-stat-value">{post.mediaType}</span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Pagination */}
          {pagination.pages > 1 && (
            <div className="pagination">
              <button
                className="btn btn-secondary"
                onClick={() => handlePageChange(pagination.page - 1)}
                disabled={pagination.page === 1 || loading}
              >
                ← Previous
              </button>

              <div className="pagination-info">
                Page {pagination.page} of {pagination.pages} • {pagination.total} total posts
              </div>

              <button
                className="btn btn-secondary"
                onClick={() => handlePageChange(pagination.page + 1)}
                disabled={pagination.page === pagination.pages || loading}
              >
                Next →
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Posts;
