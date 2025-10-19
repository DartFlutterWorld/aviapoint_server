# 🔧 Решение проблем при развертывании

## ❌ Частые ошибки и решения

### 1. **Приложение не стартует**

#### Симптомы:
```
Error: Container exited with code 1
docker-compose up failed
```

#### Решение:
```bash
# 1. Проверьте логи приложения
docker-compose -f docker-compose.prod.yaml logs app

# 2. Проверьте наличие библиотек
dart pub get

# 3. Проверьте конфигурацию
cat .env

# 4. Перестройте образ
docker-compose -f docker-compose.prod.yaml build --no-cache

# 5. Перезагрузитесь
docker-compose -f docker-compose.prod.yaml down -v
docker-compose -f docker-compose.prod.yaml up -d
```

---

### 2. **Ошибка подключения к БД**

#### Симптомы:
```
Error: Connection refused
postgres: connection refused
FATAL: Ident authentication failed
```

#### Решение:
```bash
# 1. Проверьте, запущена ли БД
docker-compose -f docker-compose.prod.yaml ps

# 2. Проверьте логи БД
docker-compose -f docker-compose.prod.yaml logs db

# 3. Проверьте переменные окружения
docker-compose -f docker-compose.prod.yaml config | grep POSTGRESQL

# 4. Убедитесь что переменные правильные
# .env должна содержать:
# POSTGRESQL_HOST=db
# POSTGRESQL_PASSWORD=your_password
# POSTGRESQL_DB=aviapoint

# 5. Проверьте сеть между контейнерами
docker network inspect aviapoint_server_backend

# 6. Если всё ещё не работает, пересоздайте
docker-compose -f docker-compose.prod.yaml down -v
docker volume prune -f
docker-compose -f docker-compose.prod.yaml up -d
```

---

### 3. **502 Bad Gateway (Nginx)**

#### Симптомы:
```
502 Bad Gateway - Nginx
curl: (52) Empty reply from server
```

#### Решение:
```bash
# 1. Проверьте, запущено ли приложение
docker-compose -f docker-compose.prod.yaml ps app

# 2. Проверьте логи приложения
docker-compose -f docker-compose.prod.yaml logs app -f

# 3. Проверьте логи Nginx
docker-compose -f docker-compose.prod.yaml logs nginx -f

# 4. Проверьте конфигурацию Nginx
docker exec aviapoint-nginx nginx -t

# 5. Перезагрузите Nginx
docker-compose -f docker-compose.prod.yaml restart nginx

# 6. Если приложение не отвечает, перезагрузите его
docker-compose -f docker-compose.prod.yaml restart app
```

---

### 4. **SSL сертификат не работает**

#### Симптомы:
```
ERR_SSL_PROTOCOL_ERROR
unable to get local issuer certificate
```

#### Решение:
```bash
# 1. Проверьте наличие сертификатов
ls -la /app/aviapoint_server/ssl/

# 2. Проверьте валидность сертификата
openssl x509 -in ssl/cert.pem -text -noout

# 3. Проверьте ключ
openssl rsa -in ssl/key.pem -check

# 4. Получите новый сертификат (Let's Encrypt)
sudo certbot certonly --standalone -d yourdomain.com

# 5. Скопируйте в проект
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
chmod 644 ssl/cert.pem
chmod 644 ssl/key.pem

# 6. Перезагрузите Nginx
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

### 5. **Nginx: permission denied**

#### Симптомы:
```
2024/01/15 10:00:00 [emerg] 1#1: open() "/etc/nginx/ssl/cert.pem" failed
permission denied
```

#### Решение:
```bash
# 1. Установите правильные права доступа
chmod 644 ssl/cert.pem
chmod 644 ssl/key.pem

# 2. Убедитесь что nginx может читать
ls -la ssl/

# 3. Проверьте владельца файлов
sudo chown 101:101 ssl/cert.pem ssl/key.pem

# 4. Перезагрузите
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

### 6. **Высокое использование памяти**

#### Симптомы:
```
Out of memory
Container killed
docker-compose logs show OOMKilled
```

#### Решение:
```bash
# 1. Проверьте использование памяти
docker stats

# 2. Очистите неиспользуемые контейнеры
docker container prune -f
docker image prune -f
docker volume prune -f

# 3. Проверьте размер БД
docker exec aviapoint-postgres du -sh /var/lib/postgresql/data

# 4. Добавьте ограничения памяти в docker-compose.prod.yaml
services:
  app:
    mem_limit: 1g
  db:
    mem_limit: 2g

# 5. Перезагрузитесь
docker-compose -f docker-compose.prod.yaml down
docker-compose -f docker-compose.prod.yaml up -d
```

---

### 7. **Медленный ответ API**

#### Симптомы:
```
Response time > 5000ms
curl -w "@curl-format.txt" https://yourdomain.com/api/profiles
```

