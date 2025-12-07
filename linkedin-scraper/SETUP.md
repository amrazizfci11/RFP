# LinkedIn Scraper - Setup Guide

Complete setup instructions for the LinkedIn Post Scraper application.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Manual Setup](#manual-setup)
3. [Docker Setup](#docker-setup)
4. [Production Deployment](#production-deployment)
5. [Troubleshooting](#troubleshooting)

## Quick Start

### Prerequisites
- Node.js 18+
- MongoDB 6+
- npm or yarn

### 1. Clone and Install

```bash
# Navigate to project
cd linkedin-scraper

# Install backend dependencies
cd backend
npm install

# Install frontend dependencies
cd ../frontend
npm install
```

### 2. Configure Environment

```bash
# Backend configuration
cd backend
cp .env.example .env
# Edit .env with your settings

# Frontend configuration
cd ../frontend
cp .env.example .env
```

### 3. Start MongoDB

```bash
# Local MongoDB
mongod

# Or use MongoDB Atlas (cloud)
# Update MONGODB_URI in backend/.env
```

### 4. Run Application

```bash
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### 5. Access Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Health Check: http://localhost:5000/api/v1/health

## Manual Setup

### Step 1: Install Node.js

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18

# Windows
# Download from https://nodejs.org/
```

### Step 2: Install MongoDB

#### Ubuntu/Debian
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### macOS
```bash
brew tap mongodb/brew
brew install mongodb-community@7.0
brew services start mongodb-community@7.0
```

#### Windows
Download from https://www.mongodb.com/try/download/community

### Step 3: Configure MongoDB

```bash
# Connect to MongoDB
mongosh

# Create database and user
use linkedin-scraper
db.createUser({
  user: "scraperuser",
  pwd: "securepassword",
  roles: [{ role: "readWrite", db: "linkedin-scraper" }]
})
```

Update `backend/.env`:
```env
MONGODB_URI=mongodb://scraperuser:securepassword@localhost:27017/linkedin-scraper
```

### Step 4: Backend Configuration

Create `backend/.env`:

```env
# Server
NODE_ENV=development
PORT=5000
API_VERSION=v1

# Database
MONGODB_URI=mongodb://localhost:27017/linkedin-scraper
MONGODB_USER=scraperuser
MONGODB_PASSWORD=securepassword

# Security
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-long
JWT_EXPIRE=7d
BCRYPT_ROUNDS=12

# CORS
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Scraper
SCRAPER_TIMEOUT=60000
MAX_POSTS_PER_PROFILE=100
SCRAPER_DELAY_MIN=2000
SCRAPER_DELAY_MAX=5000
```

### Step 5: Frontend Configuration

Create `frontend/.env`:

```env
VITE_API_URL=http://localhost:5000/api/v1
VITE_APP_NAME=LinkedIn Scraper
```

### Step 6: Install Dependencies

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

### Step 7: Start Application

```bash
# Backend (Terminal 1)
cd backend
npm run dev

# Frontend (Terminal 2)
cd frontend
npm run dev
```

## Docker Setup

### Prerequisites
- Docker
- Docker Compose

### Quick Start with Docker

```bash
# Create .env file
cp .env.example .env

# Edit .env with your configuration
nano .env

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Docker Environment Variables

Create `.env` in project root:

```env
# MongoDB
MONGODB_USER=admin
MONGODB_PASSWORD=securepassword123

# Backend
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=7d
CORS_ORIGIN=http://localhost:3000

# Frontend
VITE_API_URL=http://localhost:5000/api/v1
```

### Docker Commands

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f [service-name]

# Stop services
docker-compose stop

# Remove services
docker-compose down

# Remove volumes (WARNING: deletes data)
docker-compose down -v

# Restart service
docker-compose restart [service-name]

# Access MongoDB shell
docker-compose exec mongodb mongosh -u admin -p securepassword123

# Access backend container
docker-compose exec backend sh

# View service status
docker-compose ps
```

## Production Deployment

### 1. Prepare Environment

```bash
# Update environment
NODE_ENV=production

# Generate strong secrets
JWT_SECRET=$(openssl rand -base64 64)
SESSION_SECRET=$(openssl rand -base64 64)

# Update CORS
CORS_ORIGIN=https://yourdomain.com
```

### 2. Build Frontend

```bash
cd frontend
npm run build
# Serve dist/ folder with nginx or similar
```

### 3. Process Manager (PM2)

```bash
# Install PM2
npm install -g pm2

# Start backend
cd backend
pm2 start src/server.js --name linkedin-scraper-api

# Save PM2 config
pm2 save

# Setup startup script
pm2 startup
```

### 4. Nginx Configuration

```nginx
# /etc/nginx/sites-available/linkedin-scraper
server {
    listen 80;
    server_name yourdomain.com;

    # Frontend
    location / {
        root /var/www/linkedin-scraper/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5. SSL with Let's Encrypt

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo certbot renew --dry-run
```

### 6. Firewall Configuration

```bash
# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow MongoDB (only from localhost)
sudo ufw deny 27017/tcp

# Enable firewall
sudo ufw enable
```

### 7. MongoDB Security

```bash
# Enable authentication
sudo nano /etc/mongod.conf

# Add:
security:
  authorization: enabled

# Restart MongoDB
sudo systemctl restart mongod
```

## Troubleshooting

### Backend Issues

#### Port Already in Use
```bash
# Find process
lsof -i :5000

# Kill process
kill -9 <PID>
```

#### MongoDB Connection Failed
```bash
# Check MongoDB status
sudo systemctl status mongod

# Check MongoDB logs
tail -f /var/log/mongodb/mongod.log

# Restart MongoDB
sudo systemctl restart mongod
```

#### Puppeteer/Chromium Issues
```bash
# Install dependencies (Ubuntu)
sudo apt-get install -y \
  gconf-service libasound2 libatk1.0-0 libc6 libcairo2 \
  libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 \
  libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 \
  libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
  libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
  libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 \
  libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation \
  libappindicator1 libnss3 lsb-release xdg-utils wget chromium-browser
```

### Frontend Issues

#### Build Errors
```bash
# Clear cache
rm -rf node_modules package-lock.json
npm install

# Clear Vite cache
rm -rf node_modules/.vite
```

#### CORS Errors
- Verify CORS_ORIGIN in backend `.env`
- Check both servers are running
- Clear browser cache
- Check browser console for details

### Docker Issues

#### Container Won't Start
```bash
# Check logs
docker-compose logs [service-name]

# Check container status
docker-compose ps

# Rebuild container
docker-compose build --no-cache [service-name]
docker-compose up -d [service-name]
```

#### MongoDB Connection in Docker
```bash
# Access MongoDB from backend
# Use hostname: mongodb (not localhost)
MONGODB_URI=mongodb://admin:password@mongodb:27017/linkedin-scraper
```

### General Issues

#### Clear Application Data
```bash
# Clear browser localStorage
# Open browser console:
localStorage.clear()

# Reset MongoDB database
mongosh
use linkedin-scraper
db.dropDatabase()
```

#### Check Application Health
```bash
# Backend health
curl http://localhost:5000/api/v1/health

# Check logs
tail -f backend/logs/combined.log
```

## Next Steps

1. Create your first user account
2. Initialize the LinkedIn scraper
3. Scrape your first profile
4. Explore the dashboard and posts

For more information, see:
- [README.md](README.md) - Overview and features
- [SECURITY.md](SECURITY.md) - Security guidelines
- API documentation at http://localhost:5000/api/v1

## Support

For issues:
1. Check this guide
2. Review error logs
3. Check GitHub issues
4. Create new issue with details

---

**Happy Scraping! 🚀**
