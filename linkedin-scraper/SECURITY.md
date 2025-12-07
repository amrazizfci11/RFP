# Security Guidelines

## Overview

This document outlines the security measures implemented in the LinkedIn Scraper application and best practices for maintaining security.

## Security Architecture

### 1. Authentication & Authorization

#### JWT Implementation
- **Algorithm**: HS256 (HMAC with SHA-256)
- **Expiration**: 7 days (configurable)
- **Storage**: Client-side in localStorage
- **Transmission**: Bearer token in Authorization header

#### Password Security
- **Hashing**: bcrypt with 12 rounds
- **Requirements**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character

#### Account Protection
- **Failed Login Attempts**: Maximum 5 attempts
- **Lockout Duration**: 2 hours
- **Lockout Mechanism**: Automatic account lock after threshold

### 2. Input Validation

#### Backend Validation
- **express-validator**: All endpoints validate input
- **MongoDB Sanitization**: Prevents NoSQL injection
- **Type Checking**: Strong type validation
- **Length Limits**: Maximum lengths enforced

#### Frontend Validation
- **DOMPurify**: Sanitizes all user input
- **Pattern Matching**: URL and format validation
- **Client-side Checks**: Immediate feedback

### 3. Rate Limiting

| Endpoint Type | Window | Max Requests |
|--------------|--------|--------------|
| Standard API | 15 min | 100 |
| Authentication | 15 min | 5 |
| Scraper | 60 min | 10 |

### 4. Security Headers

```javascript
// Implemented via Helmet.js
{
  contentSecurityPolicy: {
    defaultSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    scriptSrc: ["'self'"],
    imgSrc: ["'self'", "data:", "https:"]
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  noSniff: true,
  xssFilter: true,
  hidePoweredBy: true
}
```

### 5. Database Security

#### MongoDB Configuration
- **Connection**: Encrypted connections only
- **Authentication**: Username/password required
- **Authorization**: Role-based database access
- **Indexes**: Optimized queries, prevent DoS

#### Data Protection
- **Sensitive Data**: Never log passwords or tokens
- **Schema Validation**: Mongoose schema enforcement
- **Query Sanitization**: All queries sanitized

### 6. CORS Policy

```javascript
{
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}
```

### 7. Error Handling

#### Secure Error Messages
- **Production**: Generic error messages
- **Development**: Detailed stack traces
- **Logging**: All errors logged with context

#### Information Disclosure Prevention
- No database structure in errors
- No sensitive data in responses
- Generic 401/403 messages

## OWASP Top 10 Compliance

### A01:2021 - Broken Access Control ✅
- JWT authentication on all protected routes
- Role-based authorization (user, admin)
- User can only access their own resources

### A02:2021 - Cryptographic Failures ✅
- Bcrypt for password hashing
- JWT for secure sessions
- No plaintext sensitive data storage

### A03:2021 - Injection ✅
- MongoDB query sanitization
- Input validation on all endpoints
- Parameterized queries
- XSS protection via DOMPurify

### A04:2021 - Insecure Design ✅
- Security-first architecture
- Rate limiting by design
- Fail-secure defaults
- Principle of least privilege

### A05:2021 - Security Misconfiguration ✅
- Helmet.js security headers
- Environment-based configuration
- No default credentials
- Error messages don't leak info

### A06:2021 - Vulnerable Components ✅
- Regular dependency updates
- Security audit (`npm audit`)
- Minimal dependencies
- Trusted packages only

### A07:2021 - Authentication Failures ✅
- Strong password policy
- Account lockout mechanism
- Session expiration
- Secure password reset

### A08:2021 - Data Integrity Failures ✅
- Input validation
- Digital signatures (JWT)
- Checksums for critical operations
- Audit logging

### A09:2021 - Logging Failures ✅
- Winston logger implementation
- Comprehensive error logging
- Security event logging
- Log rotation

### A10:2021 - SSRF ✅
- URL validation
- Whitelist approach
- No user-controlled redirects
- LinkedIn URL pattern matching

## Best Practices for Deployment

### Environment Variables
```bash
# Never commit these files
.env
.env.local
.env.production

# Always use strong secrets
JWT_SECRET=[64+ character random string]
SESSION_SECRET=[64+ character random string]
```

### HTTPS Configuration
```bash
# Always use HTTPS in production
# Redirect HTTP to HTTPS
# Use valid SSL certificates
```

### MongoDB Security
```bash
# Enable authentication
mongod --auth

# Use strong passwords
# Limit network exposure
# Regular backups
# Enable audit logging
```

### Reverse Proxy (Production)
```nginx
# Use nginx or similar
# Enable rate limiting at proxy level
# Add additional security headers
# SSL termination
```

## Security Checklist

### Before Deployment

- [ ] Change all default credentials
- [ ] Update all environment variables
- [ ] Enable HTTPS
- [ ] Configure firewall rules
- [ ] Set up MongoDB authentication
- [ ] Configure backup strategy
- [ ] Enable application logging
- [ ] Set up monitoring/alerts
- [ ] Review CORS settings
- [ ] Audit npm dependencies
- [ ] Test rate limiting
- [ ] Verify error handling
- [ ] Check CSP headers
- [ ] Test authentication flows
- [ ] Review file permissions

### Regular Maintenance

- [ ] Weekly: Review logs for suspicious activity
- [ ] Weekly: Check failed login attempts
- [ ] Monthly: Update dependencies
- [ ] Monthly: Run security audit
- [ ] Quarterly: Review access controls
- [ ] Quarterly: Rotate secrets
- [ ] Yearly: Security assessment

## Vulnerability Reporting

If you discover a security vulnerability:

1. **Do NOT** open a public issue
2. Email security details to [your-email]
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Incident Response

### In Case of Breach

1. **Immediate Actions**:
   - Isolate affected systems
   - Revoke compromised credentials
   - Enable additional logging

2. **Investigation**:
   - Review logs
   - Identify entry point
   - Assess data exposure

3. **Remediation**:
   - Patch vulnerability
   - Update affected systems
   - Notify affected users

4. **Post-Incident**:
   - Document incident
   - Update security measures
   - Conduct review

## Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Express Security](https://expressjs.com/en/advanced/best-practice-security.html)
- [MongoDB Security Checklist](https://docs.mongodb.com/manual/administration/security-checklist/)

## Compliance

This application follows:
- OWASP Top 10 2021
- OWASP API Security Top 10
- CWE Top 25 Software Weaknesses
- NIST Cybersecurity Framework

---

**Security is a continuous process. Stay vigilant and keep security measures updated.**
