# 🧪 FINAL COMPREHENSIVE TESTING PROCEDURE

## ✅ All Bugs Fixed - Ready for Testing

---

## 🚀 **STEP-BY-STEP TESTING GUIDE**

### PHASE 1: System Startup (5 minutes)

#### 1.1 Start Services
```powershell
# Option A: Automated (Recommended)
.\START_AND_TEST.ps1

# Option B: Manual
# Open 6 PowerShell terminals and run:
cd backend\auth-service && python main.py       # Terminal 1
cd backend\appointment-service && python main.py # Terminal 2
cd backend\payment-service && python main.py     # Terminal 3
cd backend\inspection-service && python main.py  # Terminal 4
cd backend\logging-service && python main.py     # Terminal 5
cd frontend && python -m http.server 3000        # Terminal 6
```

#### 1.2 Verify Service Health
```powershell
# Check each service (should all return 200 OK)
curl http://localhost:8001/health  # Auth
curl http://localhost:8002/health  # Appointment
curl http://localhost:8003/health  # Payment
curl http://localhost:8004/health  # Inspection
curl http://localhost:8005/health  # Logging
```

**✅ PASS CRITERIA:**
- All 5 services return `{"status": "healthy"}`
- Auth service logs show: "✓ Database schema migration completed successfully"
- No error messages in any terminal

---

### PHASE 2: Clear Old Data (1 minute)

#### 2.1 Clear Browser Storage
```javascript
// Open browser console (F12) on http://localhost:3000
localStorage.clear();
sessionStorage.clear();
location.reload();
```

**✅ PASS CRITERIA:**
- Browser shows login page (not auto-logged in)
- No token in localStorage
- No console errors

---

### PHASE 3: Test Registration (3 minutes)

#### 3.1 Minimal Registration (Email + Password Only)
1. Navigate to http://localhost:3000
2. Click "Create Account"
3. Fill in:
   - Email: `test1@example.com`
   - Password: `TestPass123`
   - Check reCAPTCHA box
4. **SKIP all optional fields** (First Name, Last Name, etc.)
5. Click "Register"

**✅ PASS CRITERIA:**
- ✅ Registration successful message
- ✅ Auto-login works
- ✅ Redirected to customer dashboard
- ✅ No 500 errors
- ✅ Weekly schedule displayed

#### 3.2 Full Registration (With Optional Fields)
1. Logout
2. Register new account:
   - Email: `test2@example.com`
   - Password: `TestPass123`
   - First Name: `John`
   - Last Name: `Doe`
   - Date of Birth: `1995-05-15`
   - ID Number: `ID123456`
   - Country: `France`
   - State: `Paris`
3. Register

**✅ PASS CRITERIA:**
- ✅ Registration successful
- ✅ All fields saved correctly
- ✅ Auto-login works

---

### PHASE 4: Test Login (2 minutes)

#### 4.1 Login with Existing Account
1. Logout
2. Login with `test1@example.com` / `TestPass123`

**✅ PASS CRITERIA:**
- ✅ Login successful
- ✅ "Login successful!" message
- ✅ Redirected to dashboard
- ✅ No 500 errors in console
- ✅ Token stored in localStorage

#### 4.2 Test Invalid Login
1. Try to login with wrong password

**✅ PASS CRITERIA:**
- ✅ "Invalid credentials" error
- ✅ Stays on login page
- ✅ No 500 errors

---

### PHASE 5: Test Customer Workflow (10 minutes)

#### 5.1 View Schedule
1. Login as customer
2. Dashboard should show weekly schedule

**✅ PASS CRITERIA:**
- ✅ Calendar with 7 days visible
- ✅ Available time slots shown
- ✅ Can click on time slots

#### 5.2 Book Appointment
1. Click "Appointments" in navigation
2. Fill vehicle details:
   - Type: Car
   - Registration: `ABC-123-DE`
   - Brand: `Toyota`
   - Model: `Corolla`
