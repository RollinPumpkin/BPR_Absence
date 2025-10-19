# 📸 Screenshot Guide for BPR Absence User Guidebook

This document lists all the screenshots needed for the user guidebook, with specific instructions for each image.

---

## 🎯 Screenshot Requirements List

### 1. Getting Started & Login (7 screenshots)

#### 1.1 Main Login Page
**Location:** `http://localhost:8080/`
**Description:** Clean login form showing email/password fields, remember me checkbox, and login button
**Instructions:**
- Take screenshot of full login page
- Ensure all form elements are visible
- Show company branding/logo

#### 1.2 Login Form with Sample Data
**Location:** Same as above
**Description:** Login form with sample credentials filled in
**Instructions:**
- Fill email: `admin@bpr.com`
- Fill password: `••••••••` (masked)
- Check "Remember Me"
- Don't click login yet - just show filled form

#### 1.3 Forgot Password Page
**Location:** `http://localhost:8080/#/forgot-password`
**Description:** Password reset request form
**Instructions:**
- Show email input field
- Show "Send Reset Link" button
- Show back to login link

#### 1.4 Password Reset Email Form
**Location:** `http://localhost:8080/#/forgot-password/email`
**Description:** Email confirmation page
**Instructions:**
- Show confirmation message
- Show email address where reset link was sent

#### 1.5 Reset Password Form
**Location:** `http://localhost:8080/#/forgot-password/reset-password`
**Description:** New password creation form
**Instructions:**
- Show new password field
- Show confirm password field
- Show reset button

#### 1.6 First-Time Setup (if available)
**Location:** After first login
**Description:** Profile completion or password change prompt
**Instructions:**
- Capture any first-time user setup screens

#### 1.7 Role-Based Routing
**Location:** After successful login
**Description:** Show how different roles are redirected
**Instructions:**
- Login as admin → capture admin dashboard
- Login as user → capture user dashboard

---

### 2. Admin Dashboard (12 screenshots)

#### 2.1 Admin Dashboard Overview
**Location:** `http://localhost:8080/#/admin/dashboard`
**Description:** Main admin dashboard with all widgets
**Instructions:**
- Show header with welcome message
- Show statistics cards (employee count, attendance rate, etc.)
- Show recent activity section
- Show navigation menu

#### 2.2 Employee Management - List View
**Location:** `http://localhost:8080/#/admin/employees`
**Description:** List of all employees
**Instructions:**
- Show employee cards with photos, names, departments
- Show search/filter options
- Show "Add Employee" button

#### 2.3 Add Employee Form - Page 1
**Location:** Click "Add Employee" button
**Description:** Employee creation form - personal information
**Instructions:**
- Show personal info fields (name, email, phone)
- Show profile picture upload area
- Show form validation if possible

#### 2.4 Add Employee Form - Page 2
**Location:** Same form, scroll down or next section
**Description:** Employment information section
**Instructions:**
- Show employee ID, department, position fields
- Show role selection dropdown
- Show save button

#### 2.5 Employee Detail View
**Location:** Click on any employee card
**Description:** Detailed employee information page
**Instructions:**
- Show employee profile with full details
- Show edit button
- Show attendance summary
- Show action buttons

#### 2.6 Attendance Dashboard
**Location:** `http://localhost:8080/#/admin/attendance`
**Description:** Attendance monitoring interface
**Instructions:**
- Show daily attendance summary
- Show present/absent/late statistics
- Show attendance calendar or timeline

#### 2.7 Attendance Report Generation
**Location:** Admin → Reports section
**Description:** Report generation interface
**Instructions:**
- Show date range selector
- Show employee/department filters
- Show export format options (PDF/Excel)

#### 2.8 Manual Attendance Entry
**Location:** Attendance → Manual Entry
**Description:** Form for manual attendance adjustment
**Instructions:**
- Show employee selector
- Show date picker
- Show time inputs for check-in/out
- Show reason field

#### 2.9 Letters Inbox - Admin View
**Location:** `http://localhost:8080/#/admin/letter`
**Description:** Admin letter management interface
**Instructions:**
- Show list of letters with sender, subject, status
- Show read/unread indicators
- Show filter options

#### 2.10 Compose Letter Form
**Location:** Letters → Compose
**Description:** Letter creation interface
**Instructions:**
- Show recipient selector (multiple employees)
- Show subject and message fields
- Show attachment option
- Show priority settings

#### 2.11 Assignments Dashboard
**Location:** `http://localhost:8080/#/admin/assignment`
**Description:** Assignment management overview
**Instructions:**
- Show assignment cards with titles, assignees, due dates
- Show status indicators (in progress, completed, overdue)
- Show "Create Assignment" button

#### 2.12 Admin Profile Page
**Location:** `http://localhost:8080/#/admin/profile`
**Description:** Admin profile with the new design we created
**Instructions:**
- Show red header with name "Anindya Nurhaliza Putri"
- Show contact info section
- Show information section (Manager, Management, Dec 32, 2045)
- Show leave summary with 12 Days quota
- Show blue "Request Leave" button

---

### 3. User Dashboard (10 screenshots)

#### 3.1 User Dashboard Overview  
**Location:** `http://localhost:8080/#/user/dashboard` (login as regular user)
**Description:** Employee dashboard main view
**Instructions:**
- Show welcome message with employee name
- Show quick action buttons
- Show today's schedule/tasks
- Show attendance status

#### 3.2 User Check-in Process - Step 1
**Location:** `http://localhost:8080/#/user/attendance`
**Description:** Attendance page with check-in option
**Instructions:**
- Show "Check In" button prominently
- Show location permission request if applicable
- Show current time and date

