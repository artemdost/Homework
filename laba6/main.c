/* Processed by ecpg (16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "main.ec"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#line 1 "/usr/include/postgresql/sqlca.h"
#ifndef POSTGRES_SQLCA_H
#define POSTGRES_SQLCA_H

#ifndef PGDLLIMPORT
#if  defined(WIN32) || defined(__CYGWIN__)
#define PGDLLIMPORT __declspec (dllimport)
#else
#define PGDLLIMPORT
#endif							/* __CYGWIN__ */
#endif							/* PGDLLIMPORT */

#define SQLERRMC_LEN	150

#ifdef __cplusplus
extern "C"
{
#endif

struct sqlca_t
{
	char		sqlcaid[8];
	long		sqlabc;
	long		sqlcode;
	struct
	{
		int			sqlerrml;
		char		sqlerrmc[SQLERRMC_LEN];
	}			sqlerrm;
	char		sqlerrp[8];
	long		sqlerrd[6];
	/* Element 0: empty						*/
	/* 1: OID of processed tuple if applicable			*/
	/* 2: number of rows processed				*/
	/* after an INSERT, UPDATE or				*/
	/* DELETE statement					*/
	/* 3: empty						*/
	/* 4: empty						*/
	/* 5: empty						*/
	char		sqlwarn[8];
	/* Element 0: set to 'W' if at least one other is 'W'	*/
	/* 1: if 'W' at least one character string		*/
	/* value was truncated when it was			*/
	/* stored into a host variable.             */

	/*
	 * 2: if 'W' a (hopefully) non-fatal notice occurred
	 */	/* 3: empty */
	/* 4: empty						*/
	/* 5: empty						*/
	/* 6: empty						*/
	/* 7: empty						*/

	char		sqlstate[5];
};

struct sqlca_t *ECPGget_sqlca(void);

#ifndef POSTGRES_ECPG_INTERNAL
#define sqlca (*ECPGget_sqlca())
#endif

#ifdef __cplusplus
}
#endif

#endif

#line 5 "main.ec"


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
    /* exec sql begin declare section */
        
        
        
    
#line 23 "main.ec"
 const char * db_user = username ;
 
#line 24 "main.ec"
 const char * db_pass = password ;
 
#line 25 "main.ec"
 const char * db_name_conn = db_name ;
/* exec sql end declare section */
#line 26 "main.ec"


    { ECPGconnect(__LINE__, 0, db_name_conn , db_user , db_pass , NULL, 0); }
#line 28 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Connection failed: %s\n", sqlca.sqlerrm.sqlerrmc);
        exit(1);
    }
    printf("Connected to database '%s' successfully!\n", db_name_conn);
}

void add_book(const char *title, const char *release_date, const char *genre) {
    /* exec sql begin declare section */
        
        
        
    
#line 38 "main.ec"
 const char * book_title = title ;
 
#line 39 "main.ec"
 const char * book_release_date = release_date ;
 
#line 40 "main.ec"
 const char * book_genre = genre ;
/* exec sql end declare section */
#line 41 "main.ec"


    // Вызов хранимой процедуры add_book
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "call add_book ( $1  , $2  , $3  )", 
	ECPGt_char,&(book_title),(long)0,(long)1,(1)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,&(book_release_date),(long)0,(long)1,(1)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,&(book_genre),(long)0,(long)1,(1)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 44 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to add book: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 47 "main.ec"

        return;
    }
    { ECPGtrans(__LINE__, NULL, "commit");}
#line 50 "main.ec"
 // Фиксируем изменения
    printf("Book added successfully!\n");
}

