const mongoose = require('mongoose');
require('dotenv').config();

const Student = require('../models/Student');
const User = require('../models/User');
const Class = require('../models/Class');
const Subject = require('../models/Subject');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(async () => {
  console.log('✅ MongoDB Connected');
  
  const studentCount = await Student.countDocuments({});
  const teacherCount = await User.countDocuments({ role: 'teacher' });
  const classCount = await Class.countDocuments({});
  const subjectCount = await Subject.countDocuments({});
  
  console.log('\n📊 DATABASE COUNTS:\n');
  console.log(`Total Students: ${studentCount}`);
  console.log(`Total Teachers: ${teacherCount}`);
  console.log(`Total Classes: ${classCount}`);
  console.log(`Total Subjects: ${subjectCount}`);
  
  // Check students per class
  console.log('\n👨‍🎓 STUDENTS PER CLASS:\n');
  const classes = await Class.find({}).populate('classTeacher', 'profile.name email');
  
  for (const cls of classes) {
    const studentsInClass = await Student.countDocuments({ classId: cls._id });
    console.log(`${cls.className}-${cls.section}: ${studentsInClass} students (Teacher: ${cls.classTeacher?.profile?.name || 'Not assigned'})`);
  }
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});
