const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Connection options optimized for both local and remote MongoDB
    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
      socketTimeoutMS: 45000, // Close sockets after 45s of inactivity
      family: 4, // Use IPv4, skip trying IPv6
      maxPoolSize: 10, // Maintain up to 10 socket connections
      minPoolSize: 2, // Maintain at least 2 socket connections
      retryWrites: true, // Automatically retry certain write operations
      retryReads: true, // Automatically retry certain read operations
    };

    const conn = await mongoose.connect(process.env.MONGODB_URI, options);
    
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database: ${conn.connection.name}`);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB connection error:', err.message);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️  MongoDB disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      console.log('✅ MongoDB reconnected');
    });
    
    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('🔌 MongoDB connection closed through app termination');
      process.exit(0);
    });
    
  } catch (error) {
    console.error('❌ Error connecting to MongoDB:', error.message);
    console.error('💡 Tip: Check your MONGODB_URI in .env file');
    
    // Provide helpful error messages
    if (error.message.includes('ECONNREFUSED')) {
      console.error('💡 MongoDB server is not running or not accessible');
    } else if (error.message.includes('Authentication failed')) {
      console.error('💡 Check your MongoDB username and password');
    } else if (error.message.includes('timed out')) {
      console.error('💡 MongoDB server is not reachable. Check network/firewall');
    }
    
    process.exit(1);
  }
};

module.exports = connectDB;
