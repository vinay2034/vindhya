const express = require('express');
const router = express.Router();
const parentController = require('../controllers/parent.controller');
const { verifyToken, authorize } = require('../middleware/auth.middleware');

// Apply authentication and parent authorization to all routes
router.use(verifyToken, authorize('parent'));

// Dashboard
router.get('/dashboard', parentController.getDashboard);
router.get('/children', parentController.getChildren);

// Attendance
router.get('/attendance/:studentId', parentController.getAttendance);

// Fees
router.get('/fees/:studentId', parentController.getFees);
router.post('/fees/pay', parentController.initiatePayment);

// Gallery
router.get('/gallery', parentController.getGallery);

// Student Progress
router.get('/progress/:studentId', parentController.getStudentProgress);

module.exports = router;
