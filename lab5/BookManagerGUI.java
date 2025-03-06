
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.sql.*;
import java.util.Vector;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

public class BookManagerGUI extends JFrame {

    private BookManager manager;
    private JTable booksTable;  // Таблица для отображения данных
    private JLabel lblCurrentDB; // Метка для отображения имени текущей базы
    private String currentRole = "guest";

    public BookManagerGUI(BookManager manager) {
        this.manager = manager;
        setTitle("Менеджер книг");
        setSize(900, 600);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        initComponents();
        refreshBooksTable();
    }

    private void initComponents() {
        // Верхняя панель с информацией о текущей базе данных и кнопкой подключения
        JPanel topPanel = new JPanel(new BorderLayout());
        lblCurrentDB = new JLabel("Подключено к базе данных: " + getCurrentDatabaseName());
        topPanel.add(lblCurrentDB, BorderLayout.WEST);

        JButton btnConnect = new JButton("Подключить к базе");
        btnConnect.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                JTextField dbField = new JTextField();
                JTextField userField = new JTextField();
                JPasswordField passField = new JPasswordField();
                Object[] message = {
                    "Имя базы данных:", dbField,
                    "Логин:", userField,
                    "Пароль:", passField
                };
                int option = JOptionPane.showConfirmDialog(null, message, "Подключение к базе", JOptionPane.OK_CANCEL_OPTION);
                if (option == JOptionPane.OK_OPTION) {
                    String dbName = dbField.getText().trim();
                    String login = userField.getText().trim();
                    String password = new String(passField.getPassword());
                    if (dbName.isEmpty() || login.isEmpty() || password.isEmpty()) {
                        JOptionPane.showMessageDialog(null, "Все поля должны быть заполнены!");
                        return;
                    }
                    try {
                        // Закрываем старое соединение
                        manager.close();
                        // Подключаемся к новой базе
                        manager = new BookManager("jdbc:postgresql://localhost:5432/" + dbName, login, password);
                        JOptionPane.showMessageDialog(null, "Подключено к базе " + dbName);
                        // Обновляем метку текущей базы
                        lblCurrentDB.setText("Подключено к базе: " + dbName);
                        // Обновляем таблицу с данными
                        refreshBooksTable();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                        JOptionPane.showMessageDialog(null, "Ошибка подключения к базе: " + ex.getMessage());
                    }
                }
            }
        });

        // Левая панель с кнопками
        JPanel buttonPanel = new JPanel();
        buttonPanel.setLayout(new GridLayout(9, 1, 5, 5));

        JButton btnCreateDB = new JButton("Создать базу данных");
        btnCreateDB.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String newDBName = JOptionPane.showInputDialog("Введите имя новой базы данных (например, booksdb_new):");
                if (newDBName == null || newDBName.trim().isEmpty()) {
                    JOptionPane.showMessageDialog(null, "Имя базы данных не может быть пустым.");
                    return;
                }
                try {
                    createAndSetupDatabase(newDBName);
                    refreshBooksTable();
                    updateCurrentDBLabel(newDBName);
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка при создании базы данных: " + ex.getMessage());
                }
            }
        });

        JButton btnDropDB = new JButton("Удалить базу данных");
        btnDropDB.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String dbName = JOptionPane.showInputDialog("Введите имя базы данных для удаления:");
                if (dbName == null || dbName.trim().isEmpty()) {
                    JOptionPane.showMessageDialog(null, "Имя базы данных не может быть пустым.");
                    return;
                }
                // Предупреждаем, что нельзя удалять текущую базу, к которой подключены
                if (dbName.equalsIgnoreCase(getCurrentDatabaseName())) {
                    JOptionPane.showMessageDialog(null, "Нельзя удалить базу, к которой вы сейчас подключены. Сначала переключитесь на другую базу.");
                    return;
                }
                try {
                    dropDatabase(dbName);
                    JOptionPane.showMessageDialog(null, "База данных " + dbName + " удалена.");
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка при удалении базы данных: " + ex.getMessage());
                }
            }
        });

        JButton btnInsert = new JButton("Добавить книгу");
        btnInsert.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String title = JOptionPane.showInputDialog("Введите название книги:");
                String author = JOptionPane.showInputDialog("Введите автора книги:");
                String genre = JOptionPane.showInputDialog("Введите жанр книги:");
                try {
                    manager.insertBook(title, author, genre);
                    JOptionPane.showMessageDialog(null, "Книга добавлена");
                    refreshBooksTable();
                } catch (SQLException ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка: " + ex.getMessage());
                }
            }
        });

        JButton btnSearch = new JButton("Найти книги по автору");
        btnSearch.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String author = JOptionPane.showInputDialog("Введите имя автора для поиска:");
                try {
                    ResultSet rs = manager.searchBooksByAuthorForTable(author);
                    DefaultTableModel model = buildTableModel(rs);
                    booksTable.setModel(model);
                    rs.close();
                    JOptionPane.showMessageDialog(null, "Результаты поиска обновлены в таблице");
                } catch (SQLException ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка: " + ex.getMessage());
                }
            }
        });

        JButton btnUpdate = new JButton("Обновить книгу (обновление кортежа)");
        btnUpdate.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String title = JOptionPane.showInputDialog("Введите название книги для обновления:");
                String newAuthor = JOptionPane.showInputDialog("Введите нового автора:");
                String newGenre = JOptionPane.showInputDialog("Введите новый жанр:");
                try {
                    manager.updateBook(title, newAuthor, newGenre);
                    JOptionPane.showMessageDialog(null, "Книга обновлена");
                    refreshBooksTable();
                } catch (SQLException ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка: " + ex.getMessage());
                }
            }
        });

        JButton btnDelete = new JButton("Удалить книгу");
        btnDelete.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String title = JOptionPane.showInputDialog("Введите название книги для удаления:");
                try {
                    manager.deleteBookByTitle(title);
                    JOptionPane.showMessageDialog(null, "Книга удалена");
                    refreshBooksTable();
                } catch (SQLException ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка: " + ex.getMessage());
                }
            }
        });

        JButton btnClearTable = new JButton("Очистить таблицу");
        btnClearTable.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    manager.clearTable();
                    JOptionPane.showMessageDialog(null, "Таблица очищена");
                    refreshBooksTable();
                } catch (SQLException ex) {
                    JOptionPane.showMessageDialog(null, "Ошибка: " + ex.getMessage());
                }
            }
        });

        JButton btnRefresh = new JButton("Обновить таблицу");
        btnRefresh.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                refreshBooksTable();
            }
        });

        JButton btnShowUser = new JButton("Текущий пользователь");
        btnShowUser.addActionListener(e -> {
            try {
                String currentUser = manager.getCurrentUser();
                JOptionPane.showMessageDialog(null, "Сейчас вы работаете под пользователем: " + currentUser);
            } catch (SQLException ex) {
                JOptionPane.showMessageDialog(null, "Ошибка при получении имени пользователя: " + ex.getMessage());
            }
        });

        // Добавляем кнопки в левую панель
        buttonPanel.add(btnShowUser);
        buttonPanel.add(btnInsert);
        buttonPanel.add(btnSearch);
        buttonPanel.add(btnUpdate);
        buttonPanel.add(btnDelete);
        buttonPanel.add(btnClearTable);
        buttonPanel.add(btnRefresh);
        buttonPanel.add(btnConnect);
        buttonPanel.add(btnCreateDB);
        buttonPanel.add(btnDropDB);

        // Таблица для отображения данных
        booksTable = new JTable();
        JScrollPane tableScrollPane = new JScrollPane(booksTable);

        // Разбиваем окно: левая панель с кнопками, правая – таблица
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, buttonPanel, tableScrollPane);
        splitPane.setDividerLocation(250);

        // Устанавливаем компоновку основного окна
        getContentPane().setLayout(new BorderLayout());
        getContentPane().add(topPanel, BorderLayout.NORTH);
        getContentPane().add(splitPane, BorderLayout.CENTER);
    }

    // Метод для обновления таблицы (загрузка всех записей из books)
    private void refreshBooksTable() {
        try {
            ResultSet rs = manager.getAllBooks();
            DefaultTableModel model = buildTableModel(rs);
            booksTable.setModel(model);
            rs.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(null, "Ошибка обновления таблицы: " + ex.getMessage());
        }
    }

    // Вспомогательный метод для построения модели таблицы на основе ResultSet
    public static DefaultTableModel buildTableModel(ResultSet rs) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        Vector<String> columnNames = new Vector<>();
        int columnCount = metaData.getColumnCount();
        for (int column = 1; column <= columnCount; column++) {
            columnNames.add(metaData.getColumnName(column));
        }
        Vector<Vector<Object>> data = new Vector<>();
        while (rs.next()) {
            Vector<Object> vector = new Vector<>();
            for (int i = 1; i <= columnCount; i++) {
                vector.add(rs.getObject(i));
            }
            data.add(vector);
        }
        return new DefaultTableModel(data, columnNames);
    }

    /**
     * Метод, создающий новую базу данных (если она не существует), затем
     * выполняющий скрипт setup.sql, а потом переподключающийся к ней.
     */
    private void createAndSetupDatabase(String dbName) throws Exception {
        // Проверяем, что текущий пользователь является администратором
        String currentUser = manager.getCurrentUser();
        if (!"admin".equalsIgnoreCase(currentUser)) {
            throw new SecurityException("Недостаточно прав для создания базы данных! Операция доступна только администратору.");
        }

        boolean databaseCreated = false; // Флаг успешного создания базы

        // 1) Подключаемся к "postgres", чтобы проверить/создать новую базу
        String sysUrl = "jdbc:postgresql://localhost:5432/postgres";
        String sysUser = "postgres";
        String sysPass = "admin";
        try (Connection conn = DriverManager.getConnection(sysUrl, sysUser, sysPass)) {
            boolean exists = false;
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT 1 FROM pg_database WHERE datname = '" + dbName + "'")) {
                exists = rs.next();
            }
            if (exists) {
                JOptionPane.showMessageDialog(null, "База данных " + dbName + " уже существует. Пропускаем создание.");
            } else {
                try (Statement st = conn.createStatement()) {
                    st.executeUpdate("CREATE DATABASE " + dbName);
                    databaseCreated = true; // Флаг успешного создания
                }
                JOptionPane.showMessageDialog(null, "База данных " + dbName + " успешно создана!");
            }
        }

        // Если база не была создана (например, уже существует), выходим из метода
        if (!databaseCreated) {
            return;
        }

        // 2) Выполняем setup.sql в новой базе
        ProcessBuilder pb = new ProcessBuilder("psql", "-U", "postgres", "-d", dbName, "-f", "setup.sql");
        pb.environment().put("PGPASSWORD", "admin");
        pb.redirectErrorStream(true);
        Process proc = pb.start();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }
        int exitCode = proc.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("psql вернул код " + exitCode);
        }
        JOptionPane.showMessageDialog(null, "Скрипт setup.sql выполнен для базы данных " + dbName);

        // 3) Закрываем текущее соединение и переподключаемся к новой базе
        manager.close();
        manager = new BookManager("jdbc:postgresql://localhost:5432/" + dbName, "admin", "admin_pass");
        updateCurrentDBLabel(dbName);
        JOptionPane.showMessageDialog(null, "Подключено к базе данных " + dbName);
    }

    /**
     * Метод для удаления базы данных через подключение к базе postgres. Важно:
     * база, которую удаляют, не должна быть текущей.
     */
    private void dropDatabase(String dbName) throws Exception {
        String sysUrl = "jdbc:postgresql://localhost:5432/postgres";
        String sysUser = "postgres";
        String sysPass = "admin";
        try (Connection conn = DriverManager.getConnection(sysUrl, sysUser, sysPass)) {
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("DROP DATABASE IF EXISTS " + dbName);
            }
        }
    }

    /**
     * Метод для подключения к указанной базе данных.
     */
    private void connectToDatabase(String dbName) throws SQLException {
        manager.close();
        manager = new BookManager("jdbc:postgresql://localhost:5432/" + dbName, "admin", "admin_pass");
        updateCurrentDBLabel(dbName);
        refreshBooksTable();
    }

    /**
     * Возвращает имя текущей базы данных из URL соединения. Предполагается, что
     * URL имеет вид: jdbc:postgresql://host:port/dbName
     */
    private String getCurrentDatabaseName() {
        try {
            String url = manager.getConnection().getMetaData().getURL();
            String[] parts = url.split("/");
            return parts[parts.length - 1];
        } catch (SQLException e) {
            e.printStackTrace();
            return "Неизвестно";
        }
    }

    /**
     * Обновляет текст метки, отображающей имя текущей базы данных.
     */
    private void updateCurrentDBLabel(String dbName) {
        lblCurrentDB.setText("Подключено к базе данных: " + dbName);
    }

    public static void main(String[] args) {
        // Предварительный диалог для ввода данных подключения
        JTextField dbField = new JTextField("booksdb"); // можно задать значение по умолчанию
        JTextField userField = new JTextField();
        JPasswordField passField = new JPasswordField();

        Object[] message = {
            "Имя базы данных:", dbField,
            "Логин:", userField,
            "Пароль:", passField
        };

        int option = JOptionPane.showConfirmDialog(
                null,
                message,
                "Вход в базу данных",
                JOptionPane.OK_CANCEL_OPTION
        );

        if (option == JOptionPane.OK_OPTION) {
            String dbName = dbField.getText().trim();
            String login = userField.getText().trim();
            String password = new String(passField.getPassword());

            if (dbName.isEmpty() || login.isEmpty() || password.isEmpty()) {
                JOptionPane.showMessageDialog(null, "Все поля должны быть заполнены!");
                System.exit(1);
            }

            try {
                // Формируем URL подключения к указанной базе
                String url = "jdbc:postgresql://localhost:5432/" + dbName;
                BookManager manager = new BookManager(url, login, password);
                SwingUtilities.invokeLater(() -> {
                    new BookManagerGUI(manager).setVisible(true);
                });
            } catch (SQLException ex) {
                ex.printStackTrace();
                JOptionPane.showMessageDialog(null, "Ошибка подключения к базе: " + ex.getMessage());
            }
        } else {
            System.exit(0);
        }
    }
}
