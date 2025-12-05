require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const {
  initializeFirebase,
  testConnection,
  initializeCollections,
  getFirestore
} = require('./config/database');

const app = express();
const PORT = process.env.PORT || 3000;

// ======================================================
//  STARTUP LOGS
// ======================================================
console.log('🔥 Starting Firebase NPM Server...');
console.log('📡 Server will run on port:', PORT);

// ======================================================
//  FIREBASE INIT
// ======================================================
initializeFirebase();

// ======================================================
//  COMPRESSION CONTROL
//  Disable compression specifically for /api/*
// ======================================================
app.use((req, res, next) => {
  if (req.path && req.path.startsWith('/api/')) {
    delete req.headers['accept-encoding'];
    res.set('Content-Encoding', 'identity');
    console.log('🚫 Compression disabled for:', req.path);
  }
  next();
});

// ======================================================
//  REQUEST LOGGING MIDDLEWARE
// ======================================================
app.use((req, res, next) => {
  const startTime = Date.now();
  const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress;
  
  console.log(`📥 ${req.method} ${req.path} from ${clientIP}`);
  
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    console.log(`📤 ${req.method} ${req.path} → ${res.statusCode} (${duration}ms)`);
  });
  
  next();
});

// Compression enabled only for NON-API routes
app.use(
  compression({
    level: 6,
    threshold: 1024,
    filter: (req, res) => {
      if (req.path && req.path.startsWith('/api/')) {
        return false;
      }
      return compression.filter(req, res);
    },
  })
);

// ======================================================
//  SECURITY HEADERS
// ======================================================
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
    crossOriginEmbedderPolicy: false,
  })
);

// ======================================================
//  RATE LIMITING (skip /health)
// ======================================================
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    success: false,
    message: 'Too many requests. Try again later.',
  },
  skip: (req) => req.path === '/health',
});
app.use('/api/', limiter);

// ======================================================
//  CORS
// ======================================================
app.use(
  cors({
    origin: function (origin, callback) {
      if (!origin) return callback(null, true);

      const allowed = [
        'http://localhost:3000',
        'http://localhost:3030',
        'http://localhost:8080',
        'http://localhost:8081',
        'http://10.0.2.2:3000', // Android emulator
        'http://127.0.0.1:3000',
        'http://127.0.0.1:3030',
        process.env.FRONTEND_URL,
        'https://khatulistiwareklame.com',
        'https://www.khatulistiwareklame.com',
        'https://api.khatulistiwareklame.com',
      ].filter(Boolean);

      console.log(`🔍 CORS Check: ${origin}`);

      // Allow all origins in development mode for mobile testing
      if (process.env.NODE_ENV === 'development') {
        console.log(`✅ CORS Allowed (Development Mode): ${origin || 'no-origin'}`);
        callback(null, true);
      } else if (allowed.includes(origin)) {
        console.log(`✅ CORS Allowed: ${origin}`);
        callback(null, true);
      } else {
        console.log(`❌ CORS Rejected: ${origin}`);
        // IMPORTANT: In production, reject unknown origins for security!
        const error = new Error(`CORS policy: Origin ${origin} not allowed`);
        callback(error);
      }
    },
    credentials: true,
  })
);

// ======================================================
//  BODY PARSER
// ======================================================
app.use(
  express.json({
    limit: '10mb',
    type: ['application/json', 'text/plain'],
  })
);
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ======================================================
//  STATIC FILES
// ======================================================
app.use(
  '/uploads',
  express.static('uploads', {
    maxAge: '1d',
  })
);

// Serve Flutter Web App (from frontend/build/web)
app.use(express.static(path.join(__dirname, '..', 'frontend', 'build', 'web')));

// Serve public folder for mobile test page (from parent directory)
app.use(express.static(path.join(__dirname, '..', 'public')));

// ======================================================
//  ROUTES
// ======================================================
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/letters', require('./routes/letters'));
app.use('/api/profile', require('./routes/profile'));
app.use('/api/assignments', require('./routes/assignments'));
app.use('/api/shifts', require('./routes/shifts')); // Shift roster management
app.use('/api/seeder', require('./routes/seeder'));

// ======================================================
//  HEALTH CHECK
// ======================================================
app.get('/health', (req, res) => {
  const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log(`🏥 Health check from: ${clientIP}`);
  
  res.json({
    status: 'OK',
    message: 'BPR Absence API running',
    time: new Date().toISOString(),
    clientIP: clientIP,
    serverIP: req.socket.localAddress,
  });
});

// Mobile connectivity test endpoint
app.get('/api/test/mobile', (req, res) => {
  const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log(`📱 Mobile test from: ${clientIP}`);
  
  res.json({
    success: true,
    message: 'Mobile connection successful!',
    clientIP: clientIP,
    serverIP: req.socket.localAddress,
    timestamp: new Date().toISOString(),
    headers: req.headers,
  });
});

// ======================================================
//  DEBUG TOKEN
// ======================================================
app.get('/api/debug/token', (req, res) => {
  const jwt = require('jsonwebtoken');

  const header = req.header('Authorization');
  if (!header) {
    return res.json({ success: false, message: 'No Authorization header' });
  }

  const token = header.replace('Bearer ', '');
  const decodedUnsafe = jwt.decode(token);

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    return res.json({
      success: true,
      message: 'Token OK',
      decoded: verified,
      unsafe: decodedUnsafe,
    });
  } catch (err) {
    return res.json({
      success: false,
      message: 'JWT invalid',
      error: err.message,
      unsafe: decodedUnsafe,
    });
  }
});

// ======================================================
//  404
// ======================================================
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
  });
});

// ======================================================
//  GLOBAL ERROR HANDLER
// ======================================================
app.use((err, req, res, next) => {
  const errorId = uuidv4();
  console.error('❌ Error ID:', errorId);
  console.error(err.stack);

  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    errorId,
  });
});

// ======================================================
//  START SERVER
// ======================================================
const startServer = async () => {
  try {
    console.log('🔥 Testing Firebase connection...');
    await testConnection();
    console.log('✅ Firebase OK');

    console.log('📁 Initializing collections...');
    await initializeCollections();
    console.log('✅ Collections initialized');

    app.listen(PORT, '0.0.0.0', () => {
      console.log('='.repeat(60));
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📝 Environment: ${process.env.NODE_ENV}`);
      console.log(`🔥 Database: Firebase Firestore`);
      console.log(`🌐 Local: http://localhost:${PORT}`);
      console.log(`🌐 Network: http://192.168.x.x:${PORT}`);
      console.log('='.repeat(60));
    });
  } catch (e) {
    console.error('❌ Server failed to start:', e);
    process.exit(1);
  }
};

startServer();
