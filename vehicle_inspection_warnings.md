⚠️ VEHICLE INSPECTION SYSTEM - CRITICAL WARNINGS & SOLUTIONS
==============================================================

This document outlines common issues that WILL occur and their solutions.
READ THIS BEFORE RUNNING THE APPLICATION.

---

## 🔴 CRITICAL ISSUES (FIX IMMEDIATELY)

### 1. JWT_SECRET_KEY NOT CHANGED
⚠️ SECURITY RISK: Using default secret key

ISSUE:
- Default SECRET_KEY = "your-super-secret-key-change-this-in-production"
- Anyone can forge valid JWT tokens
- All user data is vulnerable

SOLUTION:
```bash
# Generate a secure key
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Update .env file
JWT_SECRET_KEY=<YOUR_GENERATED_KEY>

# MUST be the same across ALL services
# If different, tokens won't validate
```

VERIFICATION:
- Check all service files use same JWT_SECRET_KEY
- Search codebase for hardcoded secrets
- Never commit .env to git

---

### 2. DATABASE PASSWORD IS WEAK
⚠️ SECURITY RISK: Default password "secure_password_change_this"

ISSUE:
- Default password is in documentation
- Anyone with network access can connect
- Production databases are vulnerable

SOLUTION:
```bash
# Generate strong password (20+ characters)
python -c "import secrets; print(secrets.token_urlsafe(20))"

# Update .env
DB_PASSWORD=<YOUR_STRONG_PASSWORD>

# Store securely (AWS Secrets Manager, HashiCorp Vault, etc.)
# NEVER commit to version control
```

VERIFICATION:
- Run `docker-compose down` then `docker-compose up`
- Test database connection with new password
- Verify no plaintext passwords in logs

---

### 3. CORS NOT CONFIGURED
⚠️ FUNCTIONAL ISSUE: Frontend cannot communicate with backend

ISSUE:
- Frontend (localhost:3000) can't call backend (localhost:8001)
- Browser blocks cross-origin requests
- Application won't work

SOLUTION:
This is ALREADY INCLUDED in all service templates.
Verify each service has:
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, use specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
```

VERIFICATION:
- Check browser console for CORS errors
- Verify Access-Control-Allow-Origin header in responses

---

### 4. JWT TOKEN NOT IN AUTHORIZATION HEADER
⚠️ AUTHENTICATION ERROR: Requests rejected with 401 Unauthorized

ISSUE:
- Frontend not sending token: `Authorization: Bearer {token}`
- Token in URL or body instead
- Token format incorrect

SOLUTION:
Frontend must include token in every authenticated request:
```javascript
const headers = {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
};

fetch('http://localhost:8002/appointments', {
  method: 'GET',
  headers: headers
});
```

VERIFICATION:
- Check request headers in browser DevTools (F12 → Network)
- Look for "Authorization: Bearer ..." header
- Verify token is not expired

---

### 5. DATABASE NOT INITIALIZED
⚠️ CONNECTION ERROR: Services fail to start

ISSUE:
- Services start before PostgreSQL is ready
- Database tables don't exist
- ConnectionRefusedError or "relation does not exist"

SOLUTION:
```bash
# Wait for database to be ready
docker-compose up -d postgres

# Wait 10-15 seconds
sleep 15

# Then start other services
docker-compose up

# Or use depends_on with condition in docker-compose.yml
services:
  auth-service:
    depends_on:
      postgres:
        condition: service_healthy
```

VERIFICATION:
- Check postgres container: `docker ps`
- Test connection: `psql -h localhost -U admin -d auth_db`
- Check service logs for database errors

---

## 🟠 MAJOR ISSUES (WILL CAUSE FAILURES)

### 6. SERVICE PORT ALREADY IN USE
⚠️ STARTUP ERROR: "Address already in use"

ISSUE:
- Another application using the port
- Previous Docker container not cleaned up
- Multiple service instances on same port

SOLUTION:
```bash
# Find process using port 8001
lsof -i :8001  # macOS/Linux
netstat -ano | findstr :8001  # Windows

