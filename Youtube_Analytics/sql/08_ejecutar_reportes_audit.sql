-- Ejecutar reporte completo
EXEC dbo.sp_auditoria_partnerships_2026 @min_vistas = 5000, @solo_alertas = 0;

-- Filtrar únicamente videos con alerta de tráfico inflado
EXEC dbo.sp_auditoria_partnerships_2026 @min_vistas = 5000, @solo_alertas = 1;