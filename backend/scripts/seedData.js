const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
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
.then(() => console.log('✅ MongoDB Connected for seeding'))
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Sample data
const teachersData = [
  { name: 'Rajesh Kumar', email: 'rajesh.kumar@school.com', mobile: '9876543210', subject: 'Mathematics', qualification: 'M.Sc Math' },
  { name: 'Priya Sharma', email: 'priya.sharma@school.com', mobile: '9876543211', subject: 'English', qualification: 'M.A English' },
  { name: 'Amit Singh', email: 'amit.singh@school.com', mobile: '9876543212', subject: 'Science', qualification: 'M.Sc Physics' },
  { name: 'Sunita Verma', email: 'sunita.verma@school.com', mobile: '9876543213', subject: 'Hindi', qualification: 'M.A Hindi' },
  { name: 'Vikram Patel', email: 'vikram.patel@school.com', mobile: '9876543214', subject: 'Social Studies', qualification: 'M.A History' },
  { name: 'Meena Gupta', email: 'meena.gupta@school.com', mobile: '9876543215', subject: 'Computer Science', qualification: 'MCA' },
  { name: 'Ramesh Yadav', email: 'ramesh.yadav@school.com', mobile: '9876543216', subject: 'Physical Education', qualification: 'B.P.Ed' },
  { name: 'Kavita Desai', email: 'kavita.desai@school.com', mobile: '9876543217', subject: 'Art & Craft', qualification: 'BFA' },
  { name: 'Suresh Reddy', email: 'suresh.reddy@school.com', mobile: '9876543218', subject: 'Music', qualification: 'B.Mus' },
  { name: 'Anjali Joshi', email: 'anjali.joshi@school.com', mobile: '9876543219', subject: 'Sanskrit', qualification: 'M.A Sanskrit' },
];

const classesData = [
  { name: 'LKG', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'UKG', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 1', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 2', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 3', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 4', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 5', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 6', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 7', section: 'A', capacity: 30, academicYear: '2024-2025' },
  { name: 'Class 8', section: 'A', capacity: 30, academicYear: '2024-2025' },
];

// Student names with parent names
const firstNames = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Arnav', 'Ayaan', 'Krishna', 'Ishaan',
  'Aadhya', 'Ananya', 'Diya', 'Isha', 'Kavya', 'Kiara', 'Navya', 'Saanvi', 'Sara', 'Avni',
  'Rohan', 'Reyansh', 'Atharv', 'Kabir', 'Shivansh', 'Dhruv'];

const lastNames = ['Kumar', 'Singh', 'Sharma', 'Patel', 'Verma', 'Gupta', 'Reddy', 'Yadav', 'Desai', 'Joshi',
  'Mehta', 'Nair', 'Iyer', 'Chopra', 'Malhotra', 'Kapoor', 'Bhatia', 'Agarwal', 'Bansal', 'Saxena'];

const fatherNames = ['Rajesh', 'Suresh', 'Mahesh', 'Ramesh', 'Dinesh', 'Mukesh', 'Rakesh', 'Naresh', 'Hitesh', 'Jitesh',
  'Amit', 'Sumit', 'Ajit', 'Mohit', 'Rohit', 'Lalit', 'Ankit', 'Sanjay', 'Vijay', 'Ajay'];

const motherNames = ['Sunita', 'Anita', 'Kavita', 'Geeta', 'Meera', 'Neeta', 'Seema', 'Reema', 'Priya', 'Pooja',
  'Anjali', 'Shweta', 'Preeti', 'Nisha', 'Ritu', 'Sapna', 'Rekha', 'Maya', 'Radha', 'Sita'];

// Global set to track all roll numbers across all classes
const globalUsedRollNumbers = new Set();
const globalUsedAdmissionNumbers = new Set();

