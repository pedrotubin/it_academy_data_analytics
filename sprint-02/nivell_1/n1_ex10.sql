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
