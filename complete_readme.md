# Vehicle Inspection Center Management System

A complete **microservices-based full-stack application** for managing vehicle inspection centers. Built with FastAPI, PostgreSQL, React, and Docker.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Common Issues](#common-issues)
- [Deployment](#deployment)

---

## ✨ Features

### Core Functionality
- 🔐 **Authentication** - User registration, login, JWT tokens
- 📅 **Appointment Management** - Book, view, and manage appointments
- 💳 **Payment Processing** - Secure payment handling
- 🔍 **Vehicle Inspection** - Detailed inspection results
- 📊 **Admin Dashboard** - Logs and system monitoring
- 🏥 **Health Checks** - Service status monitoring

### Technical Features
- **Microservices Architecture** - Independent, scalable services
- **Database per Service** - PostgreSQL databases
- **REST APIs** - Clean API design with JSON
- **JWT Authentication** - Token-based security
- **Docker Containerization** - Easy deployment and scaling
- **Centralized Logging** - All events logged to Logging Service

---

## 🏗️ Architecture

### System Diagram

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
┌──────▼──────────────────────────────────────────┐
│         Frontend (HTML/CSS/JS)                    │
│         Port: 3000 (Nginx)                        │
└──────┬──────────────────────────────────────────┘
       │
┌──────▼──────────────────────────────────────────────┐
│              API Gateway / Router                    │
└──────┬───────────────────────────────────────────────┘
       │
  ┌────┴──────────────────────────────────┐
  │                                        │
  │    Microservices Layer                │
  │    ├── Auth Service (8001)             │
  │    ├── Appointment Service (8002)      │
  │    ├── Payment Service (8003)          │
  │    ├── Inspection Service (8004)       │
  │    └── Logging Service (8005)          │
  │                                        │
  │    Database Layer                      │
  │    └── PostgreSQL (5432)               │
  │        ├── auth_db                     │
  │        ├── appointments_db             │
  │        ├── payments_db                 │
  │        ├── inspections_db              │
  │        └── logs_db                     │
  │                                        │
  └────────────────────────────────────────┘
```

---

## 📦 Prerequisites

- **Docker** & **Docker Compose** (latest version)
  - Download: https://www.docker.com/products/docker-desktop
  
- **Python 3.9+** (for local development without Docker)
  - Download: https://www.python.org/downloads/

- **Git** (for version control)
  - Download: https://git-scm.com/

- **System Requirements**:
  - 4GB RAM minimum
  - 10GB free disk space
  - Linux, macOS, or Windows with WSL2

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd vehicle-inspection-system
```

### 2. Setup Environment Variables

```bash
# Copy example .env file
cp .env.example .env

# Edit .env with your values
nano .env  # macOS/Linux
# or
notepad .env  # Windows
```

**Important**: Change these values:
```env
JWT_SECRET_KEY=your-new-secret-key-32-chars-minimum
DB_PASSWORD=your-new-secure-password-20-chars-minimum
```

Generate secure keys:
```bash
# Generate JWT secret
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Generate DB password
python3 -c "import secrets; print(secrets.token_urlsafe(20))"
```

### 3. Build & Start Services

```bash
# Build Docker images
docker-compose build

# Start all services (in background)
docker-compose up -d

# Wait 30 seconds for services to initialize
sleep 30

# Verify all services are running
docker-compose ps
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Auth Service API**: http://localhost:8001/docs
- **Appointment API**: http://localhost:8002/docs
- **Payment API**: http://localhost:8003/docs
- **Inspection API**: http://localhost:8004/docs
- **Logging API**: http://localhost:8005/docs

### 5. Test Login

**Customer Account:**
- Email: customer@example.com
- Password: customer123

**Technician Account:**
- Email: technician@example.com
- Password: technician123

**Admin Account:**
- Email: admin@example.com
- Password: admin123

---

## 📁 Project Structure

```
vehicle-inspection-system/
│
├── frontend/
│   ├── index.html              # Main application
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── api.js
│
├── backend/
│   ├── auth-service/
│   │   ├── main.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── appointment-service/
│   │   ├── main.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── payment-service/
│   │   ├── main.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   ├── inspection-service/
│   │   ├── main.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   └── logging-service/
│       ├── main.py
│       ├── Dockerfile
│       └── requirements.txt
│
├── docker-compose.yml
├── nginx.conf
├── init-databases.sql
├── .env.example
├── .env                        # ⚠️ Do NOT commit to git
├── WARNINGS.txt
└── README.md
```

---

## 🔗 API Documentation

### Authentication Service (Port 8001)

#### Register User
```bash
POST /register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123",
  "role": "customer"
}
```

#### Login
```bash
POST /login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123"
}

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "customer"
  }
}
```

### Appointment Service (Port 8002)

#### Create Appointment
```bash
POST /appointments
Authorization: Bearer {token}
Content-Type: application/json

