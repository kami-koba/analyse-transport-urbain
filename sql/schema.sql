-- Schéma relationnel : réseau de transport urbain

CREATE TABLE IF NOT EXISTS LIGNES(
    id_ligne INT PRIMARY KEY,
    nom_ligne VARCHAR(100),
    type_ligne VARCHAR(1)
);

CREATE TABLE IF NOT EXISTS ARRETS(
    id_arret INT PRIMARY KEY,
    nom_arret VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS TRAJETS(
    id_trajet INT PRIMARY KEY,
    ligne_id INT,
    date_trajet DATE,
    heure_depart_prevue TIME,
    heure_depart_reelle TIME,
    FOREIGN KEY(ligne_id) REFERENCES LIGNES(id_ligne)
);

CREATE TABLE IF NOT EXISTS TRAJET_ARRETS(
    id_trajet_arret INT PRIMARY KEY,
    trajet_id INT,
    arret_id INT,
    ordre INT,
    heure_prevue TIME,
    heure_reelle TIME,
    FOREIGN KEY(trajet_id) REFERENCES TRAJETS(id_trajet),
    FOREIGN KEY(arret_id) REFERENCES ARRETS(id_arret)
);

CREATE TABLE IF NOT EXISTS PASSAGERS(
    id_passager INT PRIMARY KEY,
    abonnement VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS VALIDATIONS(
    id_validation INT PRIMARY KEY,
    passager_id INT,
    trajet_arret_id INT,
    date_validation TIME,
    FOREIGN KEY(passager_id) REFERENCES PASSAGERS(id_passager),
    FOREIGN KEY(trajet_arret_id) REFERENCES TRAJET_ARRETS(id_trajet_arret)
);
