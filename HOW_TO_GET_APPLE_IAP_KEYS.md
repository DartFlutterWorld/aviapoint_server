# Как получить ключи для Apple In-App Purchases

## Шаг 1: Получение Key ID и Issuer ID

### Вариант 1: Через меню (если есть права)

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите: **Users and Access** → **Keys** → **App Store Connect API**

### Вариант 2: Прямая ссылка

1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите по прямой ссылке: https://appstoreconnect.apple.com/access/api

### Вариант 3: Если нет доступа к разделу

Если вы не видите раздел "Users and Access":
- **У вас нет прав администратора** - попросите администратора создать ключ
- **Или попросите предоставить роль Admin/Account Holder**
- Раздел "Users and Access" доступен только администраторам
3. Если ключа еще нет:
   - Нажмите **"+"** (Generate API Key)
   - Название: `AviaPoint IAP Key` (или любое другое)
   - Access: выберите **"In-App Purchases"**
   - Нажмите **"Generate"**
4. После создания сохраните:
   - **Key ID** (например: `ABC123DEF4`) → это `APPLE_IAP_KEY_ID`
   - **Issuer ID** (показан вверху страницы, например: `12345678-1234-1234-1234-123456789012`) → это `APPLE_IAP_ISSUER_ID`

⚠️ **Важно:** Key ID можно посмотреть позже, но Issuer ID лучше сохранить сразу.

## Шаг 2: Получение Private Key (.p8 файл)

1. После создания ключа нажмите **"Download API Key"**
2. Скачается файл с расширением `.p8` (например: `AuthKey_ABC123DEF4.p8`)
3. ⚠️ **КРИТИЧНО:** Скачайте файл сразу - его нельзя скачать повторно!
4. Откройте файл в текстовом редакторе
5. Скопируйте всё содержимое, включая строки:
   ```
   -----BEGIN PRIVATE KEY-----
   [содержимое ключа]
   -----END PRIVATE KEY-----
   ```

## Шаг 3: Настройка Private Key в переменной окружения

Есть два способа:

### Способ 1: Прямо в переменной окружения (для одной строки)

```bash
APPLE_IAP_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...\n-----END PRIVATE KEY-----"
```

⚠️ Используйте `\n` для переносов строк.

### Способ 2: Через файл (рекомендуется)

1. Сохраните `.p8` файл в безопасном месте на сервере (например: `/root/.ssh/apple_iap_key.p8`)
2. В переменной окружения укажите путь к файлу или загрузите содержимое:

```bash
# Читаем содержимое файла
APPLE_IAP_PRIVATE_KEY=$(cat /path/to/AuthKey_ABC123DEF4.p8)
```

Или в `.env` файле:
```bash
APPLE_IAP_PRIVATE_KEY="$(cat /root/.ssh/apple_iap_key.p8)"
```

## Шаг 4: Получение Bundle ID

1. В App Store Connect перейдите: **Ваше приложение** → **App Information**
2. Найдите поле **"Bundle ID"**
3. Обычно это: `com.aviapoint.app` или `com.aviapoint`
4. Это значение → `APPLE_BUNDLE_ID`

## Пример заполнения .env файла

```bash
# Apple In-App Purchase настройки
APPLE_IAP_KEY_ID=ABC123DEF4
APPLE_IAP_ISSUER_ID=12345678-1234-1234-1234-123456789012
APPLE_IAP_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
[остальное содержимое ключа]
...
-----END PRIVATE KEY-----"
APPLE_BUNDLE_ID=com.aviapoint.app
```

## Проверка настройки

После настройки переменных окружения:
1. Перезапустите сервер
2. Проверьте логи при запуске - не должно быть ошибок о нехватке Apple IAP credentials
3. Попробуйте сделать тестовую верификацию IAP (в Sandbox режиме)

## Безопасность

⚠️ **Важно:**
- Никогда не коммитьте `.p8` файл в git
- Храните ключи в безопасном месте
- Используйте переменные окружения, а не хардкод в коде
- Если ключ скомпрометирован - создайте новый и удалите старый

## Если потеряли .p8 файл

Если вы потеряли `.p8` файл:
1. Создайте новый ключ в App Store Connect
2. Удалите старый ключ (если нужно)
3. Используйте новый Key ID и новый .p8 файл
