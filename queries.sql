-- 1. Listado de jugadores: Obtén la lista de todos los jugadores que han participado en alguna partida.
SELECT DISTINCT Persona.Nombre_persona
FROM Persona
INNER JOIN Participa ON Persona.Nombre_persona = Participa.Nombre_persona
ORDER BY Persona.Nombre_persona;

-- 2. Total de juegos: Cuenta el número total de juegos disponibles en el club.
SELECT COUNT(*) AS Total_Juegos
FROM Juego_Mesa;

-- 4. Partidas en enero: Lista todas las partidas jugadas entre el 1 de enero de 2023 y el 30 de enero de 2023 (ambos incluidos).
SELECT *
FROM Partida
WHERE Fecha BETWEEN '2023-01-01' AND '2023-01-30'
ORDER BY Fecha, Hora;

-- 5. Juegos y expansiones: Muestra todos los juegos junto con sus respectivas expansiones, ordenados alfabéticamente por el nombre del juego.
SELECT DISTINCT Juego_Mesa.Nombre_juego, Expansion.Nombre_expansion
FROM Juego_Mesa
LEFT JOIN Partida ON Juego_Mesa.Nombre_juego = Partida.Nombre_juego
LEFT JOIN Utiliza ON Partida.ID_partida = Utiliza.ID_partida
LEFT JOIN Expansion ON Utiliza.Nombre_expansion = Expansion.Nombre_expansion
ORDER BY Juego_Mesa.Nombre_juego;

-- 6. Historial de partidas: Lista todas las partidas, incluyendo la información del juego jugado y el resultado, ordenadas por fecha y hora.
SELECT Partida.ID_partida, Partida.Fecha, Partida.Hora, 
Partida.Nombre_juego, Partida.Resultado, Partida.Supervisor
FROM Partida
ORDER BY Partida.Fecha, Partida.Hora;

-- 8. Personal diverso: Lista el personal que ha supervisado partidas en las que se han jugado más de tres juegos diferentes.
SELECT Supervisor
FROM club_videojuegos.Partida
GROUP BY Supervisor
HAVING COUNT(DISTINCT Nombre_juego) > 3;

-- 9. Jugador más activo: Determina qué jugador ha participado en el mayor número de partidas.
SELECT Nombre_persona
FROM club_videojuegos.Participa
GROUP BY Nombre_persona
ORDER BY COUNT(ID_partida) DESC
LIMIT 1;

-- 12. Organizadores selectivos: Lista el personal que ha organizado partidas en las que se ha utilizado la expansión «Modo Blitz» pero no la expansión «Edición Limitada».
SELECT Supervisor
FROM club_videojuegos.Partida
JOIN club_videojuegos.Utiliza ON Partida.ID_partida = Utiliza.ID_partida
JOIN club_videojuegos.Copia_Expansion ON Utiliza.ID_copia_expansion = Copia_Expansion.ID_copia_expansion
WHERE Partida.Supervisor IS NOT NULL
GROUP BY Supervisor, Partida.ID_partida
HAVING SUM(CASE WHEN Utiliza.Nombre_expansion = 'Modo Blitz' THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN Utiliza.Nombre_expansion = 'Edición Limitada' THEN 1 ELSE 0 END) = 0;

-- 13. Trayectoria de jugadores: Identifica los jugadores que han participado en partidas con el juego «Catan» y, posteriormente, en partidas con el juego «Ticket to Ride».
SELECT DISTINCT Participa.Nombre_persona
FROM club_videojuegos.Participa
JOIN club_videojuegos.Partida ON Participa.ID_partida = Partida.ID_partida
WHERE Partida.Nombre_juego = 'Catan'
AND Participa.Nombre_persona IN (
    SELECT Nombre_persona
    FROM club_videojuegos.Participa
    JOIN club_videojuegos.Partida ON Participa.ID_partida = Partida.ID_partida
    WHERE Partida.Nombre_juego = 'Ticket to Ride'
)
ORDER BY Participa.Nombre_persona;

-- 15. Ajedrez con expansiones: Encuentra a los jugadores que han participado en partidas de «Ajedrez» donde la suma del coste de las expansiones utilizadas fue menor que 55.
SELECT DISTINCT Participa.Nombre_persona
FROM club_videojuegos.Participa
JOIN club_videojuegos.Partida ON Participa.ID_partida = Partida.ID_partida
JOIN club_videojuegos.Utiliza ON Partida.ID_partida = Utiliza.ID_partida
JOIN club_videojuegos.Copia_Expansion ON Utiliza.ID_copia_expansion = Copia_Expansion.ID_copia_expansion
WHERE Partida.Nombre_juego = 'Ajedrez'
GROUP BY Participa.Nombre_persona, Partida.ID_partida
HAVING SUM(Copia_Expansion.Precio_copia_expansion) < 55;