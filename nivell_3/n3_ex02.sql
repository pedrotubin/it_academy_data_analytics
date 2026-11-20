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
