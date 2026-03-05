const nodemailer = require('nodemailer');
const logger = require('./logger');

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    },
    tls: {
        rejectUnauthorized: false
    }
});

const sendPasswordResetEmail = async (email, nombre, tempPassword) => {
    try {
        const mailOptions = {
            from: process.env.EMAIL_FROM,
            to: email,
            subject: ' Recuperación de Contraseña - Sistema SYAC',
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }
                        .container { max-width: 600px; margin: 20px auto; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                        .header { background: #00236B; color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }
                        .content { padding: 30px; }
                        .password-box { background: #f8f8fa; border: 2px solid #00236B; padding: 15px; text-align: center; margin: 20px 0; border-radius: 8px; }
                        .password { font-size: 24px; font-weight: bold; color: #00236B; letter-spacing: 2px; }
                        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #eee; }
                        .button { background: #00C853; color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; display: inline-block; margin: 20px 0; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1> Sistema SYAC</h1>
                        </div>
                        <div class="content">
                            <h2>Hola ${nombre}!</h2>
                            <p>Has solicitado recuperar tu contraseña. Aquí tienes una contraseña temporal para acceder a tu cuenta:</p>
                            
                            <div class="password-box">
                                <p style="margin:0; color:#666;">Contraseña Temporal:</p>
                                <div class="password">${tempPassword}</div>
                            </div>
                            
                            <p><strong> Importante:</strong> Por seguridad, te recomendamos cambiar esta contraseña después de iniciar sesión.</p>
                            
                            <div style="text-align: center;">
                                <a href="${process.env.FRONTEND_URL}/login" class="button">Ir a Iniciar Sesión</a>
                            </div>
                            
                            <p>Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
                        </div>
                        <div class="footer">
                            <p>© 2026 Sistema SYAC - Calculadora Financiera Honduras</p>
                            <p>Este es un correo automático, por favor no respondas a este mensaje.</p>
                        </div>
                    </div>
                </body>
                </html>
            `
        };

        const info = await transporter.sendMail(mailOptions);
        logger.info(` Email de recuperación enviado a: ${email}`);
        return { success: true, info };
    } catch (error) {
        logger.error(` Error enviando email: ${error.message}`);
        return { success: false, error: error.message };
    }
};

module.exports = {
    sendPasswordResetEmail
};