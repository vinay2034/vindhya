require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

async function resetAllTeacherPasswords() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Find all teachers
    const teachers = await User.find({ role: 'teacher' }).select('+password');
    console.log(`Found ${teachers.length} teachers\n`);

    const hashedPassword = await bcrypt.hash('teacher123', 10);

    let updated = 0;
    let alreadyCorrect = 0;

    for (const teacher of teachers) {
      // Check if password already matches
      const isMatch = await bcrypt.compare('teacher123', teacher.password);
      
      if (!isMatch) {
        // Update password
        await User.updateOne(
          { _id: teacher._id },
          { $set: { password: hashedPassword } }
        );
        console.log(`✅ Reset password for: ${teacher.email}`);
        updated++;
      } else {
        console.log(`✓  Already correct: ${teacher.email}`);
        alreadyCorrect++;
      }
    }

    console.log(`\n📊 Summary:`);
    console.log(`   Total teachers: ${teachers.length}`);
    console.log(`   Passwords reset: ${updated}`);
    console.log(`   Already correct: ${alreadyCorrect}`);
    console.log(`\n✅ All teacher passwords are now: teacher123`);

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

resetAllTeacherPasswords();
