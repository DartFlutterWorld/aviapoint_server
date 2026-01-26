# Отчет о сравнении структуры БД: локальная vs удаленная

**Дата:** $(date)  
**Локальная БД:** 127.0.0.1:5432  
**Удаленная БД:** 83.166.246.205 (aviapoint-postgres)

## Резюме

На основе анализа миграций и структуры проекта:

### Статистика таблиц

- **Таблиц в локальной БД:** ~52 таблицы
- **Таблиц в удаленной БД:** ~12 таблиц (по данным предыдущих проверок)
- **Общих таблиц:** Минимальное количество (большинство таблиц отсутствует на сервере)

## Основные различия

### Таблицы, которые есть только в локальной БД (необходимо создать на сервере):

1. **aircraft_main_categories** - Основные категории самолетов
2. **aircraft_subcategories** - Подкатегории самолетов
3. **aircraft_manufacturers** - Производители самолетов
4. **aircraft_models** - Модели самолетов
5. **aircraft_model_specs** - Характеристики моделей
6. **aircraft_market** - Рынок самолетов (переименована из market_products)
7. **aircraft_market_price_history** - История цен на самолеты
8. **user_favorite_aircraft_market** - Избранные самолеты пользователей
9. **airports** - Аэропорты
10. **airport_reviews** - Отзывы об аэропортах
11. **airport_feedback** - Обратная связь по аэропортам
12. **airport_ownership_requests** - Запросы на владение аэропортами
13. **airport_visitor_photos** - Фото посетителей аэропортов
14. **flights** - Полеты
15. **flight_waypoints** - Точки маршрута полетов
16. **flight_photos** - Фото полетов
17. **flight_questions** - Вопросы по полетам
18. **bookings** - Бронирования
19. **reviews** - Отзывы
20. **blog_articles** - Статьи блога
21. **blog_categories** - Категории блога
22. **blog_tags** - Теги блога
23. **blog_article_tags** - Связь статей и тегов
24. **blog_comments** - Комментарии к статьям
25. **news** - Новости
26. **news_images** - Изображения новостей
27. **category_news** - Категории новостей
28. **profiles** - Профили пользователей
29. **payments** - Платежи
30. **subscriptions** - Подписки
31. **subscription_types** - Типы подписок
32. **app_settings** - Настройки приложения
33. **publication_settings** - Настройки публикации
34. **fcm_tokens** (user_fcm_tokens) - FCM токены пользователей
35. **schema_migrations** - История миграций
36. **feedback** - Обратная связь
37. **stories** - Истории
38. **video** - Видео
39. И другие таблицы...

### Критические миграции, которые нужно применить на сервере:

1. **069_add_published_to_news** - Добавление полей `published` и `author_id` в таблицу `news`
2. **070_add_sequence_to_news_id** - Создание sequence для `news.id`
3. **071_add_content_and_images_to_news** - Добавление поля `content` и таблицы `news_images`
4. **055_rename_market_products_to_aircraft_market** - Переименование таблиц market
5. **062_add_aircraft_market_publish_until** - Добавление поля `published_until`
6. **063_create_publication_settings_table** - Создание таблицы настроек публикации
7. **064_create_user_fcm_tokens_table** - Создание таблицы FCM токенов
8. **065_add_is_admin_to_profiles** - Добавление поля `is_admin` в `profiles`

## Рекомендации

1. **Применить все миграции на сервере** - Использовать скрипт `sync_schema_only_to_prod.sh` для синхронизации структуры
2. **Проверить наличие PRIMARY KEY** - Убедиться, что все таблицы имеют PRIMARY KEY (особенно `news`)
3. **Проверить внешние ключи** - Убедиться, что все внешние ключи созданы корректно
4. **Создать резервную копию** - Перед применением миграций создать бэкап БД

## Следующие шаги

1. Запустить `./backup_prod_database.sh` для создания бэкапа
2. Запустить `./sync_schema_only_to_prod.sh` для синхронизации структуры
3. Проверить результат с помощью `./check_tables_on_server.sh`
