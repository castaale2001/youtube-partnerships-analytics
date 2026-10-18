USE YouTubeAnalytics2026;
GO

SELECT 
    video_id,
    titulo,
    nombre_canal,
    duracion_minutos,
    vistas,
    likes,
    comentarios,
    -- 1. Segmentación por formato de duración
    CASE 
        WHEN duracion_segundos <= 300 THEN 'Dinámico (< 5 min)'
        ELSE 'Largo (> 5 min)'
    END AS segmento_formato,
    -- 2. Tasa de interacciones por cada 1.000 vistas
    CAST(
        CASE 
            WHEN vistas = 0 THEN 0.00
            ELSE ((likes + comentarios) * 1000.0) / vistas
        END AS DECIMAL(10, 2)
    ) AS engagement_por_mil_vistas
FROM dbo.tbl_videos_musicales
ORDER BY engagement_por_mil_vistas DESC;