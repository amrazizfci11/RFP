import mongoose from 'mongoose';
import { logger } from '../utils/logger.js';

/**
 * Connect to MongoDB with security best practices
 */
export const connectDB = async () => {
  try {
    const options = {
      // Connection pool settings
      maxPoolSize: 10,
      minPoolSize: 2,
      socketTimeoutMS: 45000,
      serverSelectionTimeoutMS: 5000,

      // Security settings
      authSource: 'admin',
      retryWrites: true,
      w: 'majority',

      // Other settings
      useNewUrlParser: true,
      useUnifiedTopology: true,
    };

    // Build connection string
    let mongoUri = process.env.MONGODB_URI;

    if (process.env.MONGODB_USER && process.env.MONGODB_PASSWORD) {
      const user = encodeURIComponent(process.env.MONGODB_USER);
      const pass = encodeURIComponent(process.env.MONGODB_PASSWORD);
      mongoUri = mongoUri.replace('mongodb://', `mongodb://${user}:${pass}@`);
    }

    const conn = await mongoose.connect(mongoUri, options);

    logger.info(`MongoDB Connected: ${conn.connection.host}`);

    // Handle connection events
    mongoose.connection.on('error', (err) => {
      logger.error(`MongoDB connection error: ${err}`);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });

    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('MongoDB connection closed through app termination');
      process.exit(0);
    });

    return conn;
  } catch (error) {
    logger.error(`MongoDB connection failed: ${error.message}`);
    process.exit(1);
  }
};

/**
 * Check database connection health
 */
export const checkDBHealth = () => {
  const state = mongoose.connection.readyState;
  const states = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
  };

  return {
    status: states[state] || 'unknown',
    isHealthy: state === 1
  };
};
