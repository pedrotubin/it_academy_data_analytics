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