void search_books_by_genre(const char *genre) {
    /* exec sql begin declare section */
     
     
      // Формат даты: YYYY-MM-DD
     
        
    
#line 56 "main.ec"
 int id ;
 
#line 57 "main.ec"
 char title [ 256 ] ;
 
#line 58 "main.ec"
 char release_date [ 11 ] ;
 
#line 59 "main.ec"
 char book_genre [ 256 ] ;
 
#line 60 "main.ec"
 const char * search_genre = genre ;
/* exec sql end declare section */
#line 61 "main.ec"


    // Используем курсор для поиска книг по жанру
    ECPGset_var( 0, &( search_genre ), __LINE__);\
 /* declare genre_cur cursor for select id , title , release_date , genre from books where genre ilike '%' || $1  || '%' */
#line 67 "main.ec"

#line 67 "main.ec"

    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "declare genre_cur cursor for select id , title , release_date , genre from books where genre ilike '%' || $1  || '%'", 
	ECPGt_char,&(search_genre),(long)0,(long)1,(1)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 68 "main.ec"


    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to open cursor: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 72 "main.ec"

        return;
    }

    printf("\n--- Books in Genre: %s ---\n", search_genre);
    while (1) {
        { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "fetch genre_cur", ECPGt_EOIT, 
	ECPGt_int,&(id),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(title),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(release_date),(long)11,(long)1,(11)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(book_genre),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 78 "main.ec"

        if (sqlca.sqlcode == 100) break; // Код 100 означает "нет данных"
        if (sqlca.sqlcode != 0) {
            fprintf(stderr, "Failed to fetch data: %s\n", sqlca.sqlerrm.sqlerrmc);
            { ECPGtrans(__LINE__, NULL, "rollback");}
#line 82 "main.ec"

            break;
        }
        printf("ID: %d, Title: %s, Release Date: %s, Genre: %s\n", id, title, release_date, book_genre);
    }

    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "close genre_cur", ECPGt_EOIT, ECPGt_EORT);}
#line 88 "main.ec"

}

void show_all_books() {
    /* exec sql begin declare section */
     
     
      // Формат даты: YYYY-MM-DD
     
    
#line 93 "main.ec"
 int id ;
 
#line 94 "main.ec"
 char title [ 256 ] ;
 
#line 95 "main.ec"
 char release_date [ 11 ] ;
 
#line 96 "main.ec"
 char genre [ 256 ] ;
/* exec sql end declare section */
#line 97 "main.ec"


    // Используем курсор для выборки всех книг
    /* declare all_books_cur cursor for select * from books */
#line 101 "main.ec"

    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "declare all_books_cur cursor for select * from books", ECPGt_EOIT, ECPGt_EORT);}
#line 102 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to open cursor: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 105 "main.ec"

        return;
    }

    printf("\n--- All Books ---\n");
    while (1) {
        { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "fetch all_books_cur", ECPGt_EOIT, 
	ECPGt_int,&(id),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(title),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(release_date),(long)11,(long)1,(11)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(genre),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 111 "main.ec"

        if (sqlca.sqlcode == 100) break; // Код 100 означает "нет данных"
        if (sqlca.sqlcode != 0) {
            fprintf(stderr, "Failed to fetch data: %s\n", sqlca.sqlerrm.sqlerrmc);
            { ECPGtrans(__LINE__, NULL, "rollback");}
#line 115 "main.ec"

            return;
        }
        printf("ID: %d, Title: %s, Release Date: %s, Genre: %s\n", id, title, release_date, genre);
    }
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "close all_books_cur", ECPGt_EOIT, ECPGt_EORT);}
#line 120 "main.ec"

}

void delete_book(const char *title) {
    /* exec sql begin declare section */
        
    
#line 125 "main.ec"
 const char * book_title = title ;
/* exec sql end declare section */
#line 126 "main.ec"


    // Вызов хранимой процедуры delete_book_by_title
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "call delete_book_by_title ( $1  )", 
	ECPGt_char,&(book_title),(long)0,(long)1,(1)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 129 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to delete book: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 132 "main.ec"

        return;
    }
    { ECPGtrans(__LINE__, NULL, "commit");}
#line 135 "main.ec"
 // Фиксируем изменения
    printf("Book(s) deleted successfully!\n");
}

void delete_all_books() {
    // Вызов хранимой процедуры delete_all_books
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "call delete_all_books ( )", ECPGt_EOIT, ECPGt_EORT);}
#line 141 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to delete all books: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 144 "main.ec"

        return;
    }
    { ECPGtrans(__LINE__, NULL, "commit");}
#line 147 "main.ec"
 // Фиксируем изменения
    printf("All books deleted successfully!\n");
}

void update_book_by_id() {
    /* exec sql begin declare section */
     
     
      // Формат даты: YYYY-MM-DD
     
    
#line 153 "main.ec"
 int book_id ;
 
#line 154 "main.ec"
 char new_title [ 256 ] ;
 
#line 155 "main.ec"
 char new_release_date [ 11 ] ;
 
#line 156 "main.ec"
 char new_genre [ 256 ] ;
/* exec sql end declare section */
#line 157 "main.ec"


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
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "call update_book ( $1  , $2  , $3  , $4  )", 
	ECPGt_int,&(book_id),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(new_title),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(new_release_date),(long)11,(long)1,(11)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(new_genre),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 180 "main.ec"


    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to update book: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 184 "main.ec"

        return;
    }

    { ECPGtrans(__LINE__, NULL, "commit");}
