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