{
  "vehicle_type": "car",
  "vehicle_registration": "AB-123-CD",
  "vehicle_brand": "Toyota",
  "vehicle_model": "Corolla"
}
```

#### Get User Appointments
```bash
GET /appointments/{user_id}?skip=0&limit=10
Authorization: Bearer {token}
```

---

## ⚠️ Common Issues & Solutions

### 1. "Address already in use" Error

**Problem**: Port is already occupied

**Solution**:
```bash
# Find which process is using the port
lsof -i :8001  # macOS/Linux

# Kill the process
kill -9 <PID>

# Or change the port in .env
APPOINTMENT_SERVICE_PORT=8012
```

### 2. "Connection refused" Error

**Problem**: Services can't connect to each other or database

**Solution**:
```bash
# Restart all services
docker-compose restart

# Wait 30 seconds
sleep 30

# Check logs
docker-compose logs postgres
```

### 3. "Invalid token" Error

**Problem**: JWT token is expired or invalid

**Solution**:
- Logout and login again
- Check if JWT_SECRET_KEY is the same across all services
- Verify token expiration time: JWT_EXPIRATION_HOURS=24

### 4. Database Connection Failed

**Problem**: Can't connect to PostgreSQL

**Solution**:
```bash
# Check if postgres container is running
docker-compose ps postgres

# Check postgres logs
docker-compose logs postgres

# Rebuild and restart postgres
docker-compose down -v
docker-compose up -d postgres
sleep 15
docker-compose up -d
```

### 5. CORS Errors

**Problem**: Frontend can't call backend APIs

**Solution**:
- CORS is already enabled in all services
- Verify FRONTEND_URL in .env matches your frontend URL
- Clear browser cache and cookies

### 6. Services Keep Restarting

**Problem**: Services crash immediately after starting

**Solution**:
```bash
# Check service logs
docker-compose logs auth-service

# Common causes:
# - Database not ready (wait 30+ seconds)
# - Missing environment variables in .env
# - Port already in use
# - Corrupted Docker image (rebuild)

docker-compose build --no-cache
docker-compose up -d
```

---

## 🐳 Docker Commands

### Basic Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View running services
docker-compose ps

# View service logs
docker-compose logs auth-service

# View real-time logs (all services)
docker-compose logs -f

# Restart a service
docker-compose restart auth-service

# Rebuild images
docker-compose build

# Complete reset (removes volumes)
docker-compose down -v
```

### Scaling Services

```bash
# Scale a service to 3 instances
docker-compose up -d --scale appointment-service=3

# Note: Use different port mappings for each instance
# Or use Kubernetes for better orchestration
```

### Database Management

```bash
# Connect to PostgreSQL
docker exec -it vehicle-inspection-postgres psql -U admin -d auth_db

# Backup database
docker exec vehicle-inspection-postgres pg_dump -U admin auth_db | \
  gzip > backup_auth_db.sql.gz

# Restore database
gunzip -c backup_auth_db.sql.gz | \
  docker exec -i vehicle-inspection-postgres psql -U admin -d auth_db
```

