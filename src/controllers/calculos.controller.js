const { getPool, sql } = require('../config/database');
const logger = require('../utils/logger');

const normalizeTipo = (tipoRaw) => {
    if (!tipoRaw) return null;
    const value = tipoRaw.toString().trim().toLowerCase();
    if (!value || value === 'todos' || value === 'all') return null;
    if (value.startsWith('sim')) return 'Simple';
    if (value.startsWith('comp')) return 'Compuesto';
    return tipoRaw;
};

// ============================================
// GUARDAR CÁLCULO
// ============================================
const guardarCalculo = async (req, res) => {
    try {
        const {
            id_tipo_interes,
            capital_inicial,
            tasa_interes,
            periodo_tipo,
            tiempo_valor,
            fecha_inicio,
            fecha_fin,
            resultado_final
        } = req.body;

        const pool = getPool();
        const userId = req.user.id;

        const result = await pool.request()
            .input('id_usuario', sql.Int, userId)
            .input('id_tipo_interes', sql.Int, id_tipo_interes)
            .input('capital_inicial', sql.Decimal(15,2), capital_inicial)
            .input('tasa_interes', sql.Decimal(5,2), tasa_interes)
            .input('periodo_tipo', sql.NVarChar, periodo_tipo)
            .input('tiempo_valor', sql.Int, tiempo_valor)
            .input('fecha_inicio', sql.Date, fecha_inicio)
            .input('fecha_fin', sql.Date, fecha_fin)
            .input('resultado_final', sql.Decimal(15,2), resultado_final)
            .query(`
                INSERT INTO calculos (
                    id_usuario, id_tipo_interes, capital_inicial, tasa_interes,
                    periodo_tipo, tiempo_valor, fecha_inicio, fecha_fin, resultado_final
                )
                OUTPUT INSERTED.*
                VALUES (
                    @id_usuario, @id_tipo_interes, @capital_inicial, @tasa_interes,
                    @periodo_tipo, @tiempo_valor, @fecha_inicio, @fecha_fin, @resultado_final
                )
            `);

        logger.info(` Cálculo guardado para usuario ${userId}`);

        res.status(201).json({
            success: true,
            message: 'Cálculo guardado exitosamente',
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error guardando cálculo: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al guardar el cálculo'
        });
    }
};

// ============================================
// OBTENER HISTORIAL DE CÁLCULOS
// ============================================
const getHistorial = async (req, res) => {
    try {
        const userId = req.user.id;
        const { tipo, desde, hasta } = req.query;
        const pool = getPool();
        const tipoNormalizado = normalizeTipo(tipo);

        let query = `
            SELECT c.*, ti.nombre_tipo as tipo_interes_nombre
            FROM calculos c
            INNER JOIN tipos_interes ti ON c.id_tipo_interes = ti.id_tipo_interes
            WHERE c.id_usuario = @userId
        `;

        const request = pool.request()
            .input('userId', sql.Int, userId);

        if (tipoNormalizado) {
            query += ` AND ti.nombre_tipo = @tipo`;
            request.input('tipo', sql.NVarChar, tipoNormalizado);
        }

        if (desde) {
            query += ` AND c.fecha_calculo >= @desde`;
            request.input('desde', sql.DateTime, desde);
        }

        if (hasta) {
            query += ` AND c.fecha_calculo <= @hasta`;
            request.input('hasta', sql.DateTime, hasta);
        }

        query += ` ORDER BY c.fecha_calculo DESC`;

        const result = await request.query(query);

        // Estadísticas
        const stats = await pool.request()
            .input('userId', sql.Int, userId)
            .query(`
                SELECT 
                    COUNT(*) as total_calculos,
                    AVG(resultado_final) as promedio_resultado,
                    MAX(resultado_final) as max_resultado,
                    MIN(resultado_final) as min_resultado,
                    SUM(resultado_final) as suma_total
                FROM calculos
                WHERE id_usuario = @userId
            `);

        res.json({
            success: true,
            data: result.recordset,
            estadisticas: stats.recordset[0]
        });

    } catch (error) {
        logger.error(` Error obteniendo historial: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al obtener el historial'
        });
    }
};

// ============================================
// OBTENER CÁLCULO POR ID
// ============================================
const getCalculoById = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const pool = getPool();

        const result = await pool.request()
            .input('id_calculo', sql.Int, id)
            .input('id_usuario', sql.Int, userId)
            .query(`
                SELECT c.*, ti.nombre_tipo as tipo_interes_nombre
                FROM calculos c
                INNER JOIN tipos_interes ti ON c.id_tipo_interes = ti.id_tipo_interes
                WHERE c.id_calculo = @id_calculo AND c.id_usuario = @id_usuario
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'Cálculo no encontrado'
            });
        }

        res.json({
            success: true,
            data: result.recordset[0]
        });

    } catch (error) {
        logger.error(` Error obteniendo cálculo: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al obtener el cálculo'
        });
    }
};

// ============================================
// ELIMINAR CÁLCULO
// ============================================
const eliminarCalculo = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const pool = getPool();

        const result = await pool.request()
            .input('id_calculo', sql.Int, id)
            .input('id_usuario', sql.Int, userId)
            .query('DELETE FROM calculos WHERE id_calculo = @id_calculo AND id_usuario = @id_usuario');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({
                success: false,
                error: 'Cálculo no encontrado'
            });
        }

        logger.info(` Cálculo ${id} eliminado por usuario ${userId}`);

        res.json({
            success: true,
            message: 'Cálculo eliminado exitosamente'
        });

    } catch (error) {
        logger.error(` Error eliminando cálculo: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al eliminar el cálculo'
        });
    }
};

module.exports = {
    guardarCalculo,
    getHistorial,
    getCalculoById,
    eliminarCalculo
};
