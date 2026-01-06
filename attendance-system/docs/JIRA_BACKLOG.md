# Jira Backlog - GPS Attendance Management System

## Epic 1: User Authentication & Security (AUTH)

### Story AUTH-1: Implement Multi-Factor Authentication
**Priority:** High | **Story Points:** 13

**Description:**
As an employee, I want to authenticate using multiple methods so that my account is secure.

**Acceptance Criteria:**
- [ ] Users can login with Iqama number or username + password
- [ ] SMS OTP verification after password authentication
- [ ] Support for biometric authentication (fingerprint/face)
- [ ] Session management with JWT tokens
- [ ] Refresh token rotation

**Tasks:**
- [ ] AUTH-1.1: Implement password-based login endpoint
- [ ] AUTH-1.2: Integrate SMS OTP service
- [ ] AUTH-1.3: Create OTP verification flow
- [ ] AUTH-1.4: Implement JWT token generation with claims
- [ ] AUTH-1.5: Add refresh token mechanism
- [ ] AUTH-1.6: Implement biometric login in Flutter app

---

### Story AUTH-2: Nafath Integration
**Priority:** High | **Story Points:** 8

**Description:**
As a Saudi citizen employee, I want to authenticate using Nafath so that I can use my national identity.

**Acceptance Criteria:**
- [ ] Initiate Nafath authentication with National ID
- [ ] Display random verification code
- [ ] Poll for authentication status
- [ ] Complete login upon Nafath approval

**Tasks:**
- [ ] AUTH-2.1: Integrate Nafath API
- [ ] AUTH-2.2: Create Nafath initiation endpoint
- [ ] AUTH-2.3: Implement status polling mechanism
- [ ] AUTH-2.4: Build Flutter Nafath login UI

---

### Story AUTH-3: Password Management
**Priority:** Medium | **Story Points:** 5

**Description:**
As an employee, I want to manage my password securely.

**Acceptance Criteria:**
- [ ] Change password functionality
- [ ] Forgot password with email/SMS verification
- [ ] Password strength validation
- [ ] Account lockout after failed attempts

**Tasks:**
- [ ] AUTH-3.1: Implement change password endpoint
- [ ] AUTH-3.2: Create forgot password flow
- [ ] AUTH-3.3: Add password validation rules
- [ ] AUTH-3.4: Implement account lockout mechanism

---

## Epic 2: GPS-Based Attendance (ATT)

### Story ATT-1: GPS Check-In
**Priority:** High | **Story Points:** 13

**Description:**
As an employee, I want to check in at work with GPS verification so that my attendance is accurately recorded.

**Acceptance Criteria:**
- [ ] Capture GPS coordinates during check-in
- [ ] Validate location against company geofence
- [ ] Record check-in time
- [ ] Show late status if after grace period
- [ ] Prevent check-in outside allowed radius

**Tasks:**
- [ ] ATT-1.1: Implement GPS location service in Flutter
- [ ] ATT-1.2: Create check-in API endpoint
- [ ] ATT-1.3: Implement geofencing validation
- [ ] ATT-1.4: Build check-in UI with location display
- [ ] ATT-1.5: Add late arrival detection

---

### Story ATT-2: GPS Check-Out
**Priority:** High | **Story Points:** 8

**Description:**
As an employee, I want to check out from work with GPS verification.

**Acceptance Criteria:**
- [ ] Capture GPS coordinates during check-out
- [ ] Validate existing check-in for the day
- [ ] Calculate working hours
- [ ] Detect early leave

**Tasks:**
- [ ] ATT-2.1: Create check-out API endpoint
- [ ] ATT-2.2: Implement working hours calculation
- [ ] ATT-2.3: Build check-out UI
- [ ] ATT-2.4: Add early leave detection

---

### Story ATT-3: Today's Attendance Status
**Priority:** High | **Story Points:** 5

**Description:**
As an employee, I want to see my current attendance status for today.

**Acceptance Criteria:**
- [ ] Display check-in time if checked in
- [ ] Show current working duration
- [ ] Display company location on map
- [ ] Show attendance status (Present, Late, etc.)

