# Vehicle Inspection Center Management System
## Full Stack Microservices Application

---

## TABLE OF CONTENTS
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Setup & Installation](#setup--installation)
4. [Running the Application](#running-the-application)
5. [API Documentation](#api-documentation)
6. [Common Issues & Solutions](#common-issues--solutions)
7. [Security Considerations](#security-considerations)

---

## ARCHITECTURE OVERVIEW

### High-Level Design (HLD)

The system follows a **microservices architecture** with the following components:

```
User
  ↓
[Frontend - UI Service (Port 3000)]
  ↓
[API Gateway / Main Orchestrator]
  ├─ Authorization Service (Port 8001)
  ├─ Appointment Service (Port 8002)
  ├─ Payment Service (Port 8003)
  ├─ Inspection Service (Port 8004)
  └─ Logging Service (Port 8005)
```

### Key Principles

- **Database per Service**: Each microservice has its own PostgreSQL database
- **JWT Authentication**: Token-based auth with role-based access control
- **Asynchronous Communication**: Services communicate via REST APIs
- **Centralized Logging**: All services log to the Logging Service
- **Fault Tolerance**: Services can fail independently without bringing down the system

---

## PROJECT STRUCTURE

```
vehicle-inspection-system/
│
├── frontend/
│   ├── index.html
│   ├── login.html
│   ├── register.html
│   ├── customer-dashboard.html
│   ├── technician-dashboard.html
│   ├── admin-dashboard.html
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── api.js
│
├── backend/
│   ├── auth-service/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── config.py
│   │
│   ├── appointment-service/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── config.py
│   │
│   ├── payment-service/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── config.py
│   │
│   ├── inspection-service/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── config.py
│   │
│   └── logging-service/
│       ├── main.py
│       ├── requirements.txt
│       ├── Dockerfile
│       └── config.py
│
├── docker-compose.yml
├── .env
├── WARNINGS.txt
└── README.md
```

---

## SETUP & INSTALLATION

### Prerequisites

- Docker & Docker Compose (latest version)
- Python 3.9+ (for local development)
- PostgreSQL 14+ (if running services locally)
- Node.js 16+ (optional, for frontend improvements)

### Environment Setup

Create a `.env` file in the root directory:

```env
# JWT Configuration
JWT_SECRET_KEY=your-super-secret-key-change-this-in-production
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=secure_password_change_this
DB_NAME_AUTH=auth_db
DB_NAME_APPOINTMENTS=appointments_db
DB_NAME_PAYMENTS=payments_db
DB_NAME_INSPECTIONS=inspections_db
DB_NAME_LOGS=logs_db

# Service Ports
AUTH_SERVICE_PORT=8001
APPOINTMENT_SERVICE_PORT=8002
PAYMENT_SERVICE_PORT=8003
INSPECTION_SERVICE_PORT=8004
LOGGING_SERVICE_PORT=8005
UI_SERVICE_PORT=3000

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

---

## RUNNING THE APPLICATION

### Using Docker Compose (Recommended)

```bash
# Build all services
docker-compose build

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Clean up volumes
docker-compose down -v
```

### Local Development (without Docker)

```bash
# 1. Install dependencies for each service
cd backend/auth-service
pip install -r requirements.txt

# 2. Set up databases
createdb auth_db
createdb appointments_db
createdb payments_db
createdb inspections_db
createdb logs_db

# 3. Run each service in separate terminals
python main.py  # From each service directory

# 4. Serve frontend (in another terminal)
cd frontend
python -m http.server 3000
```

---

## API DOCUMENTATION

### Authentication Service (Port 8001)

#### POST /register
Create a new account

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "role": "customer"
}
```

**Response:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "role": "customer",
  "created_at": "2025-10-12T10:00:00Z"
}
```

#### POST /login
Authenticate user and get JWT token

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response:**
```json
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

#### POST /verify
Verify email (optional feature)

**Request:**
```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

### Appointment Service (Port 8002)

#### POST /appointments
Create new appointment

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "vehicle_type": "car",
  "vehicle_registration": "AB-123-CD",
  "vehicle_brand": "Toyota",
  "vehicle_model": "Corolla"
}
```

#### GET /appointments/{user_id}
Get user's appointments

**Headers:** `Authorization: Bearer {token}`

#### PUT /appointments/{id}/confirm
Confirm appointment after payment

**Headers:** `Authorization: Bearer {token}`

#### DELETE /appointments/{id}
Cancel appointment

**Headers:** `Authorization: Bearer {token}`

### Payment Service (Port 8003)

#### POST /payment
Initiate payment

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "appointment_id": "uuid",
  "amount": 49.99
}
```

#### POST /payment/confirm
Confirm payment (callback from payment gateway)

**Request:**
```json
{
  "payment_id": "uuid",
  "status": "confirmed"
}
```

#### GET /payment/status/{id}
Check payment status

**Headers:** `Authorization: Bearer {token}`

### Inspection Service (Port 8004)

#### GET /inspections/assigned/{technician_id}
Get assigned vehicles for technician

**Headers:** `Authorization: Bearer {token}`

#### POST /inspections/submit
Submit inspection results

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "appointment_id": "uuid",
  "results": {
    "brakes": "PASS",
    "lights": "PASS",
    "tires": "FAIL",
    "emissions": "PASS"
  },
  "final_status": "FAIL"
}
```

#### GET /inspections/result/{appointment_id}
Retrieve inspection report

**Headers:** `Authorization: Bearer {token}`

### Logging Service (Port 8005)

#### POST /log
Log event (called by other services)

**Request:**
```json
{
  "service": "PaymentService",
  "event": "payment.confirmed",
  "level": "INFO",
  "message": "Payment for appointment 1923 confirmed"
}
```

#### GET /log/all
Get all logs (admin only)

**Headers:** `Authorization: Bearer {token}`

---

## COMMON ISSUES & SOLUTIONS

### 1. JWT Token Validation Errors

**Issue:** "Could not validate credentials" error

**Solutions:**
- Ensure token is in `Authorization: Bearer {token}` format
- Check token expiration time
- Verify JWT_SECRET_KEY is the same across all services
- Ensure token contains required claims (email, role)

### 2. CORS Errors

**Issue:** "CORS policy: No 'Access-Control-Allow-Origin'"

**Solutions:**
- Add CORS middleware to each FastAPI service
- Configure allowed origins in `.env`
- Ensure credentials are sent with requests

### 3. Database Connection Failures

**Issue:** "ConnectionRefusedError" or "could not connect to server"

**Solutions:**
- Check PostgreSQL is running
- Verify DB credentials in `.env`
- Wait for database to initialize (Docker may need 10-15 seconds)
- Check network connectivity between services

### 4. Service Port Conflicts

**Issue:** "Address already in use" error

**Solutions:**
- Change ports in `.env`
- Kill processes using the ports: `lsof -i :8001` (Linux/Mac)
- Use `docker-compose down` to release all ports

### 5. Token Expiration Issues

**Issue:** Users logged out unexpectedly

**Solutions:**
- Increase JWT_EXPIRATION_HOURS in `.env`
- Implement refresh token mechanism
- Add token refresh endpoint in Auth Service

### 6. Duplicate Appointments

**Issue:** Multiple identical appointments created

**Solutions:**
- Use Idempotency-Key header in requests
- Add unique constraint on (user_id, appointment_date, vehicle_id)
- Implement optimistic locking

### 7. Payment Not Linked to Appointment

**Issue:** Payment confirmed but appointment status not updated

**Solutions:**
- Ensure payment_id is correctly stored in appointment record
- Add callback from Payment Service to Appointment Service
- Implement retry logic for failed updates

### 8. Missing Authorization Headers

**Issue:** "Missing Authorization header" error

**Solutions:**
- Always include `Authorization: Bearer {token}` in requests
- Check that frontend is sending token in API calls
- Implement axios/fetch interceptors to add token automatically

### 9. Slow Service Startup

**Issue:** Services timeout when starting

**Solutions:**
- Increase startup time in docker-compose
- Add health checks
- Pre-create databases
- Implement connection pooling

### 10. Service Discovery Issues

**Issue:** Services can't find each other

**Solutions:**
- Use service names in docker-compose (not localhost)
- Verify network configuration
- Check firewall rules between containers

---

## SECURITY CONSIDERATIONS

### Authentication & Authorization

1. **Password Hashing**
   - Always use bcrypt with salt rounds ≥ 12
   - Never store plaintext passwords
   - Hash before saving to database

2. **JWT Tokens**
   - Use strong SECRET_KEY (minimum 32 characters)
   - Include expiration (exp) claim
   - Include role in token for authorization checks
   - Invalidate tokens on logout (blacklist if needed)

3. **Role-Based Access Control**
   - Verify role from token before granting access
   - Admin: Can access logs and all data
   - Technician: Can only see assigned vehicles
   - Customer: Can only see own appointments

### Data Protection

1. **Sensitive Data**
   - Never log passwords, tokens, or payment details
   - Use environment variables for secrets
   - Encrypt payment information in transit (HTTPS)

2. **Database Security**
   - Use strong database passwords
   - Limit database access to specific IPs
   - Regular backups
   - Never commit credentials to version control

3. **API Security**
   - Validate all input data
   - Sanitize user inputs
   - Use HTTPS in production
   - Implement rate limiting
   - Add request timeout limits

### Common Security Mistakes to Avoid

- ❌ Storing tokens in localStorage permanently
- ❌ Using weak JWT secrets
- ❌ Logging sensitive information
- ❌ Missing CORS configuration
- ❌ Not validating user roles
- ❌ Storing plaintext passwords
- ❌ Using expired/blacklisted tokens
- ❌ Missing input validation

### Production Checklist

- [ ] Change all default credentials
- [ ] Generate strong JWT_SECRET_KEY
- [ ] Enable HTTPS/SSL
- [ ] Set up rate limiting
- [ ] Configure database backups
- [ ] Enable query logging
- [ ] Set up monitoring/alerts
- [ ] Implement API versioning
- [ ] Use secrets management (Vault, K8s Secrets)
- [ ] Enable audit logging

---

## DEPLOYMENT & SCALING

### Horizontal Scaling with Docker Compose

```yaml
# Scale payment service to 3 instances
services:
  payment-service-1:
    build: ./backend/payment-service
    environment:
      - SERVICE_INSTANCE=1
    ports:
      - "8031:8003"
  payment-service-2:
    build: ./backend/payment-service
    environment:
      - SERVICE_INSTANCE=2
    ports:
      - "8032:8003"
  payment-service-3:
    build: ./backend/payment-service
    environment:
      - SERVICE_INSTANCE=3
    ports:
      - "8033:8003"
```

### Load Balancing

Use Nginx or HAProxy to distribute requests across service instances.

### Monitoring & Health Checks

Add health check endpoints to each service:

```
GET /health
Returns: {"status": "healthy", "service": "auth-service"}
```

---

## TESTING

### Unit Tests

```bash
# Run tests for a specific service
cd backend/auth-service
pytest tests/ -v

# With coverage
pytest tests/ --cov=.
```

### Integration Tests

Test service-to-service communication:

```bash
# Test complete flow: login → appointment → payment → inspection
pytest tests/integration/test_complete_flow.py
```

### Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 100 http://localhost:3000

# Using wrk
wrk -t12 -c400 -d30s http://localhost:3000
```

---

## MAINTENANCE

### Database Maintenance

```sql
-- Vacuum and analyze (PostgreSQL)
VACUUM ANALYZE;

-- Clear old logs
DELETE FROM logs WHERE timestamp < NOW() - INTERVAL '30 days';
```

### Log Rotation

Configure log rotation in systemd or Docker:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### Backup Strategy

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
for db in auth_db appointments_db payments_db inspections_db logs_db; do
  pg_dump $db | gzip > /backups/${db}_${DATE}.sql.gz
done
```

---

## FUTURE ENHANCEMENTS

1. **Advanced Features**
   - Gray card (registration certificate) OCR scanning
   - Automated chatbot for customer support
   - Email notifications
   - SMS reminders
   - Invoice generation and payment history

2. **System Improvements**
   - Message queue (RabbitMQ/Redis) for asynchronous processing
   - Service mesh (Istio) for advanced traffic management
   - API Gateway (Kong) for routing and rate limiting
   - Caching layer (Redis) for performance
   - Search engine (Elasticsearch) for logs and analytics

3. **Security Enhancements**
   - OAuth2/OpenID Connect for third-party integrations
   - Two-factor authentication (2FA)
   - End-to-end encryption
   - Compliance with GDPR/data protection

4. **Analytics & Reporting**
   - Real-time dashboards
   - Performance metrics
   - Revenue reports
   - Customer analytics
   - Technician performance tracking

---

## SUPPORT & TROUBLESHOOTING

For detailed troubleshooting, see `WARNINGS.txt` file included in the project.

For API issues:
- Check service logs: `docker-compose logs {service-name}`
- Verify service health: `curl http://localhost:{port}/health`
- Check database connectivity: Connect directly to database and verify tables

---

**Last Updated:** October 2025
**Version:** 1.0.0
**Status:** Production Ready
