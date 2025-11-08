const mongoose = require('mongoose');
const User = require('../models/User');

const uri = 'mongodb+srv://vinaynaidu:Vinay%402005@cluster0.fvfef.mongodb.net/school_management?retryWrites=true&w=majority&appName=Cluster0';

async function checkAdmin() {
  try {
    await mongoose.connect(uri);
    console.log('✅ Connected to MongoDB');

    // Check if admin user exists
    const adminUser = await User.findOne({ email: 'admin@school.com' });
    
    if (adminUser) {
      console.log('\n✅ Admin user found:');
      console.log('   Email:', adminUser.email);
      console.log('   Role:', adminUser.role);
      console.log('   Active:', adminUser.isActive);
      console.log('   Password Hash exists:', !!adminUser.password);
    } else {
      console.log('\n❌ Admin user NOT found in database');
      console.log('\n📝 Creating admin user...');
      
      const bcrypt = require('bcryptjs');
      const hashedPassword = await bcrypt.hash('admin123', 10);
      
      const newAdmin = new User({
        email: 'admin@school.com',
        password: hashedPassword,
        role: 'admin',
        isActive: true,
        profile: {
          name: 'System Administrator',
          phone: '1234567890'
        }
      });
      
      await newAdmin.save();
      console.log('✅ Admin user created successfully');
    }

    await mongoose.connection.close();
    console.log('\n✅ Check completed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkAdmin();
