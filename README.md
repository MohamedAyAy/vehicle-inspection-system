# 🚗 Vehicle Inspection System

A comprehensive microservices-based vehicle inspection management system built with FastAPI, PostgreSQL, and modern Python technologies.

## 🚀 **LATEST VERSION: 2.0**

**GitHub:** https://github.com/Mohamed5027/vehicle-inspection-system  
**Tags:** v1.0 (stable), v2.0 (latest)

## 🌟 Features

### Core Functionality (V1.0)
- ✅ **User Authentication** - Secure JWT-based authentication with role management
- ✅ **Appointment Booking** - Schedule vehicle inspections with real-time slot availability
- ✅ **Payment System** - Simulated payment processing
- ✅ **Vehicle Inspection** - Complete inspection workflow for technicians
- ✅ **PDF Report Generation** - Professional inspection reports with payment verification
- ✅ **Vehicle Status Tracking** - Real-time inspection status for customers
- ✅ **Admin Dashboard** - Complete system monitoring and management (5 tabs)
- ✅ **Centralized Logging** - Color-coded event logging with human-readable messages
- ✅ **Billing/Facturation** - Automated invoice generation for inspection fees
- ✅ **Technician Dashboard** - View ALL vehicles (paid and unpaid)

### New Features (V2.0) 🆕
- 📧 **Notification Service** - Simulated email/SMS notifications (no real costs!)
- 📷 **File Upload Service** - Upload vehicle photos during inspection
- 📬 **In-App Notifications** - User notification inbox
- 🖼️ **Photo Management** - Organize photos by inspection/appointment
- ✉️ **Notification Templates** - Pre-built messages for common events
- 📊 **Upload Statistics** - Track file uploads and storage

## 🏗️ Architecture

### Microservices (7 Services)

```
┌──────────────────┐
│  Auth Service    │  Port 8001 - User authentication & JWT
└──────────────────┘
         │
┌──────────────────┐
│ Appointment      │  Port 8002 - Booking, scheduling, reports
│ Service          │
└──────────────────┘
         │
┌──────────────────┐
│ Payment Service  │  Port 8003 - Payments, invoices
└──────────────────┘
         │
┌──────────────────┐
│ Inspection       │  Port 8004 - Technician inspections
│ Service          │
└──────────────────┘
         │
┌──────────────────┐
│ Logging Service  │  Port 8005 - Centralized event logging
└──────────────────┘
         │
┌──────────────────┐
│ Notification     │  Port 8006 - Simulated email/SMS 🆕
│ Service          │
└──────────────────┘
         │
┌──────────────────┐
│ File Service     │  Port 8007 - Photo uploads 🆕
└──────────────────┘
```

### Tech Stack
- **Backend**: FastAPI (Python 3.10+)
- **Database**: PostgreSQL with async (asyncpg)
- **ORM**: SQLAlchemy 2.0 (async)
- **Authentication**: JWT (PyJWT)
- **PDF Generation**: ReportLab
- **API Docs**: Swagger UI (FastAPI automatic)

## 🚀 Quick Start

### Prerequisites
- Python 3.10 or higher
- PostgreSQL 12 or higher
- PowerShell (Windows) or Bash (Linux/Mac)

### 1. Database Setup

```sql
-- Connect to PostgreSQL and create databases
CREATE DATABASE auth_db;
CREATE DATABASE appointments_db;
CREATE DATABASE payments_db;
CREATE DATABASE inspections_db;
CREATE DATABASE logs_db;
CREATE DATABASE notifications_db;  -- NEW in v2.0
CREATE DATABASE files_db;           -- NEW in v2.0
```

**Or use the SQL script:**
```powershell
psql -U postgres -f SETUP_NEW_DATABASES.sql
```

### 2. Install Dependencies

**Option 1: Use automated script (NEW in v2.0)**
```powershell
.\INSTALL_NEW_SERVICES.ps1
```

**Option 2: Manual installation**
```powershell
# Navigate to project directory
cd vehicle-inspection-system

# Install dependencies for each service
cd backend/auth-service
pip install -r requirements.txt

cd ../appointment-service
pip install -r requirements.txt

cd ../payment-service
pip install -r requirements.txt

cd ../inspection-service
pip install -r requirements.txt

cd ../logging-service
pip install -r requirements.txt

cd ../notification-service  # NEW in v2.0
pip install -r requirements.txt

cd ../file-service  # NEW in v2.0
pip install -r requirements.txt

cd ../..
```

### 3. Configure Environment

Create `.env` files in each service directory with:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET_KEY=your-secret-key-change-this-in-production
```

### 4. Run Database Migrations

```powershell
# Appointments Service
cd backend/appointment-service
python migrate_db.py

