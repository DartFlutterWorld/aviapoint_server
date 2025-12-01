# ✅ Проверка статуса всех контейнеров

## Команда для проверки

```bash
# На сервере
cd /home/aviapoint_server
docker-compose -f docker-compose.prod.yaml ps
```

Или:

```bash
docker ps --filter "name=aviapoint"
```

---

## Ожидаемый результат

Должны быть запущены следующие контейнеры:

1. ✅ **aviapoint-postgres** - База данных PostgreSQL (статус: Healthy)
2. ✅ **aviapoint-server** - Серверное приложение (статус: Up)
3. ✅ **aviapoint-nginx** - Nginx reverse proxy (статус: Up)
4. ✅ **aviapoint-adminer** - Adminer для управления БД (статус: Up)
5. ✅ **aviapoint-certbot** - Certbot для SSL (статус: Up)

---

## Проблема: Два Adminer контейнера

Из вашего вывода видно:
- `Container server-side-adminer Recreated` - старый контейнер
- `Container aviapoint-adminer Started` - новый контейнер

**Нужно остановить старый контейнер:**

```bash
# На сервере
docker stop server-side-adminer
docker rm server-side-adminer
```

Или:

```bash
docker-compose -f docker-compose.prod.yaml down
docker-compose -f docker-compose.prod.yaml up -d
```

---

## Детальная проверка каждого контейнера

### 1. PostgreSQL (БД)

```bash
docker ps | grep aviapoint-postgres
docker logs --tail=20 aviapoint-postgres
```

Должен быть в статусе `Up` и `Healthy`.

### 2. Серверное приложение

```bash
docker ps | grep aviapoint-server
docker logs --tail=20 aviapoint-server
```

Должен быть в статусе `Up` и логи должны показывать запуск сервера.

### 3. Nginx

```bash
docker ps | grep aviapoint-nginx
docker logs --tail=20 aviapoint-nginx
```

Должен быть в статусе `Up`.

### 4. Adminer

```bash
docker ps | grep aviapoint-adminer
docker logs --tail=20 aviapoint-adminer
```

Должен быть в статусе `Up`.

### 5. Certbot

```bash
docker ps | grep aviapoint-certbot
```

Может быть в статусе `Exited` - это нормально, он запускается по расписанию.

---

## Проверка здоровья контейнеров

```bash
# Проверить healthcheck всех контейнеров
docker-compose -f docker-compose.prod.yaml ps
```

Все контейнеры должны быть либо `Up`, либо `Up (healthy)`.

---

## Если контейнер не запущен

### Проверить логи:

```bash
docker-compose -f docker-compose.prod.yaml logs [имя_сервиса]
```

Например:
```bash
docker-compose -f docker-compose.prod.yaml logs app
docker-compose -f docker-compose.prod.yaml logs db
```

### Перезапустить контейнер:

```bash
docker-compose -f docker-compose.prod.yaml restart [имя_сервиса]
```

### Пересоздать контейнер:

```bash
docker-compose -f docker-compose.prod.yaml up -d --force-recreate [имя_сервиса]
```

---

## Быстрая проверка всех сервисов

```bash
# На сервере выполните:
cd /home/aviapoint_server && \
echo "=== Статус всех контейнеров ===" && \
docker-compose -f docker-compose.prod.yaml ps && \
echo "" && \
echo "=== Проверка портов ===" && \
netstat -tuln | grep -E "8080|8082|5432|80|443" && \
echo "" && \
echo "=== Проверка логов сервера ===" && \
docker-compose -f docker-compose.prod.yaml logs --tail=5 app
```

---

## Очистка старых контейнеров

Если видите старые контейнеры (например, `server-side-adminer`):

```bash
# Остановить и удалить старые контейнеры
docker stop server-side-adminer 2>/dev/null
docker rm server-side-adminer 2>/dev/null

# Или очистить все остановленные контейнеры
docker container prune -f
```

---

**Готово!** Теперь вы знаете, как проверить статус всех контейнеров! ✅

