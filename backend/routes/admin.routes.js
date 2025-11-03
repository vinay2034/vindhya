const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { verifyToken, authorize } = require('../middleware/auth.middleware');
const { 
  registerValidation, 
  studentValidation, 
  classValidation 
} = require('../middleware/validation.middleware');
const upload = require('../middleware/upload.middleware');

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

// Student photo upload
router.post('/students/:id/photo', upload.single('photo'), adminController.uploadStudentPhoto);

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

// Fee Management
router.route('/fees')
  .get(adminController.getFees)
  .post(adminController.createFee);

router.route('/fees/:id')
  .put(adminController.updateFee)
  .delete(adminController.deleteFee);

// Timetable Management
router.route('/timetable')
  .get(adminController.getTimetable)
  .post(adminController.createTimetable);

router.route('/timetable/:id')
  .put(adminController.updateTimetable)
  .delete(adminController.deleteTimetable);

// Reports
router.get('/reports/attendance', adminController.getAttendanceReport);
router.get('/reports/fees', adminController.getFeeReport);

module.exports = router;
