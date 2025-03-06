DROP VIEW IF EXISTS pogruzka_view;

CREATE VIEW pogruzka_view AS
SELECT 
    p.nomer_vedomosti,
    p.data,
    s.nazvanie AS nazvanie_sudna,
    s.lgoty,
    g.nazvanie AS nazvanie_gruza,
    p.kol_vo,
    p.stoimost * (1 - s.lgoty / 100.0) AS stoimost_s_lgotoy
FROM 
    pogruzka p
JOIN 
    sudno s ON p.sudno = s.identifikator
JOIN 
    gruz g ON p.gruz = g.identifikator;


SELECT * FROM pogruzka_view;

UPDATE sudno
SET lgoty = 10
WHERE identifikator = 1;

SELECT * FROM pogruzka_view;