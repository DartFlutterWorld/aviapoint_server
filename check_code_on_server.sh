#!/bin/bash

echo "=== Проверка кода на сервере ==="
echo ""

cd /home/aviapoint_server

echo "1. Проверка версии кода в репозитории:"
echo "--------------------------------------"
git log --oneline -1
echo ""

echo "2. Проверка, что код с логированием есть:"
echo "--------------------------------------"
if grep -q "UPLOAD PHOTO METHOD CALLED" lib/profiles/controller/profile_cantroller.dart; then
    echo "✅ Код с проверкой найден"
else
    echo "❌ Код с проверкой НЕ найден!"
    echo "Выполните: git pull"
    exit 1
fi
echo ""

echo "3. Проверка времени последнего коммита:"
echo "--------------------------------------"
git log -1 --format="%ai %s"
echo ""

echo "4. Проверка времени сборки контейнера:"
echo "--------------------------------------"
docker inspect aviapoint-server | grep -i "created" | head -1
echo ""

echo "5. Проверка, что контейнер запущен:"
echo "--------------------------------------"
docker ps | grep aviapoint-server
echo ""

echo "=== Инструкции ==="
echo ""
echo "Если код обновлен, но логи не появляются:"
echo "1. Остановите контейнер: docker-compose -f docker-compose.prod.yaml stop app"
echo "2. Удалите образ: docker rmi aviapoint_server-app"
echo "3. Пересоберите: docker-compose -f docker-compose.prod.yaml build --no-cache app"
echo "4. Запустите: docker-compose -f docker-compose.prod.yaml up -d app"
echo "5. Проверьте логи: docker logs -f aviapoint-server"
echo ""
echo "При загрузке фото в логах должно появиться:"
echo "  === UPLOAD PHOTO METHOD CALLED ==="

