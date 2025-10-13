| Service | URL | Documentation |
|---------|-----|---------------|
| Frontend | http://localhost:3000 | Main application |
| Auth API | http://localhost:8001 | http://localhost:8001/docs |
| Appointment API | http://localhost:8002 | http://localhost:8002/docs |
| Payment API | http://localhost:8003 | http://localhost:8003/docs |
| Inspection API | http://localhost:8004 | http://localhost:8004/docs |
| Logging API | http://localhost:8005 | http://localhost:8005/docs |
| Database | localhost:5432 | PostgreSQL |

---

## ⚡ Essential Docker Commands

### Startup & Shutdown
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart all services
docker-compose restart

# Complete reset (removes volumes)
docker-compose down -v
docker-compose up -d
```

### Monitoring & Logs
```bash
# View all services status
docker-compose ps

# View all logs
docker-compose logs -f

# View specific service logs (last 100 lines)
docker-compose logs --tail=100 auth-service

# View only errors
docker-compose logs | grep -i error
```

### Container Management
```bash
# Restart single service
docker-compose restart auth-service

# Rebuild specific service
docker-compose up -d --build auth-service

# Execute command in container
docker exec vehicle-inspection-postgres psql -U admin

# View container resource usage
docker stats
```

### Database Operations
```bash
# Connect to PostgreSQL
docker exec -it vehicle-inspection-postgres psql -U admin

# List all databases
docker exec vehicle-inspection-postgres psql -U admin -l

# Backup all databases
docker exec vehicle-inspection-postgres pg_dumpall -U admin | \
  gzip > backup_all_$(date +%Y%m%d).sql.gz

# Restore database
gunzip -c backup.sql.gz | \
  docker exec -i vehicle-inspection-postgres psql -U admin
```

### Cleanup
```bash
# Remove unused containers
docker container prune -f

# Remove unused images
docker image prune -f

# Remove unused volumes
docker volume prune -f

# Remove all unused Docker objects
docker system prune -a -f
```

---

## 🧪 API Testing Commands

### Registration
```bash
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepass123",
    "role": "customer"
  }'
```

### Login
```bash
curl -X POST http://localhost:8001/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@example.com",
    "password": "customer123"
  }'
```

### Create Appointment
```bash
TOKEN="your_jwt_token_here"

curl -X POST http://localhost:8002/appointments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_type": "car",
    "vehicle_registration": "AB-123-CD",
    "vehicle_brand": "Toyota",
    "vehicle_model": "Corolla"
  }'
```

### Get User Appointments
```bash
curl -X GET http://localhost:8002/appointments/USER_ID \
  -H "Authorization: Bearer $TOKEN"
```

### Submit Inspection
```bash
curl -X POST http://localhost:8004/inspections/submit \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_id": "uuid",
    "results": {
      "brakes": "PASS",
      "lights": "PASS",
      "tires": "PASS",
      "emissions": "PASS"
    },
    "final_status": "PASS",
    "notes": "Vehicle in good condition"
  }'
```

### Get Logs (Admin Only)
```bash
curl -X GET http://localhost:8005/log/all \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 📁 Important Files & Their Purpose

| File | Purpose | Edit? |
|------|---------|-------|
| `.env` | Environment variables | ✅ Yes (locally) |
| `.env.example` | Example env file | ❌ No |
| `docker-compose.yml` | Service configuration | ✅ If scaling |
| `nginx.conf` | Reverse proxy config | ✅ For production |
| `init-databases.sql` | Database initialization | ❌ No |
| `WARNINGS.txt` | Important warnings | ✅ Read carefully |
| `backend/*/main.py` | Service code | ✅ For customization |
| `frontend/index.html` | UI application | ✅ For customization |

---

## 🔧 Configuration Quick Links

### Change Service Port
Edit `.env`:
```env
APPOINTMENT_SERVICE_PORT=8012  # Changed from 8002
```

