/*
Nivell 2 - Exercici 4
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la
base de dades.
*/

USE payments_dw;

DELETE FROM transaction_products
WHERE transaction_id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transactions_log
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
