# ✅ COMPLETE SYSTEM TEST & FIX GUIDE

## 🚀 **QUICK FIX (90 Seconds)**

### Step 1: Restart Inspection Service (Critical!)
```powershell
# Find the inspection service terminal window
# Press Ctrl+C to stop it
# Then run:
cd backend\inspection-service
python main.py
```

**Wait 5 seconds for it to start**

### Step 2: Test Immediately
```
1. Go to http://localhost:3000
2. Login as technician
3. Check dashboard
```

**✅ If you see vehicles: FIXED!**
**❌ If still no vehicles: Continue to Step 3**

### Step 3: Check Logs
Look at the inspection service terminal for:
```
INFO: Fetched X appointments from appointment service
INFO: Added vehicle: ...
INFO: Returning X vehicles to technician
```

- **If you see "Fetched 0 appointments"**: No appointments exist → Create them
- **If you see errors**: There's a bug → Check the error message
- **If you see "Returning 0 vehicles"** but appointments exist: Data format issue

---

## 📋 **COMPLETE TESTING PROCEDURE**

### Test 1: Verify Services Running
```powershell
# All should return 200 OK
Invoke-WebRequest http://localhost:8001/health  # Auth
Invoke-WebRequest http://localhost:8002/health  # Appointment
Invoke-WebRequest http://localhost:8004/health  # Inspection
```

**✅ All OK:** Services running
**❌ Any fails:** That service isn't running - start it

---

### Test 2: Verify Appointments Exist
```powershell
# Connect to database
psql -U postgres

# Check appointments
\c appointments_db
SELECT COUNT(*) FROM appointments;
```

**Result: 0** → No appointments, need to create them
**Result: >0** → Appointments exist, good!

**To see details:**
```sql
SELECT 
    vehicle_info->>'registration' as reg,
    status,
    created_at
FROM appointments
ORDER BY created_at DESC
LIMIT 5;
```

---

### Test 3: Create Test Appointment (If Needed)

**Via Frontend (Recommended):**
```
1. Logout if logged in
2. Register/Login as customer
3. Click "Appointments" button
4. Fill in vehicle details:
   - Type: Car
   - Registration: TEST-999-ZZ
   - Brand: Test
   - Model: Vehicle
5. Select date and time
6. Click "Book Appointment"
7. Click "Pay Now" button
8. Confirm payment
```

**Via Database (Fast):**
```sql
\c auth_db;

-- Create customer if doesn't exist
INSERT INTO accounts (id, email, password_hash, role, is_verified, first_name, last_name, birthdate, country, session_timeout_minutes)
VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'test@customer.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIl.YNlvuW',
    'customer', true, 'Test', 'Customer', '1990-01-01', 'Test', '15'
) ON CONFLICT DO NOTHING;

\c appointments_db;

-- Create test appointment
INSERT INTO appointments (id, user_id, vehicle_info, status, appointment_date, created_at)
VALUES (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111'::uuid,
    '{"type": "Car", "registration": "TEST-999-ZZ", "brand": "Test", "model": "Vehicle"}'::jsonb,
    'confirmed',
    NOW() + INTERVAL '1 day',
    NOW()
);

-- Verify it was created
SELECT * FROM appointments WHERE vehicle_info->>'registration' = 'TEST-999-ZZ';
```

---

### Test 4: Verify Technician Can See Vehicles

**Login as Technician:**
```
Email: tech@test.com
Password: Test1234
```

**If tech account doesn't exist, create it:**
```sql
\c auth_db;

INSERT INTO accounts (id, email, password_hash, role, is_verified, first_name, last_name, birthdate, country, session_timeout_minutes)
VALUES (
    '22222222-2222-2222-2222-222222222222'::uuid,
    'tech@test.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIl.YNlvuW',
    'technician', true, 'Test', 'Tech', '1985-01-01', 'Test', '15'
) ON CONFLICT DO NOTHING;
```

**After Login:**
- Dashboard should load automatically
- Should show "All Vehicles for Inspection"
- Should show table with vehicles
- Each row should have: Registration, Vehicle, Time, Payment Status, Inspection Status, Action button

**✅ If you see vehicles: WORKING!**

---

### Test 5: Check Browser Console for Errors

```
1. Press F12
2. Go to Console tab
3. Look for red errors
4. If you see errors, check what they say
```

**Common errors:**
- "Failed to fetch" → Service not running
- "403 Forbidden" → Permission issue
- "500 Internal Server Error" → Backend bug

