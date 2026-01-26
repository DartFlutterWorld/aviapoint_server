import 'dart:convert';
import 'dart:io';
import 'package:aviapoint_server/market/data/model/market_category_model.dart';
import 'package:aviapoint_server/market/data/model/aircraft_market_model.dart';
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
    // Для запчастей пока категорий нет
    return [];
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
    // Сначала получаем список объявлений, которые будут сняты с публикации
    // вместе с информацией о владельце и FCM токеном
    final expiredListings = await _connection.execute(
      Sql.named('''
        SELECT 
          am.id,
          am.title,
          am.seller_id,
          (SELECT fcm_token FROM fcm_tokens WHERE user_id = am.seller_id ORDER BY updated_at DESC LIMIT 1) as fcm_token
        FROM aircraft_market am
        LEFT JOIN profiles p ON am.seller_id = p.id
        WHERE am.is_active = true
          AND am.published_until IS NOT NULL
          AND am.published_until < NOW()
      '''),
    );

    // Отправляем push-уведомления владельцам перед снятием с публикации
    if (expiredListings.isNotEmpty) {
      final fcmService = FcmService();

      for (final row in expiredListings) {
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

    // Теперь снимаем объявления с публикации
    await _connection.execute(
      Sql('''
        UPDATE aircraft_market
        SET is_active = false
        WHERE is_active = true
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
      query += ' AND mp.is_active = true AND (mp.published_until IS NULL OR mp.published_until >= NOW())';
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
  }) async {
    // Получаем период публикации из БД
    final durationMonths = await _getPublicationDurationMonths('aircraft_market');

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO aircraft_market (
          seller_id, title, description, price, aircraft_subcategories_id,
          main_image_url, additional_image_urls, brand, location,
          year, total_flight_hours, engine_power, engine_volume, seats, condition, 
          is_share_sale, share_numerator, share_denominator,
          is_leasing, leasing_conditions,
          published_until, is_active, views_count
        )
        VALUES (
          @seller_id, @title, @description, @price, @aircraft_subcategories_id,
          @main_image_url, @additional_image_urls::jsonb, @brand, @location,
          @year, @total_flight_hours, @engine_power, @engine_volume, @seats, @condition,
          @is_share_sale, @share_numerator, @share_denominator,
          @is_leasing, @leasing_conditions,
          NOW() + MAKE_INTERVAL(months => @duration), true, 0
        )
        RETURNING *
      '''),
      parameters: {
        'seller_id': sellerId,
        'title': title,
        'description': description,
        'price': price,
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
        'duration': durationMonths,
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

  /// Получить историю цен для объявления
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

  /// Обновить объявление о самолёте
  Future<AircraftMarketModel?> updateAircraft({
    required int productId,
    required int sellerId, // Для проверки прав
    String? title,
    String? description,
    int? price,
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

    final result = await _connection.execute(
      Sql.named('''
        UPDATE aircraft_market
        SET is_active = true,
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
}
