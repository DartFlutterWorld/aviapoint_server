#!/bin/bash

# Команды для выполнения на сервере через SSH
# Выполните эти команды после подключения по SSH

echo "=========================================="
echo "Команды для выполнения на сервере"
echo "=========================================="
echo ""
echo "1. Удаление данных из таблиц на сервере:"
echo "docker exec aviapoint-postgres psql -U postgres -d aviapoint -c \"TRUNCATE TABLE payments CASCADE; TRUNCATE TABLE subscriptions CASCADE;\""
echo ""
echo "2. После копирования файла на сервер, импорт данных:"
echo "docker exec -i aviapoint-postgres psql -U postgres -d aviapoint < /tmp/payments_subscriptions_export.sql"
echo ""
echo "3. Проверка количества записей:"
echo "docker exec aviapoint-postgres psql -U postgres -d aviapoint -c \"SELECT 'payments' as table_name, COUNT(*) as count FROM payments UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions;\""
echo ""

