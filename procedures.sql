DELIMITER $$

-- 1.- Registro de jugador: Automatizar el proceso de registro de un nuevo jugador en la base de datos,
-- asignarle su primera partida y generar su primera inscripción en el sistema.

CREATE PROCEDURE registro_jugador(
    nombre VARCHAR(100),
    juego VARCHAR(100),
    copia INT,
    supervisor VARCHAR(100)
)
BEGIN
    DECLARE nuevo_id INT;
    
    SELECT MAX(ID_partida) + 1 INTO nuevo_id FROM Partida;
    IF nuevo_id IS NULL THEN
        SET nuevo_id = 1;
    END IF;
    
    INSERT INTO Persona VALUES (nombre);
    
    INSERT INTO Partida VALUES (nuevo_id, 'Primera partida', CURTIME(), CURDATE(), juego, copia, supervisor);
    
    INSERT INTO Participa VALUES (nuevo_id, nombre, FALSE);
END$$

-- 2.-Listado de juegos y expansiones: Crear un procedimiento almacenado que liste todos los juegos junto con sus expansiones,
-- presentando la lista de expansiones separada por comas y mostrando el coste de cada una entre paréntesis.

CREATE PROCEDURE listar_juegos_expansiones()
BEGIN
    SELECT 
        Juego_Mesa.Nombre_juego,
        GROUP_CONCAT(DISTINCT CONCAT(Expansion.Nombre_expansion, ' (', Copia_Expansion.Precio_copia_expansion, ')')
            ORDER BY Expansion.Nombre_expansion SEPARATOR ', ') AS Expansiones
    FROM 
        Juego_Mesa
        LEFT JOIN Partida ON Juego_Mesa.Nombre_juego = Partida.Nombre_juego
        LEFT JOIN Utiliza ON Partida.ID_partida = Utiliza.ID_partida
        LEFT JOIN Expansion ON Utiliza.Nombre_expansion = Expansion.Nombre_expansion
        LEFT JOIN Copia_Expansion ON Expansion.Nombre_expansion = Copia_Expansion.Nombre_expansion
    GROUP BY 
        Juego_Mesa.Nombre_juego;
END$$

DELIMITER ;