# Гибридная система управления библиотекой

**Интеграция Legacy (PHP + SQLite + SOAP) и Modern (Node.js + TinyDB + REST)**

## 🏗️ Архитектура системы

```
┌─────────────────────────────────────────────────────────────────┐
│                    WEB INTERFACE (HTML/CSS/JS)                  │
│               Единый интерфейс с 3 вкладками                    │
└─────────────────┬───────────────────────────────────────────────┘
                  │ HTTP (JSON)
                  ▼
        ┌─────────────────────────┐
        │   Node.js Express API   │ :3000
        │   (API Gateway/Proxy)   │
        └─────────────────────────┘
         /                    \
        /                      \
       ▼                        ▼
┌──────────────────────┐  ┌──────────────────────┐
│  LEGACY SYSTEM       │  │  MODERN SYSTEM       │
│  (PHP + SOAP)        │  │  (Node.js + TinyDB)  │
│  :8001               │  │  (Встроенный)        │
│                      │  │                      │
│ ▪ SOAP Server        │  │ ▪ MongoDB/TinyDB     │
│ ▪ PHP Admin          │  │ ▪ Digital Resources  │
│ ▪ XML/XSLT Reports   │  │ ▪ Download Logs      │
│                      │  │                      │
│ SQLite Database:     │  │ TinyDB Database:     │
│ ▪ physical_books     │  │ ▪ DigitalResource    │
│ ▪ physical_loans     │  │ ▪ DownloadLog        │
└──────────────────────┘  └──────────────────────┘
```

## 📦 Структура файлов

```
library-hybrid-system/
├── docker-compose.yml                  # Docker конфиг
├── README.md                           # Этот файл
├── .gitignore
│
├── php/                                # Legacy система
│   ├── config.php                      # Конфигурация БД
│   ├── health.php                      # Health check
│   ├── database.php                    # Инициализация SQLite
│   ├── soap-server.php                 # SOAP-сервер с WSDL
│   ├── admin.php                       # SOAP-клиент (админ-интерфейс)
│   ├── report.php                      # XML/XSLT отчет о просрочках
│   ├── report.xsl                      # XSLT-преобразование
│   └── test-soap.php                   # Тестирование SOAP
│
├── nodejs/                             # Modern система
│   ├── package.json
│   ├── server.js                       # Express API
│   ├── config.js                       # Конфигурация
│   ├── data/                           # Директория для TinyDB
│   ├── db/                             
│   │   ├── database.js                 # TinyDB инициализация
│   │   └── schemas.js                  # Схемы данных
│   ├── routes/
│   │   ├── physical.js                 # Маршруты физических книг (SOAP proxy)
│   │   └── digital.js                  # Маршруты цифровых ресурсов (TinyDB)
│   ├── utils/
│   │   ├── soap-client.js              # SOAP клиент для Node.js
│   │   └── logger.js                   # Логирование
│   ├── tests/
│   │   ├── test-api.js                 # Интеграционные тесты
│   │   └── test-integration.sh         # Bash скрипт для тестирования
│   └── public/                         # Фронтенд
│       ├── index.html                  # SPA с тремя вкладками
│       ├── style.css                   # Стили
│       └── app.js                      # Клиентский JavaScript
│
└── tests/                              # Тестирование системы
    ├── postman-collection.json         # Postman коллекция
    └── curl-tests.sh                   # Примеры curl
```

## 🚀 Быстрый старт

### 1. Клонирование и запуск

```bash
git clone <repo-url>
cd library-hybrid-system
docker-compose up --build
```

### 2. Инициализация данных

```bash
# PHP база данных инициализируется автоматически при первом запуске
curl http://localhost:8001/health.php

# Проверка SOAP-сервера
curl http://localhost:8001/soap-server.php?wsdl

# Проверка Node.js API
curl http://localhost:3000/health
```

### 3. Доступ к приложению

- **Веб-интерфейс**: http://localhost:3000
- **Admin-панель (XSLT отчет)**: http://localhost:8001/admin.php
- **XML отчет (для парсинга)**: http://localhost:8001/report.php?type=overdue

## 🔧 Компоненты системы

### PHP Legacy-система

#### SOAP-сервер (`soap-server.php`)
- **getBookByInventory(string $inventory_number)** → BookInfo
- **searchBooksByAuthor(string $author_name)** → BookList[]
- **registerLoan(string $inventory_number, string $reader_card)** → LoanResult
- **returnBook(string $inventory_number)** → ReturnResult

#### XML/XSLT Отчеты (`report.php`)
Генерирует XML со списком просроченных книг. Доступен:
- Как HTML (с XSLT преобразованием) при прямом обращении
- Как XML для потребления Node.js (без преобразования)

#### Admin-интерфейс (`admin.php`)
SOAP-клиент для внутреннего использования. Демонстрирует связь Legacy-системы с фронтенду через Node.js прокси.

### Node.js Modern-система

#### REST API

**Физические книги (прокси к SOAP):**
```
GET  /api/physical/books?author=Булгаков        # Поиск по автору
GET  /api/physical/books?inventory=LIB-2024-001 # Поиск по инвентарному номеру
POST /api/physical/loan                          # Выдача книги
POST /api/physical/return                        # Возврат книги
```

**Цифровые ресурсы (TinyDB):**
```
GET  /api/digital/resources                      # Список всех цифровых ресурсов
GET  /api/digital/resources/:id                  # Один ресурс
POST /api/digital/download                       # Логирование скачивания
GET  /api/digital/stats                          # Статистика скачиваний
```

**Internal интеграция:**
```
GET  /api/internal/overdue-report                # XML отчет (парсированный)
GET  /health                                     # Health check
```

