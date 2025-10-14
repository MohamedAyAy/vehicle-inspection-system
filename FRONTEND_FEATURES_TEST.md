# 🧪 Frontend Features Testing Guide

## ✅ **NEW FEATURES INTEGRATED INTO FRONTEND**

This guide will help you test all the newly integrated features in the frontend.

---

## 🎯 **What Was Added**

### **1. Notification Bell 🔔**
- **Location:** Header (next to logout button)
- **Features:**
  - Shows unread notification count
  - Click to open notification modal
  - Auto-refresh every 30 seconds
  - Visual badge for unread messages

### **2. File Upload System 📷**
- **Location:** Inspection form
- **Features:**
  - Click to upload or drag & drop photos
  - Image preview before upload
  - Remove individual photos
  - Supports JPG, PNG, GIF, WEBP
  - Max 10MB per file
  - Photos linked to inspection

### **3. Auto-Notifications 📨**
- **Triggers:**
  - ✅ Registration → Welcome message
  - ✅ Appointment booking → Confirmation
  - ✅ Payment → Payment confirmed
  - ✅ Inspection complete → Result notification
  
### **4. Notifications Modal 💬**
- View all notifications
- Mark as read
- Mark all as read
- Shows unread in blue background

---

## 🚀 **STEP-BY-STEP TESTING**

### **STEP 1: Setup Databases**

Run this first:
```powershell
psql -U postgres -f SETUP_NEW_DATABASES.sql
```

Expected output:
```
CREATE DATABASE
CREATE DATABASE
 datname          
------------------
 notifications_db
 files_db
(2 rows)
```

---

### **STEP 2: Start All Services**

```powershell
.\START_COMPLETE_SYSTEM.ps1
```

**Wait 15 seconds** for all services to initialize.

You should see **8 terminal windows**:
1. Auth Service (Port 8001)
2. Appointment Service (Port 8002)
3. Payment Service (Port 8003)
4. Inspection Service (Port 8004)
5. Logging Service (Port 8005)
6. Notification Service (Port 8006) ← NEW
7. File Service (Port 8007) ← NEW
8. Frontend (Port 3000)

---

### **STEP 3: Verify Services are Running**

```powershell
.\TEST_ALL_SERVICES.ps1
```

Expected output:
```
✓ Auth Service: Healthy
✓ Appointment Service: Healthy
✓ Payment Service: Healthy
✓ Inspection Service: Healthy
✓ Logging Service: Healthy
✓ Notification Service: Healthy ← NEW
✓ File Service: Healthy ← NEW

All Services Healthy!
```

---

## 📋 **FEATURE TESTING CHECKLIST**

### **TEST 1: Notification Bell Visibility** 🔔

**Steps:**
1. Open browser: http://localhost:3000
2. Register new account or login
3. Look at header (top right)

**✅ Success Criteria:**
- [ ] Bell icon 🔔 is visible in header
- [ ] Bell is between "Admin" button and "Logout" button
- [ ] Badge is initially hidden (no notifications yet)

**Screenshot Location:** Next to user email in header

---

### **TEST 2: Registration Notification** 🎉

**Steps:**
1. Click "Create Account"
2. Fill in registration form:
   - Email: `testuser@example.com`
   - Password: `Test1234`
   - Fill other optional fields
3. Click "Register"
4. Wait for auto-login
5. **Click the bell icon 🔔**

**✅ Success Criteria:**
- [ ] Bell badge shows "1" (one unread notification)
- [ ] Modal opens with title "🔔 Notifications"
- [ ] First notification says: **"🎉 Welcome to Vehicle Inspection Center!"**
- [ ] Notification has blue background (unread)
- [ ] "Mark Read" button is visible
- [ ] Click "Mark Read" → background turns white

**Troubleshooting:**
- If no notification appears, wait 5 seconds and click bell again
- Check browser console (F12) for any errors
- Ensure notification service is running (check terminal window)

---

### **TEST 3: Appointment Booking Notification** ✅

**Steps:**
1. Navigate to "Appointments" tab
2. Fill in booking form:
   - Vehicle Type: Car
   - Registration: AB-123-CD
   - Brand: Toyota
   - Model: Corolla
   - Select date/time
3. Click "Book Appointment"
4. Wait for success message
5. **Click bell icon 🔔**

**✅ Success Criteria:**
- [ ] Bell badge shows "2" (or +1 from before)
- [ ] New notification: **"✅ Appointment Booked"**
- [ ] Message includes vehicle details (Toyota Corolla AB-123-CD)
- [ ] Notification is unread (blue background)

---

### **TEST 4: Payment Notification** 💰

