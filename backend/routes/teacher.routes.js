const express = require('express');
const router = express.Router();
const teacherController = require('../controllers/teacher.controller');
const { verifyToken, authorize } = require('../middleware/auth.middleware');
const { attendanceValidation } = require('../middleware/validation.middleware');

// Apply authentication and teacher authorization to all routes
router.use(verifyToken, authorize('teacher'));

// Dashboard
router.get('/dashboard', teacherController.getDashboard);

// Assignments (Classes & Subjects)
router.get('/assignments', teacherController.getAssignments);

// Classes
router.get('/classes', teacherController.getClasses);
router.get('/subjects', teacherController.getSubjects);
router.get('/students/:classId', teacherController.getStudentsByClass);

// Student Details
router.get('/student/:id', teacherController.getStudentDetails);

// Attendance
router.post('/attendance', attendanceValidation, teacherController.markAttendance);
router.post('/attendance/bulk', teacherController.markBulkAttendance);
router.get('/attendance', teacherController.getAttendance);
router.get('/attendance/today', teacherController.getTodayAttendance);
router.get('/attendance/student/:studentId', teacherController.getStudentAttendance);

// Fees
router.get('/fees/:studentId', teacherController.getStudentFees);
router.put('/fees/:feeId', teacherController.updateFeeStatus);

module.exports = router;
