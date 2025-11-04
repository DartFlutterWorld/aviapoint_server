import 'package:aviapoint_server/learning/hand_book/model/emergency_categories_model.dart';
import 'package:aviapoint_server/learning/hand_book/model/hand_book_main_categories_model.dart';
import 'package:aviapoint_server/learning/hand_book/model/normal_categories_model.dart';
import 'package:aviapoint_server/learning/hand_book/model/normal_check_list_model.dart';
import 'package:aviapoint_server/learning/hand_book/model/preflight_inspection_categories_model.dart';
import 'package:aviapoint_server/learning/hand_book/model/preflight_inspetion_check_list_model.dart';
import 'package:aviapoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class HandBookRepository {
  final Connection _connection;

  HandBookRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить все главные категории
  Future<List<HandBookMainCategoriesModel>> fetchHandBookMainCategoties() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM hand_book_main_categories ORDER by main_category_id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => HandBookMainCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchHandBookMainCategoties: $e');
      throw e;
    }
  }

  // /// Получить все суб категории для предполётные процедуры
  Future<List<PreflightInspectionCategoriesModel>> fetchPreflightInspectionCategories() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM preflight_inspection_categories ORDER by id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => PreflightInspectionCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchPreflightInspectionCategories: $e');
      throw e;
    }
  }

  // /// Получить всех челистов для предполётные процедуры
  Future<List<PreflightInspectionCheckLisModel>> fetchPreflightInspectionCheckList() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM preflight_inspection_check_list'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => PreflightInspectionCheckLisModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchPreflightInspectionCheckList: $e');
      throw e;
    }
  }

// Получить чек лист по конкретной категории из предполётных процедур
  Future<List<PreflightInspectionCheckLisModel>> fetchPreflightInspectionCheckListById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM preflight_inspection_check_list WHERE preflight_inspection_category_id = @id ORDER by id'), parameters: {
        'id': id,
      });
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => PreflightInspectionCheckLisModel.fromJson(e.toColumnMap())).toList();

      return models;
    } catch (e) {
      logger.severe('Failed to fetchPreflightInspectionCheckListById: $e');
      throw e;
    }
  }

  // /// Получить все суб категории для Нормальных процедур
  Future<List<NormalCategoriesModel>> fetchNormalCategories() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM normal_categories ORDER by id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => NormalCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchNormalCategories: $e');
      throw e;
    }
  }

  // /// Получить всех челистов для предполётные процедуры
  Future<List<NormalCheckLisModel>> fetchNormalCheckList() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM normal_check_list'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => NormalCheckLisModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchNormalCheckList: $e');
      throw e;
    }
  }

// Получить чек лист по конкретной категории из предполётных процедур
  Future<List<NormalCheckLisModel>> fetchNormalCheckListById(int id) async {
    try {
      final result = await _connection.execute(Sql.named('SELECT * FROM normal_check_list WHERE normal_category_id = @id ORDER by id'), parameters: {
        'id': id,
      });
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => NormalCheckLisModel.fromJson(e.toColumnMap())).toList();

      return models;
    } catch (e) {
      logger.severe('Failed to fetchNormalCheckListById: $e');
      throw e;
    }
  }

  // /// Получить все суб категории для Аварийных процедур
  Future<List<EmergencyCategoriesModel>> fetchEmergencyCategories() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM emergency_categories ORDER by id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => EmergencyCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchEmergencyCategories: $e');
      throw e;
    }
  }
}
