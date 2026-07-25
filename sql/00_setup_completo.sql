-- #####################################################################
-- #  00 · SCRIPT MAESTRO — RECONSTRUCCION COMPLETA
-- #  Proyecto: Plataforma de Turnos Medicos  ·  Esquema: TURNOS_MEDICOS
-- #####################################################################
-- Ejecuta este archivo de arriba a abajo, conectado como el usuario
-- TURNOS_MEDICOS y sobre un esquema LIMPIO, para reconstruir todo:
--
--   1) Tablas + datos de prueba
--   2) JSON Relational Duality Views (3)
--   3) Habilitacion REST (ORDS AutoREST)
--   4) Select AI (Gemini) + endpoint REST del asistente IA
--
--  ANTES DE EJECUTAR:
--  En la seccion 4, reemplaza el placeholder 'TU_API_KEY_DE_GEMINI_AQUI'
--  por tu propia API key de Google Gemini. NO subas la key real al repo.
--
--  En Database Actions (SQL) o SQLcl puedes ejecutar el script completo.
--  El catalogo de consultas optimizadas (05_consultas_optimizadas.sql)
--  es analitico y se ejecuta por separado; no forma parte del setup.
-- #####################################################################


-- #####################################################################
-- #  SECCION 1
-- #####################################################################
-- =====================================================================
-- 01 · TABLAS + DATOS DE PRUEBA
-- Proyecto: Plataforma de Turnos Medicos
-- Esquema: TURNOS_MEDICOS
-- =====================================================================
-- Crea las 4 tablas del modelo y carga un juego de datos de prueba.
-- Las llaves primarias usan IDENTITY (autonumericas, empiezan en 1),
-- por lo que este script debe ejecutarse sobre un esquema LIMPIO para
-- que los IDs coincidan con las referencias de mas abajo.
-- =====================================================================

-- ---------------------------------------------------------------------
-- TABLAS
-- ---------------------------------------------------------------------
CREATE TABLE especialidad (
  id_especialidad NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre          VARCHAR2(100) NOT NULL
);

CREATE TABLE medico (
  id_medico       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre          VARCHAR2(100) NOT NULL,
  id_especialidad NUMBER REFERENCES especialidad(id_especialidad)
);

CREATE TABLE paciente (
  id_paciente NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre      VARCHAR2(100) NOT NULL,
  cedula      VARCHAR2(20)  NOT NULL
);

CREATE TABLE turno (
  id_turno    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_medico   NUMBER REFERENCES medico(id_medico),
  id_paciente NUMBER REFERENCES paciente(id_paciente),
  fecha       DATE NOT NULL,
  hora        VARCHAR2(10),
  estado      VARCHAR2(20) DEFAULT 'PENDIENTE'
);

-- ---------------------------------------------------------------------
-- ESPECIALIDADES  (ids 1..7)
-- ---------------------------------------------------------------------
INSERT INTO especialidad (nombre) VALUES ('Medicina General');  -- 1
INSERT INTO especialidad (nombre) VALUES ('Pediatría');         -- 2
INSERT INTO especialidad (nombre) VALUES ('Cardiología');       -- 3
INSERT INTO especialidad (nombre) VALUES ('Dermatología');      -- 4
INSERT INTO especialidad (nombre) VALUES ('Neurología');        -- 5
INSERT INTO especialidad (nombre) VALUES ('Ginecología');       -- 6
INSERT INTO especialidad (nombre) VALUES ('Traumatología');     -- 7

-- ---------------------------------------------------------------------
-- MEDICOS  (ids 1..8)
-- ---------------------------------------------------------------------
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dr. Carlos Pérez',    1);  -- 1
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dra. Ana Torres',     2);  -- 2
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dr. Luis Ramírez',    3);  -- 3
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dra. Sofía Vélez',    4);  -- 4
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dr. Miguel Andrade',  5);  -- 5
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dra. Carla Espinoza', 6);  -- 6
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dr. Jorge Ruiz',      7);  -- 7
INSERT INTO medico (nombre, id_especialidad) VALUES ('Dra. Elena Vaca',     1);  -- 8

-- ---------------------------------------------------------------------
-- PACIENTES  (ids 1..12)
-- ---------------------------------------------------------------------
INSERT INTO paciente (nombre, cedula) VALUES ('Juan Morales',      '0102030405');  -- 1
INSERT INTO paciente (nombre, cedula) VALUES ('María López',       '0203040506');  -- 2
INSERT INTO paciente (nombre, cedula) VALUES ('Pedro Sánchez',     '0304050607');  -- 3
INSERT INTO paciente (nombre, cedula) VALUES ('Lucía Fernández',   '0405060708');  -- 4
INSERT INTO paciente (nombre, cedula) VALUES ('Andrés Castillo',   '0506070809');  -- 5
INSERT INTO paciente (nombre, cedula) VALUES ('Valeria Cordero',   '0607080910');  -- 6
INSERT INTO paciente (nombre, cedula) VALUES ('Roberto Jiménez',   '0708091011');  -- 7
INSERT INTO paciente (nombre, cedula) VALUES ('Carmen Ortega',     '0809101112');  -- 8
INSERT INTO paciente (nombre, cedula) VALUES ('Diego Salazar',     '0910111213');  -- 9
INSERT INTO paciente (nombre, cedula) VALUES ('Patricia Núñez',    '1011121314');  -- 10
INSERT INTO paciente (nombre, cedula) VALUES ('Fernando Cabrera',  '1112131415');  -- 11
INSERT INTO paciente (nombre, cedula) VALUES ('Gabriela Mora',     '1213141516');  -- 12

