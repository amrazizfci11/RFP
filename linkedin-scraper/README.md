# LinkedIn Post Scraper

A secure, full-stack application for scraping LinkedIn posts and storing them in MongoDB with a beautiful React interface.

## 🚀 Features

- **Secure Authentication**: JWT-based user authentication with bcrypt password hashing
- **LinkedIn Scraping**: Automated scraping of LinkedIn posts using Puppeteer
- **MongoDB Storage**: Persistent storage of posts with efficient indexing
- **React Dashboard**: Modern, responsive UI for viewing and managing posts
- **Security First**: Implements OWASP best practices including:
  - Rate limiting
  - XSS protection
  - NoSQL injection prevention
  - HTTP Parameter Pollution prevention
  - Content Security Policy headers
  - Input validation and sanitization
  - Helmet security headers
  - CORS configuration

## 📋 Prerequisites

- Node.js (v18 or higher)
- MongoDB (v6 or higher)
- npm or yarn
- A LinkedIn account for scraping

## 🛠️ Installation

### 1. Clone the repository

```bash
cd linkedin-scraper
```

### 2. Backend Setup

```bash
cd backend
npm install

# Copy environment file and configure
cp .env.example .env
# Edit .env with your MongoDB URI and other settings
```

### 3. Frontend Setup

```bash
cd ../frontend
npm install

# Copy environment file
cp .env.example .env
```

### 4. MongoDB Setup

Make sure MongoDB is running:

```bash
# If using local MongoDB
mongod

# Or use MongoDB Atlas cloud database
# Update MONGODB_URI in backend/.env accordingly
```

## 🔧 Configuration

### Backend Environment Variables (`backend/.env`)

```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/linkedin-scraper
JWT_SECRET=your-super-secret-jwt-key-change-this
CORS_ORIGIN=http://localhost:3000
```

### Frontend Environment Variables (`frontend/.env`)

```env
VITE_API_URL=http://localhost:5000/api/v1
```

## 🚀 Running the Application

### Start Backend

```bash
cd backend
npm start

# Or for development with auto-reload
npm run dev
```

The API will be available at `http://localhost:5000`

### Start Frontend

```bash
cd frontend
npm run dev
```

The React app will be available at `http://localhost:3000`

## 📖 Usage

### 1. Register/Login

- Navigate to `http://localhost:3000`
- Create a new account or login
- Password must contain uppercase, lowercase, number, and special character

### 2. Initialize Scraper

- Go to the **Scraper** page
- Enter your LinkedIn credentials
- Click "Login to LinkedIn"

### 3. Scrape Posts

- Enter a LinkedIn profile URL (e.g., `https://www.linkedin.com/in/username`)
- Choose the number of posts to scrape (1-100)
- Click "Start Scraping"
- Wait for the scraper to complete

### 4. View Posts

- Navigate to **Posts** page to see all scraped posts
- Filter by profile URL
- View post details, engagement metrics, and hashtags
- Click "View on LinkedIn" to see the original post

## 🏗️ Project Structure

```
linkedin-scraper/
├── backend/
│   ├── src/
│   │   ├── config/         # Database configuration
│   │   ├── controllers/    # Route controllers
│   │   ├── middleware/     # Auth, validation, security middleware
│   │   ├── models/         # MongoDB models
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic (scraper)
│   │   ├── utils/          # Utilities (logger)
│   │   └── server.js       # Express server
│   ├── logs/               # Application logs
│   ├── .env.example        # Environment template
│   └── package.json
│
├── frontend/
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── context/        # React context (Auth)
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   ├── App.jsx         # Main app component
│   │   └── main.jsx        # Entry point
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
└── README.md
```

## 🔒 Security Features

### Backend Security

1. **Authentication & Authorization**
   - JWT tokens with expiration
   - Bcrypt password hashing (12 rounds)
   - Account lockout after failed attempts
   - Role-based access control

