# 🔍 Enhanced Error Logging & Debugging

## ✅ Changes Applied

I've added comprehensive error logging to help identify the root cause of the 500 errors you're experiencing.

### **What Was Enhanced:**

1. ✅ **Full stack traces** - All exceptions now log with `exc_info=True`
2. ✅ **Detailed error messages** - HTTP 500 errors now include the actual exception message
3. ✅ **Database session logging** - Any database errors are now logged immediately
4. ✅ **Protected log_event calls** - Logging failures won't mask real errors
5. ✅ **Test endpoint** - `/test/db` to verify database connectivity

---

## 🔧 Specific Fixes

### **1. Database Session Error Logging**
**File:** `appointment-service/main.py` Line 130-133

**Before:**
```python
except Exception:
    await session.rollback()
    raise
```

**After:**
```python
except Exception as e:
    logger.error(f"Database session error: {e}", exc_info=True)
    await session.rollback()
    raise
```

**Why:** If the database session fails, we now see the exact error in logs.

---

### **2. Detailed Error Messages in API Responses**
**Files:** Multiple endpoints

**Before:**
```python
except Exception as e:
    logger.error(f"Get all appointments error: {e}")
    raise HTTPException(status_code=500, detail="Failed to retrieve appointments")
```

**After:**
```python
except Exception as e:
    logger.error(f"Get all appointments error: {e}", exc_info=True)
    try:
        await log_event("AppointmentService", "appointments.all.error", "ERROR", f"Failed to get all appointments: {str(e)}")
    except:
        pass  # Don't let logging errors mask the real error
    raise HTTPException(status_code=500, detail=f"Failed to retrieve appointments: {str(e)}")
```

**Why:** The error response now includes the actual exception message, not a generic "Failed" message.

---

### **3. Protected Async Logging in Exception Handlers**

**Problem:** If `await log_event()` fails inside an exception handler, it could mask the original error.

**Solution:** Wrapped all `log_event()` calls in try-except:
```python
try:
    await log_event(...)
except:
    pass  # Don't let logging errors mask the real error
```

---

### **4. Database Test Endpoint**
**New endpoint:** `GET /test/db`

```python
@app.get("/test/db")
async def test_database(db: AsyncSession = Depends(get_db)):
    """Test database connectivity"""
    try:
        result = await db.execute(select(Appointment).limit(1))
        count_result = await db.execute(select(Appointment))
        all_appointments = count_result.scalars().all()
        return {
            "status": "ok",
            "message": "Database connected",
            "appointment_count": len(all_appointments)
        }
    except Exception as e:
        logger.error(f"Database test failed: {e}", exc_info=True)
        return {
            "status": "error",
            "message": str(e),
            "error_type": type(e).__name__
        }
```

**Test it:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8002/test/db" -UseBasicParsing | Select-Object -ExpandProperty Content
```

**Expected result:**
```json
{
  "status": "ok",
  "message": "Database connected",
  "appointment_count": 6
}
```

---

## 🧪 Testing Instructions

### **Test 1: Check Database Connectivity**
```powershell
Invoke-WebRequest -Uri "http://localhost:8002/test/db" -UseBasicParsing
```

**Expected:** `{"status":"ok","message":"Database connected","appointment_count":6}`  
**If it fails:** Database connection problem - check PostgreSQL is running

---

### **Test 2: Test Appointments Endpoint with Better Errors**

Now when you access the appointments endpoints from the frontend, you'll see the **actual error message** instead of just "Failed to retrieve appointments".

**Steps:**
1. Open browser (http://localhost:3000)
2. Login as admin
3. Go to "Appointments" tab
4. Open browser console (F12)
5. Look at the error message - it will now show the real cause

**Before:**
```
{detail: 'Failed to retrieve appointments'}
```

**After (example):**
```
{detail: 'Failed to retrieve appointments: role not found in token payload'}
```
OR
```
{detail: 'Failed to retrieve appointments: database connection lost'}
```
OR
```
{detail: 'Failed to retrieve appointments: Appointment.status invalid value'}
```

---

## 🔍 What to Look For

When you test the endpoints now, the error message will tell us:

### **Possible Root Causes:**

1. **"Token validation error"** → JWT token is invalid or expired
2. **"role not found"** → Token doesn't contain role field
3. **"Database connection"** → PostgreSQL is down or unreachable
4. **"column does not exist"** → Database schema mismatch
5. **"invalid status value"** → Data integrity issue
6. **"Timeout"** → Service communication problem

---

## 📊 Verification Steps

### **Step 1: Verify All Services Running**
```powershell
@(8001, 8002, 8003, 8004, 8005) | ForEach-Object {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$_/health" -UseBasicParsing
        Write-Host "[OK] Port $_" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] Port $_" -ForegroundColor Red
    }
}
```

**Expected:** All ports return `[OK]`

---

### **Step 2: Test Database**
```powershell
Invoke-WebRequest -Uri "http://localhost:8002/test/db" -UseBasicParsing
```

**Expected:** `"status":"ok"`

---

### **Step 3: Test Frontend**
1. Login to application
2. Try to access:
   - Customer Dashboard (schedule)
   - Admin Appointments tab
3. Check browser console for **detailed error messages**

---

## 🎯 Next Steps

### **After Testing:**

1. **Share the NEW error message** from browser console
   - It will now show the actual root cause
   - Example: `"Failed to retrieve appointments: [specific error here]"`

2. **Check if database test passes**
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8002/test/db" -UseBasicParsing
   ```

3. **Try different user roles:**
   - Login as customer → Check dashboard
   - Login as admin → Check appointments tab
   - Note which role works and which doesn't

---

## 🐛 Common Issues & Solutions

### **Issue 1: "role not found" or "role is None"**
**Cause:** Token doesn't have role field  
**Solution:** Need to fix token generation in auth service

### **Issue 2: "Database connection refused"**
**Cause:** PostgreSQL not running  
**Solution:**
```powershell
Get-Service -Name postgresql-* | Start-Service
```

### **Issue 3: "column 'xyz' does not exist"**
**Cause:** Database schema outdated  
**Solution:** Need to run database migrations

### **Issue 4: "timeout"**
**Cause:** Service communication problem  
**Solution:** Check all services are running and accessible

---

## 📝 What Changed

### **Files Modified:**
- `backend/appointment-service/main.py`
  - Enhanced `get_db()` error logging
  - Added `/test/db` endpoint
  - Improved error messages in all endpoints
  - Protected async logging calls

### **Lines Changed:**
- Line 130-133: Database session error logging
- Line 196-214: New test endpoint
- Line 460-466: Enhanced `/appointments/all` error handling
- Line 537-539: Enhanced `/available-slots` error handling
  - Line 628-634: Enhanced `/weekly-schedule` error handling

---

## ✅ Service Status

**Appointment Service:** ✅ Restarted with enhanced logging  
**Port 8002:** ✅ Running and healthy

---

## 🎉 Expected Outcome

**Before:** Generic "Failed to retrieve appointments" error  
**After:** Specific error showing exactly what went wrong

**This will help us:**
1. Identify the exact root cause immediately
2. Fix the specific issue (not guess)
3. Prevent similar errors in the future

---

## 📞 Report Back

Please test now and share:

1. ✅ Database test result:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8002/test/db" -UseBasicParsing
   ```

2. ✅ Frontend error (from browser console F12):
   - What's the FULL error message now?
   - Does it include a specific cause?

3. ✅ Which user role has the issue:
   - Customer?
   - Admin?
   - Technician?

---

**With these enhanced error messages, we'll see the exact root cause and fix it immediately! 🎯**
