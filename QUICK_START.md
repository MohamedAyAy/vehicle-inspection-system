# 🚀 Quick Start Guide - Vehicle Inspection System

## ⚡ Get Running in 5 Minutes

### Step 1: Create Databases (2 minutes)
```powershell
# Open PowerShell and run:
cd C:\Users\HP\Desktop\vehicle-inspection-system
psql -U postgres -f init-databases.sql
# Enter password when prompted: azerty5027
```

### Step 2: Install Dependencies (2 minutes)
```powershell
# Install Python packages for all services
cd backend\auth-service
pip install -r requirements.txt

cd ..\appointment-service
pip install -r requirements.txt

cd ..\payment-service
pip install -r requirements.txt

cd ..\inspection-service
pip install -r requirements.txt

cd ..\logging-service
pip install -r requirements.txt

cd ..\..
```

### Step 3: Start All Services (1 minute)
```powershell
# From project root:
.\START_ALL_SERVICES.ps1
```

**OR manually open 5 PowerShell windows and run:**
1. `cd backend\logging-service && python main.py`
2. `cd backend\auth-service && python main.py`
3. `cd backend\appointment-service && python main.py`
4. `cd backend\payment-service && python main.py`
5. `cd backend\inspection-service && python main.py`

### Step 4: Verify Everything Works
Visit: http://localhost:8001/docs

You should see the Auth Service API documentation!

---

## 🧪 Quick Test

### Register a User:
```bash
POST http://localhost:8001/register
{
  "email": "test@example.com",
  "password": "password123",
  "role": "customer"
}
```

### Login:
```bash
POST http://localhost:8001/login
{
  "email": "test@example.com",
  "password": "password123"
}
```

You'll receive a JWT token - copy it for authenticated requests!

---

## 📌 Service URLs

| Service | Port | Health | API Docs |
|---------|------|--------|----------|
| Auth | 8001 | /health | /docs |
| Appointment | 8002 | /health | /docs |
| Payment | 8003 | /health | /docs |
| Inspection | 8004 | /health | /docs |
| Logging | 8005 | /health | /docs |

---

## ❓ Problems?

### "PostgreSQL not running"
```powershell
# Start PostgreSQL in Windows Services
services.msc
# Find "postgresql-x64-XX" and click Start
```

### "Database does not exist"
```powershell
psql -U postgres -f init-databases.sql
```

### "Port already in use"
```powershell
netstat -ano | findstr :8001
taskkill /PID <PID> /F
```

### "Module not found"
```powershell
cd backend\<service-name>
pip install -r requirements.txt --force-reinstall
```

---

## 📚 Full Documentation

- **INSTALL_REQUIREMENTS.md** - Complete setup guide
- **CRITICAL_WARNINGS.txt** - Common errors & solutions
- **README_SQLALCHEMY_MIGRATION.md** - Technical details

---

## ✅ Success Checklist

- [ ] PostgreSQL running
- [ ] 5 databases created
- [ ] Dependencies installed
- [ ] All 5 services running
- [ ] Can access http://localhost:8001/docs
- [ ] Can register and login

**If all checked - YOU'RE READY TO GO! 🎉**
