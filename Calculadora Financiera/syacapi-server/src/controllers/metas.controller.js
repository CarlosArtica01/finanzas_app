const { getPool, sql } = require('../config/database');
const logger = require('../utils/logger');

// ============================================
// OBTENER META DE JUBILACIÓN
// ============================================
const getMeta = async (req, res) => {
    try {
        const { userId } = req.params;
        const pool = getPool();

        // Verificar autorización
        if (parseInt(userId) !== req.user.id) {
            return res.status(403).json({
                success: false,
                error: 'No autorizado para ver esta meta'
            });
        }

        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .query('SELECT * FROM metas_jubilacion WHERE id_usuario = @id_usuario');

        if (result.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'Meta no encontrada'
            });
        }

        res.json({
            success: true,
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error obteniendo meta: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al obtener la meta'
        });
    }
};

// ============================================
// ACTUALIZAR META DE JUBILACIÓN
// ============================================
const updateMeta = async (req, res) => {
    try {
        const { userId } = req.params;
        const { monto_objetivo, monto_actual } = req.body;
        const pool = getPool();

        // Verificar autorización
        if (parseInt(userId) !== req.user.id) {
            return res.status(403).json({
                success: false,
                error: 'No autorizado para modificar esta meta'
            });
        }

        const request = pool.request()
            .input('id_usuario', sql.Int, userId);

        let updates = [];

        if (monto_objetivo !== undefined) {
            updates.push('monto_objetivo = @monto_objetivo');
            request.input('monto_objetivo', sql.Decimal(15,2), monto_objetivo);
        }

        if (monto_actual !== undefined) {
            updates.push('monto_actual = @monto_actual');
            request.input('monto_actual', sql.Decimal(15,2), monto_actual);
        }

        // Calcular porcentaje de avance
        if (monto_objetivo !== undefined || monto_actual !== undefined) {
            const currentMeta = await pool.request()
                .input('id_usuario', sql.Int, userId)
                .query('SELECT monto_objetivo, monto_actual FROM metas_jubilacion WHERE id_usuario = @id_usuario');

            const metaActual = currentMeta.recordset[0];
            const nuevoObjetivo = monto_objetivo ?? metaActual.monto_objetivo;
            const nuevoActual = monto_actual ?? metaActual.monto_actual;
            
            const porcentaje = (nuevoActual / nuevoObjetivo) * 100;
            updates.push('porcentaje_avance = @porcentaje_avance');
            request.input('porcentaje_avance', sql.Decimal(5,2), porcentaje);
        }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'No hay campos para actualizar'
            });
        }

        const query = 'UPDATE metas_jubilacion SET ' + updates.join(', ') + ' WHERE id_usuario = @id_usuario';
        await request.query(query);

        // Obtener meta actualizada
        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .query('SELECT * FROM metas_jubilacion WHERE id_usuario = @id_usuario');

        logger.info(` Meta actualizada para usuario ${userId}`);

        res.json({
            success: true,
            message: 'Meta actualizada exitosamente',
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error actualizando meta: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al actualizar la meta'
        });
    }
};

// ============================================
// CREAR META INICIAL (si no existe)
// ============================================
const crearMetaInicial = async (req, res) => {
    try {
        const { userId } = req.params;
        const { monto_objetivo = 100000 } = req.body;
        const pool = getPool();

        // Verificar si ya existe
        const existing = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .query('SELECT id_meta FROM metas_jubilacion WHERE id_usuario = @id_usuario');

        if (existing.recordset.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'La meta ya existe para este usuario'
            });
        }

        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .input('monto_objetivo', sql.Decimal(15,2), monto_objetivo)
            .query(`
                INSERT INTO metas_jubilacion (id_usuario, monto_objetivo)
                OUTPUT INSERTED.*
                VALUES (@id_usuario, @monto_objetivo)
            `);

        logger.info(` Meta creada para usuario ${userId}`);

        res.status(201).json({
            success: true,
            message: 'Meta creada exitosamente',
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error creando meta: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al crear la meta'
        });
    }
};

module.exports = {
    getMeta,
    updateMeta,
    crearMetaInicial
};