3. Select date/time
4. Click "Book Appointment"

**✅ PASS CRITERIA:**
- ✅ "Appointment booked successfully!" message
- ✅ Appointment appears in "Your Appointments" table
- ✅ Status: "pending"
- ✅ "Pay Now" button visible

#### 5.3 Pay for Appointment
1. Click "💳 Pay Now" button
2. Click "✅ Confirm Payment (Simulated)"

**✅ PASS CRITERIA:**
- ✅ "Payment successful!" message
- ✅ Modal closes
- ✅ Status changes to "confirmed"
- ✅ Shows "Paid & Confirmed"

---

### PHASE 6: Test Admin Dashboard (10 minutes)

#### 6.1 Create Admin Account (If Not Exists)
```sql
-- Connect to auth_db database
INSERT INTO accounts (
    id, email, password_hash, role, is_verified,
    first_name, last_name, birthdate, country, session_timeout_minutes
) VALUES (
    gen_random_uuid(),
    'admin@example.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIl.YNlvuW', -- Password: Admin123
    'admin',
    true,
    'Admin',
    'User',
    '1980-01-01',
    'Unknown',
    '15'
) ON CONFLICT DO NOTHING;
```

#### 6.2 Login as Admin
1. Login with `admin@example.com` / `Admin123`
2. Click "Admin" in navigation

**✅ PASS CRITERIA:**
- ✅ Admin dashboard opens
- ✅ See 5 tabs: Users, Logs, Vehicles, Appointments, Schedule

#### 6.3 Test Each Tab

**Users Tab:**
1. Click "👥 Users"
2. Should see list of all users
3. Click "➕ Create Technician"
4. Fill email & password only (skip optional fields)
5. Create

**✅ PASS CRITERIA:**
- ✅ User list displayed
- ✅ Can create technician with minimal info
- ✅ New technician appears in list
- ✅ Role badge shows "technician"

**Logs Tab:**
1. Click "📋 Logs"
2. Should see system logs
3. Try search and filters

**✅ PASS CRITERIA:**
- ✅ Logs displayed in table
- ✅ Pagination works
- ✅ Filters work
- ✅ Search works

**Vehicles Tab:**
1. Click "🚗 Vehicles"
2. Should see ALL vehicles

**✅ PASS CRITERIA:**
- ✅ Shows statistics (Total, Payment Status, Inspection Status)
- ✅ Shows ALL vehicles (including unpaid/uninspected)
- ✅ Displays: Registration, Vehicle info, Status
- ✅ At least 1 vehicle from customer booking

**Appointments Tab:**
1. Click "📅 Appointments"
2. Should see all appointments

**✅ PASS CRITERIA:**
- ✅ Shows all appointments
- ✅ Includes customer booking from Phase 5
- ✅ Shows user ID, vehicle, date, status

**Schedule Tab:**
1. Click "📆 Schedule"
2. Should see weekly schedule

**✅ PASS CRITERIA:**
- ✅ Shows 7 days
- ✅ Available slots: 🟢
- ✅ Booked slots: 🔴
- ✅ Shows available count per day

---

### PHASE 7: Test Technician Workflow (10 minutes)

#### 7.1 Login as Technician
1. Logout from admin
2. Login with technician account created in Phase 6
3. Dashboard loads automatically

**✅ PASS CRITERIA:**
- ✅ "Vehicles Ready for Inspection" section visible
- ✅ Shows the confirmed appointment from Phase 5
- ✅ Statistics: Total count, Not Checked, In Progress
- ✅ "Inspect" button available

**If "No vehicles to be inspected":**
- Verify appointment from Phase 5 is "confirmed" status
- Check: `SELECT * FROM appointments WHERE status='confirmed';`

