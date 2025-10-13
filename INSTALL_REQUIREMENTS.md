# Installation Guide for Vehicle Inspection System

## Prerequisites
- Python 3.9 or higher
- PostgreSQL 12 or higher running on Windows
- pip (Python package manager)

## Step 1: Remove Existing Packages (if any conflicts)

Open PowerShell as Administrator and run:

```powershell
# Navigate to each service directory and uninstall conflicting packages
cd backend\auth-service
pip uninstall -y PyJWT python-jose asyncpg sqlalchemy

cd ..\appointment-service
pip uninstall -y PyJWT python-jose asyncpg sqlalchemy

cd ..\payment-service
pip uninstall -y PyJWT python-jose asyncpg sqlalchemy

cd ..\inspection-service
pip uninstall -y PyJWT python-jose asyncpg sqlalchemy

cd ..\logging-service
pip uninstall -y PyJWT python-jose asyncpg sqlalchemy
```

## Step 2: Install Requirements for Each Service

### Auth Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\auth-service
pip install -r requirements.txt
```

### Appointment Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\appointment-service
pip install -r requirements.txt
```

### Payment Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\payment-service
pip install -r requirements.txt
```

### Inspection Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\inspection-service
pip install -r requirements.txt
```

### Logging Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\logging-service
pip install -r requirements.txt
```

## Step 3: Create Databases in PostgreSQL

Open **pgAdmin 4** or use **psql** command line:

```sql
-- Connect to postgres database first
CREATE DATABASE auth_db;
CREATE DATABASE appointments_db;
CREATE DATABASE payments_db;
CREATE DATABASE inspections_db;
CREATE DATABASE logs_db;
```

Or using psql command line:
```powershell
psql -U postgres
```
Then run the SQL commands above.

## Step 4: Verify .env File

Ensure your `.env` file at the project root has correct settings for Windows local development:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=azerty5027

# URLs (for local Windows development)
LOGGING_SERVICE_URL=http://localhost:8005
PAYMENT_SERVICE_URL=http://localhost:8003
APPOINTMENT_SERVICE_URL=http://localhost:8002
AUTH_SERVICE_URL=http://localhost:8001
INSPECTION_SERVICE_URL=http://localhost:8004
```

## Step 5: Start Services

Open **5 separate PowerShell windows** and run each service:

### Window 1 - Logging Service (START THIS FIRST!)
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\logging-service
python main.py
```

### Window 2 - Auth Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\auth-service
python main.py
```

### Window 3 - Appointment Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\appointment-service
python main.py
```

### Window 4 - Payment Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\payment-service
python main.py
```

### Window 5 - Inspection Service
```powershell
cd C:\Users\HP\Desktop\vehicle-inspection-system\backend\inspection-service
python main.py
```

## Step 6: Verify Services Are Running

Check each service health endpoint:
- Auth: http://localhost:8001/health
- Appointment: http://localhost:8002/health
- Payment: http://localhost:8003/health
- Inspection: http://localhost:8004/health
- Logging: http://localhost:8005/health

## Step 7: Access API Documentation

Each service has interactive API docs at `/docs`:
- Auth: http://localhost:8001/docs
- Appointment: http://localhost:8002/docs
- Payment: http://localhost:8003/docs
- Inspection: http://localhost:8004/docs
- Logging: http://localhost:8005/docs

## Troubleshooting

### Issue: "Port already in use"
**Solution:** Kill the process using that port:
```powershell
# Find process on port (e.g., 8001)
netstat -ano | findstr :8001
# Kill process by PID
taskkill /PID <PID> /F
```

### Issue: "asyncpg.exceptions.InvalidCatalogNameError: database does not exist"
**Solution:** Create the database in PostgreSQL (see Step 3)

### Issue: "ModuleNotFoundError"
**Solution:** Reinstall requirements:
```powershell
pip install -r requirements.txt --force-reinstall
```

### Issue: "Connection refused" to PostgreSQL
**Solution:** 
1. Ensure PostgreSQL is running (check Windows Services)
2. Verify credentials in .env file
3. Test connection:
```powershell
psql -U postgres -h localhost
```

### Issue: SQLAlchemy version conflicts
**Solution:**
```powershell
pip uninstall sqlalchemy
pip install sqlalchemy[asyncio]==2.0.23
```

### Issue: PyJWT version mismatch
**Solution:**
```powershell
pip uninstall PyJWT
pip install PyJWT==2.8.0
```
