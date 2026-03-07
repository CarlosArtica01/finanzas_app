const express = require('express');
const router = express.Router();
const configuracionController = require('../controllers/configuracion.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Todas las rutas de configuración requieren autenticación
router.use(authMiddleware);

router.get('/monedas', configuracionController.getMonedas);
router.get('/:userId', configuracionController.getConfiguracion);
router.put('/:userId', configuracionController.updateConfiguracion);

module.exports = router;