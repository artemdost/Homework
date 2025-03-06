
import java.sql.*;
import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.RowSetProvider;

public class BookManager {

    private Connection connection;

    // Конструктор устанавливает подключение к базе данных и отключает автокоммит.
    public BookManager(String url, String user, String password) throws SQLException {
        connection = DriverManager.getConnection(url, user, password);
        connection.setAutoCommit(false); // отключаем автокоммит для ручного управления транзакциями
    }

    // Метод для добавления новой книги через вызов процедуры sp_insert_book
    public void insertBook(String title, String author, String genre) throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_insert_book(?, ?, ?)")) {
            cs.setString(1, title);
            cs.setString(2, author);
            cs.setString(3, genre);
            cs.execute();
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("insertBook", e);
            throw e;
        }
    }

    // Метод для поиска книг по автору, выводящий данные в консоль
    public void searchBooksByAuthor(String author) throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_search_books_by_author(?, ?)")) {
            cs.setString(1, author);
            cs.registerOutParameter(2, Types.OTHER);
            cs.execute();
            try (ResultSet rs = (ResultSet) cs.getObject(2)) {
                while (rs.next()) {
                    System.out.println("Название: " + rs.getString("title")
                            + ", Автор: " + rs.getString("author")
                            + ", Жанр: " + rs.getString("genre"));
                }
            }
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("searchBooksByAuthor", e);
            throw e;
        }
    }

    // Метод для поиска книг по автору, возвращающий данные для таблицы
    public ResultSet searchBooksByAuthorForTable(String author) throws SQLException {
        CachedRowSet crs;
        try (CallableStatement cs = connection.prepareCall("call sp_search_books_by_author(?, ?)")) {
            cs.setString(1, author);
            cs.registerOutParameter(2, Types.OTHER);
            cs.execute();
            try (ResultSet rs = (ResultSet) cs.getObject(2)) {
                crs = RowSetProvider.newFactory().createCachedRowSet();
                crs.populate(rs);
            }
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("searchBooksByAuthorForTable", e);
            throw e;
        }
        return crs;
    }

    // Метод для получения всех записей из таблицы books через процедуру sp_get_all_books
    public ResultSet getAllBooks() throws SQLException {
        CachedRowSet crs;
        try (CallableStatement cs = connection.prepareCall("call sp_get_all_books(?)")) {
            cs.registerOutParameter(1, Types.OTHER);
            cs.execute();
            try (ResultSet rs = (ResultSet) cs.getObject(1)) {
                crs = RowSetProvider.newFactory().createCachedRowSet();
                crs.populate(rs);
            }
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("getAllBooks", e);
            throw e;
        }
        return crs;
    }

    // Метод для обновления записи по названию книги через процедуру sp_update_book
    public void updateBook(String title, String newAuthor, String newGenre) throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_update_book(?, ?, ?)")) {
            cs.setString(1, title);
            cs.setString(2, newAuthor);
            cs.setString(3, newGenre);
            cs.execute();
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("updateBook", e);
            throw e;
        }
    }

    // Метод для удаления книги по названию через процедуру sp_delete_book_by_title
    public void deleteBookByTitle(String title) throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_delete_book_by_title(?)")) {
            cs.setString(1, title);
            cs.execute();
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("deleteBookByTitle", e);
            throw e;
        }
    }

    // Метод для очистки таблицы через процедуру sp_clear_table
    public void clearTable() throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_clear_table()")) {
            cs.execute();
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("clearTable", e);
            throw e;
        }
    }

    // Метод для создания нового пользователя через процедуру sp_create_user
    public void createUser(String username, String password, String role) throws SQLException {
        try (CallableStatement cs = connection.prepareCall("call sp_create_user(?, ?, ?)")) {
            cs.setString(1, username);
            cs.setString(2, password);
            cs.setString(3, role);
            cs.execute();
            connection.commit();
        } catch (SQLException e) {
            rollbackAndLog("createUser", e);
            throw e;
        }
    }

    // Метод для получения имени текущего пользователя PostgreSQL
    public String getCurrentUser() throws SQLException {
        try (Statement st = connection.createStatement(); ResultSet rs = st.executeQuery("SELECT current_user")) {
            if (rs.next()) {
                return rs.getString(1);
            } else {
                return "Неизвестно";
            }
        } catch (SQLException e) {
            rollbackAndLog("getCurrentUser", e);
            throw e;
        }
    }

    // Метод для получения имени текущей базы данных из URL соединения
    public String getDatabaseName() throws SQLException {
        try {
            String url = connection.getMetaData().getURL();
            String[] parts = url.split("/");
            return parts[parts.length - 1];
        } catch (SQLException e) {
            rollbackAndLog("getDatabaseName", e);
            throw e;
        }
    }

    // Закрытие соединения
    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    // Геттер для Connection, если потребуется
    public Connection getConnection() {
        return connection;
    }

    // Вспомогательный метод для отката транзакции и логирования ошибки
    private void rollbackAndLog(String method, SQLException e) {
        System.err.println("Ошибка в методе " + method + ": " + e.getMessage());
        try {
            if (connection != null && !connection.isClosed()) {
                connection.rollback();
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
