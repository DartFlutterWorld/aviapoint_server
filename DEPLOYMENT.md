# 🚀 Руководство по развертыванию AviaPoint Server

## Требования

- Docker & Docker Compose
- Linux сервер (Ubuntu 20.04+ рекомендуется)
- Домен с SSL сертификатом
- SSH доступ на сервер
- Минимум 2GB RAM, 20GB SSD

## Варианты размещения

### 1️⃣ DigitalOcean App Platform (САМЫЙ ПРОСТОЙ)

**Преимущества:**
- Не требует Docker
- Автоматический CI/CD
- Встроенная PostgreSQL
- $12-40/месяц

**Шаги:**
1. Создайте App Platform приложение на DigitalOcean
2. Подключите GitHub репозиторий
3. Установите environment переменные из `env.example`
4. Запустите автоматический deploy

### 2️⃣ Render.com (РЕКОМЕНДУЕТСЯ)

**Преимущества:**
- Free tier доступен
- Поддержка Dart
- Автоматический SSL
- PostgreSQL included
- $7-25/месяц

**Шаги:**
```bash
# 1. Создайте новый Web Service на render.com
# 2. Подключите GitHub репозиторий
# 3. Установите Build Command:
dart pub get && dart compile exe lib/main.dart -o bin/server

# 4. Установите Start Command:
./bin/server

# 5. Добавьте PostgreSQL database
# 6. Установите environment переменные
```

### 3️⃣ VPS + Docker (ПОЛНЫЙ КОНТРОЛЬ)

**Рекомендуемые провайдеры:**
- Linode ($5-20/мес)
- Vultr ($5-20/мес)
- Hetzner ($3-10/мес)

#### Шаг 1: Подготовка сервера

```bash
# SSH на сервер
ssh root@your_server_ip

# Обновите систему
apt update && apt upgrade -y

# Установите Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установите Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Проверьте установку
docker --version
docker-compose --version
```

#### Шаг 2: Клонируйте репозиторий

```bash
# Создайте папку для приложения
mkdir -p /app && cd /app

# Клонируйте репозиторий
git clone https://github.com/yourusername/aviapoint_server.git
cd aviapoint_server

# Установите права
chmod +x start.sh
```

#### Шаг 3: Настройте переменные окружения

```bash
# Скопируйте и отредактируйте env файл
cp env.example .env

# Отредактируйте важные значения
nano .env

# Вставьте безопасные значения:
POSTGRESQL_PASSWORD=SuPeRsEcUrEp@ssw0rd123!
JWT_SECRET=$(openssl rand -hex 32)
```

#### Шаг 4: Получите SSL сертификат

```bash
# Установите Certbot
apt install certbot python3-certbot-nginx -y

# Получите сертификат (замените yourdomain.com)
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Сертификаты будут в:
# /etc/letsencrypt/live/yourdomain.com/
```

#### Шаг 5: Скопируйте SSL сертификаты

```bash
# Создайте SSL папку
mkdir -p /app/aviapoint_server/ssl

# Скопируйте сертификаты
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /app/aviapoint_server/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /app/aviapoint_server/ssl/key.pem

# Установите права доступа
chmod 644 /app/aviapoint_server/ssl/cert.pem
chmod 644 /app/aviapoint_server/ssl/key.pem
```

#### Шаг 6: Инициализируйте базу данных

```bash
# Создайте SQL файл для инициализации (если нужно)
cat > /app/aviapoint_server/init-db.sql << 'EOF'
-- Создайте необходимые таблицы здесь
-- Это выполнится при первом запуске

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Добавьте ваши миграции...
EOF
```

#### Шаг 7: Запустите Docker Compose

```bash
cd /app/aviapoint_server

# Запустите сервис
docker-compose -f docker-compose.prod.yaml up -d

# Проверьте статус
docker-compose -f docker-compose.prod.yaml ps

# Посмотрите логи
docker-compose -f docker-compose.prod.yaml logs -f app
```

#### Шаг 8: Настройте автообновление SSL

```bash
# Создайте скрипт обновления
sudo crontab -e

# Добавьте в crontab:
0 0 1 * * certbot renew --quiet && systemctl reload nginx
```

#### Шаг 9: Настройте Firewall

```bash
# UFW правила
sudo ufw enable
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS

# Проверьте
sudo ufw status
```

### 4️⃣ AWS (Для масштабирования)

**Компоненты:**
- EC2 для приложения
- RDS для PostgreSQL
- Route53 для DNS
- CloudFront для CDN

**Стоимость:** $20-100+/месяц

## Мониторинг и логи

```bash
# Просмотр логов приложения
docker-compose -f docker-compose.prod.yaml logs -f app

# Просмотр логов БД
docker-compose -f docker-compose.prod.yaml logs -f db

# Просмотр статистики
docker stats

# Вход в базу данных
docker exec -it aviapoint-postgres psql -U postgres -d aviapoint
```

## Backup и восстановление

### Создание бэкапа

```bash
# Бэкап базы данных
docker exec aviapoint-postgres pg_dump -U postgres -d aviapoint > backup_$(date +%Y%m%d).sql

# Бэкап всех данных
tar -czf aviapoint_backup_$(date +%Y%m%d).tar.gz /app/aviapoint_server/
```

### Восстановление

```bash
# Восстановите БД
cat backup_20240101.sql | docker exec -i aviapoint-postgres psql -U postgres -d aviapoint

# Восстановите файлы
tar -xzf aviapoint_backup_20240101.tar.gz -C /
```

## Обновление приложения

```bash
cd /app/aviapoint_server

# Загрузите новые изменения
git pull origin main

# Пересоберите контейнеры
docker-compose -f docker-compose.prod.yaml down
docker-compose -f docker-compose.prod.yaml build --no-cache
docker-compose -f docker-compose.prod.yaml up -d

# Проверьте
docker-compose -f docker-compose.prod.yaml logs -f app
```

## Решение проблем

### Контейнер не стартует

```bash
# Проверьте логи
docker-compose -f docker-compose.prod.yaml logs app

# Если БД недоступна, пересоздайте контейнер
docker-compose -f docker-compose.prod.yaml down -v
docker-compose -f docker-compose.prod.yaml up -d
```

### Нет соединения с БД

```bash
# Проверьте переменные окружения
docker-compose -f docker-compose.prod.yaml config

# Проверьте сеть
docker network ls
docker network inspect aviapoint_server_backend
```

### Высокое использование памяти

```bash
# Проверьте контейнеры
docker ps -a --no-trunc

# Очистите неиспользуемые контейнеры
docker container prune -f
docker image prune -f
docker volume prune -f
```

## Performance оптимизация

1. **Включите Gzip** - уже в nginx.conf ✅
2. **Cache static files** - уже в nginx.conf ✅
3. **Rate limiting** - уже в nginx.conf ✅
4. **Connection pooling** - настроить в Dart коде
5. **Database indexes** - добавить нужные индексы
6. **CDN** - использовать Cloudflare (free tier доступен)

## Безопасность

- ✅ SSL/TLS включен
- ✅ CORS настроен
- ✅ Security headers установлены
- ⚠️ Смените дефолтный пароль БД
- ⚠️ Используйте strong JWT secret
- ⚠️ Регулярно обновляйте пакеты
- ⚠️ Используйте firewall

## Поддержка

Для помощи:
1. Проверьте логи: `docker-compose logs`
2. Посмотрите ошибки: `docker-compose ps`
3. Проверьте конфиг: `docker-compose config`
