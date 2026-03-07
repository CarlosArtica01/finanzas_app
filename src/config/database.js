const sql = require('mssql');
const logger = require('../utils/logger');

const trustCert = process.env.DB_TRUST_CERTIFICATE !== 'false';

const config = {
    server: process.env.DB_SERVER || 'YUDITH',
    port: parseInt(process.env.DB_PORT) || 1433,
    database: process.env.DB_DATABASE || 'syac_db',
    options: {
        encrypt: trustCert,
        trustServerCertificate: trustCert,
        enableArithAbort: true,
        connectTimeout: 30000,
        requestTimeout: 30000,
        enableImplicitTransactions: true
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

if (process.env.DB_AUTH_TYPE === 'windows') {
  
    // NTLM: desde Node hay que enviar dominio + usuario + contraseña Windows
    console.log(' Usando autenticación Windows (NTLM)');
    config.authentication = {
        type: 'ntlm',
        options: {
            domain: process.env.DB_DOMAIN || 'YUDITH',
            userName: process.env.DB_USER || 'skarl',
            password: process.env.DB_PASSWORD || ''
        }
    };
} else {
    // SQL Server Authentication
    console.log(' Usando autenticación SQL Server');
    config.user = process.env.DB_USER;
    config.password = process.env.DB_PASSWORD;
}

let pool = null;

const connectDB = async () => {
    try {
        console.log(' Conectando a SQL Server...');
        console.log(` Servidor: ${config.server}`);
        console.log(` Base de datos: ${config.database}`);
        console.log(` Autenticación: ${process.env.DB_AUTH_TYPE || 'SQL Server'}`);
        
        pool = await sql.connect(config);
        
        // consulta simple
        const result = await pool.request().query('SELECT @@VERSION as version');
        console.log(' Conectado a SQL Server exitosamente');
        console.log(` Versión: ${result.recordset[0].version.substring(0, 50)}...`);
        
        return pool;
    } catch (error) {
        console.error(' Error conectando a SQL Server:');
        console.error('   - Código:', error.code);
        console.error('   - Mensaje:', error.message);
        
        
        throw error;
    }
};

const getPool = () => {
    if (!pool) {
        throw new Error('No hay conexión a la base de datos');
    }
    return pool;
};

const testConnection = async () => {
    try {
        console.log(' Probando conexión a SQL Server...');
        const testConfig = { ...config };
        testConfig.database = 'master'; // Conectar a master primero
        
        const testPool = await sql.connect(testConfig);
        console.log(' Conexión de prueba exitosa');
        await testPool.close();
        return true;
    } catch (error) {
        console.error(' Error en conexión de prueba:', error.message);
        throw error;
    }
};

const closeConnection = async () => {
    if (pool) {
        await pool.close();
        console.log('🔌 Conexión cerrada');
    }
};

module.exports = {
    connectDB,
    getPool,
    testConnection,
    closeConnection,
    sql
};