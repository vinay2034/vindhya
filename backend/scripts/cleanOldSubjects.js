const mongoose = require('mongoose');
require('dotenv').config();

const Subject = require('../models/Subject');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(async () => {
  console.log('✅ MongoDB Connected');
  
  // Find all subjects
  const subjects = await Subject.find({}).sort({ createdAt: -1 });
  
  console.log(`\n📚 Total Subjects: ${subjects.length}\n`);
  
  // Group by code to find duplicates
  const subjectsByCode = {};
  subjects.forEach(subject => {
    if (!subjectsByCode[subject.code]) {
      subjectsByCode[subject.code] = [];
    }
    subjectsByCode[subject.code].push(subject);
  });
  
  // Find subjects created before Nov 6, 2025 (old subjects)
  const oldSubjects = subjects.filter(s => {
    const createdDate = new Date(s.createdAt);
    const nov6 = new Date('2025-11-06T00:00:00');
    return createdDate < nov6;
  });
  
  console.log(`🗑️  Old Subjects (before Nov 6): ${oldSubjects.length}\n`);
  
  if (oldSubjects.length > 0) {
    console.log('Deleting old subjects:');
    for (const subject of oldSubjects) {
      console.log(`   - ${subject.name} (${subject.code}) - Created: ${subject.createdAt}`);
      await Subject.findByIdAndDelete(subject._id);
    }
    console.log(`\n✅ Deleted ${oldSubjects.length} old subjects`);
  }
  
  // Verify remaining subjects
  const remaining = await Subject.countDocuments({});
  console.log(`\n📊 Remaining Subjects: ${remaining}`);
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});
