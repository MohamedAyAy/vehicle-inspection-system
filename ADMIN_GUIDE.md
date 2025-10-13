# 🔐 Admin & Moderator Guide

## How to Login as Admin/Moderator

### **Method 1: Register as Admin (First Time)**

1. **Open API Documentation:**
   - Visit: http://localhost:8001/docs

2. **Find the `/register` endpoint:**
   - Click on `POST /register`
   - Click "Try it out"

3. **Register with Admin Role:**
   ```json
   {
     "email": "admin@vehicle-inspection.com",
     "password": "AdminPass123",
     "role": "admin"
   }
   ```

4. **Execute** - You now have an admin account!

5. **Login:**
   - Use `/login` endpoint with the same credentials
   - Copy the `access_token` from the response

---

### **Method 2: Register as Technician**

Same process but use `"role": "technician"`:

```json
{
  "email": "tech@vehicle-inspection.com",
  "password": "TechPass123",
  "role": "technician"
}
```

---

### **Method 3: Via Frontend UI**

1. **Open:** http://localhost:3000

2. **Click "Register"**

3. **Fill in the form** with:
   - Email: `admin@example.com`
   - Password: `YourSecurePassword123`
   - **Role:** Select "admin" or "technician" from dropdown

4. **Submit** - Account created!

5. **Login** with your credentials

---

## 👥 User Roles

### **Customer** (Default)
- Book appointments
- View own appointments
- Make payments
- View inspection results

### **Technician**
- View all pending inspections
- View appointments ready for inspection
- Submit inspection results
- Update inspection status
- See vehicle information

### **Admin** (Full Access)
- All customer permissions
- All technician permissions
- View all appointments
- View all users
- Access system logs
- Manage all data

---

## 🎯 What Each Role Can Do

### **Customer Dashboard:**
- **URL:** http://localhost:3000/customer-dashboard.html
- Book new appointment
- View appointment history
- Process payments
- Download inspection reports

### **Technician Dashboard:**
- **URL:** http://localhost:3000/technician-dashboard.html
- View pending inspections (vehicles waiting)
- View in-progress inspections
- Start inspection for a vehicle
- Submit inspection results
- Update inspection status

### **Admin Dashboard:**
- **URL:** http://localhost:3000/admin-dashboard.html
- View all users
- View all appointments
- View all inspections
- View system logs
- Generate reports
- Manage time slots

---

## 🔧 API Endpoints by Role

### **Customer Endpoints:**
- `POST /register` - Register account
- `POST /login` - Login
- `POST /appointments` - Create appointment
- `GET /appointments/{user_id}` - Get own appointments
- `POST /payment` - Make payment
- `GET /inspections/result/{appointment_id}` - Get inspection results

### **Technician Endpoints:**
- All customer endpoints +
- `GET /inspections/pending` - Get pending inspections
- `GET /inspections/assigned/{technician_id}` - Get assigned inspections
- `POST /inspections/submit` - Submit inspection results
- `GET /appointments/all?status=confirmed` - Get confirmed appointments

### **Admin Endpoints:**
- All customer + technician endpoints +
- `GET /appointments/all` - Get all appointments
- `GET /log/all` - Get all system logs
- `GET /log/stats` - Get log statistics
- `DELETE /log/cleanup` - Cleanup old logs
- Full CRUD on all resources

---

## 📊 Test Accounts (Create These)

### **Admin Account:**
```json
{
  "email": "admin@vehicleinspection.com",
  "password": "Admin@2024!",
  "role": "admin"
}
```

### **Technician Account:**
```json
{
  "email": "tech.john@vehicleinspection.com",
  "password": "Tech@2024!",
  "role": "technician"
}
```

### **Customer Account:**
```json
{
  "email": "customer@example.com",
  "password": "Customer@2024!",
  "role": "customer"
}
```

---

## 🔑 Using Your Token

After login, you'll receive:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "user": {
    "email": "admin@example.com",
    "role": "admin",
    "user_id": "123e4567-e89b-12d3-a456-426614174000"
  }
}
```

**To use the token:**
1. Copy the `access_token` value
2. In API docs, click "Authorize" button
3. Enter: `Bearer YOUR_TOKEN_HERE`
4. Click "Authorize"
5. Now you can call protected endpoints!

---

## 🚀 Quick Start

### **Create Admin Account:**
```bash
# Using curl
curl -X POST "http://localhost:8001/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "AdminPass123",
    "role": "admin"
  }'
```

### **Login as Admin:**
```bash
curl -X POST "http://localhost:8001/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "AdminPass123"
  }'
```

---

## 📝 Notes

- **Default role** when registering is "customer"
- **Valid roles:** `customer`, `technician`, `admin`
- **Password requirements:** Minimum 8 characters
- **Tokens expire** after 24 hours (configurable in `.env`)
- **Case-sensitive:** Use exact role names

---

## ⚠️ Security Notes

- **Production:** Remove ability to self-register as admin
- **Production:** Implement email verification
- **Production:** Add password strength requirements
- **Production:** Add rate limiting
- **Production:** Use HTTPS only
- **Production:** Store JWT secret securely

---

## 🎉 You're Ready!

1. Register an admin account
2. Login to get your token
3. Access admin dashboard
4. Manage the entire system!

**Admin Dashboard:** http://localhost:3000/admin-dashboard.html
**API Docs:** http://localhost:8001/docs
