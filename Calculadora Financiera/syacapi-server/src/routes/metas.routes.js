const express = require('express');
const router = express.Router();
const metasController = require('../controllers/metas.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Todas las rutas de metas requieren autenticación
router.use(authMiddleware);

router.get('/:userId', metasController.getMeta);
router.put('/:userId', metasController.updateMeta);
router.post('/:userId/iniciar', metasController.crearMetaInicial);

module.exports = router;