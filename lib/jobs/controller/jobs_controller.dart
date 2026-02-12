import 'dart:convert';
import 'dart:io';

import 'package:aviapoint_server/auth/token/token_service.dart';
import 'package:aviapoint_server/core/wrap_response.dart';
import 'package:aviapoint_server/jobs/repositories/jobs_repository.dart';
import 'package:aviapoint_server/profiles/data/repositories/profile_repository.dart';
import 'package:aviapoint_server/push_notifications/fcm_service.dart';
import 'package:aviapoint_server/telegram/telegram_bot_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Контроллер для работы с вакансиями и резюме (jobs)
class JobsController {
  final JobsRepository _repository;
  final TokenService _tokenService;
  final ProfileRepository _profileRepository;

  JobsController({
    required JobsRepository repository,
    required TokenService tokenService,
    required ProfileRepository profileRepository,
  })  : _repository = repository,
        _tokenService = tokenService,
        _profileRepository = profileRepository;

  Router get router {
    final router = Router();

    // Сначала буквальные пути (my-vacancy-responses — до любых параметризованных)
    router.get('/api/jobs/my-vacancy-responses', getMyVacancyResponses);
    router.delete('/api/jobs/my-vacancy-responses/<responseId>', deleteMyVacancyResponse);
    router.get('/api/jobs/employer-vacancy-responses', getEmployerVacancyResponses);
    // Вакансии (специфичные пути до параметризованных, иначе /favorites матчится как <id>)
    router.get('/api/jobs/vacancies', getVacancies);
    router.get('/api/jobs/vacancies/favorites', getFavoriteVacancies);
    router.get('/api/jobs/vacancies/<id>', getVacancyById);
    router.post('/api/jobs/vacancies', createVacancy);
    router.put('/api/jobs/vacancies/<id>', updateVacancy);
    router.post('/api/jobs/vacancies/<id>/additional-images', uploadVacancyAdditionalImages);
    router.post('/api/jobs/vacancies/<id>/publish', publishVacancy);
    router.post('/api/jobs/vacancies/<id>/unpublish', unpublishVacancy);
    router.post('/api/jobs/vacancies/<id>/responses', respondToVacancy);
    router.put('/api/jobs/vacancies/<id>/responses/<responseId>', updateVacancyResponse);
    router.get('/api/jobs/vacancies/<id>/responses', getVacancyResponses);
    router.post('/api/jobs/vacancies/<id>/favorite', addVacancyToFavorites);
    router.delete('/api/jobs/vacancies/<id>/favorite', removeVacancyFromFavorites);
    router.delete('/api/jobs/vacancies/<id>', deleteVacancy);

    // Профили контактов для вакансий
    router.get('/api/jobs/contact-profiles', getContactProfiles);
    router.post('/api/jobs/contact-profiles', createContactProfile);
    router.put('/api/jobs/contact-profiles/<id>', updateContactProfile);
    router.delete('/api/jobs/contact-profiles/<id>', deleteContactProfile);
    router.post('/api/jobs/contact-profiles/<id>/logo', uploadContactProfileLogo);
    router.post('/api/jobs/contact-profiles/<id>/additional-images', uploadContactProfileAdditionalImages);

    // Резюме (аналогично)
    router.get('/api/jobs/resumes', getResumes);
    router.get('/api/jobs/resumes/favorites', getFavoriteResumes);
    router.get('/api/jobs/resumes/<id>', getResumeById);
    router.post('/api/jobs/resumes', createResume);
    router.put('/api/jobs/resumes/<id>', updateResume);
    router.post('/api/jobs/resumes/<id>/photo', uploadResumePhoto);
    router.post('/api/jobs/resumes/<id>/additional-photos', uploadResumeAdditionalPhotos);
    router.delete('/api/jobs/resumes/<id>', deleteResume);
    router.post('/api/jobs/resumes/<id>/favorite', addResumeToFavorites);
    router.delete('/api/jobs/resumes/<id>/favorite', removeResumeFromFavorites);

    // Резюме: опыт и образование
    router.get('/api/jobs/resumes/<id>/experiences', getResumeExperiences);
    router.post('/api/jobs/resumes/<id>/experiences', createResumeExperience);
    router.put('/api/jobs/resumes/<id>/experiences/<experienceId>', updateResumeExperience);
    router.delete('/api/jobs/resumes/<id>/experiences/<experienceId>', deleteResumeExperience);

    router.get('/api/jobs/resumes/<id>/educations', getResumeEducations);
    router.post('/api/jobs/resumes/<id>/educations', createResumeEducation);
    router.put('/api/jobs/resumes/<id>/educations/<educationId>', updateResumeEducation);
    router.delete('/api/jobs/resumes/<id>/educations/<educationId>', deleteResumeEducation);

    return router;
  }

  // ============================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ============================================

  int? _getUserIdFromRequest(Request request) {
    try {
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        if (_tokenService.validateToken(token)) {
          final userIdStr = _tokenService.getUserIdFromToken(token);
          if (userIdStr != null && userIdStr.isNotEmpty) {
            return int.tryParse(userIdStr);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  int? _parseId(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Преобразует Map/List из репозитория (с DateTime из postgres) в вид, пригодный для jsonEncode.
  /// По аналогии с toJson() в моделях (market, on_the_way), где DateTime → toIso8601String().
  static Object? _toJsonEncodable(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _toJsonEncodable(v)));
    }
    if (value is List) return value.map(_toJsonEncodable).toList();
    if (value is num || value is bool || value is String) return value;
    return value.toString();
  }

  // ============================================
  // ВАКАНСИИ
  // ============================================

  Future<Response> getVacancies(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;

      final userId = _getUserIdFromRequest(request);
      final employerId = params['employer_id'] != null ? int.tryParse(params['employer_id']!) : null;
      final search = params['search'];
      // Фильтр "Город" на фронте сейчас отправляет параметр ?city=...
      // Здесь поддерживаем и старый (?address=...), и новый (?city=...) вариант.
      final address = params['address'] ?? params['city'];
      final experienceLevel = params['experience_level'];
      final employmentType = params['employment_type'];
      final schedule = params['schedule'];
      final salaryFrom = params['salary_from'] != null ? int.tryParse(params['salary_from']!) : null;
      final salaryTo = params['salary_to'] != null ? int.tryParse(params['salary_to']!) : null;
      // Для "моих" вакансий (employer_id = текущий пользователь) показываем и черновики/на модерации
      final isMyVacancies = userId != null && employerId == userId;
      final onlyPublished = params['include_inactive'] == 'true'
          ? false
          : !isMyVacancies;
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final vacancies = await _repository.getVacancies(
        employerId: employerId,
        currentUserId: userId,
        searchQuery: search,
        address: address,
        experienceLevel: experienceLevel,
        employmentType: employmentType,
        schedule: schedule,
        salaryFrom: salaryFrom,
        salaryTo: salaryTo,
        onlyPublished: onlyPublished,
        limit: limit,
        offset: offset,
      );

      return Response.ok(jsonEncode(_toJsonEncodable(vacancies)), headers: jsonContentHeaders);
    });
  }

