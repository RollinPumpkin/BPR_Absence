const jwt = require('jsonwebtoken');
const { getAuth } = require('../config/database');

// Cache for decoded tokens to reduce verification overhead
const tokenCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

const auth = (req, res, next) => {
  try {
    console.log('🔍 Auth middleware called for:', req.method, req.path);
    const authHeader = req.header('Authorization');
    console.log('🔑 Authorization header:', authHeader ? 'Present' : 'Missing');
    
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

    // Try Firebase ID token verification first
    verifyFirebaseToken(token)
      .then(decoded => {
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
      })
      .catch(firebaseError => {
        // Fallback to JWT verification for existing tokens
        try {
          const decoded = jwt.verify(token, process.env.JWT_SECRET);
          console.log('✅ JWT verification successful:', JSON.stringify(decoded, null, 2));
          
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
        } catch (jwtError) {
          console.log('❌ Token verification failed:', {
            firebase: firebaseError.message,
            jwt: jwtError.message
          });
          
          return res.status(401).json({
            success: false,
            message: 'Access denied. Invalid token.',
            code: 'INVALID_TOKEN'
          });
        }
      });
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during authentication.',
      code: 'SERVER_ERROR'
    });
  }
};

// Verify Firebase ID token
async function verifyFirebaseToken(token) {
  const auth = getAuth();
  const { getFirestore } = require('../config/database');
  const db = getFirestore();
  
  try {
    const decodedToken = await auth.verifyIdToken(token);
    
    // Fetch user data from Firestore to get role and other info
    const usersRef = db.collection('users');
    const userQuery = await usersRef.where('firebase_uid', '==', decodedToken.uid).get();
    
    let userRole = null;
    let employeeId = null;
    let userId = decodedToken.uid;
    
    if (!userQuery.empty) {
      const userDoc = userQuery.docs[0];
      const userData = userDoc.data();
      userRole = userData.role;
      employeeId = userData.employee_id;
      userId = userDoc.id; // Use Firestore document ID
    } else {
      // If not found by firebase_uid, try by email
      const emailQuery = await usersRef.where('email', '==', decodedToken.email).get();
      if (!emailQuery.empty) {
        const userDoc = emailQuery.docs[0];
        const userData = userDoc.data();
        userRole = userData.role;
        employeeId = userData.employee_id;
        userId = userDoc.id;
      }
    }
    
    // Transform Firebase token to match expected format
    return {
      id: userId,
      userId: userId,
      firebase_uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name || decodedToken.email,
      role: userRole, // Now includes role from Firestore
      employeeId: employeeId, // Now includes employee_id from Firestore
      iat: decodedToken.iat,
      exp: decodedToken.exp,
    };
  } catch (error) {
    throw new Error(`Firebase token verification failed: ${error.message}`);
  }
}

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
