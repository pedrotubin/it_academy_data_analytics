/*
Nivell 1 - Exercici 7
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.
Recorda mostrar el canvi realitzat.
*/

USE transactions;

-- Antes del cambio
DESCRIBE credit_card;

ALTER TABLE credit_card
    DROP COLUMN pan;

-- Después del cambio
DESCRIBE credit_card;