**Steps:**
1. Stay on "Appointments" tab
2. See your appointment in the list
3. Click "💳 Pay Now"
4. In payment modal, click "✅ Confirm Payment (Simulated)"
5. Wait for success message
6. **Click bell icon 🔔**

**✅ Success Criteria:**
- [ ] Bell badge incremented (+1)
- [ ] New notification: **"💰 Payment Confirmed"**
- [ ] Message says "payment has been processed successfully"
- [ ] Notification is unread (blue background)

---

### **TEST 5: File Upload - Inspection Form** 📷

**Steps:**
1. Logout
2. Login as technician:
   - Email: `tech@test.com`
   - Password: `Test1234`
3. Click "Inspections" tab
4. Enter appointment ID from previous test
5. Scroll down to **"📷 Upload Vehicle Photos (NEW Feature!)"**

**✅ Success Criteria:**
- [ ] Upload area is visible
- [ ] Text says "📁 Click to upload or drag & drop photos"
- [ ] Supported formats listed: JPG, PNG, GIF, WEBP
- [ ] Max size shown: 10MB

---

### **TEST 6: File Upload - Click to Upload** 📁

**Steps:**
1. Click on upload area
2. File picker opens
3. Select 2-3 image files
4. Click "Open"

**✅ Success Criteria:**
- [ ] Images appear as thumbnails below upload area
- [ ] Each thumbnail has × button (remove)
- [ ] Thumbnails are in a grid
- [ ] Images are square (100x100px)

---

### **TEST 7: File Upload - Drag and Drop** 🖱️

**Steps:**
1. Click × on all uploaded files to clear
2. Open File Explorer
3. Drag an image file over upload area
4. Upload area changes color (green)
5. Drop the file

**✅ Success Criteria:**
- [ ] Drag over → upload area turns green
- [ ] Drop → image appears in preview
- [ ] Can add multiple files by dragging more
- [ ] Non-image files are ignored

---

### **TEST 8: File Upload - Remove Files** ❌

**Steps:**
1. Upload 3 images
2. Click × button on middle thumbnail
3. Verify it's removed

**✅ Success Criteria:**
- [ ] Clicked thumbnail disappears
- [ ] Other thumbnails remain
- [ ] No gaps in grid

---

### **TEST 9: Complete Inspection with Photos** 🚗

**Steps:**
1. Fill in inspection form:
   - All items: Pass or Fail
   - Overall Result: Passed
   - Notes: "Test inspection"
2. Upload 2-3 vehicle photos
3. Click "Submit Inspection"
4. Wait for "Uploading photos..." message
5. Wait for "Inspection submitted successfully!"

**✅ Success Criteria:**
- [ ] Shows "Uploading photos..." first
- [ ] Then shows "Inspection submitted successfully!"
- [ ] Upload area clears (no thumbnails left)
- [ ] Form resets

---

### **TEST 10: Inspection Notification** 📋

**Steps:**
1. Logout
2. Login as customer again (`testuser@example.com`)
3. **Click bell icon 🔔**

**✅ Success Criteria:**
- [ ] Bell badge shows unread notifications
- [ ] New notification about inspection
- [ ] Starts with ✅ (if passed) or ❌ (if failed)
- [ ] Shows status: "PASSED", "FAILED", etc.
- [ ] Notification is unread (blue background)

---

### **TEST 11: Mark All as Read** 📬

**Steps:**
1. With notifications modal open
2. Click "Mark All as Read" button
3. Wait 1-2 seconds

**✅ Success Criteria:**
- [ ] All blue backgrounds turn white
- [ ] "Mark Read" buttons disappear
- [ ] Bell badge disappears (count becomes 0)
- [ ] Bell remains visible (just no badge)

---

### **TEST 12: Notification Auto-Refresh** 🔄

**Steps:**
1. Open notifications modal
2. Leave it open
3. In another browser tab/window:
   - Login as another user
   - Book an appointment
   - Make payment
4. Go back to first tab
5. Wait 30 seconds

**✅ Success Criteria:**
- [ ] Bell badge updates automatically
- [ ] New notifications appear without page reload
- [ ] Count increments in real-time

---

## 🎨 **VISUAL VERIFICATION**

### **Notification Bell**
- Position: Top right header
- Icon: 🔔
- Badge: Red circle with white number
- Badge position: Top-right of bell
- Hover effect: Bell scales up slightly

