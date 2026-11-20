/*
Nivell 1 - Exercici 4
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls
crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera
única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i
"company"). Després de crear la taula serà necessari que ingressis la informació del document
denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu
descripció d'aquest.
*/

USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
    id            VARCHAR(15) PRIMARY KEY,
    iban          VARCHAR(50) UNIQUE,
    pan           VARCHAR(50) UNIQUE,
    pin           VARCHAR(10),
    cvv           VARCHAR(10),
    expiring_date VARCHAR(30)
);

-- Ejecutar aquí el archivo N1-Ex.4__datos_introducir_credit.sql

ALTER TABLE transaction
    ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SELECT
    *
FROM credit_card;