**Tasks:**
- [ ] ATT-3.1: Create today status API
- [ ] ATT-3.2: Build attendance dashboard widget
- [ ] ATT-3.3: Implement real-time duration counter

---

### Story ATT-4: Attendance History
**Priority:** Medium | **Story Points:** 8

**Description:**
As an employee, I want to view my attendance history.

**Acceptance Criteria:**
- [ ] View attendance records by date range
- [ ] Filter by status (Present, Absent, Late)
- [ ] Monthly calendar view
- [ ] Summary statistics

**Tasks:**
- [ ] ATT-4.1: Create attendance history API with filters
- [ ] ATT-4.2: Build calendar view UI
- [ ] ATT-4.3: Implement statistics summary
- [ ] ATT-4.4: Add pagination for history list

---

## Epic 3: Excuse Management (EXC)

### Story EXC-1: Submit Excuse
**Priority:** Medium | **Story Points:** 8

**Description:**
As an employee, I want to submit an excuse for late arrival or absence.

**Acceptance Criteria:**
- [ ] Select excuse type and date
- [ ] Enter reason description
- [ ] Attach supporting documents
- [ ] Submit for approval

**Tasks:**
- [ ] EXC-1.1: Create excuse submission API
- [ ] EXC-1.2: Implement file upload for attachments
- [ ] EXC-1.3: Build excuse form UI
- [ ] EXC-1.4: Add attachment preview

---

### Story EXC-2: View Excuses
**Priority:** Medium | **Story Points:** 5

**Description:**
As an employee, I want to view my submitted excuses and their status.

**Acceptance Criteria:**
- [ ] List all excuses with status
- [ ] Filter by status and date
- [ ] View excuse details
- [ ] See rejection reason if rejected

**Tasks:**
- [ ] EXC-2.1: Create excuse list API
- [ ] EXC-2.2: Build excuse list UI
- [ ] EXC-2.3: Implement excuse detail view

---

### Story EXC-3: Admin Excuse Approval
**Priority:** Medium | **Story Points:** 8

**Description:**
As a company admin, I want to approve or reject employee excuses.

**Acceptance Criteria:**
- [ ] View pending excuses
- [ ] Approve with optional note
- [ ] Reject with reason
- [ ] Send notification to employee

**Tasks:**
- [ ] EXC-3.1: Create approval API endpoints
- [ ] EXC-3.2: Build admin excuse management UI
- [ ] EXC-3.3: Implement notification on status change

---

## Epic 4: Vacation Management (VAC)

### Story VAC-1: View Vacation Balance
**Priority:** Medium | **Story Points:** 3

**Description:**
As an employee, I want to see my vacation balance.

**Acceptance Criteria:**
- [ ] Display annual vacation days
- [ ] Show used vacation days
- [ ] Calculate remaining balance
- [ ] Show pending requests

**Tasks:**
- [ ] VAC-1.1: Create vacation balance API
- [ ] VAC-1.2: Build balance display widget

---

### Story VAC-2: Apply for Vacation
**Priority:** Medium | **Story Points:** 8

**Description:**
As an employee, I want to apply for vacation.

**Acceptance Criteria:**
- [ ] Select vacation type
- [ ] Choose start and end dates
- [ ] Calculate total days
- [ ] Check balance availability
- [ ] Detect overlapping vacations

**Tasks:**
- [ ] VAC-2.1: Create vacation request API
- [ ] VAC-2.2: Implement date validation
- [ ] VAC-2.3: Build vacation application form
- [ ] VAC-2.4: Add calendar date picker

---

### Story VAC-3: Admin Vacation Approval
**Priority:** Medium | **Story Points:** 8

**Description:**
As a company admin, I want to manage vacation requests.

**Acceptance Criteria:**
- [ ] View pending vacation requests
- [ ] See employee's team vacations
- [ ] Approve or reject with reason
- [ ] Update employee balance on approval

**Tasks:**
- [ ] VAC-3.1: Create vacation approval APIs
- [ ] VAC-3.2: Build vacation management dashboard
- [ ] VAC-3.3: Implement balance deduction

---

## Epic 5: Reports & Analytics (RPT)

### Story RPT-1: Employee Attendance Report
**Priority:** Medium | **Story Points:** 8

