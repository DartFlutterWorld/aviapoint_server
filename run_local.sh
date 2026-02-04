#!/bin/bash

# Загружаем переменные окружения из .env.local
if [ -f .env.local ]; then
    # Загружаем переменные из .env.local
    set -a  # автоматически экспортировать все переменные
    source .env.local
    set +a  # отключить автоматический экспорт
    echo "✅ Переменные окружения загружены из .env.local"
    echo "   YOOKASSA_TEST_MODE=${YOOKASSA_TEST_MODE:-не установлено}"
else
    echo "⚠️  Файл .env.local не найден. Telegram уведомления будут отключены."
fi

# Запускаем сервер с переменными окружения
ENVIRONMENT=local dart run