#### 3.3 User Check-in Process - Step 2
**Location:** During check-in flow
**Description:** Location verification and selfie capture
**Instructions:**
- Show camera interface for selfie
- Show location confirmation
- Show check-in button

#### 3.4 User Check-in Process - Step 3
**Location:** After successful check-in
**Description:** Check-in confirmation
**Instructions:**
- Show success message
- Show check-in time
- Show "Check Out" option now available

#### 3.5 Attendance History
**Location:** User Attendance → History
**Description:** Personal attendance records
**Instructions:**
- Show calendar view or list of attendance
- Show check-in/out times
- Show total working hours
- Show any late/early indicators

#### 3.6 Leave Request Form
**Location:** User Profile → Request Leave
**Description:** Employee leave request interface
**Instructions:**
- Show leave type dropdown (Annual, Sick, Personal)
- Show date pickers for start/end dates
- Show reason text field
- Show remaining leave balance

#### 3.7 User Letters Inbox
**Location:** `http://localhost:8080/#/user/letter`
**Description:** Employee message inbox
**Instructions:**
- Show received letters list
- Show sender, subject, date
- Show read/unread status
- Show compose option

#### 3.8 User Assignments View
**Location:** `http://localhost:8080/#/user/assignment`
**Description:** Employee assigned tasks
**Instructions:**
- Show assignment cards with titles, due dates
- Show progress indicators
- Show priority levels
- Show task details

#### 3.9 Assignment Detail View
**Location:** Click on specific assignment
**Description:** Detailed assignment information
**Instructions:**
- Show full assignment description
- Show due date and priority
- Show progress update options
- Show deliverables section

#### 3.10 User Profile Page
**Location:** `http://localhost:8080/#/user/profile`
**Description:** Employee profile page
**Instructions:**
- Show personal information
- Show job details
- Show contact information
- Show leave balance

---

### 4. Common Features (6 screenshots)

#### 4.1 Bottom Navigation Bar
**Location:** Any page
**Description:** Navigation menu highlighting
**Instructions:**
- Take screenshot showing bottom navigation
- Highlight each icon with labels
- Show active/inactive states

#### 4.2 Notifications Panel
**Location:** Click bell icon in header
**Description:** Notification dropdown or page
**Instructions:**
- Show list of notifications
- Show read/unread status
- Show different notification types

#### 4.3 Settings Page
**Location:** Profile → Settings
**Description:** User preference settings
**Instructions:**
- Show account settings options
- Show notification preferences
- Show privacy options
- Show language selection

#### 4.4 Search Functionality
**Location:** Any search interface
**Description:** Search results and filters
**Instructions:**
- Show search bar with query
- Show filtered results
- Show search suggestions if available

#### 4.5 Mobile Responsive View
**Location:** Any page on mobile device or narrow browser
**Description:** Mobile-optimized layout
**Instructions:**
- Use browser dev tools to simulate mobile
- Show how navigation adapts
- Show how cards/content reflows

#### 4.6 Loading States
**Location:** During data loading
**Description:** Loading indicators and placeholders
**Instructions:**
- Capture loading spinners
- Show skeleton screens if available
- Show progress indicators

---

## 📋 Screenshot Specifications

### Technical Requirements:
- **Format:** PNG (for web) or JPG (for print)
- **Resolution:** Minimum 1920x1080 for desktop, 375x667 for mobile
- **Quality:** High quality, no compression artifacts
- **Browser:** Use Chrome or Firefox for consistency
- **Clean Environment:** Clear browser cache, use incognito mode

### Content Guidelines:
- **Sample Data:** Use realistic but anonymized data
- **UI State:** Show active/hover states where relevant
- **No Personal Data:** Blur or replace any real personal information
- **Consistent Branding:** Ensure company colors/logos are visible
- **Error States:** Include some error/validation screenshots

### Naming Convention:
```
01-01_login_main_page.png
01-02_login_filled_form.png
01-03_forgot_password.png
02-01_admin_dashboard.png
02-02_employee_list.png
...etc
```

---

## 🎨 Post-Processing Notes

### Image Editing:
1. **Add Callouts:** Use arrows, circles, or boxes to highlight important elements
2. **Add Annotations:** Number steps or add explanatory text
3. **Crop Appropriately:** Remove unnecessary browser chrome when needed
4. **Resize for Documentation:** Ensure images fit well in the guidebook layout

### Privacy & Security:
- Replace real employee names with "John Doe", "Jane Smith", etc.
- Use generic email addresses like "employee@company.com"
- Blur or replace any sensitive data
- Use sample phone numbers like "(555) 123-4567"

### Quality Check:
- Ensure all text is readable
- Check that UI elements are clearly visible
- Verify colors are accurate
- Test images at different sizes

---

## 🚀 Taking the Screenshots

### Preparation:
1. **Set up test data** with realistic sample information
2. **Clear browser cache** and use fresh session
3. **Use consistent browser** (recommend Chrome)
4. **Set standard window size** (1920x1080 or similar)
5. **Prepare sample accounts** for both admin and user roles

### Order of Screenshots:
1. Start with login flow (1.1 - 1.7)
2. Login as admin, capture admin features (2.1 - 2.12)
3. Logout, login as user, capture user features (3.1 - 3.10)
4. Capture common features and special states (4.1 - 4.6)

### Tips:
- Take screenshots in good lighting
- Use high-resolution display if possible
- Capture both light and dark modes if supported
- Take extra shots for complex workflows
- Document any issues or missing features you encounter

---

**Total Screenshots Needed:** 35 screenshots  
**Estimated Time:** 2-3 hours with preparation  
**Recommended Team:** 1 photographer + 1 system navigator

Once you have all screenshots, they can be inserted into the guidebook using the placeholder comments I've included!