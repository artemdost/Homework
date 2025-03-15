#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL INCLUDE sqlca;

void get_connection_details(char *db_name, char *username, char *password) {
    printf("Enter database name: ");
    fgets(db_name, 256, stdin);
    db_name[strcspn(db_name, "\n")] = '\0'; // Удаление символа новой строки

    printf("Enter username: ");
    fgets(username, 256, stdin);
    username[strcspn(username, "\n")] = '\0'; // Удаление символа новой строки

    printf("Enter password: ");
    fgets(password, 256, stdin);
    password[strcspn(password, "\n")] = '\0'; // Удаление символа новой строки
}

void connect_to_db(const char *username, const char *password, const char *db_name) {
    EXEC SQL BEGIN DECLARE SECTION;
    const char *db_user = username;
    const char *db_pass = password;
    const char *db_name_conn = db_name;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL CONNECT TO :db_name_conn USER :db_user USING :db_pass;
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Connection failed: %s\n", sqlca.sqlerrm.sqlerrmc);
        exit(1);
    }
    printf("Connected to database '%s' successfully!\n", db_name_conn);
}

void add_book(const char *title, const char *release_date, const char *genre) {
    EXEC SQL BEGIN DECLARE SECTION;
    const char *book_title = title;
    const char *book_release_date = release_date;
    const char *book_genre = genre;
    EXEC SQL END DECLARE SECTION;

    // Вызов хранимой процедуры add_book
    EXEC SQL CALL add_book(:book_title, :book_release_date, :book_genre);
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to add book: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }
    EXEC SQL COMMIT; // Фиксируем изменения
    printf("Book added successfully!\n");
}

void search_books_by_genre(const char *genre) {
    EXEC SQL BEGIN DECLARE SECTION;
    int id;
    char title[256];
    char release_date[11]; // Формат даты: YYYY-MM-DD
    char book_genre[256];
    const char *search_genre = genre;
    EXEC SQL END DECLARE SECTION;

    // Используем курсор для поиска книг по жанру
    EXEC SQL DECLARE genre_cur CURSOR FOR
        SELECT id, title, release_date, genre 
        FROM books 
        WHERE genre ILIKE '%' || :search_genre || '%';
    EXEC SQL OPEN genre_cur;

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to open cursor: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }

    printf("\n--- Books in Genre: %s ---\n", search_genre);
    while (1) {
        EXEC SQL FETCH genre_cur INTO :id, :title, :release_date, :book_genre;
        if (sqlca.sqlcode == 100) break; // Код 100 означает "нет данных"
        if (sqlca.sqlcode != 0) {
            fprintf(stderr, "Failed to fetch data: %s\n", sqlca.sqlerrm.sqlerrmc);
            EXEC SQL ROLLBACK;
            break;
        }
        printf("ID: %d, Title: %s, Release Date: %s, Genre: %s\n", id, title, release_date, book_genre);
    }

    EXEC SQL CLOSE genre_cur;
}

void show_all_books() {
    EXEC SQL BEGIN DECLARE SECTION;
    int id;
    char title[256];
    char release_date[11]; // Формат даты: YYYY-MM-DD
    char genre[256];
    EXEC SQL END DECLARE SECTION;

    // Используем курсор для выборки всех книг
    EXEC SQL DECLARE all_books_cur CURSOR FOR
        SELECT * FROM books;
    EXEC SQL OPEN all_books_cur;
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to open cursor: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }

    printf("\n--- All Books ---\n");
    while (1) {
        EXEC SQL FETCH all_books_cur INTO :id, :title, :release_date, :genre;
        if (sqlca.sqlcode == 100) break; // Код 100 означает "нет данных"
        if (sqlca.sqlcode != 0) {
            fprintf(stderr, "Failed to fetch data: %s\n", sqlca.sqlerrm.sqlerrmc);
            EXEC SQL ROLLBACK;
            return;
        }
        printf("ID: %d, Title: %s, Release Date: %s, Genre: %s\n", id, title, release_date, genre);
    }
    EXEC SQL CLOSE all_books_cur;
}

