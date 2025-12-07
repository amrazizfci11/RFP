import { body, param, query, validationResult } from 'express-validator';

/**
 * Handle validation errors
 */
export const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array().map(err => ({
        field: err.path,
        message: err.msg
      }))
    });
  }
  next();
};

/**
 * Validate user registration
 */
export const validateRegister = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores')
    .escape(),

  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail()
    .isLength({ max: 255 })
    .withMessage('Email cannot exceed 255 characters'),

  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),

  handleValidationErrors
];

/**
 * Validate user login
 */
export const validateLogin = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),

  body('password')
    .notEmpty()
    .withMessage('Password is required'),

  handleValidationErrors
];

/**
 * Validate LinkedIn profile URL
 */
export const validateProfileUrl = [
  body('profileUrl')
    .trim()
    .notEmpty()
    .withMessage('Profile URL is required')
    .matches(/^https?:\/\/(www\.)?linkedin\.com\/in\/[\w-]+\/?$/)
    .withMessage('Invalid LinkedIn profile URL format. Example: https://www.linkedin.com/in/username')
    .escape(),

  body('maxPosts')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('maxPosts must be between 1 and 100')
    .toInt(),

  handleValidationErrors
];

/**
 * Validate LinkedIn credentials
 */
export const validateLinkedInCredentials = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Please provide a valid LinkedIn email')
    .normalizeEmail(),

  body('password')
    .notEmpty()
    .withMessage('LinkedIn password is required'),

  handleValidationErrors
];

/**
 * Validate pagination parameters
 */
export const validatePagination = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer')
    .toInt(),

  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100')
    .toInt(),

  handleValidationErrors
];

/**
 * Validate MongoDB ObjectId
 */
export const validateObjectId = [
  param('id')
    .isMongoId()
    .withMessage('Invalid ID format'),

  handleValidationErrors
];

/**
 * Sanitize search query
 */
export const validateSearch = [
  query('q')
    .trim()
    .notEmpty()
    .withMessage('Search query is required')
    .isLength({ min: 1, max: 200 })
    .withMessage('Search query must be between 1 and 200 characters')
    .escape(),

  handleValidationErrors
];
