# Attendance Management System - Architecture Document

## Overview

This document describes the architecture of the Attendance Management System, a white-label, GPS-based employee attendance solution designed for the Saudi Arabian market.

## System Components

### 1. Mobile Application (Flutter)
- **Purpose**: Employee-facing attendance application
- **Architecture**: Clean Architecture with BLoC pattern
- **Features**:
  - Multi-factor authentication (Iqama/Username + Password + SMS OTP)
  - Biometric authentication (Fingerprint/Face ID)
  - Nafath integration for Saudi national authentication
  - GPS-based attendance check-in/check-out
  - Excuse submission with file uploads
  - Vacation requests
  - Attendance reports (daily/monthly/yearly)
  - Push notifications
  - Offline support with sync

### 2. Backend API (.NET 10)
- **Purpose**: Core business logic and API gateway
- **Architecture**: Clean/Onion Architecture with CQRS pattern
- **Components**:
  - API Gateway (YARP)
  - Authentication Service
  - Attendance Service
  - Company Management Service
  - Employee Management Service
  - Notification Service
  - Reporting Service
  - Integration Service (Nafath, SMS, HR Systems)

### 3. White Label Admin Portal (Angular)
- **Purpose**: Platform administration for SaaS provider
- **Features**:
  - Company management
  - Subscription management
  - Platform analytics
  - System configuration

### 4. Customer Company Portal (Angular)
- **Purpose**: Company-specific administration
- **Features**:
  - Employee management
  - Attendance configuration
  - Reports and analytics
  - Bulk messaging
  - Clarification requests

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                              │
├─────────────────┬─────────────────────┬─────────────────────────────────────┤
│  Mobile App     │  White Label Portal │  Customer Portal                    │
│  (Flutter)      │  (Angular)          │  (Angular)                          │
└────────┬────────┴──────────┬──────────┴─────────────┬───────────────────────┘
         │                   │                        │
         └───────────────────┼────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   API Gateway   │
                    │     (YARP)      │
                    └────────┬────────┘
                             │
┌────────────────────────────┼────────────────────────────────────────────────┐
│                        APPLICATION LAYER                                     │
├─────────────┬──────────────┼──────────────┬──────────────┬──────────────────┤
│    Auth     │  Attendance  │   Company    │   Employee   │   Notification   │
│   Service   │   Service    │   Service    │   Service    │     Service      │
└──────┬──────┴──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────────┘
       │             │              │              │              │
┌──────┴─────────────┴──────────────┴──────────────┴──────────────┴───────────┐
│                           DOMAIN LAYER                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Entities   │  │  Value      │  │  Domain     │  │  Domain     │         │
│  │             │  │  Objects    │  │  Services   │  │  Events     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────────────────────┐
│                      INFRASTRUCTURE LAYER                                    │
├──────────────┬─────────────┼─────────────┬─────────────┬────────────────────┤
│  PostgreSQL  │    Redis    │   Message   │  External   │   File Storage     │
│  Database    │    Cache    │    Queue    │   APIs      │   (S3/Azure Blob)  │
└──────────────┴─────────────┴─────────────┴─────────────┴────────────────────┘
```

## Technology Stack

### Mobile (Flutter)
- Flutter 3.x with Dart
- BLoC for state management
- GetIt for dependency injection
- Dio for HTTP client
- Hive for local storage
- Local Auth for biometrics
- Geolocator for GPS

### Backend (.NET 10)
- ASP.NET Core 10
- Entity Framework Core
- YARP (Reverse Proxy)
- MediatR (CQRS)
- FluentValidation
- Serilog
- Redis for caching
- RabbitMQ for messaging

### Frontend (Angular)
- Angular 17+
- NgRx for state management
- Angular Material UI
- Chart.js for analytics
- ngx-translate for i18n

### Infrastructure
- Docker & Docker Compose
- Kubernetes (K8s)
- PostgreSQL 16
- Redis
- RabbitMQ
- NGINX Ingress
- Prometheus & Grafana

## Security Implementation

### OWASP Compliance
- Input validation and sanitization
- Parameterized queries (SQL injection prevention)
- HTTPS/TLS encryption
- JWT with refresh tokens
- Rate limiting
- CORS configuration
- Security headers
- Audit logging

### Authentication Flow
1. User enters Iqama/Username + Password
2. System validates credentials
3. SMS OTP sent to registered mobile
4. User enters OTP
5. JWT tokens issued (access + refresh)
6. Optional: Biometric binding for future logins
7. Optional: Nafath verification for enhanced security

## Multi-tenancy Architecture

The system uses a **Database per Tenant** approach with shared schema:
- Each company gets isolated data
- Tenant ID in JWT claims
- Middleware for tenant resolution
- Connection string per tenant (optional for enterprise)

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Ingress Controller                     │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                  │
│  ┌────────────────────────────┼─────────────────────────────┐   │
│  │                     Services Mesh                         │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │   │
│  │  │ API Gateway │  │   Auth      │  │ Attendance  │       │   │
│  │  │   (3)       │  │   (3)       │  │   (5)       │       │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │   │
│  │  │  Company    │  │  Employee   │  │ Notification│       │   │
│  │  │   (2)       │  │   (3)       │  │   (2)       │       │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Stateful Services                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │ │
│  │  │ PostgreSQL  │  │    Redis    │  │  RabbitMQ   │         │ │
│  │  │  (Primary)  │  │  (Cluster)  │  │  (Cluster)  │         │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘         │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Saudi Arabia Specific Integrations

### Nafath Integration
- National Single Sign-On
- IAM authentication
- Secure identity verification

### National Address (العنوان الوطني)
- Integration with Saudi Post API
- Address validation
- Geolocation services

### SMS Gateway
- Integration with local SMS providers
- Arabic language support
- OTP delivery

## Performance Optimization

### Caching Strategy
- Redis for distributed caching
- Response caching for reports
- Entity caching for lookups

### Database Optimization
- Read replicas for reporting
- Connection pooling
- Query optimization
- Indexing strategy

### API Optimization
- Response compression
- Pagination
- Lazy loading
- Batch operations

## Scalability

### Horizontal Pod Autoscaler (HPA)
- CPU-based scaling
- Memory-based scaling
- Custom metrics (request rate)

### Database Scaling
- Read replicas
- Connection pooling
- Sharding (future)

## Monitoring & Observability

- Prometheus for metrics
- Grafana for dashboards
- Jaeger for distributed tracing
- ELK Stack for logging
- Health checks endpoints

## White Label Configuration

Each company can customize:
- Logo and branding
- Color scheme (primary/secondary)
- Slogan
- Custom domain (optional)
- Feature toggles
