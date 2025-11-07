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

// Teachers data
const teachersData = [
  { name: 'Rajesh Kumar', email: 'rajesh.kumar@school.com', mobile: '9876543210', subject: 'Mathematics', qualification: 'M.Sc Math', gender: 'male' },
  { name: 'Priya Sharma', email: 'priya.sharma@school.com', mobile: '9876543211', subject: 'English', qualification: 'M.A English', gender: 'female' },
  { name: 'Amit Singh', email: 'amit.singh@school.com', mobile: '9876543212', subject: 'Science', qualification: 'M.Sc Physics', gender: 'male' },
  { name: 'Sunita Verma', email: 'sunita.verma@school.com', mobile: '9876543213', subject: 'Hindi', qualification: 'M.A Hindi', gender: 'female' },
  { name: 'Vikram Patel', email: 'vikram.patel@school.com', mobile: '9876543214', subject: 'Social Studies', qualification: 'M.A History', gender: 'male' },
  { name: 'Meena Gupta', email: 'meena.gupta@school.com', mobile: '9876543215', subject: 'Computer Science', qualification: 'MCA', gender: 'female' },
  { name: 'Ramesh Yadav', email: 'ramesh.yadav@school.com', mobile: '9876543216', subject: 'Physical Education', qualification: 'B.P.Ed', gender: 'male' },
  { name: 'Kavita Desai', email: 'kavita.desai@school.com', mobile: '9876543217', subject: 'Art & Craft', qualification: 'BFA', gender: 'female' },
  { name: 'Suresh Reddy', email: 'suresh.reddy@school.com', mobile: '9876543218', subject: 'Music', qualification: 'B.Mus', gender: 'male' },
  { name: 'Anjali Joshi', email: 'anjali.joshi@school.com', mobile: '9876543219', subject: 'Sanskrit', qualification: 'M.A Sanskrit', gender: 'female' },
];

// Classes data
const classesData = [
  { name: 'LKG', section: 'A', room: 'Room 1' },
  { name: 'UKG', section: 'A', room: 'Room 2' },
  { name: 'Class 1', section: 'A', room: 'Room 3' },
  { name: 'Class 2', section: 'A', room: 'Room 4' },
  { name: 'Class 3', section: 'A', room: 'Room 5' },
  { name: 'Class 4', section: 'A', room: 'Room 6' },
  { name: 'Class 5', section: 'A', room: 'Room 7' },
  { name: 'Class 6', section: 'A', room: 'Room 8' },
  { name: 'Class 7', section: 'A', room: 'Room 9' },
  { name: 'Class 8', section: 'A', room: 'Room 10' },
];

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

// Fee structure by class (annual fees)
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

// Student count per class (20-26 students)
const studentsPerClass = {
  'LKG': 22,
  'UKG': 24,
  'Class 1': 26,
  'Class 2': 25,
  'Class 3': 23,
  'Class 4': 21,
  'Class 5': 20,
  'Class 6': 22,
  'Class 7': 24,
  'Class 8': 21,
};

// Student data
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

function generateRollNumber() {
  let rollNumber;
  do {
    rollNumber = 1000 + Math.floor(Math.random() * 9000);
  } while (globalUsedRollNumbers.has(rollNumber));
  globalUsedRollNumbers.add(rollNumber);
  return rollNumber;
}

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

function generateStudentData(className, count, classId) {
  const students = [];
  
  const classAgeMap = {
    'LKG': 3, 'UKG': 4, 'Class 1': 6, 'Class 2': 7, 'Class 3': 8, 'Class 4': 9, 
    'Class 5': 10, 'Class 6': 11, 'Class 7': 12, 'Class 8': 13,
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
      name: `${firstName} ${lastName}`,
      rollNumber: generateRollNumber().toString(),
      classId: classId,
      admissionNumber: generateAdmissionNumber(),
      admissionDate: new Date('2024-04-01'),
      dateOfBirth: new Date(birthYear, birthMonth, birthDay),
      gender: Math.random() > 0.5 ? 'male' : 'female',
      bloodGroup: bloodGroups[Math.floor(Math.random() * bloodGroups.length)],
      address: `${addresses[Math.floor(Math.random() * addresses.length)]}, Vindhya Nagar, MP 486001`,
      emergencyContact: {
        fatherName: `${fatherFirstName} ${lastName}`,
        motherName: `${motherFirstName} ${lastName}`,
        name: `${fatherFirstName} ${lastName}`,
        phone: `98765${Math.floor(Math.random() * 90000) + 10000}`,
        relation: 'father',
      },
      isActive: true,
    });
  }
  
  return students;
}