# Payment Service
cd ../payment-service
python migrate_db.py
```

### 5. Start All Services

**Windows:**
```powershell
.\START_COMPLETE_SYSTEM.ps1
```

**Manual Start:**
```powershell
# Start each service in separate terminals
cd backend/logging-service && python main.py
cd backend/auth-service && python main.py
cd backend/appointment-service && python main.py
cd backend/payment-service && python main.py
cd backend/inspection-service && python main.py
```

### 6. Access API Documentation

- Auth Service: http://localhost:8001/docs
- Appointment Service: http://localhost:8002/docs
- Payment Service: http://localhost:8003/docs
- Inspection Service: http://localhost:8004/docs
- Logging Service: http://localhost:8005/docs
- Notification Service: http://localhost:8006/docs 🆕
- File Service: http://localhost:8007/docs 🆕
- **Frontend:** http://localhost:3000

### 7. Test All Services

```powershell
.\TEST_ALL_SERVICES.ps1
```

This will verify all 7 services are running and healthy.

## 📖 API Usage

### Authentication

```http
POST http://localhost:8001/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "role": "customer"
}
```

```http
POST http://localhost:8001/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Book Appointment

```http
POST http://localhost:8002/appointments
Authorization: Bearer {token}
Content-Type: application/json

{
  "vehicle_info": {
    "registration": "ABC-123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "type": "sedan"
  },
  "appointment_date": "2025-10-20T10:00:00"
}
```

### View My Vehicles

```http
GET http://localhost:8002/appointments/my-vehicles
Authorization: Bearer {token}
```

### Generate PDF Report

```http
GET http://localhost:8002/appointments/my-vehicle/{appointment_id}/report
Authorization: Bearer {token}
```

## 🔄 Complete Workflow

1. **Customer** registers/logs in
2. **Customer** books appointment
3. **Customer** pays reservation fee
4. **System** confirms appointment
5. **Technician** inspects vehicle
6. **System** updates inspection status
7. **Customer** pays inspection fee
8. **System** generates invoice
9. **Customer** downloads PDF report
10. **Admin** monitors via dashboard

## 📊 Database Schema

### Appointments
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `vehicle_info` (JSON)
- `appointment_date` (Timestamp)
- `status` (VARCHAR) - pending, confirmed, completed, cancelled
- `inspection_status` (VARCHAR) - not_checked, in_progress, passed, failed, passed_with_minor_issues
- `payment_id` (UUID, FK) - Reservation payment
- `inspection_payment_id` (UUID, FK) - Inspection fee payment

### Payments
- `id` (UUID, PK)
- `appointment_id` (UUID, FK)
- `user_id` (UUID, FK)
- `amount` (Decimal)
- `payment_type` (VARCHAR) - reservation, inspection_fee
- `invoice_number` (VARCHAR) - Auto-generated for inspection fees
- `status` (VARCHAR) - pending, completed, failed

### Inspections
- `id` (UUID, PK)
- `appointment_id` (UUID, FK)
- `technician_id` (UUID, FK)
- `results` (JSON) - Inspection checklist results
- `final_status` (VARCHAR)
- `notes` (Text)

## 🧪 Testing

### PowerShell Test Script

```powershell
# Login
$body = '{"email":"customer@test.com","password":"pass123"}'
$login = Invoke-RestMethod -Uri "http://localhost:8001/login" `
  -Method POST -Body $body -ContentType "application/json"

# Get my vehicles
$vehicles = Invoke-RestMethod `
  -Uri "http://localhost:8002/appointments/my-vehicles" `
  -Headers @{ 'Authorization' = "Bearer $($login.access_token)" }

Write-Host "Total vehicles: $($vehicles.total_count)"
```

## 🐛 Troubleshooting

### Services won't start
- Check PostgreSQL is running
- Verify database credentials in `.env` files
- Ensure all databases are created
- Check ports 8001-8005 are not in use

### Database errors
- Run migration scripts: `python migrate_db.py`
- Check database connection settings
- Verify PostgreSQL version (12+)

### PDF generation fails
- Install reportlab: `pip install reportlab==4.0.7`
- Check inspection is complete
- Verify inspection payment is made

## 🆕 New Features in V2.0

### Notification Service
Send simulated email/SMS notifications without real costs:

```http
POST http://localhost:8006/notifications/send
Content-Type: application/json

{
  "user_id": "uuid-here",
  "user_email": "user@example.com",
  "notification_type": "email",
  "channel": "appointment",
  "subject": "Appointment Confirmed",
  "message": "Your appointment has been confirmed..."
}
```

Get user notifications:
```http
GET http://localhost:8006/notifications/user/{user_id}
```

### File Upload Service
Upload vehicle photos for documentation:

```http
POST http://localhost:8007/files/upload
Content-Type: multipart/form-data

file: [binary data]
uploaded_by: uuid-here
inspection_id: uuid-here
photo_type: damage
description: Front bumper scratch
```

Get files for inspection:
```http
GET http://localhost:8007/files/inspection/{inspection_id}
```

## 📚 Documentation

- **Quick Start:** See `READ_ME_FIRST.md`
- **Deployment:** See `DEPLOYMENT_GUIDE.md`
- **V2 Features:** See `V2_FEATURES.md`
- **Testing:** See `COMPLETE_TEST.md`

## 📊 System Statistics

- **Services:** 7 microservices
- **Databases:** 7 PostgreSQL databases
- **Endpoints:** 50+ REST API endpoints
- **Lines of Code:** 15,000+
- **Features:** 25+ major features
- **Tech Stack:** Python, FastAPI, PostgreSQL, SQLAlchemy

## 📝 License

This project is licensed under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using FastAPI and PostgreSQL**

**Version 2.0** - October 2024
