-- 1. Crear la base de datos del proyecto
CREATE DATABASE YouTubeAnalytics2026;
GO

USE YouTubeAnalytics2026;
GO

-- 2. Crear la tabla cruda (Raw Layer / Staging)
-- Estructura idéntica al CSV exportado por el script de Python
CREATE TABLE raw_youtube_videos_2026 (
    id_ingesta INT IDENTITY(1,1) PRIMARY KEY,
    video_id NVARCHAR(50),
    titulo NVARCHAR(500),
    id_canal NVARCHAR(100),
    nombre_canal NVARCHAR(255),
    fecha_publicacion NVARCHAR(50),      -- En formato texto crudo (ISO)
    duracion_segundos NVARCHAR(50),     -- Como texto para evitar errores de parseo inicial
    vistas NVARCHAR(50),
    likes NVARCHAR(50),
    comentarios NVARCHAR(50),
    fecha_carga DATETIME2 DEFAULT SYSDATETIME()
);
GO