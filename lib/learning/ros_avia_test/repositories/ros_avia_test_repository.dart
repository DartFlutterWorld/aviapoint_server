import 'package:airpoint_server/learning/ros_avia_test/model/answer_model.dart';
import 'package:airpoint_server/learning/ros_avia_test/model/ros_avia_test_category_model.dart';
import 'package:airpoint_server/learning/ros_avia_test/model/question_with_answers_model.dart';
import 'package:airpoint_server/learning/ros_avia_test/model/ros_avia_test_category_with_questions_model.dart';
import 'package:airpoint_server/learning/ros_avia_test/model/type_correct_answer_model.dart';
import 'package:airpoint_server/learning/ros_avia_test/model/type_sertificates_model.dart';
import 'package:airpoint_server/logger/logger.dart';
import 'package:postgres/postgres.dart';

class RosAviaTestRepository {
  final Connection _connection;

  RosAviaTestRepository({
    required Connection connection,
  }) : _connection = connection;

  // /// Получить все главные категории
  Future<List<TypeSertificatesModel>> fetchTypeSertificates() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM type_certificates ORDER by id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => TypeSertificatesModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchTypeSertificates: $e');
      throw e;
    }
  }

  // /// Получить все типы правильности ответа
  Future<List<TypeCorrectAnswerModel>> fetchTypeCorrectAnswer() async {
    try {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM type_correct_answers ORDER by id'),
      );
      // logger.info(result.first.toColumnMap());
      logger.info(result.toList().map((f) => f.toColumnMap()));

      final models = result.map((e) => TypeCorrectAnswerModel.fromJson(e.toColumnMap())).toList();
      return models;
    } catch (e) {
      logger.severe('Failed to fetchTypeCorrectAnswer: $e');
      throw e;
    }
  }

  // Future<List<RosAviaTestCategoryModel>> fetchRosAviaTestCategory() async {
  //   try {
  //     final result = await _connection.execute(
  //       Sql.named('SELECT * FROM rosaviatest_category ORDER by id'),
  //     );
  //     // logger.info(result.first.toColumnMap());
  //     logger.info(result.toList().map((f) => f.toColumnMap()));

  //     final models = result.map((e) => RosAviaTestCategoryModel.fromJson(e.toColumnMap())).toList();
  //     return models;
  //   } catch (e) {
  //     logger.severe('Failed to fetchRosaviatestCategory: $e');
  //     throw e;
  //   }
  // }

  // Получить чек лист по конкретной категории
  Future<List<RosAviaTestCategoryModel>> fetchRosAviaTestCategories(int typeCertificateId) async {
    try {
      final sql = Sql.named(r'''
      SELECT DISTINCT c.id, c.title, c.image
      FROM question_type_certificates qtc
      JOIN rosaviatest_category c ON c.id = qtc.category_id
      WHERE qtc.type_certificate_id = @typeCertificateId
      ORDER BY c.title
    ''');

      final result = await _connection.execute(
        sql,
        parameters: {'typeCertificateId': typeCertificateId},
      );

      logger.info(result.toList().map((f) => f.toColumnMap()));
      final models = result.map((row) => RosAviaTestCategoryModel.fromJson(row.toColumnMap())).toList();

      return models;
    } catch (e) {
      logger.severe('Failed to fetchRosAviaTestCategory: $e');
      rethrow;
    }
  }

  // /// Получить все  категории для Частного пилота (самолёт)
  Future<List<RosAviaTestCategoryWithQuestionsModel>> fetchRosAviaTestCategoryWithQuestions(int typeCertificateId) async {
    try {
      final result = await _connection.execute(
        Sql.named('''
      SELECT 
        c.id AS category_id,
        c.title AS category_title,
        c.image AS category_image,
        COALESCE(tcc.position, 999) AS category_position,
        (SELECT COUNT(*) FROM question_type_certificates qtc2 
         WHERE qtc2.category_id = c.id AND qtc2.type_certificate_id = @type_certificate_id) AS questions_count,
        CASE 
          WHEN q.id IS NULL THEN NULL
          ELSE JSONB_BUILD_OBJECT(
            'question_id', q.id,
            'question_text', q.title,
            'explanation', q.explanation,
            'correct_answer', q.correct_answer,
            'answers', (
              SELECT JSON_AGG(
                JSONB_BUILD_OBJECT(
                  'answer_id', a.id,
                  'answer_text', a.answer_text,
                  'is_correct', a.is_correct,
                  'is_official', a.is_official,
                  'position', a.position
                )
                ORDER BY a.position
              )
              FROM rosaviatest_answers a 
              WHERE a.question_id = q.id
            )
          )
        END AS question_data
      FROM 
        rosaviatest_type_certificates_category tcc
      INNER JOIN 
        rosaviatest_category c ON tcc.category_id = c.id
      LEFT JOIN 
        question_type_certificates qtc ON c.id = qtc.category_id 
        AND qtc.type_certificate_id = @type_certificate_id
      LEFT JOIN 
        rosaviatest_questions q ON qtc.question_id = q.id
      WHERE 
        tcc.type_sertificates_id = @type_certificate_id
      ORDER BY 
        tcc.position ASC,
        c.id ASC,
        q.id ASC;
    '''),
        parameters: {
          'type_certificate_id': typeCertificateId,
        },
      );

      // Группируем результаты по категориям
      final categoriesMap = <int, RosAviaTestCategoryWithQuestionsModel>{};

      for (final row in result) {
        final map = row.toColumnMap();
        final categoryId = map['category_id'] as int;

        // Получаем или создаем категорию
        final category = categoriesMap.putIfAbsent(categoryId, () {
          return RosAviaTestCategoryWithQuestionsModel.fromJson({
            'category_id': categoryId,
            'category_title': map['category_title'],
            'category_image': map['category_image'],
            'category_position': map['category_position'],
            'questions_count': map['questions_count'] ?? 0,
            'questions_with_answers': [],
          });
        });

        // Добавляем вопрос, если он есть
        final questionData = map['question_data'];
        if (questionData != null && questionData is Map<String, dynamic>) {
          final question = QuestionWithAnswersModel.fromJson(questionData);
          category.questionsWithAnswers.add(question);
        }
      }

      return categoriesMap.values.toList();
    } catch (e) {
      logger.severe('Failed to fetchRosAviaTestCategoryWithQuestions: $e');
      rethrow;
    }
  }

