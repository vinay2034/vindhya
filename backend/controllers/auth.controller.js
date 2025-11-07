const User = require('../models/User');
const { generateToken, generateRefreshToken } = require('../middleware/auth.middleware');

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public (Admin only in production)
const register = async (req, res) => {
  try {
    const { email, password, role, profile } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'User with this email already exists'
      });
    }
    
    // Create new user
    const user = await User.create({
      email,
      password,
      role,
      profile
    });
    
    // Generate tokens
    const token = generateToken(user._id, user.role);
    const refreshToken = generateRefreshToken(user._id);
    
    res.status(201).json({
      status: 'success',
      message: 'User registered successfully',
      data: {
        user: {
          id: user._id,
          email: user.email,
          role: user.role,
          profile: user.profile
        },
        token,
        refreshToken
      }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Registration failed',
      error: error.message
    });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Find user with password - try email first, then username (for parents with mobile login)
    let user = await User.findOne({ email }).select('+password');
    
    // If not found by email and the email looks like a mobile number, try username
    if (!user && /^\d{10}$/.test(email)) {
      user = await User.findOne({ username: email }).select('+password');
    }
    
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }
    
    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Account is inactive. Please contact administrator.'
      });
    }
    
    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }
    
    // Generate tokens
    const token = generateToken(user._id, user.role);
    const refreshToken = generateRefreshToken(user._id);
    
    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          email: user.email,
          role: user.role,
          profile: user.profile
        },
        token,
        refreshToken
      }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Login failed',
      error: error.message
    });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: { user }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch profile',
      error: error.message
    });
  }
};

// @desc    Update user profile
// @route   PUT /api/auth/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const { name, phone, address, dateOfBirth, gender } = req.body;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Update profile fields
    if (name) user.profile.name = name;
    if (phone) user.profile.phone = phone;
    if (address) user.profile.address = address;
    if (dateOfBirth) user.profile.dateOfBirth = dateOfBirth;
    if (gender !== undefined) user.profile.gender = gender;

    await user.save();
    
    res.status(200).json({
      status: 'success',
      message: 'Profile updated successfully',
      data: { user }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to update profile',
      error: error.message
    });
  }
};

// @desc    Upload profile avatar
// @route   POST /api/auth/upload-avatar
// @access  Private
const uploadAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'Please upload an image file'
      });
    }

    const avatarUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    user.profile.avatar = avatarUrl;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Avatar uploaded successfully',
      data: { 
        avatar: avatarUrl,
        user 
      }
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to upload avatar',
      error: error.message
    });
  }
};

// @desc    Change password
// @route   PUT /api/auth/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    // Validation
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        status: 'error',
        message: 'Please provide current password and new password'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        status: 'error',
        message: 'New password must be at least 6 characters long'
      });
    }

    // Get user with password
    const user = await User.findById(req.user.id).select('+password');
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Verify current password
    const isPasswordValid = await user.comparePassword(currentPassword);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Current password is incorrect'
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Password changed successfully'
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Failed to change password',
      error: error.message
    });
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Private
const logout = async (req, res) => {
  try {
    // In a production app, you might want to blacklist the token
    res.status(200).json({
      status: 'success',
      message: 'Logout successful'
    });
    
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Logout failed',
      error: error.message
    });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  uploadAvatar,
  changePassword,
  logout
};
