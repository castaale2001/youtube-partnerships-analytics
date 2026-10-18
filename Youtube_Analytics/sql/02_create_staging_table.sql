USE YouTubeAnalytics2026;
GO

-- 1. Si existe una versión previa, la eliminamos para reiniciar limpio
IF OBJECT_ID('dbo.tbl_videos_musicales', 'U') IS NOT NULL
    DROP TABLE dbo.tbl_videos_musicales;
GO

-- 2. Creación de la tabla base de trabajo
CREATE TABLE dbo.tbl_videos_musicales (
    sk_video INT IDENTITY(1,1) PRIMARY KEY,     -- Clave subrogada analítica
    video_id NVARCHAR(50) NOT NULL UNIQUE,       -- Clave natural de YouTube
    titulo NVARCHAR(500) NOT NULL,
    id_canal NVARCHAR(100) NOT NULL,
    nombre_canal NVARCHAR(255) NOT NULL,
    fecha_publicacion DATETIME2 NOT NULL,        -- Fecha tipada para series de tiempo
    duracion_segundos INT NOT NULL,              -- Duración en segundos enteros
    duracion_minutos DECIMAL(6,2),               -- Métrica calculada útil para BI
    vistas BIGINT NOT NULL DEFAULT 0,
    likes BIGINT NOT NULL DEFAULT 0,
    comentarios BIGINT NOT NULL DEFAULT 0,
    fecha_proceso_etl DATETIME2 DEFAULT SYSDATETIME() -- Auditoría de carga
);
GO