const User = require('../models/User');
const Student = require('../models/Student');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Attendance = require('../models/Attendance');
const Fee = require('../models/Fee');
const Timetable = require('../models/Timetable');
const Gallery = require('../models/Gallery');

// @desc    Get admin dashboard statistics
// @route   GET /api/admin/dashboard
// @access  Private/Admin
const getDashboard = async (req, res) => {
  try {
    const [totalStudents, totalTeachers, totalClasses, activeClasses] = await Promise.all([
      Student.countDocuments({ isActive: true }),
      User.countDocuments({ role: 'teacher', isActive: true }),
      Class.countDocuments(),
      Class.countDocuments({ isActive: true })
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        totalStudents,
        totalTeachers,
        totalClasses,
        activeClasses
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

// USER MANAGEMENT
// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private/Admin
const getUsers = async (req, res) => {
  try {
    const { role, isActive, page = 1, limit = 10 } = req.query;
    
    const query = {};
    if (role) query.role = role;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    
    const users = await User.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const count = await User.countDocuments(query);
    
    res.status(200).json({
      status: 'success',
      data: {
        users,
        totalPages: Math.ceil(count / limit),
        currentPage: page,
        total: count
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch users',
      error: error.message
    });
  }
};

// @desc    Create new user
// @route   POST /api/admin/users
// @access  Private/Admin
const createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    
    res.status(201).json({
      status: 'success',
      message: 'User created successfully',
      data: { user }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to create user',
      error: error.message
    });
  }
};

// @desc    Update user
// @route   PUT /api/admin/users/:id
// @access  Private/Admin
const updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'User updated successfully',
      data: { user }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update user',
      error: error.message
    });
  }
};

// @desc    Delete user
// @route   DELETE /api/admin/users/:id
// @access  Private/Admin
const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'User deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete user',
      error: error.message
    });
  }
};

