USE YouTubeAnalytics2026;
GO

WITH VideosLimpios AS (
    SELECT 
        TRIM(video_id) AS video_id,
        TRIM(titulo) AS titulo,
        TRIM(id_canal) AS id_canal,
        TRIM(nombre_canal) AS nombre_canal,
        -- Conversión segura a DATETIME2 (soporta formato ISO 8601 de YouTube)
        TRY_CAST(fecha_publicacion AS DATETIME2) AS fecha_publicacion,
        -- Conversión de métricas numéricas con reemplazo de nulos por 0
        ISNULL(TRY_CAST(duracion_segundos AS INT), 0) AS duracion_segundos,
        ISNULL(TRY_CAST(vistas AS BIGINT), 0) AS vistas,
        ISNULL(TRY_CAST(likes AS BIGINT), 0) AS likes,
        ISNULL(TRY_CAST(comentarios AS BIGINT), 0) AS comentarios,
        -- Numerar registros por video_id para eliminar duplicados si los hubiera
        ROW_NUMBER() OVER (
            PARTITION BY TRIM(video_id) 
            ORDER BY TRY_CAST(vistas AS BIGINT) DESC
        ) AS rn
    FROM dbo.raw_youtube_videos_2026
    WHERE video_id IS NOT NULL AND TRIM(video_id) <> ''
)
INSERT INTO dbo.tbl_videos_musicales (
    video_id,
    titulo,
    id_canal,
    nombre_canal,
    fecha_publicacion,
    duracion_segundos,
    duracion_minutos,
    vistas,
    likes,
    comentarios
)
SELECT 
    video_id,
    titulo,
    id_canal,
    nombre_canal,
    fecha_publicacion,
    duracion_segundos,
    ROUND(CAST(duracion_segundos AS DECIMAL(10,2)) / 60.0, 2) AS duracion_minutos,
    vistas,
    likes,
    comentarios
FROM VideosLimpios
WHERE rn = 1; -- Selecciona solo el primer registro único por video
GO