#!/usr/bin/env node

/**
 * MongoDB Connection Test Script
 * 
 * This script tests your MongoDB connection before starting the server.
 * Usage: node test-db-connection.js
 */

require('dotenv').config();
const mongoose = require('mongoose');

const testConnection = async () => {
  console.log('🔍 Testing MongoDB Connection...\n');
  console.log('📍 Connection String:', process.env.MONGODB_URI?.replace(/\/\/[^:]+:[^@]+@/, '//***:***@') || 'NOT SET');
  console.log('');

  try {
    const startTime = Date.now();
    
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 10000,
    });
    
    const endTime = Date.now();
    const duration = endTime - startTime;

    console.log('✅ SUCCESS! MongoDB Connection Established');
    console.log('');
    console.log('📊 Connection Details:');
    console.log('   Host:', conn.connection.host);
    console.log('   Database:', conn.connection.name);
    console.log('   Port:', conn.connection.port || 'N/A (Atlas)');
    console.log('   Connection Time:', duration + 'ms');
    console.log('');
    console.log('🎉 Your database is ready!');
    
    // Test write operation
    console.log('\n🧪 Testing Write Operation...');
    const TestCollection = mongoose.connection.db.collection('_test');
    await TestCollection.insertOne({ test: true, timestamp: new Date() });
    console.log('✅ Write operation successful');
    
    // Test read operation
    console.log('🧪 Testing Read Operation...');
    const result = await TestCollection.findOne({ test: true });
    console.log('✅ Read operation successful');
    
    // Cleanup
    await TestCollection.deleteOne({ test: true });
    console.log('✅ Cleanup successful');
    
    await mongoose.connection.close();
    console.log('\n🔌 Connection closed');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ CONNECTION FAILED\n');
    console.error('Error:', error.message);
    console.error('');
    
    // Helpful error messages
    console.log('💡 Troubleshooting Tips:');
    
    if (error.message.includes('ECONNREFUSED')) {
      console.log('   • MongoDB server is not running');
      console.log('   • Start MongoDB: sudo systemctl start mongod');
      console.log('   • Or use MongoDB Atlas for cloud hosting');
    } else if (error.message.includes('Authentication failed')) {
      console.log('   • Check your MongoDB username and password');
      console.log('   • Ensure user has correct permissions');
      console.log('   • Password may need URL encoding for special characters');
    } else if (error.message.includes('timed out') || error.message.includes('ETIMEDOUT')) {
      console.log('   • MongoDB server is not reachable');
      console.log('   • Check your network connection');
      console.log('   • Verify firewall allows port 27017');
      console.log('   • For Atlas: Check IP whitelist (0.0.0.0/0 for testing)');
    } else if (error.message.includes('Invalid connection string')) {
      console.log('   • Check MONGODB_URI format in .env file');
      console.log('   • Local: mongodb://localhost:27017/dbname');
      console.log('   • Atlas: mongodb+srv://user:pass@cluster.mongodb.net/dbname');
    } else if (!process.env.MONGODB_URI) {
      console.log('   • MONGODB_URI is not set in .env file');
      console.log('   • Copy .env.example to .env');
      console.log('   • Add your MongoDB connection string');
    }
    
    console.log('\n📖 See MONGODB_SETUP.md for detailed setup instructions');
    process.exit(1);
  }
};

// Run the test
testConnection();