### Change Database Password
```bash
# In .env
DB_PASSWORD=your_new_secure_password

# Then restart
docker-compose down -v
docker-compose up -d
```

### Change JWT Expiration
```env
JWT_EXPIRATION_HOURS=48  # Changed from 24
```

### Enable HTTPS
Edit `nginx.conf`:
```nginx
listen 443 ssl http2;
ssl_certificate /path/to/cert.pem;
ssl_certificate_key /path/to/key.pem;
```

---

## 🚨 Emergency Procedures

### Service Down
```bash
# Check status
docker-compose ps

# View error logs
docker-compose logs service-name

# Restart service
docker-compose restart service-name

# Rebuild and restart
docker-compose up -d --build service-name
```

### Database Corruption
```bash
# Backup current data
docker exec vehicle-inspection-postgres pg_dump -U admin > backup.sql

# Restore from known good backup
gunzip -c backup_2025_10_12.sql.gz | \
  docker exec -i vehicle-inspection-postgres psql -U admin
```

### All Services Down
```bash
# Check Docker daemon
docker ps

# Restart Docker
sudo systemctl restart docker  # Linux
# Or restart Docker Desktop (macOS/Windows)

# Restart all services
docker-compose down
docker-compose up -d

# Wait and verify
sleep 30
docker-compose ps
```

### High Memory Usage
```bash
# Check resource usage
docker stats

# Limit container memory in docker-compose.yml
services:
  auth-service:
    mem_limit: 512m
    mem_reservation: 256m
```

---

## 📊 Performance Monitoring

### Check Service Response Times
```bash
# Using curl with timing
curl -w "\nTime: %{time_total}s\n" http://localhost:8001/health

# Using Apache Bench
ab -n 100 -c 10 http://localhost:3000/
```

### Database Query Performance
```bash
# Connect to database
docker exec -it vehicle-inspection-postgres psql -U admin -d auth_db

# Check slow queries
SELECT query, mean_time, calls FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

# Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Monitor Docker Resource Usage
```bash
# Real-time monitoring
docker stats --no-stream

# Historical data
docker events --since 1h

# Container resource limits
docker inspect container_name | grep -A 10 "MemoryStats"
```

---

## 🔐 Security Quick Tips

### ⚠️ CRITICAL - Before Production

1. **Generate Secure Secrets**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
python3 -c "import secrets; print(secrets.token_urlsafe(20))"
```

2. **Update .env**
```env
JWT_SECRET_KEY=<generated_secret>
DB_PASSWORD=<generated_password>
```