void delete_book(const char *title) {
    EXEC SQL BEGIN DECLARE SECTION;
    const char *book_title = title;
    EXEC SQL END DECLARE SECTION;

    // Вызов хранимой процедуры delete_book_by_title
    EXEC SQL CALL delete_book_by_title(:book_title);
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to delete book: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }
    EXEC SQL COMMIT; // Фиксируем изменения
    printf("Book(s) deleted successfully!\n");
}

void delete_all_books() {
    // Вызов хранимой процедуры delete_all_books
    EXEC SQL CALL delete_all_books();
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to delete all books: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }
    EXEC SQL COMMIT; // Фиксируем изменения
    printf("All books deleted successfully!\n");
}

void update_book_by_id() {
    EXEC SQL BEGIN DECLARE SECTION;
    int book_id;
    char new_title[256];
    char new_release_date[11]; // Формат даты: YYYY-MM-DD
    char new_genre[256];
    EXEC SQL END DECLARE SECTION;

    // Запрос ID книги
    printf("Enter the ID of the book to update: ");
    scanf("%d", &book_id);
    getchar(); // Очистка буфера после ввода числа

    // Запрос нового названия
    printf("Enter the new title: ");
    fgets(new_title, sizeof(new_title), stdin);
    new_title[strcspn(new_title, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос новой даты выпуска
    printf("Enter the new release date (YYYY-MM-DD): ");
    fgets(new_release_date, sizeof(new_release_date), stdin);
    new_release_date[strcspn(new_release_date, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос нового жанра
    printf("Enter the new genre: ");
    fgets(new_genre, sizeof(new_genre), stdin);
    new_genre[strcspn(new_genre, "\n")] = '\0'; // Удаление символа новой строки

    // Вызов хранимой процедуры update_book
    EXEC SQL CALL update_book(:book_id, :new_title, :new_release_date, :new_genre);

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to update book: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }

    EXEC SQL COMMIT; // Фиксируем изменения
    printf("Book updated successfully!\n");
}

void show_current_database_and_user() {
    EXEC SQL BEGIN DECLARE SECTION;
    char db_name[256];
    char user_name[256];
    EXEC SQL END DECLARE SECTION;

    // Получаем текущую базу данных и пользователя
    EXEC SQL SELECT current_database(), current_user INTO :db_name, :user_name;

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to fetch current database and user: %s\n", sqlca.sqlerrm.sqlerrmc);
        return;
    }

    printf("Current Database: %s\n", db_name);
    printf("Current User: %s\n", user_name);
}


void create_and_switch_database(const char *db_name) {
    char command[512];

    // Формируем команду для создания базы данных через psql
    snprintf(command, sizeof(command), "psql -U admin -d postgres -c 'CREATE DATABASE %s'", db_name);

    // Выполняем команду через system()
    int result = system(command);

    if (result != 0) {
        fprintf(stderr, "Failed to create database: Command execution failed.\n");
        return;
    }

    printf("Database '%s' created successfully!\n", db_name);

    // Закрываем текущее подключение
    EXEC SQL DISCONNECT;
    printf("Disconnected from the current database.\n");

    // Подключаемся к новой базе данных
    connect_to_db("admin", "adminpass", db_name);

    // Выполняем SQL-запросы из шаблона
    snprintf(command, sizeof(command), "psql -U admin -d %s -f template.sql", db_name);
    result = system(command);

    if (result != 0) {
        fprintf(stderr, "Failed to execute template.sql: Command execution failed.\n");
        return;
    }

    printf("Procedures and permissions created successfully in database '%s'.\n", db_name);
}

void switch_database() {
    EXEC SQL BEGIN DECLARE SECTION;
    char db_name[256];
    char username[256];
    char password[256];
    EXEC SQL END DECLARE SECTION;

    // Запрос имени базы данных
    printf("Enter the name of the database: ");
    fgets(db_name, sizeof(db_name), stdin);
    db_name[strcspn(db_name, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос логина
    printf("Enter the username: ");
    fgets(username, sizeof(username), stdin);
    username[strcspn(username, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос пароля
    printf("Enter the password: ");
    fgets(password, sizeof(password), stdin);
    password[strcspn(password, "\n")] = '\0'; // Удаление символа новой строки

    // Закрываем текущее подключение
    EXEC SQL DISCONNECT;
    printf("Disconnected from the current database.\n");

    // Подключаемся к новой базе данных
    connect_to_db(username, password, db_name);
}

void delete_database() {
    EXEC SQL BEGIN DECLARE SECTION;
    char db_name[256];
    char current_user[256];
    bool is_admin; // Используем тип bool
    EXEC SQL END DECLARE SECTION;

    // Получаем текущего пользователя
    EXEC SQL SELECT current_user INTO :current_user;
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to get current user: %s\n", sqlca.sqlerrm.sqlerrmc);
        return;
    }

    printf("Current user: %s\n", current_user); // Отладочное сообщение

    // Проверяем, является ли пользователь администратором
    EXEC SQL SELECT rolsuper INTO :is_admin FROM pg_roles WHERE rolname = :current_user;
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to check admin privileges: %s\n", sqlca.sqlerrm.sqlerrmc);
        return;
    }

    printf("Is admin: %d\n", is_admin); // Отладочное сообщение

    if (!is_admin) { // Проверяем, что is_admin == false
        fprintf(stderr, "Permission denied: Only admin can delete databases.\n");
        return;
    }

    // Запрос имени базы данных для удаления
    printf("Enter the name of the database to delete: ");
    fgets(db_name, sizeof(db_name), stdin);
    db_name[strcspn(db_name, "\n")] = '\0'; // Удаление символа новой строки

    // Проверка длины имени базы данных
    if (strlen(db_name) > 242) {
        fprintf(stderr, "Database name is too long. Maximum length is 242 characters.\n");
        return;
    }

    // Формируем команду для удаления базы данных через psql
    char command[512];
    snprintf(command, sizeof(command), "psql -U admin -d postgres -c 'DROP DATABASE %s'", db_name);

    // Выполняем команду через system()
    int result = system(command);

    if (result != 0) {
        fprintf(stderr, "Failed to delete database: Command execution failed.\n");
        return;
    }

    printf("Database '%s' deleted successfully!\n", db_name);
}

void create_user_with_permissions() {
    EXEC SQL BEGIN DECLARE SECTION;
    char username[256];
    char password[256];
    int can_view;
    int can_insert;
    int can_update;
    int can_delete;
    EXEC SQL END DECLARE SECTION;

    // Запрос имени пользователя
    printf("Enter username: ");
    fgets(username, sizeof(username), stdin);
    username[strcspn(username, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос пароля
    printf("Enter password: ");
    fgets(password, sizeof(password), stdin);
    password[strcspn(password, "\n")] = '\0'; // Удаление символа новой строки

    // Запрос прав доступа
    printf("Can view (1/0): ");
    scanf("%d", &can_view);
    getchar(); // Очистка буфера после ввода числа

    printf("Can insert (1/0): ");
    scanf("%d", &can_insert);
    getchar(); // Очистка буфера после ввода числа

    printf("Can update (1/0): ");
    scanf("%d", &can_update);
    getchar(); // Очистка буфера после ввода числа

    printf("Can delete (1/0): ");
    scanf("%d", &can_delete);
    getchar(); // Очистка буфера после ввода числа

    // Вызов хранимой процедуры
    EXEC SQL CALL create_user_with_permissions(:username, :password, :can_view, :can_insert, :can_update, :can_delete);
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to create user: %s\n", sqlca.sqlerrm.sqlerrmc);
        EXEC SQL ROLLBACK;
        return;
    }

    EXEC SQL COMMIT; // Фиксируем изменения
    printf("User '%s' created successfully with selected permissions!\n", username);
}

// ANSI escape-коды для цветов
#define COLOR_RESET   "\033[0m"
#define COLOR_RED     "\033[31m"
#define COLOR_GREEN   "\033[32m"
#define COLOR_YELLOW  "\033[33m"
#define COLOR_BLUE    "\033[34m"
#define COLOR_MAGENTA "\033[35m"
#define COLOR_CYAN    "\033[36m"
#define COLOR_WHITE   "\033[37m"
#define COLOR_BOLD    "\033[1m"

void print_menu() {
    printf("\n%s--- Menu ---%s\n", COLOR_BOLD COLOR_BLUE, COLOR_RESET);
    printf("%s1.%s Add a book\n", COLOR_GREEN, COLOR_RESET);
    printf("%s2.%s Search books by genre\n", COLOR_GREEN, COLOR_RESET);
    printf("%s3.%s Show all books\n", COLOR_GREEN, COLOR_RESET);
    printf("%s4.%s Delete a book by title\n", COLOR_GREEN, COLOR_RESET);
    printf("%s5.%s Delete all books\n", COLOR_GREEN, COLOR_RESET);
    printf("%s6.%s Update a book by ID\n", COLOR_GREEN, COLOR_RESET);
    printf("%s7.%s Create and switch to a new database\n", COLOR_GREEN, COLOR_RESET);
    printf("%s8.%s Show current database and user\n", COLOR_GREEN, COLOR_RESET);
    printf("%s9.%s Switch database\n", COLOR_GREEN, COLOR_RESET);
    printf("%s10.%s Delete database (admin only)\n", COLOR_RED, COLOR_RESET);
    printf("%s11.%s Create user with permissions\n", COLOR_GREEN, COLOR_RESET); // Новый пункт
    printf("%s12.%s Exit\n", COLOR_RED, COLOR_RESET);
    printf("Enter your choice: ");
}

int main() {
    EXEC SQL BEGIN DECLARE SECTION;
    char db_name[256];
    char username[256];
    char password[256];
    EXEC SQL END DECLARE SECTION;

    // Запрашиваем данные для подключения
    get_connection_details(db_name, username, password);

    // Подключаемся к базе данных
    EXEC SQL CONNECT TO :db_name USER :username USING :password;
    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Connection failed: %s\n", sqlca.sqlerrm.sqlerrmc);
        return 1;
    }
    printf("Connected to database '%s' successfully!\n", db_name);

    // Основной цикл программы
    int choice;
    char input[256];
    char release_date[11]; // Формат даты: YYYY-MM-DD
    char genre[256];

    while (1) {
        print_menu();
        scanf("%d", &choice);
        getchar(); // Очистка буфера после ввода числа

        switch (choice) {
            case 1:
                printf("Enter book title: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = '\0'; // Удаление символа новой строки

                printf("Enter release date (YYYY-MM-DD): ");
                fgets(release_date, sizeof(release_date), stdin);
                release_date[strcspn(release_date, "\n")] = '\0'; // Удаление символа новой строки

                printf("Enter genre: ");
                fgets(genre, sizeof(genre), stdin);
                genre[strcspn(genre, "\n")] = '\0'; // Удаление символа новой строки

                add_book(input, release_date, genre);
                break;

            case 2:
                printf("Enter genre to search: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = '\0'; // Удаление символа новой строки

                search_books_by_genre(input);
                break;

            case 3:
                show_all_books();
                break;

            case 4:
                printf("Enter book title to delete: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = '\0'; // Удаление символа новой строки

                delete_book(input);
                break;

            case 5:
                delete_all_books();
                break;

            case 6:
                update_book_by_id();
                break;

            case 7:
                printf("Enter the name of the new database: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = '\0'; // Удаление символа новой строки

                create_and_switch_database(input);
                break;

            case 8:
                show_current_database_and_user();
                break;

            case 9:
                switch_database();
                break;

            case 10:
                delete_database();
                break;

            case 11: // Новый пункт
                create_user_with_permissions();
                break;

            case 12:
                EXEC SQL DISCONNECT;
                printf("Disconnected from database.\n");
                return 0;

            default:
                printf("Invalid choice. Please try again.\n");
                break;
        }
    }

    return 0;
}