import 'package:airpoint_server/learning/hand_book/model/hand_book_main_categories_model.dart';
import 'package:airpoint_server/learning/hand_book/model/preflight_inspection_categories_model.dart';
import 'package:airpoint_server/logger/logger.dart';
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
        Sql.named('SELECT * FROM hand_book_main_categories'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => HandBookMainCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to hand_book_main_categories: $e');
      throw e;
    }
  }

  // /// Получить все суб категории для предполётные процедуры
  Future<List<PreflightInspectionCategoriesModel>> fetchPreflightInspectionCategoriesModel() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM preflight_inspection_categories'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => PreflightInspectionCategoriesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to preflight_inspection_categories: $e');
      throw e;
    }
  }

  // Future<CheckListModel> fetchCheckListById(int id) async {
  //   try {
  //     final result = await _connection.execute(Sql.named('SELECT * FROM checklist WHERE id = @id'), parameters: {
  //       'id': id,
  //     });
  //     // logger.info(result.first.toColumnMap());
  //     logger.info(result.toList().map((f) => f.toColumnMap()));

  //     final models = CheckListModel.fromJson(result.first.toColumnMap());
  //     return models;
  //   } catch (e) {
  //     logger.severe('Failed to fetchCheckListById: $e');
  //     throw e;
  //   }
  // }
}