  Future<Response> getVacancyById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final userId = _getUserIdFromRequest(request);
      final vacancy = await _repository.getVacancyById(id, currentUserId: userId);
      if (vacancy == null) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }

      await _repository.incrementVacancyViews(id);

      return Response.ok(jsonEncode(_toJsonEncodable(vacancy)), headers: jsonContentHeaders);
    });
  }

  Future<Response> createVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final title = body['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Title is required'}), headers: jsonContentHeaders);
      }

      final contactProfileId = _parseId('${body['contact_profile_id']}');
      if (contactProfileId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'contact_profile_id is required'}),
          headers: jsonContentHeaders,
        );
      }

      List<String>? skills;
      if (body['skills'] is List) {
        skills = (body['skills'] as List).map((e) => e.toString()).toList();
      }
      final rawIsPublished = body['is_published'];
      final isPublished = rawIsPublished == null
          ? true
          : (rawIsPublished is bool ? rawIsPublished : rawIsPublished.toString().toLowerCase() == 'true');
      final vacancy = await _repository.createVacancy(
        employerId: userId,
        title: title.trim(),
        contactProfileId: contactProfileId,
        description: body['description'] as String?,
        responsibilities: body['responsibilities'] as String?,
        requirements: body['requirements'] as String?,
        conditions: body['conditions'] as String?,
        salaryFrom: body['salary_from'] is int ? body['salary_from'] as int : (body['salary_from'] is num ? (body['salary_from'] as num).toInt() : int.tryParse('${body['salary_from']}')),
        salaryTo: body['salary_to'] is int ? body['salary_to'] as int : (body['salary_to'] is num ? (body['salary_to'] as num).toInt() : int.tryParse('${body['salary_to']}')),
        currency: (body['currency'] as String?) ?? 'RUB',
        isGross: body['is_gross'] as bool?,
        employmentType: body['employment_type'] as String?,
        schedule: body['schedule'] as String?,
        experienceLevel: body['experience_level'] as String?,
        educationLevel: body['education_level'] as String?,
        employmentForm: body['employment_form'] as String?,
        workHours: body['work_hours'] as String?,
        relocationAllowed: body['relocation_allowed'] as bool?,
        businessTrips: body['business_trips'] as String?,
        aircraftCategory: body['aircraft_category'] as String?,
        requiredLicense: body['required_license'] as String?,
        minFlightHours: body['min_flight_hours'] is int
            ? body['min_flight_hours'] as int
            : (body['min_flight_hours'] is num ? (body['min_flight_hours'] as num).toInt() : int.tryParse('${body['min_flight_hours']}')),
        requiredTypeRating: body['required_type_rating'] as String?,
        skills: skills,
        isPublished: isPublished,
      );

      // Уведомление в Telegram-канал о новой вакансии
      try {
        final fullVacancy = await _repository.getVacancyById(vacancy['id'] as int);
        if (fullVacancy != null) {
          final empFirstName = fullVacancy['employer_first_name'] as String?;
          final empLastName = fullVacancy['employer_last_name'] as String?;
          final employerName = '${empFirstName ?? ''} ${empLastName ?? ''}'.trim();
          await TelegramBotService().notifyVacancyCreated(
            vacancyId: vacancy['id'] as int,
            employerId: userId,
            employerName: employerName.isNotEmpty ? employerName : null,
            employerPhone: fullVacancy['employer_phone'] as String?,
            title: fullVacancy['title'] as String? ?? title.trim(),
            companyName: fullVacancy['company_name'] as String?,
            address: fullVacancy['address'] as String?,
          );
        }
      } catch (_) {}

      return Response.ok(jsonEncode(_toJsonEncodable(vacancy)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      List<String>? skills;
      if (body['skills'] is List) {
        skills = (body['skills'] as List).map((e) => e.toString()).toList();
      }
      bool? isPublished;
      if (body['is_published'] != null) {
        final v = body['is_published'];
        isPublished = v is bool ? v : v.toString().toLowerCase() == 'true';
      }

      final updated = await _repository.updateVacancy(
        vacancyId: id,
        employerId: userId,
        title: body['title'] as String?,
        contactProfileId: _parseId('${body['contact_profile_id']}'),
        description: body['description'] as String?,
        responsibilities: body['responsibilities'] as String?,
        requirements: body['requirements'] as String?,
        conditions: body['conditions'] as String?,
        salaryFrom: body['salary_from'] != null
            ? (body['salary_from'] is int
                ? body['salary_from'] as int
                : (body['salary_from'] is num ? (body['salary_from'] as num).toInt() : int.tryParse('${body['salary_from']}')))
            : null,
        salaryTo: body['salary_to'] != null
            ? (body['salary_to'] is int
                ? body['salary_to'] as int
                : (body['salary_to'] is num ? (body['salary_to'] as num).toInt() : int.tryParse('${body['salary_to']}')))
            : null,
        currency: body['currency'] as String?,
        isGross: body['is_gross'] as bool?,
        employmentType: body['employment_type'] as String?,
        schedule: body['schedule'] as String?,
        experienceLevel: body['experience_level'] as String?,
        educationLevel: body['education_level'] as String?,
        employmentForm: body['employment_form'] as String?,
        workHours: body['work_hours'] as String?,
        relocationAllowed: body['relocation_allowed'] as bool?,
        businessTrips: body['business_trips'] as String?,
        aircraftCategory: body['aircraft_category'] as String?,
        requiredLicense: body['required_license'] as String?,
        minFlightHours: body['min_flight_hours'] != null
            ? (body['min_flight_hours'] is int
                ? body['min_flight_hours'] as int
                : (body['min_flight_hours'] is num ? (body['min_flight_hours'] as num).toInt() : int.tryParse('${body['min_flight_hours']}')))
            : null,
        requiredTypeRating: body['required_type_rating'] as String?,
        skills: skills,
        isPublished: isPublished,
        additionalImageUrls: body['additional_image_urls'] is List
            ? List<String>.from(body['additional_image_urls'] as List)
            : null,
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> publishVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final vacancy = await _repository.publishVacancy(vacancyId: id, employerId: userId);
      if (vacancy == null) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(vacancy)), headers: jsonContentHeaders);
    });
  }

  Future<Response> unpublishVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final vacancy = await _repository.unpublishVacancy(vacancyId: id, employerId: userId);
      if (vacancy == null) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(vacancy)), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deleteVacancy(vacancyId: id, employerId: userId);
      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Vacancy deleted successfully'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> respondToVacancy(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      final body = bodyStr.isNotEmpty ? jsonDecode(bodyStr) as Map<String, dynamic> : <String, dynamic>{};
      final resumeId = body['resume_id'] != null
          ? (body['resume_id'] is int ? body['resume_id'] as int : int.tryParse('${body['resume_id']}'))
          : null;
      final coverLetter = body['cover_letter'] as String?;

      final response = await _repository.respondToVacancy(
        vacancyId: id,
        candidateId: userId,
        resumeId: resumeId,
        coverLetter: coverLetter,
      );

      // Push-уведомление работодателю о новом отклике
      try {
        final vacancy = await _repository.getVacancyById(id);
        if (vacancy != null) {
          final employerId = vacancy['employer_id'] as int?;
          final vacancyTitle = vacancy['title'] as String? ?? '';
          if (employerId != null) {
            final tokensList = await _profileRepository.getAllFcmTokens(employerId);
            final tokens = tokensList.map((m) => m['fcm_token'] as String).where((t) => t.isNotEmpty).toList();
            if (tokens.isNotEmpty) {
              await FcmService().sendNotificationToAllUserTokens(
                fcmTokens: tokens,
                title: '📩 Новый отклик на вакансию',
                body: 'По вакансии «$vacancyTitle» поступил новый отклик',
                data: {
                  'type': 'vacancy_new_response',
                  'vacancy_id': id.toString(),
                  'screen': 'employer_vacancy_responses',
                },
              );
            }
          }
        }
      } catch (_) {}

      return Response.ok(jsonEncode(_toJsonEncodable(response)), headers: jsonContentHeaders);
    });
  }

  Future<Response> getMyVacancyResponses(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }
      final responses = await _repository.getMyVacancyResponses(userId);
      return Response.ok(jsonEncode(_toJsonEncodable(responses)), headers: jsonContentHeaders);
    });
  }

  Future<Response> getEmployerVacancyResponses(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }
      final responses = await _repository.getEmployerVacancyResponses(userId);
      return Response.ok(jsonEncode(_toJsonEncodable(responses)), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteMyVacancyResponse(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }
      final responseIdStr = request.params['responseId'];
      final responseId = _parseId(responseIdStr);
      if (responseId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid response ID'}),
          headers: jsonContentHeaders,
        );
      }
      final deleted = await _repository.deleteMyVacancyResponse(responseId: responseId, candidateId: userId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'error': 'Response not found or you are not the owner of this response'}),
          headers: jsonContentHeaders,
        );
      }
      return Response.ok(jsonEncode({'message': 'Response deleted'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> getVacancyResponses(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      // TODO: при необходимости добавить проверку, что userId = employer_id или админ
      final responses = await _repository.getVacancyResponses(id);
      return Response.ok(jsonEncode(_toJsonEncodable(responses)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateVacancyResponse(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final vacancyIdStr = request.params['id'];
      final responseIdStr = request.params['responseId'];
      final vacancyId = _parseId(vacancyIdStr);
      final responseId = _parseId(responseIdStr);
      if (vacancyId == null || responseId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid vacancy ID or response ID'}),
          headers: jsonContentHeaders,
        );
      }

      final bodyStr = await request.readAsString();
      final body = bodyStr.isNotEmpty ? jsonDecode(bodyStr) as Map<String, dynamic> : <String, dynamic>{};
      final status = body['status'] as String?;
      if (status == null || status.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'status is required (in_progress, rejected, accepted)'}),
          headers: jsonContentHeaders,
        );
      }
      final employerComment = body['employer_comment'] as String?;

      final updated = await _repository.updateVacancyResponseStatus(
        vacancyId: vacancyId,
        responseId: responseId,
        status: status.trim(),
        employerId: userId,
        employerComment: employerComment,
      );
      if (updated == null) {
        return Response.notFound(
          jsonEncode({'error': 'Response not found or you are not the employer of this vacancy'}),
          headers: jsonContentHeaders,
        );
      }

      // Push-уведомление кандидату об ответе на отклик
      try {
        final candidateId = updated['candidate_id'] as int?;
        final vacancy = await _repository.getVacancyById(vacancyId);
        final vacancyTitle = vacancy?['title'] as String? ?? '';
        if (candidateId != null && vacancyTitle.isNotEmpty) {
          final tokensList = await _profileRepository.getAllFcmTokens(candidateId);
          final tokens = tokensList.map((m) => m['fcm_token'] as String).where((t) => t.isNotEmpty).toList();
          if (tokens.isNotEmpty) {
            await FcmService().sendNotificationToAllUserTokens(
              fcmTokens: tokens,
              title: '💬 Ответ на ваш отклик',
              body: 'Работодатель ответил на ваш отклик по вакансии «$vacancyTitle»',
              data: {
                'type': 'vacancy_response_reply',
                'vacancy_id': vacancyId.toString(),
                'screen': 'my_vacancy_responses',
              },
            );
          }
        }
      } catch (_) {}

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> addVacancyToFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      await _repository.addVacancyToFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Vacancy added to favorites'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> removeVacancyFromFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      await _repository.removeVacancyFromFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Vacancy removed from favorites'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> getFavoriteVacancies(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final params = request.url.queryParameters;
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final vacancies = await _repository.getFavoriteVacancies(userId, limit: limit, offset: offset);
      return Response.ok(jsonEncode(_toJsonEncodable(vacancies)), headers: jsonContentHeaders);
    });
  }

  // ============================================
  // ПРОФИЛИ КОНТАКТОВ ДЛЯ ВАКАНСИЙ
  // ============================================

  Future<Response> getContactProfiles(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final profiles = await _repository.getContactProfiles(userId);
      return Response.ok(jsonEncode(_toJsonEncodable(profiles)), headers: jsonContentHeaders);
    });
  }

  Future<Response> createContactProfile(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final isPrivate = body['is_private'] == true;
      final companyName = (body['company_name'] as String?)?.trim();
      final contactName = (body['contact_name'] as String?)?.trim();
      final contactPosition = (body['contact_position'] as String?)?.trim();
      final contactPhone = (body['contact_phone'] as String?)?.trim();
      final additionalImageUrls = body['additional_image_urls'] is List
          ? List<String>.from(body['additional_image_urls'] as List)
          : null;

      if (!isPrivate && (companyName == null || companyName.isEmpty)) {
        return Response.badRequest(
          body: jsonEncode({'error': 'company_name is required'}),
          headers: jsonContentHeaders,
        );
      }
      if (contactName == null || contactName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'contact_name is required'}),
          headers: jsonContentHeaders,
        );
      }
      if (contactPosition == null || contactPosition.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'contact_position is required'}),
          headers: jsonContentHeaders,
        );
      }
      if (contactPhone == null || contactPhone.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'contact_phone is required'}),
          headers: jsonContentHeaders,
        );
      }

      final profile = await _repository.createContactProfile(
        ownerId: userId,
        isPrivate: isPrivate,
        companyName: isPrivate ? null : companyName,
        inn: isPrivate ? null : (body['inn'] as String?)?.trim(),
        address: (body['address'] as String?)?.trim(),
        logoUrl: (body['logo_url'] as String?)?.trim(),
        additionalImageUrls: additionalImageUrls,
        contactName: contactName,
        contactPosition: contactPosition,
        contactPhone: contactPhone,
        contactPhoneAlt: (body['contact_phone_alt'] as String?)?.trim(),
        contactTelegram: (body['contact_telegram'] as String?)?.trim(),
        contactWhatsapp: (body['contact_whatsapp'] as String?)?.trim(),
        contactMax: (body['contact_max'] as String?)?.trim(),
        contactEmail: (body['contact_email'] as String?)?.trim(),
        contactSite: (body['contact_site'] as String?)?.trim(),
      );

      return Response.ok(jsonEncode(_toJsonEncodable(profile)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateContactProfile(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid contact profile ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final updated = await _repository.updateContactProfile(
        ownerId: userId,
        profileId: id,
        isPrivate: body['is_private'] as bool?,
        companyName: (body['company_name'] as String?)?.trim(),
        inn: (body['inn'] as String?)?.trim(),
        address: (body['address'] as String?)?.trim(),
        logoUrl: (body['logo_url'] as String?)?.trim(),
        additionalImageUrls: body['additional_image_urls'] is List
            ? List<String>.from(body['additional_image_urls'] as List)
            : null,
        contactName: (body['contact_name'] as String?)?.trim(),
        contactPosition: (body['contact_position'] as String?)?.trim(),
        contactPhone: (body['contact_phone'] as String?)?.trim(),
        contactPhoneAlt: (body['contact_phone_alt'] as String?)?.trim(),
        contactTelegram: (body['contact_telegram'] as String?)?.trim(),
        contactWhatsapp: (body['contact_whatsapp'] as String?)?.trim(),
        contactMax: (body['contact_max'] as String?)?.trim(),
        contactEmail: (body['contact_email'] as String?)?.trim(),
        contactSite: (body['contact_site'] as String?)?.trim(),
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Contact profile not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteContactProfile(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid contact profile ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deleteContactProfile(ownerId: userId, profileId: id);
      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Contact profile not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Contact profile deleted successfully'}), headers: jsonContentHeaders);
    });
  }

  int _indexOfBytes(List<int> haystack, List<int> needle, int start) {
    for (int i = start; i <= haystack.length - needle.length; i++) {
      bool found = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  Map<String, dynamic>? _parseMultipartPart(List<int> partBytes) {
    // Ищем разделитель заголовков
    final headerEndIndex = _indexOfBytes(partBytes, [13, 10, 13, 10], 0);
    if (headerEndIndex == -1) return null;

    final headerBytes = partBytes.sublist(0, headerEndIndex);
    final dataBytes = partBytes.sublist(headerEndIndex + 4);

    final headers = <String, String>{};
    final headerLines = utf8.decode(headerBytes).split('\r\n');
    for (final line in headerLines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        headers[parts[0].toLowerCase()] = parts.sublist(1).join(':').trim();
      }
    }

    return {
      'content-disposition': headers['content-disposition'],
      'content-type': headers['content-type'],
      'data': dataBytes,
    };
  }

  Future<Response> uploadContactProfileLogo(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid contact profile ID'}), headers: jsonContentHeaders);
      }

      final profile = await _repository.getContactProfileById(id);
      if (profile == null) {
        return Response.notFound(jsonEncode({'error': 'Contact profile not found'}), headers: jsonContentHeaders);
      }

      final ownerId = profile['owner_id'] as int?;
      if (ownerId == null || ownerId != userId) {
        return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload images for this profile'}), headers: jsonContentHeaders);
      }

      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
      }

      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      String? imageUrl;
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final jobsDir = Directory('public/jobs');
      if (!await jobsDir.exists()) {
        await jobsDir.create(recursive: true);
      }

      final profilesDir = Directory('public/jobs/contact-profiles');
      if (!await profilesDir.exists()) {
        await profilesDir.create(recursive: true);
      }

      final profileDir = Directory('public/jobs/contact-profiles/$id');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?image').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
        }

        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          } else if (partMediaType.subtype == 'webp') {
            extension = 'webp';
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'logo.$timestamp.$random.$extension';
        final filePath = 'public/jobs/contact-profiles/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrl = 'jobs/contact-profiles/$id/$fileName';
        break;
      }

      if (imageUrl == null) {
        return Response.badRequest(body: jsonEncode({'error': 'No image provided'}), headers: jsonContentHeaders);
      }

      final updated = await _repository.updateContactProfile(
        ownerId: userId,
        profileId: id,
        logoUrl: imageUrl,
      );

      if (updated == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update contact profile'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'url': imageUrl}), headers: jsonContentHeaders);
    });
  }

  Future<Response> uploadContactProfileAdditionalImages(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid contact profile ID'}), headers: jsonContentHeaders);
      }

      final profile = await _repository.getContactProfileById(id);
      if (profile == null) {
        return Response.notFound(jsonEncode({'error': 'Contact profile not found'}), headers: jsonContentHeaders);
      }

      final ownerId = profile['owner_id'] as int?;
      if (ownerId == null || ownerId != userId) {
        return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload images for this profile'}), headers: jsonContentHeaders);
      }

      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
      }

      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      final imageUrls = <String>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final jobsDir = Directory('public/jobs');
      if (!await jobsDir.exists()) {
        await jobsDir.create(recursive: true);
      }

      final profilesDir = Directory('public/jobs/contact-profiles');
      if (!await profilesDir.exists()) {
        await profilesDir.create(recursive: true);
      }

      final profileDir = Directory('public/jobs/contact-profiles/$id');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?images').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
        }

        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          final subtype = partMediaType.subtype;
          if (subtype == 'jpeg' || subtype == 'jpg') {
            extension = 'jpg';
          } else if (subtype == 'png') {
            extension = 'png';
          } else if (subtype == 'webp') {
            extension = 'webp';
          } else if (subtype == 'pdf') {
            extension = 'pdf';
          } else if (subtype == 'msword') {
            extension = 'doc';
          } else if (subtype == 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
            extension = 'docx';
          } else if (subtype == 'vnd.ms-excel') {
            extension = 'xls';
          } else if (subtype == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
            extension = 'xlsx';
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'additional.$timestamp.$random.$extension';
        final filePath = 'public/jobs/contact-profiles/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrls.add('jobs/contact-profiles/$id/$fileName');
      }

      if (imageUrls.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'No files provided'}), headers: jsonContentHeaders);
      }

      final existingRaw = profile['additional_image_urls'];
      final existingUrls = <String>[];
      if (existingRaw is String && existingRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingRaw);
          if (decoded is List) {
            existingUrls.addAll(decoded.map((e) => e.toString()));
          }
        } catch (_) {}
      } else if (existingRaw is List) {
        existingUrls.addAll(existingRaw.map((e) => e.toString()));
      }

      final updatedUrls = [...existingUrls, ...imageUrls];
      final updated = await _repository.updateContactProfile(
        ownerId: userId,
        profileId: id,
        additionalImageUrls: updatedUrls,
      );

      if (updated == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update contact profile'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'urls': imageUrls}), headers: jsonContentHeaders);
    });
  }

  // ============================================
  // РЕЗЮМЕ
  // ============================================

  Future<Response> getResumes(Request request) async {
    return wrapResponse(() async {
      final params = request.url.queryParameters;
      final userIdFilter = params['user_id'] != null ? int.tryParse(params['user_id']!) : null;
      final search = params['search'];
      final address = params['address'];
      final licenseFilter = params['license'];
      final aircraftTypeFilter = params['aircraft_type'];
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final resumes = await _repository.getResumes(
        userId: userIdFilter,
        searchQuery: search,
        address: address,
        licenseFilter: licenseFilter,
        aircraftTypeFilter: aircraftTypeFilter,
        limit: limit,
        offset: offset,
      );

      return Response.ok(jsonEncode(_toJsonEncodable(resumes)), headers: jsonContentHeaders);
    });
  }

  Future<Response> getResumeById(Request request) async {
    return wrapResponse(() async {
      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final resume = await _repository.getResumeById(id);
      if (resume == null) {
        return Response.notFound(jsonEncode({'error': 'Resume not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(resume)), headers: jsonContentHeaders);
    });
  }

  Future<Response> createResume(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final title = body['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Title is required'}), headers: jsonContentHeaders);
      }

      final desiredSalary = body['desired_salary'] != null
          ? (body['desired_salary'] is int
              ? body['desired_salary'] as int
              : (body['desired_salary'] is num ? (body['desired_salary'] as num).toInt() : int.tryParse('${body['desired_salary']}')))
          : null;

      DateTime? parseDate(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        try {
          return DateTime.parse(value.toString());
        } catch (_) {
          return null;
        }
      }

      List<String>? parseStringList(dynamic value) {
        if (value == null) return null;
        if (value is List) return value.map((e) => e.toString()).toList();
        return null;
      }

      final contactProfileId = _parseId('${body['contact_profile_id']}');
      if (contactProfileId != null) {
        final profile = await _repository.getContactProfileById(contactProfileId);
        if (profile == null || (profile['owner_id'] as int?) != userId) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid or unauthorized contact_profile_id'}),
            headers: jsonContentHeaders,
          );
        }
      }

      final rawVisible = body['is_visible_for_employers'];
      final isVisibleForEmployers = rawVisible == null
          ? true
          : (rawVisible is bool ? rawVisible : rawVisible.toString().toLowerCase() == 'true');

      final resume = await _repository.createResume(
        userId: userId,
        title: title.trim(),
        about: body['about'] as String?,
        desiredSalary: desiredSalary,
        currency: (body['currency'] as String?) ?? 'RUB',
        employmentTypes: body['employment_types'] as String?,
        schedules: body['schedules'] as String?,
        readyToRelocate: body['ready_to_relocate'] as bool?,
        readyForBusinessTrips: body['ready_for_business_trips'] as bool?,
        address: (body['address'] as String?)?.trim(),
        dateOfBirth: parseDate(body['date_of_birth']),
        citizenship: parseStringList(body['citizenship']),
        workPermit: body['work_permit'] as bool?,
        photoUrl: (body['photo_url'] as String?)?.trim(),
        additionalPhotoUrls: parseStringList(body['additional_photo_urls']),
        contactProfileId: contactProfileId,
        currentPosition: (body['current_position'] as String?)?.trim(),
        currentCompany: (body['current_company'] as String?)?.trim(),
        totalExperienceMonths: body['total_experience_months'] != null
            ? (body['total_experience_months'] is int
                ? body['total_experience_months'] as int
                : (body['total_experience_months'] is num
                    ? (body['total_experience_months'] as num).toInt()
                    : int.tryParse('${body['total_experience_months']}')))
            : null,
        flightHoursTotal: body['flight_hours_total'] != null
            ? (body['flight_hours_total'] is int
                ? body['flight_hours_total'] as int
                : (body['flight_hours_total'] is num ? (body['flight_hours_total'] as num).toInt() : int.tryParse('${body['flight_hours_total']}')))
            : null,
        flightHoursPic: body['flight_hours_pic'] != null
            ? (body['flight_hours_pic'] is int
                ? body['flight_hours_pic'] as int
                : (body['flight_hours_pic'] is num ? (body['flight_hours_pic'] as num).toInt() : int.tryParse('${body['flight_hours_pic']}')))
            : null,
        licenses: body['licenses'] as String?,
        typeRatings: body['type_ratings'] as String?,
        medicalClass: body['medical_class'] as String?,
        isVisibleForEmployers: isVisibleForEmployers,
      );

      // Уведомление в Telegram-канал о новом резюме
      try {
        final fullResume = await _repository.getResumeById(resume['id'] as int);
        if (fullResume != null) {
          final contactName = fullResume['contact_name'] as String?;
          final contactPhone = fullResume['contact_phone'] as String? ?? fullResume['user_phone'] as String?;
          await TelegramBotService().notifyResumeCreated(
            resumeId: resume['id'] as int,
            userId: userId,
            contactName: contactName?.trim().isNotEmpty == true ? contactName : null,
            contactPhone: contactPhone?.trim().isNotEmpty == true ? contactPhone : null,
            title: fullResume['title'] as String? ?? title.trim(),
            currentPosition: fullResume['current_position'] as String?,
            desiredSalary: fullResume['desired_salary'] is int ? fullResume['desired_salary'] as int : (fullResume['desired_salary'] is num ? (fullResume['desired_salary'] as num).toInt() : null),
            currency: fullResume['currency'] as String?,
          );
        }
      } catch (_) {}

      return Response.ok(jsonEncode(_toJsonEncodable(resume)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateResume(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final desiredSalary = body['desired_salary'] != null
          ? (body['desired_salary'] is int
              ? body['desired_salary'] as int
              : (body['desired_salary'] is num ? (body['desired_salary'] as num).toInt() : int.tryParse('${body['desired_salary']}')))
          : null;

      DateTime? parseDate(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        try {
          return DateTime.parse(value.toString());
        } catch (_) {
          return null;
        }
      }

      List<String>? parseStringList(dynamic value) {
        if (value == null) return null;
        if (value is List) return value.map((e) => e.toString()).toList();
        return null;
      }

      final hasContactProfileKey = body.containsKey('contact_profile_id');
      final contactProfileId = hasContactProfileKey ? _parseId('${body['contact_profile_id']}') : null;
      final clearContactProfileId = hasContactProfileKey && body['contact_profile_id'] == null;
      if (contactProfileId != null) {
        final profile = await _repository.getContactProfileById(contactProfileId);
        if (profile == null || (profile['owner_id'] as int?) != userId) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid or unauthorized contact_profile_id'}),
            headers: jsonContentHeaders,
          );
        }
      }

      final updated = await _repository.updateResume(
        resumeId: id,
        userId: userId,
        title: (body['title'] as String?)?.trim(),
        about: body['about'] as String?,
        desiredSalary: desiredSalary,
        currency: body['currency'] as String?,
        employmentTypes: body['employment_types'] as String?,
        schedules: body['schedules'] as String?,
        readyToRelocate: body['ready_to_relocate'] as bool?,
        readyForBusinessTrips: body['ready_for_business_trips'] as bool?,
        address: (body['address'] as String?)?.trim(),
        dateOfBirth: parseDate(body['date_of_birth']),
        citizenship: parseStringList(body['citizenship']),
        workPermit: body['work_permit'] as bool?,
        photoUrl: (body['photo_url'] as String?)?.trim(),
        additionalPhotoUrls: parseStringList(body['additional_photo_urls']),
        contactProfileId: contactProfileId,
        clearContactProfileId: clearContactProfileId,
        currentPosition: (body['current_position'] as String?)?.trim(),
        currentCompany: (body['current_company'] as String?)?.trim(),
        totalExperienceMonths: body['total_experience_months'] != null
            ? (body['total_experience_months'] is int
                ? body['total_experience_months'] as int
                : (body['total_experience_months'] is num
                    ? (body['total_experience_months'] as num).toInt()
                    : int.tryParse('${body['total_experience_months']}')))
            : null,
        flightHoursTotal: body['flight_hours_total'] != null
            ? (body['flight_hours_total'] is int
                ? body['flight_hours_total'] as int
                : (body['flight_hours_total'] is num
                    ? (body['flight_hours_total'] as num).toInt()
                    : int.tryParse('${body['flight_hours_total']}')))
            : null,
        flightHoursPic: body['flight_hours_pic'] != null
            ? (body['flight_hours_pic'] is int
                ? body['flight_hours_pic'] as int
                : (body['flight_hours_pic'] is num
                    ? (body['flight_hours_pic'] as num).toInt()
                    : int.tryParse('${body['flight_hours_pic']}')))
            : null,
        licenses: body['licenses'] as String?,
        typeRatings: body['type_ratings'] as String?,
        medicalClass: body['medical_class'] as String?,
        status: body['status'] as String?,
        isVisibleForEmployers: body['is_visible_for_employers'] as bool?,
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Resume not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> uploadResumePhoto(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final resume = await _repository.getResumeById(id);
      if (resume == null) {
        return Response.notFound(jsonEncode({'error': 'Resume not found'}), headers: jsonContentHeaders);
      }
      final ownerId = resume['user_id'] as int?;
      if (ownerId == null || ownerId != userId) {
        return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload photos for this resume'}), headers: jsonContentHeaders);
      }

      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
      }

      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      String? imageUrl;
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final jobsDir = Directory('public/jobs');
      if (!await jobsDir.exists()) {
        await jobsDir.create(recursive: true);
      }

      final resumesDir = Directory('public/jobs/resumes');
      if (!await resumesDir.exists()) {
        await resumesDir.create(recursive: true);
      }

      final resumeDir = Directory('public/jobs/resumes/$id');
      if (!await resumeDir.exists()) {
        await resumeDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?image').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
        }

        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          if (partMediaType.subtype == 'jpeg' || partMediaType.subtype == 'jpg') {
            extension = 'jpg';
          } else if (partMediaType.subtype == 'png') {
            extension = 'png';
          } else if (partMediaType.subtype == 'webp') {
            extension = 'webp';
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'photo.$timestamp.$random.$extension';
        final filePath = 'public/jobs/resumes/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrl = 'jobs/resumes/$id/$fileName';
        break;
      }

      if (imageUrl == null) {
        return Response.badRequest(body: jsonEncode({'error': 'No image provided'}), headers: jsonContentHeaders);
      }

      final updated = await _repository.updateResume(
        resumeId: id,
        userId: userId,
        photoUrl: imageUrl,
      );

      if (updated == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update resume'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'url': imageUrl}), headers: jsonContentHeaders);
    });
  }

  Future<Response> uploadResumeAdditionalPhotos(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final resume = await _repository.getResumeById(id);
      if (resume == null) {
        return Response.notFound(jsonEncode({'error': 'Resume not found'}), headers: jsonContentHeaders);
      }
      final ownerId = resume['user_id'] as int?;
      if (ownerId == null || ownerId != userId) {
        return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload photos for this resume'}), headers: jsonContentHeaders);
      }

      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
      }

      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;

        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;

        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;

        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) {
            parts.add(partData);
          }
        }

        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      final imageUrls = <String>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      final jobsDir = Directory('public/jobs');
      if (!await jobsDir.exists()) {
        await jobsDir.create(recursive: true);
      }

      final resumesDir = Directory('public/jobs/resumes');
      if (!await resumesDir.exists()) {
        await resumesDir.create(recursive: true);
      }

      final resumeDir = Directory('public/jobs/resumes/$id');
      if (!await resumeDir.exists()) {
        await resumeDir.create(recursive: true);
      }

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;

        final isImageField = RegExp('name=["\']?images').hasMatch(contentDisposition);
        if (!isImageField) continue;

        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;

        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
        }

        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          final subtype = partMediaType.subtype;
          if (subtype == 'jpeg' || subtype == 'jpg') {
            extension = 'jpg';
          } else if (subtype == 'png') {
            extension = 'png';
          } else if (subtype == 'webp') {
            extension = 'webp';
          } else if (subtype == 'pdf') {
            extension = 'pdf';
          } else if (subtype == 'msword') {
            extension = 'doc';
          } else if (subtype == 'vnd.openxmlformats-officedocument.wordprocessingml.document') {
            extension = 'docx';
          } else if (subtype == 'vnd.ms-excel') {
            extension = 'xls';
          } else if (subtype == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
            extension = 'xlsx';
          }
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'additional.$timestamp.$random.$extension';
        final filePath = 'public/jobs/resumes/$id/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(imageData);

        imageUrls.add('jobs/resumes/$id/$fileName');
      }

      if (imageUrls.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'No files provided'}), headers: jsonContentHeaders);
      }

      final existingRaw = resume['additional_photo_urls'];
      final existingUrls = <String>[];
      if (existingRaw is String && existingRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingRaw);
          if (decoded is List) {
            existingUrls.addAll(decoded.map((e) => e.toString()));
          }
        } catch (_) {}
      } else if (existingRaw is List) {
        existingUrls.addAll(existingRaw.map((e) => e.toString()));
      }

      final updatedUrls = [...existingUrls, ...imageUrls];
      final updated = await _repository.updateResume(
        resumeId: id,
        userId: userId,
        additionalPhotoUrls: updatedUrls,
      );

      if (updated == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update resume'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'urls': imageUrls}), headers: jsonContentHeaders);
    });
  }

  Future<Response> uploadVacancyAdditionalImages(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid vacancy ID'}), headers: jsonContentHeaders);
      }

      final vacancy = await _repository.getVacancyById(id);
      if (vacancy == null) {
        return Response.notFound(jsonEncode({'error': 'Vacancy not found'}), headers: jsonContentHeaders);
      }
      final employerId = vacancy['employer_id'] as int?;
      if (employerId == null || employerId != userId) {
        return Response.forbidden(jsonEncode({'error': 'You do not have permission to upload files for this vacancy'}), headers: jsonContentHeaders);
      }

      final contentType = request.headers['Content-Type'];
      if (contentType == null || !contentType.startsWith('multipart/form-data')) {
        return Response.badRequest(body: jsonEncode({'error': 'Content-Type must be multipart/form-data'}), headers: jsonContentHeaders);
      }

      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Missing boundary in Content-Type'}), headers: jsonContentHeaders);
      }

      final bodyBytes = <int>[];
      await for (final chunk in request.read()) {
        bodyBytes.addAll(chunk);
      }

      final boundaryMarker = '--$boundary';
      final boundaryBytes = utf8.encode(boundaryMarker);
      final parts = <Map<String, dynamic>>[];

      int searchStart = 0;
      while (true) {
        final boundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        if (boundaryIndex == -1) break;
        searchStart = boundaryIndex + boundaryBytes.length;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 13) searchStart++;
        if (searchStart < bodyBytes.length && bodyBytes[searchStart] == 10) searchStart++;
        final nextBoundaryIndex = _indexOfBytes(bodyBytes, boundaryBytes, searchStart);
        final partEnd = nextBoundaryIndex == -1 ? bodyBytes.length : nextBoundaryIndex;
        if (partEnd > searchStart) {
          final partBytes = bodyBytes.sublist(searchStart, partEnd);
          final partData = _parseMultipartPart(partBytes);
          if (partData != null) parts.add(partData);
        }
        if (nextBoundaryIndex == -1) break;
        searchStart = nextBoundaryIndex;
      }

      final imageUrls = <String>[];
      final publicDir = Directory('public');
      if (!await publicDir.exists()) await publicDir.create(recursive: true);
      final jobsDir = Directory('public/jobs');
      if (!await jobsDir.exists()) await jobsDir.create(recursive: true);
      final vacanciesDir = Directory('public/jobs/vacancies');
      if (!await vacanciesDir.exists()) await vacanciesDir.create(recursive: true);
      final vacancyDir = Directory('public/jobs/vacancies/$id');
      if (!await vacancyDir.exists()) await vacancyDir.create(recursive: true);

      for (final part in parts) {
        final contentDisposition = part['content-disposition'] as String?;
        if (contentDisposition == null) continue;
        if (!RegExp('name=["\']?images').hasMatch(contentDisposition)) continue;
        final imageData = part['data'] as List<int>?;
        if (imageData == null || imageData.isEmpty) continue;
        if (imageData.length > 5 * 1024 * 1024) {
          return Response.badRequest(body: jsonEncode({'error': 'File size exceeds 5MB limit'}), headers: jsonContentHeaders);
        }
        String extension = 'jpg';
        final partContentType = part['content-type'] as String?;
        if (partContentType != null) {
          final partMediaType = MediaType.parse(partContentType);
          final subtype = partMediaType.subtype;
          if (subtype == 'jpeg' || subtype == 'jpg') extension = 'jpg';
          else if (subtype == 'png') extension = 'png';
          else if (subtype == 'webp') extension = 'webp';
          else if (subtype == 'pdf') extension = 'pdf';
          else if (subtype == 'msword') extension = 'doc';
          else if (subtype == 'vnd.openxmlformats-officedocument.wordprocessingml.document') extension = 'docx';
          else if (subtype == 'vnd.ms-excel') extension = 'xls';
          else if (subtype == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet') extension = 'xlsx';
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 1000000;
        final fileName = 'additional.$timestamp.$random.$extension';
        final file = File('public/jobs/vacancies/$id/$fileName');
        await file.writeAsBytes(imageData);
        imageUrls.add('jobs/vacancies/$id/$fileName');
      }

      if (imageUrls.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'No files provided'}), headers: jsonContentHeaders);
      }

      final existingRaw = vacancy['additional_image_urls'];
      final existingUrls = <String>[];
      if (existingRaw is String && existingRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingRaw);
          if (decoded is List) existingUrls.addAll(decoded.map((e) => e.toString()));
        } catch (_) {}
      } else if (existingRaw is List) {
        existingUrls.addAll(existingRaw.map((e) => e.toString()));
      }

      final updatedUrls = [...existingUrls, ...imageUrls];
      final updated = await _repository.updateVacancy(
        vacancyId: id,
        employerId: userId,
        additionalImageUrls: updatedUrls,
      );

      if (updated == null) {
        return Response.internalServerError(body: jsonEncode({'error': 'Failed to update vacancy'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'urls': imageUrls}), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteResume(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deleteResume(resumeId: id, userId: userId);
      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Resume not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Resume deleted successfully'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> addResumeToFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      await _repository.addResumeToFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Resume added to favorites'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> removeResumeFromFavorites(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final idStr = request.params['id'];
      final id = _parseId(idStr);
      if (id == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      await _repository.removeResumeFromFavorites(userId, id);
      return Response.ok(jsonEncode({'message': 'Resume removed from favorites'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> getFavoriteResumes(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final params = request.url.queryParameters;
      final limit = params['limit'] != null ? int.tryParse(params['limit']!) ?? 20 : 20;
      final offset = params['offset'] != null ? int.tryParse(params['offset']!) ?? 0 : 0;

      final resumes = await _repository.getFavoriteResumes(userId, limit: limit, offset: offset);
      return Response.ok(jsonEncode(_toJsonEncodable(resumes)), headers: jsonContentHeaders);
    });
  }

  // ============================================
  // РЕЗЮМЕ: ОПЫТ И ОБРАЗОВАНИЕ
  // ============================================

  Future<Response> getResumeExperiences(Request request) async {
    return wrapResponse(() async {
      // Просмотр опыта должен быть доступен и без авторизации (работодатель может смотреть резюме по отклику,
      // а резюме в целом открывается без токена). userId используем опционально, если есть.
      final userId = _getUserIdFromRequest(request);

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      if (resumeId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final experiences = await _repository.getResumeExperiences(resumeId, userId: userId);
      return Response.ok(jsonEncode(_toJsonEncodable(experiences)), headers: jsonContentHeaders);
    });
  }

  Future<Response> createResumeExperience(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      if (resumeId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final companyName = body['company_name'] as String?;
      if (companyName == null || companyName.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'company_name is required'}),
          headers: jsonContentHeaders,
        );
      }

      DateTime? parseDate(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        try {
          return DateTime.parse(value.toString());
        } catch (_) {
          return null;
        }
      }

      final experience = await _repository.createResumeExperience(
        resumeId: resumeId,
        userId: userId,
        companyName: companyName.trim(),
        startDate: parseDate(body['start_date']),
        endDate: parseDate(body['end_date']),
        isCurrent: body['is_current'] as bool?,
        responsibilitiesAndAchievements: (body['responsibilities_and_achievements'] as String?)?.trim(),
      );

      return Response.ok(jsonEncode(_toJsonEncodable(experience)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateResumeExperience(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      final experienceIdStr = request.params['experienceId'];
      final experienceId = _parseId(experienceIdStr);
      if (resumeId == null || experienceId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume or experience ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      DateTime? parseDate(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        try {
          return DateTime.parse(value.toString());
        } catch (_) {
          return null;
        }
      }

      final updated = await _repository.updateResumeExperience(
        experienceId: experienceId,
        resumeId: resumeId,
        userId: userId,
        companyName: (body['company_name'] as String?)?.trim(),
        startDate: parseDate(body['start_date']),
        endDate: parseDate(body['end_date']),
        isCurrent: body['is_current'] as bool?,
        responsibilitiesAndAchievements: (body['responsibilities_and_achievements'] as String?)?.trim(),
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Experience not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteResumeExperience(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      final experienceIdStr = request.params['experienceId'];
      final experienceId = _parseId(experienceIdStr);
      if (resumeId == null || experienceId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume or experience ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deleteResumeExperience(
        experienceId: experienceId,
        resumeId: resumeId,
        userId: userId,
      );

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Experience not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Experience deleted successfully'}), headers: jsonContentHeaders);
    });
  }

  Future<Response> getResumeEducations(Request request) async {
    return wrapResponse(() async {
      // Просмотр образования также должен быть доступен без обязательной авторизации.
      final userId = _getUserIdFromRequest(request);

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      if (resumeId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final educations = await _repository.getResumeEducations(resumeId, userId: userId);
      return Response.ok(jsonEncode(_toJsonEncodable(educations)), headers: jsonContentHeaders);
    });
  }

  Future<Response> createResumeEducation(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      if (resumeId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      final institution = body['institution'] as String?;
      if (institution == null || institution.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'institution is required'}),
          headers: jsonContentHeaders,
        );
      }

      int? parseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        return int.tryParse(value.toString());
      }

      final education = await _repository.createResumeEducation(
        resumeId: resumeId,
        userId: userId,
        institution: institution.trim(),
        speciality: (body['speciality'] as String?)?.trim(),
        yearStart: parseInt(body['year_start']),
        yearEnd: parseInt(body['year_end']),
        isCurrent: body['is_current'] as bool?,
      );

      return Response.ok(jsonEncode(_toJsonEncodable(education)), headers: jsonContentHeaders);
    });
  }

  Future<Response> updateResumeEducation(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      final educationIdStr = request.params['educationId'];
      final educationId = _parseId(educationIdStr);
      if (resumeId == null || educationId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume or education ID'}), headers: jsonContentHeaders);
      }

      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Request body is required'}), headers: jsonContentHeaders);
      }
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;

      int? parseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        return int.tryParse(value.toString());
      }

      final updated = await _repository.updateResumeEducation(
        educationId: educationId,
        resumeId: resumeId,
        userId: userId,
        institution: (body['institution'] as String?)?.trim(),
        speciality: (body['speciality'] as String?)?.trim(),
        yearStart: parseInt(body['year_start']),
        yearEnd: parseInt(body['year_end']),
        isCurrent: body['is_current'] as bool?,
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Education not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode(_toJsonEncodable(updated)), headers: jsonContentHeaders);
    });
  }

  Future<Response> deleteResumeEducation(Request request) async {
    return wrapResponse(() async {
      final userId = _getUserIdFromRequest(request);
      if (userId == null) {
        return Response.unauthorized(jsonEncode({'error': 'Authentication required'}), headers: jsonContentHeaders);
      }

      final resumeIdStr = request.params['id'];
      final resumeId = _parseId(resumeIdStr);
      final educationIdStr = request.params['educationId'];
      final educationId = _parseId(educationIdStr);
      if (resumeId == null || educationId == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid resume or education ID'}), headers: jsonContentHeaders);
      }

      final deleted = await _repository.deleteResumeEducation(
        educationId: educationId,
        resumeId: resumeId,
        userId: userId,
      );

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Education not found'}), headers: jsonContentHeaders);
      }

      return Response.ok(jsonEncode({'message': 'Education deleted successfully'}), headers: jsonContentHeaders);
    });
  }
}