#### 7.2 Submit Inspection
1. Click "Inspect" button
2. Appointment ID should be pre-filled
3. Select:
   - Brakes: Pass
   - Lights: Pass
   - Tires: Pass
   - Emissions: Pass
   - Overall: Passed
   - Notes: "All systems operational"
4. Click "Submit Inspection"

**✅ PASS CRITERIA:**
- ✅ "Inspection submitted successfully!" message
- ✅ Form resets
- ✅ Vehicle disappears from list (or marked completed)

#### 7.3 Verify Inspection
1. Logout
2. Login as customer
3. Check appointments

**✅ PASS CRITERIA:**
- ✅ Appointment shows inspection result
- ✅ Status updated

---

### PHASE 8: Test Session Management (2 minutes)

#### 8.1 Session Timeout
**Quick Test (1 minute timeout):**
1. In `backend/auth-service/main.py`, temporarily set:
   ```python
   DEFAULT_SESSION_TIMEOUT_MINUTES = 1
   ```
2. Restart auth service
3. Login
4. Wait 1 minute
5. Try to navigate or refresh

**✅ PASS CRITERIA:**
- ✅ Token expires after 1 minute
- ✅ Redirected to login
- ✅ Must login again

**Restore:**
```python
DEFAULT_SESSION_TIMEOUT_MINUTES = 15  # Back to 15 minutes
```

#### 8.2 Invalid Token Handling
1. Login
2. Open DevTools → Application → Local Storage
3. Modify token value to "invalid"
4. Refresh page

**✅ PASS CRITERIA:**
- ✅ Invalid token detected
- ✅ Token cleared from localStorage
- ✅ Redirected to login
- ✅ No errors in console

---

### PHASE 9: Error Scenarios (5 minutes)

#### 9.1 Duplicate Email Registration
1. Try to register with existing email

**✅ PASS CRITERIA:**
- ✅ Error: "Email already registered"
- ✅ Registration form stays open

#### 9.2 Duplicate ID Number (If Provided)
1. Register with ID: TEST123
2. Try to register another account with same ID: TEST123

**✅ PASS CRITERIA:**
- ✅ Error message about duplicate ID
- ✅ Registration blocked

#### 9.3 Age Validation
1. Try to register with birthdate: 2020-01-01 (under 18)

**✅ PASS CRITERIA:**
- ✅ Error: "You must be at least 18 years old"
- ✅ Registration blocked

#### 9.4 Weak Password
1. Try to register with password: "123" (less than 8 characters)

**✅ PASS CRITERIA:**
- ✅ HTML5 validation prevents submission
- ✅ Or backend error: "Password must be at least 8 characters"

---

### PHASE 10: Performance & Stability (5 minutes)

#### 10.1 Rapid Navigation
1. Login as admin
2. Rapidly click between tabs 10 times

**✅ PASS CRITERIA:**
- ✅ No errors
- ✅ All tabs load correctly
- ✅ No memory leaks
- ✅ Response time < 1 second

#### 10.2 Multiple Requests
1. Open 3 browser tabs
2. Login in each tab
3. Navigate to different pages

**✅ PASS CRITERIA:**
- ✅ All tabs work independently
- ✅ No conflicts
- ✅ Sessions handled correctly

#### 10.3 Logout/Login Cycle
1. Login
2. Logout
3. Login again
4. Repeat 5 times

**✅ PASS CRITERIA:**
- ✅ No errors
- ✅ Clean session each time
- ✅ Consistent behavior

---

## 📋 **FINAL CHECKLIST**

### Critical Functionality
- [ ] ✅ Can register with minimal info (email + password)
- [ ] ✅ Can register with full info (all optional fields)
- [ ] ✅ Can login with existing accounts
- [ ] ✅ No 500 errors on login
- [ ] ✅ Token validation works
- [ ] ✅ Auto-logout on invalid token

### Customer Features
- [ ] ✅ View weekly schedule
- [ ] ✅ Book appointment
- [ ] ✅ Pay for appointment
- [ ] ✅ View inspection results

