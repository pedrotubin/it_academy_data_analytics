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
