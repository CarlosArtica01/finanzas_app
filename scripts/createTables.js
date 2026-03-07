const sql = require('mssql');
require('dotenv').config();

const trustCert = process.env.DB_TRUST_CERTIFICATE !== 'false';
const config = {
    server: process.env.DB_SERVER || 'YUDITH',
    port: parseInt(process.env.DB_PORT) || 1433,
    database: 'master',
    options: {
        encrypt: trustCert,
        trustServerCertificate: trustCert,
        enableArithAbort: true,
        connectTimeout: 30000
    }
};
if (process.env.DB_AUTH_TYPE === 'windows') {
    config.authentication = {
        type: 'ntlm',
        options: {
            domain: process.env.DB_DOMAIN || 'YUDITH',
            userName: process.env.DB_USER || 'skarl',
            password: process.env.DB_PASSWORD || ''
        }
    };
} else {
    config.user = process.env.DB_USER;
    config.password = process.env.DB_PASSWORD;
}

const createDatabase = async () => {
    try {
        const pool = await sql.connect(config);
        
        console.log('🔨 Creando base de datos syac_db...');
        
        // Crear base de datos si no existe
        await pool.request().query(`
            IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'syac_db')
            BEGIN
                CREATE DATABASE syac_db;
            END
        `);
        
        console.log(' Base de datos verificada/creada');
        
        // Cambiar a la base de datos syac_db
        await pool.request().query('USE syac_db');
        
        console.log(' Creando tablas...');
        
        // Crear tabla usuarios
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='usuarios' AND xtype='U')
            CREATE TABLE usuarios (
                id_usuario INT IDENTITY(1,1) PRIMARY KEY,
                nombre NVARCHAR(100) NOT NULL,
                apellido NVARCHAR(100) NOT NULL,
                correo NVARCHAR(150) NOT NULL UNIQUE,
                password_hash NVARCHAR(255) NOT NULL,
                fecha_registro DATETIME DEFAULT GETDATE()
            )
        `);
        
        // Crear tabla tipos_interes
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tipos_interes' AND xtype='U')
            CREATE TABLE tipos_interes (
                id_tipo_interes INT IDENTITY(1,1) PRIMARY KEY,
                nombre_tipo NVARCHAR(50) NOT NULL UNIQUE,
                descripcion NVARCHAR(255)
            )
        `);
        
        // Crear tabla monedas
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='monedas' AND xtype='U')
            CREATE TABLE monedas (
                id_moneda INT IDENTITY(1,1) PRIMARY KEY,
                codigo_moneda NVARCHAR(10) NOT NULL UNIQUE,
                nombre_moneda NVARCHAR(100) NOT NULL,
                simbolo NVARCHAR(10) NOT NULL
            )
        `);
        
        // Crear tabla configuraciones
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='configuraciones' AND xtype='U')
            CREATE TABLE configuraciones (
                id_configuracion INT IDENTITY(1,1) PRIMARY KEY,
                id_usuario INT NOT NULL,
                id_moneda INT NOT NULL,
                tema NVARCHAR(20) NOT NULL DEFAULT 'Claro',
                notificaciones_activas BIT DEFAULT 1,
                CONSTRAINT fk_config_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
                CONSTRAINT fk_config_moneda FOREIGN KEY (id_moneda) REFERENCES monedas(id_moneda)
            )
        `);
        
        // Crear tabla calculos
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='calculos' AND xtype='U')
            CREATE TABLE calculos (
                id_calculo INT IDENTITY(1,1) PRIMARY KEY,
                id_usuario INT NOT NULL,
                id_tipo_interes INT NOT NULL,
                capital_inicial DECIMAL(15,2) NOT NULL,
                tasa_interes DECIMAL(5,2) NOT NULL,
                periodo_tipo NVARCHAR(20) NOT NULL,
                tiempo_valor INT NOT NULL,
                fecha_inicio DATE NOT NULL,
                fecha_fin DATE NOT NULL,
                resultado_final DECIMAL(15,2) NOT NULL,
                fecha_calculo DATETIME DEFAULT GETDATE(),
                CONSTRAINT fk_calculo_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
                CONSTRAINT fk_calculo_tipo FOREIGN KEY (id_tipo_interes) REFERENCES tipos_interes(id_tipo_interes)
            )
        `);
        
        // Crear tabla metas_jubilacion
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='metas_jubilacion' AND xtype='U')
            CREATE TABLE metas_jubilacion (
                id_meta INT IDENTITY(1,1) PRIMARY KEY,
                id_usuario INT NOT NULL,
                monto_objetivo DECIMAL(15,2) NOT NULL,
                monto_actual DECIMAL(15,2) DEFAULT 0,
                porcentaje_avance DECIMAL(5,2) DEFAULT 0,
                fecha_creacion DATETIME DEFAULT GETDATE(),
                CONSTRAINT fk_meta_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
            )
        `);
        
        console.log(' Tablas creadas exitosamente');
        
        // Insertar datos iniciales si no existen
        console.log(' Insertando datos iniciales...');
        
        // Tipos de interés
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM tipos_interes)
            BEGIN
                INSERT INTO tipos_interes (nombre_tipo, descripcion)
                VALUES 
                ('Simple', 'Interés calculado sobre el capital inicial'),
                ('Compuesto', 'Interés calculado sobre capital acumulado')
            END
        `);
        
        // Monedas
        await pool.request().query(`
            IF NOT EXISTS (SELECT * FROM monedas)
            BEGIN
                INSERT INTO monedas (codigo_moneda, nombre_moneda, simbolo)
                VALUES ('HNL', 'Lempira Hondureño', 'LPS.')
            END
        `);
        
        console.log(' Datos iniciales insertados');
        console.log(' Base de datos lista para usar!');
        
        await pool.close();
        
    } catch (error) {
        console.error(' Error:', error);
    }
};

createDatabase();