-- =====================================================================
-- CATALOGO DE CONSULTAS SQL OPTIMIZADAS
-- Proyecto: Plataforma de Turnos Medicos
-- D5: 15 consultas -- version original y version optimizada de cada una
-- =====================================================================
-- INSTRUCCIONES DE USO:
-- 1) Ejecuta primero el bloque de INDICES (una sola vez).
-- 2) Para cada consulta: ejecuta el EXPLAIN PLAN de la version ANTES,
--    luego el SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY) para ver el plan.
-- 3) Repite lo mismo con la version DESPUES.
-- 4) Copia el resultado de cada DBMS_XPLAN.DISPLAY (Cost, Operation,
--    Rows, Bytes) -- esos son los datos que necesito para armar la tabla
--    comparativa del informe (ver mensaje de chat).
-- Ejecuta cada sentencia por separado (Ctrl+Enter), no todo el script
-- de golpe, para poder revisar cada plan individualmente.
-- =====================================================================


-- =====================================================================
-- 0. INDICES DE OPTIMIZACION (ejecutar una sola vez, antes que todo)
-- =====================================================================

CREATE INDEX idx_turno_medico ON turno(id_medico);

CREATE INDEX idx_turno_paciente ON turno(id_paciente);

CREATE INDEX idx_medico_especialidad ON medico(id_especialidad);

CREATE INDEX idx_turno_fecha ON turno(fecha);


