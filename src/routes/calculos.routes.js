const express = require('express');
const router = express.Router();
const calculosController = require('../controllers/calculos.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const { calculoValidation } = require('../middlewares/validator.middleware');

// Todas las rutas de cálculos requieren autenticación
router.use(authMiddleware);

router.post('/guardar', calculoValidation, calculosController.guardarCalculo);
router.get('/historial', calculosController.getHistorial);
router.get('/:id', calculosController.getCalculoById);
router.delete('/:id', calculosController.eliminarCalculo);

module.exports = router;