# Kill the process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or change port in .env
APPOINTMENT_SERVICE_PORT=8012  # Use different port

# Clean up Docker
docker-compose down -v
docker system prune
```

---

### 7. TOKEN EXPIRATION TOO SHORT
⚠️ UX ISSUE: Users logged out immediately

ISSUE:
- JWT_EXPIRATION_HOURS = 1 (too short)
- Token expires before user finishes tasks
- Sudden logout during appointment booking

SOLUTION:
Update `.env`:
```env
JWT_EXPIRATION_HOURS=24  # 24 hours recommended
# For development: 72 or more
```

But ALSO implement refresh tokens for production:
```python
# Auth Service should provide:
# 1. Short-lived access token (1 hour)
# 2. Long-lived refresh token (30 days)

# Endpoint to refresh expired token
@app.post("/refresh")
async def refresh_token(refresh_token: str):
    # Validate refresh token
    # Issue new access token
    return {"access_token": new_token}
```

---

### 8. MISSING INPUT VALIDATION
⚠️ SECURITY ISSUE: SQL injection, invalid data

ISSUE:
```python
# BAD: No validation
@app.post("/appointments")
async def create_appointment(data: dict):
    # data could contain anything
    db.execute(f"INSERT INTO appointments VALUES {data}")
```

SOLUTION:
Use Pydantic models for validation:
```python
from pydantic import BaseModel, EmailStr, validator

class AppointmentRequest(BaseModel):
    vehicle_type: str
    vehicle_registration: str
    vehicle_brand: str
    vehicle_model: str
    
    @validator('vehicle_type')
    def validate_type(cls, v):
        if v not in ['car', 'motorcycle', 'truck']:
            raise ValueError('Invalid vehicle type')
        return v

@app.post("/appointments")
async def create_appointment(data: AppointmentRequest):
    # data is automatically validated
```

---

### 9. PAYMENT NOT LINKED TO APPOINTMENT
⚠️ BUSINESS LOGIC ERROR: Orphaned records

ISSUE:
- Payment created but appointment not updated
- Appointment status stays "pending"
- User thinks payment failed

SOLUTION:
```python
# Payment Service must call Appointment Service
@app.post("/payment/confirm")
async def confirm_payment(payment_data: PaymentConfirm):
    # 1. Update payment status
    db.update_payment(payment_data.payment_id, "confirmed")
    
    # 2. Call Appointment Service to confirm
    response = requests.put(
        f"http://appointment-service:8002/appointments/{payment_data.appointment_id}/confirm",
        json={"payment_id": payment_data.payment_id},
        headers={"Authorization": f"Bearer {service_token}"}
    )
    
    if response.status_code != 200:
        # Rollback: set payment back to pending
        db.update_payment(payment_data.payment_id, "pending")
        raise HTTPException(500, "Failed to confirm appointment")
    
    # 3. Log to Logging Service
    await log_event("PaymentService", "payment.confirmed", "INFO", ...)
```

---

### 10. TECHNICIAN ROLE NOT VERIFIED
⚠️ SECURITY ISSUE: Non-technicians can submit inspection results

ISSUE:
```python
# BAD: No role check
@app.post("/inspections/submit")
async def submit_inspection(token: str, data: InspectionData):
    # Anyone with a token can submit inspection
```

SOLUTION:
Always verify role from token:
```python
async def verify_technician_role(token: str):
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    role = payload.get("role")
    
    if role != "technician":
        raise HTTPException(403, "Only technicians can submit inspections")
    
    return payload

@app.post("/inspections/submit")
async def submit_inspection(
    token: str = Header(...),
    data: InspectionData = None
):
    user = await verify_technician_role(token)
    # Now safe to process
```

---

### 11. LOGGING SERVICE NOT RESPONDING
⚠️ SERVICE FAILURE: Logs not recorded, data integrity compromised

ISSUE:
- Other services call logging service synchronously
- If logging service is down, all services timeout
- No error handling for failed log attempts

SOLUTION:
```python
# ASYNC logging (don't wait for response)
import asyncio

