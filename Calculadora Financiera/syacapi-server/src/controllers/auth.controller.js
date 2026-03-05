const { getPool, sql } = require('../config/database');
const { hashPassword, comparePassword } = require('../utils/bcrypt.util');
const { generateToken } = require('../utils/jwt.util');
const { sendPasswordResetEmail } = require('../utils/email.util');
const logger = require('../utils/logger');

// ============================================
// REGISTRO DE USUARIO
// ============================================
const register = async (req, res) => {
    try {
        const { nombre, apellido, correo, password } = req.body;
        const pool = getPool();

        // Verificar si el usuario ya existe
        const existingUser = await pool.request()
            .input('correo', sql.NVarChar, correo)
            .query('SELECT id_usuario FROM usuarios WHERE correo = @correo');

        if (existingUser.recordset.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'El correo electrónico ya está registrado'
            });
        }

        // Hash de la contraseña
        const hashedPassword = await hashPassword(password);

        // Insertar usuario
        const result = await pool.request()
            .input('nombre', sql.NVarChar, nombre)
            .input('apellido', sql.NVarChar, apellido)
            .input('correo', sql.NVarChar, correo)
            .input('password_hash', sql.NVarChar, hashedPassword)
            .query(`
                INSERT INTO usuarios (nombre, apellido, correo, password_hash)
                OUTPUT INSERTED.*
                VALUES (@nombre, @apellido, @correo, @password_hash)
            `);

        const newUser = result.recordset[0];

        // Crear configuración por defecto para el usuario
        await pool.request()
            .input('id_usuario', sql.Int, newUser.id_usuario)
            .input('id_moneda', sql.Int, 1) // HNL por defecto
            .query(`
                INSERT INTO configuraciones (id_usuario, id_moneda, tema, notificaciones_activas)
                VALUES (@id_usuario, @id_moneda, 'Claro', 1)
            `);

        // Crear meta de jubilación por defecto
        await pool.request()
            .input('id_usuario', sql.Int, newUser.id_usuario)
            .input('monto_objetivo', sql.Decimal(15,2), 100000) // Meta por defecto
            .query(`
                INSERT INTO metas_jubilacion (id_usuario, monto_objetivo)
                VALUES (@id_usuario, @monto_objetivo)
            `);

        logger.info(` Nuevo usuario registrado: ${correo}`);

        res.status(201).json({
            success: true,
            message: 'Usuario registrado exitosamente',
            data: {
                id_usuario: newUser.id_usuario,
                nombre: newUser.nombre,
                apellido: newUser.apellido,
                correo: newUser.correo
            }
        });

    } catch (error) {
        logger.error(` Error en registro: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al registrar usuario'
        });
    }
};

// ============================================
// LOGIN DE USUARIO
// ============================================
const login = async (req, res) => {
    try {
        const { correo, password } = req.body;
        const pool = getPool();

        // Buscar usuario
        const result = await pool.request()
            .input('correo', sql.NVarChar, correo)
            .query(`
                SELECT u.*, c.tema, c.notificaciones_activas, m.codigo_moneda, m.simbolo
                FROM usuarios u
                LEFT JOIN configuraciones c ON u.id_usuario = c.id_usuario
                LEFT JOIN monedas m ON c.id_moneda = m.id_moneda
                WHERE u.correo = @correo
            `);

        if (result.recordset.length === 0) {
            return res.status(401).json({
                success: false,
                error: 'Credenciales inválidas'
            });
        }

        const user = result.recordset[0];

        // Verificar contraseña
        const isValidPassword = await comparePassword(password, user.password_hash);
        
        if (!isValidPassword) {
            return res.status(401).json({
                success: false,
                error: 'Credenciales inválidas'
            });
        }

        // Generar token
        const token = generateToken(user);

        logger.info(` Usuario autenticado: ${correo}`);

        res.json({
            success: true,
            message: 'Login exitoso',
            token,
            usuario: {
                id_usuario: user.id_usuario,
                nombre: user.nombre,
                apellido: user.apellido,
                correo: user.correo,
                configuracion: {
                    tema: user.tema || 'Claro',
                    notificaciones_activas: user.notificaciones_activas,
                    moneda: {
                        codigo: user.codigo_moneda || 'HNL',
                        simbolo: user.simbolo || 'LPS.'
                    }
                }
            }
        });

    } catch (error) {
        logger.error(` Error en login: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al iniciar sesión'
        });
    }
};

// =============================================
// RECUPERAR CONTRASEÑA
// ============================================
const forgotPassword = async (req, res) => {
    try {
        const { correo } = req.body;
        const pool = getPool();

        // Buscar usuario
        const result = await pool.request()
            .input('correo', sql.NVarChar, correo)
            .query('SELECT id_usuario, nombre, apellido FROM usuarios WHERE correo = @correo');

        if (result.recordset.length === 0) {
            // Por seguridad, no se revela si el correo existe
            return res.json({
                success: true,
                mensaje: 'Si el correo existe, recibirás instrucciones para recuperar tu contraseña'
            });
        }

        const user = result.recordset[0];
        
        // Generar contraseña temporal (8 caracteres)
        const tempPassword = Math.random().toString(36).slice(-8) + 'A1';
        const hashedPassword = await hashPassword(tempPassword);

        // Actualizar contraseña en BD
        await pool.request()
            .input('password_hash', sql.NVarChar, hashedPassword)
            .input('id_usuario', sql.Int, user.id_usuario)
            .query('UPDATE usuarios SET password_hash = @password_hash WHERE id_usuario = @id_usuario');

        // Enviar email
        const emailResult = await sendPasswordResetEmail(
            correo,
            `${user.nombre} ${user.apellido}`,
            tempPassword
        );

        if (emailResult.success) {
            logger.info(` Email de recuperación enviado a: ${correo}`);
        } else {
            logger.warn(` No se pudo enviar email a: ${correo}`);
        }

        res.json({
            success: true,
            mensaje: 'Se ha enviado una nueva contraseña a tu correo electrónico'
        });

    } catch (error) {
        logger.error(` Error en recuperación: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al procesar la solicitud'
        });
    }
};

// ============================================
// ACTUALIZAR PERFIL (nombre, apellido)
// ============================================
const updatePerfil = async (req, res) => {
    try {
        const { nombre, apellido } = req.body;
        const userId = req.user.id;
        const pool = getPool();

        if (!nombre || !apellido) {
            return res.status(400).json({
                success: false,
                error: 'Nombre y apellido son obligatorios'
            });
        }

        await pool.request()
            .input('id_usuario', sql.Int, userId)
            .input('nombre', sql.NVarChar, nombre.trim())
            .input('apellido', sql.NVarChar, apellido.trim())
            .query(`
                UPDATE usuarios SET nombre = @nombre, apellido = @apellido
                WHERE id_usuario = @id_usuario
            `);

        logger.info(` Perfil actualizado para usuario ${userId}`);

        res.json({
            success: true,
            message: 'Perfil actualizado exitosamente',
            data: { nombre: nombre.trim(), apellido: apellido.trim() }
        });

    } catch (error) {
        logger.error(` Error actualizando perfil: ${error.message}`);
        res.status(500).json({
            success: false,
            error: 'Error al actualizar el perfil'
        });
    }
};

module.exports = {
    register,
    login,
    forgotPassword,
    updatePerfil
};