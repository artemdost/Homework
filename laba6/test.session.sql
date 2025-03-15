-- Создание ролей (профилей)
CREATE ROLE admin WITH LOGIN PASSWORD 'adminpass';
CREATE ROLE guest WITH LOGIN PASSWORD 'guestpass';


GRANT ALL PRIVILEGES ON TABLE books TO admin;
GRANT USAGE, SELECT ON SEQUENCE books_id_seq TO admin;
-- Создание таблицы books
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    release_date DATE NOT NULL,
    genre TEXT NOT NULL
);

-- Назначение прав доступа
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO admin;
GRANT CONNECT ON DATABASE mydatabase TO guest;

GRANT ALL PRIVILEGES ON TABLE books TO admin;
GRANT SELECT ON TABLE books TO guest;

-- Хранимые процедуры

-- 1. Создание таблицы (если её нет)
CREATE OR REPLACE PROCEDURE create_books_table() AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'books') THEN
        CREATE TABLE books (
            id SERIAL PRIMARY KEY,
            title TEXT NOT NULL,
            release_date DATE NOT NULL,
            genre TEXT NOT NULL
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. Добавление книги
CREATE OR REPLACE PROCEDURE add_book(title TEXT, release_date DATE, genre TEXT) AS $$
BEGIN
    INSERT INTO books (title, release_date, genre) VALUES (title, release_date, genre);
END;
$$ LANGUAGE plpgsql;

-- 3. Поиск книг по жанру
DROP PROCEDURE IF EXISTS sp_search_books_by_title(text, OUT refcursor);
CREATE OR REPLACE PROCEDURE sp_search_books_by_title(_title text, OUT ref refcursor)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN ref FOR
        SELECT title, release_date, genre
        FROM books
        WHERE title ILIKE '%' || _title || '%';
END;
$$;

-- 4. Удаление книги по названию
CREATE OR REPLACE PROCEDURE delete_book_by_title(book_title TEXT) AS $$
BEGIN
    DELETE FROM books WHERE title = book_title;
END;
$$ LANGUAGE plpgsql;

-- 5. Удаление всех книг
CREATE OR REPLACE PROCEDURE delete_all_books() AS $$
BEGIN
    DELETE FROM books;
END;
$$ LANGUAGE plpgsql;

-- 6. Обновление книги по ID
CREATE OR REPLACE PROCEDURE update_book(book_id INT, new_title TEXT, new_release_date DATE, new_genre TEXT) AS $$
BEGIN
    UPDATE books
    SET title = new_title,
        release_date = new_release_date,
        genre = new_genre
    WHERE id = book_id;
END;
$$ LANGUAGE plpgsql;

ALTER USER admin CREATEDB;

-- 7. Создание нового пользователя с заданным режимом доступа
CREATE OR REPLACE PROCEDURE create_user(username TEXT, password TEXT, is_admin BOOLEAN) AS $$
BEGIN
    EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', username, password);

    IF is_admin THEN
        EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE mydatabase TO %I', username);
        EXECUTE format('GRANT ALL PRIVILEGES ON TABLE books TO %I', username);
    ELSE
        EXECUTE format('GRANT CONNECT ON DATABASE mydatabase TO %I', username);
        EXECUTE format('GRANT SELECT ON TABLE books TO %I', username);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. Удаление базы данных (для администратора)
CREATE OR REPLACE PROCEDURE drop_database() AS $$
BEGIN
    -- Удаляем базу данных (только для администратора)
    EXECUTE 'DROP DATABASE IF EXISTS mydatabase';
END;
$$ LANGUAGE plpgsql;

-- 9. Очистка таблицы (для администратора)
CREATE OR REPLACE PROCEDURE truncate_books_table() AS $$
BEGIN
    TRUNCATE TABLE books;
END;
$$ LANGUAGE plpgsql;


-- 9. Добавление новой бд
CREATE OR REPLACE PROCEDURE create_new_database(db_name TEXT) 
LANGUAGE plpgsql AS $$
BEGIN
    -- Создание новой базы данных
    EXECUTE format('CREATE DATABASE %I', db_name);

    -- Создание таблицы books в новой базе данных
    EXECUTE format('
        CREATE TABLE %I.books (
            id SERIAL PRIMARY KEY,
            title TEXT NOT NULL,
            release_date DATE NOT NULL,
            genre TEXT NOT NULL
        );
    ', db_name);

    -- Вывод сообщения об успешном создании
    RAISE NOTICE 'Database % and table "books" created successfully.', db_name;
END;
$$;