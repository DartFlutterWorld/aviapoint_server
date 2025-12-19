#!/bin/bash

echo "=== Проверка прав доступа к папке public/profiles ==="
echo ""

echo "1. Проверка на хосте (вне контейнера):"
echo "--------------------------------------"
ls -la /home/aviapoint_server/public/profiles 2>/dev/null || echo "❌ Папка не существует на хосте"
echo ""

echo "2. Проверка внутри контейнера:"
echo "--------------------------------------"
docker exec aviapoint-server ls -la /app/public/profiles 2>/dev/null || echo "❌ Папка не существует в контейнере"
echo ""

echo "3. Проверка прав на запись (тест создания файла):"
echo "--------------------------------------"
if docker exec aviapoint-server touch /app/public/profiles/test_write.txt 2>/dev/null; then
    echo "✅ Запись возможна"
    docker exec aviapoint-server rm /app/public/profiles/test_write.txt 2>/dev/null
else
    echo "❌ Запись НЕВОЗМОЖНА - ошибка:"
    docker exec aviapoint-server touch /app/public/profiles/test_write.txt 2>&1
fi
echo ""

echo "4. Проверка пользователя, от которого запущено приложение:"
echo "--------------------------------------"
docker exec aviapoint-server whoami
echo ""

echo "5. Проверка владельца папки на хосте:"
echo "--------------------------------------"
stat -c "%U:%G %a" /home/aviapoint_server/public/profiles 2>/dev/null || echo "Не удалось получить информацию"
echo ""

echo "6. Проверка монтирования volume:"
echo "--------------------------------------"
docker inspect aviapoint-server | grep -A 10 "Mounts" | grep -A 5 "public"
echo ""

echo "7. Попытка создать папку, если её нет:"
echo "--------------------------------------"
docker exec aviapoint-server mkdir -p /app/public/profiles
docker exec aviapoint-server chmod 755 /app/public/profiles 2>/dev/null || echo "Не удалось изменить права (возможно, read-only)"
echo ""

echo "=== Проверка завершена ==="

