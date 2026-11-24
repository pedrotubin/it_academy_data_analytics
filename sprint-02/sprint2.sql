/*
Nivel 1 - Ejercicio 1
A partir de los documentos adjuntos (estructura_dades y dades_introduir), importa las dos tablas.
Muestra las características principales del esquema creado y explica las diferentes tablas y
variables que existen. Asegúrate de incluir un diagrama que ilustre la relación entre las
diferentes tablas y variables.
*/

DROP DATABASE IF EXISTS transactions;
CREATE DATABASE IF NOT EXISTS transactions;
USE transactions;

CREATE TABLE IF NOT EXISTS company (
    id           VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone        VARCHAR(15),
    email        VARCHAR(100),
    country      VARCHAR(100),
    website      VARCHAR(255)
);

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


/*
Nivel 1 - Ejercicio 2
Utilizando JOIN realizarás las siguientes consultas:
- Listado de los países que están generando ventas.
- Desde cuántos países se generan las ventas.
- Identifica la compañía con la mayor media de ventas.
*/

USE transactions;

-- Países que generan ventas
SELECT DISTINCT
    c.country
FROM transaction AS t
JOIN company AS c
    ON t.company_id = c.id
WHERE t.declined = 0;

-- Número de países que generan ventas
SELECT
    COUNT(DISTINCT c.country) AS country_quantity
FROM transaction AS t
JOIN company AS c
    ON t.company_id = c.id
WHERE t.declined = 0;

-- Compañía con la media de ventas más alta
SELECT
    c.company_name,
    ROUND(AVG(t.amount), 2) AS avg_sales
FROM transaction AS t
JOIN company AS c
    ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY avg_sales DESC
LIMIT 1;


/*
Nivel 1 - Ejercicio 3
Utilizando solo subconsultas (sin utilizar JOIN):
- Muestra todas las transacciones realizadas por empresas de Alemania.
- Lista las empresas que han realizado transacciones por un amount superior a la media de
  todas las transacciones.
- Eliminarán del sistema las empresas que no tienen transacciones registradas, entrega el
  listado de estas empresas.
*/

USE transactions;

-- Transacciones de empresas de Alemania
SELECT
    *
FROM transaction AS t
WHERE EXISTS (
    SELECT
        1
    FROM company AS c
    WHERE t.company_id = c.id
        AND c.country = 'Germany'
);

-- Empresas con transacciones por encima de la media
SELECT
    *
FROM company AS c
WHERE EXISTS (
    SELECT
        1
    FROM transaction AS t
    WHERE c.id = t.company_id
        AND t.amount > (
            SELECT
                AVG(t2.amount)
            FROM transaction AS t2
        )
);

-- Empresas sin transacciones registradas
SELECT
    c.company_name
FROM company AS c
WHERE NOT EXISTS (
    SELECT
        1
    FROM transaction AS t
    WHERE c.id = t.company_id
);


/*
Nivel 1 - Ejercicio 4
Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales
sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar de manera única
cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y
"company"). Después de crear la tabla será necesario que ingreses la información del documento
denominado "dades_introduir_credit". Recuerda mostrar el diagrama y realizar una breve
descripción de este.
*/

USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
    id            VARCHAR(15) PRIMARY KEY,
    iban          VARCHAR(50) UNIQUE,
    pan           VARCHAR(50) UNIQUE,
    pin           VARCHAR(10),
    cvv           VARCHAR(10),
    expiring_date VARCHAR(30)
);

-- Ejecutar aquí el archivo N1-Ex.4__datos_introducir_credit.sql

ALTER TABLE transaction
    ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SELECT
    *
FROM credit_card;


/*
Nivel 1 - Ejercicio 5
El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a
la tarjeta de crédito con ID CcU-2938. La información que debe mostrarse para este registro es:
TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.
*/

USE transactions;

-- Antes del cambio
SELECT
    *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- Después del cambio
SELECT
    *
FROM credit_card
WHERE id = 'CcU-2938';


/*
Nivel 1 - Ejercicio 6
En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
id:             108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id: CcU-9999
company_id:     b-9999
user_id:        9999
lat:            829.999
longitude:      -117.999
amount:         111.11
declined:       0
*/

USE transactions;

/*
Primer intento (comentado para que el script se ejecute sin errores):
falla porque company_id y credit_card_id son claves foráneas y 'b-9999' y 'CcU-9999'
todavía no existen en company ni en credit_card. Hay que crearlos antes.
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
*/

