const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const { initializeFirebase, testConnection, initializeCollections } = require('./config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Firebase
initializeFirebase();

// Enable compression for response optimization
app.use(compression({
  level: 6,
  threshold: 1024,
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false
}));

// Rate limiting with enhanced configuration
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
    retryAfter: 15 * 60 // 15 minutes in seconds
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  skip: (req) => {
    // Skip rate limiting for health checks
    return req.path === '/health';
  }
});
app.use('/api/', limiter);

// CORS configuration - optimized for Flutter app
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'http://localhost:3000', 
      'http://localhost:3030', // Flutter web default port
      'http://localhost:8080',
      'http://localhost:8081',
      'http://10.0.2.2:3000', // Android emulator
      'http://127.0.0.1:3000',
      'http://127.0.0.1:8080', // Flutter web localhost
      'http://127.0.0.1:3030', // Flutter web localhost
      process.env.FRONTEND_URL
    ].filter(Boolean);
    
    console.log(`🔍 CORS Check - Origin: ${origin}`);
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      console.log(`✅ CORS Allowed: ${origin}`);
      callback(null, true);
    } else {
      console.log(`❌ CORS Rejected: ${origin}`);
      callback(null, true); // Allow all for development
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  optionsSuccessStatus: 200,
  preflightContinue: false
}));

// Body parsing middleware with optimized settings
app.use(express.json({ 
  limit: '10mb',
  type: ['application/json', 'text/plain']
}));
app.use(express.urlencoded({ 
  extended: true, 
  limit: '10mb',
  parameterLimit: 1000
}));

// Request logging middleware for performance monitoring
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (duration > 1000) { // Log slow requests (>1s)
      console.log(`⚠️  Slow request: ${req.method} ${req.path} - ${duration}ms`);
    }
  });
  next();
});

// Serve static files with optimized caching
app.use('/uploads', express.static('uploads', {
  maxAge: '1d', // Cache for 1 day
  etag: true,
  lastModified: true,
  setHeaders: (res, path) => {
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
      res.setHeader('Cache-Control', 'public, max-age=86400'); // 1 day for images
    }
  }
}));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/letters', require('./routes/letters'));
app.use('/api/profile', require('./routes/profile'));
app.use('/api/assignments', require('./routes/assignments'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'BPR Absence API is running',
    timestamp: new Date().toISOString(),
    database: 'Firebase Firestore'
  });
});

// API documentation endpoint with caching
app.get('/api', (req, res) => {
  res.set('Cache-Control', 'public, max-age=3600'); // Cache for 1 hour
  res.json({
    name: 'BPR Absence Management API',
    version: '1.0.0',
    description: 'REST API for BPR Adiartha Reksacipta Absence Management System',
    database: 'Firebase Firestore',
    features: [
      'JWT Authentication',
      'Rate Limiting',
      'Request Compression',
      'Static File Caching',
      'Performance Monitoring'
    ],
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      attendance: '/api/attendance',
      admin: '/api/admin',
      dashboard: '/api/dashboard',
      letters: '/api/letters',
      profile: '/api/profile'
    },
    status: {
      server: 'running',
      database: 'connected',
      uptime: process.uptime()
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Global error handler with improved logging
app.use((err, req, res, next) => {
  const timestamp = new Date().toISOString();
  const errorId = require('uuid').v4();
  
  // Log error details
  console.error(`[${timestamp}] Error ID: ${errorId}`);
  console.error(`Request: ${req.method} ${req.path}`);
  console.error(`User: ${req.user?.userId || 'anonymous'}`);
  console.error(`Stack: ${err.stack}`);
  
  // Send appropriate response
  const statusCode = err.statusCode || 500;
  const response = {
    success: false,
    message: statusCode === 500 ? 'Internal server error' : err.message,
    errorId: errorId,
    timestamp: timestamp
  };
  
  if (process.env.NODE_ENV === 'development') {
    response.error = err.message;
    response.stack = err.stack;
  }
  
  res.status(statusCode).json(response);
});

// Start server with enhanced initialization
const startServer = async () => {
  try {
    console.log('🚀 Starting BPR Absence API Server...');
    
    // Test Firebase connection
    console.log('🔥 Testing Firebase connection...');
    await testConnection();
    console.log('✅ Firebase connection successful');
    
    // Initialize collections
    console.log('📊 Initializing database collections...');
    await initializeCollections();
    console.log('✅ Database collections initialized');
    
    // Graceful shutdown handling
    const gracefulShutdown = () => {
      console.log('\n🔄 Received shutdown signal, gracefully closing server...');
      process.exit(0);
    };
    
    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);
    
    app.listen(PORT, () => {
      console.log('\n' + '='.repeat(60));
      console.log(`🚀 BPR Absence API Server running on port ${PORT}`);
      console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🔥 Database: Firebase Firestore`);
      console.log(`🛡️  Security: Helmet, CORS, Rate Limiting enabled`);
      console.log(`⚡ Performance: Compression, Caching enabled`);
      console.log(`🔗 Health check: http://localhost:${PORT}/health`);
      console.log(`📚 API docs: http://localhost:${PORT}/api`);
      console.log('='.repeat(60));
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