---

## 🚀 Deployment

### Development Deployment (Current)

```bash
docker-compose up -d
# Access: http://localhost:3000
```

### Production Deployment

#### 1. Generate Secure Secrets

```bash
# JWT Secret (32+ characters)
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Database Password (20+ characters)
python3 -c "import secrets; print(secrets.token_urlsafe(20))"
```

#### 2. Enable HTTPS

Update `nginx.conf`:
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    return 301 https://$server_name$request_uri;
}
```

#### 3. Use Environment Variable Management

```bash
# AWS Secrets Manager
aws secretsmanager create-secret --name db-password \
  --secret-string "your-secure-password"

# Or use HashiCorp Vault
vault kv put secret/db password="your-secure-password"
```

#### 4. Set up Monitoring

```bash
# Add Prometheus
docker run -d --name prometheus \
  -v prometheus.yml:/etc/prometheus/prometheus.yml \
  -p 9090:9090 \
  prom/prometheus

# Add Grafana
docker run -d --name grafana \
  -p 3000:3000 \
  grafana/grafana
```

#### 5. Configure Backups

```bash
# Daily backup script (backup.sh)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"

for db in auth_db appointments_db payments_db inspections_db logs_db; do
  docker exec vehicle-inspection-postgres pg_dump -U admin -d $db | \
    gzip > $BACKUP_DIR/${db}_${DATE}.sql.gz
done

# Upload to S3
aws s3 sync $BACKUP_DIR s3://my-bucket/backups/
```

Schedule with crontab:
```bash
0 2 * * * /path/to/backup.sh
```

---

## 📊 Performance Tips

### 1. Database Optimization

```sql
-- Add indexes for frequently queried fields
CREATE INDEX idx_user_appointments ON appointments(user_id, created_at DESC);
CREATE INDEX idx_appointment_status ON appointments(status, created_at DESC);

-- Analyze query plans
EXPLAIN ANALYZE SELECT * FROM appointments WHERE user_id = 'uuid';
```

### 2. Connection Pooling

Services already use connection pooling with:
- Min connections: 5
- Max connections: 20

Adjust in service code if needed.

### 3. Caching

Add Redis for caching:
```python
import redis

cache = redis.Redis(host='localhost', port=6379)
cache.set('user:uuid', json.dumps(user_data), ex=3600)
```

### 4. API Rate Limiting

Add to Nginx:
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location /api/ {
    limit_req zone=api burst=20 nodelay;
}
```

---

## 🔒 Security Checklist

Before deploying to production:

- [ ] Change JWT_SECRET_KEY
- [ ] Change DB_PASSWORD
- [ ] Enable HTTPS/SSL
- [ ] Set up firewall rules
- [ ] Enable database encryption
- [ ] Configure backup strategy
- [ ] Set up monitoring and alerts
- [ ] Enable audit logging
- [ ] Use secrets management (Vault, AWS Secrets)
- [ ] Regular security updates
- [ ] Implement rate limiting
- [ ] Enable input validation
- [ ] Set up WAF (Web Application Firewall)

---

## 📞 Support & Troubleshooting

### Getting Help

1. **Check Logs**:
   ```bash
   docker-compose logs service-name
   ```

2. **Health Check**:
   ```bash
   curl http://localhost:8001/health
   ```

3. **Database Connection**:
   ```bash
   docker exec vehicle-inspection-postgres psql -U admin -c "SELECT 1;"
   ```

4. **View Recent Errors**:
   - Admin Dashboard → Recent Logs

### Useful Resources

- FastAPI Docs: https://fastapi.tiangolo.com
- PostgreSQL Docs: https://www.postgresql.org/docs
- Docker Docs: https://docs.docker.com
- JWT Guide: https://jwt.io

---

## 📝 License

This project is provided for educational purposes.

---

## 👨‍💻 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

**Last Updated**: October 2025  
**Version**: 1.0.0  
**Status**: Production Ready