INSERT INTO company (id)
VALUE ('b-9999');

INSERT INTO credit_card (id)
VALUE ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

SELECT
    *
FROM transaction AS t
JOIN credit_card AS cc
    ON t.credit_card_id = cc.id
JOIN company AS c
    ON t.company_id = c.id
WHERE t.id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


/*
Nivel 1 - Ejercicio 7
Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card.
Recuerda mostrar el cambio realizado.
*/

USE transactions;

-- Antes del cambio
DESCRIBE credit_card;

ALTER TABLE credit_card
    DROP COLUMN pan;

-- Después del cambio
DESCRIBE credit_card;


/*
Nivel 1 - Ejercicio 8
Descarga los archivos CSV que encontrarás en el apartado de recursos:
american_users.csv, european_users.csv, companies.csv, credit_cards.csv, transactions.csv
Estúdialos y diseña una base de datos con un esquema de estrella que contenga, al menos,
4 tablas de las que puedas realizar las siguientes consultas.
La tabla de products.csv la utilizaremos más adelante.
*/

DROP DATABASE IF EXISTS payments_dw;
CREATE DATABASE payments_dw;
USE payments_dw;

SET GLOBAL local_infile = 1;

CREATE TABLE IF NOT EXISTS users (
    id           INT PRIMARY KEY,
    name         VARCHAR(255),
    surname      VARCHAR(255),
    phone        VARCHAR(20),
    email        VARCHAR(255),
    birth_date   DATE,
    country      VARCHAR(50),
    continent    VARCHAR(50),
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
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
    continent  = 'North America';

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__european_users.csv'
INTO TABLE users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
    continent  = 'Europe';

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
    card_renewal_flag BOOLEAN,
    CONSTRAINT fk_card_user FOREIGN KEY (user_id) REFERENCES users(id)
);

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__credit_cards.csv'
INTO TABLE credit_cards
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date, card_type, card_renewal_flag)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

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

SET GLOBAL local_infile = 0;


/*
Nivel 1 - Ejercicio 9
Realiza una subconsulta que muestre todos los usuarios con más de 80 transacciones utilizando
al menos 2 tablas.
*/

USE payments_dw;

SELECT
    *
FROM users AS u
WHERE EXISTS (
    SELECT
        1
    FROM transactions_log AS tl
    WHERE u.id = tl.user_id
    GROUP BY tl.user_id
    HAVING COUNT(tl.id) > 80
);


/*
Nivel 1 - Ejercicio 10
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd,
utiliza al menos 2 tablas.
*/

USE payments_dw;

SELECT
    cc.iban,
    ROUND(AVG(tl.amount), 2) AS avg_amount
FROM transactions_log AS tl
JOIN credit_cards AS cc
    ON tl.card_id = cc.id
WHERE EXISTS (
    SELECT
        1
    FROM companies AS c
    WHERE tl.business_id = c.company_id
        AND c.company_name = 'Donec Ltd'
)
GROUP BY cc.iban
ORDER BY avg_amount DESC;


/*
Nivel 2 - Ejercicio 1
Identifica los cinco días en que se generó la mayor cantidad de ingresos en la empresa por
ventas. Muestra la fecha de cada transacción junto con el total de las ventas.
*/

USE payments_dw;

SELECT
    DATE(tl.transaction_date) AS sale_day,
    ROUND(SUM(tl.amount), 2) AS total_amount
FROM transactions_log AS tl
WHERE tl.declined = 0
GROUP BY DATE(tl.transaction_date)
ORDER BY total_amount DESC
LIMIT 5;


/*
Nivel 2 - Ejercicio 2
Presenta el nombre, teléfono, país, fecha y amount de aquellas empresas que realizaron
transacciones con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas:
29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024.
Ordena los resultados de mayor a menor cantidad.
*/

USE payments_dw;

SELECT
    c.company_id,
    c.company_name,
    c.phone,
    c.country,
    DATE(tl.transaction_date) AS transaction_day,
    tl.amount
FROM companies AS c
JOIN transactions_log AS tl
    ON c.company_id = tl.business_id
WHERE tl.amount BETWEEN 350 AND 400
    AND DATE(tl.transaction_date) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY tl.amount DESC;