async function seedDatabase() {
  try {
    console.log('🗑️  Clearing existing data...');
    await User.deleteMany({ role: 'teacher' });
    await Class.deleteMany({});
    await Student.deleteMany({});
    await Subject.deleteMany({});
    await Fee.deleteMany({});
    
    // Create teachers
    console.log('\n👨‍🏫 Creating teachers...');
    const teachers = [];
    let empIdCounter = 1;
    
    for (const teacher of teachersData) {
      const hashedPassword = await bcrypt.hash('teacher123', 10);
      const newTeacher = await User.create({
        email: teacher.email,
        password: hashedPassword,
        role: 'teacher',
        employeeId: `EMP${empIdCounter.toString().padStart(4, '0')}`,
        profile: {
          name: teacher.name,
          phone: teacher.mobile,
          gender: teacher.gender,
        },
        isActive: true,
      });
      teachers.push(newTeacher);
      empIdCounter++;
      console.log(`   ✓ ${teacher.name} - ${teacher.email}`);
    }
    
    // Create subjects
    console.log('\n📚 Creating subjects...');
    const subjects = await Subject.insertMany(subjectsData.map(subject => ({
      name: subject.name,
      code: subject.code,
      description: subject.description,
      type: subject.type,
      isActive: true,
    })));
    console.log(`✅ Created ${subjects.length} subjects`);
    
    // Create classes
    console.log('\n🏫 Creating classes...');
    const classes = [];
    let roomCounter = 1;
    
    for (let i = 0; i < classesData.length; i++) {
      const classData = classesData[i];
      const teacher = teachers[i];
      
      // Find subjects for this class
      const relevantSubjects = subjects.filter(subject => {
        const subjectData = subjectsData.find(s => s.code === subject.code);
        return subjectData && subjectData.forClasses.includes(classData.name);
      });
      
      const newClass = await Class.create({
        className: classData.name,
        section: classData.section,
        classTeacher: teacher._id,
        subjects: relevantSubjects.map(s => s._id),
        capacity: 30,
        academicYear: '2024-2025',
        room: `Room ${roomCounter}`,
        isActive: true,
      });
      
      classes.push(newClass);
      roomCounter++;
      console.log(`   ✓ ${classData.name}-${classData.section} (Teacher: ${teacher.profile.name}, Subjects: ${relevantSubjects.length})`);
    }
    
    // Create students
    console.log('\n👨‍🎓 Creating students...');
    let totalStudents = 0;
    const allStudents = [];
    
    for (const classDoc of classes) {
      const studentCount = studentsPerClass[classDoc.className];
      const students = generateStudentData(classDoc.className, studentCount, classDoc._id);
      const createdStudents = await Student.insertMany(students);
      allStudents.push(...createdStudents);
      totalStudents += createdStudents.length;
      console.log(`   ✓ ${classDoc.className}-${classDoc.section}: ${createdStudents.length} students`);
    }
    
    // Create fees for students
    console.log('\n💰 Creating fee records...');
    let totalFeesCreated = 0;
    
    for (const student of allStudents) {
      const classDoc = await Class.findById(student.classId);
      const className = classDoc.className;
      const fees = feeStructure[className];
      const feeRecords = [];
      
      // Determine payment status (70% have paid tuition)
      const hasPaidTuition = Math.random() < 0.7;
      
      // Tuition fee
      const tuitionDueDate = new Date('2024-07-15');
      const tuitionFee = {
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'tuition',
        amount: fees.tuition,
        dueDate: tuitionDueDate,
        status: hasPaidTuition ? 'paid' : (new Date() > tuitionDueDate ? 'overdue' : 'pending'),
        paidAmount: hasPaidTuition ? fees.tuition : 0,
      };
      if (hasPaidTuition) {
        tuitionFee.paymentDate = new Date('2024-07-10');
        tuitionFee.paymentMethod = Math.random() > 0.5 ? 'online' : 'cash';
        tuitionFee.transactionId = `TXN${Date.now()}${Math.floor(Math.random() * 100000)}`;
        tuitionFee.receiptNumber = `REC${Date.now()}${Math.floor(Math.random() * 10000)}`;
      }
      feeRecords.push(tuitionFee);
      
      // Transport fee (60% students use transport)
      if (Math.random() < 0.6) {
        const transportPaid = Math.random() < 0.8;
        const transportFee = {
          studentId: student._id,
          academicYear: '2024-2025',
          feeType: 'transport',
          amount: fees.transport,
          dueDate: new Date('2024-08-15'),
          status: transportPaid ? 'paid' : 'pending',
          paidAmount: transportPaid ? fees.transport : 0,
        };
        if (transportPaid) {
          transportFee.paymentDate = new Date('2024-08-10');
          transportFee.paymentMethod = 'online';
          transportFee.receiptNumber = `REC${Date.now()}${Math.floor(Math.random() * 10000)}`;
        }
        feeRecords.push(transportFee);
      }
      
      // Exam fee
      const examPaid = Math.random() < 0.75;
      const examFee = {
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'exam',
        amount: fees.exam,
        dueDate: new Date('2024-09-30'),
        status: examPaid ? 'paid' : 'pending',
        paidAmount: examPaid ? fees.exam : 0,
      };
      if (examPaid) {
        examFee.paymentDate = new Date('2024-09-25');
        examFee.paymentMethod = 'cash';
        examFee.receiptNumber = `REC${Date.now()}${Math.floor(Math.random() * 10000)}`;
      }
      feeRecords.push(examFee);
      
      // Library fee
      feeRecords.push({
        studentId: student._id,
        academicYear: '2024-2025',
        feeType: 'library',
        amount: fees.library,
        dueDate: new Date('2024-10-15'),
        status: 'pending',
        paidAmount: 0,
      });
      
      // Sports fee
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
    }
    
    console.log(`✅ Created ${totalFeesCreated} fee records`);
    
    // Print comprehensive summary
    console.log('\n' + '='.repeat(70));
    console.log('📊 COMPLETE DATABASE SEEDING SUMMARY');
    console.log('='.repeat(70));
    console.log(`Teachers Created: ${teachers.length}`);
    console.log(`Subjects Created: ${subjects.length}`);
    console.log(`Classes Created: ${classes.length}`);
    console.log(`Students Created: ${totalStudents}`);
    console.log(`Fee Records Created: ${totalFeesCreated}`);
    console.log('='.repeat(70));
    
    // Print students per class
    console.log('\n👨‍🎓 STUDENTS PER CLASS:');
    console.log('─'.repeat(70));
    for (const classDoc of classes) {
      const count = studentsPerClass[classDoc.className];
      const teacher = teachers.find(t => t._id.equals(classDoc.classTeacher));
      console.log(`${classDoc.className}-${classDoc.section}:`.padEnd(15) + 
                  `${count} students (Capacity: 30) | Teacher: ${teacher.profile.name}`);
    }
    
    // Print fee structure
    console.log('\n💰 FEE STRUCTURE BY CLASS (Annual):');
    console.log('─'.repeat(70));
    for (const [className, fees] of Object.entries(feeStructure)) {
      const total = Object.values(fees).reduce((sum, fee) => sum + fee, 0);
      console.log(`${className.padEnd(10)} | Total: ₹${total.toLocaleString('en-IN').padStart(8)} | ` +
                  `Tuition: ₹${fees.tuition.toLocaleString('en-IN')}, Transport: ₹${fees.transport.toLocaleString('en-IN')}`);
    }
    
    // Print subjects by class range
    console.log('\n📚 SUBJECTS BY CLASS RANGE:');
    console.log('─'.repeat(70));
    const classRanges = [
      { range: 'LKG & UKG', classes: ['LKG', 'UKG'] },
      { range: 'Class 1-5', classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'] },
      { range: 'Class 6-8', classes: ['Class 6', 'Class 7', 'Class 8'] },
    ];
    
    for (const { range, classes: rangeClasses } of classRanges) {
      const subjects = subjectsData.filter(s => 
        s.forClasses.some(c => rangeClasses.includes(c))
      );
      console.log(`\n${range}:`);
      subjects.forEach(s => console.log(`   • ${s.name.padEnd(25)} (${s.code}) - ${s.type}`));
    }
    
    // Login credentials
    console.log('\n🔑 LOGIN CREDENTIALS:');
    console.log('─'.repeat(70));
    console.log('Admin: admin@school.com / admin123');
    console.log('Teachers: [teacher-email] / teacher123');
    console.log(`   Example: ${teachers[0].email} / teacher123`);
    
    console.log('\n✅ Complete database seeding finished successfully!');
    console.log('='.repeat(70));
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

// Run the seeding
seedDatabase();
