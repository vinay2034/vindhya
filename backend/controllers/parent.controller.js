const Student = require('../models/Student');
const Attendance = require('../models/Attendance');
const Fee = require('../models/Fee');
const Gallery = require('../models/Gallery');

// @desc    Get parent dashboard
// @route   GET /api/parent/dashboard
// @access  Private/Parent
const getDashboard = async (req, res) => {
  try {
    const parentId = req.user.id;
    
    // Get all children
    const students = await Student.find({ parentId, isActive: true })
      .populate('classId', 'className section');
    
    // Get attendance summary for current month
    const firstDayOfMonth = new Date();
    firstDayOfMonth.setDate(1);
    firstDayOfMonth.setHours(0, 0, 0, 0);
    
    const studentIds = students.map(s => s._id);
    
    const attendanceSummary = await Attendance.aggregate([
      {
        $match: {
          studentId: { $in: studentIds },
          date: { $gte: firstDayOfMonth }
        }
      },
      {
        $group: {
          _id: { studentId: '$studentId', status: '$status' },
          count: { $sum: 1 }
        }
      }
    ]);
    
    // Get pending fees
    const pendingFees = await Fee.find({
      studentId: { $in: studentIds },
      status: { $in: ['pending', 'overdue'] }
    });
    
    res.status(200).json({
      status: 'success',
      data: {
        students,
        attendanceSummary,
        pendingFees
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch dashboard data',
      error: error.message
    });
  }
};

// @desc    Get children of parent
// @route   GET /api/parent/children
// @access  Private/Parent
const getChildren = async (req, res) => {
  try {
    const parentId = req.user.id;
    
    const students = await Student.find({ parentId, isActive: true })
      .populate('classId', 'className section classTeacher')
      .sort({ name: 1 });
    
    res.status(200).json({
      status: 'success',
      data: { students }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch children',
      error: error.message
    });
  }
};

// ATTENDANCE
// @desc    Get attendance for a student
// @route   GET /api/parent/attendance/:studentId
// @access  Private/Parent
const getAttendance = async (req, res) => {
  try {
    const { studentId } = req.params;
    const { startDate, endDate } = req.query;
    
    // Verify student belongs to parent
    const student = await Student.findOne({
      _id: studentId,
      parentId: req.user.id
    });
    
    if (!student) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }
    
    const query = { studentId };
    if (startDate && endDate) {
      query.date = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const attendance = await Attendance.find(query)
      .sort({ date: -1 })
      .limit(100);
    
    // Calculate statistics
    const stats = await Attendance.aggregate([
      { $match: { studentId: student._id } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        attendance,
        stats
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch attendance',
      error: error.message
    });
  }
};

// FEES
// @desc    Get fees for a student
// @route   GET /api/parent/fees/:studentId
// @access  Private/Parent
const getFees = async (req, res) => {
  try {
    const { studentId } = req.params;
    
    // Verify student belongs to parent
    const student = await Student.findOne({
      _id: studentId,
      parentId: req.user.id
    });
    
    if (!student) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }
    
    const fees = await Fee.find({ studentId })
      .sort({ dueDate: -1 });
    
    // Calculate summary
    const summary = await Fee.aggregate([
      { $match: { studentId: student._id } },
      {
        $group: {
          _id: '$status',
          totalAmount: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      }
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        fees,
        summary
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch fees',
      error: error.message
    });
  }
};

// @desc    Initiate fee payment
// @route   POST /api/parent/fees/pay
// @access  Private/Parent
const initiatePayment = async (req, res) => {
  try {
    const { feeId, amount, paymentMethod } = req.body;
    
    const fee = await Fee.findById(feeId).populate('studentId');
    
    if (!fee) {
      return res.status(404).json({
        status: 'error',
        message: 'Fee record not found'
      });
    }
    
    // Verify student belongs to parent
    if (fee.studentId.parentId.toString() !== req.user.id) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }
    
    // In production, integrate with payment gateway (Razorpay/Stripe)
    // For now, we'll simulate a successful payment
    
    const transactionId = `TXN${Date.now()}`;
    
    fee.status = 'paid';
    fee.paidAmount = amount;
    fee.paymentMethod = paymentMethod;
    fee.paymentDate = new Date();
    fee.transactionId = transactionId;
    fee.receiptNumber = `REC${Date.now()}`;
    
    await fee.save();
    
    res.status(200).json({
      status: 'success',
      message: 'Payment successful',
      data: {
        fee,
        transactionId,
        receiptNumber: fee.receiptNumber
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Payment failed',
      error: error.message
    });
  }
};

// GALLERY
// @desc    Get gallery items
// @route   GET /api/parent/gallery
// @access  Private/Parent
const getGallery = async (req, res) => {
  try {
    const { type, category, page = 1, limit = 20 } = req.query;
    
    const query = { isPublic: true };
    if (type) query.type = type;
    if (category) query.category = category;
    
    const gallery = await Gallery.find(query)
      .sort({ uploadDate: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const count = await Gallery.countDocuments(query);
    
    res.status(200).json({
      status: 'success',
      data: {
        gallery,
        totalPages: Math.ceil(count / limit),
        currentPage: page,
        total: count
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch gallery',
      error: error.message
    });
  }
};

// @desc    Get student progress/academic info
// @route   GET /api/parent/progress/:studentId
// @access  Private/Parent
const getStudentProgress = async (req, res) => {
  try {
    const { studentId } = req.params;
    
    // Verify student belongs to parent
    const student = await Student.findOne({
      _id: studentId,
      parentId: req.user.id
    }).populate('classId');
    
    if (!student) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }
    
    // Get recent attendance
    const recentAttendance = await Attendance.find({ studentId })
      .sort({ date: -1 })
      .limit(30);
    
    // Calculate attendance percentage
    const presentCount = recentAttendance.filter(a => a.status === 'present').length;
    const attendancePercentage = recentAttendance.length > 0 
      ? ((presentCount / recentAttendance.length) * 100).toFixed(2)
      : 0;
    
    res.status(200).json({
      status: 'success',
      data: {
        student,
        attendancePercentage,
        recentAttendance: recentAttendance.slice(0, 10)
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch student progress',
      error: error.message
    });
  }
};

module.exports = {
  getDashboard,
  getChildren,
  getAttendance,
  getFees,
  initiatePayment,
  getGallery,
  getStudentProgress
};
