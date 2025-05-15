-- =========================================
-- TESTING DE TRIGGERS Y PROCEDIMIENTOS
-- =========================================

-- ==================
-- TRIGGERS
-- ==================

-- 1. conflicto_horario_supervisor_insert
-- Este trigger debe evitar que un supervisor tenga dos partidas a la misma hora
INSERT INTO Persona (Nombre_persona) VALUES ('María');
-- Insertamos una partida con un supervisor
INSERT INTO Partida VALUES (6262626, 'Jugador_test33', '15:00:00', '2025-05-10', 'Catan', 1, 'María');
INSERT INTO Partida VALUES (6262627, 'Jugador_test34', '15:00:00', '2025-05-10', 'Catan', 2, 'María');


-- 2. conflicto_horario_jugador_insert
-- Este trigger debe evitar que un jugador participe en dos partidas a la misma hora
INSERT INTO Persona (Nombre_persona) VALUES ('Carlos'),('Ana'), ('María'),('Luis');
INSERT INTO Partida (ID_partida, Resultado, Hora, Fecha, Nombre_juego, ID_copia_juego, Supervisor)
VALUES 
(50001, 'Luis', '14:44', '2025-05-07', 'Scythe', 10, 'Carlos'),
(50002, 'Luis', '14:44', '2025-05-07', 'Catan', 8, 'Ana');
INSERT INTO Participa (ID_partida, Nombre_persona, es_ganador)
VALUES (50001, 'María', FALSE);
INSERT INTO Participa (ID_partida, Nombre_persona, es_ganador)
VALUES (50002, 'María', FALSE);


-- 3. integridad_juego_delete
-- Este trigger debe evitar que se elimine un juego que está siendo utilizado en partidas
DELETE FROM Juego_Mesa WHERE Nombre_juego = 'Catan'; 


-- 4. disponibilidad_juego_y_expansiones
-- Este trigger debe evitar que se use una copia de juego en dos partidas simultáneas
INSERT INTO Partida VALUES (06262641, 'Ana', '15:00:00', '2025-06-10', 'Catan', 1, 'María');
INSERT INTO Partida VALUES (06262640, 'Carlos', '15:00:00', '2025-06-10', 'Catan', 1, 'Luis');


-- 5. disponibilidad_expansiones_insert
-- Este trigger debe evitar que se use una copia de expansión en dos partidas simultáneas
INSERT INTO Expansion VALUES ('Expansión de Prueba');
INSERT INTO Copia_Expansion VALUES (99, 19.99, 'Expansión de Prueba');
INSERT INTO Utiliza VALUES (732, 'Expansión de Prueba', 99);
INSERT INTO Utiliza VALUES (1413, 'Expansión de Prueba', 99);


-- ==================
-- PROCEDURES
-- ==================

-- 1. registro_jugador
-- Este procedimiento debe registrar un nuevo jugador y una partida
CALL club_videojuegos.registro_jugador('Brianeitor', 'Catan', 1, 'Ana');

SELECT * FROM Persona 
WHERE Nombre_persona LIKE 'Brianeitor' 
ORDER BY Nombre_persona DESC 
LIMIT 1;

SELECT * FROM Partida 
ORDER BY ID_partida DESC 
LIMIT 1;

SELECT * FROM Participa 
WHERE Nombre_persona LIKE 'Brianeitor' 
ORDER BY ID_partida DESC 
LIMIT 1;


-- 2. listar_juegos_expansiones
-- Este procedimiento muestra una tabla con todos los juegos y sus expansiones, no requiere de test como tal
CALL listar_juegos_expansiones();
