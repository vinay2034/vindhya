const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Class = require('../models/Class');
const Student = require('../models/Student');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB Connected'))
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Check data function
async function checkData() {
  try {
    console.log('\n📊 DATABASE STATISTICS\n');
    console.log('='.repeat(60));
    
    // Count teachers
    const teacherCount = await User.countDocuments({ role: 'teacher' });
    console.log(`👨‍🏫 Teachers: ${teacherCount}`);
    
    // Count classes
    const classCount = await Class.countDocuments({});
    console.log(`🏫 Classes: ${classCount}`);
    
    // Count students
    const studentCount = await Student.countDocuments({});
    console.log(`👨‍🎓 Total Students: ${studentCount}`);
    
    console.log('='.repeat(60));
    
    // Get class-wise student count
    console.log('\n📚 STUDENTS PER CLASS:\n');
    console.log('='.repeat(60));
    
    const classes = await Class.find({}).sort({ className: 1 });
    
    for (const classDoc of classes) {
      const studentsInClass = await Student.countDocuments({ classId: classDoc._id });
      console.log(`${classDoc.className} - ${classDoc.section}: ${studentsInClass} students (Capacity: ${classDoc.capacity})`);
    }
    
    console.log('='.repeat(60));
    
    // Show sample students
    console.log('\n👤 SAMPLE STUDENTS (First 5):\n');
    console.log('='.repeat(60));
    
    const sampleStudents = await Student.find({})
      .populate('classId', 'className section')
      .limit(5)
      .lean();
    
    sampleStudents.forEach((student, index) => {
      console.log(`\n${index + 1}. ${student.name}`);
      console.log(`   Roll Number: ${student.rollNumber}`);
      console.log(`   Admission Number: ${student.admissionNumber}`);
      console.log(`   Class: ${student.classId?.className || 'N/A'}-${student.classId?.section || 'N/A'}`);
      console.log(`   Father: ${student.emergencyContact?.fatherName || 'N/A'}`);
      console.log(`   Mother: ${student.emergencyContact?.motherName || 'N/A'}`);
      console.log(`   Gender: ${student.gender}`);
      console.log(`   Blood Group: ${student.bloodGroup}`);
    });
    
    console.log('\n' + '='.repeat(60));
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error checking data:', error);
    process.exit(1);
  }
}

// Run check
checkData();
