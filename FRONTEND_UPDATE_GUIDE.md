# 🎨 Frontend Update Guide

## ✅ **What Was Fixed:**

### **1. Registration Form** ✅ COMPLETED
- ❌ Removed "Technician" option from dropdown
- ℹ️ Added info message about admin-only technician creation
- Role field is now hidden and defaults to "customer"

---

## 🚧 **What Needs Manual Update:**

Due to file size limits, I've fixed the most critical issue (registration). Here are the remaining updates needed:

### **2. Technician Dashboard - Vehicle List**

**Location:** Around line 906-914 in `index.html`

**Current Code:**
```javascript
} else if (currentUser.role === 'technician') {
    content.innerHTML = `
        <div class="stats">
            <div class="stat-card">
                <h3>🔍</h3>
                <p>Submit inspection results</p>
                <button onclick="navigateTo('inspection')" style="margin-top: 10px;">Go to Inspections</button>
            </div>
        </div>
    `;
}
```

**Replace With:**
```javascript
} else if (currentUser.role === 'technician') {
    // Load vehicles for inspection
    loadTechnicianVehicles();
}

// Add this new function after loadDashboard():
async function loadTechnicianVehicles() {
    const content = document.getElementById('dashboardContent');
    content.innerHTML = '<div class="loading"><div class="spinner"></div><p>Loading vehicles...</p></div>';
    
    try {
        const response = await fetch(`${SERVICES.inspection}/inspections/vehicles-for-inspection`, {
            headers: { 'Authorization': `Bearer ${currentToken}` }
        });
        
        const data = await response.json();
        
        if (data.vehicles && data.vehicles.length > 0) {
            content.innerHTML = `
                <h2>Vehicles Ready for Inspection</h2>
                <p style="margin-bottom: 20px;">Total: ${data.total_count} vehicles | Not Checked: ${data.by_status.not_checked} | In Progress: ${data.by_status.in_progress}</p>
                <table>
                    <thead>
                        <tr>
                            <th>Registration</th>
                            <th>Vehicle</th>
                            <th>Appointment Time</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.vehicles.map(v => `
                            <tr>
                                <td><strong>${v.vehicle_info.registration}</strong></td>
                                <td>${v.vehicle_info.brand} ${v.vehicle_info.model} (${v.vehicle_info.type})</td>
                                <td>${v.appointment_time}</td>
                                <td><span class="badge ${v.status}">${v.status_display}</span></td>
                                <td>
                                    ${v.status === 'not_checked' || v.status === 'in_progress' ? 
                                        `<button onclick="startInspection('${v.appointment_id}')">Inspect</button>` : 
                                        `<button disabled>Completed</button>`
                                    }
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        } else {
            content.innerHTML = '<p>No vehicles ready for inspection.</p>';
        }
    } catch (error) {
        content.innerHTML = `<p class="error">Error loading vehicles: ${error.message}</p>`;
    }
}

function startInspection(appointmentId) {
    document.getElementById('inspectionAppId').value = appointmentId;
    navigateTo('inspection');
}
```

---

### **3. Customer Dashboard - Weekly Schedule**

**Location:** Around line 890-904 in `index.html`

**Current Code:**
```javascript
if (currentUser.role === 'customer') {
    content.innerHTML = `
        <div class="stats">
            <div class="stat-card">
                <h3>📋</h3>
                <p>Book your vehicle inspection</p>
                <button onclick="navigateTo('appointments')" style="margin-top: 10px;">Go to Appointments</button>
            </div>
            <div class="stat-card">
                <h3>✅</h3>
                <p>Track your appointments</p>
                <button onclick="navigateTo('appointments')" style="margin-top: 10px;">View Status</button>
            </div>
        </div>
    `;
}
```

**Replace With:**
```javascript
if (currentUser.role === 'customer') {
    loadCustomerDashboard();
}

// Add this new function:
async function loadCustomerDashboard() {
    const content = document.getElementById('dashboardContent');
    
    // Calculate start of current week (Monday)
    const today = new Date();
    const dayOfWeek = today.getDay() || 7; // Sunday = 0, make it 7
    const monday = new Date(today);
    monday.setDate(today.getDate() - dayOfWeek + 1);
    const startDate = monday.toISOString().split('T')[0];
    
    content.innerHTML = '<div class="loading"><div class="spinner"></div><p>Loading schedule...</p></div>';
    
    try {
        const response = await fetch(
            `${SERVICES.appointment}/appointments/weekly-schedule?start_date=${startDate}`,
            { headers: { 'Authorization': `Bearer ${currentToken}` }}
        );
        
        const schedule = await response.json();
        
        content.innerHTML = `
            <h2>📅 Weekly Inspection Schedule (45-min slots)</h2>
            <p style="margin-bottom: 20px;">Working hours: ${schedule.working_hours} | 🟢 Available | 🔴 Booked</p>
            
            <div style="overflow-x: auto;">
                <table style="min-width: 100%;">
                    <thead>
                        <tr>
                            <th>Time</th>
                            ${schedule.days.map(day => `<th>${day.day_name}<br/><small>${day.date}</small></th>`).join('')}
                        </tr>
                    </thead>
                    <tbody>
                        ${generateWeeklyScheduleRows(schedule)}
                    </tbody>
                </table>
            </div>
            
            <div style="margin-top: 30px; text-align: center;">
                <button onclick="navigateTo('appointments')" style="padding: 15px 30px; font-size: 16px;">
                    📋 Book New Appointment
                </button>
            </div>
        `;
    } catch (error) {
        content.innerHTML = `<p class="error">Error loading schedule: ${error.message}</p>`;
    }
}

function generateWeeklyScheduleRows(schedule) {
    if (!schedule.days || schedule.days.length === 0) return '<tr><td colspan="8">No data</td></tr>';
    
    const maxSlots = Math.max(...schedule.days.map(d => d.slots.length));
    let rows = '';
    
    for (let i = 0; i < maxSlots; i++) {
        rows += '<tr>';
        rows += `<td><strong>${schedule.days[0].slots[i]?.display || ''}</strong></td>`;
        
        schedule.days.forEach(day => {
            const slot = day.slots[i];
            if (slot) {
                const bgColor = slot.available ? '#d4edda' : '#f8d7da';
                const icon = slot.available ? '🟢' : '🔴';
                rows += `<td style="background: ${bgColor}; text-align: center;">${icon}</td>`;
            } else {
                rows += '<td></td>';
            }
        });
        
        rows += '</tr>';
    }
    
    return rows;
}
```

---

### **4. Admin Dashboard - Show Actual Logs**

**Location:** Around line 831-884 in `index.html`

**Current Function:** `loadAdminDash()`

**Replace Entire Function With:**
```javascript
async function loadAdminDash() {
    const statsDiv = document.getElementById('adminStats');
    const logsDiv = document.getElementById('adminLogs');
    
    statsDiv.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
    logsDiv.innerHTML = '';
    
    try {
        // Load all logs
        const logsResponse = await fetch(`${SERVICES.logging}/log/all?limit=50`, {
            headers: { 'Authorization': `Bearer ${currentToken}` }
        });
        
        const logs = await response.json();
        
        // Calculate stats
        const stats = {
            total: logs.length,
            info: logs.filter(l => l.level === 'INFO').length,
            warning: logs.filter(l => l.level === 'WARNING').length,
            error: logs.filter(l => l.level === 'ERROR').length
        };
        
        statsDiv.innerHTML = `
            <div class="stat-card">
                <h3>${stats.total}</h3>
                <p>Total Logs</p>
            </div>
            <div class="stat-card">
                <h3>${stats.info}</h3>
                <p>Info</p>
            </div>
            <div class="stat-card">
                <h3>${stats.warning}</h3>
                <p>Warnings</p>
            </div>
            <div class="stat-card">
                <h3>${stats.error}</h3>
                <p>Errors</p>
            </div>
        `;
        
        if (logs.length > 0) {
            logsDiv.innerHTML = `
                <table>
                    <thead>
                        <tr>
                            <th>Service</th>
                            <th>Event</th>
                            <th>Level</th>
                            <th>Message</th>
                            <th>Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${logs.slice(0, 30).map(log => `
                            <tr>
                                <td><strong>${log.service}</strong></td>
                                <td>${log.event}</td>
                                <td><span class="badge ${log.level.toLowerCase()}">${log.level}</span></td>
                                <td style="max-width: 400px; overflow: hidden; text-overflow: ellipsis;">${log.message}</td>
                                <td><small>${new Date(log.timestamp).toLocaleString()}</small></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        } else {
            logsDiv.innerHTML = '<p>No logs available.</p>';
        }
    } catch (error) {
        statsDiv.innerHTML = `<p class="error">Error loading admin dashboard: ${error.message}</p>`;
    }
}
```

---

### **5. Update Final Status Values for Inspection**

**Location:** Around line 547-554 in `index.html`

**Current Code:**
```html
<select id="finalStatus" required>
    <option value="">Select Result</option>
    <option value="PASS">Pass</option>
    <option value="FAIL">Fail</option>
    <option value="PASS_WITH_REPAIRS">Pass with Repairs</option>
</select>
```

**Replace With:**
```html
<select id="finalStatus" required>
    <option value="">Select Result</option>
    <option value="passed">Passed</option>
    <option value="failed">Failed</option>
    <option value="in_progress">In Progress (Save & Continue Later)</option>
    <option value="passed_with_minor_issues">Passed with Minor Issues</option>
</select>
```

---

### **6. Add Payment Integration**

**Add new section after appointments page (around line 486):**

```html
<!-- Payment Modal -->
<div id="paymentModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closePaymentModal()">&times;</span>
        <h2>💳 Payment Required</h2>
        <div id="paymentAlert" class="alert"></div>
        <p>Inspection fee: <strong>$50.00</strong></p>
        <p style="margin-bottom: 20px;">Appointment ID: <span id="paymentAppointmentId"></span></p>
        <div class="alert info" style="display: block; margin-bottom: 15px;">
            ℹ️ This is a simulated payment for educational purposes only. No real money will be charged.
        </div>
        <button onclick="processPayment()" style="width: 100%;">✅ Confirm Payment (Simulated)</button>
    </div>
</div>
```

**Add these functions to the JavaScript section:**

```javascript
let currentPaymentAppointmentId = null;

function showPaymentModal(appointmentId) {
    currentPaymentAppointmentId = appointmentId;
    document.getElementById('paymentAppointmentId').textContent = appointmentId;
    document.getElementById('paymentModal').style.display = 'block';
}

function closePaymentModal() {
    document.getElementById('paymentModal').style.display = 'none';
    currentPaymentAppointmentId = null;
}

async function processPayment() {
    const alert = document.getElementById('paymentAlert');
    
    try {
        // Create payment
        const createResponse = await fetch(`${SERVICES.payment}/payment`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${currentToken}`
            },
            body: JSON.stringify({
                appointment_id: currentPaymentAppointmentId,
                amount: 50.00
            })
        });
        
        if (!createResponse.ok) {
            const error = await createResponse.json();
            showAlert(alert, error.detail || 'Payment failed', 'error');
            return;
        }
        
        const payment = await createResponse.json();
        
        // Confirm payment (simulated)
        const confirmResponse = await fetch(
            `${SERVICES.payment}/payment/${payment.id}/confirm-simulated`,
            {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${currentToken}` }
            }
        );
        
        if (confirmResponse.ok) {
            showAlert(alert, '✅ Payment successful! Appointment confirmed.', 'success');
            setTimeout(() => {
                closePaymentModal();
                loadAppointments();
            }, 2000);
        } else {
            const error = await confirmResponse.json();
            showAlert(alert, error.detail || 'Payment confirmation failed', 'error');
        }
    } catch (error) {
        showAlert(alert, 'Error: ' + error.message, 'error');
    }
}
```

**Update the appointments list display to include payment button:**

```javascript
// In loadAppointments() function, update the table generation:
list.innerHTML = `
    <table>
        <thead>
            <tr>
                <th>Vehicle</th>
                <th>Registration</th>
                <th>Date</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            ${appointments.map(apt => `
                <tr>
                    <td>${apt.vehicle_info.brand} ${apt.vehicle_info.model}</td>
                    <td>${apt.vehicle_info.registration}</td>
                    <td>${apt.appointment_date ? new Date(apt.appointment_date).toLocaleString() : 'Not scheduled'}</td>
                    <td><span class="badge ${apt.status}">${apt.status}</span></td>
                    <td>
                        ${apt.status === 'pending' ? 
                            `<button onclick="showPaymentModal('${apt.id}')">Pay Now</button>` : 
                            apt.status === 'confirmed' ? 
                            '<span style="color: green;">✓ Paid</span>' :
                            '<span>-</span>'
                        }
                    </td>
                </tr>
            `).join('')}
        </tbody>
    </table>
`;
```

---

## 🎨 Additional CSS (Add to <style> section)

```css
.badge {
    padding: 5px 10px;
    border-radius: 15px;
    font-size: 12px;
    font-weight: bold;
}

.badge.pending {
    background: #fff3cd;
    color: #856404;
}

.badge.confirmed {
    background: #d4edda;
    color: #155724;
}

.badge.not_checked {
    background: #e7f3ff;
    color: #004085;
}

.badge.in_progress {
    background: #fff3cd;
    color: #856404;
}

.badge.passed {
    background: #d4edda;
    color: #155724;
}

.badge.failed {
    background: #f8d7da;
    color: #721c24;
}

.badge.passed_with_minor_issues {
    background: #fff3cd;
    color: #856404;
}

button:disabled {
    background: #ccc;
    cursor: not-allowed;
}

button:disabled:hover {
    background: #ccc;
    transform: none;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
}

table th,
table td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

table th {
    background: #f8f9fa;
    font-weight: bold;
    color: #333;
}

table tr:hover {
    background: #f8f9fa;
}
```

---

## ✅ Quick Implementation Checklist

- [x] 1. Remove technician option from registration
- [ ] 2. Add technician vehicle list to dashboard
- [ ] 3. Add customer weekly schedule to dashboard
- [ ] 4. Update admin logs display
- [ ] 5. Update inspection status values
- [ ] 6. Add payment modal and integration
- [ ] 7. Add CSS for badges and tables

---

## 🚀 Testing After Updates

1. **Registration:** Try registering - should only see "Customer" option
2. **Technician Login:** Should see vehicle list with statuses and times
3. **Customer Login:** Should see weekly calendar with availability
4. **Admin Login:** Should see actual log entries
5. **Payment:** Book appointment → Pay → Should auto-confirm
6. **Inspection:** Submit with new status options

---

**All backend APIs are ready! Just need these frontend updates to complete the system.** ✅