#### Решение:
```bash
# 1. Проверьте логи производительности
docker-compose -f docker-compose.prod.yaml logs app | grep "took"

# 2. Включите профилирование
DART_ENV=debug docker-compose -f docker-compose.prod.yaml up

# 3. Оптимизируйте запросы к БД
# - Добавьте индексы
# - Используйте connection pooling
# - Кэшируйте результаты

# 4. Проверьте сеть
ping yourdomain.com
traceroute yourdomain.com

# 5. Проверьте DNS
nslookup yourdomain.com
```

---

### 8. **Невозможно подключиться к хосту**

#### Симптомы:
```
curl: (7) Failed to connect to yourdomain.com port 443
Connection refused
```

#### Решение:
```bash
# 1. Проверьте DNS
nslookup yourdomain.com
dig yourdomain.com

# 2. Проверьте, запущен ли Nginx
docker-compose -f docker-compose.prod.yaml ps nginx

# 3. Проверьте firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 4. Проверьте порты
netstat -tuln | grep 80
netstat -tuln | grep 443

# 5. Проверьте логи Nginx
docker-compose -f docker-compose.prod.yaml logs nginx

# 6. Проверьте конфиг Nginx
docker exec aviapoint-nginx nginx -t

# 7. Перезагрузите Nginx
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

### 9. **CORS ошибки**

#### Симптомы:
```
Access to XMLHttpRequest at 'https://yourdomain.com/api/...' from origin 'https://frontend.com' 
has been blocked by CORS policy
```

#### Решение:
```bash
# 1. Проверьте CORS конфигурацию в nginx.conf
# Убедитесь что cors headers добавлены

# 2. Проверьте origin
curl -i -X OPTIONS https://yourdomain.com/api/profiles \
  -H "Origin: https://frontend.com" \
  -H "Access-Control-Request-Method: GET"

# 3. Если нужно открыть все origins (не рекомендуется для production):
# add_header 'Access-Control-Allow-Origin' '*' always;

# 4. Если нужен specific origin:
# add_header 'Access-Control-Allow-Origin' 'https://frontend.com' always;

# 5. Перезагрузите
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

### 10. **Не могу залить большой файл**

#### Симптомы:
```
413 Request Entity Too Large
```

#### Решение:
```bash
# В nginx.conf увеличьте лимит:
client_max_body_size 100M;  # уже установлено

# Или для конкретного endpoint:
location /api/upload {
    client_max_body_size 500M;
    proxy_pass http://backend;
}

# Перезагрузите
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

## 🔍 Диагностика

### Проверить здоровье сервиса

```bash
# 1. Status контейнеров
docker-compose -f docker-compose.prod.yaml ps

# 2. Логи
docker-compose -f docker-compose.prod.yaml logs --tail=50 -f

# 3. Статистика ресурсов
docker stats

# 4. Проверить здоровье приложения
curl -i http://localhost:8080/openapi/

# 5. Проверить БД
docker exec -it aviapoint-postgres psql -U postgres -d aviapoint -c "SELECT 1"

# 6. Проверить сеть
docker network inspect aviapoint_server_backend

# 7. Полная диагностика
docker-compose -f docker-compose.prod.yaml logs
docker-compose -f docker-compose.prod.yaml config
docker inspect aviapoint-app
```

---

## 📋 Чек-лист для debugging

- [ ] Проверены ли логи (`docker logs`)?
- [ ] Запущены ли все контейнеры (`docker ps`)?
- [ ] Нормально ли работает сеть (`docker network`)?
- [ ] Правильны ли переменные окружения (`.env`)?
- [ ] Корректны ли права доступа на файлы?
- [ ] Достаточно ли ресурсов (памяти, диска)?
- [ ] Настроен ли firewall?
- [ ] Не истёк ли SSL сертификат?
- [ ] Проверена ли конфигурация (`docker-compose config`)?

---

## 🆘 Когда всё совсем плохо

```bash
# Полная очистка и переустановка
docker-compose -f docker-compose.prod.yaml down -v
docker system prune -f --volumes
docker-compose -f docker-compose.prod.yaml up -d --build

# Если это не помогло, проверьте:
# 1. Логи сервера: docker-compose logs
# 2. Системные логи: journalctl -xe
# 3. Disk space: df -h
# 4. Memory: free -h
# 5. Network: netstat -tuln
```

---

## 📞 Получить помощь

1. **Проверьте документацию:**
   - DEPLOYMENT.md - подробный гайд
   - HOSTING_GUIDE.md - путеводитель
   - ARCHITECTURE.md - архитектура

2. **Включите debug режим:**
   ```bash
   DART_ENV=debug docker-compose -f docker-compose.prod.yaml up
   ```

3. **Соберите информацию:**
   ```bash
   docker-compose -f docker-compose.prod.yaml logs > debug.log
   docker-compose -f docker-compose.prod.yaml ps > status.log
   # Отправьте логи разработчику
   ```

4. **Откройте issue на GitHub** с:
   - Полными логами
   - Описанием проблемы
   - Шагами для воспроизведения
   - Вашей конфигурацией (без чувствительных данных)
