# ⚡ Быстрый старт: SSL для avia-point.com

## За 5 минут на production! 🚀

### Шаг 1: На вашей машине

```bash
cd /Users/admin/Projects/aviapoint_server

# Проверьте конфиги
grep "avia-point.com" docker-compose.prod.yaml nginx.conf
# Должны быть результаты ✓

# Если все хорошо - коммитьте
git add docker-compose.prod.yaml nginx.conf env.example .gitignore
git add PRODUCTION_SETUP.md SSL_INSTALL_GUIDE.md DEPLOYMENT_CHECKLIST.md deploy.sh
git commit -m "🔐 Setup SSL/HTTPS for avia-point.com with Let's Encrypt"
git push
```

### Шаг 2: На VPS

```bash
# Подключитесь по SSH
ssh root@YOUR_VPS_IP

# Обновите код
cd /home/aviapoint/aviapoint_server
git pull

# Создайте переменные окружения
cp env.example .env
nano .env
# Замените:
# - POSTGRESQL_PASSWORD=<выберите сложный пароль>
# Сохраните (Ctrl+X, Y, Enter в nano)

# Создайте директории
mkdir -p ssl public pgdata

# Запустите скрипт
bash deploy.sh

# Скрипт автоматически:
# ✓ Проверит DNS
# ✓ Получит Let's Encrypt сертификаты
# ✓ Запустит все контейнеры
# ✓ Проверит что все работает
```

### Шаг 3: Проверьте что работает

```bash
# На VPS - дождитесь пока скрипт завершится

# После этого проверьте:
curl -I https://avia-point.com
# Должен вернуть 200 OK

# HTTP редирект?
curl -I http://avia-point.com
# Должен вернуть 301 редирект на HTTPS

# API работает?
curl https://avia-point.com/openapi -I
# Должен вернуть 200 OK
```

### Шаг 4: В браузере

Откройте https://avia-point.com в любом браузере.

Вы должны увидеть:
- 🔒 Зеленый замок рядом с URL
- ✓ "Secure" или "Safe"
- Без предупреждений

**Готово! HTTPS работает! 🎉**

---

## 🤔 Что если что-то не работает?

### DNS не разрешается

```bash
# На VPS проверьте
nslookup avia-point.com
# Должен вернуть IP VPS

# Если нет - обновите DNS записи у регистратора домена
# Может занять до 24 часов
```

### Сертификат не получен

```bash
# На VPS проверьте логи certbot
docker logs aviapoint-certbot

# Проверьте что порты открыты
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Контейнеры не запустились

```bash
# Проверьте логи
docker-compose -f docker-compose.prod.yaml logs

# Проверьте .env файл
cat .env

# Перезапустите
docker-compose -f docker-compose.prod.yaml down
docker-compose -f docker-compose.prod.yaml up -d
```

---

## 📚 Дополнительно

Если вам нужны более подробные инструкции:

- **Полный гайд**: [PRODUCTION_SETUP.md](./PRODUCTION_SETUP.md)
- **SSL детали**: [SSL_INSTALL_GUIDE.md](./SSL_INSTALL_GUIDE.md)
- **Чеклист**: [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
- **Архитектура**: [SETUP_SUMMARY.md](./SETUP_SUMMARY.md)

---

## 🎯 Далее

После успешного развертывания:

1. **Настройте мониторинг**: `docker logs -f aviapoint-nginx`
2. **Проверьте сертификат через месяц**: `openssl x509 -in ssl/live/avia-point.com/fullchain.pem -noout -enddate`
3. **Обновляйте код**: `git pull && docker-compose -f docker-compose.prod.yaml up -d --build`

---

**Вопросы? Смотрите документацию выше! 📖**

**Успеха! 🚀**

