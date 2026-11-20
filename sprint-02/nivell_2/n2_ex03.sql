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