//   // /// Получить всех челистов для предполётные процедуры
//   Future<List<PreflightInspectionCheckLisModel>> fetchPreflightInspectionCheckList() async {
//     try {
//       final result = await _connection.execute(
//         Sql.named('SELECT * FROM preflight_inspection_check_list'),
//       );
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => PreflightInspectionCheckLisModel.fromJson(e.toColumnMap())).toList();
//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchPreflightInspectionCheckList: $e');
//       throw e;
//     }
//   }

// // Получить чек лист по конкретной категории из предполётных процедур
//   Future<List<PreflightInspectionCheckLisModel>> fetchPreflightInspectionCheckListById(int id) async {
//     try {
//       final result = await _connection.execute(Sql.named('SELECT * FROM preflight_inspection_check_list WHERE preflight_inspection_category_id = @id ORDER by id'), parameters: {
//         'id': id,
//       });
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => PreflightInspectionCheckLisModel.fromJson(e.toColumnMap())).toList();

//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchPreflightInspectionCheckListById: $e');
//       throw e;
//     }
//   }

//   // /// Получить все суб категории для Нормальных процедур
//   Future<List<NormalCategoriesModel>> fetchNormalCategories() async {
//     try {
//       final result = await _connection.execute(
//         Sql.named('SELECT * FROM normal_categories ORDER by id'),
//       );
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => NormalCategoriesModel.fromJson(e.toColumnMap())).toList();
//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchNormalCategories: $e');
//       throw e;
//     }
//   }

//   // /// Получить всех челистов для предполётные процедуры
//   Future<List<NormalCheckLisModel>> fetchNormalCheckList() async {
//     try {
//       final result = await _connection.execute(
//         Sql.named('SELECT * FROM normal_check_list'),
//       );
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => NormalCheckLisModel.fromJson(e.toColumnMap())).toList();
//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchNormalCheckList: $e');
//       throw e;
//     }
//   }

// // Получить чек лист по конкретной категории из предполётных процедур
//   Future<List<NormalCheckLisModel>> fetchNormalCheckListById(int id) async {
//     try {
//       final result = await _connection.execute(Sql.named('SELECT * FROM normal_check_list WHERE normal_category_id = @id ORDER by id'), parameters: {
//         'id': id,
//       });
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => NormalCheckLisModel.fromJson(e.toColumnMap())).toList();

//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchNormalCheckListById: $e');
//       throw e;
//     }
//   }

//   // /// Получить все суб категории для Аварийных процедур
//   Future<List<EmergencyCategoriesModel>> fetchEmergencyCategories() async {
//     try {
//       final result = await _connection.execute(
//         Sql.named('SELECT * FROM emergency_categories ORDER by id'),
//       );
//       // logger.info(result.first.toColumnMap());
//       logger.info(result.toList().map((f) => f.toColumnMap()));

//       final models = result.map((e) => EmergencyCategoriesModel.fromJson(e.toColumnMap())).toList();
//       return models;
//     } catch (e) {
//       logger.severe('Failed to fetchEmergencyCategories: $e');
//       throw e;
//     }
//   }
}
