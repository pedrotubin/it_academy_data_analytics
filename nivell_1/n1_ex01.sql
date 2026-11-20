/*
Nivell 1 - Exercici 1
A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules.
Mostra les característiques principals de l'esquema creat i explica les diferents taules i
variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació entre les
diferents taules i variables.
*/

-- Creamos la base de datos
DROP DATABASE IF EXISTS transactions;
CREATE DATABASE IF NOT EXISTS transactions;
USE transactions;

-- Creamos la tabla company
CREATE TABLE IF NOT EXISTS company (
    id           VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone        VARCHAR(15),
    email        VARCHAR(100),
    country      VARCHAR(100),
    website      VARCHAR(255)
);

-- Creamos la tabla transaction
CREATE TABLE IF NOT EXISTS transaction (
    id             VARCHAR(255) PRIMARY KEY,
    credit_card_id VARCHAR(15), -- REFERENCES credit_card(id)
    company_id     VARCHAR(20),
    user_id        INT,         -- REFERENCES user(id)
    lat            FLOAT,
    longitude      FLOAT,
    timestamp      TIMESTAMP,
    amount         DECIMAL(10, 2),
    declined       BOOLEAN,
    FOREIGN KEY (company_id) REFERENCES company(id)
);

-- Ejecutar aquí el archivo N1-Ex.1__dades_introduir.sql
