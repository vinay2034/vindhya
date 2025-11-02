#!/usr/bin/env node

/**
 * Seed Database Script
 * Creates initial users in the remote MongoDB database
 */

require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Import models
const User = require('./models/User');

const seedUsers = async () => {
  try {
    console.log('🔄 Connecting to MongoDB Atlas...\n');
    
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB Atlas');
    console.log('📊 Database:', mongoose.connection.name);
    console.log('');

    // Check if users already exist
    const existingUsers = await User.countDocuments();
    
    if (existingUsers > 0) {
      console.log(`⚠️  Database already has ${existingUsers} user(s)`);
      console.log('Do you want to:');
      console.log('  1. Add new users (keep existing)');
      console.log('  2. Clear all and recreate');
      console.log('  3. Skip seeding');
      console.log('');
      console.log('For now, adding new users without clearing...\n');
    }

    // Create users
    const usersToCreate = [
      {
        email: 'admin@school.com',
        password: 'admin123',
        role: 'admin',
        profile: {
          name: 'Admin User',
          phone: '9876543210',
          gender: 'male',
          address: 'School Admin Office'
        }
      },
      {
        email: 'teacher@school.com',
        password: 'teacher123',
        role: 'teacher',
        profile: {
          name: 'John Teacher',
          phone: '9876543211',
          gender: 'male',
          address: 'Teachers Block'
        }
      },
      {
        email: 'parent@school.com',
        password: 'parent123',
        role: 'parent',
        profile: {
          name: 'Mary Parent',
          phone: '9876543212',
          gender: 'female',
          address: 'Parent Address'
        }
      }
    ];

    console.log('👥 Creating users...\n');

    for (const userData of usersToCreate) {
      try {
        // Check if user already exists
        const existingUser = await User.findOne({ email: userData.email });
        
        if (existingUser) {
          console.log(`⏭️  Skipped: ${userData.email} (already exists)`);
          continue;
        }

        // Create new user
        const user = new User(userData);
        await user.save();
        
        console.log(`✅ Created: ${userData.role.toUpperCase()} - ${userData.email}`);
      } catch (error) {
        console.error(`❌ Failed to create ${userData.email}:`, error.message);
      }
    }

    // Display summary
    console.log('\n📊 Database Summary:');
    const totalUsers = await User.countDocuments();
    const adminCount = await User.countDocuments({ role: 'admin' });
    const teacherCount = await User.countDocuments({ role: 'teacher' });
    const parentCount = await User.countDocuments({ role: 'parent' });
    
    console.log(`   Total Users: ${totalUsers}`);
    console.log(`   Admins: ${adminCount}`);
    console.log(`   Teachers: ${teacherCount}`);
    console.log(`   Parents: ${parentCount}`);

    console.log('\n🎉 Database seeding completed!');
    console.log('\n📝 Demo Credentials:');
    console.log('   Admin:   admin@school.com   / admin123');
    console.log('   Teacher: teacher@school.com / teacher123');
    console.log('   Parent:  parent@school.com  / parent123');

    await mongoose.connection.close();
    console.log('\n🔌 Connection closed');
    process.exit(0);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    
    if (error.message.includes('auth')) {
      console.log('\n💡 Check your MongoDB Atlas credentials in .env file');
    } else if (error.message.includes('connect')) {
      console.log('\n💡 Check your internet connection and MongoDB Atlas IP whitelist');
    }
    
    process.exit(1);
  }
};

// Run the seeding
console.log('🌱 Database Seeding Script');
console.log('==========================\n');
seedUsers();
