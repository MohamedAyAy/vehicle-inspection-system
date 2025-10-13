# 🚗 Vehicle Inspection System

A comprehensive microservices-based vehicle inspection management system built with FastAPI, PostgreSQL, and modern Python technologies.

## 🌟 Features

### Core Functionality
- ✅ **User Authentication** - Secure JWT-based authentication with role management
- ✅ **Appointment Booking** - Schedule vehicle inspections with real-time slot availability
- ✅ **Dual Payment System** - Separate reservation and inspection fee payments
- ✅ **Vehicle Inspection** - Complete inspection workflow for technicians
- ✅ **PDF Report Generation** - Professional inspection reports with payment verification
- ✅ **Vehicle Status Tracking** - Real-time inspection status for customers
- ✅ **Admin Dashboard** - Complete system monitoring and management
- ✅ **Centralized Logging** - Color-coded event logging with human-readable messages
- ✅ **Billing/Facturation** - Automated invoice generation for inspection fees

### Recent Enhancements
- 🎨 **Enhanced Logging**: Technician emails and vehicle numbers in logs (not UUIDs)
- 📊 **Admin View**: See ALL vehicles, not just inspected ones
- 📄 **PDF Reports**: Professional reports with color-coded results
- 💰 **Invoice System**: Auto-generated invoice numbers (INV-YYYYMMDD-XXXXXXXX)
- 🔐 **Payment Verification**: Reports require inspection payment (HTTP 402)

## 🏗️ Architecture

### Microservices

```
┌─────────────────┐
│  Auth Service   │  Port 8001 - User authentication & JWT
└─────────────────┘
         │
┌─────────────────┐
│ Appointment     │  Port 8002 - Booking, scheduling, reports
│ Service         │
└─────────────────┘
         │
┌─────────────────┐
│ Payment Service │  Port 8003 - Dual payments, invoices
└─────────────────┘
         │
┌─────────────────┐
│ Inspection      │  Port 8004 - Technician inspections
│ Service         │
└─────────────────┘
         │
┌─────────────────┐
│ Logging Service │  Port 8005 - Centralized event logging
└─────────────────┘
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
CREATE DATABASE users_db;
CREATE DATABASE appointments_db;
CREATE DATABASE payments_db;
CREATE DATABASE inspections_db;
CREATE DATABASE logs_db;
```

### 2. Install Dependencies

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

## 📝 License

This project is licensed under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with ❤️ using FastAPI and PostgreSQL**
