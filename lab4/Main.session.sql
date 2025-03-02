CREATE TABLE sudno (
    identifikator VARCHAR(3) PRIMARY KEY,  -- Первичный ключ
    nazvanie VARCHAR(100) NOT NULL,
    port_pripiski VARCHAR(100) NOT NULL,
    lgoty INTEGER NOT NULL
);

INSERT INTO sudno (identifikator, nazvanie, port_pripiski, lgoty) VALUES 
('001', 'Балтимор', 'Одесса', 3),
('002', 'Генуя', 'Одесса', 3),
('003', 'ТПР-123', 'Владивосток', 5),
('004', 'Ф. Шаляпин', 'Мурманск', 6),
('005', 'Рейн', 'Калининград', 4),
('006', 'Россия', 'Владивосток', 5);


CREATE TABLE mesta_pogruzki (
    identifikator VARCHAR(3) PRIMARY KEY,  -- Первичный ключ
    prichal VARCHAR(100) NOT NULL,
    port VARCHAR(100) NOT NULL,
    otchisleniya_na_pogruzku INTEGER NOT NULL
);

INSERT INTO mesta_pogruzki (identifikator, prichal, port, otchisleniya_na_pogruzku) VALUES 
('001', 'Северный', 'Одесса', 3),
('002', 'Южный', 'Одесса', 4),
('003', 'N1', 'Владивосток', 2),
('004', 'N2', 'Владивосток', 2),
('005', 'N3', 'Владивосток', 2),
('006', 'Основной', 'Калининград', 4);

CREATE TABLE gruz (
    identifikator VARCHAR(3) PRIMARY KEY,  -- Первичный ключ
    nazvanie VARCHAR(100) NOT NULL,
    port_skladirivaniya VARCHAR(100) NOT NULL,
    stoimost NUMERIC NOT NULL,
    max_kol_vo INTEGER NOT NULL
);

INSERT INTO gruz (identifikator, nazvanie, port_skladirivaniya, stoimost, max_kol_vo) VALUES 
('001', 'Рис', 'Одесса', 100000, 700),
('002', 'Зерно', 'Одесса', 80000, 890),
('003', 'Хлопок', 'Одесса', 300000, 400),
('004', 'Сахар', 'Владивосток', 140000, 600),
('005', 'Соль', 'Мурманск', 120000, 700),
('006', 'Скобяные изделия', 'Калининград', 300000, 140),
('007', 'Древесина', 'Мурманск', 400000, 260),
('008', 'Уголь', 'Владивосток', 400000, 400);


CREATE TABLE pogruzka (
    nomer_vedomosti VARCHAR(5) PRIMARY KEY,  -- Первичный ключ
    data VARCHAR(15) NOT NULL,
    sudno VARCHAR(3) NOT NULL,
    mesto_pogruzki VARCHAR(3) NOT NULL,
    gruz VARCHAR(3) NOT NULL,
    kol_vo INTEGER NOT NULL,
    stoimost NUMERIC NOT NULL
);

INSERT INTO pogruzka (nomer_vedomosti, data, sudno, mesto_pogruzki, gruz, kol_vo, stoimost) VALUES 
('70204', 'Понедельник', '001', '005', '002', 100, 8000000),
('70205', 'Понедельник', '003', '003', '006', 4, 1200000),
('70206', 'Вторник', '001', '005', '007', 2, 800000),
('70207', 'Вторник', '002', '005', '001', 20, 2000000),
('70208', 'Вторник', '005', '005', '002', 3, 240000),
('70209', 'Среда', '003', '003', '006', 4, 1200000),
('70210', 'Среда', '004', '001', '001', 70, 7000000),
('70211', 'Среда', '004', '002', '006', 1, 300000),
('70212', 'Среда', '004', '002', '001', 10, 1000000),
('70213', 'Четверг', '001', '006', '003', 20, 6000000),
('70214', 'Четверг', '003', '004', '002', 2, 16000),
('70215', 'Четверг', '004', '003', '004', 30, 4200000),
('70216', 'Суббота', '003', '002', '005', 10, 1200000),
('70217', 'Суббота', '002', '003', '008', 20, 8000000),
('70218', 'Суббота', '001', '001', '001', 20, 2000000),
('70219', 'Суббота', '005', '006', '004', 10, 1400000);
