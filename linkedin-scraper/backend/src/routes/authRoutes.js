import express from 'express';
import {
  register,
  login,
  getMe,
  logout
} from '../controllers/authController.js';
import { protect } from '../middleware/auth.js';
import { validateRegister, validateLogin } from '../middleware/validation.js';
import { strictRateLimiter } from '../middleware/security.js';

const router = express.Router();

// Public routes with strict rate limiting
router.post('/register', strictRateLimiter, validateRegister, register);
router.post('/login', strictRateLimiter, validateLogin, login);

// Protected routes
router.get('/me', protect, getMe);
router.post('/logout', protect, logout);

export default router;
