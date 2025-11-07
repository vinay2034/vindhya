const mongoose = require('mongoose');
require('dotenv').config();

const Subject = require('../models/Subject');

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/school_management', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(async () => {
  console.log('✅ MongoDB Connected');
  
  const subjects = await Subject.find({}).select('name code description createdAt');
  
  console.log(`\n📚 Total Subjects in Database: ${subjects.length}\n`);
  
  subjects.forEach((subject, index) => {
    console.log(`${index + 1}. ${subject.name} (${subject.code})`);
    console.log(`   Description: ${subject.description}`);
    console.log(`   Created: ${subject.createdAt}`);
    console.log('');
  });
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});
