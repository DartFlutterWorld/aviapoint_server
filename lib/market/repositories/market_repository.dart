import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/market/data/model/market_category_model.dart';
import 'package:aviapoint_server/market/data/model/aircraft_market_model.dart';
import 'package:aviapoint_server/market/data/model/parts_market_model.dart';
import 'package:aviapoint_server/market/data/model/price_history_model.dart';
import 'package:aviapoint_server/push_notifications/fcm_service.dart';
import 'package:postgres/postgres.dart';

class MarketRepository {
  final Connection _connection;

  MarketRepository({required Connection connection}) : _connection = connection;

  /// Получить период публикации для таблицы (в месяцах)
  /// Если настройка не найдена, возвращает значение по умолчанию (1 месяц)
  Future<int> _getPublicationDurationMonths(String tableName) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
          SELECT publication_duration_months 
          FROM publication_settings 
          WHERE table_name = @table_name
        '''),
        parameters: {'table_name': tableName},
      );

      if (result.isEmpty) {
        // Если настройка не найдена, возвращаем дефолтное значение 1 месяц
        return 1;
      }

      return result.first[0] as int;
    } catch (e) {
      // В случае ошибки возвращаем дефолтное значение
      return 1;
    }
  }

  /// Получить основные категории по типу продукта
  Future<List<MarketCategoryModel>> getMainCategories(String productType) async {
    if (productType == 'aircraft') {
      return _getAircraftSubcategories();
    }
    // Для запчастей пока категорий нет
    return [];
  }

  /// Получить категории из таблицы aircraft_subcategories
  Future<List<MarketCategoryModel>> _getAircraftSubcategories() async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          name,
          name_en,
          icon as icon_url,
          'aircraft' as product_type,
          NULL as parent_id,
          0 as display_order,
          true as is_main
        FROM aircraft_subcategories
        WHERE main_categories_id = 1
        ORDER BY name ASC
      '''),
    );

    return result.map((row) => MarketCategoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить все категории по типу продукта
  Future<List<MarketCategoryModel>> getAllCategories(String productType) async {
    if (productType == 'aircraft') {
      return _getAircraftSubcategories();
    }
    if (productType == 'parts') {
      return getPartsMainCategories();
    }
    return [];
  }

  /// Получить основные категории запчастей (типы техники)
  Future<List<MarketCategoryModel>> getPartsMainCategories() async {
    final result = await _connection.execute(
      Sql('''
        SELECT 
          id,
          name,
          name_en,
          NULL as icon_url,
          'parts' as product_type,
          NULL as parent_id,
          0 as display_order,
          true as is_main
        FROM parts_main_categories
        ORDER BY name ASC
      '''),
    );

    return result.map((row) => MarketCategoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить подкатегории запчастей по основной категории
  Future<List<MarketCategoryModel>> getPartsSubcategoriesByMainCategory(int mainCategoryId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          name,
          name_en,
          icon as icon_url,
          'parts' as product_type,
          parent_id,
          main_categories_id as parts_main_category_id,
          display_order,
          false as is_main
        FROM parts_subcategories
        WHERE main_categories_id = @main_category_id
          AND parent_id IS NULL
        ORDER BY display_order ASC, name ASC
      '''),
      parameters: {'main_category_id': mainCategoryId},
    );

    return result.map((row) => MarketCategoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить подкатегории запчастей по родительской категории
  Future<List<MarketCategoryModel>> getPartsSubcategoriesByParent(int parentId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          name,
          name_en,
          icon as icon_url,
          'parts' as product_type,
          parent_id,
          main_categories_id as parts_main_category_id,
          display_order,
          false as is_main
        FROM parts_subcategories
        WHERE parent_id = @parent_id
        ORDER BY display_order ASC, name ASC
      '''),
      parameters: {'parent_id': parentId},
    );

    return result.map((row) => MarketCategoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить категорию по ID
  Future<MarketCategoryModel?> getCategoryById(int id) async {
    // Ищем только в aircraft_subcategories
    return _getAircraftSubcategoryById(id);
  }

  /// Получить категорию из таблицы aircraft_subcategories по ID
  Future<MarketCategoryModel?> _getAircraftSubcategoryById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT 
          id,
          name,
          name_en,
          icon as icon_url,
          'aircraft' as product_type,
          NULL as parent_id,
          0 as display_order,
          true as is_main
        FROM aircraft_subcategories
        WHERE id = @id AND main_categories_id = 1
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return MarketCategoryModel.fromJson(result.first.toColumnMap());
  }

  Future<void> _deactivateExpired() async {
    // Сначала получаем список объявлений самолётов, которые будут сняты с публикации
    // вместе с информацией о владельце и FCM токеном
    final expiredAircraftListings = await _connection.execute(
      Sql.named('''
        SELECT 
          am.id,
          am.title,
          am.seller_id,
          (SELECT fcm_token FROM fcm_tokens WHERE user_id = am.seller_id ORDER BY updated_at DESC LIMIT 1) as fcm_token
        FROM aircraft_market am
        LEFT JOIN profiles p ON am.seller_id = p.id
        WHERE am.is_published = true
          AND am.published_until IS NOT NULL
          AND am.published_until < NOW()
      '''),
    );

    // Отправляем push-уведомления владельцам самолётов перед снятием с публикации
    if (expiredAircraftListings.isNotEmpty) {
      final fcmService = FcmService();

      for (final row in expiredAircraftListings) {
        final map = row.toColumnMap();
        final listingId = map['id'] as int;
        final title = map['title'] as String? ?? 'Объявление';
        final fcmToken = map['fcm_token'] as String?;

        // Отправляем push-уведомление, если есть FCM токен
        if (fcmToken != null && fcmToken.isNotEmpty) {
          try {
            final notificationSent = await fcmService.notifyOwnerAboutUnpublishedListing(
              fcmToken: fcmToken,
              listingTitle: title,
              listingId: listingId,
            );

            if (notificationSent) {
              print('✅ [MarketRepository] Push-уведомление о снятии с публикации отправлено владельцу объявления #$listingId');
            } else {
              print('⚠️ [MarketRepository] Не удалось отправить push-уведомление о снятии с публикации для объявления #$listingId');
            }
          } catch (e) {
            print('⚠️ [MarketRepository] Ошибка отправки push-уведомления о снятии с публикации для объявления #$listingId: $e');
            // Продолжаем обработку других объявлений даже при ошибке
          }
        } else {
          print('⚠️ [MarketRepository] FCM токен владельца не найден для объявления #$listingId, уведомление не отправлено');
        }
      }
    }

    // Получаем список объявлений запчастей, которые будут сняты с публикации
    final expiredPartsListings = await _connection.execute(
      Sql.named('''
        SELECT 
          pm.id,
          pm.title,
          pm.seller_id,
          (SELECT fcm_token FROM fcm_tokens WHERE user_id = pm.seller_id ORDER BY updated_at DESC LIMIT 1) as fcm_token
        FROM parts_market pm
        LEFT JOIN profiles p ON pm.seller_id = p.id
        WHERE pm.is_published = true
          AND pm.published_until IS NOT NULL
          AND pm.published_until < NOW()
      '''),
    );

    // Отправляем push-уведомления владельцам запчастей перед снятием с публикации
    if (expiredPartsListings.isNotEmpty) {
      final fcmService = FcmService();

      for (final row in expiredPartsListings) {
        final map = row.toColumnMap();
        final listingId = map['id'] as int;
        final title = map['title'] as String? ?? 'Объявление';
        final fcmToken = map['fcm_token'] as String?;

        // Отправляем push-уведомление, если есть FCM токен
        if (fcmToken != null && fcmToken.isNotEmpty) {
          try {
            final notificationSent = await fcmService.notifyOwnerAboutUnpublishedListing(
              fcmToken: fcmToken,
              listingTitle: title,
              listingId: listingId,
            );

            if (notificationSent) {
              print('✅ [MarketRepository] Push-уведомление о снятии с публикации отправлено владельцу объявления #$listingId');
            } else {
              print('⚠️ [MarketRepository] Не удалось отправить push-уведомление о снятии с публикации для объявления #$listingId');
            }
          } catch (e) {
            print('⚠️ [MarketRepository] Ошибка отправки push-уведомления о снятии с публикации для объявления #$listingId: $e');
            // Продолжаем обработку других объявлений даже при ошибке
          }
        } else {
          print('⚠️ [MarketRepository] FCM токен владельца не найден для объявления #$listingId, уведомление не отправлено');
        }
      }
    }

    // Теперь снимаем объявления с публикации (меняем is_published, не трогаем is_active)
    await _connection.execute(
      Sql('''
        UPDATE aircraft_market
        SET is_published = false
        WHERE is_published = true
          AND published_until IS NOT NULL
          AND published_until < NOW()
      '''),
    );

    // Снимаем запчасти с публикации
    await _connection.execute(
      Sql('''
        UPDATE parts_market
        SET is_published = false
        WHERE is_published = true
          AND published_until IS NOT NULL
          AND published_until < NOW()
      '''),
    );
  }

  /// Получить самолёты с фильтрами
  Future<List<AircraftMarketModel>> getAircraft({
    required String productType,
    int? categoryId,
    int? sellerId,
    String? searchQuery,
    List<int>? categoryIds,
    int? priceFrom,
    int? priceTo,
    String? brand,
    String? sortBy,
    int? userId,
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  }) async {
    await _deactivateExpired();

    String query = '''
      SELECT 
        mp.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        ${userId != null ? 'EXISTS(SELECT 1 FROM user_favorite_aircraft_market WHERE user_id = @user_id AND product_id = mp.id) as is_favorite' : 'FALSE as is_favorite'}
      FROM aircraft_market mp
      LEFT JOIN profiles p ON mp.seller_id = p.id
      WHERE 1 = 1
    ''';

    final parameters = <String, dynamic>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }

    // Фильтр по категории (aircraft_subcategories_id)
    if (categoryId != null) {
      query += ' AND mp.aircraft_subcategories_id = @category_id';
      parameters['category_id'] = categoryId;
    }

    // Фильтр по нескольким категориям
    if (categoryIds != null && categoryIds.isNotEmpty) {
      query += ' AND mp.aircraft_subcategories_id = ANY(@category_ids)';
      parameters['category_ids'] = categoryIds;
    }

    // Фильтр по продавцу
    if (sellerId != null) {
      query += ' AND mp.seller_id = @seller_id';
      parameters['seller_id'] = sellerId;
    }

    // Поиск по названию
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND mp.title ILIKE @search_query';
      parameters['search_query'] = '%$searchQuery%';
    }

    if (!includeInactive) {
      query += ' AND mp.is_published = true AND mp.is_active = true AND (mp.published_until IS NULL OR mp.published_until >= NOW())';
    }

    // Фильтр по цене от
    if (priceFrom != null) {
      query += ' AND mp.price >= @price_from';
      parameters['price_from'] = priceFrom;
    }

    // Фильтр по цене до
    if (priceTo != null) {
      query += ' AND mp.price <= @price_to';
      parameters['price_to'] = priceTo;
    }

    // Фильтр по бренду
    if (brand != null && brand.isNotEmpty) {
      query += ' AND mp.brand ILIKE @brand';
      parameters['brand'] = '%$brand%';
    }

    // Сортировка
    switch (sortBy) {
      case 'price_asc':
        query += ' ORDER BY mp.price ASC';
        break;
      case 'price_desc':
        query += ' ORDER BY mp.price DESC';
        break;
      case 'date':
        query += ' ORDER BY mp.created_at DESC';
        break;
      default:
        query += ' ORDER BY mp.created_at DESC';
    }

    // Пагинация
    query += ' LIMIT @limit OFFSET @offset';
    parameters['limit'] = limit;
    parameters['offset'] = offset;

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    return result.map((row) => AircraftMarketModel.fromJson(row.toColumnMap())).toList();
  }

  /// Получить самолёт по ID
  Future<AircraftMarketModel?> getAircraftById(int id, {int? userId}) async {
    await _deactivateExpired();

    String query = '''
      SELECT 
        mp.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        ${userId != null ? 'EXISTS(SELECT 1 FROM user_favorite_aircraft_market WHERE user_id = @user_id AND product_id = mp.id) as is_favorite' : 'FALSE as is_favorite'}
      FROM aircraft_market mp
      LEFT JOIN profiles p ON mp.seller_id = p.id
      WHERE mp.id = @id
        AND (
          (mp.is_active = true AND (mp.published_until IS NULL OR mp.published_until >= NOW()))
          ${userId != null ? ' OR mp.seller_id = @user_id' : ''}
        )
    ''';

    final parameters = <String, dynamic>{'id': id};
    if (userId != null) {
      parameters['user_id'] = userId;
    }

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    if (result.isEmpty) return null;
    return AircraftMarketModel.fromJson(result.first.toColumnMap());
  }

  /// Увеличить счетчик просмотров
  Future<void> incrementViews(int productId) async {
    await _connection.execute(Sql.named('UPDATE aircraft_market SET views_count = views_count + 1 WHERE id = @id'), parameters: {'id': productId});
  }

  /// Добавить в избранное
  Future<void> addToFavorites(int userId, int productId) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO user_favorite_aircraft_market (user_id, product_id)
        VALUES (@user_id, @product_id)
        ON CONFLICT (user_id, product_id) DO NOTHING
      '''),
      parameters: {'user_id': userId, 'product_id': productId},
    );
  }

  /// Удалить из избранного
  Future<void> removeFromFavorites(int userId, int productId) async {
    await _connection.execute(Sql.named('DELETE FROM user_favorite_aircraft_market WHERE user_id = @user_id AND product_id = @product_id'), parameters: {'user_id': userId, 'product_id': productId});
  }

  /// Получить избранные самолёты пользователя
  Future<List<AircraftMarketModel>> getFavoriteAircraft(int userId, {String? productType, int limit = 20, int offset = 0}) async {
    await _deactivateExpired();

    String query = '''
      SELECT 
        mp.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        TRUE as is_favorite
      FROM aircraft_market mp
      INNER JOIN user_favorite_aircraft_market ufp ON mp.id = ufp.product_id
      LEFT JOIN profiles p ON mp.seller_id = p.id
      WHERE ufp.user_id = @user_id
        AND mp.is_active = true
        AND (mp.published_until IS NULL OR mp.published_until >= NOW())
      ORDER BY ufp.created_at DESC
      LIMIT @limit OFFSET @offset
    ''';

    final result = await _connection.execute(Sql.named(query), parameters: {'user_id': userId, 'limit': limit, 'offset': offset});
    return result.map((row) => AircraftMarketModel.fromJson(row.toColumnMap())).toList();
  }

  /// Создать новое объявление о самолёте
  Future<AircraftMarketModel> createAircraft({
    required int sellerId,
    required String title,
    String? description,
    required int price,
    String currency = 'RUB',
    int? aircraftSubcategoriesId,
    String? mainImageUrl,
    List<String> additionalImageUrls = const [],
    String? brand,
    String? location,
    int? year,
    int? totalFlightHours,
    int? enginePower,
    int? engineVolume,
    int? seats,
    String? condition,
    bool? isShareSale,
    int? shareNumerator,
    int? shareDenominator,
    bool? isLeasing,
    String? leasingConditions,
    bool isPublished = true,
  }) async {
    // Получаем период публикации из БД
    final durationMonths = await _getPublicationDurationMonths('aircraft_market');

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO aircraft_market (
          seller_id, title, description, price, currency, aircraft_subcategories_id,
          main_image_url, additional_image_urls, brand, location,
          year, total_flight_hours, engine_power, engine_volume, seats, condition, 
          is_share_sale, share_numerator, share_denominator,
          is_leasing, leasing_conditions,
          is_published, published_until, is_active, views_count
        )
        VALUES (
          @seller_id, @title, @description, @price, @currency, @aircraft_subcategories_id,
          @main_image_url, @additional_image_urls::jsonb, @brand, @location,
          @year, @total_flight_hours, @engine_power, @engine_volume, @seats, @condition,
          @is_share_sale, @share_numerator, @share_denominator,
          @is_leasing, @leasing_conditions,
          @is_published, @published_until, true, 0
        )
        RETURNING *
      '''),
      parameters: {
        'seller_id': sellerId,
        'title': title,
        'description': description,
        'price': price,
        'currency': currency,
        'aircraft_subcategories_id': aircraftSubcategoriesId,
        'main_image_url': mainImageUrl,
        'additional_image_urls': jsonEncode(additionalImageUrls),
        'brand': brand,
        'location': location,
        'year': year,
        'total_flight_hours': totalFlightHours,
        'engine_power': enginePower,
        'engine_volume': engineVolume,
        'seats': seats,
        'condition': condition,
        'is_share_sale': isShareSale ?? false,
        'share_numerator': shareNumerator,
        'share_denominator': shareDenominator,
        'is_leasing': isLeasing ?? false,
        'leasing_conditions': leasingConditions,
        'is_published': isPublished,
        'published_until': isPublished ? DateTime.now().add(Duration(days: durationMonths * 30)) : null,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create product');
    }

    final product = AircraftMarketModel.fromJson(result.first.toColumnMap());

    // Сохраняем первую запись в истории цен
    await _addPriceHistory(product.id, price);

    return product;
  }

  /// Добавить запись в историю цен
  Future<void> _addPriceHistory(int aircraftMarketId, int price) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO aircraft_market_price_history (aircraft_market_id, price, created_at)
        VALUES (@aircraft_market_id, @price, NOW())
      '''),
      parameters: {
        'aircraft_market_id': aircraftMarketId,
        'price': price,
      },
    );
  }

  /// Получить историю цен для объявления о самолёте
  Future<List<PriceHistoryModel>> getPriceHistory(int aircraftMarketId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, aircraft_market_id, price, created_at
        FROM aircraft_market_price_history
        WHERE aircraft_market_id = @aircraft_market_id
        ORDER BY created_at DESC
      '''),
      parameters: {'aircraft_market_id': aircraftMarketId},
    );

    return result.map((row) => PriceHistoryModel.fromJson(row.toColumnMap())).toList();
  }

  /// Добавить запись в историю цен запчасти
  Future<void> _addPartPriceHistory(int partId, int price) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO parts_market_price_history (part_id, price, created_at)
        VALUES (@part_id, @price, NOW())
      '''),
      parameters: {
        'part_id': partId,
        'price': price,
      },
    );
  }

  /// Получить историю цен для объявления о запчасти
  Future<List<PriceHistoryModel>> getPartPriceHistory(int partId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT id, part_id, price, created_at
        FROM parts_market_price_history
        WHERE part_id = @part_id
        ORDER BY created_at DESC
      '''),
      parameters: {'part_id': partId},
    );

    // Преобразуем результат в формат PriceHistoryModel
    // Используем part_id как aircraft_market_id для совместимости с моделью
    return result.map((row) {
      final map = row.toColumnMap();
      return PriceHistoryModel.fromJson({
        'id': map['id'],
        'aircraft_market_id': map['part_id'], // Используем part_id для совместимости
        'price': map['price'],
        'created_at': map['created_at'],
      });
    }).toList();
  }

  /// Обновить объявление о самолёте
  Future<AircraftMarketModel?> updateAircraft({
    required int productId,
    required int sellerId, // Для проверки прав
    String? title,
    String? description,
    int? price,
    String? currency,
    int? aircraftSubcategoriesId,
    String? mainImageUrl,
    List<String>? additionalImageUrls,
    String? brand,
    String? location,
    int? year,
    int? totalFlightHours,
    int? enginePower,
    int? engineVolume,
    int? seats,
    String? condition,
    bool? isShareSale,
    int? shareNumerator,
    int? shareDenominator,
    bool? isLeasing,
    String? leasingConditions,
  }) async {
    // Сначала проверяем права доступа и получаем старые данные товара
    final existingProduct = await _connection.execute(Sql.named('SELECT seller_id, price, main_image_url, additional_image_urls FROM aircraft_market WHERE id = @id'), parameters: {'id': productId});

    if (existingProduct.isEmpty) {
      return null; // Товар не найден
    }

    final existingProductMap = existingProduct.first.toColumnMap();
    final productSellerId = existingProductMap['seller_id'] as int;

    // Проверяем права: владелец или администратор
    final isOwner = productSellerId == sellerId;
    if (!isOwner) {
      // Проверяем, является ли пользователь администратором
      final adminCheck = await _connection.execute(
        Sql.named('SELECT is_admin FROM profiles WHERE id = @id'),
        parameters: {'id': sellerId},
      );
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You do not have permission to update this product');
      }
    }

    // Сохраняем старую цену для истории
    final oldPrice = existingProductMap['price'] as int;

    // Сохраняем старые URL изображений для удаления неиспользуемых файлов
    final oldMainImageUrl = existingProductMap['main_image_url'] as String?;
    final oldAdditionalImageUrls = <String>[];

    final oldAdditionalUrls = existingProductMap['additional_image_urls'];
    if (oldAdditionalUrls != null) {
      if (oldAdditionalUrls is List) {
        oldAdditionalImageUrls.addAll(oldAdditionalUrls.map((e) => e.toString()).where((e) => e.isNotEmpty));
      } else if (oldAdditionalUrls is String) {
        try {
          final decoded = jsonDecode(oldAdditionalUrls) as List;
          oldAdditionalImageUrls.addAll(decoded.map((e) => e.toString()).where((e) => e.isNotEmpty));
        } catch (e) {
          // Игнорируем ошибки парсинга
        }
      }
    }

    // Строим динамический UPDATE запрос
    final updates = <String>[];
    final parameters = <String, dynamic>{'id': productId};

    if (title != null) {
      updates.add('title = @title');
      parameters['title'] = title;
    }
    if (description != null) {
      updates.add('description = @description');
      parameters['description'] = description;
    }
    if (price != null) {
      updates.add('price = @price');
      parameters['price'] = price;
    }
    if (currency != null) {
      updates.add('currency = @currency');
      parameters['currency'] = currency;
    }
    if (aircraftSubcategoriesId != null) {
      updates.add('aircraft_subcategories_id = @aircraft_subcategories_id');
      parameters['aircraft_subcategories_id'] = aircraftSubcategoriesId;
    }
    // Обрабатываем основное изображение
    // Если mainImageUrl == null, не меняем
    // Если mainImageUrl == "", удаляем (устанавливаем NULL)
    // Если mainImageUrl != null && != "", обновляем
    if (mainImageUrl != null) {
      if (mainImageUrl.isEmpty) {
        // Удаляем основное изображение
        updates.add('main_image_url = NULL');
      } else {
        // Обновляем основное изображение
        updates.add('main_image_url = @main_image_url');
        parameters['main_image_url'] = mainImageUrl;
      }
    }
    // Обрабатываем дополнительные изображения
    // Если additionalImageUrls == null, не меняем
    // Если additionalImageUrls == [], удаляем все (устанавливаем пустой массив)
    // Если additionalImageUrls != null && != [], обновляем
    if (additionalImageUrls != null) {
      updates.add('additional_image_urls = @additional_image_urls::jsonb');
      parameters['additional_image_urls'] = jsonEncode(additionalImageUrls);
    }
    if (brand != null) {
      updates.add('brand = @brand');
      parameters['brand'] = brand;
    }
    if (location != null) {
      updates.add('location = @location');
      parameters['location'] = location;
    }
    if (year != null) {
      updates.add('year = @year');
      parameters['year'] = year;
    }
    if (totalFlightHours != null) {
      updates.add('total_flight_hours = @total_flight_hours');
      parameters['total_flight_hours'] = totalFlightHours;
    }
    if (enginePower != null) {
      updates.add('engine_power = @engine_power');
      parameters['engine_power'] = enginePower;
    }
    if (engineVolume != null) {
      updates.add('engine_volume = @engine_volume');
      parameters['engine_volume'] = engineVolume;
    }
    if (seats != null) {
      updates.add('seats = @seats');
      parameters['seats'] = seats;
    }
    if (condition != null) {
      updates.add('condition = @condition');
      parameters['condition'] = condition;
    }
    if (isShareSale != null) {
      updates.add('is_share_sale = @is_share_sale');
      parameters['is_share_sale'] = isShareSale;
    }
    if (shareNumerator != null) {
      updates.add('share_numerator = @share_numerator');
      parameters['share_numerator'] = shareNumerator;
    }
    if (shareDenominator != null) {
      updates.add('share_denominator = @share_denominator');
      parameters['share_denominator'] = shareDenominator;
    }
    if (isLeasing != null) {
      updates.add('is_leasing = @is_leasing');
      parameters['is_leasing'] = isLeasing;
    }
    if (leasingConditions != null) {
      updates.add('leasing_conditions = @leasing_conditions');
      parameters['leasing_conditions'] = leasingConditions;
    }

    if (updates.isEmpty) {
      // Нет изменений, возвращаем текущий товар
      return await getAircraftById(productId);
    }

    updates.add('updated_at = NOW()');

    final query = '''
      UPDATE aircraft_market
      SET ${updates.join(', ')}
      WHERE id = @id
      RETURNING *
    ''';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);

    if (result.isEmpty) {
      return null;
    }

    final updatedProduct = AircraftMarketModel.fromJson(result.first.toColumnMap());

    // Если цена изменилась, сохраняем в историю
    if (price != null && price != oldPrice) {
      await _addPriceHistory(productId, price);
    }

    // Определяем, какие файлы нужно удалить (старые, которых нет в новых)
    final filesToDelete = <String>[];

    // Проверяем основное изображение
    // Если mainImageUrl передан (не null), значит нужно обновить или удалить
    if (mainImageUrl != null) {
      if (mainImageUrl.isEmpty) {
        // Основное изображение удалено явно
        if (oldMainImageUrl != null && oldMainImageUrl.isNotEmpty) {
          filesToDelete.add(oldMainImageUrl);
        }
      } else {
        // Основное изображение заменено - удаляем старое, если оно отличается
        if (oldMainImageUrl != null && oldMainImageUrl.isNotEmpty && oldMainImageUrl != mainImageUrl) {
          filesToDelete.add(oldMainImageUrl);
        }
      }
    }

    // Проверяем дополнительные изображения
    // Если additionalImageUrls передан (не null), значит нужно обновить или удалить
    if (additionalImageUrls != null) {
      if (additionalImageUrls.isEmpty) {
        // Все дополнительные изображения удалены
        filesToDelete.addAll(oldAdditionalImageUrls);
      } else {
        // Находим изображения, которые были удалены (есть в старом списке, но нет в новом)
        for (final oldUrl in oldAdditionalImageUrls) {
          if (!additionalImageUrls.contains(oldUrl)) {
            filesToDelete.add(oldUrl);
          }
        }
      }
    }

    // Удаляем неиспользуемые файлы (асинхронно, не блокируя ответ)
    if (filesToDelete.isNotEmpty) {
      _deleteProductFiles(productId, filesToDelete).catchError((e) {
        print('⚠️ Error deleting unused product files: $e');
      });
    }

    return updatedProduct;
  }

  Future<AircraftMarketModel?> publishAircraft({
    required int productId,
    required int sellerId,
  }) async {
    final existingProduct = await _connection.execute(
      Sql.named('SELECT seller_id FROM aircraft_market WHERE id = @id'),
      parameters: {'id': productId},
    );

    if (existingProduct.isEmpty) {
      return null;
    }

    final existingProductMap = existingProduct.first.toColumnMap();
    final productSellerId = existingProductMap['seller_id'] as int;

    // Проверяем права: владелец или администратор
    final isOwner = productSellerId == sellerId;
    if (!isOwner) {
      // Проверяем, является ли пользователь администратором
      final adminCheck = await _connection.execute(
        Sql.named('SELECT is_admin FROM profiles WHERE id = @id'),
        parameters: {'id': sellerId},
      );
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You do not have permission to publish this product');
      }
    }

    // Получаем период публикации из БД
    final durationMonths = await _getPublicationDurationMonths('aircraft_market');

    // Пользователь управляет только is_published, не трогаем is_active (его контролирует только админ)
    final result = await _connection.execute(
      Sql.named('''
        UPDATE aircraft_market
        SET is_published = true,
            published_until = NOW() + MAKE_INTERVAL(months => @duration),
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': productId,
        'duration': durationMonths,
      },
    );

    if (result.isEmpty) return null;
    return AircraftMarketModel.fromJson(result.first.toColumnMap());
  }

  Future<AircraftMarketModel?> unpublishAircraft({
    required int productId,
    required int sellerId,
  }) async {
    final existingProduct = await _connection.execute(
      Sql.named('SELECT seller_id FROM aircraft_market WHERE id = @id'),
      parameters: {'id': productId},
    );

    if (existingProduct.isEmpty) {
      return null;
    }

    final existingProductMap = existingProduct.first.toColumnMap();
    final productSellerId = existingProductMap['seller_id'] as int;

    // Проверяем права: владелец или администратор
    final isOwner = productSellerId == sellerId;
    if (!isOwner) {
      // Проверяем, является ли пользователь администратором
      final adminCheck = await _connection.execute(
        Sql.named('SELECT is_admin FROM profiles WHERE id = @id'),
        parameters: {'id': sellerId},
      );
      final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

      if (!isAdmin) {
        throw Exception('You do not have permission to unpublish this product');
      }
    }

    // Пользователь управляет только is_published, не трогаем is_active (его контролирует только админ)
    // ВАЖНО: При unpublish меняем ТОЛЬКО is_published, is_active остается без изменений
    // Даже если published_until истек, is_active не должен меняться при unpublish
    
    // Получаем текущее значение is_active перед обновлением для проверки
    final beforeUpdate = await _connection.execute(
      Sql.named('SELECT is_active FROM aircraft_market WHERE id = @id'),
      parameters: {'id': productId},
    );
    final isActiveBefore = beforeUpdate.isNotEmpty ? (beforeUpdate.first.toColumnMap()['is_active'] as bool? ?? true) : true;

    final result = await _connection.execute(
      Sql.named('''
        UPDATE aircraft_market
        SET is_published = false,
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': productId},
    );

    if (result.isEmpty) return null;
    
    final updatedProduct = AircraftMarketModel.fromJson(result.first.toColumnMap());
    
    // Проверяем, что is_active не изменился
    if (updatedProduct.isActive != isActiveBefore) {
      print('⚠️ [MarketRepository] ВНИМАНИЕ: is_active изменился при unpublish! Было: $isActiveBefore, Стало: ${updatedProduct.isActive}');
      // Восстанавливаем правильное значение is_active
      await _connection.execute(
        Sql.named('''
          UPDATE aircraft_market
          SET is_active = @is_active
          WHERE id = @id
        '''),
        parameters: {'id': productId, 'is_active': isActiveBefore},
      );
      // Получаем обновленный продукт с правильным is_active
      final correctedResult = await _connection.execute(
        Sql.named('SELECT * FROM aircraft_market WHERE id = @id'),
        parameters: {'id': productId},
      );
      if (correctedResult.isNotEmpty) {
        return AircraftMarketModel.fromJson(correctedResult.first.toColumnMap());
      }
    }
    
    return updatedProduct;
  }

  /// Деактивировать объявление о самолете (для админа - блокирует публикацию)
  /// Устанавливает is_active = false, что блокирует показ объявления даже если is_published = true
  Future<AircraftMarketModel?> deactivateAircraft({
    required int productId,
  }) async {
    final existingProduct = await _connection.execute(
      Sql.named('SELECT id FROM aircraft_market WHERE id = @id'),
      parameters: {'id': productId},
    );

    if (existingProduct.isEmpty) {
      return null;
    }

    final result = await _connection.execute(
      Sql.named('''
        UPDATE aircraft_market
        SET is_active = false,
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': productId},
    );

    if (result.isEmpty) return null;
    return AircraftMarketModel.fromJson(result.first.toColumnMap());
  }

  /// Активировать объявление о самолете (для админа - разблокирует публикацию)
  Future<AircraftMarketModel?> activateAircraft({
    required int productId,
  }) async {
    final existingProduct = await _connection.execute(
      Sql.named('SELECT id FROM aircraft_market WHERE id = @id'),
      parameters: {'id': productId},
    );

    if (existingProduct.isEmpty) {
      return null;
    }

    final result = await _connection.execute(
      Sql.named('''
        UPDATE aircraft_market
        SET is_active = true,
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': productId},
    );

    if (result.isEmpty) return null;
    return AircraftMarketModel.fromJson(result.first.toColumnMap());
  }

  /// Удалить самолёт (с проверкой прав и удалением файлов)
  Future<bool> deleteAircraft(int productId, int sellerId) async {
    // Начинаем транзакцию
    await _connection.execute(Sql('BEGIN'));

    try {
      // 1. Получаем товар и проверяем права доступа
      final productResult = await _connection.execute(
        Sql.named('''
          SELECT seller_id, main_image_url, additional_image_urls 
          FROM aircraft_market 
          WHERE id = @id
        '''),
        parameters: {'id': productId},
      );

      if (productResult.isEmpty) {
        await _connection.execute(Sql('ROLLBACK'));
        return false; // Товар не найден
      }

      final product = productResult.first.toColumnMap();
      final productSellerId = product['seller_id'] as int;

      // 2. Проверяем права доступа: владелец или администратор
      final isOwner = productSellerId == sellerId;
      if (!isOwner) {
        // Проверяем, является ли пользователь администратором
        final adminCheck = await _connection.execute(
          Sql.named('SELECT is_admin FROM profiles WHERE id = @id'),
          parameters: {'id': sellerId},
        );
        final isAdmin = adminCheck.isNotEmpty && (adminCheck.first.toColumnMap()['is_admin'] as bool? ?? false);

        if (!isAdmin) {
          await _connection.execute(Sql('ROLLBACK'));
          throw Exception('You do not have permission to delete this product');
        }
      }

      // 3. Собираем пути к файлам для удаления
      final filesToDelete = <String>[];

      final mainImageUrl = product['main_image_url'] as String?;
      if (mainImageUrl != null && mainImageUrl.isNotEmpty) {
        filesToDelete.add(mainImageUrl);
      }

      final additionalImageUrls = product['additional_image_urls'];
      if (additionalImageUrls != null) {
        if (additionalImageUrls is List) {
          filesToDelete.addAll(additionalImageUrls.map((e) => e.toString()).where((e) => e.isNotEmpty));
        } else if (additionalImageUrls is String) {
          try {
            final decoded = jsonDecode(additionalImageUrls) as List;
            filesToDelete.addAll(decoded.map((e) => e.toString()).where((e) => e.isNotEmpty));
          } catch (e) {
            // Игнорируем ошибки парсинга
          }
        }
      }

      // 4. Удаляем связанные записи из избранного
      await _connection.execute(Sql.named('DELETE FROM user_favorite_aircraft_market WHERE product_id = @product_id'), parameters: {'product_id': productId});

      // 5. Удаляем товар из БД
      await _connection.execute(Sql.named('DELETE FROM aircraft_market WHERE id = @id'), parameters: {'id': productId});

      // 6. Коммитим транзакцию
      await _connection.execute(Sql('COMMIT'));

      // 7. Удаляем всю директорию товара с диска (вне транзакции, чтобы не блокировать БД)
      // При полном удалении товара удаляем всю директорию
      try {
        await _deleteProductDirectory(productId);
      } catch (e) {
        // Логируем ошибку, но не блокируем операцию удаления товара
        print('⚠️ Error deleting product directory: $e');
      }

      return true;
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }
  }

  /// Удалить конкретные файлы товара с диска (при обновлении)
  /// НЕ удаляет директорию - только указанные файлы
  Future<void> _deleteProductFiles(int productId, List<String> fileUrls) async {
    final publicDir = Directory('public');
    if (!await publicDir.exists()) {
      print('⚠️ Public directory does not exist, skipping file deletion');
      return;
    }

    int deletedFilesCount = 0;
    int failedFilesCount = 0;

    // Удаляем только указанные файлы
    for (final fileUrl in fileUrls) {
      if (fileUrl.isEmpty) continue;

      try {
        // URL в БД хранится как "market/aircraft/3/main.123456.789.jpg"
        // Нужно добавить "public/" в начало
        final cleanUrl = fileUrl.startsWith('/') ? fileUrl.substring(1) : fileUrl;
        final filePath = '${publicDir.path}/$cleanUrl';
        final file = File(filePath);

        if (await file.exists()) {
          await file.delete();
          deletedFilesCount++;
          print('✅ Deleted file: ${file.path}');
        } else {
          print('⚠️ File does not exist: ${file.path}');
        }
      } catch (e) {
        failedFilesCount++;
        print('⚠️ Error deleting file $fileUrl: $e');
      }
    }

    print('📊 File deletion summary for product $productId: $deletedFilesCount deleted, $failedFilesCount failed');
  }

  /// Удалить всю директорию товара с диска (при полном удалении товара)
  Future<void> _deleteProductDirectory(int productId) async {
    final publicDir = Directory('public');
    if (!await publicDir.exists()) {
      return;
    }

    final productDir = Directory('${publicDir.path}/market/aircraft/$productId');
    if (await productDir.exists()) {
      try {
        await productDir.delete(recursive: true);
        print('✅ Deleted directory: ${productDir.path}');
      } catch (e) {
        print('⚠️ Error deleting directory ${productDir.path}: $e');
      }
    }
  }

  // ============================================
  // МЕТОДЫ ДЛЯ РАБОТЫ С ЗАПЧАСТЯМИ
  // ============================================

  /// Получить объявления о запчастях с фильтрами
  Future<List<PartsMarketModel>> getParts({
    int? mainCategoryId,
    int? subcategoryId,
    int? sellerId,
    int? manufacturerId,
    String? searchQuery,
    String? condition,
    int? priceFrom,
    int? priceTo,
    String? sortBy,
    int? userId,
    bool includeInactive = false,
    int limit = 20,
    int offset = 0,
  }) async {
    await _deactivateExpiredParts();

    String query = '''
      SELECT 
        pm.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        pmc.name as main_category_name,
        psc.name as subcategory_name,
        COALESCE(pmfr.name, pm.manufacturer_name) as manufacturer_name_display,
        ${userId != null ? 'EXISTS(SELECT 1 FROM user_favorite_parts_market WHERE user_id = @user_id AND part_id = pm.id) as is_favorite' : 'FALSE as is_favorite'},
        COALESCE(
          (SELECT json_agg(aircraft_model_id ORDER BY aircraft_model_id)
           FROM parts_market_aircraft_compatibility
           WHERE part_id = pm.id),
          '[]'::json
        ) as compatible_aircraft_model_ids
      FROM parts_market pm
      LEFT JOIN profiles p ON pm.seller_id = p.id
      LEFT JOIN parts_main_categories pmc ON pm.parts_main_category_id = pmc.id
      LEFT JOIN parts_subcategories psc ON pm.parts_subcategory_id = psc.id
      LEFT JOIN parts_manufacturers pmfr ON pm.manufacturer_id = pmfr.id
      WHERE 1 = 1
    ''';

    final parameters = <String, dynamic>{};
    if (userId != null) {
      parameters['user_id'] = userId;
    }

    // Фильтр по основной категории
    if (mainCategoryId != null) {
      query += ' AND pm.parts_main_category_id = @main_category_id';
      parameters['main_category_id'] = mainCategoryId;
    }

    // Фильтр по подкатегории
    if (subcategoryId != null) {
      query += ' AND pm.parts_subcategory_id = @subcategory_id';
      parameters['subcategory_id'] = subcategoryId;
    }

    // Фильтр по производителю
    if (manufacturerId != null) {
      query += ' AND pm.manufacturer_id = @manufacturer_id';
      parameters['manufacturer_id'] = manufacturerId;
    }

    // Фильтр по продавцу
    if (sellerId != null) {
      query += ' AND pm.seller_id = @seller_id';
      parameters['seller_id'] = sellerId;
    }

    // Поиск по названию и описанию
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (pm.title ILIKE @search OR pm.description ILIKE @search OR pm.part_number ILIKE @search)';
      parameters['search'] = '%$searchQuery%';
    }

    // Фильтр по состоянию
    if (condition != null && condition.isNotEmpty) {
      query += ' AND pm.condition = @condition';
      parameters['condition'] = condition;
    }

    // Фильтр по цене
    if (priceFrom != null) {
      query += ' AND pm.price >= @price_from';
      parameters['price_from'] = priceFrom;
    }
    if (priceTo != null) {
      query += ' AND pm.price <= @price_to';
      parameters['price_to'] = priceTo;
    }

    // Фильтр по активности
    // Логика: is_published - пользователь решил опубликовать, is_active - система проверила срок
    // Для отображения нужно: опубликовано И (срок не истек ИЛИ срок не установлен)
    if (!includeInactive) {
      query += ' AND pm.is_published = true AND pm.is_active = true AND (pm.published_until IS NULL OR pm.published_until >= NOW())';
    } else if (sellerId != null && userId != null && sellerId == userId) {
      // Владелец может видеть свои объявления (даже неопубликованные или истекшие)
      query += ' AND pm.seller_id = @seller_id';
    } else {
      // Если includeInactive = true, но не владелец, все равно показываем только активные и опубликованные
      query += ' AND pm.is_published = true AND pm.is_active = true AND (pm.published_until IS NULL OR pm.published_until >= NOW())';
    }

    // Сортировка
    switch (sortBy) {
      case 'price_asc':
        query += ' ORDER BY pm.price ASC';
        break;
      case 'price_desc':
        query += ' ORDER BY pm.price DESC';
        break;
      case 'date':
        query += ' ORDER BY pm.created_at DESC';
        break;
      default:
        query += ' ORDER BY pm.created_at DESC';
    }

    query += ' LIMIT @limit OFFSET @offset';
    parameters['limit'] = limit;
    parameters['offset'] = offset;

    print('🔵 [getParts] SQL запрос: $query');
    print('🔵 [getParts] Параметры: $parameters');
    print('🔵 [getParts] includeInactive: $includeInactive');

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    final parts = result.map((row) => PartsMarketModel.fromJson(row.toColumnMap())).toList();

    print('🔵 [getParts] Найдено запчастей в БД: ${parts.length}');
    if (parts.isEmpty) {
      // Проверяем, сколько всего запчастей в БД без фильтров
      final countResult = await _connection.execute(Sql('SELECT COUNT(*) as count FROM parts_market'));
      final totalCount = (countResult.first[0] as num).toInt();
      print('⚠️ [getParts] Всего запчастей в БД: $totalCount');

      // Проверяем, сколько с is_published = true
      final publishedResult = await _connection.execute(Sql('SELECT COUNT(*) as count FROM parts_market WHERE is_published = true AND is_active = true'));
      final publishedCount = (publishedResult.first[0] as num).toInt();
      print('⚠️ [getParts] Опубликованных и активных: $publishedCount');
    }

    return parts;
  }

  /// Получить объявление о запчасти по ID
  Future<PartsMarketModel?> getPartById(int id, {int? userId}) async {
    await _deactivateExpiredParts();

    String query = '''
      SELECT 
        pm.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        pmc.name as main_category_name,
        psc.name as subcategory_name,
        COALESCE(pmfr.name, pm.manufacturer_name) as manufacturer_name_display,
        ${userId != null ? 'EXISTS(SELECT 1 FROM user_favorite_parts_market WHERE user_id = @user_id AND part_id = pm.id) as is_favorite' : 'FALSE as is_favorite'},
        COALESCE(
          (SELECT json_agg(aircraft_model_id ORDER BY aircraft_model_id)
           FROM parts_market_aircraft_compatibility
           WHERE part_id = pm.id),
          '[]'::json
        ) as compatible_aircraft_model_ids
      FROM parts_market pm
      LEFT JOIN profiles p ON pm.seller_id = p.id
      LEFT JOIN parts_main_categories pmc ON pm.parts_main_category_id = pmc.id
      LEFT JOIN parts_subcategories psc ON pm.parts_subcategory_id = psc.id
      LEFT JOIN parts_manufacturers pmfr ON pm.manufacturer_id = pmfr.id
      WHERE pm.id = @id
        AND (
          (pm.is_active = true AND pm.is_published = true AND (pm.published_until IS NULL OR pm.published_until >= NOW()))
          ${userId != null ? ' OR pm.seller_id = @user_id' : ''}
        )
    ''';

    final parameters = <String, dynamic>{'id': id};
    if (userId != null) {
      parameters['user_id'] = userId;
    }

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    if (result.isEmpty) return null;
    return PartsMarketModel.fromJson(result.first.toColumnMap());
  }

  /// Создать объявление о запчасти
  Future<PartsMarketModel> createPart({
    required int sellerId,
    required String title,
    String? description,
    required int price,
    String currency = 'RUB',
    int? partsMainCategoryId,
    int? partsSubcategoryId,
    int? manufacturerId,
    String? manufacturerName,
    String? partNumber,
    String? oemNumber,
    String? condition,
    int quantity = 1,
    String? mainImageUrl,
    List<String> additionalImageUrls = const [],
    double? weightKg,
    double? dimensionsLengthCm,
    double? dimensionsWidthCm,
    double? dimensionsHeightCm,
    String? compatibleAircraftModelsText,
    String? location,
    List<int>? compatibleAircraftModelIds,
    bool isPublished = true,
  }) async {
    // Получаем период публикации из БД
    final durationMonths = await _getPublicationDurationMonths('parts_market');

    await _connection.execute(Sql('BEGIN'));
    try {
      // Создаем объявление
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO parts_market (
            seller_id, title, description, price, currency,
            parts_main_category_id, parts_subcategory_id,
            manufacturer_id, manufacturer_name,
            part_number, oem_number, condition, quantity,
            main_image_url, additional_image_urls,
            weight_kg, dimensions_length_cm, dimensions_width_cm, dimensions_height_cm,
            compatible_aircraft_models_text, location,
            is_published, is_active, published_until, views_count, favorites_count
          )
          VALUES (
            @seller_id, @title, @description, @price, @currency,
            @parts_main_category_id, @parts_subcategory_id,
            @manufacturer_id, @manufacturer_name,
            @part_number, @oem_number, @condition, @quantity,
            @main_image_url, @additional_image_urls::jsonb,
            @weight_kg, @dimensions_length_cm, @dimensions_width_cm, @dimensions_height_cm,
            @compatible_aircraft_models_text, @location,
            @is_published, true, @published_until, 0, 0
          )
          RETURNING *
        '''),
        parameters: {
          'seller_id': sellerId,
          'title': title,
          'description': description,
          'price': price,
          'currency': currency,
          'parts_main_category_id': partsMainCategoryId,
          'parts_subcategory_id': partsSubcategoryId,
          'manufacturer_id': manufacturerId,
          'manufacturer_name': manufacturerName,
          'part_number': partNumber,
          'oem_number': oemNumber,
          'condition': condition ?? 'used',
          'quantity': quantity,
          'main_image_url': mainImageUrl,
          'additional_image_urls': jsonEncode(additionalImageUrls),
          'weight_kg': weightKg,
          'dimensions_length_cm': dimensionsLengthCm,
          'dimensions_width_cm': dimensionsWidthCm,
          'dimensions_height_cm': dimensionsHeightCm,
          'compatible_aircraft_models_text': compatibleAircraftModelsText,
          'location': location,
          'is_published': isPublished,
          'published_until': isPublished ? DateTime.now().add(Duration(days: durationMonths * 30)) : null,
        },
      );

      if (result.isEmpty) {
        throw Exception('Failed to create part');
      }

      final partId = result.first[0] as int;

      // Добавляем совместимость с самолетами
      if (compatibleAircraftModelIds != null && compatibleAircraftModelIds.isNotEmpty) {
        for (final aircraftModelId in compatibleAircraftModelIds) {
          await _connection.execute(
            Sql.named('''
              INSERT INTO parts_market_aircraft_compatibility (part_id, aircraft_model_id)
              VALUES (@part_id, @aircraft_model_id)
              ON CONFLICT (part_id, aircraft_model_id) DO NOTHING
            '''),
            parameters: {
              'part_id': partId,
              'aircraft_model_id': aircraftModelId,
            },
          );
        }
      }

      // Добавляем первую запись в историю цен
      await _addPartPriceHistory(partId, price);

      await _connection.execute(Sql('COMMIT'));

      // Получаем созданное объявление
      final part = await getPartById(partId, userId: sellerId);
      if (part == null) {
        throw Exception('Failed to retrieve created part');
      }
      return part;
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }
  }

  /// Обновить объявление о запчасти
  Future<PartsMarketModel?> updatePart({
    required int partId,
    required int sellerId,
    String? title,
    String? description,
    int? price,
    String? currency,
    int? partsMainCategoryId,
    int? partsSubcategoryId,
    int? manufacturerId,
    String? manufacturerName,
    String? partNumber,
    String? oemNumber,
    String? condition,
    int? quantity,
    String? mainImageUrl,
    List<String>? additionalImageUrls,
    double? weightKg,
    double? dimensionsLengthCm,
    double? dimensionsWidthCm,
    double? dimensionsHeightCm,
    String? compatibleAircraftModelsText,
    String? location,
    List<int>? compatibleAircraftModelIds,
  }) async {
    // Проверяем права и получаем старую цену
    final existingPart = await _connection.execute(
      Sql.named('SELECT seller_id, price FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return null;
    }

    final existingPartMap = existingPart.first.toColumnMap();
    final partSellerId = existingPartMap['seller_id'] as int;
    // price в parts_market имеет тип NUMERIC(10, 2), преобразуем в int
    final oldPriceValue = existingPartMap['price'];
    final oldPrice = (oldPriceValue is num ? oldPriceValue : num.parse(oldPriceValue.toString())).toInt();
    if (partSellerId != sellerId) {
      throw Exception('You do not have permission to update this part');
    }

    await _connection.execute(Sql('BEGIN'));
    try {
      // Формируем динамический UPDATE запрос
      final updates = <String>[];
      final parameters = <String, dynamic>{'id': partId};

      if (title != null) {
        updates.add('title = @title');
        parameters['title'] = title;
      }
      if (description != null) {
        updates.add('description = @description');
        parameters['description'] = description;
      }
      if (price != null) {
        updates.add('price = @price');
        parameters['price'] = price;
      }
      if (currency != null) {
        updates.add('currency = @currency');
        parameters['currency'] = currency;
      }
      if (partsMainCategoryId != null) {
        updates.add('parts_main_category_id = @parts_main_category_id');
        parameters['parts_main_category_id'] = partsMainCategoryId;
      }
      if (partsSubcategoryId != null) {
        updates.add('parts_subcategory_id = @parts_subcategory_id');
        parameters['parts_subcategory_id'] = partsSubcategoryId;
      }
      if (manufacturerId != null) {
        updates.add('manufacturer_id = @manufacturer_id');
        parameters['manufacturer_id'] = manufacturerId;
      }
      if (manufacturerName != null) {
        updates.add('manufacturer_name = @manufacturer_name');
        parameters['manufacturer_name'] = manufacturerName;
      }
      if (partNumber != null) {
        updates.add('part_number = @part_number');
        parameters['part_number'] = partNumber;
      }
      if (oemNumber != null) {
        updates.add('oem_number = @oem_number');
        parameters['oem_number'] = oemNumber;
      }
      if (condition != null) {
        updates.add('condition = @condition');
        parameters['condition'] = condition;
      }
      if (quantity != null) {
        updates.add('quantity = @quantity');
        parameters['quantity'] = quantity;
      }
      if (mainImageUrl != null) {
        updates.add('main_image_url = @main_image_url');
        parameters['main_image_url'] = mainImageUrl;
      }
      if (additionalImageUrls != null) {
        updates.add('additional_image_urls = @additional_image_urls::jsonb');
        parameters['additional_image_urls'] = jsonEncode(additionalImageUrls);
      }
      if (weightKg != null) {
        updates.add('weight_kg = @weight_kg');
        parameters['weight_kg'] = weightKg;
      }
      if (dimensionsLengthCm != null) {
        updates.add('dimensions_length_cm = @dimensions_length_cm');
        parameters['dimensions_length_cm'] = dimensionsLengthCm;
      }
      if (dimensionsWidthCm != null) {
        updates.add('dimensions_width_cm = @dimensions_width_cm');
        parameters['dimensions_width_cm'] = dimensionsWidthCm;
      }
      if (dimensionsHeightCm != null) {
        updates.add('dimensions_height_cm = @dimensions_height_cm');
        parameters['dimensions_height_cm'] = dimensionsHeightCm;
      }
      if (compatibleAircraftModelsText != null) {
        updates.add('compatible_aircraft_models_text = @compatible_aircraft_models_text');
        parameters['compatible_aircraft_models_text'] = compatibleAircraftModelsText;
      }
      if (location != null) {
        updates.add('location = @location');
        parameters['location'] = location;
      }

      if (updates.isEmpty) {
        await _connection.execute(Sql('COMMIT'));
        return await getPartById(partId, userId: sellerId);
      }

      updates.add('updated_at = NOW()');

      await _connection.execute(
        Sql.named('UPDATE parts_market SET ${updates.join(', ')} WHERE id = @id'),
        parameters: parameters,
      );

      // Если цена изменилась, добавляем запись в историю цен
      if (price != null && price != oldPrice) {
        await _addPartPriceHistory(partId, price);
      }

      // Обновляем совместимость с самолетами
      if (compatibleAircraftModelIds != null) {
        // Удаляем старые связи
        await _connection.execute(
          Sql.named('DELETE FROM parts_market_aircraft_compatibility WHERE part_id = @part_id'),
          parameters: {'part_id': partId},
        );

        // Добавляем новые связи
        for (final aircraftModelId in compatibleAircraftModelIds) {
          await _connection.execute(
            Sql.named('''
              INSERT INTO parts_market_aircraft_compatibility (part_id, aircraft_model_id)
              VALUES (@part_id, @aircraft_model_id)
            '''),
            parameters: {
              'part_id': partId,
              'aircraft_model_id': aircraftModelId,
            },
          );
        }
      }

      await _connection.execute(Sql('COMMIT'));
      return await getPartById(partId, userId: sellerId);
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }
  }

  /// Увеличить счетчик просмотров
  Future<void> incrementPartViews(int partId) async {
    await _connection.execute(
      Sql.named('UPDATE parts_market SET views_count = views_count + 1 WHERE id = @id'),
      parameters: {'id': partId},
    );
  }

  /// Добавить в избранное
  Future<void> addPartToFavorites(int userId, int partId) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO user_favorite_parts_market (user_id, part_id)
        VALUES (@user_id, @part_id)
        ON CONFLICT (user_id, part_id) DO NOTHING
      '''),
      parameters: {'user_id': userId, 'part_id': partId},
    );

    // Обновляем счетчик избранных
    await _connection.execute(
      Sql.named('UPDATE parts_market SET favorites_count = favorites_count + 1 WHERE id = @part_id'),
      parameters: {'part_id': partId},
    );
  }

  /// Удалить из избранного
  Future<void> removePartFromFavorites(int userId, int partId) async {
    await _connection.execute(
      Sql.named('DELETE FROM user_favorite_parts_market WHERE user_id = @user_id AND part_id = @part_id'),
      parameters: {'user_id': userId, 'part_id': partId},
    );

    // Обновляем счетчик избранных
    await _connection.execute(
      Sql.named('UPDATE parts_market SET favorites_count = GREATEST(0, favorites_count - 1) WHERE id = @part_id'),
      parameters: {'part_id': partId},
    );
  }

  /// Получить избранные запчасти пользователя
  Future<List<PartsMarketModel>> getFavoriteParts(int userId, {int limit = 20, int offset = 0}) async {
    await _deactivateExpiredParts();

    String query = '''
      SELECT 
        pm.*,
        p.first_name as seller_first_name,
        p.last_name as seller_last_name,
        p.phone as seller_phone,
        p.telegram as seller_telegram,
        p.max as seller_max,
        pmc.name as main_category_name,
        psc.name as subcategory_name,
        COALESCE(pmfr.name, pm.manufacturer_name) as manufacturer_name_display,
        TRUE as is_favorite
      FROM parts_market pm
      INNER JOIN user_favorite_parts_market ufp ON pm.id = ufp.part_id
      LEFT JOIN profiles p ON pm.seller_id = p.id
      LEFT JOIN parts_main_categories pmc ON pm.parts_main_category_id = pmc.id
      LEFT JOIN parts_subcategories psc ON pm.parts_subcategory_id = psc.id
      LEFT JOIN parts_manufacturers pmfr ON pm.manufacturer_id = pmfr.id
      WHERE ufp.user_id = @user_id
        AND pm.is_active = true
        AND pm.is_published = true
        AND (pm.published_until IS NULL OR pm.published_until >= NOW())
      ORDER BY ufp.created_at DESC
      LIMIT @limit OFFSET @offset
    ''';

    final result = await _connection.execute(
      Sql.named(query),
      parameters: {'user_id': userId, 'limit': limit, 'offset': offset},
    );
    return result.map((row) => PartsMarketModel.fromJson(row.toColumnMap())).toList();
  }

  /// Опубликовать объявление о запчасти
  Future<PartsMarketModel?> publishPart({
    required int partId,
    required int sellerId,
  }) async {
    final existingPart = await _connection.execute(
      Sql.named('SELECT seller_id FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return null;
    }

    final partSellerId = existingPart.first[0] as int;
    if (partSellerId != sellerId) {
      throw Exception('You do not have permission to publish this part');
    }

    // Получаем период публикации из БД
    final durationMonths = await _getPublicationDurationMonths('parts_market');

    // Пользователь управляет только is_published, не трогаем is_active (его контролирует только админ)
    final result = await _connection.execute(
      Sql.named('''
        UPDATE parts_market
        SET is_published = true,
            published_until = NOW() + MAKE_INTERVAL(months => @duration),
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': partId,
        'duration': durationMonths,
      },
    );

    if (result.isEmpty) return null;
    return await getPartById(partId, userId: null);
  }

  /// Снять с публикации
  Future<PartsMarketModel?> unpublishPart({
    required int partId,
    required int sellerId,
  }) async {
    final existingPart = await _connection.execute(
      Sql.named('SELECT seller_id FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return null;
    }

    final partSellerId = existingPart.first[0] as int;
    if (partSellerId != sellerId) {
      throw Exception('You do not have permission to unpublish this part');
    }

    await _connection.execute(
      Sql.named('''
        UPDATE parts_market
        SET is_published = false,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': partId},
    );

    return await getPartById(partId, userId: sellerId);
  }

  /// Деактивировать объявление (для админа - блокирует публикацию)
  /// Устанавливает is_active = false, что блокирует показ объявления даже если is_published = true
  Future<PartsMarketModel?> deactivatePart({
    required int partId,
  }) async {
    final existingPart = await _connection.execute(
      Sql.named('SELECT id FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return null;
    }

    await _connection.execute(
      Sql.named('''
        UPDATE parts_market
        SET is_active = false,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': partId},
    );

    return await getPartById(partId, userId: null);
  }

  /// Активировать объявление (для админа - разблокирует публикацию)
  Future<PartsMarketModel?> activatePart({
    required int partId,
  }) async {
    final existingPart = await _connection.execute(
      Sql.named('SELECT id FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return null;
    }

    await _connection.execute(
      Sql.named('''
        UPDATE parts_market
        SET is_active = true,
            updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': partId},
    );

    return await getPartById(partId, userId: null);
  }

  /// Удалить объявление о запчасти
  Future<bool> deletePart({
    required int partId,
    required int sellerId,
  }) async {
    final existingPart = await _connection.execute(
      Sql.named('SELECT seller_id FROM parts_market WHERE id = @id'),
      parameters: {'id': partId},
    );

    if (existingPart.isEmpty) {
      return false;
    }

    final partSellerId = existingPart.first[0] as int;
    if (partSellerId != sellerId) {
      throw Exception('You do not have permission to delete this part');
    }

    await _connection.execute(Sql('BEGIN'));
    try {
      // Удаляем совместимость
      await _connection.execute(
        Sql.named('DELETE FROM parts_market_aircraft_compatibility WHERE part_id = @part_id'),
        parameters: {'part_id': partId},
      );

      // Удаляем из избранного
      await _connection.execute(
        Sql.named('DELETE FROM user_favorite_parts_market WHERE part_id = @part_id'),
        parameters: {'part_id': partId},
      );

      // Удаляем объявление
      await _connection.execute(
        Sql.named('DELETE FROM parts_market WHERE id = @id'),
        parameters: {'id': partId},
      );

      await _connection.execute(Sql('COMMIT'));
      return true;
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }
  }

  /// Деактивировать истекшие объявления о запчастях
  Future<void> _deactivateExpiredParts() async {
    await _connection.execute(
      Sql('''
        UPDATE parts_market
        SET is_active = false
        WHERE is_active = true
          AND is_published = true
          AND published_until IS NOT NULL
          AND published_until < NOW()
      '''),
    );
  }

  /// Получить список производителей запчастей
  Future<List<Map<String, dynamic>>> getPartsManufacturers({String? search}) async {
    String query = '''
      SELECT id, name, name_en, country
      FROM parts_manufacturers
      WHERE is_active = true
    ''';

    final parameters = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      query += ' AND (name ILIKE @search OR name_en ILIKE @search)';
      parameters['search'] = '%$search%';
    }

    query += ' ORDER BY name ASC';

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    return result
        .map((row) => {
              'id': row[0] as int,
              'name': row[1] as String,
              'name_en': row[2] as String?,
              'country': row[3] as String?,
            })
        .toList();
  }
}
