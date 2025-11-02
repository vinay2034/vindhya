const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { verifyToken, authorize } = require('../middleware/auth.middleware');
const { 
  registerValidation, 
  studentValidation, 
  classValidation 
} = require('../middleware/validation.middleware');

// Apply authentication and admin authorization to all routes
router.use(verifyToken, authorize('admin'));

// Dashboard
router.get('/dashboard', adminController.getDashboard);

// User Management
router.route('/users')
  .get(adminController.getUsers)
  .post(registerValidation, adminController.createUser);

router.route('/users/:id')
  .put(adminController.updateUser)
  .delete(adminController.deleteUser);

// Student Management
router.route('/students')
  .get(adminController.getStudents)
  .post(studentValidation, adminController.createStudent);

router.route('/students/:id')
  .put(adminController.updateStudent)
  .delete(adminController.deleteStudent);

// Class Management
router.route('/classes')
  .get(adminController.getClasses)
  .post(classValidation, adminController.createClass);

router.route('/classes/:id')
  .put(adminController.updateClass)
  .delete(adminController.deleteClass);

// Subject Management
router.route('/subjects')
  .get(adminController.getSubjects)
  .post(adminController.createSubject);

router.route('/subjects/:id')
  .put(adminController.updateSubject)
  .delete(adminController.deleteSubject);

// Reports
router.get('/reports/attendance', adminController.getAttendanceReport);
router.get('/reports/fees', adminController.getFeeReport);

module.exports = router;
