# 🚀 AviaPoint Server - Развертывание

Полное руководство по развертыванию Dart/Flutter backend приложения на различные платформы хостинга.

## 📊 Выбран ваш проект:

```
✅ Dart HTTP Server (Shelf Framework)
✅ PostgreSQL Database
✅ OpenAPI/Swagger UI
✅ JWT Authentication
✅ Docker & Docker Compose
✅ Nginx Reverse Proxy
✅ Production Ready
```

---

## 🎯 Быстрый выбор хостинга

### **Для новичков** → Render.com (5 минут) ⭐
```bash
1. Скопируйте env.example в .env
2. Создайте PostgreSQL сервис на render.com
3. Создайте Web Service из GitHub репозитория
4. Установите переменные окружения
5. Deploy - и готово!
```
**Цена:** $7-25/мес | **Сложность:** ⭐ Easy

### **Для сбалансированного решения** → DigitalOcean App Platform
```bash
1. Создайте App Platform приложение
2. Подключите GitHub репозиторий
3. Установите конфигурацию
4. Автоматический deploy при push
```
**Цена:** $12-40/мес | **Сложность:** ⭐ Easy

### **Для полного контроля** → VPS + Docker (30 минут)
```bash
1. Создайте VPS (Linode $5, Vultr $5, Hetzner $3)
2. ./install.sh production
3. nano .env
4. ./start.sh production
```
**Цена:** $5-20/мес | **Сложность:** ⭐⭐⭐ Hard

---

## 📁 Файлы для развертывания

| Файл | Описание |
|------|---------|
| `Dockerfile` | Docker образ приложения |
| `docker-compose.prod.yaml` | Production Docker Compose |
| `nginx.conf` | Nginx конфиг (SSL, rate limiting) |
| `env.example` | Пример переменных окружения |
| `start.sh` | Скрипт запуска |
| `DEPLOYMENT.md` | **Подробный гайд** ⭐ ЧИТАЙТЕ ЗДЕСЬ |
| `HOSTING_GUIDE.md` | Сравнение платформ |
| `ARCHITECTURE.md` | Архитектура системы |
| `TROUBLESHOOTING.md` | Решение проблем |

---

## 🚀 Вариант 1: Render.com (САМЫЙ ПРОСТОЙ)

### Шаг 1: Подготовьте репозиторий
```bash
git add .
git commit -m "Add deployment files"
git push origin main
```

### Шаг 2: Создайте PostgreSQL
1. Перейдите на **render.com**
2. Нажмите "New +" → "PostgreSQL"
3. Заполните:
   - Name: `aviapoint-db`
   - Database: `aviapoint`
   - Region: Выберите ближайший

### Шаг 3: Создайте Web Service
1. Нажмите "New +" → "Web Service"
2. Подключите GitHub репозиторий
3. Заполните:
   - Name: `aviapoint-server`
   - Build Command: `dart pub get`
   - Start Command: `dart lib/main.dart`

### Шаг 4: Переменные окружения
Установите в Environment:
```
POSTGRESQL_HOST=[адрес из БД]
POSTGRESQL_USER=postgres
POSTGRESQL_PASSWORD=[из БД]
POSTGRESQL_DB=aviapoint
```

### Шаг 5: Deploy!
Нажмите "Create Web Service" ✅

**URL:** `https://aviapoint-server.onrender.com`

---

## 🏗️ Вариант 2: VPS + Docker

