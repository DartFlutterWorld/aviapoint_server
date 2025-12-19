#!/bin/bash

echo "=== Проверка кода загрузки фото в контейнере ==="
echo ""

echo "1. Проверка, что код с логированием есть в контейнере:"
echo "--------------------------------------"
if docker exec aviapoint-server grep -q "Upload photo:" /app/bin/server 2>/dev/null; then
    echo "✅ Код с логированием найден в бинарнике"
else
    echo "⚠️  Не удалось проверить бинарник напрямую"
    echo "Проверяем исходный код в репозитории:"
    if grep -q "Upload photo:" lib/profiles/controller/profile_cantroller.dart; then
        echo "✅ Код с логированием есть в исходниках"
        echo "⚠️  Но контейнер может использовать старый бинарник"
        echo "Нужно пересобрать контейнер:"
        echo "docker-compose -f docker-compose.prod.yaml build --no-cache app"
    else
        echo "❌ Код с логированием НЕ найден в исходниках"
    fi
fi
echo ""

echo "2. Проверка времени сборки контейнера:"
echo "--------------------------------------"
docker inspect aviapoint-server | grep -i "created\|started" | head -3
echo ""

echo "3. Проверка, что контейнер использует новый код (попробуйте загрузить фото и проверьте логи):"
echo "--------------------------------------"
echo "Выполните команду для просмотра логов в реальном времени:"
echo "docker logs -f aviapoint-server"
echo ""
echo "Затем попробуйте загрузить фото через фронтенд."
echo "В логах должны появиться сообщения:"
echo "  - 'Upload photo: bodySize=...'"
echo "  - 'Upload photo: parsed X parts'"
echo "  - 'Upload photo: found photo field'"
echo ""

echo "4. Если логи не появляются, принудительно пересоберите контейнер:"
echo "--------------------------------------"
echo "docker-compose -f docker-compose.prod.yaml build --no-cache app"
echo "docker-compose -f docker-compose.prod.yaml up -d app"
echo ""

