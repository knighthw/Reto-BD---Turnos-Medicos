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
