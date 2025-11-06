const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { verifyToken } = require('../middleware/auth.middleware');
const { loginValidation, registerValidation } = require('../middleware/validation.middleware');
const upload = require('../middleware/upload.middleware');

// Public routes
router.post('/register', registerValidation, authController.register);
router.post('/login', loginValidation, authController.login);

// Protected routes
router.get('/me', verifyToken, authController.getProfile);
router.put('/profile', verifyToken, authController.updateProfile);
router.post('/upload-avatar', verifyToken, upload.single('avatar'), authController.uploadAvatar);
router.post('/logout', verifyToken, authController.logout);

module.exports = router;
