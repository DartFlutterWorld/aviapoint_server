#!/bin/bash

# Скрипт для проверки состояния таблицы FCM токенов

echo "🔍 Проверка состояния таблицы FCM токенов..."

# Проверяем, какая таблица существует
psql -U postgres -d aviapoint -c "
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fcm_tokens') 
        THEN '✅ Таблица fcm_tokens существует'
        ELSE '❌ Таблица fcm_tokens НЕ существует'
    END as fcm_tokens_status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_fcm_tokens') 
        THEN '⚠️ Таблица user_fcm_tokens все еще существует (миграция не применена)'
        ELSE '✅ Таблица user_fcm_tokens не существует (миграция применена)'
    END as user_fcm_tokens_status;
"

echo ""
echo "📊 Проверка структуры таблицы fcm_tokens (если существует):"
psql -U postgres -d aviapoint -c "
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'fcm_tokens' 
ORDER BY ordinal_position;
" 2>/dev/null || echo "Таблица fcm_tokens не найдена"

echo ""
echo "🔑 Проверка индексов:"
psql -U postgres -d aviapoint -c "
SELECT 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE tablename IN ('fcm_tokens', 'user_fcm_tokens')
ORDER BY tablename, indexname;
" 2>/dev/null || echo "Индексы не найдены"

echo ""
echo "📈 Количество записей:"
psql -U postgres -d aviapoint -c "
SELECT 
    'fcm_tokens' as table_name,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE user_id IS NULL) as anonymous,
    COUNT(*) FILTER (WHERE user_id IS NOT NULL) as with_user_id
FROM fcm_tokens
UNION ALL
SELECT 
    'user_fcm_tokens' as table_name,
    COUNT(*) as total,
    0 as anonymous,
    COUNT(*) as with_user_id
FROM user_fcm_tokens;
" 2>/dev/null || echo "Не удалось получить статистику"
