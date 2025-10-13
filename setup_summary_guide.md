# Vehicle Inspection Center System - Complete Setup Guide

## 📋 Project Overview

This is a **production-ready microservices architecture** for a vehicle inspection center management system built with:
- **Frontend**: HTML/CSS/JavaScript + Nginx
- **Backend**: FastAPI (Python) microservices
- **Database**: PostgreSQL (1 per service)
- **Containerization**: Docker & Docker Compose
- **Authentication**: JWT tokens
- **Communication**: REST APIs over HTTP

---

## 📦 Complete File Structure

Create this folder structure in your project:

```
vehicle-inspection-system/
├── .env                           # Environment variables (DO NOT COMMIT)
├── .env.example                   # Example env file (commit this)
├── .gitignore
├── docker-compose.yml
├── nginx.conf
├── init-databases.sql
├── README.md
├── SETUP_GUIDE.md
├── WARNINGS.txt
│
├── frontend/
│   ├── index.html                 # Single HTML file with all content
│   ├── css/
│   │   └── style.css              # (Already in index.html as <style>)
│   └── js/
│       └── api.js                 # (Already in index.html as <script>)
│
└── backend/
    ├── auth-service/
    │   ├── main.py
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── config.py
    │
    ├── appointment-service/
    │   ├── main.py
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── config.py
    │
    ├── payment-service/
    │   ├── main.py
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── config.py
    │
    ├── inspection-service/
    │   ├── main.py
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── config.py
    │
    └── logging-service/
        ├── main.py
        ├── Dockerfile
        ├── requirements.txt
        └── config.py
```

---

## 🚀 Step-by-Step Setup

### Step 1: Prerequisites Installation

**macOS:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker
brew install docker docker-compose

# Install Python
brew install python@3.11

# Verify installation
docker --version
docker-compose --version
python3 --version
```

**Windows:**
1. Download Docker Desktop: https://www.docker.com/products/docker-desktop
2. Download Python: https://www.python.org/downloads/
3. Install both with default settings
4. Restart your computer

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io docker-compose -y

# Install Python
sudo apt install python3.11 python3-pip -y

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker-compose --version
```

### Step 2: Create Project Directories

```bash
# Create main project directory
mkdir -p vehicle-inspection-system
cd vehicle-inspection-system

# Create all backend service directories
mkdir -p backend/{auth-service,appointment-service,payment-service,inspection-service,logging-service}

# Create frontend directory
mkdir -p frontend/{css,js}
```

### Step 3: Create Configuration Files

Create `.env.example`:
```env
# JWT Configuration
JWT_SECRET_KEY=your-super-secret-key-32-chars-minimum
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=your-secure-password-20-chars-minimum

# Database names
DB_NAME_AUTH=auth_db
DB_NAME_APPOINTMENTS=appointments_db
DB_NAME_PAYMENTS=payments_db
DB_NAME_INSPECTIONS=inspections_db
DB_NAME_LOGS=logs_db

# Ports
AUTH_SERVICE_PORT=8001
APPOINTMENT_SERVICE_PORT=8002
PAYMENT_SERVICE_PORT=8003
INSPECTION_SERVICE_PORT=8004
LOGGING_SERVICE_PORT=8005
UI_SERVICE_PORT=3000

# URLs
FRONTEND_URL=http://localhost:3000
LOGGING_SERVICE_URL=http://logging-service:8005
PAYMENT_SERVICE_URL=http://payment-service:8003
APPOINTMENT_SERVICE_URL=http://appointment-service:8002
```

Create `.env` by copying `.env.example` and updating with secure values:
```bash
cp .env.example .env

# Generate secure values
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_urlsafe(32))"
python3 -c "import secrets; print('DB_PASSWORD=' + secrets.token_urlsafe(20))"
```

### Step 4: Create Backend Service Files

For each service (auth, appointment, payment, inspection, logging):

1. **Copy main.py** from the artifacts (each service has its own main.py)
2. **Create Dockerfile** (same for all):
   ```dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   RUN apt-get update && apt-get install -y gcc curl && rm -rf /var/lib/apt/lists/*
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . .
   EXPOSE 8000
   HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
       CMD curl -f http://localhost:8000/health || exit 1
   CMD ["python", "main.py"]
   ```