-- =====================================================================
-- CONSULTA 1: Medicos con al menos un turno atendido
-- Tecnica: subconsulta IN -> JOIN
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT nombre FROM medico WHERE id_medico IN (SELECT id_medico FROM turno WHERE estado = 'ATENDIDO');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT DISTINCT m.nombre FROM medico m JOIN turno t ON t.id_medico = m.id_medico WHERE t.estado = 'ATENDIDO';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 2: Pacientes con al menos un turno cancelado
-- Tecnica: IN -> EXISTS
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT nombre FROM paciente WHERE id_paciente IN (SELECT id_paciente FROM turno WHERE estado = 'CANCELADO');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT p.nombre FROM paciente p WHERE EXISTS (SELECT 1 FROM turno t WHERE t.id_paciente = p.id_paciente AND t.estado = 'CANCELADO');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 3: Medicos con mas de 2 turnos registrados
-- Tecnica: join implicito con coma -> JOIN ANSI explicito
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT m.nombre, COUNT(*) AS total FROM medico m, turno t WHERE m.id_medico = t.id_medico GROUP BY m.nombre HAVING COUNT(*) > 2;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT m.nombre, COUNT(*) AS total FROM medico m JOIN turno t ON t.id_medico = m.id_medico GROUP BY m.nombre HAVING COUNT(*) > 2;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 4: Carga de turnos por medico sin colapsar filas
-- Tecnica: subconsulta repetida por fila -> funcion analitica
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT m.nombre, t.fecha, (SELECT COUNT(*) FROM turno t2 WHERE t2.id_medico = t.id_medico) AS total_turnos FROM medico m JOIN turno t ON t.id_medico = m.id_medico;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT m.nombre, t.fecha, COUNT(*) OVER (PARTITION BY m.id_medico) AS total_turnos FROM medico m JOIN turno t ON t.id_medico = m.id_medico;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 5: Turnos activos e inactivos combinados
-- Tecnica: UNION -> UNION ALL
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT id_turno, 'ACTIVO' AS grupo FROM turno WHERE estado = 'ATENDIDO' UNION SELECT id_turno, 'INACTIVO' AS grupo FROM turno WHERE estado = 'CANCELADO';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT id_turno, 'ACTIVO' AS grupo FROM turno WHERE estado = 'ATENDIDO' UNION ALL SELECT id_turno, 'INACTIVO' AS grupo FROM turno WHERE estado = 'CANCELADO';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 6: Total de turnos por paciente
-- Tecnica: subconsulta escalar correlacionada -> LEFT JOIN agregado
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT p.nombre, (SELECT COUNT(*) FROM turno t WHERE t.id_paciente = p.id_paciente) AS total_turnos FROM paciente p;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT p.nombre, COUNT(t.id_turno) AS total_turnos FROM paciente p LEFT JOIN turno t ON t.id_paciente = p.id_paciente GROUP BY p.nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 7: Pacientes que nunca han tenido un turno
-- Tecnica: NOT IN -> NOT EXISTS
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT nombre FROM paciente WHERE id_paciente NOT IN (SELECT id_paciente FROM turno);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT p.nombre FROM paciente p WHERE NOT EXISTS (SELECT 1 FROM turno t WHERE t.id_paciente = p.id_paciente);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 8: Turnos de la semana actual
-- Tecnica: funcion sobre columna -> predicado sargable (rango)
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT * FROM turno WHERE TRUNC(fecha, 'IW') = TRUNC(SYSDATE, 'IW');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT * FROM turno WHERE fecha >= TRUNC(SYSDATE, 'IW') AND fecha < TRUNC(SYSDATE, 'IW') + 7;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 9: Medicos por especialidad con conteo
-- Tecnica: subconsulta anidada por fila -> JOIN + agregacion unica
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT e.nombre, (SELECT COUNT(*) FROM medico m WHERE m.id_especialidad = e.id_especialidad) AS total FROM especialidad e;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT e.nombre, COUNT(m.id_medico) AS total FROM especialidad e LEFT JOIN medico m ON m.id_especialidad = e.id_especialidad GROUP BY e.nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 10: Turno mas reciente de cada medico
-- Tecnica: subconsulta MAX correlacionada -> ROW_NUMBER analitico
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT t.* FROM turno t WHERE t.fecha = (SELECT MAX(t2.fecha) FROM turno t2 WHERE t2.id_medico = t.id_medico);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT * FROM (SELECT t.*, ROW_NUMBER() OVER (PARTITION BY t.id_medico ORDER BY t.fecha DESC) AS rn FROM turno t) WHERE rn = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 11: Porcentaje de turnos atendidos por medico
-- Tecnica: dos subconsultas separadas -> una sola pasada con CASE
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT m.nombre, (SELECT COUNT(*) FROM turno t WHERE t.id_medico = m.id_medico AND t.estado = 'ATENDIDO') * 100 / (SELECT COUNT(*) FROM turno t WHERE t.id_medico = m.id_medico) AS pct FROM medico m;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT m.nombre, ROUND(SUM(CASE WHEN t.estado = 'ATENDIDO' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS pct FROM medico m JOIN turno t ON t.id_medico = m.id_medico GROUP BY m.nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 12: Especialidades sin ningun medico asignado
-- Tecnica: NOT IN -> anti-join con NOT EXISTS
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT nombre FROM especialidad e WHERE e.id_especialidad NOT IN (SELECT id_especialidad FROM medico);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT e.nombre FROM especialidad e WHERE NOT EXISTS (SELECT 1 FROM medico m WHERE m.id_especialidad = e.id_especialidad);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 13: Pacientes atendidos por mas de un medico distinto
-- Tecnica: join implicito con coma -> JOIN ANSI explicito
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT p.nombre FROM paciente p, turno t WHERE p.id_paciente = t.id_paciente GROUP BY p.nombre HAVING COUNT(DISTINCT t.id_medico) > 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT p.nombre FROM paciente p JOIN turno t ON t.id_paciente = p.id_paciente GROUP BY p.nombre HAVING COUNT(DISTINCT t.id_medico) > 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 14: Turnos duplicados (mismo medico, misma fecha y hora)
-- Tecnica: self-join -> funcion analitica
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT t1.id_turno FROM turno t1, turno t2 WHERE t1.id_medico = t2.id_medico AND t1.fecha = t2.fecha AND t1.hora = t2.hora AND t1.id_turno <> t2.id_turno;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT id_turno FROM (SELECT id_turno, COUNT(*) OVER (PARTITION BY id_medico, fecha, hora) AS conflictos FROM turno) WHERE conflictos > 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- CONSULTA 15: Vista jerarquica completa
-- especialidad -> medico -> turnos -> paciente
-- Tecnica: join implicito con coma -> JOINs ANSI explicitos con indices
-- =====================================================================

-- ANTES
EXPLAIN PLAN FOR SELECT e.nombre AS especialidad, m.nombre AS medico, t.fecha, p.nombre AS paciente FROM especialidad e, medico m, turno t, paciente p WHERE e.id_especialidad = m.id_especialidad AND m.id_medico = t.id_medico AND t.id_paciente = p.id_paciente;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- DESPUES
EXPLAIN PLAN FOR SELECT e.nombre AS especialidad, m.nombre AS medico, t.fecha, p.nombre AS paciente FROM especialidad e JOIN medico m ON m.id_especialidad = e.id_especialidad JOIN turno t ON t.id_medico = m.id_medico JOIN paciente p ON p.id_paciente = t.id_paciente;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =====================================================================
-- FIN DEL CATALOGO
-- =====================================================================