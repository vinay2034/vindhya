const mongoose = require('mongoose');
const Timetable = require('../models/Timetable');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const User = require('../models/User');
require('dotenv').config();

// School timing: 10:00 AM to 3:00 PM, 30 min lunch at 12:00 PM
// Period structure:
// Period 1: 10:00 - 10:40 (40 min)
// Period 2: 10:40 - 11:20 (40 min)
// Period 3: 11:20 - 12:00 (40 min)
// LUNCH:    12:00 - 12:30 (30 min)
// Period 4: 12:30 - 1:10  (40 min)
// Period 5: 1:10  - 1:50  (40 min)
// Period 6: 1:50  - 2:30  (40 min)
// Period 7: 2:30  - 3:00  (30 min) - Activity/Games

const periods = [
  { period: 1, startTime: '10:00', endTime: '10:40' },
  { period: 2, startTime: '10:40', endTime: '11:20' },
  { period: 3, startTime: '11:20', endTime: '12:00' },
  { period: 4, startTime: '12:30', endTime: '13:10' },
  { period: 5, startTime: '13:10', endTime: '13:50' },
  { period: 6, startTime: '13:50', endTime: '14:30' },
  { period: 7, startTime: '14:30', endTime: '15:00' },
];

const weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const academicYear = '2024-2025';

// Timetable structure for different class levels
const classTimeTables = {
  // LKG & UKG - Focus on play-based learning
  kindergarten: {
    schedule: [
      { subjects: ['ENG-KG', 'HIN-KG', 'MTH-KG', 'EVS-KG', 'ART-KG', 'MUS-KG', 'Games'] },
      { subjects: ['HIN-KG', 'ENG-KG', 'EVS-KG', 'MTH-KG', 'MUS-KG', 'ART-KG', 'Games'] },
      { subjects: ['MTH-KG', 'EVS-KG', 'ENG-KG', 'HIN-KG', 'ART-KG', 'MUS-KG', 'Games'] },
      { subjects: ['EVS-KG', 'MTH-KG', 'HIN-KG', 'ENG-KG', 'MUS-KG', 'ART-KG', 'Games'] },
      { subjects: ['ENG-KG', 'MTH-KG', 'EVS-KG', 'HIN-KG', 'ART-KG', 'MUS-KG', 'Games'] },
      { subjects: ['HIN-KG', 'ENG-KG', 'MTH-KG', 'EVS-KG', 'ART-KG', 'MUS-KG', 'Games'] },
    ]
  },
  
  // Class 1-5 - Primary
  primary: {
    schedule: [
      { subjects: ['ENG-15', 'HIN-15', 'MTH-15', 'EVS-15', 'GK-15', 'CS-15', 'PE-15'] },
      { subjects: ['MTH-15', 'ENG-15', 'EVS-15', 'HIN-15', 'CS-15', 'ART-15', 'PE-15'] },
      { subjects: ['HIN-15', 'MTH-15', 'ENG-15', 'GK-15', 'EVS-15', 'CS-15', 'PE-15'] },
      { subjects: ['EVS-15', 'ENG-15', 'MTH-15', 'HIN-15', 'CS-15', 'GK-15', 'PE-15'] },
      { subjects: ['ENG-15', 'MTH-15', 'HIN-15', 'EVS-15', 'GK-15', 'ART-15', 'PE-15'] },
      { subjects: ['MTH-15', 'HIN-15', 'ENG-15', 'EVS-15', 'CS-15', 'GK-15', 'PE-15'] },
    ]
  },
  
  // Class 6-8 - Upper Primary
  upperPrimary: {
    schedule: [
      { subjects: ['ENG-68', 'HIN-68', 'MTH-68', 'SCI-68', 'SST-68', 'CS-68', 'PE-68'] },
      { subjects: ['MTH-68', 'SCI-68', 'ENG-68', 'HIN-68', 'SST-68', 'SKT-68', 'PE-68'] },
      { subjects: ['SCI-68', 'MTH-68', 'HIN-68', 'ENG-68', 'CS-68', 'SST-68', 'PE-68'] },
      { subjects: ['HIN-68', 'ENG-68', 'SST-68', 'MTH-68', 'SCI-68', 'SKT-68', 'PE-68'] },
      { subjects: ['ENG-68', 'MTH-68', 'SCI-68', 'HIN-68', 'CS-68', 'SST-68', 'PE-68'] },
      { subjects: ['MTH-68', 'SCI-68', 'ENG-68', 'SST-68', 'HIN-68', 'CS-68', 'ART-68'] },
    ]
  }
};