**Description:**
As an employee, I want to download my attendance report.

**Acceptance Criteria:**
- [ ] Select date range
- [ ] Choose format (PDF/Excel)
- [ ] Include summary statistics
- [ ] Download report file

**Tasks:**
- [ ] RPT-1.1: Implement PDF report generation
- [ ] RPT-1.2: Implement Excel report generation
- [ ] RPT-1.3: Create report download API
- [ ] RPT-1.4: Build report page UI

---

### Story RPT-2: Admin Company Reports
**Priority:** Medium | **Story Points:** 13

**Description:**
As a company admin, I want comprehensive attendance reports.

**Acceptance Criteria:**
- [ ] Company-wide attendance overview
- [ ] Department-wise breakdown
- [ ] Late arrivals report
- [ ] Absenteeism report
- [ ] Export to PDF/Excel

**Tasks:**
- [ ] RPT-2.1: Create company reports API
- [ ] RPT-2.2: Build admin reports dashboard
- [ ] RPT-2.3: Implement department filters
- [ ] RPT-2.4: Add chart visualizations

---

## Epic 6: Company Administration (ADM)

### Story ADM-1: Employee Management
**Priority:** High | **Story Points:** 13

**Description:**
As a company admin, I want to manage employees.

**Acceptance Criteria:**
- [ ] Add new employees
- [ ] Edit employee details
- [ ] Deactivate/activate employees
- [ ] Bulk import from Excel
- [ ] Export employee list

**Tasks:**
- [ ] ADM-1.1: Create employee CRUD APIs
- [ ] ADM-1.2: Implement Excel import
- [ ] ADM-1.3: Build employee management UI
- [ ] ADM-1.4: Add bulk operations

---

### Story ADM-2: Attendance Configuration
**Priority:** High | **Story Points:** 8

**Description:**
As a company admin, I want to configure attendance settings.

**Acceptance Criteria:**
- [ ] Set working hours
- [ ] Configure grace period
- [ ] Define working days
- [ ] Set GPS radius for check-in
- [ ] Configure company location

**Tasks:**
- [ ] ADM-2.1: Create configuration APIs
- [ ] ADM-2.2: Build settings UI
- [ ] ADM-2.3: Add location picker

---

### Story ADM-3: Clarification Requests
**Priority:** Medium | **Story Points:** 8

**Description:**
As a company admin, I want to request clarification from employees.

**Acceptance Criteria:**
- [ ] Create clarification request
- [ ] View employee responses
- [ ] Send reminders
- [ ] Track pending clarifications

**Tasks:**
- [ ] ADM-3.1: Create clarification APIs
- [ ] ADM-3.2: Build clarification management UI
- [ ] ADM-3.3: Implement notification system

---

### Story ADM-4: Bulk Messaging
**Priority:** Medium | **Story Points:** 5

**Description:**
As a company admin, I want to send messages to employees.

**Acceptance Criteria:**
- [ ] Select recipients (all, department, individual)
- [ ] Compose message
- [ ] Send via push notification and SMS
- [ ] Track delivery status

**Tasks:**
- [ ] ADM-4.1: Create messaging API
- [ ] ADM-4.2: Integrate push notification service
- [ ] ADM-4.3: Build messaging UI

---

## Epic 7: White Label Platform (WLP)

### Story WLP-1: Company Onboarding
**Priority:** High | **Story Points:** 13

**Description:**
As a platform admin, I want to onboard new companies.

**Acceptance Criteria:**
- [ ] Create company profile
- [ ] Assign subscription package
- [ ] Configure branding (logo, colors)
- [ ] Set up admin user

**Tasks:**
- [ ] WLP-1.1: Create company management APIs
- [ ] WLP-1.2: Implement branding configuration
- [ ] WLP-1.3: Build company creation wizard

---

### Story WLP-2: Subscription Management
**Priority:** High | **Story Points:** 8

**Description:**
As a platform admin, I want to manage subscriptions.

**Acceptance Criteria:**
- [ ] View subscription packages
- [ ] Create/edit packages
- [ ] Assign packages to companies
- [ ] Track subscription expiry
- [ ] Send renewal reminders

