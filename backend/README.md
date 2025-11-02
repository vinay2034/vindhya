# School Management System - Backend API

## Overview
RESTful API backend for a comprehensive school management system with role-based access control for Admins, Teachers, and Parents.

## Tech Stack
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose ODM
- **Authentication:** JWT (JSON Web Tokens)
- **Validation:** Express Validator
- **File Upload:** Multer + Cloudinary

## Features
- ✅ Role-based authentication (Admin, Teacher, Parent)
- ✅ User management
- ✅ Student management
- ✅ Class and subject management
- ✅ Attendance tracking
- ✅ Fee management and payment processing
- ✅ Timetable management
- ✅ Media gallery
- ✅ Comprehensive reporting

## Installation

### Prerequisites
- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn

### Setup Steps

1. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and configure:
   - MongoDB connection string
   - JWT secrets
   - Cloudinary credentials (optional)
   - Payment gateway credentials (optional)

3. **Start MongoDB**
   ```bash
   # If using local MongoDB
   mongod
   
   # Or use MongoDB Atlas (cloud)
   ```

4. **Run the Server**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

The server will start on `http://localhost:5000`

## API Documentation

### Authentication Endpoints
```
POST   /api/auth/register  - Register new user
POST   /api/auth/login     - Login user
GET    /api/auth/me        - Get current user profile
PUT    /api/auth/profile   - Update user profile
POST   /api/auth/logout    - Logout user
```

### Admin Endpoints
```
GET    /api/admin/dashboard              - Admin dashboard stats
GET    /api/admin/users                  - Get all users
POST   /api/admin/users                  - Create new user
PUT    /api/admin/users/:id              - Update user
DELETE /api/admin/users/:id              - Delete user

GET    /api/admin/students               - Get all students
POST   /api/admin/students               - Create student
PUT    /api/admin/students/:id           - Update student
DELETE /api/admin/students/:id           - Delete student

GET    /api/admin/classes                - Get all classes
POST   /api/admin/classes                - Create class
PUT    /api/admin/classes/:id            - Update class
DELETE /api/admin/classes/:id            - Delete class

GET    /api/admin/subjects               - Get all subjects
POST   /api/admin/subjects               - Create subject
PUT    /api/admin/subjects/:id           - Update subject
DELETE /api/admin/subjects/:id           - Delete subject

GET    /api/admin/reports/attendance     - Attendance reports
GET    /api/admin/reports/fees           - Fee reports
```

### Teacher Endpoints
```
GET    /api/teacher/dashboard            - Teacher dashboard
GET    /api/teacher/classes              - Get assigned classes
GET    /api/teacher/students/:classId    - Get students by class
POST   /api/teacher/attendance           - Mark attendance
POST   /api/teacher/attendance/bulk      - Mark bulk attendance
GET    /api/teacher/attendance           - Get attendance records
GET    /api/teacher/fees/:studentId      - Get student fees
PUT    /api/teacher/fees/:feeId          - Update fee status
```

### Parent Endpoints
```
GET    /api/parent/dashboard             - Parent dashboard
GET    /api/parent/children              - Get children
GET    /api/parent/attendance/:studentId - Get student attendance
GET    /api/parent/fees/:studentId       - Get student fees
POST   /api/parent/fees/pay              - Make fee payment
GET    /api/parent/gallery               - Get media gallery
GET    /api/parent/progress/:studentId   - Get student progress
```

## Request/Response Examples

### Login Request
```json
POST /api/auth/login
{
  "email": "admin@school.com",
  "password": "admin123"
}
```

### Login Response
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": "64abc123...",
      "email": "admin@school.com",
      "role": "admin",
      "profile": {
        "name": "John Admin",
        "phone": "+1234567890"
      }
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Mark Attendance Request
```json
POST /api/teacher/attendance
Headers: Authorization: Bearer <token>
{
  "studentId": "64abc456...",
  "classId": "64abc789...",
  "date": "2024-11-02",
  "status": "present",
  "remarks": "On time"
}
```

## Database Models

### User Schema
- email, password, role (admin/teacher/parent)
- profile (name, phone, avatar, address, DOB, gender)
- isActive, timestamps

### Student Schema
- name, rollNumber, admissionNumber
- parentId (ref: User), classId (ref: Class)
- dateOfBirth, gender, bloodGroup, address
- emergencyContact, medicalInfo

### Class Schema
- className, section, academicYear
- classTeacher (ref: User), subjects (ref: Subject)
- capacity, room, schedule

### Attendance Schema
- studentId, classId, date, status
- remarks, markedBy (ref: User)

### Fee Schema
- studentId, academicYear, feeType, amount
- dueDate, status, paymentDate
- transactionId, receiptNumber

## Security Features
- Password hashing with bcrypt
- JWT token authentication
- Role-based access control
- Input validation and sanitization
- CORS enabled
- Helmet security headers
- Request compression

## Error Handling
All API responses follow a consistent format:

**Success Response:**
```json
{
  "status": "success",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "status": "error",
  "message": "Error description",
  "errors": [ ... ] // For validation errors
}
```

## Testing the API

### Using curl
```bash
# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@school.com","password":"admin123"}'

# Get dashboard (with token)
curl -X GET http://localhost:5000/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using Postman
1. Import the API collection (if available)
2. Set environment variables for base URL and token
3. Test endpoints with proper authorization headers

## Development Tips

### Creating Initial Admin User
```bash
# Use the register endpoint or directly insert into MongoDB
mongosh
use school_management
db.users.insertOne({
  email: "admin@school.com",
  password: "$2a$10$...", // bcrypt hashed password
  role: "admin",
  profile: {
    name: "Super Admin",
    phone: "+1234567890"
  },
  isActive: true,
  createdAt: new Date()
})
```

### Debugging
Enable detailed logging by setting:
```env
NODE_ENV=development
```

## Production Deployment

### Environment Setup
- Set `NODE_ENV=production`
- Use strong JWT secrets
- Enable HTTPS
- Set up MongoDB replica set
- Configure proper CORS origins
- Set up monitoring and logging

### Recommended Services
- **Hosting:** AWS EC2, Heroku, DigitalOcean
- **Database:** MongoDB Atlas
- **File Storage:** Cloudinary, AWS S3
- **Payment:** Razorpay, Stripe

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT License

## Support
For issues and questions, please open an issue on GitHub.