### Technician Features
- [ ] ✅ See vehicles for inspection
- [ ] ✅ Submit inspection results
- [ ] ✅ View inspection history

### Admin Features
- [ ] ✅ All 5 tabs visible and working
- [ ] ✅ Vehicles tab shows ALL vehicles
- [ ] ✅ Can create technicians with minimal info
- [ ] ✅ Can view logs with filters
- [ ] ✅ Schedule tab displays correctly

### Security & Session
- [ ] ✅ Session expires after timeout
- [ ] ✅ Invalid tokens cleared
- [ ] ✅ Age validation works
- [ ] ✅ Password requirements enforced
- [ ] ✅ Duplicate prevention works

### Database
- [ ] ✅ Auto-migration runs successfully
- [ ] ✅ Old accounts work with new schema
- [ ] ✅ New fields have defaults
- [ ] ✅ Unique constraints enforced

---

## 🎯 **SUCCESS CRITERIA**

**System is FULLY WORKING if:**

1. ✅ All 10 test phases pass
2. ✅ Zero 500 errors during testing
3. ✅ All critical functionality checked
4. ✅ No console errors
5. ✅ Clean browser network tab (no failed requests)
6. ✅ Services running stable
7. ✅ Database operations successful
8. ✅ All roles can login and use features

---

## 📊 **TEST REPORT TEMPLATE**

```
=================================================
VEHICLE INSPECTION SYSTEM - TEST REPORT
=================================================
Date: _______________
Tester: _______________
Version: 2.1

PHASE 1: System Startup           [ ] PASS [ ] FAIL
PHASE 2: Clear Old Data           [ ] PASS [ ] FAIL
PHASE 3: Test Registration        [ ] PASS [ ] FAIL
PHASE 4: Test Login               [ ] PASS [ ] FAIL
PHASE 5: Customer Workflow        [ ] PASS [ ] FAIL
PHASE 6: Admin Dashboard          [ ] PASS [ ] FAIL
PHASE 7: Technician Workflow      [ ] PASS [ ] FAIL
PHASE 8: Session Management       [ ] PASS [ ] FAIL
PHASE 9: Error Scenarios          [ ] PASS [ ] FAIL
PHASE 10: Performance & Stability [ ] PASS [ ] FAIL

OVERALL RESULT: [ ] ALL PASS [ ] NEEDS FIXES

Issues Found:
1. _____________________________________
2. _____________________________________
3. _____________________________________

Notes:
_________________________________________
_________________________________________
_________________________________________

Signature: _______________
```

---

## 🆘 **TROUBLESHOOTING DURING TESTS**

### If Any Test Fails:

1. **Check Service Logs** - Look at terminal windows
2. **Check Browser Console** - F12 → Console tab
3. **Check Network Tab** - F12 → Network tab
4. **Verify Database** - Run SQL queries
5. **Restart Services** - Fresh start
6. **Clear Browser** - localStorage.clear()

### Common Issues:

**"No vehicles" in technician dashboard:**
- Need at least 1 confirmed appointment
- Create → Book → Pay → Then login as technician

**500 errors:**
- Check auth service started first
- Verify migration completed
- Check database connection

**Auto-login not working:**
- Clear localStorage
- Restart auth service
- Check /verify endpoint

---

## ✅ **COMPLETION**

**When all tests pass:**
1. ✅ Document results in test report
2. ✅ Take screenshots of each dashboard
3. ✅ Save test data for future reference
4. ✅ System is PRODUCTION READY

**Total Testing Time:** ~45-60 minutes

**Files to Review:**
- URGENT_FIXES_APPLIED.md - What was fixed
- START_AND_TEST.ps1 - Automated startup
- FINAL_TEST_PROCEDURE.md - This file

---

*Last Updated: October 14, 2024*
*Version: 2.1*
*Status: Ready for Comprehensive Testing*
