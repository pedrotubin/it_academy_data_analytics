/*
Nivell 1 - Exercici 5
El departament de Recursos Humans ha identificat un error en el número de compte associat a la
targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és:
TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
*/

USE transactions;

-- Antes del cambio
SELECT
    *
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- Después del cambio
SELECT
    *
FROM credit_card
WHERE id = 'CcU-2938';
