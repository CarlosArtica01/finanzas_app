const { getPool, sql } = require('../config/database');
const logger = require('../utils/logger');

// ============================================
// OBTENER CONFIGURACIÓN DEL USUARIO
// ============================================
const getConfiguracion = async (req, res) => {
    try {
        const { userId } = req.params;
        const pool = getPool();

        // Verificar que el usuario solicita su propia configuración
        if (parseInt(userId) !== req.user.id) {
            return res.status(403).json({
                success: false,
                error: 'No autorizado para ver esta configuración'
            });
        }

        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .query(`
                SELECT 
                    c.id_configuracion,
                    c.id_usuario,
                    c.tema,
                    c.notificaciones_activas,
                    m.id_moneda,
                    m.codigo_moneda,
                    m.nombre_moneda,
                    m.simbolo
                FROM configuraciones c
                INNER JOIN monedas m ON c.id_moneda = m.id_moneda
                WHERE c.id_usuario = @id_usuario
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'Configuración no encontrada'
            });
        }

        res.json({
            success: true,
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error obteniendo configuración: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al obtener la configuración'
        });
    }
};

// ============================================
// ACTUALIZAR CONFIGURACIÓN
// ============================================
const updateConfiguracion = async (req, res) => {
    try {
        const { userId } = req.params;
        const { tema, notificaciones_activas, id_moneda } = req.body;
        const pool = getPool();

        // Verificar autorización
        if (parseInt(userId) !== req.user.id) {
            return res.status(403).json({
                success: false,
                error: 'No autorizado para modificar esta configuración'
            });
        }

        let query = 'UPDATE configuraciones SET ';
        const request = pool.request()
            .input('id_usuario', sql.Int, userId);

        const updates = [];

        if (tema !== undefined) {
            updates.push('tema = @tema');
            request.input('tema', sql.NVarChar, tema);
        }

        if (notificaciones_activas !== undefined) {
            updates.push('notificaciones_activas = @notificaciones_activas');
            request.input('notificaciones_activas', sql.Bit, notificaciones_activas ? 1 : 0);
        }

        if (id_moneda !== undefined) {
            updates.push('id_moneda = @id_moneda');
            request.input('id_moneda', sql.Int, id_moneda);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'No hay campos para actualizar'
            });
        }

        query += updates.join(', ') + ' WHERE id_usuario = @id_usuario';

        await request.query(query);

        // Obtener configuración actualizada
        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .query(`
                SELECT 
                    c.*,
                    m.codigo_moneda,
                    m.simbolo
                FROM configuraciones c
                INNER JOIN monedas m ON c.id_moneda = m.id_moneda
                WHERE c.id_usuario = @id_usuario
            `);

        logger.info(` Configuración actualizada para usuario ${userId}`);

        res.json({
            success: true,
            message: 'Configuración actualizada exitosamente',
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error actualizando configuración: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al actualizar la configuración'
        });
    }
};

// ============================================
// OBTENER MONEDAS DISPONIBLES
// ============================================
const getMonedas = async (req, res) => {
    try {
        const pool = getPool();
        const result = await pool.request()
            .query('SELECT * FROM monedas ORDER BY codigo_moneda');

        res.json({
            success: true,
            data: result.recordset
        });

    } catch (error) {
        logger.error(` Error obteniendo monedas: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al obtener las monedas'
        });
    }
};

module.exports = {
    getConfiguracion,
    updateConfiguracion,
    getMonedas
};