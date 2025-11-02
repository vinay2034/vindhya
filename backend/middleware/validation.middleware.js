const { body, validationResult } = require('express-validator');

// Validation error handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg
      }))
    });
  }
  
  next();
};

// Login validation
const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  handleValidationErrors
];

// Register validation
const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  body('role')
    .isIn(['admin', 'teacher', 'parent'])
    .withMessage('Invalid role'),
  body('profile.name')
    .notEmpty()
    .withMessage('Name is required')
    .trim(),
  body('profile.phone')
    .notEmpty()
    .withMessage('Phone number is required')
    .isMobilePhone()
    .withMessage('Please provide a valid phone number'),
  handleValidationErrors
];

// Student validation
const studentValidation = [
  body('name')
    .notEmpty()
    .withMessage('Student name is required')
    .trim(),
  body('rollNumber')
    .notEmpty()
    .withMessage('Roll number is required')
    .trim(),
  body('admissionNumber')
    .notEmpty()
    .withMessage('Admission number is required')
    .trim(),
  body('parentId')
    .notEmpty()
    .withMessage('Parent reference is required')
    .isMongoId()
    .withMessage('Invalid parent ID'),
  body('classId')
    .notEmpty()
    .withMessage('Class reference is required')
    .isMongoId()
    .withMessage('Invalid class ID'),
  body('dateOfBirth')
    .notEmpty()
    .withMessage('Date of birth is required')
    .isISO8601()
    .withMessage('Invalid date format'),
  body('gender')
    .isIn(['male', 'female', 'other'])
    .withMessage('Invalid gender'),
  handleValidationErrors
];

// Class validation
const classValidation = [
  body('className')
    .notEmpty()
    .withMessage('Class name is required')
    .trim(),
  body('section')
    .notEmpty()
    .withMessage('Section is required')
    .trim(),
  body('academicYear')
    .notEmpty()
    .withMessage('Academic year is required')
    .trim(),
  body('capacity')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Capacity must be a positive number'),
  handleValidationErrors
];

// Attendance validation
const attendanceValidation = [
  body('studentId')
    .notEmpty()
    .withMessage('Student reference is required')
    .isMongoId()
    .withMessage('Invalid student ID'),
  body('classId')
    .notEmpty()
    .withMessage('Class reference is required')
    .isMongoId()
    .withMessage('Invalid class ID'),
  body('date')
    .optional()
    .isISO8601()
    .withMessage('Invalid date format'),
  body('status')
    .isIn(['present', 'absent', 'half-day', 'late'])
    .withMessage('Invalid attendance status'),
  handleValidationErrors
];

// Fee validation
const feeValidation = [
  body('studentId')
    .notEmpty()
    .withMessage('Student reference is required')
    .isMongoId()
    .withMessage('Invalid student ID'),
  body('academicYear')
    .notEmpty()
    .withMessage('Academic year is required')
    .trim(),
  body('feeType')
    .isIn(['tuition', 'transport', 'library', 'sports', 'exam', 'hostel', 'other'])
    .withMessage('Invalid fee type'),
  body('amount')
    .isFloat({ min: 0 })
    .withMessage('Amount must be a positive number'),
  body('dueDate')
    .notEmpty()
    .withMessage('Due date is required')
    .isISO8601()
    .withMessage('Invalid date format'),
  handleValidationErrors
];

module.exports = {
  loginValidation,
  registerValidation,
  studentValidation,
  classValidation,
  attendanceValidation,
  feeValidation,
  handleValidationErrors
};
