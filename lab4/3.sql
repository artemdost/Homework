
DROP FUNCTION IF EXISTS calculate_stoimost;
CREATE OR REPLACE FUNCTION calculate_stoimost()
RETURNS TRIGGER AS $$
DECLARE
    cena_za_ed NUMERIC;
BEGIN
    IF NEW.stoimost IS NULL THEN
        SELECT stoimost INTO cena_za_ed
        FROM gruz 
        WHERE identifikator = NEW.gruz;
        NEW.stoimost := NEW.kol_vo * cena_za_ed;

        RAISE NOTICE 'Сумма не указана. Вычислено автоматически: %', NEW.stoimost;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS calculate_stoimost_trigger ON pogruzka;
CREATE TRIGGER calculate_stoimost_trigger
BEFORE INSERT ON pogruzka
FOR EACH ROW EXECUTE FUNCTION calculate_stoimost();

-- Вставляем запись без указания суммы
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo) 
VALUES ('Воскресенье', 1, 1, 1, 60);
SELECT * FROM pogruzka WHERE kol_vo = 60;

-- Вставляем запись с указанием суммы
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) 
VALUES ('Воскресенье', 1, 1, 1, 75, 10000000);
SELECT * FROM pogruzka WHERE kol_vo = 75;




