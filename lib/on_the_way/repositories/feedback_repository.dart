import 'dart:convert';
import 'package:aviapoint_server/on_the_way/data/model/feedback_model.dart';
import 'package:postgres/postgres.dart';

class FeedbackRepository {
  final Connection _connection;

  FeedbackRepository({required Connection connection}) : _connection = connection;

  /// Сохранить обратную связь
  Future<FeedbackModel> submitFeedback({
    required String sourcePage,
    String? airportCode,
    int? flightId,
    String? email,
    required String comment,
    List<String>? photoUrls,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO feedback (source_page, airport_code, flight_id, email, comment, photos, status)
        VALUES (@source_page, @airport_code, @flight_id, @email, @comment, @photos::jsonb, 'pending')
        RETURNING *
      '''),
      parameters: {
        'source_page': sourcePage,
        'airport_code': airportCode,
        'flight_id': flightId,
        'email': email,
        'comment': comment,
        'photos': photoUrls != null && photoUrls.isNotEmpty ? jsonEncode(photoUrls) : null,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create feedback');
    }

    return FeedbackModel.fromJson(result.first.toColumnMap());
  }

  /// Получить все обратные связи
  Future<List<FeedbackModel>> getAllFeedback({String? status}) async {
    var sql = 'SELECT * FROM feedback';
    final parameters = <String, dynamic>{};

    if (status != null && status.isNotEmpty) {
      sql += ' WHERE status = @status';
      parameters['status'] = status;
    }

    sql += ' ORDER BY created_at DESC';

    final result = await _connection.execute(Sql.named(sql), parameters: parameters);

    return result.map((row) => FeedbackModel.fromJson(row.toColumnMap())).toList();
  }

  /// Обновить статус обратной связи
  Future<FeedbackModel?> updateFeedbackStatus(int id, String status) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE feedback
        SET status = @status, updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': id, 'status': status},
    );

    if (result.isEmpty) return null;

    return FeedbackModel.fromJson(result.first.toColumnMap());
  }
}


