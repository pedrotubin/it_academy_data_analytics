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
