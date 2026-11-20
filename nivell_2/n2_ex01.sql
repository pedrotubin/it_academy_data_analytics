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