// Generate random student data
function generateStudentData(className, classSection, classId, count) {
  const students = [];
  
  for (let i = 0; i < count; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const fatherName = fatherNames[Math.floor(Math.random() * fatherNames.length)] + ' ' + lastName;
    const motherName = motherNames[Math.floor(Math.random() * motherNames.length)] + ' ' + lastName;
    
    // Generate unique roll number globally
    let rollNumber;
    do {
      rollNumber = Math.floor(Math.random() * 9000) + 1000;
    } while (globalUsedRollNumbers.has(rollNumber));
    globalUsedRollNumbers.add(rollNumber);
    
    // Generate unique admission number globally
    let admissionNumber;
    do {
      admissionNumber = `ADM${new Date().getFullYear()}${Math.floor(Math.random() * 90000) + 10000}`;
    } while (globalUsedAdmissionNumbers.has(admissionNumber));
    globalUsedAdmissionNumbers.add(admissionNumber);
    
    // Random date of birth based on class
    const classNumber = className.includes('LKG') ? 0 : 
                       className.includes('UKG') ? 1 : 
                       parseInt(className.replace('Class ', ''));
    const age = 5 + classNumber;
    const birthYear = 2024 - age;
    const birthMonth = Math.floor(Math.random() * 12) + 1;
    const birthDay = Math.floor(Math.random() * 28) + 1;
    
    students.push({
      name: `${firstName} ${lastName}`,
      rollNumber: rollNumber.toString(),
      admissionNumber: admissionNumber,
      classId: classId,
      dateOfBirth: new Date(`${birthYear}-${birthMonth.toString().padStart(2, '0')}-${birthDay.toString().padStart(2, '0')}`),
      gender: Math.random() > 0.5 ? 'male' : 'female',
      bloodGroup: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'][Math.floor(Math.random() * 8)],
      emergencyContact: {
        fatherName: fatherName,
        motherName: motherName,
        phone: `98765${Math.floor(Math.random() * 90000) + 10000}`,
        relation: 'Parent'
      },
      address: `${Math.floor(Math.random() * 900) + 100}, ${['MG Road', 'Park Street', 'Gandhi Nagar', 'Station Road', 'Mall Road'][Math.floor(Math.random() * 5)]}, Vindhya Nagar`,
      admissionDate: new Date('2024-04-01'),
      isActive: true
    });
  }
  
  return students;
}

// Main seeding function
async function seedDatabase() {
  try {
    console.log('🗑️  Clearing existing data...');
    
    // Clear existing data (except admin)
    await User.deleteMany({ role: 'teacher' });
    await Class.deleteMany({});
    await Student.deleteMany({});
    
    console.log('✅ Existing data cleared');
    
    // Create Teachers
    console.log('👨‍🏫 Creating teachers...');
    const hashedPassword = await bcrypt.hash('teacher123', 10);
    
    const teachers = await User.insertMany(
      teachersData.map((teacher, index) => ({
        email: teacher.email,
        password: hashedPassword,
        role: 'teacher',
        profile: {
          name: teacher.name,
          phone: teacher.mobile,
          gender: Math.random() > 0.5 ? 'male' : 'female'
        },
        employeeId: `EMP${(index + 1).toString().padStart(4, '0')}`,
        isActive: true
      }))
    );
    
    console.log(`✅ Created ${teachers.length} teachers`);
    
    // Create Classes with assigned teachers
    console.log('🏫 Creating classes...');
    const classes = [];
    
    for (let i = 0; i < classesData.length; i++) {
      const classData = classesData[i];
      const assignedTeacher = teachers[i % teachers.length];
      
      const newClass = await Class.create({
        className: classData.name,
        section: classData.section,
        capacity: classData.capacity,
        academicYear: classData.academicYear,
        classTeacher: assignedTeacher._id,
        room: `Room ${i + 1}`,
        isActive: true
      });
      
      classes.push(newClass);
    }
    
    console.log(`✅ Created ${classes.length} classes`);
    
    // Create Students for each class
    console.log('👨‍🎓 Creating students...');
    let totalStudents = 0;
    
    for (const classDoc of classes) {
      // Random number of students between 20-26
      const studentCount = Math.floor(Math.random() * 7) + 20;
      const students = generateStudentData(classDoc.className, classDoc.section, classDoc._id, studentCount);
      
      const createdStudents = await Student.insertMany(students);
      totalStudents += createdStudents.length;
      
      console.log(`   ✅ Created ${createdStudents.length} students in ${classDoc.className}-${classDoc.section}`);
    }
    
    console.log(`✅ Total students created: ${totalStudents}`);
    
    // Summary
    console.log('\n📊 SEEDING SUMMARY:');
    console.log('='.repeat(50));
    console.log(`👨‍🏫 Teachers: ${teachers.length}`);
    console.log(`🏫 Classes: ${classes.length}`);
    console.log(`👨‍🎓 Students: ${totalStudents}`);
    console.log('='.repeat(50));
    console.log('\n✅ Demo data seeded successfully!');
    console.log('\n📝 Login Credentials:');
    console.log('Admin: admin@school.com / admin123');
    console.log('Teacher: rajesh.kumar@school.com / teacher123');
    console.log('(All teachers have password: teacher123)');
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run seeding
seedDatabase();