### Шаг 1: Создайте VPS
- Linode ($5/мес) - [linode.com](https://linode.com)
- Vultr ($5/мес) - [vultr.com](https://vultr.com)
- Hetzner ($3/мес) - [hetzner.com](https://hetzner.com)

Выберите: **Ubuntu 22.04 LTS**, **2GB RAM**, **50GB SSD**

### Шаг 2: SSH и установка
```bash
ssh root@YOUR_IP

# Установите Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установите Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### Шаг 3: Клонируйте проект
```bash
mkdir -p /app && cd /app
git clone https://github.com/yourusername/aviapoint_server.git
cd aviapoint_server
chmod +x start.sh
```

### Шаг 4: Настройте
```bash
cp env.example .env
nano .env  # Отредактируйте!
```

### Шаг 5: Получите SSL сертификат
```bash
apt install certbot -y
certbot certonly --standalone -d yourdomain.com

mkdir -p ssl
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
```

### Шаг 6: Запустите
```bash
./start.sh production

# Проверьте статус
docker-compose -f docker-compose.prod.yaml ps
```

### Шаг 7: Firewall
```bash
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

**Готово!** Откройте `https://yourdomain.com`

---

## 📊 Сравнение стоимости (в месяц)

### Minimal ($5-10)
```
VPS 2GB:              $5
= Total: $5/мес
```

### Recommended ($15-30)
```
Render Web:           $7
Render Database:      $8
= Total: $15/мес
```

### Enterprise ($100+)
```
AWS EC2 t3.medium:    $30
AWS RDS PostgreSQL:   $30
Bandwidth:            $20
= Total: $80+/мес
```

---

## ✅ Чек-лист перед deploy

- [ ] Код закоммичен в GitHub
- [ ] Все зависимости обновлены: `dart pub get`
- [ ] Нет синтаксических ошибок: `dart analyze`
- [ ] `.env` создан с правильными значениями
- [ ] SSL сертификат готов (если VPS)
- [ ] Домен указывает на хост
- [ ] Firewall настроен (если VPS)
- [ ] Backup стратегия продумана
- [ ] Логирование включено

---

## 🔧 После развертывания

### Проверьте здоровье
```bash
# Откройте в браузере
https://yourdomain.com/openapi/

# Проверьте API
curl https://yourdomain.com/api/profiles

# Просмотрите логи
docker-compose -f docker-compose.prod.yaml logs -f app
```

### Основные команды
```bash
# Просмотр статуса
docker-compose -f docker-compose.prod.yaml ps

# Логи
docker-compose -f docker-compose.prod.yaml logs -f

# Перезагрузка
docker-compose -f docker-compose.prod.yaml restart

# Остановка
docker-compose -f docker-compose.prod.yaml down

# Обновление
git pull origin main
docker-compose -f docker-compose.prod.yaml up -d --build
```

---

## 🆘 Частые проблемы

| Проблема | Решение |
|----------|---------|
| Приложение не стартует | `docker logs` - проверьте ошибки |
| БД недоступна | Проверьте переменные в `.env` |
| 502 Bad Gateway | Перезагрузите Nginx: `docker restart nginx` |
| SSL ошибка | Проверьте сертификат: `certbot renew` |
| Медленно | Включите Gzip в nginx.conf (уже включен) |

📖 **Подробнее:** смотрите `TROUBLESHOOTING.md`

---

## 📚 Документация

- **DEPLOYMENT.md** - Полный гайд развертывания (30+ страниц)
- **HOSTING_GUIDE.md** - Быстрый путеводитель по платформам
- **ARCHITECTURE.md** - Архитектура и схемы
- **TROUBLESHOOTING.md** - Решение 10 частых проблем

---

## 🎓 Обучение

### Основы Docker
```bash
docker --help                    # Помощь
docker ps                        # Текущие контейнеры
docker logs CONTAINER_ID         # Логи
docker exec CONTAINER_ID bash    # Вход в контейнер
```

### Docker Compose
```bash
docker-compose up -d             # Запуск
docker-compose down              # Остановка
docker-compose logs -f           # Логи
docker-compose restart           # Перезагрузка
```

### Nginx
```bash
nginx -t                         # Проверить конфиг
systemctl restart nginx          # Перезагрузить
```

---

## 💡 Pro Tips

### 1. Используйте Cloudflare (бесплатно)
- Улучшит производительность CDN
- Добавит DDoS защиту
- Даст бесплатный SSL (если нужен)

### 2. Регулярный backup
```bash
# Daily backup (добавьте в crontab)
0 2 * * * docker exec aviapoint-postgres pg_dump -U postgres aviapoint > /backups/db_$(date +\%Y\%m\%d).sql
```

### 3. Мониторинг (бесплатные)
- **UptimeRobot** - проверяет доступность
- **Sentry** - ошибки в коде
- **Cloudflare** - аналитика

### 4. Обновления
- Регулярно: `dart pub upgrade`
- Проверяйте: GitHub Dependabot
- Изучайте: security advisories

---

## 🚢 Continuous Deployment

Создан GitHub Actions workflow (`.github/workflows/deploy.yml`):
1. Запускает тесты
2. Собирает Docker образ
3. Пушит в registry
4. Деплойит на сервер (если настроено)

Настройте GitHub Secrets для автоматического деплоя.

---

## 📞 Нужна помощь?

1. **Читайте документацию** в этом проекте
2. **Проверьте логи:** `docker-compose logs`
3. **Найдите решение:** `TROUBLESHOOTING.md`
4. **Откройте issue** на GitHub с логами

---

## 🎉 Успешное развертывание!

После успешного развертывания:

```
✅ API доступен на https://yourdomain.com
✅ Swagger UI на https://yourdomain.com/openapi/
✅ PostgreSQL работает и синхронизирует данные
✅ SSL сертификат активен
✅ Логирование включено
✅ Регулярные бэкапы настроены
```

**Поздравляем с развертыванием!** 🎊

---

**Версия:** 1.0  
**Последнее обновление:** January 2024  
**Автор:** DevOps Documentation
