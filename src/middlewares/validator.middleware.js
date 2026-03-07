const { body, validationResult } = require('express-validator');

const validateRequest = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            errors: errors.array().map(err => ({
                campo: err.param,
                mensaje: err.msg
            }))
        });
    }
    next();
};

// Validaciones para registro
const registerValidation = [
    body('nombre').notEmpty().withMessage('El nombre es obligatorio')
        .isLength({ min: 2 }).withMessage('El nombre debe tener al menos 2 caracteres'),
    body('apellido').notEmpty().withMessage('El apellido es obligatorio')
        .isLength({ min: 2 }).withMessage('El apellido debe tener al menos 2 caracteres'),
    body('correo').isEmail().withMessage('Correo electrónico inválido')
        .normalizeEmail(),
    body('password').isLength({ min: 6 }).withMessage('La contraseña debe tener al menos 6 caracteres')
        .matches(/^(?=.*[A-Z])(?=.*[0-9])/).withMessage('La contraseña debe contener al menos una mayúscula y un número'),
    validateRequest
];

// Validaciones para login
const loginValidation = [
    body('correo').isEmail().withMessage('Correo electrónico inválido')
        .normalizeEmail(),
    body('password').notEmpty().withMessage('La contraseña es obligatoria'),
    validateRequest
];

// Validaciones para cálculo
const calculoValidation = [
    body('capital_inicial').isNumeric().withMessage('El capital debe ser numérico')
        .custom(value => value > 0).withMessage('El capital debe ser mayor a 0'),
    body('tasa_interes').isNumeric().withMessage('La tasa debe ser numérica')
        .custom(value => value > 0).withMessage('La tasa debe ser mayor a 0'),
    body('periodo_tipo').isIn(['Anual', 'Mensual', 'Trimestral']).withMessage('Período inválido'),
    body('tiempo_valor').isInt({ min: 1 }).withMessage('El tiempo debe ser un número entero positivo'),
    validateRequest
];

module.exports = {
    registerValidation,
    loginValidation,
    calculoValidation
};