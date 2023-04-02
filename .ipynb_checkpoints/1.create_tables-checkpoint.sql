-- Création de tables pour la conversion de la base de données vers MySQL


CREATE TABLE region (
                id_region VARCHAR(4) NOT NULL PRIMARY KEY,
                nom_region VARCHAR(50) NOT NULL
);


CREATE TABLE commune (
                id_commune VARCHAR(7) NOT NULL PRIMARY KEY,
                nom_commune VARCHAR(50) NOT NULL,
                code_departement VARCHAR(3) NOT NULL,
                nb_hab INT NOT NULL,
                id_region VARCHAR(4) NOT NULL
);


CREATE TABLE bien (
                id_bien INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
                no_voie INT,
                type_voie VARCHAR(4),
                voie VARCHAR(50) NOT NULL,
                total_piece INT,
                surface_carrez FLOAT,
                surface_reelle INT,
                type_local VARCHAR(50) NOT NULL,
                id_commune VARCHAR(7) NOT NULL
);


CREATE TABLE vente (
                id_vente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
                date_mutation DATE NOT NULL,
                valeur INT NOT NULL,
                id_bien INT NOT NULL
);


ALTER TABLE commune ADD FOREIGN KEY (id_region)
REFERENCES region (id_region)
ON DELETE NO ACTION
ON UPDATE NO ACTION;


ALTER TABLE bien ADD FOREIGN KEY (id_commune)
REFERENCES commune (id_commune)
ON DELETE NO ACTION
ON UPDATE NO ACTION;


ALTER TABLE vente ADD FOREIGN KEY (id_bien)
REFERENCES bien (id_bien)
ON DELETE NO ACTION
ON UPDATE NO ACTION;