/*
Nivel 2 - Ejercicio 3
Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que
se requiera, por lo que te piden la información sobre la cantidad de transacciones que
realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un
listado de las empresas donde especifiques si tienen igual o más de 400 transacciones o menos.
*/

USE payments_dw;

SELECT
    tl.business_id,
    c.company_name,
    COUNT(tl.id) AS total_transactions,
    CASE
        WHEN COUNT(tl.id) >= 400 THEN 'High (400 or more)'
        ELSE 'Low (fewer than 400)'
    END AS transaction_volume
FROM transactions_log AS tl
JOIN companies AS c
    ON tl.business_id = c.company_id
GROUP BY tl.business_id
ORDER BY total_transactions DESC;


/*
Nivel 2 - Ejercicio 4
Elimina de la tabla transaction el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la
base de datos.
*/

USE payments_dw;

DELETE FROM transactions_log
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


/*
Nivel 2 - Ejercicio 5
La sección de marketing desea tener acceso a información específica para realizar análisis y
estrategias efectivas. Se ha solicitado crear una vista que proporcione detalles clave sobre
las compañías y sus transacciones. Será necesario que crees una vista llamada VistaMarketing
que contenga la siguiente información: Nombre de la compañía. Teléfono de contacto. País de
residencia. Media de compra realizada por cada compañía. Presenta la vista creada, ordenando
los datos de mayor a menor media de compra.
*/

USE payments_dw;

DROP VIEW IF EXISTS VistaMarketing;

CREATE VIEW VistaMarketing AS
SELECT
    c.company_name,
    c.phone,
    c.country,
    ROUND(AVG(tl.amount), 2) AS avg_sales
FROM transactions_log AS tl
JOIN companies AS c
    ON tl.business_id = c.company_id
WHERE tl.declined = 0
GROUP BY c.company_id;

SELECT
    *
FROM VistaMarketing
ORDER BY avg_sales DESC;


/*
Nivel 3 - Ejercicio 1
Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres
últimas transacciones han sido declinadas, entonces es inactiva; si al menos una no es
rechazada, entonces es activa. Partiendo de esta tabla responde:
¿Cuántas tarjetas están activas?
*/

USE payments_dw;

DROP TABLE IF EXISTS card_status_table;

CREATE TABLE card_status_table AS
SELECT
    ol.card_id,
    CASE
        WHEN SUM(ol.declined) = COUNT(ol.card_id) THEN 'Inactive'
        ELSE 'Active'
    END AS card_status
FROM (
    SELECT
        tl.transaction_date,
        tl.card_id,
        tl.declined,
        ROW_NUMBER() OVER (
            PARTITION BY tl.card_id
            ORDER BY tl.transaction_date DESC
        ) AS trans_order
    FROM transactions_log AS tl
) AS ol
WHERE ol.trans_order <= 3
GROUP BY ol.card_id;

-- Tarjetas activas
SELECT
    COUNT(*) AS active_cards
FROM card_status_table AS cs
WHERE cs.card_status = 'Active';


/*
Nivel 3 - Ejercicio 2
Crea una tabla con la que podamos unir los datos del archivo products.csv con la base de
datos creada (ya que hasta ahora no podíamos hacerlo), teniendo en cuenta que desde
transaction tienes product_ids. Genera la siguiente consulta:
Necesitamos conocer el número de veces que se ha vendido cada producto.
*/

USE payments_dw;

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

CREATE TABLE IF NOT EXISTS products (
    id           INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price        DECIMAL(7, 2),
    colour       VARCHAR(50),
    weight       DECIMAL(5, 2),
    warehouse_id VARCHAR(10),
    category     VARCHAR(50),
    brand        VARCHAR(50),
    cost         DECIMAL(7, 2),
    launch_date  DATE
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__products.csv'
INTO TABLE products
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET price = REPLACE(@price, '$', ''),
    cost  = REPLACE(@cost, '$', '');

SET GLOBAL local_infile = 0;

ALTER TABLE transaction_products
    ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES products(id);

SELECT
    p.product_name,
    p.id,
    COUNT(tp.product_id) AS total_sold
FROM transaction_products AS tp
JOIN transactions_log AS tl
    ON tp.transaction_id = tl.id
JOIN products AS p
    ON tp.product_id = p.id
WHERE tl.declined = 0
GROUP BY p.id
ORDER BY total_sold DESC;
