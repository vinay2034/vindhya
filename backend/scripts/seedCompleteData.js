const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Class = require('../models/Class');
const Student = require('../models/Student');
const Subject = require('../models/Subject');
const Fee = require('../models/Fee');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB Connected for complete seeding'))
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Tracking used IDs globally
const globalUsedRollNumbers = new Set();
const globalUsedAdmissionNumbers = new Set();

// Subjects data for different classes
const subjectsData = [
  // LKG & UKG subjects
  { name: 'English', code: 'ENG-KG', description: 'Basic English for Kindergarten', type: 'core', forClasses: ['LKG', 'UKG'] },
  { name: 'Hindi', code: 'HIN-KG', description: 'Basic Hindi for Kindergarten', type: 'core', forClasses: ['LKG', 'UKG'] },
  { name: 'Mathematics', code: 'MTH-KG', description: 'Basic Math for Kindergarten', type: 'core', forClasses: ['LKG', 'UKG'] },
  { name: 'Environmental Science', code: 'EVS-KG', description: 'Environment awareness', type: 'core', forClasses: ['LKG', 'UKG'] },
  { name: 'Art & Craft', code: 'ART-KG', description: 'Creative activities', type: 'activity', forClasses: ['LKG', 'UKG'] },
  { name: 'Music', code: 'MUS-KG', description: 'Music and rhythm', type: 'activity', forClasses: ['LKG', 'UKG'] },
  
  // Class 1-5 subjects
  { name: 'English', code: 'ENG-15', description: 'English Language', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Hindi', code: 'HIN-15', description: 'Hindi Language', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Mathematics', code: 'MTH-15', description: 'Mathematics', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Environmental Science', code: 'EVS-15', description: 'Environmental Studies', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'General Knowledge', code: 'GK-15', description: 'General Knowledge', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Computer Science', code: 'CS-15', description: 'Basic Computer', type: 'core', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Art & Craft', code: 'ART-15', description: 'Art and Craft', type: 'activity', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  { name: 'Physical Education', code: 'PE-15', description: 'Physical Education', type: 'activity', forClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
  
  // Class 6-8 subjects
  { name: 'English', code: 'ENG-68', description: 'English Language & Literature', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Hindi', code: 'HIN-68', description: 'Hindi Language', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Mathematics', code: 'MTH-68', description: 'Mathematics', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Science', code: 'SCI-68', description: 'General Science', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Social Science', code: 'SST-68', description: 'Social Studies', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Sanskrit', code: 'SKT-68', description: 'Sanskrit Language', type: 'elective', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Computer Science', code: 'CS-68', description: 'Computer Science', type: 'core', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Art & Craft', code: 'ART-68', description: 'Art Education', type: 'activity', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
  { name: 'Physical Education', code: 'PE-68', description: 'Physical Education & Sports', type: 'activity', forClasses: ['Class 6', 'Class 7', 'Class 8'] },
];

// Fee structure by class
const feeStructure = {
  'LKG': { tuition: 15000, transport: 8000, library: 1000, sports: 1500, exam: 1000 },
  'UKG': { tuition: 16000, transport: 8000, library: 1000, sports: 1500, exam: 1000 },
  'Class 1': { tuition: 18000, transport: 9000, library: 1500, sports: 2000, exam: 1500 },
  'Class 2': { tuition: 18000, transport: 9000, library: 1500, sports: 2000, exam: 1500 },
  'Class 3': { tuition: 20000, transport: 9000, library: 1500, sports: 2000, exam: 1500 },
  'Class 4': { tuition: 20000, transport: 9000, library: 1500, sports: 2000, exam: 1500 },
  'Class 5': { tuition: 22000, transport: 10000, library: 2000, sports: 2500, exam: 2000 },
  'Class 6': { tuition: 25000, transport: 10000, library: 2000, sports: 2500, exam: 2000 },
  'Class 7': { tuition: 25000, transport: 10000, library: 2000, sports: 2500, exam: 2000 },
  'Class 8': { tuition: 28000, transport: 11000, library: 2500, sports: 3000, exam: 2500 },
};

// Generate unique roll number
function generateRollNumber() {
  let rollNumber;
  do {
    rollNumber = 1000 + Math.floor(Math.random() * 9000);
  } while (globalUsedRollNumbers.has(rollNumber));
  globalUsedRollNumbers.add(rollNumber);
  return rollNumber;
}

// Generate unique admission number
function generateAdmissionNumber() {
  const year = new Date().getFullYear();
  let admissionNumber;
  do {
    const randomNum = Math.floor(Math.random() * 10000).toString().padStart(5, '0');
    admissionNumber = `ADM${year}${randomNum}`;
  } while (globalUsedAdmissionNumbers.has(admissionNumber));
  globalUsedAdmissionNumbers.add(admissionNumber);
  return admissionNumber;
}

// Student data generation
const firstNames = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Arnav', 'Ayaan', 'Krishna', 'Ishaan',
  'Aadhya', 'Ananya', 'Diya', 'Isha', 'Kavya', 'Kiara', 'Navya', 'Saanvi', 'Sara', 'Avni',
  'Riya', 'Anvi', 'Pari', 'Myra', 'Aanya', 'Shanaya', 'Reyansh', 'Shaurya', 'Advait', 'Atharv'];

const lastNames = ['Kumar', 'Sharma', 'Singh', 'Patel', 'Verma', 'Gupta', 'Yadav', 'Reddy', 'Joshi', 'Desai',
  'Mehta', 'Nair', 'Iyer', 'Pillai', 'Rao', 'Malhotra', 'Khanna', 'Chopra', 'Agarwal', 'Bhatia'];

const fatherNames = ['Rajesh', 'Suresh', 'Ramesh', 'Mahesh', 'Dinesh', 'Mukesh', 'Rakesh', 'Naresh', 'Hitesh', 'Jitesh',
  'Vijay', 'Ajay', 'Sanjay', 'Manoj', 'Anil', 'Sunil', 'Kapil', 'Nitin', 'Sachin', 'Rahul'];

const motherNames = ['Sunita', 'Meena', 'Kavita', 'Anita', 'Geeta', 'Seeta', 'Neeta', 'Rita', 'Savita', 'Mamta',
  'Priya', 'Pooja', 'Sneha', 'Anjali', 'Ritu', 'Deepa', 'Rekha', 'Usha', 'Asha', 'Nisha'];

const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

const addresses = [
  'MG Road, Vindhya Nagar',
  'Park Street, Vindhya Nagar',
  'Gandhi Nagar, Vindhya Nagar',
  'Station Road, Vindhya Nagar',
  'Mall Road, Vindhya Nagar',
  'Civil Lines, Vindhya Nagar',
  'Model Town, Vindhya Nagar',
  'New Colony, Vindhya Nagar',
  'Old City, Vindhya Nagar',
  'Green Park, Vindhya Nagar'
];

function generateStudentData(className, count) {
  const students = [];
  
  // Calculate age based on class
  const classAgeMap = {
    'LKG': 3,
    'UKG': 4,
    'Class 1': 6,
    'Class 2': 7,
    'Class 3': 8,
    'Class 4': 9,
    'Class 5': 10,
    'Class 6': 11,
    'Class 7': 12,
    'Class 8': 13,
  };
  
  const baseAge = classAgeMap[className] || 6;
  
  for (let i = 0; i < count; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const fatherFirstName = fatherNames[Math.floor(Math.random() * fatherNames.length)];
    const motherFirstName = motherNames[Math.floor(Math.random() * motherNames.length)];
    
    const birthYear = new Date().getFullYear() - baseAge;
    const birthMonth = Math.floor(Math.random() * 12);
    const birthDay = Math.floor(Math.random() * 28) + 1;
    
    students.push({
      firstName,
      lastName,
      fullName: `${firstName} ${lastName}`,
      rollNumber: generateRollNumber(),
      admissionNumber: generateAdmissionNumber(),
      dateOfBirth: new Date(birthYear, birthMonth, birthDay),
      gender: Math.random() > 0.5 ? 'male' : 'female',
      bloodGroup: bloodGroups[Math.floor(Math.random() * bloodGroups.length)],
      fatherName: `${fatherFirstName} ${lastName}`,
      motherName: `${motherFirstName} ${lastName}`,
      guardianName: `${fatherFirstName} ${lastName}`,
      guardianRelation: 'father',
      contactNumber: `98765${Math.floor(Math.random() * 90000) + 10000}`,
      alternateNumber: `97654${Math.floor(Math.random() * 90000) + 10000}`,
      email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@parent.com`,
      address: addresses[Math.floor(Math.random() * addresses.length)],
      city: 'Vindhya Nagar',
      state: 'Madhya Pradesh',
      pincode: '486001',
      admissionDate: new Date('2024-04-01'),
      previousSchool: i % 3 === 0 ? 'St. Mary School' : null,
      isActive: true,
    });
  }
  
  return students;
}

async function seedDatabase() {
  try {
    console.log('🗑️  Clearing existing subjects and fees...');
    await Subject.deleteMany({});
    await Fee.deleteMany({});
    
    console.log('\n📚 Creating subjects...');
    const createdSubjects = await Subject.insertMany(subjectsData.map(subject => ({
      name: subject.name,
      code: subject.code,
      description: subject.description,
      type: subject.type,
      isActive: true,
    })));
    console.log(`✅ Created ${createdSubjects.length} subjects`);
    
    // Get all students and classes
    console.log('\n🔍 Fetching existing students and classes...');
    const students = await Student.find({}).populate('classId');
    const classes = await Class.find({});
    
    if (students.length === 0) {
      console.log('⚠️  No students found. Please run seedData.js first to create students.');
      return;
    }
    
    console.log(`✅ Found ${students.length} students across ${classes.length} classes`);
    
    // Assign subjects to classes
    console.log('\n📋 Assigning subjects to classes...');
    for (const classDoc of classes) {
      const className = classDoc.className;
      const relevantSubjects = createdSubjects.filter(subject => {
        const subjectData = subjectsData.find(s => s.code === subject.code);
        return subjectData && subjectData.forClasses.includes(className);
      });
      
      classDoc.subjects = relevantSubjects.map(s => s._id);
      await classDoc.save();
      console.log(`   ✓ ${className}-${classDoc.section}: ${relevantSubjects.length} subjects`);
    }
    
    // Create fees for students
    console.log('\n💰 Creating fee records...');
    let totalFeesCreated = 0;
    let studentsWithFees = 0;
    
    for (const student of students) {
      const className = student.classId?.className;
      if (!className || !feeStructure[className]) continue;
      
      const fees = feeStructure[className];
      const feeRecords = [];
      
      // Randomly decide if student has paid fees (70% have paid)
      const hasPaid = Math.random() < 0.7;
      
      // Create tuition fee
      const tuitionDueDate = new Date('2024-07-15');
      feeRecords.push({
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'tuition',
        amount: fees.tuition,
        dueDate: tuitionDueDate,
        status: hasPaid ? 'paid' : (new Date() > tuitionDueDate ? 'overdue' : 'pending'),
        paidAmount: hasPaid ? fees.tuition : 0,
        paymentDate: hasPaid ? new Date('2024-07-10') : null,
        paymentMethod: hasPaid ? (Math.random() > 0.5 ? 'online' : 'cash') : null,
        transactionId: hasPaid ? `TXN${Date.now()}${Math.floor(Math.random() * 1000)}` : null,
      });
      
      // Create transport fee (only 60% students use transport)
      if (Math.random() < 0.6) {
        const transportPaid = Math.random() < 0.8;
        feeRecords.push({
          studentId: student._id,
          academicYear: '2024-2025',
          feeType: 'transport',
          amount: fees.transport,
          dueDate: new Date('2024-08-15'),
          status: transportPaid ? 'paid' : 'pending',
          paidAmount: transportPaid ? fees.transport : 0,
          paymentDate: transportPaid ? new Date('2024-08-10') : null,
          paymentMethod: transportPaid ? 'online' : null,
        });
      }
      
      // Create exam fee
      const examPaid = Math.random() < 0.75;
      feeRecords.push({
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'exam',
        amount: fees.exam,
        dueDate: new Date('2024-09-30'),
        status: examPaid ? 'paid' : 'pending',
        paidAmount: examPaid ? fees.exam : 0,
        paymentDate: examPaid ? new Date('2024-09-25') : null,
        paymentMethod: examPaid ? 'cash' : null,
      });
      
      // Create library fee
      feeRecords.push({
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'library',
        amount: fees.library,
        dueDate: new Date('2024-10-15'),
        status: 'pending',
        paidAmount: 0,
      });
      
      // Create sports fee
      feeRecords.push({
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'sports',
        amount: fees.sports,
        dueDate: new Date('2024-11-15'),
        status: 'pending',
        paidAmount: 0,
      });
      
      await Fee.insertMany(feeRecords);
      totalFeesCreated += feeRecords.length;
      studentsWithFees++;
    }
    
    console.log(`✅ Created ${totalFeesCreated} fee records for ${studentsWithFees} students`);
    
    // Print summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 DATABASE SEEDING SUMMARY');
    console.log('='.repeat(60));
    console.log(`Subjects Created: ${createdSubjects.length}`);
    console.log(`Classes Updated: ${classes.length}`);
    console.log(`Students with Fees: ${studentsWithFees}`);
    console.log(`Total Fee Records: ${totalFeesCreated}`);
    console.log('='.repeat(60));
    
    // Print fee summary by class
    console.log('\n💰 FEE STRUCTURE BY CLASS:');
    console.log('─'.repeat(60));
    for (const [className, fees] of Object.entries(feeStructure)) {
      const total = Object.values(fees).reduce((sum, fee) => sum + fee, 0);
      console.log(`${className.padEnd(12)} - Total: ₹${total.toLocaleString('en-IN')}`);
      console.log(`   Tuition: ₹${fees.tuition.toLocaleString('en-IN')}, Transport: ₹${fees.transport.toLocaleString('en-IN')}, Others: ₹${(fees.library + fees.sports + fees.exam).toLocaleString('en-IN')}`);
    }
    
    // Print subjects by class range
    console.log('\n📚 SUBJECTS BY CLASS:');
    console.log('─'.repeat(60));
    const classRanges = [
      { range: 'LKG & UKG', classes: ['LKG', 'UKG'] },
      { range: 'Class 1-5', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
      { range: 'Class 6-8', classes: ['Class 6', 'Class 7', 'Class 8'] },
    ];
    
    for (const { range, classes: rangeClasses } of classRanges) {
      console.log(`\n${range}:`);
      const subjects = subjectsData.filter(s => 
        s.forClasses.some(c => rangeClasses.includes(c))
      );
      subjects.forEach(s => console.log(`   • ${s.name} (${s.code})`));
    }
    
    console.log('\n✅ Complete database seeding finished successfully!');
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

// Run the seeding
seedDatabase();
