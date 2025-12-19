💰 StudyMoney Desktop
StudyMoney — это современное десктопное приложение для управления личными финансами, разработанное с использованием C++ (Qt 6) и QML.
Приложение помогает студентам и молодым специалистам следить за бюджетом, анализировать расходы, копить на цели и получать автоматические рекомендации по финансовой грамотности.

📸 Скриншоты
<img width="1199" height="798" alt="image" src="https://github.com/user-attachments/assets/c9148a34-d619-4914-aacc-c6f752777243" />
<img width="1193" height="785" alt="image" src="https://github.com/user-attachments/assets/bc81fae7-a4fd-4ff8-b687-9391945c8e53" />
<img width="1189" height="787" alt="image" src="https://github.com/user-attachments/assets/f3abe0a4-01af-4a00-b87f-5b2eb21393d6" />
<img width="1190" height="798" alt="image" src="https://github.com/user-attachments/assets/bfdb1d61-bf86-41e3-bfce-2c2da6bc156a" />

🛠 Технологический стек
Язык: C++17
Фреймворк: Qt 6.5+ (Qt Quick / QML)
Сборка: CMake
База данных: PostgreSQL
Архитектура: Layered Architecture (MVC)
Стиль кода: Строгое ООП, SOLID принципы 
🏗 Архитектура приложения
Проект построен с использованием трехслойной архитектуры, что обеспечивает слабую связность компонентов и легкость в поддержке.
1. View (Представление)
Реализовано на QML.
Полностью кастомный UI (нет стандартных системных виджетов).
Адаптивный дизайн, поддержка Темной и Светлой темы.
Использование Canvas для отрисовки графиков и векторных иконок (без использования внешних изображений).
2. Controller (Контроллер)
Класс MainController.
Связывает QML и C++ через механизм Qt Properties и Signals/Slots.
Отвечает за логику приложения, валидацию данных и обновление интерфейса.
3. Model (Модель данных)
Реализована через строгие принципы ООП:
Абстракция: Интерфейс IStorage (чисто виртуальный класс) описывает контракт работы с данными.
Инкапсуляция: Класс SqlStorage скрывает реализацию SQL-запросов и подключение к БД.
Полиморфизм: Контроллер работает с указателем IStorage*, не зная о конкретной реализации базы данных.

🚀 Функционал
🏠 Дашборд
Отображение текущего баланса, общих доходов и расходов.
Таблица последних 7 операций (с цветовой индикацией: доходы — зеленые, расходы — красные).
📊 Аналитика
Круговая диаграмма (Pie Chart): Визуализация трат по категориям в процентах.
Столбчатая диаграмма (Bar Chart): Сравнение сумм расходов.
Все графики отрисованы вручную через HTML5 Canvas Context внутри QML.
🎯 Цели (Savings)
Создание финансовых целей (например, "На ноутбук").
Пополнение целей (списание средств с основного бюджета).
Визуальный прогресс-бар накопления.
💡 Умные рекомендации
Система анализирует траты за последние 30 дней.
Выдает советы, если траты по определенным категориям (Еда, Жилье) превышают норму или средние показатели по рынку.
⚙️ Интерфейс
Боковое меню (Sidebar) с навигацией.
Модальные диалоговые окна для ввода данных.
Переключение темы (Dark/Light Mode).
🗄 Структура Базы Данных (PostgreSQL)
Для работы приложения используются 4 связанные таблицы:
users — Хранение учетных записей, хэшей паролей, текущего бюджета.
expenses — История расходов (связь с users).
incomes — История доходов (связь с users).
goals — Финансовые цели и прогресс.
Пароли пользователей хэшируются (SHA-256) перед сохранением.

📥 Установка и запуск
Требования
Qt 6.5 или выше.
Компилятор C++ (MinGW или MSVC).
PostgreSQL.
1. Настройка Базы Данных
Создайте базу данных StudyMoney (или db) и выполните скрипт инициализации:
code
SQL
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    budget NUMERIC(10, 2) DEFAULT 0,
    spent NUMERIC(10, 2) DEFAULT 0
);

CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    category VARCHAR(50),
    date_added DATE DEFAULT CURRENT_DATE
);

CREATE TABLE incomes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    source VARCHAR(50),
    date_received DATE DEFAULT CURRENT_DATE
);

CREATE TABLE goals (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    target_amount NUMERIC(10, 2),
    current_amount NUMERIC(10, 2) DEFAULT 0
);
2. Сборка проекта
Откройте CMakeLists.txt в Qt Creator.
В файле Model/storage.cpp укажите ваши данные для подключения к БД:
code
C++
m_db.setHostName("127.0.0.1");
m_db.setDatabaseName("ВАШЕ_ИМЯ_БД");
m_db.setUserName("postgres");
m_db.setPassword("ВАШ_ПАРОЛЬ");
Нажмите Build и Run.

👨‍💻 Автор
Разработано в рамках курсовой работы по Объектно-Ориентированному Программированию.
2025 г.
