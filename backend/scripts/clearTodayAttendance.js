const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school-management')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

const Attendance = require('../models/Attendance');

const clearTodayAttendance = async () => {
  try {
    // Get November 22, 2025 date range
    const startDate = new Date('2025-11-22T00:00:00.000Z');
    const endDate = new Date('2025-11-23T00:00:00.000Z');
    
    console.log('Searching for attendance records between:');
    console.log('Start:', startDate);
    console.log('End:', endDate);
    
    // Find all attendance records for November 22, 2025
    const records = await Attendance.find({
      date: {
        $gte: startDate,
        $lt: endDate
      }
    });
    
    console.log(`\nFound ${records.length} attendance records for November 22, 2025`);
    
    if (records.length > 0) {
      console.log('Sample records:', records.slice(0, 5).map(r => ({
        studentId: r.studentId,
        status: r.status,
        date: r.date
      })));
      
      // Delete attendance for November 22, 2025
      const result = await Attendance.deleteMany({
        date: {
          $gte: startDate,
          $lt: endDate
        }
      });
      
      console.log(`✅ Successfully deleted ${result.deletedCount} attendance records`);
    } else {
      console.log('ℹ️  No attendance records found for November 22, 2025');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error clearing attendance:', error);
    process.exit(1);
  }
};

clearTodayAttendance();
