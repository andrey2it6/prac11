#!/bin/bash
# Quick start script для системы

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Гибридная система управления библиотекой - Quick Start     ║"
echo "║  Интеграция Legacy (PHP + SQLite) и Modern (Node.js + TinyDB)║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Проверяем Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и попробуйте снова."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Установите Docker Compose и попробуйте снова."
    exit 1
fi

echo "✅ Docker найден"
echo "✅ Docker Compose найден"
echo ""

# Проверяем, что мы в правильной директории
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml не найден. Убедитесь, что вы в корневой директории проекта."
    exit 1
fi

echo "📦 Запуск Docker контейнеров..."
echo ""

# Запускаем Docker Compose
docker-compose up --build -d

echo ""
echo "⏳ Ожидание инициализации сервисов (10 секунд)..."
sleep 10

echo ""
echo "🔍 Проверка здоровья сервисов..."
echo ""

# Проверяем Node.js
echo -n "Node.js API: "
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Готов"
else
    echo "⏳ Инициализируется..."
fi

# Проверяем PHP
echo -n "PHP Legacy: "
if curl -s http://localhost:8001/health.php > /dev/null 2>&1; then
    echo "✅ Готов"
else
    echo "⏳ Инициализируется..."
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    СИСТЕМА ЗАПУЩЕНА                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Доступные адреса:"
echo ""
echo "  🌐 Веб-интерфейс:     http://localhost:3000"
echo "  📊 Admin-панель:      http://localhost:8001/admin.php"
echo "  📋 Отчеты:            http://localhost:8001/report.php"
echo ""
echo "🔧 Команды:"
echo ""
echo "  # Просмотр логов:"
echo "  docker-compose logs -f"
echo ""
echo "  # Запуск тестов:"
echo "  docker-compose exec node npm test"
echo ""
echo "  # Остановка системы:"
echo "  docker-compose down"
echo ""
echo "📚 Документация:"
echo "  См. README.md для полной документации"
echo ""
echo "✨ Готовой к использованию! Откройте http://localhost:3000 в браузере."
echo ""
