const jwt = require('jsonwebtoken');

// Cache for decoded tokens to reduce JWT verification overhead
const tokenCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

const auth = (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.',
        code: 'NO_TOKEN'
      });
    }

    const token = authHeader.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid token format.',
        code: 'INVALID_FORMAT'
      });
    }

    // Check cache first
    const cached = tokenCache.get(token);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      req.user = cached.decoded;
      return next();
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Cache the decoded token
    tokenCache.set(token, {
      decoded: decoded,
      timestamp: Date.now()
    });
    
    // Clean up expired cache entries periodically
    if (Math.random() < 0.01) { // 1% chance to trigger cleanup
      cleanupCache();
    }
    
    req.user = decoded;
    next();

  } catch (error) {
    // Remove from cache if verification fails
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (token) {
      tokenCache.delete(token);
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired',
        code: 'TOKEN_EXPIRED'
      });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token',
        code: 'INVALID_TOKEN'
      });
    } else {
      return res.status(500).json({
        success: false,
        message: 'Token verification failed',
        code: 'VERIFICATION_FAILED'
      });
    }
  }
};

// Clean up expired cache entries
const cleanupCache = () => {
  const now = Date.now();
  for (const [token, data] of tokenCache.entries()) {
    if (now - data.timestamp > CACHE_TTL) {
      tokenCache.delete(token);
    }
  }
};

module.exports = auth;
