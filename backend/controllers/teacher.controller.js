const Student = require('../models/Student');
const Class = require('../models/Class');
const Attendance = require('../models/Attendance');
const Fee = require('../models/Fee');

// @desc    Get teacher dashboard
// @route   GET /api/teacher/dashboard
// @access  Private/Teacher
const getDashboard = async (req, res) => {
  try {
    const teacherId = req.user.id;
    
    // Get classes where teacher is class teacher
    const classes = await Class.find({ classTeacher: teacherId })
      .populate('subjects', 'name code');
    
    // Get total students in teacher's classes
    const classIds = classes.map(cls => cls._id);
    const totalStudents = await Student.countDocuments({ 
      classId: { $in: classIds },
      isActive: true 
    });
    
    // Get today's attendance stats
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const todayAttendance = await Attendance.aggregate([
      {
        $match: {
          classId: { $in: classIds },
          date: { $gte: today }
        }
      },
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
        classes,
        totalStudents,
        todayAttendance
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

// @desc    Get classes assigned to teacher
// @route   GET /api/teacher/classes
// @access  Private/Teacher
const getClasses = async (req, res) => {
  try {
    const teacherId = req.user.id;
    
    const classes = await Class.find({ classTeacher: teacherId })
      .populate('subjects', 'name code')
      .sort({ className: 1, section: 1 });
    
    res.status(200).json({
      status: 'success',
      data: classes
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch classes',
      error: error.message
    });
  }
};

// @desc    Get teacher's subjects
// @route   GET /api/teacher/subjects
// @access  Private/Teacher
const getSubjects = async (req, res) => {
  try {
    const teacherId = req.user.id;
    const User = require('../models/User');
    const Subject = require('../models/Subject');
    
    const teacher = await User.findById(teacherId).populate('subjectsTaught', 'name code');
    
    if (!teacher || !teacher.subjectsTaught) {
      return res.status(200).json({
        status: 'success',
        data: []
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: teacher.subjectsTaught
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch subjects',
      error: error.message
    });
  }
};

// @desc    Get students by class
// @route   GET /api/teacher/students/:classId
// @access  Private/Teacher
const getStudentsByClass = async (req, res) => {
  try {
    const { classId } = req.params;
    
    const students = await Student.find({ classId, isActive: true })
      .populate('parentId', 'profile.name profile.phone email')
      .sort({ rollNumber: 1 });
    
    res.status(200).json({
      status: 'success',
      data: { students }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch students',
      error: error.message
    });
  }
};

// ATTENDANCE MANAGEMENT
// @desc    Mark attendance
// @route   POST /api/teacher/attendance
// @access  Private/Teacher
const markAttendance = async (req, res) => {
  try {
    const { studentId, classId, date, status, remarks } = req.body;
    
    // Check if attendance already exists for this student and date
    const existingAttendance = await Attendance.findOne({
      studentId,
      date: new Date(date)
    });
    
    if (existingAttendance) {
      // Update existing attendance
      existingAttendance.status = status;
      existingAttendance.remarks = remarks;
      existingAttendance.markedBy = req.user.id;
      await existingAttendance.save();
      
      return res.status(200).json({
        status: 'success',
        message: 'Attendance updated successfully',
        data: { attendance: existingAttendance }
      });
    }
    
    // Create new attendance record
    const attendance = await Attendance.create({
      studentId,
      classId,
      date,
      status,
      remarks,
      markedBy: req.user.id
    });
    
    res.status(201).json({
      status: 'success',
      message: 'Attendance marked successfully',
      data: { attendance }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to mark attendance',
      error: error.message
    });
  }
};

// @desc    Mark bulk attendance
// @route   POST /api/teacher/attendance/bulk
// @access  Private/Teacher
const markBulkAttendance = async (req, res) => {
  try {
    const { classId, date, attendanceList } = req.body;
    // attendanceList: [{ studentId, status, remarks }]
    
    // Parse the date string (YYYY-MM-DD format) and create date at midnight UTC
    const dateParts = date.split('T')[0].split('-'); // Get YYYY-MM-DD part
    const attendanceDate = new Date(Date.UTC(
      parseInt(dateParts[0]), 
      parseInt(dateParts[1]) - 1, 
      parseInt(dateParts[2]),
      0, 0, 0, 0
    ));
    
    console.log('Marking attendance for date:', attendanceDate, 'from input:', date);
    
    const bulkOps = attendanceList.map(item => ({
      updateOne: {
        filter: { 
          studentId: item.studentId, 
          date: attendanceDate,
          classId: classId
        },
        update: {
          $set: {
            classId,
            status: item.status,
            remarks: item.remarks || '',
            markedBy: req.user.id,
            markedAt: new Date()
          }
        },
        upsert: true
      }
    }));
    
    await Attendance.bulkWrite(bulkOps);
    
    console.log('Bulk attendance marked for', attendanceList.length, 'students');
    
    res.status(200).json({
      status: 'success',
      message: 'Bulk attendance marked successfully'
    });
  } catch (error) {
    console.error('Error in markBulkAttendance:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to mark bulk attendance',
      error: error.message
    });
  }
};

// @desc    Get attendance by class and date range
// @route   GET /api/teacher/attendance
// @access  Private/Teacher
const getAttendance = async (req, res) => {
  try {
    const { classId, startDate, endDate } = req.query;
    
    const query = { classId };
    if (startDate && endDate) {
      query.date = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const attendance = await Attendance.find(query)
      .populate('studentId', 'name rollNumber')
      .sort({ date: -1 });
    
    res.status(200).json({
      status: 'success',
      data: { attendance }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch attendance',
      error: error.message
    });
  }
};

// FEE MANAGEMENT
// @desc    Get fees for a student
// @route   GET /api/teacher/fees/:studentId
// @access  Private/Teacher
const getStudentFees = async (req, res) => {
  try {
    const { studentId } = req.params;
    
    const fees = await Fee.find({ studentId })
      .sort({ dueDate: -1 });
    
    res.status(200).json({
      status: 'success',
      data: { fees }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch fees',
      error: error.message
    });
  }
};

// @desc    Update fee payment status
// @route   PUT /api/teacher/fees/:feeId
// @access  Private/Teacher
const updateFeeStatus = async (req, res) => {
  try {
    const { feeId } = req.params;
    const { status, paidAmount, paymentMethod, paymentDate, transactionId, remarks } = req.body;
    
    const fee = await Fee.findById(feeId);
    
    if (!fee) {
      return res.status(404).json({
        status: 'error',
        message: 'Fee record not found'
      });
    }
    
    fee.status = status;
    fee.paidAmount = paidAmount || fee.paidAmount;
    fee.paymentMethod = paymentMethod;
    fee.paymentDate = paymentDate || new Date();
    fee.transactionId = transactionId;
    fee.remarks = remarks;
    fee.updatedBy = req.user.id;
    
    await fee.save();
    
    res.status(200).json({
      status: 'success',
      message: 'Fee status updated successfully',
      data: { fee }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update fee status',
      error: error.message
    });
  }
};

// @desc    Get teacher assignments (classes and subjects)
// @route   GET /api/teacher/assignments
// @access  Private/Teacher
const getAssignments = async (req, res) => {
  try {
    const teacherId = req.user.id;
    const User = require('../models/User');
    const Subject = require('../models/Subject');
    
    // Get teacher user to access subjectsTaught and assignedClasses
    const teacher = await User.findById(teacherId)
      .populate('assignedClasses', 'name grade section')
      .populate('subjectsTaught', 'name code');
    
    if (!teacher) {
      return res.status(404).json({
        status: 'error',
        message: 'Teacher not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: {
        classes: teacher.assignedClasses || [],
        subjects: teacher.subjectsTaught || []
      }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch teacher assignments',
      error: error.message
    });
  }
};

// @desc    Get student details
// @route   GET /api/teacher/student/:id
// @access  Private/Teacher
const getStudentDetails = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id)
      .populate('parentId', 'email profile')
      .populate('classId', 'className section grade');
    
    if (!student) {
      return res.status(404).json({
        status: 'error',
        message: 'Student not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: student
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch student details',
      error: error.message
    });
  }
};

// @desc    Get today's attendance summary for teacher's classes
// @route   GET /api/teacher/attendance/today
// @access  Private/Teacher
const getTodayAttendance = async (req, res) => {
  try {
    const teacherId = req.user.id;
    
    // Get teacher's classes
    const classes = await Class.find({ classTeacher: teacherId });
    const classIds = classes.map(cls => cls._id);
    
    // Get today's date in UTC (to match attendance save format)
    const today = new Date();
    const startOfDay = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0, 0));
    const endOfDay = new Date(Date.UTC(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59, 999));
    
    console.log('Searching attendance between:', startOfDay, 'and', endOfDay);
    
    // Get today's attendance records
    const attendanceRecords = await Attendance.find({
      classId: { $in: classIds },
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    });
    
    console.log('Found attendance records:', attendanceRecords.length);
    
    // Count present and absent
    let presentCount = 0;
    let absentCount = 0;
    
    attendanceRecords.forEach(record => {
      const status = record.status.toLowerCase();
      if (status === 'present') {
        presentCount++;
      } else if (status === 'absent') {
        absentCount++;
      }
    });
    
    // Get total students
    const totalStudents = await Student.countDocuments({
      classId: { $in: classIds },
      isActive: true
    });
    
    console.log('Today attendance - Present:', presentCount, 'Absent:', absentCount, 'Total:', totalStudents);
    
    res.status(200).json({
      status: 'success',
      data: {
        present: presentCount,
        absent: absentCount,
        total: totalStudents,
        percentage: totalStudents > 0 ? Math.round((presentCount / totalStudents) * 100) : 0
      }
    });
  } catch (error) {
    console.error('Error in getTodayAttendance:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch today\'s attendance',
      error: error.message
    });
  }
};

// @desc    Get attendance for a specific student
// @route   GET /api/teacher/attendance/student/:studentId
// @access  Private/Teacher
const getStudentAttendance = async (req, res) => {
  try {
    const { studentId } = req.params;
    const { days = 7 } = req.query; // Default to last 7 days
    
    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));
    
    const attendance = await Attendance.find({
      studentId,
      date: {
        $gte: startDate,
        $lte: endDate
      }
    }).sort({ date: -1 });
    
    res.status(200).json({
      status: 'success',
      data: { attendance }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch student attendance',
      error: error.message
    });
  }
};

module.exports = {
  getDashboard,
  getAssignments,
  getClasses,
  getSubjects,
  getStudentsByClass,
  getStudentDetails,
  markAttendance,
  markBulkAttendance,
  getAttendance,
  getTodayAttendance,
  getStudentAttendance,
  getStudentFees,
  updateFeeStatus
};
