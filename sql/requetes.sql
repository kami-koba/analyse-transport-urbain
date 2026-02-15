-- =========================================================
-- PROJET : Analyse d’un réseau de transport urbain
-- Objectifs : fréquentation / retards / ponctualité / affluence
-- =========================================================

-- -------------------------
-- 1) Fréquentation par ligne
-- -------------------------
SELECT
    l.nom_ligne,
    COUNT(*) AS nb_passagers,
    l.type_ligne
FROM VALIDATIONS v
JOIN TRAJET_ARRETS ta ON ta.id_trajet_arret = v.trajet_arret_id
JOIN TRAJETS t ON t.id_trajet = ta.trajet_id
JOIN LIGNES l ON l.id_ligne = t.ligne_id
GROUP BY l.nom_ligne
ORDER BY nb_passagers DESC;

-- -------------------------
-- 2) Fréquentation par arrêt
-- -------------------------
SELECT
    a.nom_arret,
    COUNT(*) AS nb_passagers
FROM VALIDATIONS v
JOIN TRAJET_ARRETS ta ON ta.id_trajet_arret = v.trajet_arret_id
JOIN ARRETS a ON a.id_arret = ta.arret_id
GROUP BY a.nom_arret
ORDER BY nb_passagers DESC;

-- -------------------------
-- 3) Fréquentation par jour
-- -------------------------
SELECT
    t.date_trajet AS jour,
    COUNT(v.id_validation) AS nb_passagers
FROM VALIDATIONS v
JOIN TRAJET_ARRETS ta ON v.trajet_arret_id = ta.id_trajet_arret
JOIN TRAJETS t ON ta.trajet_id = t.id_trajet
GROUP BY jour
ORDER BY jour ASC;

-- =========================================================
-- 4) Retards moyens
-- =========================================================

-- 4.1 Retard au départ (en minutes)
SELECT
    l.nom_ligne,
    ROUND(
        (strftime('%s', t.heure_depart_reelle) - strftime('%s', t.heure_depart_prevue)) / 60.0,
        2
    ) AS retard_depart_min
FROM TRAJETS t
JOIN LIGNES l ON t.ligne_id = l.id_ligne
ORDER BY retard_depart_min DESC;

-- 4.2 Retard par passage (arrêt par arrêt)
SELECT
    ta.id_trajet_arret,
    ta.trajet_id,
    a.nom_arret,
    ta.ordre,
    ROUND(
        (strftime('%s', ta.heure_reelle) - strftime('%s', ta.heure_prevue)) / 60.0,
        2
    ) AS retard_minutes
FROM TRAJET_ARRETS ta
JOIN ARRETS a ON a.id_arret = ta.arret_id
ORDER BY retard_minutes DESC;

-- 4.3 Retard moyen par ligne
SELECT
    l.id_ligne,
    l.nom_ligne,
    l.type_ligne,
    ROUND(
        AVG((strftime('%s', ta.heure_reelle) - strftime('%s', ta.heure_prevue)) / 60.0),
        2
    ) AS retard_moyen_minutes
FROM TRAJET_ARRETS ta
JOIN TRAJETS t ON t.id_trajet = ta.trajet_id
JOIN LIGNES l ON l.id_ligne = t.ligne_id
GROUP BY l.id_ligne, l.nom_ligne, l.type_ligne
ORDER BY retard_moyen_minutes DESC;

-- =========================================================
-- 5) Classement des lignes les plus ponctuelles
-- (trajets "à l’heure" si retard départ entre 0 et 3 minutes)
-- =========================================================
SELECT
    l.nom_ligne,
    ROUND(
        COUNT(
            CASE
                WHEN (strftime('%s', t.heure_depart_reelle) - strftime('%s', t.heure_depart_prevue))
                     BETWEEN 0 AND 180
                THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS taux_ponctualite_pourcent,
    COUNT(*) AS total_trajets
FROM TRAJETS t
JOIN LIGNES l ON l.id_ligne = t.ligne_id
GROUP BY l.nom_ligne
ORDER BY taux_ponctualite_pourcent DESC;

-- =========================================================
-- 6) Périodes de forte affluence
-- =========================================================

-- 6.1 Affluence par heure
SELECT
    strftime('%H', v.date_validation) AS heure,
    COUNT(*) AS nb_passagers
FROM VALIDATIONS v
GROUP BY heure
ORDER BY nb_passagers DESC;

-- 6.2 Affluence par tranche (matin/soir/autres)
SELECT
    CASE
        WHEN CAST(strftime('%H', v.date_validation) AS INT) BETWEEN 6 AND 12 THEN 'Matin'
        WHEN CAST(strftime('%H', v.date_validation) AS INT) BETWEEN 18 AND 23 THEN 'Soir'
        ELSE 'Autres'
    END AS periode,
    COUNT(*) AS nb_passagers
FROM VALIDATIONS v
GROUP BY periode
ORDER BY nb_passagers DESC;

-- 6.3 Arrêts les plus fréquentés pendant les heures de pointe (7-9 / 17-19)
SELECT
    a.nom_arret,
    COUNT(*) AS nb_passagers
FROM VALIDATIONS v
JOIN TRAJET_ARRETS ta ON ta.id_trajet_arret = v.trajet_arret_id
JOIN ARRETS a ON a.id_arret = ta.arret_id
WHERE CAST(strftime('%H', v.date_validation) AS INT) BETWEEN 7 AND 9
   OR CAST(strftime('%H', v.date_validation) AS INT) BETWEEN 17 AND 19
GROUP BY a.nom_arret
ORDER BY nb_passagers DESC;
