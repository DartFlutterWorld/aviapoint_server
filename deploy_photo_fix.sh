#!/bin/bash

echo "=== Деплой исправления загрузки фото ==="
echo ""

echo "1. Проверка текущей версии кода:"
echo "--------------------------------------"
cd /home/aviapoint_server
git log --oneline -5
echo ""

echo "2. Получение последних изменений:"
echo "--------------------------------------"
git pull
echo ""

echo "3. Проверка, что файл содержит логирование:"
echo "--------------------------------------"
if grep -q "Upload photo:" lib/profiles/controller/profile_cantroller.dart; then
    echo "✅ Код с логированием найден"
else
    echo "❌ Код с логированием НЕ найден - возможно, нужно обновить код"
    exit 1
fi
echo ""

echo "4. Пересборка контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml build app
echo ""

echo "5. Перезапуск контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml up -d app
echo ""

echo "6. Ожидание запуска контейнера (10 секунд):"
echo "--------------------------------------"
sleep 10
echo ""

echo "7. Проверка статуса контейнера:"
echo "--------------------------------------"
docker ps | grep aviapoint-server
echo ""

echo "8. Проверка последних логов:"
echo "--------------------------------------"
docker logs aviapoint-server --tail=20
echo ""

echo "=== Деплой завершен ==="
echo ""
echo "Теперь попробуйте загрузить фото и проверьте логи:"
echo "docker logs -f aviapoint-server"

