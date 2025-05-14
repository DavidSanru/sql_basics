DELIMITER $$

-- 1.-Conflicto de horarios: Impedir que se asigne una partida a un jugador o al personal 
-- si ya tienen otra partida programada para la misma fecha y hora.
CREATE TRIGGER conflicto_horario_supervisor_insert
BEFORE INSERT ON Partida
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Partida
        WHERE Supervisor = NEW.Supervisor
        AND Fecha = NEW.Fecha
        AND Hora = NEW.Hora
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El supervisor ya tiene una partida asignada en ese horario';
    END IF;
END$$


CREATE TRIGGER conflicto_horario_jugador_insert
BEFORE INSERT ON Participa
FOR EACH ROW
BEGIN
    DECLARE v_fecha DATE;
    DECLARE v_hora TIME;
    SELECT Fecha, Hora INTO v_fecha, v_hora
    FROM Partida
    WHERE ID_partida = NEW.ID_partida;
    IF EXISTS (
        SELECT 1
        FROM Participa
        JOIN Partida ON Participa.ID_partida = Partida.ID_partida
        WHERE Participa.Nombre_persona = NEW.Nombre_persona
        AND Partida.Fecha = v_fecha
        AND Partida.Hora = v_hora
        AND Participa.ID_partida != NEW.ID_partida
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El jugador ya tiene una partida asignada en ese horario';
    END IF;
END$$

-- 2.- Integridad de juegos: Evitar que se pueda eliminar un juego si existe al menos una partida programada que lo incluya
CREATE TRIGGER integridad_juego_delete
BEFORE DELETE ON Juego_Mesa
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Partida 
        WHERE Nombre_juego = OLD.Nombre_juego
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede eliminar el juego, existen partidas programadas';
    END IF;
END$$


-- 3.-Bonus track: Impedir que se asigne una partida con un juego y unas expansiones si todas las copias
-- de estos están ya asignados a partidas para la misma fecha y hora.

CREATE TRIGGER disponibilidad_juego_y_expansiones
BEFORE INSERT ON Partida
FOR EACH ROW
BEGIN
    DECLARE total_copias_juego INT;
    DECLARE copias_usadas INT;
    DECLARE copias_disponibles INT;
    
    SELECT COUNT(*) INTO total_copias_juego 
    FROM Copia_Juego_Mesa 
    WHERE Nombre_juego = NEW.Nombre_juego;
    
    SELECT COUNT(*) INTO copias_usadas 
    FROM Partida 
    WHERE Nombre_juego = NEW.Nombre_juego 
    AND Fecha = NEW.Fecha 
    AND Hora = NEW.Hora
    AND ID_partida != NEW.ID_partida;
    
    SET copias_disponibles = total_copias_juego - copias_usadas;
    
    IF copias_disponibles <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Todas las copias del juego están ocupadas para esa fecha y hora';
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM Partida
        WHERE ID_copia_juego = NEW.ID_copia_juego
        AND Fecha = NEW.Fecha
        AND Hora = NEW.Hora
        AND ID_partida != NEW.ID_partida
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La copia del juego ya está asignada para esa fecha y hora';
    END IF;
END$$

CREATE TRIGGER disponibilidad_expansiones_insert
BEFORE INSERT ON Utiliza
FOR EACH ROW
BEGIN
    DECLARE fecha_partida DATE;
    DECLARE hora_partida TIME;
    DECLARE total_copias_expansion INT;
    DECLARE copias_usadas INT;
    DECLARE copias_disponibles INT;
    
    SELECT Fecha, Hora INTO fecha_partida, hora_partida
    FROM Partida
    WHERE ID_partida = NEW.ID_partida;
    
    SELECT COUNT(*) INTO total_copias_expansion
    FROM Copia_Expansion
    WHERE Nombre_expansion = NEW.Nombre_expansion;
    
    SELECT COUNT(*) INTO copias_usadas
    FROM Utiliza
    JOIN Partida ON Utiliza.ID_partida = Partida.ID_partida
    WHERE Utiliza.Nombre_expansion = NEW.Nombre_expansion
    AND Partida.Fecha = fecha_partida
    AND Partida.Hora = hora_partida
    AND Utiliza.ID_partida != NEW.ID_partida;

    SET copias_disponibles = total_copias_expansion - copias_usadas;

    IF copias_disponibles <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Todas las copias de la expansión están ocupadas para esa fecha y hora';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Utiliza
        JOIN Partida ON Utiliza.ID_partida = Partida.ID_partida
        WHERE Utiliza.ID_copia_expansion = NEW.ID_copia_expansion
        AND Utiliza.Nombre_expansion = NEW.Nombre_expansion
        AND Partida.Fecha = fecha_partida
        AND Partida.Hora = hora_partida
        AND Utiliza.ID_partida != NEW.ID_partida
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La copia de la expansión ya está asignada para esa fecha y hora';
    END IF;
END$$

DELIMITER ;