async def log_event(service: str, event: str, level: str, message: str):
    try:
        # Fire and forget - don't wait for response
        asyncio.create_task(
            send_log_to_logging_service(service, event, level, message)
        )
    except Exception as e:
        # Log locally if logging service fails
        print(f"Failed to log: {e}")
        with open("local_logs.txt", "a") as f:
            f.write(f"{service} | {event} | {message}\n")

# Don't do this:
# response = requests.post("logging-service/log", json=data)  # BLOCKING!
```

---

### 12. NO RETRY LOGIC FOR FAILED REQUESTS
⚠️ RELIABILITY ISSUE: Transient failures cause complete failures

ISSUE:
```python
# BAD: Single attempt, no retry
response = requests.post("http://payment-service:8003/payment", json=data)
if response.status_code != 200:
    raise HTTPException(500, "Payment failed")
```

SOLUTION:
Implement retry logic with exponential backoff:
```python
import tenacity

@tenacity.retry(
    wait=tenacity.wait_exponential(multiplier=1, min=2, max=10),
    stop=tenacity.stop_after_attempt(3),
    reraise=True
)
async def call_payment_service(appointment_id: str, amount: float):
    response = requests.post(
        "http://payment-service:8003/payment",
        json={"appointment_id": appointment_id, "amount": amount},
        timeout=5
    )
    response.raise_for_status()
    return response.json()
```

---

### 13. NO TIMEOUT ON SERVICE CALLS
⚠️ PERFORMANCE ISSUE: Requests hang indefinitely

ISSUE:
```python
# BAD: No timeout
response = requests.post("http://some-service/endpoint", json=data)
# If service is down, this hangs forever
```

SOLUTION:
Always set timeout:
```python
# GOOD: 5 second timeout
response = requests.post(
    "http://some-service/endpoint",
    json=data,
    timeout=5  # ← Add this
)

# With retry and timeout
@tenacity.retry(
    wait=tenacity.wait_exponential(),
    stop=tenacity.stop_after_attempt(3)
)
def call_service(url, data):
    return requests.post(url, json=data, timeout=5)
```

---

### 14. DUPLICATE APPOINTMENTS
⚠️ DATA INTEGRITY ISSUE: Same appointment created multiple times

ISSUE:
- User clicks submit button twice
- Network retry creates duplicate
- Race condition in concurrent requests

SOLUTION:
Implement idempotency:
```python
# 1. Use Idempotency-Key header
@app.post("/appointments")
async def create_appointment(
    data: AppointmentRequest,
    idempotency_key: str = Header(None)
):
    if idempotency_key:
        # Check if we've already processed this key
        existing = db.query("SELECT * FROM appointments WHERE idempotency_key = ?", 
                           [idempotency_key])
        if existing:
            return existing[0]  # Return previous response
    
    # Create new appointment
    appointment = db.create_appointment(data)
    
    # Store idempotency key
    if idempotency_key:
        db.store_idempotency_key(idempotency_key, appointment.id)
    
    return appointment

# 2. Database unique constraint
CREATE UNIQUE INDEX idx_appointment_idempotency 
ON appointments(idempotency_key) 
WHERE idempotency_key IS NOT NULL;
```

---

## 🟡 MODERATE ISSUES (PERFORMANCE & USER EXPERIENCE)

### 15. NO PAGINATION FOR LIST ENDPOINTS
⚠️ PERFORMANCE: Loading all records at once

ISSUE:
```python
@app.get("/appointments/{user_id}")
async def get_appointments(user_id: str):
    # Returns ALL appointments
    appointments = db.query(f"SELECT * FROM appointments WHERE user_id = '{user_id}'")
    return appointments  # Could be 10,000+ records!
```

SOLUTION:
```python
@app.get("/appointments/{user_id}")
async def get_appointments(
    user_id: str,
    skip: int = 0,
    limit: int = 10
):
    appointments = db.query(
        "SELECT * FROM appointments WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?",
        [user_id, limit, skip]
    )
    total = db.query("SELECT COUNT(*) FROM appointments WHERE user_id = ?", [user_id])[0]
    
    return {
        "data": appointments,
        "total": total,
        "skip": skip,
        "limit": limit
    }
```

---