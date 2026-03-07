-- =========================================
-- CREAR BASE DE DATOS
-- =========================================
CREATE DATABASE syac_db;
GO

USE syac_db;
GO

-- =========================================
-- TABLA: USUARIOS
-- =========================================
CREATE TABLE usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    correo NVARCHAR(150) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE()
);
GO

-- =========================================
-- TABLA: TIPOS_INTERES
-- =========================================
CREATE TABLE tipos_interes (
    id_tipo_interes INT IDENTITY(1,1) PRIMARY KEY,
    nombre_tipo NVARCHAR(50) NOT NULL UNIQUE,
    descripcion NVARCHAR(255)
);
GO

-- =========================================
-- TABLA: MONEDAS
-- =========================================
CREATE TABLE monedas (
    id_moneda INT IDENTITY(1,1) PRIMARY KEY,
    codigo_moneda NVARCHAR(10) NOT NULL UNIQUE,
    nombre_moneda NVARCHAR(100) NOT NULL,
    simbolo NVARCHAR(10) NOT NULL
);
GO

-- =========================================
-- TABLA: CONFIGURACIONES
-- =========================================
CREATE TABLE configuraciones (
    id_configuracion INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_moneda INT NOT NULL,
    tema NVARCHAR(20) NOT NULL DEFAULT 'Claro',
    notificaciones_activas BIT DEFAULT 1,

    CONSTRAINT fk_config_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_config_moneda
        FOREIGN KEY (id_moneda)
        REFERENCES monedas(id_moneda)
);
GO

-- =========================================
-- TABLA: CALCULOS
-- =========================================
CREATE TABLE calculos (
    id_calculo INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_tipo_interes INT NOT NULL,
    capital_inicial DECIMAL(15,2) NOT NULL,
    tasa_interes DECIMAL(5,2) NOT NULL,
    periodo_tipo NVARCHAR(20) NOT NULL, -- Anual, Mensual, Trimestral
    tiempo_valor INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    resultado_final DECIMAL(15,2) NOT NULL,
    fecha_calculo DATETIME DEFAULT GETDATE(),

    CONSTRAINT fk_calculo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_calculo_tipo
        FOREIGN KEY (id_tipo_interes)
        REFERENCES tipos_interes(id_tipo_interes)
);
GO

-- =========================================
-- TABLA: METAS_JUBILACION
-- =========================================
CREATE TABLE metas_jubilacion (
    id_meta INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL,
    monto_objetivo DECIMAL(15,2) NOT NULL,
    monto_actual DECIMAL(15,2) DEFAULT 0,
    porcentaje_avance DECIMAL(5,2) DEFAULT 0,
    fecha_creacion DATETIME DEFAULT GETDATE(),

    CONSTRAINT fk_meta_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);
GO

-- =========================================
-- INSERTAR DATOS INICIALES
-- =========================================
INSERT INTO tipos_interes (nombre_tipo, descripcion)
VALUES
('Simple', 'Interés calculado sobre el capital inicial'),
('Compuesto', 'Interés calculado sobre capital acumulado');
GO

INSERT INTO monedas (codigo_moneda, nombre_moneda, simbolo)
VALUES
('HNL', 'Lempira Hondureño', 'LPS.');
GO