// STUDENT MANAGEMENT
// @desc    Get all students
// @route   GET /api/admin/students
// @access  Private/Admin
const getStudents = async (req, res) => {
  try {
    const { classId, isActive, page = 1, limit = 10 } = req.query;
    
    const query = {};
    if (classId) query.classId = classId;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    
    const students = await Student.find(query)
      .populate('parentId', 'email profile')
      .populate('classId', 'className section')
      .sort({ name: 1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const count = await Student.countDocuments(query);
    
    res.status(200).json({
      status: 'success',
      data: {
        students,
        totalPages: Math.ceil(count / limit),
        currentPage: page,
        total: count
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch students',
      error: error.message
    });
  }
};

// @desc    Create new student
// @route   POST /api/admin/students
// @access  Private/Admin
const createStudent = async (req, res) => {
  try {
    const student = await Student.create(req.body);
    
    res.status(201).json({
      status: 'success',
      message: 'Student created successfully',
      data: { student }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to create student',
      error: error.message
    });
  }
};

// @desc    Update student
// @route   PUT /api/admin/students/:id
// @access  Private/Admin
const updateStudent = async (req, res) => {
  try {
    const student = await Student.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!student) {
      return res.status(404).json({
        status: 'error',
        message: 'Student not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Student updated successfully',
      data: { student }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update student',
      error: error.message
    });
  }
};

// @desc    Delete student
// @route   DELETE /api/admin/students/:id
// @access  Private/Admin
const deleteStudent = async (req, res) => {
  try {
    const student = await Student.findByIdAndDelete(req.params.id);
    
    if (!student) {
      return res.status(404).json({
        status: 'error',
        message: 'Student not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Student deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete student',
      error: error.message
    });
  }
};

// CLASS MANAGEMENT
// @desc    Get all classes
// @route   GET /api/admin/classes
// @access  Private/Admin
const getClasses = async (req, res) => {
  try {
    const classes = await Class.find()
      .populate('classTeacher', 'profile.name email')
      .populate('subjects', 'name code')
      .sort({ className: 1, section: 1 });
    
    res.status(200).json({
      status: 'success',
      data: { classes }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch classes',
      error: error.message
    });
  }
};

// @desc    Create new class
// @route   POST /api/admin/classes
// @access  Private/Admin
const createClass = async (req, res) => {
  try {
    const classData = await Class.create(req.body);
    
    res.status(201).json({
      status: 'success',
      message: 'Class created successfully',
      data: { class: classData }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to create class',
      error: error.message
    });
  }
};

// @desc    Update class
// @route   PUT /api/admin/classes/:id
// @access  Private/Admin
const updateClass = async (req, res) => {
  try {
    const classData = await Class.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!classData) {
      return res.status(404).json({
        status: 'error',
        message: 'Class not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Class updated successfully',
      data: { class: classData }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update class',
      error: error.message
    });
  }
};

// @desc    Delete class
// @route   DELETE /api/admin/classes/:id
// @access  Private/Admin
const deleteClass = async (req, res) => {
  try {
    const classData = await Class.findByIdAndDelete(req.params.id);
    
    if (!classData) {
      return res.status(404).json({
        status: 'error',
        message: 'Class not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Class deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete class',
      error: error.message
    });
  }
};

// SUBJECT MANAGEMENT
// @desc    Get all subjects
// @route   GET /api/admin/subjects
// @access  Private/Admin
const getSubjects = async (req, res) => {
  try {
    const subjects = await Subject.find()
      .populate('teachers', 'profile.name email')
      .sort({ name: 1 });
    
    res.status(200).json({
      status: 'success',
      data: { subjects }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch subjects',
      error: error.message
    });
  }
};

// @desc    Create new subject
// @route   POST /api/admin/subjects
// @access  Private/Admin
const createSubject = async (req, res) => {
  try {
    const subject = await Subject.create(req.body);
    
    res.status(201).json({
      status: 'success',
      message: 'Subject created successfully',
      data: { subject }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to create subject',
      error: error.message
    });
  }
};

// @desc    Update subject
// @route   PUT /api/admin/subjects/:id
// @access  Private/Admin
const updateSubject = async (req, res) => {
  try {
    const subject = await Subject.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!subject) {
      return res.status(404).json({
        status: 'error',
        message: 'Subject not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Subject updated successfully',
      data: { subject }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update subject',
      error: error.message
    });
  }
};

// @desc    Delete subject
// @route   DELETE /api/admin/subjects/:id
// @access  Private/Admin
const deleteSubject = async (req, res) => {
  try {
    const subject = await Subject.findByIdAndDelete(req.params.id);
    
    if (!subject) {
      return res.status(404).json({
        status: 'error',
        message: 'Subject not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Subject deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete subject',
      error: error.message
    });
  }
};

// REPORTS
// @desc    Get attendance report
// @route   GET /api/admin/reports/attendance
// @access  Private/Admin
const getAttendanceReport = async (req, res) => {
  try {
    const { classId, startDate, endDate } = req.query;
    
    const query = {};
    if (classId) query.classId = classId;
    if (startDate && endDate) {
      query.date = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const attendanceData = await Attendance.find(query)
      .populate('studentId', 'name rollNumber')
      .populate('classId', 'className section')
      .sort({ date: -1 });
    
    res.status(200).json({
      status: 'success',
      data: { attendanceData }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch attendance report',
      error: error.message
    });
  }
};

// @desc    Get fee report
// @route   GET /api/admin/reports/fees
// @access  Private/Admin
const getFeeReport = async (req, res) => {
  try {
    const { status, academicYear } = req.query;
    
    const query = {};
    if (status) query.status = status;
    if (academicYear) query.academicYear = academicYear;
    
    const feeData = await Fee.find(query)
      .populate('studentId', 'name rollNumber')
      .sort({ dueDate: -1 });
    
    const summary = await Fee.aggregate([
      { $match: query },
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
        feeData,
        summary
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch fee report',
      error: error.message
    });
  }
};

module.exports = {
  getDashboard,
  getUsers,
  createUser,
  updateUser,
  deleteUser,
  getStudents,
  createStudent,
  updateStudent,
  deleteStudent,
  getClasses,
  createClass,
  updateClass,
  deleteClass,
  getSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
  getAttendanceReport,
  getFeeReport
};
