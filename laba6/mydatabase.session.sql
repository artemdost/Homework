CREATE TABLE mytable (
    id SERIAL PRIMARY KEY,
    data TEXT
);

GRANT ALL PRIVILEGES ON TABLE mytable TO admin;
GRANT ALL PRIVILEGES ON TABLE books TO admin;
GRANT USAGE, SELECT ON SEQUENCE mytable_id_seq TO admin;
GRANT USAGE, SELECT ON SEQUENCE books_id_seq TO admin;

CREATE TABLE books (
    id SERIAL PRIMARY KEY,          -- Уникальный идентификатор книги
    title TEXT NOT NULL,            -- Название книги
    release_date DATE NOT NULL,     -- Дата выхода книги
    genre TEXT NOT NULL             -- Жанр книги
);


-- Процедура для добавления данных
CREATE OR REPLACE PROCEDURE add_data(new_data TEXT) AS $$
BEGIN
    INSERT INTO mytable(data) VALUES (new_data);
END;
$$ LANGUAGE plpgsql;

-- Процедура для обновления данных
CREATE OR REPLACE PROCEDURE update_data(row_id INT, new_data TEXT) AS $$
BEGIN
    UPDATE mytable SET data = new_data WHERE id = row_id;
END;
$$ LANGUAGE plpgsql;

-- Процедура для удаления данных
CREATE OR REPLACE PROCEDURE delete_data(pattern TEXT) AS $$
BEGIN
    DELETE FROM mytable WHERE data LIKE pattern;
END;
$$ LANGUAGE plpgsql;

-- Функция для поиска данных (оставляем как функцию, так как она возвращает данные)
CREATE OR REPLACE FUNCTION search_data(pattern TEXT) RETURNS SETOF mytable AS $$
BEGIN
    RETURN QUERY SELECT * FROM mytable WHERE data LIKE pattern;
END;
$$ LANGUAGE plpgsql;