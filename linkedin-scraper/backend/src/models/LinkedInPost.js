import mongoose from 'mongoose';

const linkedInPostSchema = new mongoose.Schema({
  profileUrl: {
    type: String,
    required: [true, 'Profile URL is required'],
    trim: true,
    validate: {
      validator: function(v) {
        return /^https?:\/\/(www\.)?linkedin\.com\/in\/[\w-]+\/?$/.test(v);
      },
      message: 'Invalid LinkedIn profile URL format'
    }
  },
  profileName: {
    type: String,
    required: true,
    trim: true,
    maxlength: [200, 'Profile name cannot exceed 200 characters']
  },
  postId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  postUrl: {
    type: String,
    required: true,
    trim: true
  },
  content: {
    type: String,
    required: true,
    maxlength: [10000, 'Content cannot exceed 10000 characters']
  },
  publishedDate: {
    type: Date,
    required: true,
    index: true
  },
  likes: {
    type: Number,
    default: 0,
    min: [0, 'Likes cannot be negative']
  },
  comments: {
    type: Number,
    default: 0,
    min: [0, 'Comments cannot be negative']
  },
  shares: {
    type: Number,
    default: 0,
    min: [0, 'Shares cannot be negative']
  },
  mediaType: {
    type: String,
    enum: ['none', 'image', 'video', 'document', 'poll', 'article'],
    default: 'none'
  },
  mediaUrl: {
    type: String,
    trim: true
  },
  hashtags: [{
    type: String,
    trim: true,
    maxlength: [50, 'Hashtag cannot exceed 50 characters']
  }],
  scrapedAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for efficient queries
linkedInPostSchema.index({ profileUrl: 1, publishedDate: -1 });
linkedInPostSchema.index({ scrapedAt: -1 });

// Virtual for engagement rate
linkedInPostSchema.virtual('engagementRate').get(function() {
  const total = this.likes + this.comments + this.shares;
  return total;
});

// Update lastUpdated timestamp before saving
linkedInPostSchema.pre('save', function(next) {
  this.lastUpdated = Date.now();
  next();
});

// Static method to get posts by profile
linkedInPostSchema.statics.getByProfile = function(profileUrl, limit = 50) {
  return this.find({ profileUrl })
    .sort({ publishedDate: -1 })
    .limit(limit)
    .select('-__v');
};

// Static method to get recent posts
linkedInPostSchema.statics.getRecent = function(limit = 20) {
  return this.find()
    .sort({ scrapedAt: -1 })
    .limit(limit)
    .select('-__v');
};

const LinkedInPost = mongoose.model('LinkedInPost', linkedInPostSchema);

export default LinkedInPost;
