import express from 'express';
import {
  initializeScraper,
  scrapePosts,
  closeScraper,
  getAllPosts,
  getPostsByProfile,
  getPostById,
  deletePost,
  getScraperStatus
} from '../controllers/scraperController.js';
import { protect, authorize } from '../middleware/auth.js';
import {
  validateProfileUrl,
  validateLinkedInCredentials,
  validatePagination,
  validateObjectId
} from '../middleware/validation.js';
import { scraperRateLimiter } from '../middleware/security.js';

const router = express.Router();

// Scraper control routes (very strict rate limiting)
router.post('/login', protect, scraperRateLimiter, validateLinkedInCredentials, initializeScraper);
router.post('/scrape', protect, scraperRateLimiter, validateProfileUrl, scrapePosts);
router.post('/logout', protect, closeScraper);
router.get('/status', protect, getScraperStatus);

// Posts routes
router.get('/posts', protect, validatePagination, getAllPosts);
router.get('/posts/profile', protect, getPostsByProfile);
router.get('/posts/:id', protect, validateObjectId, getPostById);
router.delete('/posts/:id', protect, authorize('admin'), validateObjectId, deletePost);

export default router;
