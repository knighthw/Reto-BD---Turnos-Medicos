-- =====================================================================
-- 04 · SELECT AI (NLQ) + ENDPOINT REST DEL ASISTENTE IA
-- Proyecto: Plataforma de Turnos Medicos
-- Provider: Google Gemini  ·  Modelo: gemini-flash-latest
-- =====================================================================
-- Configura Oracle Select AI (DBMS_CLOUD_AI) para responder preguntas
-- en lenguaje natural sobre la base, y publica un endpoint REST manual
-- POST /ai/consulta que ejecuta DBMS_CLOUD_AI.GENERATE.
--
--  IMPORTANTE - SEGURIDAD:
--  Reemplaza el placeholder 'TU_API_KEY_DE_GEMINI_AQUI' por tu propia
--  API key de Google Gemini. NO subas la key real al repositorio.
--
--  Si tu region/tenancy usa un proxy de salida, puede requerirse una ACL
--  de red (DBMS_NETWORK_ACL_ADMIN) para permitir el acceso al provider.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Credencial del provider (Google Gemini)
-- ---------------------------------------------------------------------
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'GEMINI_CRED',
    username        => 'GEMINI',
    password        => 'TU_API_KEY_DE_GEMINI_AQUI'   -- <-- reemplaza por tu API key
  );
END;
/

-- SELECT credential_name, username, enabled FROM user_credentials;

-- ---------------------------------------------------------------------
-- 2. Perfil de Select AI  (modelo gemini-flash-latest)
--    object_list = tablas que la IA puede consultar
-- ---------------------------------------------------------------------
BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'TURNOS_AI',
    attributes   => '{
      "provider": "google",
      "credential_name": "GEMINI_CRED",
      "model": "gemini-flash-latest",
      "object_list": [
        {"owner": "TURNOS_MEDICOS", "name": "MEDICO"},
        {"owner": "TURNOS_MEDICOS", "name": "PACIENTE"},
        {"owner": "TURNOS_MEDICOS", "name": "TURNO"},
        {"owner": "TURNOS_MEDICOS", "name": "ESPECIALIDAD"}
      ]
    }'
  );
END;
/

-- Fijar el perfil como activo para la sesion
BEGIN
  DBMS_CLOUD_AI.SET_PROFILE('TURNOS_AI');
END;
/

-- ---------------------------------------------------------------------
-- 3. Endpoint REST manual: POST /ai/consulta
--    Body JSON esperado:  { "prompt": "cuantos medicos hay" }
--    Respuesta JSON:      { "respuesta": "..." }
-- ---------------------------------------------------------------------
BEGIN
  ORDS.DEFINE_MODULE(
    p_module_name    => 'ai.module',
    p_base_path      => '/ai/',
    p_items_per_page => 0
  );

  ORDS.DEFINE_TEMPLATE(
    p_module_name => 'ai.module',
    p_pattern     => 'consulta'
  );

  ORDS.DEFINE_HANDLER(
    p_module_name   => 'ai.module',
    p_pattern       => 'consulta',
    p_method        => 'POST',
    p_mimes_allowed => 'application/json',
    p_source_type   => ORDS.source_type_plsql,
    p_source        => q'[DECLARE
  l_req    JSON_OBJECT_T;
  l_prompt VARCHAR2(4000);
  l_result CLOB;
  l_resp   JSON_OBJECT_T := JSON_OBJECT_T();
BEGIN
  l_req    := JSON_OBJECT_T(:body);
  l_prompt := l_req.get_string('prompt');
  l_result := DBMS_CLOUD_AI.GENERATE(prompt => l_prompt, profile_name => 'TURNOS_AI', action => 'narrate');
  l_resp.put('respuesta', l_result);
  OWA_UTIL.MIME_HEADER('application/json', TRUE);
  HTP.P(l_resp.to_string);
END;]'
  );
END;
/

COMMIT;

-- ---------------------------------------------------------------------
-- Endpoint resultante (reemplaza <HOST> por el host de tu instancia):
--   POST https://<HOST>/ords/turnos_medicos/ai/consulta
-- Ejemplos de uso de SELECT AI: ver sql/ejemplos_select_ai.sql
-- ---------------------------------------------------------------------
