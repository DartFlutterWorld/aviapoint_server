#!/bin/bash

# Загружаем переменные окружения из .env.local
if [ -f .env.local ]; then
    export $(cat .env.local | grep -v '^#' | xargs)
    echo "✅ Переменные окружения загружены из .env.local"
else
    echo "⚠️  Файл .env.local не найден. Telegram уведомления будут отключены."
fi

# Запускаем сервер
ENVIRONMENT=local dart run
