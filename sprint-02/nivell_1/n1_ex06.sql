/*
Nivell 1 - Exercici 6
En la taula "transaction" ingressa una nova transacció amb la següent informació:
id:             108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id: CcU-9999
company_id:     b-9999
user_id:        9999
lat:            829.999
longitude:      -117.999
amount:         111.11
declined:       0
*/

USE transactions;

/*
Primer intento (comentado para que el script se ejecute sin errores):
falla porque company_id y credit_card_id son claves foráneas y 'b-9999' y 'CcU-9999'
todavía no existen en company ni en credit_card. Hay que crearlos antes.
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);
*/

INSERT INTO company (id)
VALUE ('b-9999');

INSERT INTO credit_card (id)
VALUE ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

SELECT
    *
FROM transaction AS t
JOIN credit_card AS cc
    ON t.credit_card_id = cc.id
JOIN company AS c
    ON t.company_id = c.id
WHERE t.id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
