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
