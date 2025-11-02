# MongoDB Remote Server Setup Guide

## Option 1: MongoDB Atlas (Recommended - Free Tier Available)

### Step 1: Create MongoDB Atlas Account
1. Go to [https://www.mongodb.com/cloud/atlas/register](https://www.mongodb.com/cloud/atlas/register)
2. Sign up for a free account
3. Verify your email address

### Step 2: Create a Cluster
1. Click **"Build a Database"**
2. Choose **"M0 FREE"** tier
3. Select a cloud provider and region (closest to your location)
4. Name your cluster (e.g., `school-management-cluster`)
5. Click **"Create"**

### Step 3: Configure Database Access
1. Go to **"Database Access"** in left sidebar
2. Click **"Add New Database User"**
3. Choose **"Password"** authentication
4. Set username: `school_admin`
5. Set password: (generate a strong password or use your own)
6. Set privileges to **"Read and write to any database"**
7. Click **"Add User"**

### Step 4: Configure Network Access
1. Go to **"Network Access"** in left sidebar
2. Click **"Add IP Address"**
3. For development, click **"Allow Access from Anywhere"** (0.0.0.0/0)
   - ⚠️ **For production**: Add specific IP addresses only
4. Click **"Confirm"**

### Step 5: Get Connection String
1. Go to **"Database"** in left sidebar
2. Click **"Connect"** on your cluster
3. Choose **"Connect your application"**
4. Select **"Node.js"** as driver
5. Copy the connection string (looks like):
   ```
   mongodb+srv://school_admin:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### Step 6: Update Backend Configuration
1. Open `backend/.env` file
2. Replace the `MONGODB_URI` with your connection string
3. Replace `<password>` with your actual password
4. Add database name after `.net/`:
   ```env
   MONGODB_URI=mongodb+srv://school_admin:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/school_management?retryWrites=true&w=majority
   ```

### Step 7: Restart Backend Server
```bash
cd backend
npm run dev
```

You should see: ✅ MongoDB Connected Successfully

---

## Option 2: Self-Hosted MongoDB Server

### Using MongoDB on Remote VPS/Server

1. **Install MongoDB on your server:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install mongodb
   
   # Or use official MongoDB installation
   wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
   echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
   sudo apt-get update
   sudo apt-get install -y mongodb-org
   ```

2. **Configure MongoDB for remote access:**
   Edit `/etc/mongod.conf`:
   ```yaml
   net:
     port: 27017
     bindIp: 0.0.0.0  # Allow connections from any IP
   
   security:
     authorization: enabled
   ```

3. **Create database user:**
   ```bash
   mongo
   use admin
   db.createUser({
     user: "school_admin",
     pwd: "your_secure_password",
     roles: [{ role: "readWrite", db: "school_management" }]
   })
   ```

4. **Open firewall port:**
   ```bash
   sudo ufw allow 27017
   ```

5. **Restart MongoDB:**
   ```bash
   sudo systemctl restart mongod
   ```

6. **Update backend .env:**
   ```env
   MONGODB_URI=mongodb://school_admin:your_secure_password@your-server-ip:27017/school_management?authSource=admin
   ```

---

## Option 3: Using Docker (Remote or Local)

### Docker Compose Setup

1. **Create `docker-compose.yml` in project root:**
   ```yaml
   version: '3.8'
   
   services:
     mongodb:
       image: mongo:latest
       container_name: school_management_db
       restart: always
       ports:
         - "27017:27017"
       environment:
         MONGO_INITDB_ROOT_USERNAME: school_admin
         MONGO_INITDB_ROOT_PASSWORD: secure_password
         MONGO_INITDB_DATABASE: school_management
       volumes:
         - mongodb_data:/data/db
   
   volumes:
     mongodb_data:
   ```

2. **Start MongoDB:**
   ```bash
   docker-compose up -d
   ```

3. **Update backend .env:**
   ```env
   MONGODB_URI=mongodb://school_admin:secure_password@localhost:27017/school_management?authSource=admin
   ```

---

## Testing Connection

After configuring, test your connection:

```bash
cd backend
node -e "const mongoose = require('mongoose'); mongoose.connect(process.env.MONGODB_URI || 'YOUR_CONNECTION_STRING').then(() => console.log('✅ Connected!')).catch(err => console.error('❌ Error:', err));"
```

---

## Troubleshooting

### Error: "Authentication failed"
- Check username and password are correct
- Ensure password doesn't contain special characters that need URL encoding
- Verify user has correct permissions

### Error: "Network timeout"
- Check firewall allows connections on port 27017
- Verify IP whitelist in MongoDB Atlas
- Ensure server is running

### Error: "ECONNREFUSED"
- MongoDB service is not running
- Wrong host/port in connection string
- Check if bindIp is set correctly

---

## Security Best Practices

1. **Use strong passwords** for database users
2. **Whitelist specific IPs** instead of 0.0.0.0/0
3. **Enable SSL/TLS** for production
4. **Rotate credentials** regularly
5. **Use environment variables** for sensitive data
6. **Enable MongoDB authentication** always
7. **Regular backups** of your database

---

## Recommended: MongoDB Atlas Free Tier

✅ **Pros:**
- Free 512MB storage
- Automatic backups
- High availability
- No server maintenance
- SSL/TLS enabled by default
- Easy scaling

❌ **Cons:**
- Limited storage on free tier
- Internet connection required
- Shared resources

For this project, **MongoDB Atlas** is recommended for ease of use and reliability.
