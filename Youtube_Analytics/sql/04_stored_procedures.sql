USE YouTubeAnalytics2026;
GO

CREATE OR ALTER PROCEDURE dbo.sp_auditoria_partnerships_2026
    @min_vistas BIGINT = 1000,
    @solo_alertas BIT = 0  -- 1 para ver únicamente casos sospechosos, 0 para todo el catálogo
AS
BEGIN
    SET NOCOUNT ON;

    WITH AnalisisCanales AS (
        SELECT 
            video_id,
            titulo,
            nombre_canal,
            duracion_minutos,
            vistas,
            likes,
            comentarios,
            -- Engagement por cada 1.000 vistas
            CAST(
                CASE 
                    WHEN vistas = 0 THEN 0.00
                    ELSE ((likes + comentarios) * 1000.0) / vistas
                END AS DECIMAL(10, 2)
            ) AS engagement_x1k,
            -- Promedio del canal
            AVG(vistas) OVER (PARTITION BY nombre_canal) AS promedio_vistas_canal
        FROM dbo.tbl_videos_musicales
        WHERE vistas >= @min_vistas
    ),
    DiagnosticoFinal AS (
        SELECT 
            video_id,
            titulo,
            nombre_canal,
            duracion_minutos,
            vistas,
            promedio_vistas_canal,
            engagement_x1k,
            CASE 
                WHEN vistas > promedio_vistas_canal AND engagement_x1k < 20.00 
                    THEN 'Alerta: Tráfico Alto / Baja Retención'
                WHEN engagement_x1k >= 60.00 
                    THEN 'Top Engagement Orgánico'
                ELSE 'Comportamiento Normal'
            END AS diagnostico_partnerships
        FROM AnalisisCanales
    )
    SELECT *
    FROM DiagnosticoFinal
    WHERE (@solo_alertas = 0) 
       OR (@solo_alertas = 1 AND diagnostico_partnerships = 'Alerta: Tráfico Alto / Baja Retención')
    ORDER BY vistas DESC;
END;
GO