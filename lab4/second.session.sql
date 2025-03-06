DROP TABLE IF EXISTS pogruzka CASCADE;
DROP TABLE IF EXISTS mesto_razresheniy_gruz CASCADE;
DROP TABLE IF EXISTS gruz CASCADE;
DROP TABLE IF EXISTS mesta_pogruzki CASCADE;
DROP TABLE IF EXISTS sudno CASCADE;

CREATE TABLE sudno (
    identifikator SERIAL  PRIMARY KEY,  -- Теперь INT
    nazvanie VARCHAR(100) NOT NULL,
    port_pripiski VARCHAR(100) NOT NULL,
    lgoty INTEGER NOT NULL
);

CREATE TABLE mesta_pogruzki (
    identifikator SERIAL  PRIMARY KEY,  -- Теперь INT
    prichal VARCHAR(100) NOT NULL,
    port VARCHAR(100) NOT NULL,
    otchisleniya_na_pogruzku INTEGER NOT NULL
);

CREATE TABLE gruz (
    identifikator SERIAL  PRIMARY KEY,  -- Теперь INT
    nazvanie VARCHAR(100) NOT NULL,
    port_skladirivaniya VARCHAR(100) NOT NULL,
    stoimost NUMERIC NOT NULL,
    max_kol_vo INTEGER NOT NULL
);

CREATE TABLE pogruzka (
    nomer_vedomosti SERIAL PRIMARY KEY,
    data VARCHAR(15) NOT NULL,
    sudno INT NOT NULL,  -- Теперь INT
    mesto_pogruzki INT NOT NULL,  -- Теперь INT
    gruz INT NOT NULL,  -- Теперь INT
    kol_vo INTEGER NOT NULL,
    stoimost NUMERIC NOT NULL,
    FOREIGN KEY (sudno) REFERENCES sudno(identifikator),
    FOREIGN KEY (mesto_pogruzki) REFERENCES mesta_pogruzki(identifikator),
    FOREIGN KEY (gruz) REFERENCES gruz(identifikator)
);

INSERT INTO sudno (identifikator, nazvanie, port_pripiski, lgoty) VALUES 
(1, 'Балтимор', 'Одесса', 3),
(2, 'Генуя', 'Одесса', 3),
(3, 'ТПР-123', 'Владивосток', 5),
(4, 'Ф. Шаляпин', 'Мурманск', 6),
(5, 'Рейн', 'Калининград', 4),
(6, 'Россия', 'Владивосток', 5);

INSERT INTO mesta_pogruzki (identifikator, prichal, port, otchisleniya_na_pogruzku) VALUES 
(1, 'Северный', 'Одесса', 3),
(2, 'Южный', 'Одесса', 4),
(3, 'N1', 'Владивосток', 2),
(4, 'N2', 'Владивосток', 2),
(5, 'N3', 'Владивосток', 2),
(6, 'Основной', 'Калининград', 4);

INSERT INTO gruz (identifikator, nazvanie, port_skladirivaniya, stoimost, max_kol_vo) VALUES 
(1, 'Рис', 'Одесса', 100000, 700),
(2, 'Зерно', 'Одесса', 80000, 890),
(3, 'Хлопок', 'Одесса', 300000, 400),
(4, 'Сахар', 'Владивосток', 140000, 600),
(5, 'Соль', 'Мурманск', 120000, 700),
(6, 'Скобяные изделия', 'Калининград', 300000, 140),
(7, 'Древесина', 'Мурманск', 400000, 260),
(8, 'Уголь', 'Владивосток', 400000, 400);

INSERT INTO pogruzka (nomer_vedomosti, data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) VALUES 
('70204', 'Понедельник', 1, 5, 2, 100, 8000000),
('70205', 'Понедельник', 3, 3, 6, 4, 1200000),
('70206', 'Вторник', 1, 5, 7, 2, 800000),
('70207', 'Вторник', 2, 5, 1, 20, 2000000),
('70208', 'Вторник', 5, 5, 2, 3, 240000),
('70209', 'Среда', 3, 3, 6, 4, 1200000),
('70210', 'Среда', 4, 1, 1, 70, 7000000),
('70211', 'Среда', 4, 2, 6, 1, 300000),
('70212', 'Среда', 4, 2, 1, 10, 1000000),
('70213', 'Четверг', 1, 6, 3, 20, 6000000),
('70214', 'Четверг', 3, 4, 2, 2, 16000),
('70215', 'Четверг', 4, 3, 4, 30, 4200000),
('70216', 'Суббота', 3, 2, 5, 10, 1200000),
('70217', 'Суббота', 2, 3, 8, 20, 8000000),
('70218', 'Суббота', 1, 1, 1, 20, 2000000),
('70219', 'Суббота', 5, 6, 4, 10, 1400000);