-- =====================================================================
-- EJEMPLOS · Consultas en lenguaje natural con SELECT AI
-- Proyecto: Plataforma de Turnos Medicos
-- =====================================================================
-- Requiere haber ejecutado antes 04_select_ai_y_endpoint.sql
-- (credencial + perfil TURNOS_AI configurados y activos).
--
-- Ejecuta cada linea por separado. La accion tras "SELECT AI" cambia
-- el tipo de respuesta:
--   (sin accion) -> ejecuta y devuelve el resultado
--   showsql      -> muestra el SQL que genero la IA
--   narrate      -> respuesta en lenguaje natural
-- =====================================================================

-- Asegura que el perfil este activo en esta sesion:
-- BEGIN DBMS_CLOUD_AI.SET_PROFILE('TURNOS_AI'); END;
-- /

SELECT AI cuantos medicos hay;

SELECT AI showsql cuantos medicos hay;

SELECT AI cuantos turnos tiene cada medico este mes;

SELECT AI narrate que medico tiene mas turnos cancelados;
