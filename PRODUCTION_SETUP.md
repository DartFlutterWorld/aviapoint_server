# Production Setup для avia-point.com

## Предварительные требования

1. **VPS с установленным Docker и Docker Compose**
2. **Домен avia-point.com** с DNS указывающими на IP вашего VPS
3. **SSH доступ** к VPS

## Шаг 1: Настройка DNS

Перед началом убедитесь, что DNS правильно настроены:

```bash
# На вашей машине
nslookup avia-point.com
# Должен вернуть IP вашего VPS
```

## Шаг 2: Подготовка VPS

```bash
# SSH на VPS
ssh root@YOUR_VPS_IP

# Обновите систему
apt update && apt upgrade -y

# Установите Docker (если не установлен)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Проверьте установку
docker --version
docker-compose --version
```

## Шаг 3: Клонируйте проект

```bash
# Перейдите в домашнюю директорию
cd /home/aviapoint

# Клонируйте репозиторий
git clone https://github.com/YOUR_USERNAME/aviapoint_server.git
cd aviapoint_server
```

## Шаг 4: Создайте .env файл

```bash
# Скопируйте шаблон
cp env.example .env

# Отредактируйте с нужными паролями и ключами
nano .env
```

**Важные переменные для production:**

```
POSTGRESQL_PASSWORD=<ОЧЕНЬ_НАДЕЖНЫЙ_ПАРОЛЬ>
POSTGRESQL_DB=aviapoint
POSTGRESQL_USER=postgres
SERVER_PORT=8080
DART_ENV=production
```

## Шаг 5: Создайте структуру директорий

```bash
# Создайте директорию для SSL сертификатов
mkdir -p ssl

# Создайте директорию для статических файлов
mkdir -p public
```

## Шаг 6: Запустите приложение

```bash
# Запустите все контейнеры
docker-compose -f docker-compose.prod.yaml up -d

# Проверьте логи
docker-compose -f docker-compose.prod.yaml logs -f

# Должны увидеть что certbot получает сертификаты
```

## Шаг 7: Проверьте сертификаты

```bash
# Проверьте что сертификаты установлены
docker exec aviapoint-certbot ls -la /etc/letsencrypt/live/avia-point.com/

# Должны видеть файлы:
# - fullchain.pem
# - privkey.pem
```

## Шаг 8: Протестируйте HTTPS

```bash
# Проверьте что сайт доступен
curl https://avia-point.com -I

# Проверьте редирект с HTTP на HTTPS
curl -I http://avia-point.com

# Проверьте сертификат
openssl s_client -connect avia-point.com:443
```

## Шаг 9: Автоматическое обновление сертификатов

Сертификаты Let's Encrypt действуют 90 дней. Настройте автоматическое обновление:

```bash
# На VPS, добавьте cron-задачу
crontab -e

# Добавьте эту строку (обновление в 2:00 AM первого числа каждого месяца):
0 2 1 * * cd /home/aviapoint/aviapoint_server && docker-compose -f docker-compose.prod.yaml exec -T certbot certbot renew --quiet

# Сохраните (Ctrl+X, Y, Enter в nano)
```

## Шаг 10: Мониторинг логов

```bash
# Посмотрите логи всех сервисов
docker-compose -f docker-compose.prod.yaml logs -f

# Или конкретного сервиса
docker-compose -f docker-compose.prod.yaml logs -f app
docker-compose -f docker-compose.prod.yaml logs -f certbot
docker-compose -f docker-compose.prod.yaml logs -f nginx
```

## Полезные команды

```bash
# Перезагрузить nginx (например, для обновления конфига)
docker exec aviapoint-nginx nginx -s reload

# Проверить здоровье сервисов
docker-compose -f docker-compose.prod.yaml ps

# Остановить все контейнеры
docker-compose -f docker-compose.prod.yaml down

# Пересобрать образы при изменении кода
docker-compose -f docker-compose.prod.yaml up -d --build

# Просмотр конфига nginx
docker exec aviapoint-nginx cat /etc/nginx/nginx.conf
```

## Troubleshooting

### ❌ "Connection refused" на 8080
- Убедитесь что `app` контейнер работает: `docker ps`
- Проверьте логи: `docker-compose -f docker-compose.prod.yaml logs app`

### ❌ "Certificate not yet valid" ошибка
- Проверьте дату на VPS: `date`
- Перезагрузитесь и перезапустите certbot

### ❌ Certbot не может получить сертификат
- Убедитесь что порты 80 и 443 открыты на хосте
- Проверьте DNS: `nslookup avia-point.com`
- Посмотрите логи certbot: `docker logs aviapoint-certbot`

### ❌ Nginx не стартует
- Проверьте синтаксис конфига: `docker exec aviapoint-nginx nginx -t`
- Посмотрите логи: `docker logs aviapoint-nginx`

## Бекап базы данных

```bash
# Создайте бекап
docker exec server-side-postgres-database pg_dump -U postgres aviapoint > backup.sql

# Восстановите из бекапа
cat backup.sql | docker exec -i server-side-postgres-database psql -U postgres
```

---

**Поздравляем! 🎉 Ваше приложение работает на avia-point.com с HTTPS сертификатом!**