2. **Input Validation**
   - express-validator for all inputs
   - MongoDB sanitization
   - XSS cleaning
   - HTTP Parameter Pollution prevention

3. **Rate Limiting**
   - Standard: 100 requests per 15 minutes
   - Strict (auth): 5 requests per 15 minutes
   - Scraper: 10 requests per hour

4. **Security Headers**
   - Helmet.js for security headers
   - Content Security Policy
   - HSTS (HTTP Strict Transport Security)
   - X-Content-Type-Options
   - X-Frame-Options

5. **CORS**
   - Configurable allowed origins
   - Credentials support
   - Method whitelisting

### Frontend Security

1. **Input Sanitization**
   - DOMPurify for XSS prevention
   - Input validation on forms
   - Pattern matching for URLs

2. **Content Security Policy**
   - Strict CSP headers
   - No inline scripts (except Vite dev)
   - Limited external resources

3. **Authentication**
   - Token stored in localStorage
   - Automatic token refresh
   - Auto-logout on 401

## 📊 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/auth/logout` - Logout user

### Scraper
- `POST /api/v1/scraper/login` - Initialize scraper
- `POST /api/v1/scraper/scrape` - Scrape posts
- `POST /api/v1/scraper/logout` - Close scraper
- `GET /api/v1/scraper/status` - Get scraper status

### Posts
- `GET /api/v1/scraper/posts` - Get all posts (paginated)
- `GET /api/v1/scraper/posts/profile` - Get posts by profile
- `GET /api/v1/scraper/posts/:id` - Get single post
- `DELETE /api/v1/scraper/posts/:id` - Delete post (admin only)

### Health
- `GET /api/v1/health` - Health check

## 🐛 Troubleshooting

### Puppeteer Issues

If Puppeteer fails to launch:

```bash
# Install required dependencies (Linux)
sudo apt-get install -y chromium-browser

# Or install Chromium manually
npx puppeteer install
```

### MongoDB Connection

If MongoDB connection fails:

- Check MongoDB is running: `sudo systemctl status mongod`
- Verify MONGODB_URI in `.env`
- Check MongoDB logs: `tail -f /var/log/mongodb/mongod.log`

### CORS Errors

- Ensure CORS_ORIGIN in backend `.env` matches frontend URL
- Check both servers are running
- Clear browser cache

## ⚠️ Important Notes

1. **LinkedIn Terms of Service**: Be aware of LinkedIn's terms of service and rate limits
2. **Credentials**: Never commit `.env` files to version control
3. **Rate Limiting**: Respect LinkedIn's rate limits to avoid account restrictions
4. **Production**: Use environment-specific configurations in production
5. **HTTPS**: Always use HTTPS in production environments

## 🔐 OWASP Compliance

This application implements the following OWASP Top 10 protections:

1. ✅ **Broken Access Control**: JWT authentication, role-based authorization
2. ✅ **Cryptographic Failures**: Bcrypt hashing, secure token generation
3. ✅ **Injection**: MongoDB sanitization, parameterized queries, input validation
4. ✅ **Insecure Design**: Security by design, rate limiting, validation
5. ✅ **Security Misconfiguration**: Helmet headers, CSP, secure defaults
6. ✅ **Vulnerable Components**: Regular dependency updates, security audits
7. ✅ **Authentication Failures**: Account lockout, strong password policy
8. ✅ **Data Integrity Failures**: Input validation, sanitization
9. ✅ **Logging Failures**: Winston logging, error tracking
10. ✅ **SSRF**: URL validation, whitelist approach

## 📝 License

MIT License - feel free to use this project for learning and development.

## 🤝 Contributing

Contributions are welcome! Please ensure:

- Code follows existing style
- Security best practices are maintained
- All tests pass
- Documentation is updated

## 📧 Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review error logs in `backend/logs/`

---

**Built with security, modularity, and best practices in mind** 🔒
