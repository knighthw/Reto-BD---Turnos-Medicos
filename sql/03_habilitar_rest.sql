-- =====================================================================
-- 03 · HABILITACION REST (ORDS AutoREST)
-- Proyecto: Plataforma de Turnos Medicos
-- =====================================================================
-- Habilita el esquema TURNOS_MEDICOS en ORDS y expone las 3 Duality
-- Views como endpoints REST con CRUD automatico (GET/POST/PUT/DELETE).
-- Ejecutar despues de 02_duality_views.sql.
-- =====================================================================

-- 1. Habilitar el esquema en ORDS (base path: /ords/turnos_medicos/)
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => 'TURNOS_MEDICOS',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'turnos_medicos',
    p_auto_rest_auth      => FALSE
  );
END;
/

-- 2. Exponer cada Duality View como objeto REST
BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled      => TRUE,
    p_schema       => 'TURNOS_MEDICOS',
    p_object       => 'MEDICO_TURNOS_DV',
    p_object_type  => 'VIEW',
    p_object_alias => 'medicos-turnos',
    p_auto_rest_auth => FALSE
  );
END;
/

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled      => TRUE,
    p_schema       => 'TURNOS_MEDICOS',
    p_object       => 'PACIENTE_TURNOS_DV',
    p_object_type  => 'VIEW',
    p_object_alias => 'pacientes-turnos',
    p_auto_rest_auth => FALSE
  );
END;
/

BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled      => TRUE,
    p_schema       => 'TURNOS_MEDICOS',
    p_object       => 'ESPECIALIDAD_MEDICOS_DV',
    p_object_type  => 'VIEW',
    p_object_alias => 'especialidades-medicos',
    p_auto_rest_auth => FALSE
  );
END;
/

COMMIT;

-- Verificacion
-- SELECT * FROM user_ords_schemas;
-- SELECT * FROM user_ords_enabled_objects;

-- ---------------------------------------------------------------------
-- Endpoints resultantes (reemplaza <HOST> por el host de tu instancia):
--   https://<HOST>/ords/turnos_medicos/medicos-turnos/
--   https://<HOST>/ords/turnos_medicos/pacientes-turnos/
--   https://<HOST>/ords/turnos_medicos/especialidades-medicos/
-- ---------------------------------------------------------------------
