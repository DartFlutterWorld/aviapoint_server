#!/bin/bash

echo "=== Принудительная пересборка контейнера ==="
echo ""

cd /home/aviapoint_server

echo "1. Проверка кода с логированием:"
echo "--------------------------------------"
if grep -q "Upload photo: bodySize" lib/profiles/controller/profile_cantroller.dart; then
    echo "✅ Код с логированием найден"
else
    echo "❌ Код с логированием НЕ найден!"
    echo "Выполните: git pull"
    exit 1
fi
echo ""

echo "2. Остановка контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml stop app
echo ""

echo "3. Удаление старого образа:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml rm -f app
docker rmi aviapoint_server-app 2>/dev/null || echo "Образ уже удален или не существует"
echo ""

echo "4. Принудительная пересборка без кэша:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml build --no-cache app
echo ""

echo "5. Запуск контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml up -d app
echo ""

echo "6. Ожидание запуска (15 секунд):"
echo "--------------------------------------"
sleep 15
echo ""

echo "7. Проверка статуса:"
echo "--------------------------------------"
docker ps | grep aviapoint-server
echo ""

echo "8. Проверка последних логов:"
echo "--------------------------------------"
docker logs aviapoint-server --tail=30
echo ""

echo "=== Пересборка завершена ==="
echo ""
echo "Теперь попробуйте загрузить фото и проверьте логи:"
echo "docker logs -f aviapoint-server"
echo ""
echo "В логах должны появиться сообщения:"
echo "  - 'Upload photo: bodySize=...'"
echo "  - 'Upload photo: parsed X parts'"
echo "  - 'Upload photo: found photo field'"
echo "  - 'Upload photo: saving file to ...'"

