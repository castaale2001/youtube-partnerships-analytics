USE YouTubeAnalytics2026;
GO

WITH AnalisisCanales AS (
    SELECT 
        video_id,
        titulo,
        nombre_canal,
        duracion_segundos,
        vistas,
        likes,
        comentarios,
        -- Engagement individual por 1.000 vistas
        CAST(
            CASE 
                WHEN vistas = 0 THEN 0.00
                ELSE ((likes + comentarios) * 1000.0) / vistas
            END AS DECIMAL(10, 2)
        ) AS engagement_x1k,
        -- Promedio de vistas específico de este canal
        AVG(vistas) OVER (PARTITION BY nombre_canal) AS promedio_vistas_canal
    FROM dbo.tbl_videos_musicales
)
SELECT 
    video_id,
    titulo,
    nombre_canal,
    vistas,
    promedio_vistas_canal,
    engagement_x1k,
    -- Detección de anomalías según criterio del Lead
    CASE 
        WHEN vistas > promedio_vistas_canal AND engagement_x1k < 20.00 
            THEN 'Alerta: Tráfico Alto / Baja Retención'
        WHEN engagement_x1k >= 60.00 
            THEN 'Top Engagement Orgánico'
        ELSE 'Comportamiento Normal'
    END AS diagnostico_partnerships
FROM AnalisisCanales
ORDER BY vistas DESC;