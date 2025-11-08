const mongoose = require('mongoose');
const Timetable = require('../models/Timetable');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const User = require('../models/User');

const uri = 'mongodb+srv://vinaynaidu:Vinay%402005@cluster0.fvfef.mongodb.net/school_management?retryWrites=true&w=majority&appName=Cluster0';

async function checkTimetable() {
  try {
    await mongoose.connect(uri);
    console.log('✅ Connected to MongoDB');

    // Get all classes
    const classes = await Class.find();
    console.log(`\n📚 Total classes: ${classes.length}`);

    // Get total timetable entries
    const totalTimetables = await Timetable.countDocuments();
    console.log(`📅 Total timetable entries: ${totalTimetables}`);

    // Check for specific class
    if (classes.length > 0) {
      const firstClass = classes[0];
      console.log(`\n🔍 Checking timetable for: ${firstClass.className} ${firstClass.section}`);

      const classTimetables = await Timetable.find({ classId: firstClass._id })
        .populate('classId', 'className section')
        .populate('subjectId', 'name code')
        .populate('teacherId', 'profile.name email');

      console.log(`   Found ${classTimetables.length} entries`);

      if (classTimetables.length > 0) {
        console.log(`\n📖 Sample entries for ${firstClass.className} ${firstClass.section}:`);
        
        // Group by day
        const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        
        for (const day of days.slice(0, 2)) { // Show first 2 days
          const dayEntries = classTimetables.filter(t => t.dayOfWeek === day);
          if (dayEntries.length > 0) {
            console.log(`\n   ${day}:`);
            dayEntries.forEach(entry => {
              console.log(`     ${entry.startTime}-${entry.endTime}: ${entry.subjectId?.name || 'N/A'} (${entry.teacherId?.profile?.name || 'N/A'}) - Room ${entry.room || 'N/A'}`);
            });
          }
        }
      }
    }

    // Check academic year distribution
    const timetablesByYear = await Timetable.aggregate([
      { $group: { _id: '$academicYear', count: { $sum: 1 } } }
    ]);
    
    console.log(`\n📊 Timetables by Academic Year:`);
    timetablesByYear.forEach(year => {
      console.log(`   ${year._id}: ${year.count} entries`);
    });

    await mongoose.connection.close();
    console.log('\n✅ Check completed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkTimetable();
