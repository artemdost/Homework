-- =====================================================
-- Скрипт настройки базы данных для проекта "Book Manager"
-- =====================================================

-- =====================================================
-- 1. Создание таблицы "books"
-- =====================================================
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre VARCHAR(100)
);

-- =====================================================
-- 2. Создание ролей для доступа
-- =====================================================
DO $$
BEGIN
   -- Роль для администратора (полный доступ)
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_role') THEN
      CREATE ROLE admin_role;
   END IF;
   
   -- Роль для гостя (доступ только к просмотру и поиску)
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'guest_role') THEN
      CREATE ROLE guest_role;
   END IF;
END
$$;

-- =====================================================
-- 3. Процедуры управления базой данных
-- =====================================================

-- 3.1. Процедура для создания базы данных
-- Выполняется из системной базы (например, postgres). Вызов процедуры должен происходить только
-- от пользователя, обладающего правами admin_role.
DROP PROCEDURE IF EXISTS sp_create_database(text);
CREATE OR REPLACE PROCEDURE sp_create_database(db_name text)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE 'CREATE DATABASE ' || quote_ident(db_name);
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_create_database(text) TO admin_role;

-- 3.2. Процедура для удаления базы данных
DROP PROCEDURE IF EXISTS sp_drop_database(text);
CREATE OR REPLACE PROCEDURE sp_drop_database(db_name text)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE 'DROP DATABASE IF EXISTS ' || quote_ident(db_name);
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_drop_database(text) TO admin_role;

-- =====================================================
-- 4. Процедуры работы с таблицей "books"
-- =====================================================

-- 4.1. Процедура очистки таблицы "books"
DROP PROCEDURE IF EXISTS sp_clear_table();
CREATE OR REPLACE PROCEDURE sp_clear_table()
LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE TABLE books;
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_clear_table() TO admin_role;

-- 4.2. Процедура добавления новой книги
DROP PROCEDURE IF EXISTS sp_insert_book(text, text, text);
CREATE OR REPLACE PROCEDURE sp_insert_book(_title text, _author text, _genre text)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO books(title, author, genre) VALUES (_title, _author, _genre);
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_insert_book(text, text, text) TO admin_role;

-- 4.3. Процедура поиска книг по автору
DROP PROCEDURE IF EXISTS sp_search_books_by_author(text, OUT refcursor);
CREATE OR REPLACE PROCEDURE sp_search_books_by_author(_author text, OUT ref refcursor)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN ref FOR
        SELECT title, author, genre
        FROM books
        WHERE author ILIKE '%' || _author || '%';
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_search_books_by_author(text, OUT refcursor) TO admin_role, guest_role;

-- 4.4. Процедура обновления записи по названию книги (обновление кортежа)
DROP PROCEDURE IF EXISTS sp_update_book(text, text, text);
CREATE OR REPLACE PROCEDURE sp_update_book(_title text, _new_author text, _new_genre text)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE books 
    SET author = _new_author, genre = _new_genre
    WHERE title = _title;
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_update_book(text, text, text) TO admin_role;

-- 4.5. Процедура удаления книги по названию
DROP PROCEDURE IF EXISTS sp_delete_book_by_title(text);
CREATE OR REPLACE PROCEDURE sp_delete_book_by_title(_title text)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM books WHERE title = _title;
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_delete_book_by_title(text) TO admin_role;

-- =====================================================
-- 5. Процедура для получения всех записей из таблицы "books"
-- =====================================================
DROP PROCEDURE IF EXISTS sp_get_all_books();
CREATE OR REPLACE PROCEDURE sp_get_all_books(OUT ref refcursor)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN ref FOR SELECT * FROM books;
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_get_all_books() TO admin_role, guest_role;

-- =====================================================
-- 6. Процедура для создания нового пользователя с режимом доступа
-- =====================================================
DROP PROCEDURE IF EXISTS sp_create_user(text, text, text);
CREATE OR REPLACE PROCEDURE sp_create_user(_username text, _password text, _role text)
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE 'CREATE USER ' || quote_ident(_username) ||
            ' WITH PASSWORD ' || quote_literal(_password);
    IF lower(_role) = 'admin' THEN
        EXECUTE 'GRANT admin_role TO ' || quote_ident(_username);
    ELSIF lower(_role) = 'guest' THEN
        EXECUTE 'GRANT guest_role TO ' || quote_ident(_username);
    ELSE
        RAISE EXCEPTION 'Неверно указан режим доступа: %', _role;
    END IF;
END;
$$;
GRANT EXECUTE ON PROCEDURE sp_create_user(text, text, text) TO admin_role;

-- =====================================================
-- 7. Настройка прав на таблицу "books" и связанные объекты
-- =====================================================
-- Полный доступ для admin_role
GRANT ALL PRIVILEGES ON TABLE books TO admin_role;
-- Только SELECT для guest_role
GRANT SELECT ON TABLE books TO guest_role;

-- Права на последовательность, используемую для поля id
GRANT ALL PRIVILEGES ON SEQUENCE books_id_seq TO admin_role;
GRANT ALL PRIVILEGES ON SEQUENCE books_id_seq TO guest_role;

-- =====================================================
-- 8. Разрешения на подключение к базе данных (booksdb)
-- =====================================================
GRANT CONNECT ON DATABASE booksdb TO admin_role;
GRANT CONNECT ON DATABASE booksdb TO guest_role;

-- =====================================================
-- 9. Предоставление роли admin_role пользователю postgres
-- =====================================================
GRANT admin_role TO postgres;

-- =====================================================
-- 10. Создание пользователей admin и guest (пример)
-- =====================================================
CALL sp_create_user('admin', 'admin_pass', 'admin');
CALL sp_create_user('guest', 'guest_pass', 'guest');