### **Upload Area**
- Border: Dashed teal (#1abc9c)
- Background: Light gray (#f8f9fa)
- Hover: Darker gray (#e9ecef)
- Dragover: Green background (#d4edda)
- Icon: 📁 in center

### **File Previews**
- Size: 100x100px squares
- Border radius: 5px
- Remove button: Red circle (×) top-right
- Grid: 10px gap between items

### **Notifications Modal**
- Title: "🔔 Notifications"
- Width: Max 600px
- Unread: Light blue background (#f0f8ff)
- Read: White background
- Button: "Mark All as Read" (gray)

---

## 🐛 **TROUBLESHOOTING**

### **Bell icon not showing**
**Solution:**
```javascript
// Check browser console (F12) for errors
// Verify you're logged in
// Refresh page
```

### **No notifications appearing**
**Solution:**
1. Check notification service is running:
   ```powershell
   Invoke-RestMethod http://localhost:8006/health
   ```
2. Check browser console for API errors
3. Verify user ID is correct

### **File upload not working**
**Solution:**
1. Check file service is running:
   ```powershell
   Invoke-RestMethod http://localhost:8007/health
   ```
2. Check file size (max 10MB)
3. Verify file format (JPG, PNG, GIF, WEBP)
4. Check `uploads/` folder exists

### **Drag and drop not working**
**Solution:**
- Try clicking upload area instead
- Check browser console for errors
- Verify file types are images
- Try smaller files

---

## 📊 **BACKEND VERIFICATION**

### **Check Notifications in Database**
```powershell
psql -U postgres -d notifications_db -c "SELECT * FROM notifications ORDER BY created_at DESC LIMIT 10;"
```

Expected columns:
- id
- user_id
- notification_type (email/sms)
- subject
- message
- read (true/false)
- created_at

### **Check Uploaded Files in Database**
```powershell
psql -U postgres -d files_db -c "SELECT * FROM files ORDER BY created_at DESC LIMIT 10;"
```

Expected columns:
- id
- appointment_id
- inspection_id
- file_name
- file_path
- file_size
- uploaded_by
- created_at

### **Check Files on Disk**
```powershell
ls uploads/
```

You should see uploaded image files.

---

## ✅ **SUCCESS CHECKLIST**

Mark off as you verify each feature:

### **Notification Features**
- [ ] Bell icon visible after login
- [ ] Badge shows unread count
- [ ] Click bell opens modal
- [ ] Welcome notification on registration
- [ ] Booking notification on appointment
- [ ] Payment notification on payment
- [ ] Inspection notification on completion
- [ ] Mark as read works
- [ ] Mark all as read works
- [ ] Auto-refresh every 30 seconds

### **File Upload Features**
- [ ] Upload area visible in inspection form
- [ ] Click to upload works
- [ ] Drag and drop works
- [ ] File preview shows thumbnails
- [ ] Remove file (×) works
- [ ] Multiple files supported
- [ ] Files uploaded with inspection
- [ ] Upload progress message shows
- [ ] Files stored in uploads/ folder
- [ ] Files recorded in database

### **Integration**
- [ ] All 7 services running
- [ ] Frontend connects to all services
- [ ] No console errors
- [ ] Notifications trigger automatically
- [ ] Photos link to inspections
- [ ] Complete workflow: Register → Book → Pay → Inspect → Notify

---

## 🎉 **ALL FEATURES VERIFIED!**

If all checkboxes are marked, you have successfully verified:

✅ **Notification Service** - Fully integrated with frontend
✅ **File Upload Service** - Working with drag & drop
✅ **Auto-notifications** - Triggered on all key events
✅ **Complete User Experience** - Seamless workflow

**Your Vehicle Inspection System V2.0 is COMPLETE and WORKING!** 🚀

---

## 📸 **WHAT YOU SHOULD SEE**

### **1. Header with Bell**
```
[🚗 Vehicle Inspection Center]     [testuser@example.com]  [🔔¹] [Logout]
```

### **2. Notification Modal**
```
🔔 Notifications                                           ×
[Mark All as Read]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Welcome to Vehicle Inspection Center!              [Mark Read]
Thank you for registering! You can now book...
5 minutes ago
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Appointment Booked
Your appointment for Toyota Corolla (AB-123-CD)...
3 minutes ago
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### **3. File Upload Area**
```
┌─────────────────────────────────────────────┐
│                                             │
│    📁 Click to upload or drag & drop photos │
│    Supported: JPG, PNG, GIF, WEBP (Max 10MB)│
│                                             │
└─────────────────────────────────────────────┘

┌───────┐ ┌───────┐ ┌───────┐
│ [IMG] │ │ [IMG] │ │ [IMG] │
│   ×   │ │   ×   │ │   ×   │
└───────┘ └───────┘ └───────┘
```

---

**🎊 CONGRATULATIONS! Your system is fully functional with all V2.0 features!**