---

### Test 6: Check Inspection Endpoint Directly

**Using PowerShell:**
```powershell
# First login to get token
$loginBody = '{"email":"tech@test.com","password":"Test1234"}'
$response = Invoke-RestMethod -Uri "http://localhost:8001/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $response.access_token

# Then fetch vehicles
$headers = @{"Authorization" = "Bearer $token"}
$vehicles = Invoke-RestMethod -Uri "http://localhost:8004/inspections/vehicles-for-inspection" -Headers $headers

# Show results
Write-Host "Total vehicles: $($vehicles.total_count)"
Write-Host "Vehicles array: $($vehicles.vehicles.Count)"
$vehicles.vehicles | Format-Table
```

**Expected Output:**
```
Total vehicles: 2
Vehicles array: 2

registration  brand  model  payment_status  status
TEST-999-ZZ   Test   Vehicle confirmed      not_checked
```

---

## 🐛 **COMMON ISSUES & SOLUTIONS**

### Issue 1: "Fetched 0 appointments"
**Cause:** No appointments in database
**Solution:** Create appointments (see Test 3)

### Issue 2: "Appointment service returned status 403"
**Cause:** Token doesn't have permission
**Solution:** 
- Check user role is technician or admin
- Restart auth service
- Login again to get fresh token

### Issue 3: "Error processing appointment..."
**Cause:** Malformed data in appointment
**Solution:** Check logs for which appointment ID, then inspect that appointment:
```sql
\c appointments_db;
SELECT * FROM appointments WHERE id = '[problematic-id]';
```

### Issue 4: Vehicles show in API but not in frontend
**Cause:** Frontend issue
**Solution:** 
- Clear browser cache (Ctrl+Shift+Delete)
- Hard refresh (Ctrl+F5)
- Check browser console for JS errors

### Issue 5: "Cannot connect to inspection service"
**Cause:** Inspection service not running
**Solution:** 
```powershell
cd backend\inspection-service
python main.py
```

---

## ✅ **VERIFICATION CHECKLIST**

Before saying "it works":
- [ ] All 5 backend services running
- [ ] Frontend running on port 3000
- [ ] At least 1 appointment exists in database
- [ ] Can login as technician
- [ ] Technician dashboard shows vehicles table
- [ ] No errors in browser console
- [ ] No errors in inspection service logs
- [ ] Can click "Inspect" button on a vehicle

---

## 🎯 **IF STILL NOT WORKING**

### Step 1: Close Everything
```powershell
# Close all terminal windows
# Close browser
# Wait 10 seconds
```

### Step 2: Fresh Start
```powershell
.\START_COMPLETE_SYSTEM.ps1
# Wait 15 seconds for everything to initialize
```

### Step 3: Create Fresh Test Data
```powershell
psql -U postgres -f CREATE_TEST_DATA.sql
```

### Step 4: Test Again
```
1. Open http://localhost:3000
2. Login as tech@test.com / Test1234
3. Should see vehicle TEST-123-XY
```

### Step 5: If STILL Not Working
**Send me:**
1. Inspection service logs (copy from terminal)
2. Browser console errors (screenshot or copy)
3. Result of: `SELECT COUNT(*) FROM appointments;`
4. Result of the PowerShell test in Test 6

---

## 📊 **WHAT SUCCESS LOOKS LIKE**

**Inspection Service Logs:**
```
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8004
INFO: User tech@test.com (role: technician) viewed vehicle list at 2024-10-14T18:45:00
INFO: Fetched 2 appointments from appointment service
INFO: Added vehicle: TEST-999-ZZ
INFO: Added vehicle: ABC-123-XY
INFO: Returning 2 vehicles to technician
INFO: Result summary: 2 total, 2 not checked
```

**Technician Dashboard:**
```
🚗 All Vehicles for Inspection
Total: 2 vehicles | Not Checked: 2 | In Progress: 0

Registration  Vehicle        Time          Payment    Inspection   Action
TEST-999-ZZ   Test Vehicle   2024-10-15   Paid       Not Checked  [Inspect]
ABC-123-XY    Honda Civic    2024-10-16   Not Paid   Not Checked  [Inspect]
```

**Browser Console:**
```
(no errors - should be empty or just info messages)
```

---

**THE SYSTEM IS WORKING WHEN YOU CAN CLICK "INSPECT" AND SUBMIT AN INSPECTION!** ✅

---

*Last Updated: October 14, 2024, 6:45 PM*
