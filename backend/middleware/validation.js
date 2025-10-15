const Joi = require('joi');

// Validation schemas
const registerSchema = Joi.object({
  employee_id: Joi.string().required().min(3).max(20),
  full_name: Joi.string().required().min(2).max(100),
  email: Joi.string().email().required(),
  password: Joi.string().required().min(6),
  department: Joi.string().max(50),
  position: Joi.string().max(50),
  phone: Joi.string().max(20),
  role: Joi.string().valid('employee', 'account_officer', 'security', 'office_boy', 'admin').default('employee'),
  
  // Personal Information (optional)
  place_of_birth: Joi.string().max(100).allow(''),
  date_of_birth: Joi.date().iso().allow(null),
  gender: Joi.string().valid('Male', 'Female', 'male', 'female', '').allow(''),
  nik: Joi.string().max(20).allow(''),
  
  // Employment (optional)
  division: Joi.string().max(50).allow(''),
  contract_type: Joi.string().valid('3 Months', '6 Months', '1 Year', '').allow(''),
  last_education: Joi.string().valid('High School', 'Diploma', 'Bachelor', 'Master', '').allow(''),
  
  // Banking (optional)
  bank: Joi.string().valid('BCA', 'BRI', 'Mandiri', 'BNI', '').allow(''),
  account_holder_name: Joi.string().max(100).allow(''),
  account_number: Joi.string().max(30).allow(''),
  
  // Other (optional)
  warning_letter_type: Joi.string().valid('SP1', 'SP2', 'SP3', 'None', '').default('None')
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

const attendanceSchema = Joi.object({
  qr_code: Joi.string().required(),
  location: Joi.string().required().max(255),
  notes: Joi.string().max(500).allow('')
});

const letterSchema = Joi.object({
  recipient_id: Joi.string().required(),
  subject: Joi.string().required().min(5).max(200),
  content: Joi.string().required().min(10),
  letter_type: Joi.string().required().valid('warning', 'promotion', 'transfer', 'termination', 'appreciation', 'memo', 'announcement', 'other'),
  letter_number: Joi.string().max(50).allow(''),
  letter_date: Joi.date().iso().allow(null),
  priority: Joi.string().valid('low', 'normal', 'high', 'urgent').default('normal'),
  requires_response: Joi.boolean().default(false),
  response_deadline: Joi.date().iso().allow(null),
  attachments: Joi.array().items(Joi.object({
    filename: Joi.string().required(),
    file_url: Joi.string().required(),
    file_size: Joi.number(),
    file_type: Joi.string()
  })).default([]),
  cc_recipients: Joi.array().items(Joi.string()).default([]),
  template_used: Joi.string().allow(null),
  reference_number: Joi.string().max(50).allow('')
});

const profileSchema = Joi.object({
  full_name: Joi.string().min(2).max(100),
  phone: Joi.string().max(20).allow(''),
  address: Joi.string().max(255).allow(''),
  emergency_contact: Joi.string().max(100).allow(''),
  emergency_phone: Joi.string().max(20).allow(''),
  date_of_birth: Joi.date().iso().allow(null),
  gender: Joi.string().valid('Male', 'Female', 'male', 'female', '').allow(''),
  marital_status: Joi.string().valid('Single', 'Married', 'Divorced', 'Widowed', '').allow(''),
  national_id: Joi.string().max(20).allow(''),
  bank_account: Joi.string().max(30).allow(''),
  bank_name: Joi.string().max(50).allow(''),
  
  // Admin-only fields
  email: Joi.string().email(),
  employee_id: Joi.string().min(3).max(20),
  position: Joi.string().max(50).allow(''),
  department: Joi.string().max(50).allow(''),
  hire_date: Joi.date().iso().allow(null),
  salary: Joi.number().min(0).allow(null),
  status: Joi.string().valid('active', 'inactive', 'suspended', 'terminated').allow(''),
  role: Joi.string().valid('employee', 'account_officer', 'security', 'office_boy', 'admin').allow('')
});

const passwordChangeSchema = Joi.object({
  current_password: Joi.string().required(),
  new_password: Joi.string().required().min(6).max(50),
  confirm_password: Joi.string().required().valid(Joi.ref('new_password')).messages({
    'any.only': 'Confirm password must match new password'
  })
});

// ===================== ADMIN VALIDATIONS =====================

// Assignment validations
const assignmentSchema = Joi.object({
  title: Joi.string().required().min(5).max(200),
  description: Joi.string().required().min(10).max(2000),
  assignedTo: Joi.array().items(Joi.string()).min(1).required(),
  dueDate: Joi.date().iso().min('now').required(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
  category: Joi.string().max(50).allow(''),
  tags: Joi.array().items(Joi.string()).default([]),
  attachments: Joi.array().items(Joi.object({
    filename: Joi.string().required(),
    file_url: Joi.string().required(),
    file_size: Joi.number(),
    file_type: Joi.string()
  })).default([])
});

const assignmentUpdateSchema = Joi.object({
  title: Joi.string().min(5).max(200),
  description: Joi.string().min(10).max(2000),
  dueDate: Joi.date().iso(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent'),
  status: Joi.string().valid('pending', 'in-progress', 'completed', 'on-hold'),
  progress: Joi.number().min(0).max(100),
  category: Joi.string().max(50).allow(''),
  tags: Joi.array().items(Joi.string())
});

const commentSchema = Joi.object({
  comment: Joi.string().required().min(1).max(1000)
});

// Employee management validations
const createEmployeeSchema = Joi.object({
  full_name: Joi.string().required().min(2).max(100).pattern(/^[a-zA-Z\s'-]+$/),
  email: Joi.string().email().required(),
  employee_id: Joi.string().required().pattern(/^[A-Z]{2,3}\d{3,4}$/),
  role: Joi.string().valid('employee', 'admin', 'super_admin', 'account_officer', 'manager').required(),
  department: Joi.string().required().min(2).max(100),
  position: Joi.string().required().min(2).max(100),
  phone: Joi.string().pattern(/^(\+\d{1,3}[- ]?)?\d{10,15}$/).allow(''),
  hire_date: Joi.date().iso().allow(null),
  salary: Joi.number().min(0).allow(null),
  manager_id: Joi.string().allow(''),
  emergency_contact: Joi.object({
    name: Joi.string().max(100),
    phone: Joi.string().pattern(/^(\+\d{1,3}[- ]?)?\d{10,15}$/),
    relationship: Joi.string().max(50)
  }).allow(null)
});

const updateEmployeeSchema = Joi.object({
  full_name: Joi.string().min(2).max(100),
  email: Joi.string().email(),
  role: Joi.string().valid('employee', 'admin', 'super_admin', 'account_officer', 'manager'),
  department: Joi.string().min(2).max(100),
  position: Joi.string().min(2).max(100),
  phone: Joi.string().pattern(/^(\+\d{1,3}[- ]?)?\d{10,15}$/).allow(''),
  salary: Joi.number().min(0),
  status: Joi.string().valid('active', 'inactive', 'terminated', 'resigned'),
  manager_id: Joi.string().allow(''),
  emergency_contact: Joi.object({
    name: Joi.string().max(100),
    phone: Joi.string().pattern(/^(\+\d{1,3}[- ]?)?\d{10,15}$/),
    relationship: Joi.string().max(50)
  }).allow(null)
});

const employeeStatusSchema = Joi.object({
  status: Joi.string().valid('active', 'inactive', 'terminated', 'resigned').required(),
  reason: Joi.string().min(5).max(500).allow('')
});

const bulkImportSchema = Joi.object({
  employees: Joi.array().items(
    Joi.object({
      full_name: Joi.string().required().min(2).max(100),
      email: Joi.string().email().required(),
      employee_id: Joi.string().required().pattern(/^[A-Z]{2,3}\d{3,4}$/),
      department: Joi.string().required().min(2).max(100),
      position: Joi.string().required().min(2).max(100),
      role: Joi.string().valid('employee', 'admin', 'super_admin', 'account_officer', 'manager').default('employee'),
      phone: Joi.string().pattern(/^(\+\d{1,3}[- ]?)?\d{10,15}$/).allow(''),
      hire_date: Joi.date().iso().allow(null),
      salary: Joi.number().min(0).allow(null)
    })
  ).min(1).max(100).required()
});

const resetPasswordSchema = Joi.object({
  new_password: Joi.string()
    .min(8)
    .max(128)
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .allow('')
    .messages({
      'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
    })
});

// Attendance admin validations
const leaveRequestSchema = Joi.object({
  leave_type: Joi.string().valid('sick', 'annual', 'personal', 'emergency', 'maternity', 'paternity').required(),
  start_date: Joi.date().iso().min('now').required(),
  end_date: Joi.date().iso().min(Joi.ref('start_date')).required(),
  reason: Joi.string().required().min(10).max(1000)
});

const bulkAttendanceUpdateSchema = Joi.object({
  updates: Joi.array().items(
    Joi.object({
      user_id: Joi.string().required(),
      date: Joi.date().iso().required(),
      status: Joi.string().valid('present', 'absent', 'late', 'sick', 'leave').required(),
      reason: Joi.string().max(255).allow('')
    })
  ).min(1).required()
});

// Letter admin validations
const bulkLetterActionSchema = Joi.object({
  letter_ids: Joi.array().items(Joi.string()).min(1).required(),
  action: Joi.string().valid('approve', 'reject', 'delete').required(),
  reason: Joi.string().min(5).max(500).allow('')
});

const letterTemplateSchema = Joi.object({
  name: Joi.string().required().min(3).max(100),
  letter_type: Joi.string().required().valid('warning', 'promotion', 'transfer', 'termination', 'appreciation', 'memo', 'announcement', 'other'),
  content_template: Joi.string().required().min(10).max(10000),
  subject_template: Joi.string().max(200).allow(''),
  variables: Joi.array().items(Joi.string()).default([]),
  is_active: Joi.boolean().default(true)
});

// Notification validations
const notificationSchema = Joi.object({
  title: Joi.string().required().min(3).max(100),
  message: Joi.string().required().min(5).max(500),
  type: Joi.string().valid('info', 'warning', 'error', 'success', 'letter', 'assignment', 'attendance', 'system').required(),
  priority: Joi.string().valid('low', 'normal', 'high', 'urgent').default('normal'),
  user_ids: Joi.array().items(Joi.string()).min(1).required()
});

// Query parameter validations
const paginationSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10)
});

const dateRangeSchema = Joi.object({
  start_date: Joi.date().iso(),
  end_date: Joi.date().iso().min(Joi.ref('start_date'))
});

const searchSchema = Joi.object({
  search: Joi.string().min(1).max(100).allow(''),
  sort_by: Joi.string().min(1).max(50).allow(''),
  sort_order: Joi.string().valid('asc', 'desc').default('asc')
});

const reportParamsSchema = Joi.object({
  period: Joi.string().valid('week', 'month', 'year', 'custom').default('month'),
  format: Joi.string().valid('json', 'csv', 'xlsx').default('json'),
  department: Joi.string().min(1).max(100).allow('')
});

// Middleware functions
const validateRegister = (req, res, next) => {
  const { error } = registerSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateLogin = (req, res, next) => {
  const { error } = loginSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateAttendance = (req, res, next) => {
  const { error } = attendanceSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateLetter = (req, res, next) => {
  const { error } = letterSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateProfile = (req, res, next) => {
  const { error } = profileSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validatePasswordChange = (req, res, next) => {
  const { error } = passwordChangeSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

// ===================== VALIDATION MIDDLEWARE FUNCTIONS =====================

const validateAssignment = (req, res, next) => {
  const { error } = assignmentSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateAssignmentUpdate = (req, res, next) => {
  const { error } = assignmentUpdateSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateComment = (req, res, next) => {
  const { error } = commentSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateCreateEmployee = (req, res, next) => {
  const { error } = createEmployeeSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateUpdateEmployee = (req, res, next) => {
  const { error } = updateEmployeeSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateEmployeeStatus = (req, res, next) => {
  const { error } = employeeStatusSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateBulkImport = (req, res, next) => {
  const { error } = bulkImportSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateResetPassword = (req, res, next) => {
  const { error } = resetPasswordSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateLeaveRequest = (req, res, next) => {
  const { error } = leaveRequestSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateBulkAttendanceUpdate = (req, res, next) => {
  const { error } = bulkAttendanceUpdateSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateBulkLetterAction = (req, res, next) => {
  const { error } = bulkLetterActionSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateLetterTemplate = (req, res, next) => {
  const { error } = letterTemplateSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateNotification = (req, res, next) => {
  const { error } = notificationSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validatePagination = (req, res, next) => {
  const { error } = paginationSchema.validate(req.query);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  // Set validated values back to query
  req.query.page = req.query.page || 1;
  req.query.limit = req.query.limit || 10;
  next();
};

const validateDateRange = (req, res, next) => {
  const { error } = dateRangeSchema.validate(req.query);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateSearch = (req, res, next) => {
  const { error } = searchSchema.validate(req.query);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

const validateReportParams = (req, res, next) => {
  const { error } = reportParamsSchema.validate(req.query);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      details: error.details[0].message
    });
  }
  next();
};

// File upload validation middleware
const validateFileUpload = (allowedTypes = [], maxSize = 5 * 1024 * 1024) => {
  return (req, res, next) => {
    if (!req.file && !req.files) {
      return next();
    }

    const files = req.files ? Object.values(req.files).flat() : [req.file];
    
    for (const file of files) {
      // Check file size
      if (file.size > maxSize) {
        return res.status(400).json({
          success: false,
          message: `File size too large. Maximum size is ${Math.round(maxSize / (1024 * 1024))}MB`
        });
      }

      // Check file type
      if (allowedTypes.length > 0 && !allowedTypes.includes(file.mimetype)) {
        return res.status(400).json({
          success: false,
          message: `Invalid file type. Allowed types: ${allowedTypes.join(', ')}`
        });
      }
    }

    next();
  };
};

// Input sanitization middleware
const sanitizeInput = (req, res, next) => {
  const sanitizeString = (str) => {
    if (typeof str !== 'string') return str;
    return str.trim().replace(/[<>]/g, '');
  };

  const sanitizeObject = (obj) => {
    if (Array.isArray(obj)) {
      return obj.map(sanitizeObject);
    }
    
    if (obj && typeof obj === 'object') {
      const sanitized = {};
      for (const key in obj) {
        sanitized[key] = sanitizeObject(obj[key]);
      }
      return sanitized;
    }
    
    return sanitizeString(obj);
  };

  req.body = sanitizeObject(req.body);
  req.query = sanitizeObject(req.query);
  next();
};

module.exports = {
  // Original validations
  validateRegister,
  validateLogin,
  validateAttendance,
  validateLetter,
  profileValidation: validateProfile,
  passwordChangeValidation: validatePasswordChange,
  
  // Admin Assignment validations
  validateAssignment,
  validateAssignmentUpdate,
  validateComment,
  
  // Admin Employee validations
  validateCreateEmployee,
  validateUpdateEmployee,
  validateEmployeeStatus,
  validateBulkImport,
  validateResetPassword,
  
  // Admin Attendance validations
  validateLeaveRequest,
  validateBulkAttendanceUpdate,
  
  // Admin Letter validations
  validateBulkLetterAction,
  validateLetterTemplate,
  
  // Notification validations
  validateNotification,
  
  // Query parameter validations
  validatePagination,
  validateDateRange,
  validateSearch,
  validateReportParams,
  
  // Utility middleware
  validateFileUpload,
  sanitizeInput
};
