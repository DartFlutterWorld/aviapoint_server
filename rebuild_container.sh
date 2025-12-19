#!/bin/bash

echo "=== Полная пересборка контейнера ==="
echo ""

cd /home/aviapoint_server

echo "1. Обновление кода:"
echo "--------------------------------------"
git pull
echo ""

echo "2. Проверка кода:"
echo "--------------------------------------"
if grep -q "UPLOAD PHOTO METHOD CALLED" lib/profiles/controller/profile_cantroller.dart; then
    echo "✅ Код обновлен"
else
    echo "❌ Код не обновлен! Выполните: git pull"
    exit 1
fi
echo ""

echo "3. Остановка и удаление контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml stop app
docker-compose -f docker-compose.prod.yaml rm -f app
echo ""

echo "4. Удаление образа:"
echo "--------------------------------------"
docker rmi aviapoint_server-app 2>/dev/null || echo "Образ уже удален или не существует"
echo ""

echo "5. Пересборка БЕЗ кэша:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml build --no-cache app
echo ""

echo "6. Запуск контейнера:"
echo "--------------------------------------"
docker-compose -f docker-compose.prod.yaml up -d app
echo ""

echo "7. Ожидание запуска (15 секунд):"
echo "--------------------------------------"
sleep 15
echo ""

echo "8. Проверка статуса:"
echo "--------------------------------------"
docker ps | grep aviapoint-server
echo ""

echo "9. Проверка последних логов:"
echo "--------------------------------------"
docker logs aviapoint-server --tail=20
echo ""

echo "=== Пересборка завершена ==="
echo ""
echo "Теперь попробуйте загрузить фото и проверьте логи:"
echo "docker logs -f aviapoint-server"
echo ""
echo "В логах должно появиться:"
echo "  === UPLOAD PHOTO METHOD CALLED ==="

