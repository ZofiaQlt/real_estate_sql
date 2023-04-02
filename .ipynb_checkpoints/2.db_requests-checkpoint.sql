-- Interrogation de la base de données


-- 1. Nombre total d’appartements vendus au 1er semestre 2020

SELECT COUNT(*) AS nb_apt_vendus_2020_sem_1
FROM vente
JOIN bien USING (id_bien)
WHERE type_local = 'appartement' 
AND date_mutation BETWEEN '2020-01-01' AND '2020-06-30';


-- 2. Le nombre de ventes d’appartement par région pour le 1er semestre 2020

SELECT nom_region, 
       COUNT(*) AS nb_apt
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
JOIN region USING (id_region)
WHERE type_local = 'appartement'
GROUP BY nom_region
ORDER BY nb_apt DESC;

    
-- 3. Proportion des ventes d’appartements par le nombre de pièces

SELECT total_piece, 
       COUNT(*) AS nb_apt_vendus, 
       ROUND(COUNT(*)/(SELECT COUNT(*) AS nb_apt_vendus_2020_sem_1
                       FROM vente
                       JOIN bien USING (id_bien)
                       WHERE type_local = 'appartement'
                      )*100, 2
       ) AS proportion_apt_vendus
FROM vente
JOIN bien USING (id_bien)
WHERE type_local = 'appartement'
GROUP BY total_piece
ORDER BY proportion_apt_vendus DESC;

    
-- 4. Liste des 10 départements où le prix du mètre carré est le plus élevé

SELECT code_departement, 
       ROUND(AVG(valeur/surface_carrez), 2) AS valeur_m2
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
GROUP BY code_departement
ORDER BY valeur_m2 DESC
LIMIT 10;


-- 5. Prix moyen du mètre carré d’une maison en Île-de-France

SELECT nom_region, 
       type_local, 
       ROUND(AVG(valeur/surface_carrez), 2) AS valeur_m2
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
JOIN region USING (id_region)
WHERE nom_region = 'Ile-de-France' 
AND type_local = 'maison';


-- 6. Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés

SELECT valeur, 
       nom_region, 
       surface_carrez, 
       surface_reelle
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
JOIN region USING (id_region)
WHERE type_local = 'appartement'
ORDER BY valeur DESC
LIMIT 10;


-- 7. Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020

WITH premier_trim AS (
    SELECT COUNT(id_vente) AS nb_ventes_prem_trim
    FROM vente
    WHERE date_mutation BETWEEN '2020-01-01' AND '2020-03-31'),

     second_trim AS (
    SELECT COUNT(id_vente) AS nb_ventes_sec_trim
    FROM vente
    WHERE date_mutation BETWEEN '2020-04-01' AND '2020-06-30')

SELECT nb_ventes_prem_trim, 
       nb_ventes_sec_trim, 
       ROUND((nb_ventes_sec_trim - nb_ventes_prem_trim)/nb_ventes_prem_trim*100, 2) AS taux_evolution
FROM premier_trim, 
     second_trim;
     
     
-- 8. Le classement des régions par rapport au prix au mètre carré des appartements de plus de 4 pièces

SELECT nom_region, 
       ROUND(AVG(valeur/surface_carrez), 2) AS valeur_m2
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
JOIN region USING (id_region)
WHERE total_piece > 4 AND type_local = 'appartement'
GROUP BY nom_region
ORDER BY valeur_m2 DESC;


-- 9. Liste des communes ayant eu au moins 50 ventes au 1er trimestre

SELECT nom_commune, 
       COUNT(*) AS nb_vente
FROM vente
JOIN bien USING (id_bien)
JOIN commune USING (id_commune)
WHERE date_mutation BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY nom_commune
HAVING nb_vente >= 50
ORDER BY nb_vente;


-- 10. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces

WITH apt_2_piece AS (
     SELECT ROUND(AVG(valeur/surface_carrez), 2) AS valeur_m2_deux_piece
     FROM vente
     JOIN bien USING (id_bien)
     WHERE type_local = 'appartement' AND total_piece = 2),

     apt_3_piece AS (
     SELECT ROUND(AVG(valeur/surface_carrez), 2) AS valeur_m2_trois_piece
     FROM vente
     JOIN bien USING (id_bien)
     WHERE type_local = 'appartement' AND total_piece = 3)

SELECT valeur_m2_deux_piece, 
       valeur_m2_trois_piece, 
       ROUND(((valeur_m2_deux_piece - valeur_m2_trois_piece)/valeur_m2_trois_piece*100), 2) AS difference_en_pourcentage
FROM apt_2_piece, 
     apt_3_piece;
     
     
-- 11. Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69

WITH step1 AS (
    SELECT code_departement, 
           nom_commune, 
           AVG(valeur) AS moyenne_valeur
    FROM vente 
    JOIN bien USING (id_bien)
    JOIN commune USING (id_commune)
    WHERE code_departement IN (6, 13, 33, 59, 69)
    GROUP BY code_departement, nom_commune)
    
SELECT code_departement, 
       top3, 
       nom_commune, 
       ROUND(moyenne_valeur, 2) AS valeur_moyenne
FROM (SELECT code_departement,
             nom_commune,
             moyenne_valeur, 
             RANK() OVER (PARTITION BY code_departement ORDER BY moyenne_valeur DESC) AS top3
      FROM step1) AS step2
WHERE top3 < 4;