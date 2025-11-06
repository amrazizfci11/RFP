# RFP Analyzer System

An intelligent RFP (Request for Proposal) document analysis system powered by Claude AI. Upload RFP documents and get automated analysis of project requirements, resources, timelines, and implementation boundaries.

## Features

- **User Authentication**: Secure JWT-based authentication with sign up/sign in
- **Multi-User Support**: Each user has their own document library
- **Document Upload**: Upload up to 10 documents per user (PDF, Word formats)
- **AI-Powered Analysis**: Automatic analysis using Claude Sonnet API
- **Structured Extraction**: Extracts key information including:
  - Project Name
  - Project Duration
  - Human Resources Hierarchy
  - Project Stages
  - Special Conditions
  - Implementation Boundaries (ITIL, governance, cybersecurity)
- **Real-time Updates**: Automatic background processing of documents
- **Modern UI**: Clean, responsive React interface

## Technology Stack

### Backend
- **ASP.NET Core 8** - Web API framework
- **Entity Framework Core** - ORM for database operations
- **SQL Server** - Database
- **JWT Bearer Authentication** - Secure token-based auth
- **Anthropic Claude SDK** - AI document analysis
- **DocumentFormat.OpenXml** - Word document processing
- **iTextSharp** - PDF text extraction

### Frontend
- **React 18** - UI framework
- **Vite** - Build tool and dev server
- **React Router** - Client-side routing
- **Axios** - HTTP client
- **Modern CSS** - Custom responsive styling

## Project Structure

```
RFP/
├── Backend/
│   ├── RFPAnalyzer.API/
│   │   ├── Controllers/        # API endpoints
│   │   ├── Models/            # Database models
│   │   ├── DTOs/              # Data transfer objects
│   │   ├── Services/          # Business logic
│   │   ├── Data/              # Database context
│   │   ├── Program.cs         # Application entry point
│   │   └── appsettings.json   # Configuration
│   └── RFPAnalyzer.sln        # Solution file
│
├── Frontend/
│   └── rfp-analyzer/
│       ├── src/
│       │   ├── components/    # React components
│       │   ├── pages/         # Page components
│       │   ├── contexts/      # React contexts
│       │   ├── services/      # API services
│       │   └── styles/        # CSS files
│       ├── index.html
│       ├── vite.config.js
│       └── package.json
│
└── README.md
```

## Prerequisites