-- ---------------------------------------------------------------------
-- TURNOS
-- estado: PENDIENTE / ATENDIDO / CANCELADO
-- Las fechas se calculan relativas a SYSDATE para que siempre haya
-- turnos "de hoy", "de esta semana" y "de este mes".
-- ---------------------------------------------------------------------
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 1, TRUNC(SYSDATE),      '08:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 2, TRUNC(SYSDATE),      '09:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 3, TRUNC(SYSDATE) - 2,  '10:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (2, 4, TRUNC(SYSDATE),      '11:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (2, 5, TRUNC(SYSDATE) - 3,  '12:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (3, 6, TRUNC(SYSDATE),      '13:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (3, 1, TRUNC(SYSDATE) - 10, '14:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (4, 2, TRUNC(SYSDATE) - 15, '15:00', 'CANCELADO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (4, 3, TRUNC(SYSDATE),      '16:00', 'PENDIENTE');

-- Turnos adicionales (referencian medicos 5..8 y pacientes 7..12)
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 4,  TRUNC(SYSDATE),      '08:30', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 5,  TRUNC(SYSDATE),      '09:30', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (2, 6,  TRUNC(SYSDATE) - 1,  '10:30', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (2, 7,  TRUNC(SYSDATE) - 1,  '11:30', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (3, 7,  TRUNC(SYSDATE) - 4,  '08:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (3, 8,  TRUNC(SYSDATE) - 4,  '09:00', 'CANCELADO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (5, 9,  TRUNC(SYSDATE) - 5,  '14:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (5, 10, TRUNC(SYSDATE) - 6,  '15:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (6, 11, TRUNC(SYSDATE) - 7,  '16:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (6, 12, TRUNC(SYSDATE) - 8,  '08:45', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (7, 1,  TRUNC(SYSDATE) - 12, '10:15', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (7, 2,  TRUNC(SYSDATE) - 20, '11:00', 'CANCELADO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (8, 3,  TRUNC(SYSDATE) - 25, '13:30', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (8, 4,  TRUNC(SYSDATE) - 30, '14:30', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (1, 6,  TRUNC(SYSDATE) - 2,  '12:00', 'ATENDIDO');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (2, 7,  TRUNC(SYSDATE) - 3,  '13:00', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (3, 9,  TRUNC(SYSDATE),      '15:30', 'PENDIENTE');
INSERT INTO turno (id_medico, id_paciente, fecha, hora, estado) VALUES (5, 11, TRUNC(SYSDATE) - 1,  '16:30', 'ATENDIDO');

COMMIT;


-- #####################################################################
-- #  SECCION 2
-- #####################################################################
-- =====================================================================
-- 02 · JSON RELATIONAL DUALITY VIEWS
-- Proyecto: Plataforma de Turnos Medicos
-- =====================================================================
-- Modelado hibrido: expone las tablas relacionales como documentos JSON
-- editables (soportan GET/POST/PUT/DELETE via ORDS AutoREST).
--
--   medico_turnos_dv       : medico -> sus turnos -> paciente de cada turno
--   paciente_turnos_dv     : paciente -> sus turnos -> medico de cada turno
--   especialidad_medicos_dv: especialidad -> sus medicos
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Duality View — Medico
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW medico_turnos_dv AS
SELECT JSON {
  '_id'   : m.id_medico,
  'nombre': m.nombre,
  'turnos': [
    SELECT JSON {
      'idTurno' : t.id_turno,
      'fecha'   : t.fecha,
      'hora'    : t.hora,
      'estado'  : t.estado,
      'paciente': [
        SELECT JSON {
          'idPaciente': p.id_paciente,
          'nombre'    : p.nombre,
          'cedula'    : p.cedula
        }
        FROM paciente p WITH INSERT UPDATE DELETE
        WHERE p.id_paciente = t.id_paciente
      ]
    }
    FROM turno t WITH INSERT UPDATE DELETE
    WHERE t.id_medico = m.id_medico
  ]
}
FROM medico m WITH INSERT UPDATE DELETE;

-- ---------------------------------------------------------------------
-- 2. Duality View — Paciente
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW paciente_turnos_dv AS
SELECT JSON {
  '_id'   : p.id_paciente,
  'nombre': p.nombre,
  'cedula': p.cedula,
  'turnos': [
    SELECT JSON {
      'idTurno': t.id_turno,
      'fecha'  : t.fecha,
      'hora'   : t.hora,
      'estado' : t.estado,
      'medico' : [
        SELECT JSON {
          'idMedico': m.id_medico,
          'nombre'  : m.nombre
        }
        FROM medico m WITH INSERT UPDATE DELETE
        WHERE m.id_medico = t.id_medico
      ]
    }
    FROM turno t WITH INSERT UPDATE DELETE
    WHERE t.id_paciente = p.id_paciente
  ]
}
FROM paciente p WITH INSERT UPDATE DELETE;

-- ---------------------------------------------------------------------
-- 3. Duality View — Especialidad
-- ---------------------------------------------------------------------
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW especialidad_medicos_dv AS
SELECT JSON {
  '_id'    : e.id_especialidad,
  'nombre' : e.nombre,
  'medicos': [
    SELECT JSON {
      'idMedico': m.id_medico,
      'nombre'  : m.nombre
    }
    FROM medico m WITH INSERT UPDATE DELETE
    WHERE m.id_especialidad = e.id_especialidad
  ]
}
FROM especialidad e WITH INSERT UPDATE DELETE;

-- Verificacion rapida
-- SELECT * FROM medico_turnos_dv;
-- SELECT * FROM paciente_turnos_dv;
-- SELECT * FROM especialidad_medicos_dv;


-- #####################################################################
-- #  SECCION 3
-- #####################################################################
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


-- #####################################################################
-- #  SECCION 4
-- #####################################################################
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


-- #####################################################################
-- #  FIN DEL SCRIPT MAESTRO
-- #####################################################################
