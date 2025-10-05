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

module.exports = {
  validateRegister,
  validateLogin,
  validateAttendance,
  validateLetter,
  profileValidation: validateProfile,
  passwordChangeValidation: validatePasswordChange
};