- **.NET 8 SDK**: [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Node.js 18+**: [Download](https://nodejs.org/)
- **SQL Server**: [Download](https://www.microsoft.com/sql-server/sql-server-downloads) or use LocalDB
- **Anthropic API Key**: [Get API Key](https://console.anthropic.com/)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd RFP
```

### 2. Backend Setup

#### Configure Database Connection

Edit `Backend/RFPAnalyzer.API/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=RFPAnalyzerDB;Trusted_Connection=true;MultipleActiveResultSets=true;TrustServerCertificate=true"
  }
}
```

For production, use a proper SQL Server connection string:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=your-server;Database=RFPAnalyzerDB;User Id=your-user;Password=your-password;TrustServerCertificate=true"
  }
}
```

#### Configure Claude API Key

Edit `Backend/RFPAnalyzer.API/appsettings.json`:

```json
{
  "Claude": {
    "ApiKey": "YOUR_ANTHROPIC_API_KEY_HERE"
  }
}
```

**IMPORTANT**: Never commit your actual API key to version control!

#### Configure JWT Secret

Edit `Backend/RFPAnalyzer.API/appsettings.json`:

```json
{
  "JwtSettings": {
    "SecretKey": "YourSuperSecretKeyThatIsAtLeast32CharactersLong!ChangeThisInProduction",
    "Issuer": "RFPAnalyzerAPI",
    "Audience": "RFPAnalyzerClient"
  }
}
```

**IMPORTANT**: Change the SecretKey to a strong random string in production!

#### Install Dependencies and Run

```bash
cd Backend/RFPAnalyzer.API
dotnet restore
dotnet ef database update    # Create database and run migrations
dotnet run                   # Start the API (default: https://localhost:5001)
```

The API will be available at:
- HTTPS: `https://localhost:5001`
- HTTP: `http://localhost:5000`
- Swagger UI: `https://localhost:5001/swagger`

### 3. Frontend Setup

```bash
cd Frontend/rfp-analyzer
npm install
npm run dev
```

The React app will be available at `http://localhost:3000`

## Usage

1. **Register an Account**
   - Navigate to `http://localhost:3000`
   - Click "Sign Up"
   - Enter your email and password
   - Password requirements: minimum 8 characters, uppercase, lowercase, digit, and special character

2. **Upload Documents**
   - After logging in, you'll see the dashboard
   - Click "Choose File" to select a PDF or Word document
   - Click "Upload & Analyze"
   - The document will be uploaded and analyzed automatically in the background

3. **View Analysis Results**
   - Click on any document in the left sidebar
   - View the extracted information:
     - Project Name
     - Project Duration
     - Human Resources Hierarchy
     - Project Stages
     - Special Conditions
     - Implementation Boundaries
   - Scroll down to see the full raw analysis

4. **Manage Documents**
   - You can upload up to 10 documents
   - Click the × button on any document to delete it
   - Analysis happens automatically in the background

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Documents
- `GET /api/documents` - Get all user documents
- `GET /api/documents/{id}` - Get specific document with analysis
- `POST /api/documents/upload` - Upload new document
- `DELETE /api/documents/{id}` - Delete document

## Configuration Options

### Backend Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Your database connection string"
  },
  "JwtSettings": {
    "SecretKey": "Your JWT secret key (min 32 chars)",
    "Issuer": "RFPAnalyzerAPI",
    "Audience": "RFPAnalyzerClient"
  },
  "Claude": {
    "ApiKey": "Your Anthropic API key"
  }
}
```

### Frontend Configuration

Update API base URL in `Frontend/rfp-analyzer/src/services/api.js` if needed:

```javascript
const api = axios.create({
  baseURL: 'http://localhost:5000',  // Change for production
  headers: {
    'Content-Type': 'application/json'
  }
})
```

## Security Considerations

1. **Never commit sensitive data** to version control:
   - API keys
   - Database passwords
   - JWT secret keys

2. **Use environment variables** in production:
   - Backend: Use Azure Key Vault, AWS Secrets Manager, or environment variables
   - Frontend: Use `.env` files (not committed to git)

3. **HTTPS in production**: Always use HTTPS for production deployments

4. **Strong passwords**: Enforce strong password requirements for users

5. **Rate limiting**: Consider adding rate limiting for API endpoints

## Troubleshooting

### Database Issues

If migrations fail:
```bash
cd Backend/RFPAnalyzer.API
dotnet ef database drop      # Drop existing database
dotnet ef migrations remove  # Remove migrations
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### CORS Issues

If the frontend can't connect to the backend, check CORS settings in `Program.cs`:
```csharp
policy.WithOrigins("http://localhost:3000", "http://localhost:5173")
```

### Claude API Errors

- Verify your API key is correct
- Check your API usage limits
- Ensure you have sufficient credits

### File Upload Issues

- Check file size limits (default: 50MB)
- Verify upload directory permissions
- Ensure supported file types (.pdf, .doc, .docx)

## Performance Optimization

1. **Document Processing**: Analysis happens in background threads
2. **Database Indexing**: Add indexes to frequently queried fields
3. **Caching**: Consider adding Redis for session/token caching
4. **File Storage**: Use cloud storage (Azure Blob, AWS S3) for production

## Future Enhancements

- [ ] Batch document upload
- [ ] Export analysis results to Excel/PDF
- [ ] Document comparison features
- [ ] Custom analysis prompts
- [ ] Email notifications when analysis completes
- [ ] Admin dashboard for user management
- [ ] Document versioning
- [ ] Collaboration features

## License

This project is proprietary and confidential.

## Support

For issues and questions, please contact the development team.
