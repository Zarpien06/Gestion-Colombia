-- Crear la base de datos
CREATE DATABASE colombia;
USE colombia;

-- Crear tabla departamentos
CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

-- Crear tabla ciudades
CREATE TABLE ciudades (
    id_ciudad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_departamento INT,
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
);

-- Insertar departamentos
INSERT INTO departamentos (nombre) VALUES 
('Antioquia'), 
('Valle'), 
('Santander');

INSERT INTO ciudades (nombre, id_departamento) VALUES
('Medellin', 1),
('Turbo', 1),
('Cali', 2),
('Bucaramanga', 3),
('Bogota', NULL); 

