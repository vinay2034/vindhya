const express = require('express');
const router = express.Router();
const teacherController = require('../controllers/teacher.controller');
const { verifyToken, authorize } = require('../middleware/auth.middleware');
const { attendanceValidation } = require('../middleware/validation.middleware');

// Apply authentication and teacher authorization to all routes
router.use(verifyToken, authorize('teacher'));

// Dashboard
router.get('/dashboard', teacherController.getDashboard);

// Classes
router.get('/classes', teacherController.getClasses);
router.get('/students/:classId', teacherController.getStudentsByClass);

// Attendance
router.post('/attendance', attendanceValidation, teacherController.markAttendance);
router.post('/attendance/bulk', teacherController.markBulkAttendance);
router.get('/attendance', teacherController.getAttendance);

// Fees
router.get('/fees/:studentId', teacherController.getStudentFees);
router.put('/fees/:feeId', teacherController.updateFeeStatus);

module.exports = router;