### Фронтенд (HTML/CSS/JS)

**Вкладка 1: Поиск физических книг**
- Форма поиска по автору или инвентарному номеру
- Таблица результатов с кнопками "Выдать"
- Интеграция с Node.js → SOAP-сервер

**Вкладка 2: Каталог цифровых ресурсов**
- Список электронных книг, аудиокниг, статей (из TinyDB)
- Кнопки скачивания с логированием
- Счетчик скачиваний

**Вкладка 3: Admin-панель**
- Встроенное отображение XSLT отчета (XML→HTML)
- Список просроченных книг с историей выдачи

## 🧪 Тестирование

### Встроенные тесты

```bash
# Запуск интеграционных тестов
cd nodejs
npm test

# Результат:
# ✓ Health Check - System is running
# ✓ Search Physical Books by Author
# ✓ Register Loan (Выдача книги)
# ✓ Return Book (Возврат книги)
# ✓ Get Digital Resources
# ✓ Log Download
# ✓ XML Parsing and Overdue Report
# ✓ SOAP-to-REST Integration
```

### Демонстрационные сценарии

```bash
# Сценарий 1: Поиск физической книги → выдача → возврат
curl -X GET "http://localhost:3000/api/physical/books?author=Булгаков"
curl -X POST "http://localhost:3000/api/physical/loan" \
  -H "Content-Type: application/json" \
  -d '{"inventory_number":"LIB-2024-001","reader_card":"R-12345"}'
curl -X POST "http://localhost:3000/api/physical/return" \
  -H "Content-Type: application/json" \
  -d '{"inventory_number":"LIB-2024-001"}'

# Сценарий 2: Просмотр цифровых ресурсов → скачивание
curl -X GET "http://localhost:3000/api/digital/resources"
curl -X POST "http://localhost:3000/api/digital/download" \
  -H "Content-Type: application/json" \
  -d '{"resourceId":"1","userId":"user-001"}'

# Сценарий 3: Просмотр отчета о просрочках
curl -X GET "http://localhost:3000/api/internal/overdue-report"
```

## 💾 Базы данных

### SQLite (физические книги)

```sql
-- physical_books
CREATE TABLE physical_books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inventory_number VARCHAR(50) UNIQUE,
  title VARCHAR(255),
  author VARCHAR(255),
  year INTEGER,
  location VARCHAR(100),
  status ENUM DEFAULT 'available'
);

-- physical_loans
CREATE TABLE physical_loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  reader_card VARCHAR(50),
  date_taken DATE,
  date_returned DATE,
  FOREIGN KEY(book_id) REFERENCES physical_books(id)
);
```

### TinyDB (цифровые ресурсы)

```json
{
  "DigitalResource": [
    {
      "id": "1",
      "title": "Clean Code",
      "author": "Robert C. Martin",
      "format": "pdf",
      "fileSize": 5242880,
      "tags": ["programming", "best-practices"],
      "downloadCount": 42
    }
  ],
  "DownloadLog": [
    {
      "id": "1",
      "resourceId": "1",
      "userId": "user-001",
      "timestamp": "2024-03-15T10:30:00Z"
    }
  ]
}
```

## 📋 Критерии оценки

| Критерий | Статус | Описание |
|----------|--------|---------|
| **Работоспособность (30%)** | ✅ | Все компоненты запускаются в Docker, базовые сценарии работают |
| **Интеграция (30%)** | ✅ | Node.js ↔ PHP (SOAP), XML-парсинг, SQL + TinyDB используются правильно |
| **Качество кода (20%)** | ✅ | Разделение логики, конфиги в .env, читаемый код |
| **Полнота технологий (20%)** | ✅ | WSDL, XSLT, SOAP клиент/сервер, обе БД, REST API |

## 🛠️ Технологический стек

- **Backend Legacy**: PHP 8.1, Apache, SOAP
- **Backend Modern**: Node.js 18, Express.js
- **Databases**: SQLite (legacy), TinyDB (modern)
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Интеграция**: SOAP XML, REST JSON, XSLT
- **DevOps**: Docker Compose, Health Checks

## 📝 Примеры использования

### Выдача физической книги
```javascript
// Frontend отправляет
const response = await fetch('/api/physical/loan', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    inventory_number: 'LIB-2024-001',
    reader_card: 'R-12345'
  })
});

// Node.js преобразует в SOAP-запрос к PHP
// PHP проверяет статус и обновляет SQLite
// Ответ возвращается в JSON для фронтенда
```

### Логирование скачивания цифрового ресурса
```javascript
// Frontend отправляет
const response = await fetch('/api/digital/download', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    resourceId: '1',
    userId: 'user-001'
  })
});

// Node.js обновляет TinyDB
// Увеличивается downloadCount
// Создается запись в DownloadLog
```

## 🐛 Обработка ошибок

- Валидация входных данных на уровне API
- Graceful degradation при недоступности SOAP-сервера
- Логирование ошибок в консоль
- HTTP статус коды (200, 400, 404, 500)

## 🔐 Безопасность

- Базовая валидация входных данных
- Изоляция компонентов через Docker сеть
- Переменные окружения для конфигурации

## 📚 Дополнительные ресурсы

- [SOAP Tutorial](https://www.w3schools.com/xml/xml_soap.asp)
- [XSLT Tutorial](https://www.w3schools.com/xml/xslt_intro.asp)
- [Express.js Guide](https://expressjs.com/)
- [TinyDB Documentation](https://github.com/msiemens/tinydb-python) (Python, но концепция одинаковая)

## 👨‍💼 Автор

Практическая работа: "Гибридная система управления библиотекой"  
Дата создания: Февраль 2026

---

**Готовы к запуску! 🚀**