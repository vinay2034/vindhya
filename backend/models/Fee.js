const mongoose = require('mongoose');

const feeSchema = new mongoose.Schema({
  studentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Student',
    required: [true, 'Student reference is required']
  },
  academicYear: {
    type: String,
    required: [true, 'Academic year is required']
  },
  feeType: {
    type: String,
    enum: ['tuition', 'transport', 'library', 'sports', 'exam', 'hostel', 'other'],
    required: [true, 'Fee type is required'],
    default: 'tuition'
  },
  amount: {
    type: Number,
    required: [true, 'Amount is required'],
    min: 0
  },
  dueDate: {
    type: Date,
    required: [true, 'Due date is required']
  },
  status: {
    type: String,
    enum: ['paid', 'pending', 'overdue', 'partial'],
    default: 'pending'
  },
  paidAmount: {
    type: Number,
    default: 0,
    min: 0
  },
  paymentDate: {
    type: Date,
    default: null
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'online', 'cheque', 'bank_transfer', null],
    default: null
  },
  transactionId: {
    type: String,
    trim: true,
    default: null
  },
  receiptNumber: {
    type: String,
    trim: true,
    unique: true,
    sparse: true
  },
  discount: {
    type: Number,
    default: 0,
    min: 0
  },
  lateFee: {
    type: Number,
    default: 0,
    min: 0
  },
  remarks: {
    type: String,
    trim: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
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

// Indexes for efficient queries
feeSchema.index({ studentId: 1, academicYear: 1 });
feeSchema.index({ status: 1 });
feeSchema.index({ dueDate: 1 });

// Calculate total amount including discount and late fee
feeSchema.virtual('totalAmount').get(function() {
  return this.amount - this.discount + this.lateFee;
});

// Calculate remaining amount
feeSchema.virtual('remainingAmount').get(function() {
  return this.totalAmount - this.paidAmount;
});

module.exports = mongoose.model('Fee', feeSchema);
