const mongoose = require('mongoose');
const Attendance = require('../models/Attendance');
const Student = require('../models/Student');
const Class = require('../models/Class');
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

const seedAttendance = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB Connected');

    // Clear existing attendance data
    await Attendance.deleteMany({});
    console.log('🗑️  Cleared existing attendance data');

    // Get all students and classes
    const students = await Student.find({}).populate('classId');
    const classes = await Class.find({});

    if (students.length === 0) {
      console.log('❌ No students found. Please seed students first.');
      process.exit(1);
    }

    console.log(`📊 Found ${students.length} students across ${classes.length} classes`);

    const attendanceRecords = [];
    const today = new Date();
    
    // Generate attendance for last 7 days
    for (let dayOffset = 0; dayOffset < 7; dayOffset++) {
      const date = new Date(today);
      date.setDate(date.getDate() - dayOffset);
      date.setHours(0, 0, 0, 0);

      // Skip weekends
      if (date.getDay() === 0 || date.getDay() === 6) continue;

      for (const student of students) {
        if (!student.classId) continue;

        // 90% present, 5% absent, 5% late
        const random = Math.random();
        let status = 'present';
        if (random > 0.95) {
          status = 'absent';
        } else if (random > 0.90) {
          status = 'late';
        }

        attendanceRecords.push({
          studentId: student._id,
          classId: student.classId._id,
          date: date,
          status: status,
          markedBy: student.classId.classTeacher,
          remarks: status === 'absent' ? 'No reason provided' : null,
        });
      }
    }

    // Insert all attendance records
    await Attendance.insertMany(attendanceRecords);

    console.log(`✅ Successfully created ${attendanceRecords.length} attendance records!`);
    console.log(`📅 Date range: Last 7 days (excluding weekends)`);
    console.log(`📊 Status distribution:`);
    console.log(`   - Present: ~90%`);
    console.log(`   - Late: ~5%`);
    console.log(`   - Absent: ~5%`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

seedAttendance();
