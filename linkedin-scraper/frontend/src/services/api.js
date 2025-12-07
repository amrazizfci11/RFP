import axios from 'axios';
import DOMPurify from 'dompurify';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

// Create axios instance
const api = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Clear token and redirect to login
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

/**
 * Sanitize input to prevent XSS
 */
const sanitizeInput = (input) => {
  if (typeof input === 'string') {
    return DOMPurify.sanitize(input, { ALLOWED_TAGS: [] });
  }
  return input;
};

/**
 * Auth API
 */
export const authAPI = {
  register: async (userData) => {
    const sanitized = {
      username: sanitizeInput(userData.username),
      email: sanitizeInput(userData.email),
      password: userData.password
    };
    const response = await api.post('/auth/register', sanitized);
    return response.data;
  },

  login: async (credentials) => {
    const sanitized = {
      email: sanitizeInput(credentials.email),
      password: credentials.password
    };
    const response = await api.post('/auth/login', sanitized);
    return response.data;
  },

  logout: async () => {
    const response = await api.post('/auth/logout');
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    return response.data;
  },

  getMe: async () => {
    const response = await api.get('/auth/me');
    return response.data;
  }
};

/**
 * Scraper API
 */
export const scraperAPI = {
  login: async (credentials) => {
    const sanitized = {
      email: sanitizeInput(credentials.email),
      password: credentials.password
    };
    const response = await api.post('/scraper/login', sanitized);
    return response.data;
  },

  scrape: async (profileUrl, maxPosts = 50) => {
    const sanitized = {
      profileUrl: sanitizeInput(profileUrl),
      maxPosts: parseInt(maxPosts)
    };
    const response = await api.post('/scraper/scrape', sanitized);
    return response.data;
  },

  logout: async () => {
    const response = await api.post('/scraper/logout');
    return response.data;
  },

  getStatus: async () => {
    const response = await api.get('/scraper/status');
    return response.data;
  }
};

/**
 * Posts API
 */
export const postsAPI = {
  getAll: async (page = 1, limit = 20) => {
    const response = await api.get('/scraper/posts', {
      params: { page, limit }
    });
    return response.data;
  },

  getByProfile: async (profileUrl, limit = 50) => {
    const response = await api.get('/scraper/posts/profile', {
      params: { profileUrl: sanitizeInput(profileUrl), limit }
    });
    return response.data;
  },

  getById: async (id) => {
    const response = await api.get(`/scraper/posts/${id}`);
    return response.data;
  },

  delete: async (id) => {
    const response = await api.delete(`/scraper/posts/${id}`);
    return response.data;
  }
};

/**
 * Health API
 */
export const healthAPI = {
  check: async () => {
    const response = await api.get('/health');
    return response.data;
  }
};

export default api;
