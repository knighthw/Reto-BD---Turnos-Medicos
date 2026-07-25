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
