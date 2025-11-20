require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

async function checkTeacher() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const teacher = await User.findOne({ email: 'amit.singh@school.com' }).select('+password');
    
    if (teacher) {
      console.log('\n✅ Teacher Found:');
      console.log('   Email:', teacher.email);
      console.log('   Role:', teacher.role);
      console.log('   Active:', teacher.isActive);
      console.log('   Has Password:', !!teacher.password);
      
      // Test password
      const isMatch = await bcrypt.compare('teacher123', teacher.password);
      console.log('   Password Matches "teacher123":', isMatch);
      
      if (!isMatch) {
        console.log('\n❌ Password does NOT match!');
        console.log('   Resetting password to "teacher123"...');
        
        const hashedPassword = await bcrypt.hash('teacher123', 10);
        
        // Update directly without triggering pre-save middleware
        await User.updateOne(
          { email: 'amit.singh@school.com' },
          { $set: { password: hashedPassword } }
        );
        
        console.log('✅ Password reset successfully!');
      }
    } else {
      console.log('\n❌ Teacher NOT found in database');
    }

    await mongoose.connection.close();
    console.log('\n✅ Check completed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkTeacher();
