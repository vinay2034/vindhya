const mongoose = require('mongoose');

const gallerySchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  type: {
    type: String,
    enum: ['photo', 'video'],
    required: [true, 'Media type is required']
  },
  url: {
    type: String,
    required: [true, 'Media URL is required']
  },
  thumbnail: {
    type: String,
    default: null
  },
  category: {
    type: String,
    enum: ['event', 'sports', 'academic', 'cultural', 'general'],
    default: 'general'
  },
  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Uploader reference is required']
  },
  tags: [{
    type: String,
    trim: true
  }],
  isPublic: {
    type: Boolean,
    default: true
  },
  uploadDate: {
    type: Date,
    default: Date.now
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for efficient queries
gallerySchema.index({ type: 1, category: 1 });
gallerySchema.index({ isPublic: 1 });
gallerySchema.index({ uploadDate: -1 });

module.exports = mongoose.model('Gallery', gallerySchema);
