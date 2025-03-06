@echo off
echo Компиляция исходных файлов...
javac --release 8 -cp postgresql-42.5.0.jar BookManager.java BookManagerGUI.java
if errorlevel 1 (
    echo Ошибка компиляции!
    pause
    exit /b 1
)
echo Запуск приложения...
java -cp .;postgresql-42.5.0.jar BookManagerGUI
pause
