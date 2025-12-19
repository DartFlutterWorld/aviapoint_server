#!/bin/bash

echo "=== Проверка загрузки фото ==="
echo ""

echo "1. Проверка последних логов приложения:"
echo "--------------------------------------"
docker logs aviapoint-server --tail=50 | grep -i "photo\|avatar\|profile\|upload" || echo "Нет записей о загрузке фото"
echo ""

echo "2. Проверка ошибок в логах:"
echo "--------------------------------------"
docker logs aviapoint-server --tail=100 | grep -i "error\|exception\|failed" | tail -10
echo ""

echo "3. Проверка структуры папки public:"
echo "--------------------------------------"
docker exec aviapoint-server ls -la /app/public/
echo ""

echo "4. Проверка рабочей директории приложения:"
echo "--------------------------------------"
docker exec aviapoint-server pwd
echo ""

echo "5. Проверка, может ли приложение создать файл в public/profiles:"
echo "--------------------------------------"
docker exec aviapoint-server sh -c "cd /app && echo 'test' > public/profiles/test_from_app.txt && cat public/profiles/test_from_app.txt && rm public/profiles/test_from_app.txt && echo '✅ Приложение может писать в папку' || echo '❌ Ошибка записи'"
echo ""

echo "6. Проверка переменных окружения:"
echo "--------------------------------------"
docker exec aviapoint-server env | grep -E "ENVIRONMENT|DART_ENV|WORKDIR" || echo "Нет специальных переменных"
echo ""

echo "=== Проверка завершена ==="
echo ""
echo "Если видите ошибки выше, проверьте:"
echo "- Правильность пути в коде (должен быть 'public/profiles/...')"
echo "- Логи при попытке загрузки фото через API"
echo "- Формат multipart запроса"

