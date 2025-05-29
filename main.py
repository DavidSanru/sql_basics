""" leaks.py

Práctica de Bases de Datos I - Curso 2024/2025
Grado en Ciencia de Datos e Inteligencia artificial
Escuela Técnica Superior de Ingeniería de Sistemas Informáticos

Autores:
Brian Bedoya Piedrahita
David Santiago Ruiz

SQL de creación de usuario:
CREATE USER 'VivaSQL'@'localhost' IDENTIFIED BY 'Entidadrelacion2025';
GRANT CREATE ON *.* TO 'usuarioprueba'@'localhost';
GRANT CREATE, SELECT, INSERT, DELETE, REFERENCES ON Leaks.* TO 'VivaSQL'@'localhost';
FLUSH PRIVILEGES;


"""

import mysql.connector
from mysql.connector import Error

mydb = mysql.connector.connect(
    host="localhost",
    user="VivaSQL",
    password="Entidadrelacion2025"
)


def initialize():
    cursor = mydb.cursor()
    cursor.execute(
        "CREATE SCHEMA IF NOT EXISTS Leaks CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS Leaks.Users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL
        )
        """
    )
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS Leaks.Documents (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL UNIQUE,
            content TEXT NOT NULL,
            created DATE NOT NULL,
            confidentiality ENUM('baja', 'media', 'alta') NOT NULL,
            user_id INT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
        )
        """
    )
    mydb.commit()


def show_menu():
    print('------- MENU -------')
    print(' 1. Crear cuenta')
    print(' 2. Login')
    print(' 3. Salir')
    print('---------------------')


def show_tasks(username):
    print(f'--- OPERACIONES (Usuario: {username}) ---')
    print(' 1. Subir documento')
    print(' 2. Listar mis documentos')
    print(' 3. Buscar por fecha')
    print(' 4. Eliminar documento')
    print(' 5. Logout')
    print('---------------------')


def create_user():
    cursor = mydb.cursor()
    username = input('Nombre de usuario: ')
    password = input('Contraseña (cuidado, visible): ')
    try:
        query = "INSERT INTO Leaks.Users (username, password) VALUES (%s, %s)"
        cursor.execute(query, (username, password))
        mydb.commit()
        print(f'Usuario {username} creado exitosamente.')
    except mysql.connector.Error as err:
        if err.errno == 1062:  # Duplicate entry
            print('Error: El nombre de usuario ya existe.')
        else:
            print(f'Error al crear usuario: {err}')


def login():
    cursor = mydb.cursor()
    username = input('Nombre de usuario: ')
    password = input('Contraseña (cuidado, visible): ')
    query = "SELECT id, username FROM Leaks.Users WHERE username = %s AND password = %s"
    cursor.execute(query, (username, password))
    result = cursor.fetchone()
    if result:
        user_id, user_name = result
        option = None
        while option != 5:
            show_tasks(user_name)
            option = int(input('Elige una opción: '))
            match option:
                case 1: doc_upload(user_id)
                case 2: doc_list(user_id)
                case 3: doc_find_by_date(user_id)
                case 4: doc_remove(user_id)
    else:
        print('Credenciales incorrectas.')


def doc_upload(user_id):
    cursor = mydb.cursor()
    title = input('Título: ')
    content = input('Contenido: ')
    created = input('Fecha (YYYY-MM-DD): ')
    confidentiality = input('Confidencialidad (baja/media/alta): ')
    try:
        query = """INSERT INTO Leaks.Documents (title, content, created, confidentiality, user_id) 
                   VALUES (%s, %s, %s, %s, %s)"""
        cursor.execute(query, (title, content, created, confidentiality, user_id))
        mydb.commit()
        print('Documento subido exitosamente.')
    except mysql.connector.Error as err:
        if err.errno == 1062:
            print('Error: Ya existe un documento con ese título.')
        else:
            print(f'Error al subir documento: {err}')


def doc_list(user_id):
    cursor = mydb.cursor()
    query = "SELECT id, title, created, confidentiality FROM Leaks.Documents WHERE user_id = %s"
    cursor.execute(query, (user_id,))
    rows = cursor.fetchall()
    if rows:
        for doc in rows:
            print(f"{doc[1]} (created: {doc[2]}, conf.: {doc[3]})")
    else:
        print('No se encontraron documentos.')


def doc_find_by_date(user_id):
    cursor = mydb.cursor()
    f_ini = input('Fecha inicial (YYYY-MM-DD): ')
    f_end = input('Fecha final (YYYY-MM-DD): ')
    query = """SELECT id, title, created FROM Leaks.Documents 
               WHERE user_id = %s AND created BETWEEN %s AND %s"""
    cursor.execute(query, (user_id, f_ini, f_end))
    rows = cursor.fetchall()
    if rows:
        for doc in rows:
            print(f"ID: {doc[0]} | Título: {doc[1]} | Fecha: {doc[2]}")
        print()
    else:
        print('No se encontraron documentos en ese rango de fechas.')


def doc_remove(user_id):
    cursor = mydb.cursor()
    doc_id = input('ID del documento a eliminar: ')
    try:
        check_query = "SELECT id FROM Leaks.Documents WHERE id = %s AND user_id = %s"
        cursor.execute(check_query, (doc_id, user_id))
        result = cursor.fetchone()
        
        if result:
            delete_query = "DELETE FROM Leaks.Documents WHERE id = %s AND user_id = %s"
            cursor.execute(delete_query, (doc_id, user_id))
            mydb.commit()
            print('Documento eliminado exitosamente.')
        else:
            print('Error: Documento no encontrado o no tienes permisos para eliminarlo.')
    except mysql.connector.Error as err:
        print(f'Error al eliminar documento: {err}')


if __name__ == '__main__':
    initialize()
    option = None
    while option != 3:
        show_menu()
        option = int(input('Elige una opción: '))
        match option:
            case 1: create_user()
            case 2: login()
            case 3: print('Saliendo...')