
DROP TABLE IF EXISTS mesto_razresheniy_gruz;

CREATE TABLE mesto_razresheniy_gruz (
    id SERIAL PRIMARY KEY,
    mesto_pogruzki INT NOT NULL,
    gruz INT NOT NULL
);

INSERT INTO mesto_razresheniy_gruz (mesto_pogruzki, gruz) VALUES 
(5, 1),
(3, 2),
(5, 2),
(5, 5),
(3, 3),
(1, 4),
(2, 4),
(6, 1),
(4, 3),
(3, 4),
(2, 3),
(1, 1),
(6, 5);

DROP FUNCTION IF EXISTS check_razresheniy_gruz;
CREATE OR REPLACE FUNCTION check_razresheniy_gruz()
RETURNS TRIGGER AS $$
DECLARE
    error_msg TEXT := '';
BEGIN
    -- Проверка существования судна
    IF NOT EXISTS (
        SELECT 1 FROM sudno WHERE identifikator = NEW.sudno
    ) THEN
        RAISE EXCEPTION 'Ошибка: Судно с идентификатором % не существует.', NEW.sudno;
    END IF;
    
    -- Проверка существования груза
    IF NOT EXISTS (
        SELECT 1 FROM gruz WHERE identifikator = NEW.gruz
    ) THEN
        RAISE EXCEPTION 'Ошибка: Груз с идентификатором % не существует.', NEW.gruz;
    END IF;

    -- Проверка, разрешено ли грузить данный груз в указанном месте
    IF NOT EXISTS (
        SELECT 1 
        FROM mesto_razresheniy_gruz 
        WHERE mesto_pogruzki = NEW.mesto_pogruzki 
        AND gruz = NEW.gruz
    ) THEN
        RAISE EXCEPTION 'Ошибка: Груз % не может быть загружен в месте погрузки %.', NEW.gruz, NEW.mesto_pogruzki;
    END IF;
    
    -- Проверка количества груза
    IF NEW.kol_vo < 1 THEN
        RAISE EXCEPTION 'Ошибка: Количество груза должно быть больше 0. Указано: %.', NEW.kol_vo;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_gruz_na_mesto ON pogruzka;
CREATE TRIGGER check_gruz_na_mesto
BEFORE INSERT ON pogruzka
FOR EACH ROW EXECUTE FUNCTION check_razresheniy_gruz();


-- Можно грузить
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost)
VALUES ('Воскресенье', 1, 5, 1, 30, 1200000);

SELECT * FROM pogruzka WHERE kol_vo = 30 AND stoimost = 1200000;

-- Судно не существует
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) 
VALUES ('Воскресенье', 7, 5, 1, 30, 1200000);

-- Груз не существует
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) 
VALUES ('Воскресенье', 1, 5, 20, 30, 1200000);

-- Отрицательный груз
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) 
VALUES ('Воскресенье', 1, 5, 1, -5, 1200000);

-- Груз не разрешён в этом месте
INSERT INTO pogruzka (data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) 
VALUES ('Воскресенье', 1, 1, 6, 30, 1200000);

SELECT * FROM pogruzka;