const getScheduleForClass = (className) => {
  if (className.includes('LKG') || className.includes('UKG')) {
    return classTimeTables.kindergarten;
  } else if (className.match(/Class [1-5]/)) {
    return classTimeTables.primary;
  } else if (className.match(/Class [6-8]/)) {
    return classTimeTables.upperPrimary;
  }
  return classTimeTables.primary; // default
};

const seedTimetables = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('📚 Connected to MongoDB');

    // Clear existing timetables
    await Timetable.deleteMany({});
    console.log('🗑️  Cleared existing timetables');

    // Fetch all classes, subjects, and teachers
    const classes = await Class.find({ isActive: true }).lean();
    const subjects = await Subject.find({ isActive: true }).lean();
    const teachers = await User.find({ role: 'teacher', isActive: true }).lean();

    console.log(`📖 Found ${classes.length} classes`);
    console.log(`📚 Found ${subjects.length} subjects`);
    console.log(`👨‍🏫 Found ${teachers.length} teachers`);

    if (teachers.length === 0) {
      console.log('❌ No teachers found. Please seed teachers first.');
      process.exit(1);
    }

    // Create subject code to ID mapping
    const subjectMap = {};
    subjects.forEach(subject => {
      subjectMap[subject.code] = subject._id;
    });

    const timetableEntries = [];
    const rooms = ['101', '102', '103', '104', '105', '201', '202', '203', '204', '205'];

    // For each class, create a complete timetable
    for (const classInfo of classes) {
      const schedule = getScheduleForClass(classInfo.className);
      const roomNumber = rooms[Math.floor(Math.random() * rooms.length)];

      console.log(`\n⏰ Creating timetable for ${classInfo.className} - ${classInfo.section}`);

      // For each day of the week
      weekDays.forEach((day, dayIndex) => {
        const daySchedule = schedule.schedule[dayIndex];

        // For each period
        periods.forEach((period, periodIndex) => {
          const subjectCode = daySchedule.subjects[periodIndex];
          
          // Skip if Games (not in subject list)
          if (subjectCode === 'Games') {
            return;
          }

          const subjectId = subjectMap[subjectCode];
          
          if (!subjectId) {
            console.log(`⚠️  Subject ${subjectCode} not found, skipping...`);
            return;
          }

          // Assign a random teacher for now
          const randomTeacher = teachers[Math.floor(Math.random() * teachers.length)];

          timetableEntries.push({
            classId: classInfo._id,
            subjectId: subjectId,
            teacherId: randomTeacher._id,
            dayOfWeek: day,
            startTime: period.startTime,
            endTime: period.endTime,
            room: roomNumber,
            academicYear: academicYear,
            isActive: true
          });
        });
      });
    }

    // Insert all timetable entries
    if (timetableEntries.length > 0) {
      await Timetable.insertMany(timetableEntries);
      console.log(`\n✅ Successfully created ${timetableEntries.length} timetable entries!`);
      
      // Show summary
      console.log('\n📊 Timetable Summary:');
      console.log(`   Classes: ${classes.length}`);
      console.log(`   Days per week: ${weekDays.length}`);
      console.log(`   Periods per day: 7 (including activity period)`);
      console.log(`   Total entries: ${timetableEntries.length}`);
      console.log(`   School timing: 10:00 AM - 3:00 PM`);
      console.log(`   Lunch break: 12:00 PM - 12:30 PM`);
      
      // Show sample timetable for one class
      const sampleClass = classes[0];
      const sampleEntries = await Timetable.find({ 
        classId: sampleClass._id,
        dayOfWeek: 'Monday'
      })
        .populate('subjectId', 'name code')
        .populate('teacherId', 'profile.name')
        .sort({ startTime: 1 })
        .lean();
      
      console.log(`\n📅 Sample Timetable - ${sampleClass.className} ${sampleClass.section} (Monday):`);
      sampleEntries.forEach(entry => {
        console.log(`   ${entry.startTime}-${entry.endTime}: ${entry.subjectId?.name || 'N/A'} (${entry.teacherId?.profile?.name || 'Teacher'})`);
      });
    } else {
      console.log('❌ No timetable entries created. Check subject mappings.');
    }

    await mongoose.connection.close();
    console.log('\n✅ Timetable seeding completed!');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error seeding timetables:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
};

seedTimetables();
