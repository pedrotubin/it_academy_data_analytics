/*
Nivell 1 - Exercici 8
Descarrega els arxius CSV que trobaràs a l'apartat de recursos:
american_users.csv, european_users.csv, companies.csv, credit_cards.csv, transactions.csv
Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys
4 taules de les quals puguis realitzar les següents consultes.
La taula de products.csv l'utilitzarem més endavant.
*/

DROP DATABASE IF EXISTS payments_dw;
CREATE DATABASE payments_dw;
USE payments_dw;

SET GLOBAL local_infile = 1;

-- Tabla users
CREATE TABLE IF NOT EXISTS users (
    id           INT PRIMARY KEY,
    name         VARCHAR(255),
    surname      VARCHAR(255),
    phone        VARCHAR(20),
    email        VARCHAR(255),
    birth_date   DATE,
    country      VARCHAR(50),
    city         VARCHAR(50),
    postal_code  VARCHAR(20),
    address      VARCHAR(255),
    signup_date  DATE,
    user_segment VARCHAR(50),
    income_band  VARCHAR(50)
);

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__american_users.csv'
INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__european_users.csv'
INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

-- Tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
    id                VARCHAR(20) PRIMARY KEY,
    user_id           INT,
    iban              VARCHAR(50),
    pan               VARCHAR(50),
    pin               VARCHAR(10),
    cvv               VARCHAR(10),
    track1            VARCHAR(100),
    track2            VARCHAR(100),
    expiring_date     DATE,
    card_type         VARCHAR(50),
    card_renewal_flag BOOLEAN
);

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date, card_type, card_renewal_flag)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

-- Tabla companies
CREATE TABLE IF NOT EXISTS companies (
    company_id              VARCHAR(20) PRIMARY KEY,
    company_name            VARCHAR(255),
    phone                   VARCHAR(20),
    email                   VARCHAR(255),
    country                 VARCHAR(50),
    website                 VARCHAR(255),
    merchant_category       VARCHAR(50),
    merchant_price_position VARCHAR(50)
);

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__companies.csv'
INTO TABLE companies
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position);

-- Tabla de hechos transactions_log
CREATE TABLE IF NOT EXISTS transactions_log (
    id               VARCHAR(36) PRIMARY KEY,
    card_id          VARCHAR(20),
    business_id      VARCHAR(20),
    transaction_date DATETIME,
    amount           DECIMAL(10, 2),
    declined         BOOLEAN,
    product_ids      JSON,
    user_id          INT,
    lat              DOUBLE,
    longitude        DOUBLE,
    discount_amount  DECIMAL(10, 2),
    tax_amount       DECIMAL(10, 2),
    shipping_amount  DECIMAL(10, 2),
    channel          VARCHAR(50),
    campaign_id      VARCHAR(50),
    device_type      VARCHAR(50),
    is_international BOOLEAN,
    decline_reason   VARCHAR(255),
    distance_km      DECIMAL(10, 2),
    CONSTRAINT fk_card FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    CONSTRAINT fk_company FOREIGN KEY (business_id) REFERENCES companies(company_id),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__transactions.csv'
INTO TABLE transactions_log
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id, business_id, transaction_date, amount, declined, @product_ids, user_id, lat, longitude,
 discount_amount, tax_amount, shipping_amount, channel, campaign_id, device_type, is_international,
 @decline_reason, distance_km)
SET product_ids = CONCAT('[', @product_ids, ']'),
    decline_reason = NULLIF(@decline_reason, '');

-- Tabla puente transaction_products
CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR(36),
    product_id     INT,
    PRIMARY KEY (transaction_id, product_id),
    CONSTRAINT fk_transaction FOREIGN KEY (transaction_id) REFERENCES transactions_log(id)
);

INSERT INTO transaction_products
SELECT
    tl.id,
    pj.product_id
FROM transactions_log AS tl,
    JSON_TABLE(
        tl.product_ids,
        '$[*]' COLUMNS (product_id INT PATH '$')
    ) AS pj;

ALTER TABLE transactions_log
    DROP COLUMN product_ids;
