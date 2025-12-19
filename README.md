# StudyMoney Desktop

**StudyMoney** — это десктопное приложение для управления личными финансами, разработанное с использованием **C++ (Qt 6)** и **QML**.

Приложение ориентировано на студентов и молодых специалистов и помогает:

* контролировать бюджет,
* анализировать расходы,
* копить на цели,
* получать автоматические рекомендации по финансовой грамотности.


## 📸 Скриншоты

<p align="center">
  <img width="1199" alt="image" src="https://github.com/user-attachments/assets/c9148a34-d619-4914-aacc-c6f752777243" />
  <img width="1193" alt="image" src="https://github.com/user-attachments/assets/bc81fae7-a4fd-4ff8-b687-9391945c8e53" />
  <img width="1189" alt="image" src="https://github.com/user-attachments/assets/f3abe0a4-01af-4a00-b87f-5b2eb21393d6" />
  <img width="1190" alt="image" src="https://github.com/user-attachments/assets/bfdb1d61-bf86-41e3-bfce-2c2da6bc156a" />
</p>

---

## Технологический стек

* **Язык:** C++17
* **Фреймворк:** Qt 6.5+ (Qt Quick / QML)
* **Сборка:** CMake
* **База данных:** PostgreSQL
* **Архитектура:** Layered Architecture (MVC)
* **Стиль кода:** строгое ООП, принципы SOLID

---

## Архитектура приложения

Проект построен с использованием **трёхслойной архитектуры**, что обеспечивает слабую связность компонентов и простоту поддержки.

### 1️⃣ View (Представление)

* Реализовано на **QML**
* Полностью кастомный UI (без системных виджетов)
* Адаптивный дизайн
* Поддержка **Dark / Light Mode**
* Использование `Canvas` для:

  * графиков,
  * векторных иконок
    *(без внешних изображений)*

### Controller (Контроллер)

* Класс **MainController**
* Связь QML ↔ C++ через:

  * `Q_PROPERTY`
  * Signals / Slots
* Отвечает за:

  * бизнес-логику,
  * валидацию данных,
  * обновление интерфейса

### Model (Модель данных)

Реализована с применением строгих принципов ООП:

* **Абстракция:**
  Интерфейс `IStorage` (чисто виртуальный класс) описывает контракт работы с данными

* **Инкапсуляция:**
  Класс `SqlStorage` скрывает реализацию SQL-запросов и подключение к БД

* **Полиморфизм:**
  Контроллер работает с `IStorage*`, не зная конкретной реализации хранилища

---

## 🚀 Функционал

### 🏠 Дашборд

* Текущий баланс
* Общие доходы и расходы
* Таблица последних **7 операций**

### Аналитика

* **Круговая диаграмма (Pie Chart)**
  Распределение расходов по категориям (%)
* **Столбчатая диаграмма (Bar Chart)**
  Сравнение сумм расходов
* Все графики отрисованы вручную через **HTML5 Canvas Context в QML**

### Цели (Savings)

* Создание финансовых целей (например, *«На ноутбук»*)
* Пополнение целей с основного бюджета
* Визуальный прогресс-бар накоплений

### Умные рекомендации

* Анализ трат за последние **30 дней**
* Советы при превышении норм по категориям (еда, жильё и т.д.)
* Сравнение с усреднёнными значениями

### Интерфейс

* Боковое меню (Sidebar)
* Модальные диалоги для ввода данных
* Переключение темы **Dark / Light**

---

## Структура базы данных (PostgreSQL)

Приложение использует **4 связанные таблицы**:

* `users` — пользователи, хэши паролей, текущий бюджет
* `expenses` — история расходов
* `incomes` — история доходов
* `goals` — финансовые цели

Пароли пользователей хэшируются с использованием **SHA-256**.

---

## становка и запуск

### Требования

* Qt 6.5+
* Компилятор C++ (MSVC или MinGW)
* PostgreSQL

---

### 1️⃣ Настройка базы данных

Создайте базу данных `StudyMoney` (или `db`) и выполните SQL-скрипт:

```sql
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
```

---

### 2️⃣ Сборка проекта

1. Откройте `CMakeLists.txt` в **Qt Creator**
2. В файле `Model/storage.cpp` укажите параметры подключения к БД:

```cpp
m_db.setHostName("127.0.0.1");
m_db.setDatabaseName("ВАШЕ_ИМЯ_БД");
m_db.setUserName("postgres");
m_db.setPassword("ВАШ_ПАРОЛЬ");
```

3. Нажмите **Build** → **Run**

---

## Автор (Roman Snitko)

Разработано в рамках курсовой работы по дисциплине
**«Объектно-Ориентированное Программирование»**

**2025 год**

---