3. **Create requirements.txt** (same for all):
   ```
   fastapi==0.104.1
   uvicorn[standard]==0.24.0
   asyncpg==0.29.0
   pydantic==2.5.0
   pydantic[email]==2.5.0
   python-jose[cryptography]==3.3.0
   bcrypt==4.1.1
   PyJWT==2.8.1
   tenacity==8.2.3
   httpx==0.25.2
   python-dotenv==1.0.0
   psycopg2-binary==2.9.9
   ```

### Step 5: Create Frontend

Create `frontend/index.html` with the complete HTML/CSS/JS code from the frontend artifact.

### Step 6: Create Docker Configuration

Create `docker-compose.yml` from the artifact (complete configuration provided).

Create `nginx.conf` from the artifact (server configuration provided).

Create `init-databases.sql` from the artifact (database initialization).

### Step 7: Build and Run

```bash
# Navigate to project root
cd vehicle-inspection-system

# Build all services
docker-compose build

# Start all services
docker-compose up -d

# Wait for initialization
sleep 30

# Verify all services are running
docker-compose ps

# Check logs if there are issues
docker-compose logs
```

### Step 8: Test the System

1. **Open Frontend**: http://localhost:3000
2. **Create Test Account**: 
   - Email: test@example.com
   - Password: testpassword123
   - Role: Customer
3. **Login**: Use the credentials above
4. **Book Appointment**: Fill in vehicle details
5. **Check Admin Dashboard**: Log in as admin to view logs

---

## 🔐 Security Hardening

### 1. Change Default Credentials

```bash
# Generate new JWT secret
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Generate new DB password  
python3 -c "import secrets; print(secrets.token_urlsafe(20))"

# Update .env with new values
sed -i 's/your-super-secret-key-32-chars-minimum/YOUR_NEW_SECRET/' .env
sed -i 's/your-secure-password-20-chars-minimum/YOUR_NEW_PASSWORD/' .env
```

### 2. Enable HTTPS in Production

Update `nginx.conf`:
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name _;
    return 301 https://$server_name$request_uri;
}
```

### 3. Implement Rate Limiting

Add to `nginx.conf`:
```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;
limit_req_zone $binary_remote_addr zone=login_limit:10m rate=5r/m;

server {
    location /login { limit_req zone=login_limit burst=10 nodelay; }
    location /api/ { limit_req zone=api_limit burst=50 nodelay; }
}
```

### 4. Add Input Validation

Already implemented in all services using Pydantic validators.

### 5. Database Security

```bash
# Change database password
docker exec vehicle-inspection-postgres psql -U admin -c \
  "ALTER USER admin WITH PASSWORD 'new_secure_password';"

# Enable SSL for database connections
# Update connection strings in services to use ?sslmode=require
```

---

## 🧪 Testing the Application

### Manual Testing

1. **Register New User**:
   ```bash
   curl -X POST http://localhost:8001/register \
     -H "Content-Type: application/json" \
     -d '{"email":"user@test.com","password":"pass123","role":"customer"}'
   ```

2. **Login**:
   ```bash
   curl -X POST http://localhost:8001/login \
     -H "Content-Type: application/json" \
     -d '{"email":"user@test.com","password":"pass123"}'
   ```

3. **Create Appointment** (replace TOKEN):
   ```bash
   curl -X POST http://localhost:8002/appointments \
     -H "Authorization: Bearer TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"vehicle_type":"car","vehicle_registration":"AB-123-CD","vehicle_brand":"Toyota","vehicle_model":"Corolla"}'
   ```

### Load Testing

```bash
# Using Apache Bench (ab)
ab -n 1000 -c 100 http://localhost:3000

# Using wrk
wrk -t12 -c400 -d30s http://localhost:3000
```

---

## 📊 Monitoring & Logging

### View Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f auth-service

# Last 100 lines
docker-compose logs --tail=100
```

### Database Monitoring

```bash
# Connect to database
docker exec -it vehicle-inspection-postgres psql -U admin

# Check tables
\dt  # List all tables
\d appointments  # Describe table

# Query logs
SELECT * FROM logs ORDER BY timestamp DESC LIMIT 10;

# Check slow queries
SELECT * FROM logs WHERE level = 'ERROR' LIMIT 20;
```

