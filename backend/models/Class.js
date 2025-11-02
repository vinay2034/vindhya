const mongoose = require('mongoose');

const classSchema = new mongoose.Schema({
  className: {
    type: String,
    required: [true, 'Class name is required'],
    trim: true
  },
  section: {
    type: String,
    required: [true, 'Section is required'],
    trim: true
  },
  classTeacher: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  subjects: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Subject'
  }],
  capacity: {
    type: Number,
    required: [true, 'Class capacity is required'],
    min: 1,
    default: 40
  },
  academicYear: {
    type: String,
    required: [true, 'Academic year is required']
  },
  room: {
    type: String,
    trim: true
  },
  schedule: {
    startTime: String,
    endTime: String
  },
  isActive: {
    type: Boolean,
    default: true
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

// Create compound index for unique class-section combination
classSchema.index({ className: 1, section: 1, academicYear: 1 }, { unique: true });

// Virtual for full class name
classSchema.virtual('fullClassName').get(function() {
  return `${this.className} - ${this.section}`;
});

module.exports = mongoose.model('Class', classSchema);
