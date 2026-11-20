/*
Bootcamp de Data Analytics, IT Academy (Barcelona Activa)
Sprint 2: Bases de datos relacionales con MySQL
Alumno: Pedro Tubin (linkedin.com/in/pedrotubin)
Mentor: Dagoberto Itriago
Noviembre de 2026

Ejecución:
- Ejecutar el script en orden, de arriba abajo.
- En los puntos indicados con un comentario hay que ejecutar los archivos de datos
  del enunciado: N1-Ex.1__dades_introduir.sql y N1-Ex.4__datos_introducir_credit.sql.
- Las sentencias LOAD DATA (N1 Ex8 y N3 Ex2) usan la ruta '/ruta/a/los/archivos/'.
  Sustituirla por la carpeta donde estén los CSV.
- La conexión de Workbench necesita la opción OPT_LOCAL_INFILE=1.
- Criterio general: una transacción solo cuenta como venta si declined = 0.
*/

-- ============================================================
-- NIVELL 1
-- ============================================================

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


/*
Nivell 1 - Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:
- Llistat dels països que estan generant vendes.
- Des de quants països es generen les vendes.
- Identifica la companyia amb la mitjana més gran de vendes.
*/

USE transactions;

DROP VIEW IF EXISTS company_transactions_table;

CREATE VIEW company_transactions_table AS
SELECT
    t.*,
    c.company_name,
    c.phone,
    c.email,
    c.country,
    c.website
FROM transaction AS t
JOIN company AS c
    ON t.company_id = c.id;

-- Países que generan ventas
SELECT DISTINCT
    ct.country
FROM company_transactions_table AS ct
WHERE ct.declined = 0;

-- Número de países que generan ventas
SELECT
    COUNT(DISTINCT ct.country)
FROM company_transactions_table AS ct
WHERE ct.declined = 0;

-- Compañía con la media de ventas más alta
SELECT
    ct.company_name,
    ROUND(AVG(ct.amount), 2) AS avg_sales
FROM company_transactions_table AS ct
WHERE ct.declined = 0
GROUP BY ct.company_id
ORDER BY avg_sales DESC
LIMIT 1;


/*
Nivell 1 - Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
- Mostra totes les transaccions realitzades per empreses d'Alemanya.
- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de
  totes les transaccions.
- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el
  llistat d'aquestes empreses.
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
)
    AND t.declined = 0;

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
            WHERE t2.declined = 0
        )
        AND t.declined = 0
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
Nivell 1 - Exercici 4
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls
crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera
única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i
"company"). Després de crear la taula serà necessari que ingressis la informació del document
denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu
descripció d'aquest.
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
Nivell 1 - Exercici 5
El departament de Recursos Humans ha identificat un error en el número de compte associat a la
targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és:
TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
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
Nivell 1 - Exercici 6
En la taula "transaction" ingressa una nova transacció amb la següent informació:
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
Nivell 1 - Exercici 7
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.
Recorda mostrar el canvi realitzat.
*/

USE transactions;

-- Antes del cambio
DESCRIBE credit_card;

ALTER TABLE credit_card
    DROP COLUMN pan;

-- Después del cambio
DESCRIBE credit_card;


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


/*
Nivell 1 - Exercici 9
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant
almenys 2 taules.
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
        AND tl.declined = 0
    GROUP BY tl.user_id
    HAVING COUNT(tl.id) > 80
);


/*
Nivell 1 - Exercici 10
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd,
utilitza almenys 2 taules.
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
    AND tl.declined = 0
GROUP BY cc.iban
ORDER BY avg_amount DESC;


-- ============================================================
-- NIVELL 2
-- ============================================================

/*
Nivell 2 - Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per
vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
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
Nivell 2 - Exercici 2
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar
transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates:
29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024.
Ordena els resultats de major a menor quantitat.
*/

USE payments_dw;

SELECT
    c.company_id,
    c.company_name,
    c.phone,
    c.country,
    DATE(tl.transaction_date) AS sale_day,
    tl.amount
FROM companies AS c
JOIN transactions_log AS tl
    ON c.company_id = tl.business_id
WHERE tl.declined = 0
    AND tl.amount BETWEEN 350 AND 400
    AND DATE(tl.transaction_date) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY tl.amount DESC;


/*
Nivell 2 - Exercici 3
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es
requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que
realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de
les empreses on especifiquis si tenen igual o més de 400 transaccions o menys.
*/

USE payments_dw;

SELECT
    tl.business_id,
    c.company_name,
    CASE
        WHEN COUNT(tl.id) >= 400 THEN 'High'
        ELSE 'Low'
    END AS transactions_category,
    COUNT(tl.id) AS total_transactions
FROM transactions_log AS tl
JOIN companies AS c
    ON tl.business_id = c.company_id
WHERE tl.declined = 0
GROUP BY tl.business_id;


/*
Nivell 2 - Exercici 4
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la
base de dades.
*/

USE payments_dw;

DELETE FROM transaction_products
WHERE transaction_id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transactions_log
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


/*
Nivell 2 - Exercici 5
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i
estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les
companyies i les seves transaccions. Serà necessària que creïs una vista anomenada
VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte.
País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada,
ordenant les dades de major a menor mitjana de compra.
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


-- ============================================================
-- NIVELL 3
-- ============================================================

/*
Nivell 3 - Exercici 1
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres
últimes transaccions han estat declinades aleshores és inactiu, si almenys una no és rebutjada
aleshores és actiu. Partint d'aquesta taula respon:
Quantes targetes estan actives?
*/

USE payments_dw;

DROP TABLE IF EXISTS card_status_table;

CREATE TABLE card_status_table AS
SELECT
    ol.card_id,
    CASE
        WHEN SUM(ol.declined) = 3 THEN 'Inactive'
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
Nivell 3 - Exercici 2
Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv amb la base de
dades creada (ja que fins ara no podíem fer-ho), tenint en compte que des de transaction tens
product_ids. Genera la següent consulta:
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
*/

USE payments_dw;

-- Tabla puente transaction_products ya creada en el ejercicio 8 del nivel 1

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

LOAD DATA LOCAL INFILE '/ruta/a/los/archivos/N1-Ex.8__products.csv'
INTO TABLE products
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET price = REPLACE(@price, '$', ''),
    cost  = REPLACE(@cost, '$', '');

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
