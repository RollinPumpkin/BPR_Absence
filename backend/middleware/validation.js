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

module.exports = {
  validateRegister,
  validateLogin,
  validateAttendance
};