#line 188 "main.ec"
 // Фиксируем изменения
    printf("Book updated successfully!\n");
}

void show_current_database_and_user() {
    /* exec sql begin declare section */
     
     
    
#line 194 "main.ec"
 char db_name [ 256 ] ;
 
#line 195 "main.ec"
 char user_name [ 256 ] ;
/* exec sql end declare section */
#line 196 "main.ec"


    // Получаем текущую базу данных и пользователя
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select current_database ( ) , current_user", ECPGt_EOIT, 
	ECPGt_char,(db_name),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(user_name),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 199 "main.ec"


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
    { ECPGdisconnect(__LINE__, "CURRENT");}
#line 228 "main.ec"

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
    /* exec sql begin declare section */
     
     
     
    
#line 248 "main.ec"
 char db_name [ 256 ] ;
 
#line 249 "main.ec"
 char username [ 256 ] ;
 
#line 250 "main.ec"
 char password [ 256 ] ;
/* exec sql end declare section */
#line 251 "main.ec"


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
    { ECPGdisconnect(__LINE__, "CURRENT");}
#line 269 "main.ec"

    printf("Disconnected from the current database.\n");

    // Подключаемся к новой базе данных
    connect_to_db(username, password, db_name);
}

void delete_database() {
    /* exec sql begin declare section */
     
     
      // Используем тип bool
    
#line 278 "main.ec"
 char db_name [ 256 ] ;
 
#line 279 "main.ec"
 char current_user [ 256 ] ;
 
#line 280 "main.ec"
 bool is_admin ;
/* exec sql end declare section */
#line 281 "main.ec"


    // Получаем текущего пользователя
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select current_user", ECPGt_EOIT, 
	ECPGt_char,(current_user),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 284 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to get current user: %s\n", sqlca.sqlerrm.sqlerrmc);
        return;
    }

    printf("Current user: %s\n", current_user); // Отладочное сообщение

    // Проверяем, является ли пользователь администратором
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select rolsuper from pg_roles where rolname = $1 ", 
	ECPGt_char,(current_user),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_bool,&(is_admin),(long)1,(long)1,sizeof(bool), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 293 "main.ec"

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
    /* exec sql begin declare section */
     
     
     
     
     
     
    
#line 334 "main.ec"
 char username [ 256 ] ;
 
#line 335 "main.ec"
 char password [ 256 ] ;
 
#line 336 "main.ec"
 int can_view ;
 
#line 337 "main.ec"
 int can_insert ;
 
#line 338 "main.ec"
 int can_update ;
 
#line 339 "main.ec"
 int can_delete ;
/* exec sql end declare section */
#line 340 "main.ec"


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
    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "call create_user_with_permissions ( $1  , $2  , $3  , $4  , $5  , $6  )", 
	ECPGt_char,(username),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(password),(long)256,(long)1,(256)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(can_view),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(can_insert),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(can_update),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(can_delete),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 370 "main.ec"

    if (sqlca.sqlcode != 0) {
        fprintf(stderr, "Failed to create user: %s\n", sqlca.sqlerrm.sqlerrmc);
        { ECPGtrans(__LINE__, NULL, "rollback");}
#line 373 "main.ec"

        return;
    }

    { ECPGtrans(__LINE__, NULL, "commit");}
#line 377 "main.ec"
 // Фиксируем изменения
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
    /* exec sql begin declare section */
     
     
     
    
#line 411 "main.ec"
 char db_name [ 256 ] ;
 
#line 412 "main.ec"
 char username [ 256 ] ;
 
#line 413 "main.ec"
 char password [ 256 ] ;
/* exec sql end declare section */
#line 414 "main.ec"


    // Запрашиваем данные для подключения
    get_connection_details(db_name, username, password);

    // Подключаемся к базе данных
    { ECPGconnect(__LINE__, 0, db_name , username , password , NULL, 0); }
#line 420 "main.ec"

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
                { ECPGdisconnect(__LINE__, "CURRENT");}
#line 508 "main.ec"

                printf("Disconnected from database.\n");
                return 0;

            default:
                printf("Invalid choice. Please try again.\n");
                break;
        }
    }

    return 0;
}