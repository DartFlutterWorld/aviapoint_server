#!/bin/bash

# Скрипт для полной очистки таблиц payments и subscriptions
# ВНИМАНИЕ: Это удалит ВСЕ данные из этих таблиц!
# Использование: ./clear_payments_subscriptions.sh [LOCAL|PROD]

ENVIRONMENT=${1:-"LOCAL"}

if [ "$ENVIRONMENT" = "PROD" ]; then
  echo "=========================================="
  echo "ОЧИСТКА ТАБЛИЦ НА ПРОДАКШЕНЕ"
  echo "=========================================="
  echo "⚠️  ВНИМАНИЕ: Это удалит ВСЕ данные!"
  echo ""
  read -p "Вы уверены? Введите 'yes' для подтверждения: " -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Отменено."
    exit 1
  fi
  
  SERVER_IP="83.166.246.205"
  SERVER_USER="root"
  SERVER_DB_CONTAINER="aviapoint-postgres"
  DB_USER="postgres"
  DB_NAME="aviapoint"
  
  echo "Подключение к продакшен серверу..."
  ssh $SERVER_USER@$SERVER_IP "docker exec $SERVER_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c \"TRUNCATE TABLE payments CASCADE; TRUNCATE TABLE subscriptions CASCADE;\""
  
  if [ $? -eq 0 ]; then
    echo "✅ Таблицы очищены на продакшене"
  else
    echo "❌ Ошибка при очистке таблиц"
    exit 1
  fi
else
  echo "=========================================="
  echo "ОЧИСТКА ТАБЛИЦ ЛОКАЛЬНО"
  echo "=========================================="
  echo "⚠️  ВНИМАНИЕ: Это удалит ВСЕ данные!"
  echo ""
  read -p "Вы уверены? Введите 'yes' для подтверждения: " -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Отменено."
    exit 1
  fi
  
  LOCAL_DB_CONTAINER="aviapoint-postgres"
  DB_USER="postgres"
  DB_NAME="aviapoint"
  
  echo "Очистка локальных таблиц..."
  
  if docker ps | grep -q $LOCAL_DB_CONTAINER; then
    docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "TRUNCATE TABLE payments CASCADE; TRUNCATE TABLE subscriptions CASCADE;"
    
    if [ $? -eq 0 ]; then
      echo "✅ Таблицы очищены локально"
      
      # Показываем количество записей (должно быть 0)
      echo ""
      echo "Проверка количества записей:"
      docker exec $LOCAL_DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "SELECT 'payments' as table_name, COUNT(*) as count FROM payments UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions;"
    else
      echo "❌ Ошибка при очистке таблиц"
      exit 1
    fi
  else
    echo "❌ Docker контейнер $LOCAL_DB_CONTAINER не запущен"
    echo "Запустите: docker-compose -f docker-compose.dev.yaml up -d"
    exit 1
  fi
fi

echo ""
echo "=========================================="
echo "Готово!"
echo "=========================================="

