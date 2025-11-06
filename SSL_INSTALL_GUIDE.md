# 🔒 Установка SSL сертификата для avia-point.com

## ⚡ Быстрый старт (5 минут)

### 1️⃣ На вашей машине - подготовка

```bash
# Перейдите в директорию проекта
cd /Users/admin/Projects/aviapoint_server

# Проверьте что конфиги обновлены
cat docker-compose.prod.yaml | grep avia-point.com
cat nginx.conf | grep avia-point.com

# Все должно содержать avia-point.com ✓
```

### 2️⃣ На VPS - развертывание

```bash
# SSH на VPS
ssh root@YOUR_VPS_IP

# Перейдите в директорию проекта (или клонируйте если первый раз)
cd /home/aviapoint/aviapoint_server

# Создайте .env из шаблона
cp env.example .env

# Отредактируйте важные переменные
nano .env
# Измените:
# - POSTGRESQL_PASSWORD на сложный пароль
# - SERVER_PORT если нужно

# Запустите автоматический скрипт развертывания
bash deploy.sh

# Или вручную:
docker-compose -f docker-compose.prod.yaml up -d
```

### 3️⃣ Проверка

```bash
# Дождитесь инициализации (30 сек)
sleep 30

# Проверьте что сертификат получен
ls -la ssl/live/avia-point.com/

# Проверьте HTTPS
curl -I https://avia-point.com
# Должен вернуть 200 OK

# Проверьте что API работает
curl https://avia-point.com/openapi -I
```

---

## 📋 Что происходит под капотом

### Шаг 1: Certbot получает сертификат

```
┌─────────────────────────────────────────────────┐
│ Let's Encrypt                                   │
│ └─ Отправляет вызов на avia-point.com:80       │
│    └─ Проверяет /.well-known/acme-challenge/   │
│       └─ Если OK → выдает сертификат            │
└─────────────────────────────────────────────────┘
```

### Шаг 2: Nginx переводит на HTTPS

```
User访问: http://avia-point.com
    ↓
nginx порт 80
    ↓
301 редирект → https://avia-point.com
    ↓
nginx порт 443 (SSL)
    ↓
proxy_pass → app:8080
```

---

## 🔧 Продвинутая конфигурация

### Автоматическое обновление сертификатов

```bash
# На VPS добавьте в crontab
crontab -e

# Добавьте:
# Обновление каждый месяц в 02:00
0 2 1 * * cd /home/aviapoint/aviapoint_server && \
  docker-compose -f docker-compose.prod.yaml exec -T certbot \
  certbot renew --quiet

# Сохраните (Ctrl+X, Y, Enter)
```

### Проверка сертификата

```bash
# Срок действия
openssl x509 -in ssl/live/avia-point.com/fullchain.pem -noout -enddate

# Получатель
openssl x509 -in ssl/live/avia-point.com/fullchain.pem -noout -subject

# Весь информация
openssl x509 -in ssl/live/avia-point.com/fullchain.pem -noout -text
```

### Обновление конфига nginx во время работы

```bash
# Без перезагрузки контейнера
docker exec aviapoint-nginx nginx -s reload

# С перезагрузкой контейнера
docker-compose -f docker-compose.prod.yaml restart nginx
```

---

## 🐛 Troubleshooting

### ❌ "Connection refused" на 80/443

**Проблема:** Порты не открыты на хосте

```bash
# На VPS проверьте firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### ❌ "Unable to locate a volume for acme challenge"

**Проблема:** Директория не существует

```bash
mkdir -p ssl public
chmod 755 ssl public
```

### ❌ "Certificate not yet valid"

**Проблема:** Время на сервере неправильное

```bash
# На VPS
date  # Проверьте время

# Синхронизируйте если нужно
sudo ntpdate -s time.nist.gov
# или
sudo timedatectl set-timezone UTC
sudo timedatectl set-ntp true
```

### ❌ Certbot выдает ошибку "too many requests"

**Проблема:** Лимит от Let's Encrypt на 50 сертификатов в неделю с одного IP

**Решение:** Используйте --dry-run для тестирования

```bash
docker exec aviapoint-certbot certbot renew --dry-run --quiet
```

### ❌ DNS не разрешается

**Проблема:** DNS записи не указывают на VPS

```bash
# Проверьте DNS
nslookup avia-point.com

# Должны вернуть IP вашего VPS
# Если нет - обновите DNS у регистратора
```

---

## 🎯 Финальная проверка

```bash
# Все сервисы работают?
docker-compose -f docker-compose.prod.yaml ps

# API доступен по HTTPS?
curl https://avia-point.com/openapi -v

# Сертификат правильный?
openssl s_client -connect avia-point.com:443 -brief

# HTTP редирект работает?
curl -L http://avia-point.com -v  # Должен редиректить на HTTPS
```

---

## ✅ Готово!

Ваше приложение работает на **https://avia-point.com** с защищенным SSL сертификатом! 🎉

**Дополнительно:**
- 📚 Читайте: [PRODUCTION_SETUP.md](./PRODUCTION_SETUP.md)
- 📊 Мониторьте: `docker logs -f aviapoint-nginx`
- 🔄 Обновляйте код: `git pull && docker-compose -f docker-compose.prod.yaml up -d --build`

