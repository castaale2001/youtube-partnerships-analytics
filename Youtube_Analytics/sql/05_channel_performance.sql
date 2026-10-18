USE YouTubeAnalytics2026;
GO

SELECT 
    nombre_canal,
    COUNT(*) AS total_videos,
    SUM(vistas) AS volumen_total_vistas,
    AVG(duracion_minutos) AS promedio_duracion_min,
    -- Ratio global del canal: (Total interacciones * 1000) / Total vistas
    CAST(
        (SUM(likes + comentarios) * 1000.0) / NULLIF(SUM(vistas), 0) 
        AS DECIMAL(10, 2)
    ) AS engagement_global_canal,
    -- Clasificación del canal según tamaño de audiencia
    CASE 
        WHEN SUM(vistas) >= 1000000 THEN 'Canal Grande (Mega)'
        WHEN SUM(vistas) BETWEEN 100000 AND 999999 THEN 'Canal Medio'
        ELSE 'Canal Emergente'
    END AS categoria_canal
FROM dbo.tbl_videos_musicales
GROUP BY nombre_canal
HAVING SUM(vistas) > 0  -- Excluye canales sin reproducciones
ORDER BY engagement_global_canal DESC;