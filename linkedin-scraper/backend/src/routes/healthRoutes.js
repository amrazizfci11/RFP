import express from 'express';
import { checkDBHealth } from '../config/database.js';

const router = express.Router();

/**
 * Health check endpoint
 * @route GET /api/v1/health
 * @access Public
 */
router.get('/', (req, res) => {
  const dbHealth = checkDBHealth();

  const health = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    database: dbHealth
  };

  const statusCode = dbHealth.isHealthy ? 200 : 503;

  res.status(statusCode).json({
    success: true,
    data: health
  });
});

export default router;
