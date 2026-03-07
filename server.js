const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// Importar configuración BD
const { connectDB, testConnection } = require('./src/config/database');
const logger = require('./src/utils/logger');

// Importar rutas
const authRoutes = require('./src/routes/auth.routes');
const calculosRoutes = require('./src/routes/calculos.routes');
const configuracionRoutes = require('./src/routes/configuracion.routes');
const metasRoutes = require('./src/routes/metas.routes');

const app = express();

// Middlewares
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
    origin: process.env.FRONTEND_URL || '*',
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Middleware para logging de peticiones
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.url} - IP: ${req.ip}`);
    next();
});

// Rutas
app.use('/api/auth', authRoutes);
app.use('/api/calculos', calculosRoutes);
app.use('/api/configuracion', configuracionRoutes);
app.use('/api/metas', metasRoutes);

// Ruta de bienvenida
app.get('/', (req, res) => {
    res.json({
        nombre: 'SYACAPI - Sistema Financiero',
        version: process.env.API_VERSION,
        estado: 'Online',
        base_datos: process.env.DB_DATABASE,
        endpoints: {
            autenticacion: '/api/auth',
            calculos: '/api/calculos',
            configuracion: '/api/configuracion',
            metas: '/api/metas',
            documentacion: '/api/docs'
        }
    });
});

// Documentación de la API
app.get('/api/docs', (req, res) => {
    res.json({
        api: "SYACAPI Financial",
        version: "1.0.0",
        descripcion: "API para el Sistema SYAC - Calculadora Financiera",
        autenticacion: {
            registro: "POST /api/auth/register",
            login: "POST /api/auth/login",
            olvide_password: "POST /api/auth/forgot-password"
        },
        calculos: {
            guardar: "POST /api/calculos/guardar",
            historial: "GET /api/calculos/historial",
            filtrar: "GET /api/calculos/historial?tipo=simple&desde=2024-01-01&hasta=2024-12-31"
        },
        configuracion: {
            obtener: "GET /api/configuracion/:userId",
            actualizar: "PUT /api/configuracion/:userId"
        },
        metas: {
            obtener: "GET /api/metas/:userId",
            actualizar: "PUT /api/metas/:userId"
        }
    });
});

// Middleware de errores
app.use((err, req, res, next) => {
    logger.error(`Error: ${err.message} - Stack: ${err.stack}`);
    res.status(500).json({
        success: false,
        error: 'Error interno del servidor',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// 404
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        error: 'Ruta no encontrada'
    });
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;

const startServer = async () => {
    try {
        // Probar conexión a SQL Server
        await testConnection();
        
        // Conectar a la base de datos
        await connectDB();
        
        app.listen(PORT, () => {
            logger.info(`=================================`);
            logger.info(` SYACAPI corriendo en http://localhost:${PORT}`);
            logger.info(` Documentación: http://localhost:${PORT}/api/docs`);
            logger.info(` Base de datos: ${process.env.DB_DATABASE} en ${process.env.DB_SERVER}`);
            logger.info(`=================================`);
        });
    } catch (error) {
        logger.error(' Error al iniciar el servidor:', error);
        process.exit(1);
    }
};

startServer();