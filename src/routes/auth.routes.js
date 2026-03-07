const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const { registerValidation, loginValidation } = require('../middlewares/validator.middleware');

// Rutas de autenticación
router.post('/register', registerValidation, authController.register);
router.post('/login', loginValidation, authController.login);
router.post('/forgot-password', authController.forgotPassword);

// Actualizar perfil (nombre, apellido) - requiere token
router.put('/perfil', authMiddleware, authController.updatePerfil);

// Cambiar contraseña - requiere token
router.post('/cambiar-contrasena', authMiddleware, authController.changePassword);

module.exports = router;