### Service Health

```bash
# Check all services health
for port in 8001 8002 8003 8004 8005; do
  echo "Port $port: $(curl -s http://localhost:$port/health | jq '.status')"
done
```

---

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check logs
docker-compose logs

# Rebuild images
docker-compose build --no-cache

# Restart everything
docker-compose down -v
docker-compose up -d
```

### Database Connection Issues

```bash
# Wait longer for database
sleep 60

# Restart database
docker-compose restart postgres

# Verify database exists
docker exec vehicle-inspection-postgres psql -U admin -l | grep _db
```

### Port Already in Use

```bash
# Kill process on port
lsof -i :8001  # Find process
kill -9 <PID>

# Or change port in .env
APPOINTMENT_SERVICE_PORT=8012
```

### CORS Errors

CORS is already configured in all services. If still getting errors:

1. Check FRONTEND_URL in .env
2. Clear browser cache
3. Check browser console for exact error

---

## 📈 Performance Optimization

### Database Optimization

```sql
-- Add missing indexes
CREATE INDEX idx_user_id_status ON appointments(user_id, status);
CREATE INDEX idx_appointment_timestamp ON appointments(created_at DESC);

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM appointments WHERE user_id = 'uuid';
```

### API Caching

Add Redis:
```python
import redis

redis_client = redis.Redis(host='redis', port=6379)

@app.get("/cached-endpoint")
def get_cached(request_id: str):
    cached = redis_client.get(request_id)
    if cached:
        return json.loads(cached)
    # ... fetch and cache
```

### Connection Pooling

Already optimized in services with:
- Min connections: 5
- Max connections: 20
- Adjust if needed for high traffic

---

## 🚢 Deployment to Production

### Using Docker Swarm

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml inspection-system

# Scale services
docker service scale inspection-system_auth-service=3
```

### Using Kubernetes

```bash
# Create namespace
kubectl create namespace inspection-system

# Create secrets
kubectl create secret generic db-secret \
  --from-literal=password=YOUR_DB_PASSWORD \
  -n inspection-system

# Deploy services (create deployment.yaml and service.yaml)
kubectl apply -f deployment.yaml -n inspection-system
```

### Using AWS ECS

```bash
# Create task definition
aws ecs register-task-definition --cli-input-json file://task-def.json

# Create cluster
aws ecs create-cluster --cluster-name inspection-system

# Run tasks
aws ecs run-task --cluster inspection-system \
  --task-definition auth-service:1
```

---

## 💾 Backup & Recovery

### Automated Backups

Create `backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/backups"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

for db in auth_db appointments_db payments_db inspections_db logs_db; do
  docker exec vehicle-inspection-postgres pg_dump -U admin -d $db | \
    gzip > $BACKUP_DIR/${db}_${TIMESTAMP}.sql.gz
done

# Upload to cloud (AWS S3, Google Cloud, etc.)
# aws s3 sync $BACKUP_DIR s3://my-backup-bucket/
```

Schedule with crontab:
```bash
0 2 * * * /path/to/backup.sh  # Daily at 2 AM
```

### Restore from Backup

```bash
# Extract backup
gunzip backup_auth_db_20251012_020000.sql.gz

# Restore database
docker exec -i vehicle-inspection-postgres psql -U admin -d auth_db < \
  backup_auth_db_20251012_020000.sql
```

---

## ✅ Deployment Checklist

Before going live:

- [ ] Change JWT_SECRET_KEY
- [ ] Change DB_PASSWORD
- [ ] Enable HTTPS/SSL
- [ ] Configure firewall
- [ ] Set up backup strategy
- [ ] Configure monitoring
- [ ] Set up alerting
- [ ] Test disaster recovery
- [ ] Document deployment
- [ ] Create runbooks
- [ ] Get security review
- [ ] Load test system
- [ ] Plan scaling strategy

---

## 📞 Support

If you encounter issues:

1. **Check WARNINGS.txt** for common problems
2. **Review logs**: `docker-compose logs`
3. **Verify health**: `curl http://localhost:{port}/health`
4. **Check connectivity**: `docker network ls`
5. **Review documentation**: README.md, SETUP_GUIDE.md

---

**Version**: 1.0.0  
**Last Updated**: October 2025  
**Status**: Production Ready