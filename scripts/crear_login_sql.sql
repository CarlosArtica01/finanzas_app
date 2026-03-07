-- ============================================================
-- Script ejecutado en SSMS conectado a servidor YUDITH
-- (con Autenticación de Windows) para crear el usuario de la API
-- ============================================================

USE [master];
GO

-- Requisito: el servidor debe estar en MODO MIXTO (SQL Server + Windows Authenticador)



-- Crear login para la API (si no existe) o forzar password/habilitarlo (si existe)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'syac_api')
BEGIN
    CREATE LOGIN [syac_api] WITH PASSWORD = N'Syac2026',
        DEFAULT_DATABASE = [syac_db],
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = OFF;
    PRINT 'Login syac_api creado.';
END
ELSE
BEGIN
    PRINT 'El login syac_api ya existe. Actualizando password y habilitando...';
    ALTER LOGIN [syac_api] ENABLE;
    ALTER LOGIN [syac_api] WITH PASSWORD = N'Syac2026' UNLOCK;
END
GO

USE [syac_db];
GO

-- Usuario en la base syac_db
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'syac_api')
BEGIN
    CREATE USER [syac_api] FOR LOGIN [syac_api];
    PRINT 'Usuario syac_api creado en syac_db.';
END
GO

-- Dar permisos al usuario
ALTER ROLE [db_owner] ADD MEMBER [syac_api];
GO

PRINT 'Listo. La API puede conectarse con DB_USER=syac_api y DB_PASSWORD=Syac2026';
