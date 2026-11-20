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