**Tasks:**
- [ ] WLP-2.1: Create subscription APIs
- [ ] WLP-2.2: Build package management UI
- [ ] WLP-2.3: Implement expiry notifications

---

### Story WLP-3: Platform Analytics
**Priority:** Medium | **Story Points:** 8

**Description:**
As a platform admin, I want to view platform analytics.

**Acceptance Criteria:**
- [ ] Total companies overview
- [ ] Active vs inactive breakdown
- [ ] Revenue metrics
- [ ] Usage statistics
- [ ] Growth charts

**Tasks:**
- [ ] WLP-3.1: Create analytics APIs
- [ ] WLP-3.2: Build analytics dashboard
- [ ] WLP-3.3: Implement chart components

---

## Epic 8: Infrastructure & DevOps (OPS)

### Story OPS-1: Docker Configuration
**Priority:** High | **Story Points:** 5

**Description:**
Containerize all services using Docker.

**Tasks:**
- [ ] OPS-1.1: Create backend Dockerfile
- [ ] OPS-1.2: Create gateway Dockerfile
- [ ] OPS-1.3: Create portal Dockerfiles
- [ ] OPS-1.4: Configure docker-compose

---

### Story OPS-2: Kubernetes Deployment
**Priority:** High | **Story Points:** 8

**Description:**
Set up Kubernetes deployment configuration.

**Tasks:**
- [ ] OPS-2.1: Create namespace and configs
- [ ] OPS-2.2: Create deployment manifests
- [ ] OPS-2.3: Configure Ingress
- [ ] OPS-2.4: Set up HPA for autoscaling

---

### Story OPS-3: CI/CD Pipeline
**Priority:** High | **Story Points:** 8

**Description:**
Implement continuous integration and deployment.

**Tasks:**
- [ ] OPS-3.1: Set up GitHub Actions workflows
- [ ] OPS-3.2: Configure automated testing
- [ ] OPS-3.3: Implement automated deployment
- [ ] OPS-3.4: Set up environment management

---

## Sprint Planning Recommendations

### Sprint 1 (Foundation - 2 weeks)
- AUTH-1: Multi-Factor Authentication
- ATT-1: GPS Check-In
- ATT-2: GPS Check-Out
- OPS-1: Docker Configuration

### Sprint 2 (Core Features - 2 weeks)
- AUTH-2: Nafath Integration
- ATT-3: Today's Attendance Status
- ATT-4: Attendance History
- ADM-1: Employee Management

### Sprint 3 (Excuses & Vacations - 2 weeks)
- EXC-1: Submit Excuse
- EXC-2: View Excuses
- EXC-3: Admin Excuse Approval
- VAC-1: View Vacation Balance
- VAC-2: Apply for Vacation

### Sprint 4 (Admin Features - 2 weeks)
- VAC-3: Admin Vacation Approval
- ADM-2: Attendance Configuration
- ADM-3: Clarification Requests
- ADM-4: Bulk Messaging

### Sprint 5 (Reports & Platform - 2 weeks)
- RPT-1: Employee Attendance Report
- RPT-2: Admin Company Reports
- WLP-1: Company Onboarding
- WLP-2: Subscription Management

### Sprint 6 (Platform & Infrastructure - 2 weeks)
- WLP-3: Platform Analytics
- AUTH-3: Password Management
- OPS-2: Kubernetes Deployment
- OPS-3: CI/CD Pipeline

---

## Story Point Summary

| Epic | Total Story Points |
|------|-------------------|
| Authentication | 26 |
| Attendance | 34 |
| Excuses | 21 |
| Vacations | 19 |
| Reports | 21 |
| Company Admin | 34 |
| White Label | 29 |
| Infrastructure | 21 |
| **Total** | **205** |

---

## Definition of Done

- [ ] Code is complete and follows coding standards
- [ ] Unit tests written with >80% coverage
- [ ] Code reviewed and approved
- [ ] API documentation updated
- [ ] UI/UX matches designs
- [ ] Security requirements met (OWASP)
- [ ] Performance benchmarks passed
- [ ] Deployed to staging environment
- [ ] QA testing completed
- [ ] Product Owner acceptance
