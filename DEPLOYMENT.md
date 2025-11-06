# Deployment Guide - RFP Analyzer System

This guide provides detailed steps to deploy the RFP Analyzer System to various environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Deployment](#local-development-deployment)
3. [Azure Deployment](#azure-deployment)
4. [AWS Deployment](#aws-deployment)
5. [Docker Deployment](#docker-deployment)
6. [IIS Deployment](#iis-deployment)
7. [Database Setup](#database-setup)
8. [Environment Configuration](#environment-configuration)
9. [Post-Deployment Checklist](#post-deployment-checklist)

---

## Prerequisites

### Software Requirements

- **.NET 8 SDK**: https://dotnet.microsoft.com/download/dotnet/8.0
- **Node.js 18+**: https://nodejs.org/
- **SQL Server** (or Azure SQL Database)
- **Git**: https://git-scm.com/
- **Anthropic API Key**: https://console.anthropic.com/

### Accounts Needed

- Azure Account (for Azure deployment)
- AWS Account (for AWS deployment)
- Anthropic Account with API access

---

## Local Development Deployment

### Step 1: Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd RFP

# Backend setup
cd Backend/RFPAnalyzer.API
dotnet restore
dotnet tool install --global dotnet-ef

# Frontend setup
cd ../../Frontend/rfp-analyzer
npm install
```

### Step 2: Configure Database

```bash
cd Backend/RFPAnalyzer.API

# Create database
dotnet ef database update

# Verify database
dotnet ef database list
```

### Step 3: Configure Application

Edit `Backend/RFPAnalyzer.API/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=RFPAnalyzerDB;Trusted_Connection=true"
  },
  "JwtSettings": {
    "SecretKey": "YourDevSecretKeyAtLeast32CharactersLong!",
    "Issuer": "RFPAnalyzerAPI",
    "Audience": "RFPAnalyzerClient"
  },
  "Claude": {
    "ApiKey": "YOUR_ANTHROPIC_API_KEY"
  }
}
```

### Step 4: Run Application

```bash
# Terminal 1 - Backend
cd Backend/RFPAnalyzer.API
dotnet run

# Terminal 2 - Frontend
cd Frontend/rfp-analyzer
npm run dev
```

Access:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Swagger: http://localhost:5000/swagger

---

## Azure Deployment

### Architecture
- **App Service**: Backend API
- **Static Web App**: Frontend
- **Azure SQL Database**: Database
- **Key Vault**: Secrets management
- **Blob Storage**: File uploads

### Step 1: Create Azure Resources

```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-rfpanalyzer --location eastus

# Create SQL Server
az sql server create \
  --name rfpanalyzer-sql \
  --resource-group rg-rfpanalyzer \
  --location eastus \
  --admin-user sqladmin \
  --admin-password YourStrongPassword123!

# Create SQL Database
az sql db create \
  --resource-group rg-rfpanalyzer \
  --server rfpanalyzer-sql \
  --name RFPAnalyzerDB \
  --service-objective S0

# Create App Service Plan
az appservice plan create \
  --name plan-rfpanalyzer \
  --resource-group rg-rfpanalyzer \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group rg-rfpanalyzer \
  --plan plan-rfpanalyzer \
  --name rfpanalyzer-api \
  --runtime "DOTNET|8.0"

# Create Storage Account
az storage account create \
  --name rfpanalyzerstorage \
  --resource-group rg-rfpanalyzer \
  --location eastus \
  --sku Standard_LRS
```

### Step 2: Configure Key Vault

```bash
# Create Key Vault
az keyvault create \
  --name kv-rfpanalyzer \
  --resource-group rg-rfpanalyzer \
  --location eastus

# Add secrets
az keyvault secret set \
  --vault-name kv-rfpanalyzer \
  --name "ClaudeApiKey" \
  --value "YOUR_ANTHROPIC_API_KEY"

az keyvault secret set \
  --vault-name kv-rfpanalyzer \
  --name "JwtSecretKey" \
  --value "YourProductionSecretKey32CharsMinimum!"
```

### Step 3: Deploy Backend

```bash
cd Backend/RFPAnalyzer.API

# Publish
dotnet publish -c Release -o ./publish

# Create zip
cd publish
zip -r ../deploy.zip .
cd ..

# Deploy to Azure
az webapp deployment source config-zip \
  --resource-group rg-rfpanalyzer \
  --name rfpanalyzer-api \
  --src deploy.zip
```

### Step 4: Configure App Settings

```bash
# Set connection string
az webapp config connection-string set \
  --resource-group rg-rfpanalyzer \
  --name rfpanalyzer-api \
  --settings DefaultConnection="Server=tcp:rfpanalyzer-sql.database.windows.net,1433;Initial Catalog=RFPAnalyzerDB;User ID=sqladmin;Password=YourStrongPassword123!;" \
  --connection-string-type SQLAzure

# Set app settings
az webapp config appsettings set \
  --resource-group rg-rfpanalyzer \
  --name rfpanalyzer-api \
  --settings \
    "JwtSettings__SecretKey=@Microsoft.KeyVault(VaultName=kv-rfpanalyzer;SecretName=JwtSecretKey)" \
    "JwtSettings__Issuer=RFPAnalyzerAPI" \
    "JwtSettings__Audience=RFPAnalyzerClient" \
    "Claude__ApiKey=@Microsoft.KeyVault(VaultName=kv-rfpanalyzer;SecretName=ClaudeApiKey)"
```

### Step 5: Deploy Frontend

```bash
cd Frontend/rfp-analyzer

# Update API URL
# Edit src/services/api.js
# baseURL: 'https://rfpanalyzer-api.azurewebsites.net'

# Build
npm run build

# Deploy to Azure Static Web Apps
# Install Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Deploy
az staticwebapp create \
  --name rfpanalyzer-frontend \
  --resource-group rg-rfpanalyzer \
  --source dist \
  --location eastus
```

### Step 6: Run Database Migrations

```bash
# Update connection string in appsettings.json temporarily
dotnet ef database update --connection "Server=tcp:rfpanalyzer-sql.database.windows.net,1433;Initial Catalog=RFPAnalyzerDB;User ID=sqladmin;Password=YourStrongPassword123!;"
```

---

## AWS Deployment

### Architecture
- **Elastic Beanstalk**: Backend API
- **S3 + CloudFront**: Frontend
- **RDS SQL Server**: Database
- **Secrets Manager**: Secrets

### Step 1: Create AWS Resources

```bash
# Install AWS CLI
aws configure

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier rfpanalyzer-db \
  --db-instance-class db.t3.small \
  --engine sqlserver-ex \
  --master-username admin \
  --master-user-password YourStrongPassword123! \
  --allocated-storage 20

# Create Elastic Beanstalk application
aws elasticbeanstalk create-application \
  --application-name rfpanalyzer-api

# Create environment
aws elasticbeanstalk create-environment \
  --application-name rfpanalyzer-api \
  --environment-name rfpanalyzer-api-prod \
  --solution-stack-name "64bit Amazon Linux 2 v2.5.0 running .NET 8"
```

### Step 2: Store Secrets

```bash
# Create secrets
aws secretsmanager create-secret \
  --name rfpanalyzer/claude-api-key \
  --secret-string "YOUR_ANTHROPIC_API_KEY"

aws secretsmanager create-secret \
  --name rfpanalyzer/jwt-secret \
  --secret-string "YourProductionSecretKey32CharsMinimum!"
```

### Step 3: Deploy Backend

```bash
cd Backend/RFPAnalyzer.API
dotnet publish -c Release

# Create deployment package
cd bin/Release/net8.0/publish
zip -r ../../../../deploy.zip .
cd ../../../../

# Deploy
aws elasticbeanstalk create-application-version \
  --application-name rfpanalyzer-api \
  --version-label v1 \
  --source-bundle S3Bucket="your-bucket",S3Key="deploy.zip"

aws elasticbeanstalk update-environment \
  --environment-name rfpanalyzer-api-prod \
  --version-label v1
```

### Step 4: Deploy Frontend to S3

```bash
cd Frontend/rfp-analyzer

# Build
npm run build

# Create S3 bucket
aws s3 mb s3://rfpanalyzer-frontend

# Upload
aws s3 sync dist/ s3://rfpanalyzer-frontend --acl public-read

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name rfpanalyzer-frontend.s3.amazonaws.com
```

---

## Docker Deployment

### Step 1: Create Dockerfiles

**Backend Dockerfile** (`Backend/RFPAnalyzer.API/Dockerfile`):

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["RFPAnalyzer.API/RFPAnalyzer.API.csproj", "RFPAnalyzer.API/"]
RUN dotnet restore "RFPAnalyzer.API/RFPAnalyzer.API.csproj"
COPY . .
WORKDIR "/src/RFPAnalyzer.API"
RUN dotnet build "RFPAnalyzer.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RFPAnalyzer.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RFPAnalyzer.API.dll"]
```

**Frontend Dockerfile** (`Frontend/rfp-analyzer/Dockerfile`):

```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Step 2: Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      ACCEPT_EULA: Y
      SA_PASSWORD: YourStrongPassword123!
    ports:
      - "1433:1433"
    volumes:
      - sqldata:/var/opt/mssql

  api:
    build:
      context: ./Backend
      dockerfile: RFPAnalyzer.API/Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=db;Database=RFPAnalyzerDB;User Id=sa;Password=YourStrongPassword123!;TrustServerCertificate=true
      - JwtSettings__SecretKey=YourProductionSecretKey32CharsMinimum!
      - Claude__ApiKey=YOUR_ANTHROPIC_API_KEY
    ports:
      - "5000:80"
    depends_on:
      - db

  frontend:
    build:
      context: ./Frontend/rfp-analyzer
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    depends_on:
      - api

volumes:
  sqldata:
```

### Step 3: Run with Docker Compose

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## IIS Deployment

### Step 1: Prepare Server

1. Install IIS
2. Install .NET 8 Hosting Bundle
3. Install URL Rewrite module

### Step 2: Publish Backend

```bash
cd Backend/RFPAnalyzer.API
dotnet publish -c Release -o C:\inetpub\wwwroot\rfpanalyzer-api
```

### Step 3: Create IIS Site

1. Open IIS Manager
2. Right-click "Sites" → "Add Website"
3. Site name: RFPAnalyzer-API
4. Physical path: C:\inetpub\wwwroot\rfpanalyzer-api
5. Binding: http, port 5000
6. Application Pool: .NET v8.0, No Managed Code

### Step 4: Configure Application Pool

1. Right-click Application Pool → Advanced Settings
2. Set "Load User Profile" to True
3. Set "Identity" to ApplicationPoolIdentity

### Step 5: Deploy Frontend

```bash
cd Frontend/rfp-analyzer
npm run build
```

Copy `dist` folder contents to `C:\inetpub\wwwroot\rfpanalyzer-frontend`

Create IIS site for frontend on port 3000.

---

## Database Setup

### Initial Migration

```bash
cd Backend/RFPAnalyzer.API
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### Production Migration

```bash
# Generate SQL script
dotnet ef migrations script -o migration.sql

# Review script and run on production database
sqlcmd -S your-server -d RFPAnalyzerDB -U your-user -P your-password -i migration.sql
```

---

## Environment Configuration

### Production appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=production-server;Database=RFPAnalyzerDB;User Id=prod-user;Password=strong-password"
  },
  "JwtSettings": {
    "SecretKey": "ProductionSecretKeyAtLeast32CharactersLong!",
    "Issuer": "RFPAnalyzerAPI",
    "Audience": "RFPAnalyzerClient"
  },
  "Claude": {
    "ApiKey": "your-production-api-key"
  }
}
```

### Environment Variables (Recommended)

```bash
# Linux/Mac
export ConnectionStrings__DefaultConnection="..."
export JwtSettings__SecretKey="..."
export Claude__ApiKey="..."

# Windows
setx ConnectionStrings__DefaultConnection "..."
setx JwtSettings__SecretKey "..."
setx Claude__ApiKey "..."
```

---

## Post-Deployment Checklist

### Security
- [ ] Changed all default passwords
- [ ] JWT secret key is strong and unique
- [ ] API keys stored securely (Key Vault/Secrets Manager)
- [ ] HTTPS enabled with valid certificate
- [ ] Database firewall rules configured
- [ ] CORS configured for production domain only

### Performance
- [ ] Database indexes added
- [ ] Application Insights or logging configured
- [ ] CDN configured for static assets
- [ ] Connection pooling enabled
- [ ] Compression enabled

### Testing
- [ ] User registration works
- [ ] User login works
- [ ] File upload works (all formats)
- [ ] Document analysis completes
- [ ] Results display correctly
- [ ] File deletion works
- [ ] Token refresh works

### Monitoring
- [ ] Application logging configured
- [ ] Error tracking enabled
- [ ] Performance monitoring active
- [ ] Database monitoring enabled
- [ ] Alerts configured

### Backup
- [ ] Database backup configured
- [ ] File storage backup configured
- [ ] Configuration backup saved
- [ ] Recovery plan documented

---

## Troubleshooting

### Common Issues

**Database Connection Fails**
```bash
# Test connection
sqlcmd -S your-server -U your-user -P your-password -Q "SELECT 1"

# Check firewall rules
# Verify connection string
# Check SQL Server is running
```

**API Not Starting**
```bash
# Check logs
dotnet RFPAnalyzer.API.dll

# Verify port is available
netstat -ano | findstr :5000

# Check permissions
```

**Frontend Can't Connect to API**
- Verify API URL in api.js
- Check CORS configuration
- Verify API is running
- Check browser console for errors

**File Upload Fails**
- Check upload directory permissions
- Verify file size limits
- Check available disk space
- Review application logs

---

## Scaling Considerations

### Horizontal Scaling
- Use load balancer
- Share storage (Azure Blob, AWS S3)
- Centralized session management
- Database connection pooling

### Performance Optimization
- Enable response caching
- Use CDN for static files
- Optimize database queries
- Implement request throttling
- Use async processing for analysis

---

## Support

For deployment issues:
1. Check application logs
2. Review error messages
3. Verify configuration
4. Contact development team

## Additional Resources

- [ASP.NET Core Deployment](https://docs.microsoft.com/aspnet/core/host-and-deploy/)
- [Azure App Service](https://docs.microsoft.com/azure/app-service/)
- [AWS Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/)
- [Docker Documentation](https://docs.docker.com/)
