/**
 * Script to assign subjects to a teacher
 * Usage: node scripts/assignSubjectsToTeacher.js <teacherEmail> <subjectIds...>
 * Example: node scripts/assignSubjectsToTeacher.js teacher@school.com 67890abc 12345def
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Subject = require('../models/Subject');

const assignSubjects = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Get arguments
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
      console.log('\n📋 Usage:');
      console.log('  node scripts/assignSubjectsToTeacher.js <teacherEmail> [subjectIds...]');
      console.log('\n📝 Examples:');
      console.log('  - List all teachers: node scripts/assignSubjectsToTeacher.js --list-teachers');
      console.log('  - List all subjects: node scripts/assignSubjectsToTeacher.js --list-subjects');
      console.log('  - Assign subjects: node scripts/assignSubjectsToTeacher.js teacher@school.com 67890abc 12345def');
      console.log('  - Assign all subjects: node scripts/assignSubjectsToTeacher.js teacher@school.com --all\n');
      process.exit(0);
    }

    // Handle list commands
    if (args[0] === '--list-teachers') {
      const teachers = await User.find({ role: 'teacher' }).select('email profile.name subjectsTaught');
      console.log('\n👨‍🏫 Teachers:');
      for (const teacher of teachers) {
        console.log(`  - ${teacher.email} (${teacher.profile?.name || 'No name'}) - ${teacher.subjectsTaught?.length || 0} subjects assigned`);
      }
      console.log();
      process.exit(0);
    }

    if (args[0] === '--list-subjects') {
      const subjects = await Subject.find({ isActive: true }).select('name code _id');
      console.log('\n📚 Subjects:');
      for (const subject of subjects) {
        console.log(`  - ${subject.name} (${subject.code}) - ID: ${subject._id}`);
      }
      console.log();
      process.exit(0);
    }

    // Assign subjects
    const teacherEmail = args[0];
    const subjectArgs = args.slice(1);

    // Find teacher
    const teacher = await User.findOne({ email: teacherEmail, role: 'teacher' });
    if (!teacher) {
      console.error(`❌ Teacher not found with email: ${teacherEmail}`);
      process.exit(1);
    }

    console.log(`\n👨‍🏫 Found teacher: ${teacher.profile?.name || teacher.email}`);

    // Get subjects
    let subjectIds = [];
    
    if (subjectArgs.includes('--all')) {
      const allSubjects = await Subject.find({ isActive: true }).select('_id');
      subjectIds = allSubjects.map(s => s._id);
      console.log(`📚 Assigning ALL ${subjectIds.length} subjects`);
    } else {
      subjectIds = subjectArgs;
      console.log(`📚 Assigning ${subjectIds.length} subjects`);
    }

    // Update teacher
    teacher.subjectsTaught = subjectIds;
    await teacher.save();

    // Verify
    const updatedTeacher = await User.findById(teacher._id).populate('subjectsTaught', 'name code');
    console.log('\n✅ Successfully assigned subjects:');
    for (const subject of updatedTeacher.subjectsTaught) {
      console.log(`  - ${subject.name} (${subject.code})`);
    }

    console.log(`\n🎉 Done! Teacher now has ${updatedTeacher.subjectsTaught.length} subjects assigned.\n`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
};

assignSubjects();
