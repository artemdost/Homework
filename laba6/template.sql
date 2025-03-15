-- Создание таблицы books
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    release_date DATE NOT NULL,
    genre TEXT NOT NULL
);

-- Назначение прав доступа
GRANT ALL PRIVILEGES ON TABLE books TO admin;
GRANT USAGE, SELECT ON SEQUENCE books_id_seq TO admin;
ALTER USER admin WITH SUPERUSER;

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

CREATE OR REPLACE PROCEDURE create_user_with_permissions(
    username TEXT, 
    password TEXT, 
    can_view BOOLEAN, 
    can_insert BOOLEAN, 
    can_update BOOLEAN, 
    can_delete BOOLEAN
) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверка, существует ли пользователь
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = username) THEN
        RAISE EXCEPTION 'User "%" already exists.', username;
    END IF;

    -- Создание пользователя
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', username, password);

    -- Назначение прав доступа
    IF can_view THEN
        EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), username);
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA public TO %I', username);
        EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO %I', username);
    END IF;

    IF can_insert THEN
        EXECUTE format('GRANT INSERT ON ALL TABLES IN SCHEMA public TO %I', username);
        EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO %I', username);
    END IF;

    IF can_update THEN
        EXECUTE format('GRANT UPDATE ON ALL TABLES IN SCHEMA public TO %I', username);
    END IF;

    IF can_delete THEN
        EXECUTE format('GRANT DELETE ON ALL TABLES IN SCHEMA public TO %I', username);
    END IF;

    -- Логирование успешного создания пользователя
    RAISE NOTICE 'User "%" created successfully with selected permissions.', username;
EXCEPTION
    WHEN others THEN
        -- Логирование ошибки
        RAISE EXCEPTION 'Failed to create user "%": %', username, SQLERRM;
END;
$$;

    -- Создание пользователя
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', username, password);

    -- Назначение прав доступа
    IF can_view THEN
        EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), username);
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA public TO %I', username);
        EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO %I', username);
    END IF;

    IF can_insert THEN
        EXECUTE format('GRANT INSERT ON ALL TABLES IN SCHEMA public TO %I', username);
    END IF;

    IF can_update THEN
        EXECUTE format('GRANT UPDATE ON ALL TABLES IN SCHEMA public TO %I', username);
    END IF;

    IF can_delete THEN
        EXECUTE format('GRANT DELETE ON ALL TABLES IN SCHEMA public TO %I', username);
    END IF;

    -- Логирование успешного создания пользователя
    RAISE NOTICE 'User "%" created successfully with selected permissions.', username;
EXCEPTION
    WHEN others THEN
        -- Логирование ошибки
        RAISE EXCEPTION 'Failed to create user "%": %', username, SQLERRM;
END;

-- 2. Добавление книги
CREATE OR REPLACE PROCEDURE add_book(title TEXT, release_date DATE, genre TEXT) AS $$
BEGIN
    INSERT INTO books (title, release_date, genre) VALUES (title, release_date, genre);
END;
$$ LANGUAGE plpgsql;

-- 3. Поиск книг по жанру
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

-- 7. Создание нового пользователя с заданным режимом доступа
CREATE OR REPLACE PROCEDURE create_user(username TEXT, password TEXT, is_admin BOOLEAN) AS $$
BEGIN
    EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', username, password);

    IF is_admin THEN
        EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', current_database(), username);
        EXECUTE format('GRANT ALL PRIVILEGES ON TABLE books TO %I', username);
    ELSE
        EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', current_database(), username);
        EXECUTE format('GRANT SELECT ON TABLE books TO %I', username);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. Удаление базы данных (для администратора)
CREATE OR REPLACE PROCEDURE drop_database() AS $$
BEGIN
    -- Удаляем базу данных (только для администратора)
    EXECUTE format('DROP DATABASE IF EXISTS %I', current_database());
END;
$$ LANGUAGE plpgsql;

-- 9. Очистка таблицы (для администратора)
CREATE OR REPLACE PROCEDURE truncate_books_table() AS $$
BEGIN
    TRUNCATE TABLE books;
END;
$$ LANGUAGE plpgsql;

-- Назначение прав доступа для новой базы данных
GRANT ALL PRIVILEGES ON DATABASE current_database() TO admin;
GRANT CONNECT ON DATABASE current_database() TO guest;
GRANT ALL PRIVILEGES ON TABLE books TO admin;
GRANT SELECT ON TABLE books TO guest;