3. **Enable HTTPS**
- Get SSL certificate (Let's Encrypt, AWS, etc.)
- Update nginx.conf
- Redirect HTTP to HTTPS

4. **Change Default Passwords**
```sql
ALTER USER admin WITH PASSWORD 'new_password';
```

5. **Enable Firewall**
```bash
# Open only necessary ports
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 5432/tcp  # Only from app servers
```

### Regular Security Checks

```bash
# Check for exposed secrets
grep -r "password\|token\|secret" .env* --exclude=.env.example

# Verify HTTPS is enabled
curl -I https://your-domain.com

# Test API authentication
curl -I http://localhost:8002/appointments  # Should be 401

# Monitor failed logins
docker-compose logs | grep "login.failed"
```

---

## 📚 Documentation Files

| File | Contains |
|------|----------|
| `README.md` | Project overview, features, architecture |
| `SETUP_GUIDE.md` | Complete installation instructions |
| `WARNINGS.txt` | Critical issues and solutions |
| `QUICK_REFERENCE.md` | This file - commands and quick links |

---

## 🆘 Getting Help

### Step 1: Check Documentation
- Read `WARNINGS.txt` for common issues
- Review `README.md` for overview
- Check `SETUP_GUIDE.md` for setup issues

### Step 2: Check Logs
```bash
# All logs
docker-compose logs | head -100

# Service-specific
docker-compose logs auth-service

# Errors only
docker-compose logs | grep -i error
```

### Step 3: Verify Configuration
```bash
# Check .env is loaded
docker-compose config | grep -A 20 auth-service

# Verify database connection
docker exec vehicle-inspection-postgres psql -U admin -c "SELECT 1;"

# Test API endpoints
curl http://localhost:8001/health
```

### Step 4: Restart Services
```bash
# Restart everything
docker-compose restart

# Wait for initialization
sleep 30

# Verify status
docker-compose ps
```

---

## 💡 Tips & Tricks

### Speed Up Build
```bash
# Build without cache
docker-compose build --no-cache

# Build specific service only
docker-compose build auth-service
```

### Skip Database Initialization
```bash
# Use existing volumes
# Set in docker-compose.yml
volumes:
  postgres_data:
    external: true
```

### Override Environment Variables
```bash
# Temporarily override
export JWT_EXPIRATION_HOURS=48
docker-compose up -d

# Or inline
JWT_EXPIRATION_HOURS=48 docker-compose up -d
```

### Access PostgreSQL CLI
```bash
# Interactive
docker exec -it vehicle-inspection-postgres psql -U admin

# Single command
docker exec vehicle-inspection-postgres psql -U admin -c "SELECT version();"
```

### View Network Connections
```bash
# List networks
docker network ls

# Inspect network
docker network inspect inspection-network

# Test connectivity between containers
docker exec auth-service ping logging-service
```

### Clean Development Environment
```bash
# Remove everything
docker-compose down -v

# Delete all local images
docker rmi $(docker images -q)

# Start fresh
docker-compose build --no-cache
docker-compose up -d
```

---

## 📞 Useful Links

| Resource | URL |
|----------|-----|
| FastAPI Docs | https://fastapi.tiangolo.com |
| PostgreSQL Docs | https://www.postgresql.org/docs |
| Docker Docs | https://docs.docker.com |
| JWT Guide | https://jwt.io |
| Nginx Docs | https://nginx.org/en/docs |
| Python Docs | https://docs.python.org/3 |

---

## 🎯 Common Workflows

### Adding New API Endpoint

1. Add function to `backend/service-name/main.py`
2. Add Pydantic model for request/response
3. Add JWT verification if needed
4. Add logging
5. Rebuild: `docker-compose up -d --build service-name`

### Debugging Slow Queries

```sql
-- Enable query logging
SET log_min_duration_statement = 1000;  -- 1 second

-- View slow queries
SELECT query, calls, mean_time FROM pg_stat_statements 
WHERE mean_time > 1000 ORDER BY mean_time DESC;
```

### Scaling for High Load

1. Add replicas in docker-compose.yml
2. Use load balancer (Nginx, HAProxy)
3. Enable connection pooling
4. Add Redis caching
5. Optimize database queries

### Rolling Updates

```bash
# Update auth-service without downtime
docker-compose up -d --no-deps --build auth-service

# Verify
docker-compose ps
docker-compose logs auth-service
```

---

**Last Updated**: October 2025  
**Version**: 1.0.0  
**Quick Reference**: For production use, always check WARNINGS.txt and SETUP_GUIDE.md# Quick Reference Guide - Vehicle Inspection System

## 🔓 Test Credentials

### Customer Account
```
Email: customer@example.com
Password: customer123
Role: customer
```

### Technician Account
```
Email: technician@example.com
Password: technician123
Role: technician
```

### Admin Account
```
Email: admin@example.com
Password: admin123
Role: admin
```

**Note**: Create these accounts manually or add to initial data seed.

---

## 🌐 URLs & Ports

| Service | URL | Documentation |
|---------|-----|---------------|
| Frontend | http://localhost:3000 | Main application |
| Auth API | http://localhost:8001 | http://localhost:8001/docs |
| Appointment API | http://localhost:8002 | http://localhost:8002/docs |
| Payment API | http://localhost:8003 | http://localhost:8003/docs |
| Inspection API | http://localhost:8004 |