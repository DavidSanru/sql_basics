CREATE DATABASE IF NOT EXISTS club_videojuegos
CHARACTER SET utf8mb4
COLLATE utf8mb4_bin;

USE club_videojuegos;

CREATE TABLE Juego_Mesa (
    Nombre_juego VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Copia_Juego_Mesa (
    ID_copia_juego INT NOT NULL,
    Precio_copia_juego DECIMAL(10,2) NOT NULL,
    Nombre_juego VARCHAR(100) NOT NULL,
    PRIMARY KEY (ID_copia_juego, Nombre_juego),
    FOREIGN KEY (Nombre_juego) REFERENCES Juego_Mesa(Nombre_juego)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Expansion (
    Nombre_expansion VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Copia_Expansion (
    ID_copia_expansion INT NOT NULL,
    Precio_copia_expansion DECIMAL(10,2) NOT NULL, 
    Nombre_expansion VARCHAR(100) NOT NULL,
    PRIMARY KEY (ID_copia_expansion, Nombre_expansion),
    FOREIGN KEY (Nombre_expansion) REFERENCES Expansion(Nombre_expansion)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Persona (
    Nombre_persona VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Partida (
    ID_partida INT PRIMARY KEY,
    Resultado VARCHAR(100) NOT NULL,
    Hora TIME NOT NULL,
    Fecha DATE NOT NULL,
    Nombre_juego VARCHAR(100) NOT NULL,
    ID_copia_juego INT NOT NULL,
    Supervisor VARCHAR(100) NOT NULL,
    FOREIGN KEY (Nombre_juego) REFERENCES Juego_Mesa(Nombre_juego)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_copia_juego) REFERENCES Copia_Juego_Mesa(ID_copia_juego)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,   
    FOREIGN KEY (Supervisor) REFERENCES Persona(Nombre_persona)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Utiliza(
    ID_partida INT,
    Nombre_expansion VARCHAR(100),
    ID_copia_expansion INT,
    PRIMARY KEY (ID_partida, Nombre_expansion, ID_copia_expansion),
    FOREIGN KEY (ID_partida) REFERENCES Partida(ID_partida)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Nombre_expansion) REFERENCES Expansion(Nombre_expansion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (ID_copia_expansion) REFERENCES Copia_Expansion(ID_copia_expansion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Participa(
    ID_partida INT NOT NULL,
    Nombre_persona VARCHAR(100) NOT NULL,
    es_ganador BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (ID_partida, Nombre_persona),
    FOREIGN KEY (ID_partida) REFERENCES Partida(ID_partida)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Nombre_persona) REFERENCES Persona(Nombre_persona)
        ON DELETE RESTRICT
        ON UPDATE CASCADE

)