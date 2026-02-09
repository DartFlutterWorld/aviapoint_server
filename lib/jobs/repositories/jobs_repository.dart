import 'dart:convert';
import 'package:postgres/postgres.dart';

/// Репозиторий для работы с вакансиями и резюме (jobs)
class JobsRepository {
  final Connection _connection;

  JobsRepository({required Connection connection}) : _connection = connection;

  // ============================================
  // ВАКАНСИИ
  // ============================================

  /// Получить список вакансий с фильтрами.
  /// [currentUserId] — если задан, в каждой строке добавляется is_favorite.
  Future<List<Map<String, dynamic>>> getVacancies({
    int? employerId,
    int? currentUserId,
    String? searchQuery,
    String? address,
    String? experienceLevel,
    String? employmentType,
    String? schedule,
    int? salaryFrom,
    int? salaryTo,
    bool onlyPublished = true,
    int limit = 20,
    int offset = 0,
  }) async {
    final parameters = <String, dynamic>{};
    final extraSelect = currentUserId != null
        ? ', EXISTS(SELECT 1 FROM user_favorite_vacancies fv WHERE fv.vacancy_id = v.id AND fv.user_id = @current_user_id) AS is_favorite, EXISTS(SELECT 1 FROM jobs_vacancy_responses vr WHERE vr.vacancy_id = v.id AND vr.candidate_id = @current_user_id) AS user_has_responded'
        : '';
    var query = '''
      SELECT
        v.*,
        cp.is_private,
        cp.company_name,
        cp.inn,
        cp.contact_name,
        cp.contact_position,
        cp.contact_phone,
        cp.contact_phone_alt,
        cp.contact_telegram,
        cp.contact_whatsapp,
        cp.contact_max,
        cp.contact_email,
        cp.contact_site,
        cp.logo_url,
        cp.additional_image_urls,
        cp.address AS address,
        p.first_name AS employer_first_name,
        p.last_name AS employer_last_name,
        p.phone AS employer_phone,
        p.telegram AS employer_telegram,
        p.max AS employer_max,
        COALESCE(ARRAY(
          SELECT s.name
          FROM jobs_vacancy_skills s
          WHERE s.vacancy_id = v.id
          ORDER BY s.name
        ), ARRAY[]::text[]) AS skills
        $extraSelect
      FROM jobs_vacancies v
      LEFT JOIN jobs_contact_profiles cp ON v.contact_profile_id = cp.id
      LEFT JOIN profiles p ON v.employer_id = p.id
      WHERE 1 = 1
    ''';
    if (currentUserId != null) parameters['current_user_id'] = currentUserId;

    if (employerId != null) {
      query += ' AND v.employer_id = @employer_id';
      parameters['employer_id'] = employerId;
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query += ' AND (v.title ILIKE @search OR v.description ILIKE @search OR v.responsibilities ILIKE @search)';
      parameters['search'] = '%${searchQuery.trim()}%';
    }

    if (address != null && address.trim().isNotEmpty) {
      query += ' AND cp.address ILIKE @address';
      parameters['address'] = '%${address.trim()}%';
    }

    if (experienceLevel != null && experienceLevel.isNotEmpty) {
      query += ' AND v.experience_level = @experience_level';
      parameters['experience_level'] = experienceLevel;
    }

    if (employmentType != null && employmentType.isNotEmpty) {
      query += ' AND v.employment_type = @employment_type';
      parameters['employment_type'] = employmentType;
    }

    if (schedule != null && schedule.isNotEmpty) {
      query += ' AND v.schedule = @schedule';
      parameters['schedule'] = schedule;
    }

    if (salaryFrom != null) {
      query += ' AND (v.salary_from IS NULL OR v.salary_from >= @salary_from)';
      parameters['salary_from'] = salaryFrom;
    }

    if (salaryTo != null) {
      query += ' AND (v.salary_to IS NULL OR v.salary_to <= @salary_to)';
      parameters['salary_to'] = salaryTo;
    }

    if (onlyPublished) {
      query += '''
        AND v.is_published = TRUE
        AND v.is_active = TRUE
        AND (v.published_until IS NULL OR v.published_until >= NOW())
      ''';
    }

    query += ' ORDER BY v.created_at DESC LIMIT @limit OFFSET @offset';
    parameters['limit'] = limit;
    parameters['offset'] = offset;

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Получить вакансию по ID.
  /// [currentUserId] — если задан, в ответ добавляется is_favorite и user_has_responded.
  Future<Map<String, dynamic>?> getVacancyById(int id, {int? currentUserId}) async {
    final extraSelect = currentUserId != null
        ? ', EXISTS(SELECT 1 FROM user_favorite_vacancies fv WHERE fv.vacancy_id = v.id AND fv.user_id = @current_user_id) AS is_favorite, EXISTS(SELECT 1 FROM jobs_vacancy_responses vr WHERE vr.vacancy_id = v.id AND vr.candidate_id = @current_user_id) AS user_has_responded'
        : '';
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          v.*,
          cp.is_private,
          cp.company_name,
          cp.inn,
          cp.contact_name,
          cp.contact_position,
          cp.contact_phone,
          cp.contact_phone_alt,
          cp.contact_telegram,
          cp.contact_whatsapp,
          cp.contact_max,
          cp.contact_email,
          cp.contact_site,
          cp.logo_url,
          cp.additional_image_urls,
          cp.address AS address,
          p.first_name AS employer_first_name,
          p.last_name AS employer_last_name,
          p.phone AS employer_phone,
          p.telegram AS employer_telegram,
          p.max AS employer_max,
          COALESCE(ARRAY(
            SELECT s.name
            FROM jobs_vacancy_skills s
            WHERE s.vacancy_id = v.id
            ORDER BY s.name
          ), ARRAY[]::text[]) AS skills
          $extraSelect
        FROM jobs_vacancies v
        LEFT JOIN jobs_contact_profiles cp ON v.contact_profile_id = cp.id
        LEFT JOIN profiles p ON v.employer_id = p.id
        WHERE v.id = @id
      '''),
      parameters: {'id': id, if (currentUserId != null) 'current_user_id': currentUserId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Создать вакансию
  Future<Map<String, dynamic>> createVacancy({
    required int employerId,
    required String title,
    required int contactProfileId,
    String? description,
    String? responsibilities,
    String? requirements,
    String? conditions,
    int? salaryFrom,
    int? salaryTo,
    String currency = 'RUB',
    bool? isGross,
    String? employmentType,
    String? schedule,
    String? experienceLevel,
    String? educationLevel,
    String? employmentForm,
    String? workHours,
    bool? relocationAllowed,
    String? businessTrips,
    String? aircraftCategory,
    String? requiredLicense,
    int? minFlightHours,
    String? requiredTypeRating,
    List<String>? skills,
  }) async {
    final durationResult = await _connection.execute(
      Sql.named('SELECT publication_duration_months FROM publication_settings WHERE table_name = @table_name'),
      parameters: {'table_name': 'jobs_vacancies'},
    );
    final durationMonths = durationResult.isNotEmpty ? (durationResult.first[0] as int? ?? 1) : 1;

    await _connection.execute(Sql('BEGIN'));
    try {
      final result = await _connection.execute(
        Sql.named('''
          INSERT INTO jobs_vacancies (
            employer_id, contact_profile_id,
            title, description, responsibilities, requirements, conditions,
            salary_from, salary_to, currency, is_gross, show_salary,
            employment_type, schedule, experience_level, education_level,
            employment_form, work_hours,
            relocation_allowed, business_trips,
            aircraft_category, required_license, min_flight_hours, required_type_rating,
            is_published, is_active, status, published_until,
            views_count, responses_count
          )
          VALUES (
            @employer_id, @contact_profile_id,
            @title, @description, @responsibilities, @requirements, @conditions,
            @salary_from, @salary_to, @currency, @is_gross, TRUE,
            @employment_type, @schedule, @experience_level, @education_level,
            @employment_form, @work_hours,
            @relocation_allowed, @business_trips,
            @aircraft_category, @required_license, @min_flight_hours, @required_type_rating,
            TRUE, TRUE, 'published', NOW() + MAKE_INTERVAL(months => @duration),
            0, 0
          )
          RETURNING *
        '''),
        parameters: {
          'employer_id': employerId,
          'contact_profile_id': contactProfileId,
          'title': title,
          'description': description,
          'responsibilities': responsibilities,
          'requirements': requirements,
          'conditions': conditions,
          'salary_from': salaryFrom,
          'salary_to': salaryTo,
          'currency': currency,
          'is_gross': isGross ?? true,
          'employment_type': employmentType,
          'schedule': schedule,
          'experience_level': experienceLevel,
          'education_level': educationLevel,
          'employment_form': employmentForm,
          'work_hours': workHours,
          'relocation_allowed': relocationAllowed ?? false,
          'business_trips': businessTrips,
          'aircraft_category': aircraftCategory,
          'required_license': requiredLicense,
          'min_flight_hours': minFlightHours,
          'required_type_rating': requiredTypeRating,
          'duration': durationMonths,
        },
      );

      if (result.isEmpty) {
        throw Exception('Failed to create vacancy');
      }

      final vacancy = result.first.toColumnMap();
      final vacancyId = vacancy['id'] as int;

      if (skills != null && skills.isNotEmpty) {
        for (final skill in skills) {
          final trimmed = skill.trim();
          if (trimmed.isEmpty) continue;
          await _connection.execute(
            Sql.named('''
              INSERT INTO jobs_vacancy_skills (vacancy_id, name)
              VALUES (@vacancy_id, @name)
              ON CONFLICT (vacancy_id, name) DO NOTHING
            '''),
            parameters: {
              'vacancy_id': vacancyId,
              'name': trimmed,
            },
          );
        }
      }

      vacancy['skills'] = skills ?? <String>[];
      await _connection.execute(Sql('COMMIT'));
      return vacancy;
    } catch (e) {
      await _connection.execute(Sql('ROLLBACK'));
      rethrow;
    }
  }

  /// Обновить вакансию
  Future<Map<String, dynamic>?> updateVacancy({
    required int vacancyId,
    required int employerId,
    String? title,
    int? contactProfileId,
    String? description,
    String? responsibilities,
    String? requirements,
    String? conditions,
    int? salaryFrom,
    int? salaryTo,
    String? currency,
    bool? isGross,
    String? employmentType,
    String? schedule,
    String? experienceLevel,
    String? educationLevel,
    String? employmentForm,
    String? workHours,
    bool? relocationAllowed,
    String? businessTrips,
    String? aircraftCategory,
    String? requiredLicense,
    int? minFlightHours,
    String? requiredTypeRating,
    List<String>? skills,
  }) async {
    // Проверка владельца
    final ownerResult = await _connection.execute(
      Sql.named('SELECT employer_id FROM jobs_vacancies WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
    if (ownerResult.isEmpty) return null;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != employerId) {
      throw Exception('You do not have permission to update this vacancy');
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{'id': vacancyId};

    void setField(String column, String param, dynamic value) {
      updates.add('$column = @$param');
      parameters[param] = value;
    }

    if (title != null) setField('title', 'title', title);
    if (description != null) setField('description', 'description', description);
    if (responsibilities != null) setField('responsibilities', 'responsibilities', responsibilities);
    if (requirements != null) setField('requirements', 'requirements', requirements);
    if (conditions != null) setField('conditions', 'conditions', conditions);
    if (salaryFrom != null) setField('salary_from', 'salary_from', salaryFrom);
    if (salaryTo != null) setField('salary_to', 'salary_to', salaryTo);
    if (currency != null) setField('currency', 'currency', currency);
    if (isGross != null) setField('is_gross', 'is_gross', isGross);
    if (employmentType != null) setField('employment_type', 'employment_type', employmentType);
    if (schedule != null) setField('schedule', 'schedule', schedule);
    if (experienceLevel != null) setField('experience_level', 'experience_level', experienceLevel);
    if (educationLevel != null) setField('education_level', 'education_level', educationLevel);
    if (contactProfileId != null) setField('contact_profile_id', 'contact_profile_id', contactProfileId);
    if (employmentForm != null) setField('employment_form', 'employment_form', employmentForm);
    if (workHours != null) setField('work_hours', 'work_hours', workHours);
    if (relocationAllowed != null) setField('relocation_allowed', 'relocation_allowed', relocationAllowed);
    if (businessTrips != null) setField('business_trips', 'business_trips', businessTrips);
    if (aircraftCategory != null) setField('aircraft_category', 'aircraft_category', aircraftCategory);
    if (requiredLicense != null) setField('required_license', 'required_license', requiredLicense);
    if (minFlightHours != null) setField('min_flight_hours', 'min_flight_hours', minFlightHours);
    if (requiredTypeRating != null) setField('required_type_rating', 'required_type_rating', requiredTypeRating);

    if (updates.isEmpty && skills == null) {
      return await getVacancyById(vacancyId);
    }

    updates.add('updated_at = NOW()');

    await _connection.execute(
      Sql.named('UPDATE jobs_vacancies SET ${updates.join(', ')} WHERE id = @id'),
      parameters: parameters,
    );

    if (skills != null) {
      await _connection.execute(
        Sql.named('DELETE FROM jobs_vacancy_skills WHERE vacancy_id = @vacancy_id'),
        parameters: {'vacancy_id': vacancyId},
      );
      for (final skill in skills) {
        final trimmed = skill.trim();
        if (trimmed.isEmpty) continue;
        await _connection.execute(
          Sql.named('''
            INSERT INTO jobs_vacancy_skills (vacancy_id, name)
            VALUES (@vacancy_id, @name)
            ON CONFLICT (vacancy_id, name) DO NOTHING
          '''),
          parameters: {
            'vacancy_id': vacancyId,
            'name': trimmed,
          },
        );
      }
    }

    return await getVacancyById(vacancyId);
  }

  /// Опубликовать вакансию (учитывая publication_settings)
  Future<Map<String, dynamic>?> publishVacancy({
    required int vacancyId,
    required int employerId,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT employer_id FROM jobs_vacancies WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
    if (ownerResult.isEmpty) return null;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != employerId) {
      throw Exception('You do not have permission to publish this vacancy');
    }

    final durationResult = await _connection.execute(
      Sql.named('SELECT publication_duration_months FROM publication_settings WHERE table_name = @table_name'),
      parameters: {'table_name': 'jobs_vacancies'},
    );
    final durationMonths = durationResult.isNotEmpty ? (durationResult.first[0] as int? ?? 1) : 1;

    final result = await _connection.execute(
      Sql.named('''
        UPDATE jobs_vacancies
        SET is_published = TRUE,
            is_active = TRUE,
            status = 'published',
            published_until = NOW() + MAKE_INTERVAL(months => @duration),
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': vacancyId,
        'duration': durationMonths,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Снять вакансию с публикации
  Future<Map<String, dynamic>?> unpublishVacancy({
    required int vacancyId,
    required int employerId,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT employer_id FROM jobs_vacancies WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
    if (ownerResult.isEmpty) return null;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != employerId) {
      throw Exception('You do not have permission to unpublish this vacancy');
    }

    final result = await _connection.execute(
      Sql.named('''
        UPDATE jobs_vacancies
        SET is_published = FALSE,
            status = 'closed',
            updated_at = NOW(),
            closed_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': vacancyId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Деактивировать вакансию (админ блокирует)
  Future<Map<String, dynamic>?> deactivateVacancy(int vacancyId) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE jobs_vacancies
        SET is_active = FALSE,
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': vacancyId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Активировать вакансию (админ разблокирует)
  Future<Map<String, dynamic>?> activateVacancy(int vacancyId) async {
    final result = await _connection.execute(
      Sql.named('''
        UPDATE jobs_vacancies
        SET is_active = TRUE,
            updated_at = NOW()
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {'id': vacancyId},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Удалить вакансию
  Future<bool> deleteVacancy({
    required int vacancyId,
    required int employerId,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT employer_id FROM jobs_vacancies WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
    if (ownerResult.isEmpty) return false;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != employerId) {
      throw Exception('You do not have permission to delete this vacancy');
    }

    await _connection.execute(
      Sql.named('DELETE FROM jobs_vacancies WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
    return true;
  }

  /// Увеличить счетчик просмотров вакансии
  Future<void> incrementVacancyViews(int vacancyId) async {
    await _connection.execute(
      Sql.named('UPDATE jobs_vacancies SET views_count = views_count + 1 WHERE id = @id'),
      parameters: {'id': vacancyId},
    );
  }

  /// Отклик на вакансию
  Future<Map<String, dynamic>> respondToVacancy({
    required int vacancyId,
    required int candidateId,
    int? resumeId,
    String? coverLetter,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO jobs_vacancy_responses (
          vacancy_id, resume_id, candidate_id, status, cover_letter, created_at, updated_at
        ) VALUES (
          @vacancy_id, @resume_id, @candidate_id, 'new', @cover_letter, NOW(), NOW()
        )
        RETURNING *
      '''),
      parameters: {
        'vacancy_id': vacancyId,
        'resume_id': resumeId,
        'candidate_id': candidateId,
        'cover_letter': coverLetter,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create vacancy response');
    }

    // Обновляем счётчик откликов
    await _connection.execute(
      Sql.named('UPDATE jobs_vacancies SET responses_count = responses_count + 1 WHERE id = @id'),
      parameters: {'id': vacancyId},
    );

    return result.first.toColumnMap();
  }

  /// Получить отклики по вакансии (для работодателя).
  /// Контакты берутся из контактного профиля резюме (которые указал кандидат), а не из профиля пользователя.
  Future<List<Map<String, dynamic>>> getVacancyResponses(int vacancyId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          p.first_name AS candidate_first_name,
          p.last_name AS candidate_last_name,
          COALESCE(cp.contact_phone, p.phone) AS candidate_phone,
          cp.contact_phone_alt AS candidate_phone_alt,
          COALESCE(cp.contact_telegram, p.telegram) AS candidate_telegram,
          cp.contact_whatsapp AS candidate_whatsapp,
          cp.contact_max AS candidate_max,
          cp.contact_email AS candidate_email
        FROM jobs_vacancy_responses r
        LEFT JOIN profiles p ON r.candidate_id = p.id
        LEFT JOIN jobs_resumes res ON r.resume_id = res.id
        LEFT JOIN jobs_contact_profiles cp ON res.contact_profile_id = cp.id
        WHERE r.vacancy_id = @vacancy_id
        ORDER BY r.created_at DESC
      '''),
      parameters: {'vacancy_id': vacancyId},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Отклики текущего пользователя (кандидата) — для экрана «Мои отклики».
  /// Включает данные работодателя: компания или ФИО физлица, логотип.
  Future<List<Map<String, dynamic>>> getMyVacancyResponses(int userId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          v.title AS vacancy_title,
          p.first_name AS candidate_first_name,
          p.last_name AS candidate_last_name,
          COALESCE(cp.contact_phone, p.phone) AS candidate_phone,
          cp.contact_phone_alt AS candidate_phone_alt,
          COALESCE(cp.contact_telegram, p.telegram) AS candidate_telegram,
          cp.contact_whatsapp AS candidate_whatsapp,
          cp.contact_max AS candidate_max,
          cp.contact_email AS candidate_email,
          cp_v.company_name AS employer_company_name,
          cp_v.logo_url AS employer_logo_url,
          cp_v.is_private AS employer_contact_is_private,
          p_emp.first_name AS employer_first_name,
          p_emp.last_name AS employer_last_name
        FROM jobs_vacancy_responses r
        INNER JOIN jobs_vacancies v ON r.vacancy_id = v.id
        LEFT JOIN jobs_contact_profiles cp_v ON v.contact_profile_id = cp_v.id
        LEFT JOIN profiles p_emp ON v.employer_id = p_emp.id
        LEFT JOIN profiles p ON r.candidate_id = p.id
        LEFT JOIN jobs_resumes res ON r.resume_id = res.id
        LEFT JOIN jobs_contact_profiles cp ON res.contact_profile_id = cp.id
        WHERE r.candidate_id = @user_id
        ORDER BY r.created_at DESC
      '''),
      parameters: {'user_id': userId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Все отклики по вакансиям текущего пользователя (работодателя). Для экрана «Отклики по моим вакансиям».
  Future<List<Map<String, dynamic>>> getEmployerVacancyResponses(int employerId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          v.title AS vacancy_title,
          p.first_name AS candidate_first_name,
          p.last_name AS candidate_last_name,
          COALESCE(cp.contact_phone, p.phone) AS candidate_phone,
          cp.contact_phone_alt AS candidate_phone_alt,
          COALESCE(cp.contact_telegram, p.telegram) AS candidate_telegram,
          cp.contact_whatsapp AS candidate_whatsapp,
          cp.contact_max AS candidate_max,
          cp.contact_email AS candidate_email
        FROM jobs_vacancy_responses r
        INNER JOIN jobs_vacancies v ON r.vacancy_id = v.id
        LEFT JOIN profiles p ON r.candidate_id = p.id
        LEFT JOIN jobs_resumes res ON r.resume_id = res.id
        LEFT JOIN jobs_contact_profiles cp ON res.contact_profile_id = cp.id
        WHERE v.employer_id = @employer_id
        ORDER BY r.created_at DESC
      '''),
      parameters: {'employer_id': employerId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Удалить свой отклик на вакансию. Только кандидат (владелец отклика).
  Future<bool> deleteMyVacancyResponse({required int responseId, required int candidateId}) async {
    final result = await _connection.execute(
      Sql.named('''
        DELETE FROM jobs_vacancy_responses
        WHERE id = @response_id AND candidate_id = @candidate_id
      '''),
      parameters: {'response_id': responseId, 'candidate_id': candidateId},
    );
    return result.isNotEmpty;
  }

  /// Обновить статус отклика на вакансию (и опционально комментарий). Только владелец вакансии.
  /// [status] — один из: new, in_progress, rejected, accepted.
  /// [employerComment] — комментарий работодателя (при смене статуса).
  Future<Map<String, dynamic>?> updateVacancyResponseStatus({
    required int vacancyId,
    required int responseId,
    required String status,
    required int employerId,
    String? employerComment,
  }) async {
    final vacancy = await getVacancyById(vacancyId);
    if (vacancy == null || (vacancy['employer_id'] as int?) != employerId) {
      return null;
    }
    const allowed = ['new', 'in_progress', 'rejected', 'accepted'];
    if (!allowed.contains(status)) {
      return null;
    }
    await _connection.execute(
      Sql.named('''
        UPDATE jobs_vacancy_responses
        SET status = @status, updated_at = NOW(), employer_comment = @employer_comment
        WHERE id = @response_id AND vacancy_id = @vacancy_id
      '''),
      parameters: {
        'status': status,
        'response_id': responseId,
        'vacancy_id': vacancyId,
        'employer_comment': employerComment?.trim().isEmpty == true ? null : employerComment?.trim(),
      },
    );
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          p.first_name AS candidate_first_name,
          p.last_name AS candidate_last_name,
          COALESCE(cp.contact_phone, p.phone) AS candidate_phone,
          cp.contact_phone_alt AS candidate_phone_alt,
          COALESCE(cp.contact_telegram, p.telegram) AS candidate_telegram,
          cp.contact_whatsapp AS candidate_whatsapp,
          cp.contact_max AS candidate_max,
          cp.contact_email AS candidate_email
        FROM jobs_vacancy_responses r
        LEFT JOIN profiles p ON r.candidate_id = p.id
        LEFT JOIN jobs_resumes res ON r.resume_id = res.id
        LEFT JOIN jobs_contact_profiles cp ON res.contact_profile_id = cp.id
        WHERE r.vacancy_id = @vacancy_id AND r.id = @response_id
      '''),
      parameters: {'vacancy_id': vacancyId, 'response_id': responseId},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  // ============================================
  // ИЗБРАННЫЕ ВАКАНСИИ
  // ============================================

  Future<void> addVacancyToFavorites(int userId, int vacancyId) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO user_favorite_vacancies (user_id, vacancy_id, created_at)
        VALUES (@user_id, @vacancy_id, NOW())
        ON CONFLICT (user_id, vacancy_id) DO NOTHING
      '''),
      parameters: {'user_id': userId, 'vacancy_id': vacancyId},
    );
  }

  Future<void> removeVacancyFromFavorites(int userId, int vacancyId) async {
    await _connection.execute(
      Sql.named('DELETE FROM user_favorite_vacancies WHERE user_id = @user_id AND vacancy_id = @vacancy_id'),
      parameters: {'user_id': userId, 'vacancy_id': vacancyId},
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteVacancies(int userId, {int limit = 20, int offset = 0}) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          v.*,
          cp.is_private,
          cp.company_name,
          cp.inn,
          cp.contact_name,
          cp.contact_position,
          cp.contact_phone,
          cp.contact_phone_alt,
          cp.contact_telegram,
          cp.contact_whatsapp,
          cp.contact_max,
          cp.contact_email,
          cp.contact_site,
          cp.logo_url,
          cp.additional_image_urls,
          cp.address AS address,
          p.first_name AS employer_first_name,
          p.last_name AS employer_last_name,
          p.phone AS employer_phone,
          p.telegram AS employer_telegram,
          p.max AS employer_max,
          true AS is_favorite
        FROM jobs_vacancies v
        LEFT JOIN jobs_contact_profiles cp ON v.contact_profile_id = cp.id
        INNER JOIN user_favorite_vacancies fv ON v.id = fv.vacancy_id
        LEFT JOIN profiles p ON v.employer_id = p.id
        WHERE fv.user_id = @user_id
        ORDER BY fv.created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {'user_id': userId, 'limit': limit, 'offset': offset},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  // ============================================
  // ПРОФИЛИ КОНТАКТОВ ДЛЯ ВАКАНСИЙ
  // ============================================

  Future<List<Map<String, dynamic>>> getContactProfiles(int ownerId) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT *
        FROM jobs_contact_profiles
        WHERE owner_id = @owner_id
        ORDER BY created_at DESC
      '''),
      parameters: {'owner_id': ownerId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getContactProfileById(int profileId) async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM jobs_contact_profiles WHERE id = @id'),
      parameters: {'id': profileId},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> createContactProfile({
    required int ownerId,
    required bool isPrivate,
    String? companyName,
    String? inn,
    String? address,
    String? logoUrl,
    List<String>? additionalImageUrls,
    required String contactName,
    required String contactPosition,
    required String contactPhone,
    String? contactPhoneAlt,
    String? contactTelegram,
    String? contactWhatsapp,
    String? contactMax,
    String? contactEmail,
    String? contactSite,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO jobs_contact_profiles (
          owner_id, is_private, company_name, inn, address, logo_url, additional_image_urls,
          contact_name, contact_position, contact_phone, contact_phone_alt,
          contact_telegram, contact_whatsapp, contact_max, contact_email, contact_site
        ) VALUES (
          @owner_id, @is_private, @company_name, @inn, @address, @logo_url, @additional_image_urls::jsonb,
          @contact_name, @contact_position, @contact_phone, @contact_phone_alt,
          @contact_telegram, @contact_whatsapp, @contact_max, @contact_email, @contact_site
        )
        RETURNING *
      '''),
      parameters: {
        'owner_id': ownerId,
        'is_private': isPrivate,
        'company_name': companyName,
        'inn': inn,
        'address': address,
        'logo_url': logoUrl,
        'additional_image_urls': jsonEncode(additionalImageUrls ?? []),
        'contact_name': contactName,
        'contact_position': contactPosition,
        'contact_phone': contactPhone,
        'contact_phone_alt': contactPhoneAlt,
        'contact_telegram': contactTelegram,
        'contact_whatsapp': contactWhatsapp,
        'contact_max': contactMax,
        'contact_email': contactEmail,
        'contact_site': contactSite,
      },
    );
    if (result.isEmpty) {
      throw Exception('Failed to create contact profile');
    }
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> updateContactProfile({
    required int ownerId,
    required int profileId,
    bool? isPrivate,
    String? companyName,
    String? inn,
    String? address,
    String? logoUrl,
    List<String>? additionalImageUrls,
    String? contactName,
    String? contactPosition,
    String? contactPhone,
    String? contactPhoneAlt,
    String? contactTelegram,
    String? contactWhatsapp,
    String? contactMax,
    String? contactEmail,
    String? contactSite,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT owner_id FROM jobs_contact_profiles WHERE id = @id'),
      parameters: {'id': profileId},
    );
    if (ownerResult.isEmpty) return null;
    final owner = ownerResult.first[0] as int;
    if (owner != ownerId) {
      throw Exception('You do not have permission to update this contact profile');
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{'id': profileId};
    void setField(String column, String param, dynamic value) {
      updates.add('$column = @$param');
      parameters[param] = value;
    }

    if (isPrivate != null) setField('is_private', 'is_private', isPrivate);
    if (companyName != null) setField('company_name', 'company_name', companyName);
    if (inn != null) setField('inn', 'inn', inn);
    if (address != null) setField('address', 'address', address);
    if (logoUrl != null) setField('logo_url', 'logo_url', logoUrl.isEmpty ? null : logoUrl);
    if (additionalImageUrls != null) {
      updates.add('additional_image_urls = @additional_image_urls::jsonb');
      parameters['additional_image_urls'] = jsonEncode(additionalImageUrls);
    }
    if (contactName != null) setField('contact_name', 'contact_name', contactName);
    if (contactPosition != null) setField('contact_position', 'contact_position', contactPosition);
    if (contactPhone != null) setField('contact_phone', 'contact_phone', contactPhone);
    if (contactPhoneAlt != null) setField('contact_phone_alt', 'contact_phone_alt', contactPhoneAlt);
    if (contactTelegram != null) setField('contact_telegram', 'contact_telegram', contactTelegram);
    if (contactWhatsapp != null) setField('contact_whatsapp', 'contact_whatsapp', contactWhatsapp);
    if (contactMax != null) setField('contact_max', 'contact_max', contactMax);
    if (contactEmail != null) setField('contact_email', 'contact_email', contactEmail);
    if (contactSite != null) setField('contact_site', 'contact_site', contactSite);

    if (updates.isEmpty) {
      final result = await _connection.execute(
        Sql.named('SELECT * FROM jobs_contact_profiles WHERE id = @id'),
        parameters: {'id': profileId},
      );
      if (result.isEmpty) return null;
      return result.first.toColumnMap();
    }

    updates.add('updated_at = NOW()');
    await _connection.execute(
      Sql.named('UPDATE jobs_contact_profiles SET ${updates.join(', ')} WHERE id = @id'),
      parameters: parameters,
    );

    final result = await _connection.execute(
      Sql.named('SELECT * FROM jobs_contact_profiles WHERE id = @id'),
      parameters: {'id': profileId},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> deleteContactProfile({required int ownerId, required int profileId}) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT owner_id FROM jobs_contact_profiles WHERE id = @id'),
      parameters: {'id': profileId},
    );
    if (ownerResult.isEmpty) return false;
    final owner = ownerResult.first[0] as int;
    if (owner != ownerId) {
      throw Exception('You do not have permission to delete this contact profile');
    }
    await _connection.execute(
      Sql.named('DELETE FROM jobs_contact_profiles WHERE id = @id'),
      parameters: {'id': profileId},
    );
    return true;
  }

  // ============================================
  // РЕЗЮМЕ
  // ============================================

  /// Получить список резюме с фильтрами (для работодателей).
  /// [userId] — если задан, возвращаются только резюме этого пользователя (все статусы, для "мои резюме").
  Future<List<Map<String, dynamic>>> getResumes({
    int? userId,
    String? searchQuery,
    String? address,
    String? experienceLevel, // может быть рассчитан по total_experience_months
    String? licenseFilter,
    String? aircraftTypeFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    final parameters = <String, dynamic>{};
    var query = '''
      SELECT
        r.*,
        p.first_name AS user_first_name,
        p.last_name AS user_last_name,
        p.phone AS user_phone,
        p.telegram AS user_telegram
      FROM jobs_resumes r
      LEFT JOIN profiles p ON r.user_id = p.id
      WHERE 1 = 1
    ''';

    if (userId != null) {
      query += ' AND r.user_id = @user_id';
      parameters['user_id'] = userId;
    } else {
      query += " AND r.status = 'active' AND r.is_visible_for_employers = TRUE";
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query += ' AND (r.title ILIKE @search OR r.about ILIKE @search OR r.current_position ILIKE @search)';
      parameters['search'] = '%${searchQuery.trim()}%';
    }

    if (address != null && address.trim().isNotEmpty) {
      query += ' AND r.address ILIKE @address';
      parameters['address'] = '%${address.trim()}%';
    }

    if (licenseFilter != null && licenseFilter.trim().isNotEmpty) {
      query += ' AND r.licenses ILIKE @license';
      parameters['license'] = '%${licenseFilter.trim()}%';
    }

    if (aircraftTypeFilter != null && aircraftTypeFilter.trim().isNotEmpty) {
      query += ' AND r.type_ratings ILIKE @type_ratings';
      parameters['type_ratings'] = '%${aircraftTypeFilter.trim()}%';
    }

    query += ' ORDER BY r.created_at DESC LIMIT @limit OFFSET @offset';
    parameters['limit'] = limit;
    parameters['offset'] = offset;

    final result = await _connection.execute(Sql.named(query), parameters: parameters);
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// Получить резюме по ID (с контактами из contact_profile при наличии).
  Future<Map<String, dynamic>?> getResumeById(int id) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          p.first_name AS user_first_name,
          p.last_name AS user_last_name,
          p.phone AS user_phone,
          p.telegram AS user_telegram,
          cp.contact_name AS contact_name,
          cp.contact_position AS contact_position,
          cp.contact_phone AS contact_phone,
          cp.contact_phone_alt AS contact_phone_alt,
          cp.contact_telegram AS contact_telegram,
          cp.contact_whatsapp AS contact_whatsapp,
          cp.contact_max AS contact_max,
          cp.contact_email AS contact_email,
          cp.contact_site AS contact_site
        FROM jobs_resumes r
        LEFT JOIN profiles p ON r.user_id = p.id
        LEFT JOIN jobs_contact_profiles cp ON r.contact_profile_id = cp.id AND cp.owner_id = r.user_id
        WHERE r.id = @id
      '''),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  /// Создать резюме
  Future<Map<String, dynamic>> createResume({
    required int userId,
    required String title,
    String? about,
    int? desiredSalary,
    String currency = 'RUB',
    String? employmentTypes,
    String? schedules,
    bool? readyToRelocate,
    bool? readyForBusinessTrips,
    String? address,
    DateTime? dateOfBirth,
    List<String>? citizenship,
    bool? workPermit,
    String? photoUrl,
    List<String>? additionalPhotoUrls,
    int? contactProfileId,
    String? currentPosition,
    String? currentCompany,
    int? totalExperienceMonths,
    int? flightHoursTotal,
    int? flightHoursPic,
    String? licenses,
    String? typeRatings,
    String? medicalClass,
  }) async {
    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO jobs_resumes (
          user_id, title, about, status, is_visible_for_employers,
          desired_salary, currency, employment_types, schedules,
          ready_to_relocate, ready_for_business_trips,
          address, date_of_birth, citizenship, work_permit,
          photo_url, additional_photo_urls, contact_profile_id,
          current_position, current_company,
          total_experience_months, flight_hours_total, flight_hours_pic,
          licenses, type_ratings, medical_class,
          created_at, updated_at, last_active_at
        ) VALUES (
          @user_id, @title, @about, 'active', TRUE,
          @desired_salary, @currency, @employment_types, @schedules,
          @ready_to_relocate, @ready_for_business_trips,
          @address, @date_of_birth, string_to_array(COALESCE(@citizenship, 'RU'), ',')::text[], @work_permit,
          @photo_url, @additional_photo_urls::jsonb, @contact_profile_id,
          @current_position, @current_company,
          @total_experience_months, @flight_hours_total, @flight_hours_pic,
          @licenses, @type_ratings, @medical_class,
          NOW(), NOW(), NOW()
        )
        RETURNING *
      '''),
      parameters: {
        'user_id': userId,
        'title': title,
        'about': about,
        'desired_salary': desiredSalary,
        'currency': currency,
        'employment_types': employmentTypes,
        'schedules': schedules,
        'ready_to_relocate': readyToRelocate ?? false,
        'ready_for_business_trips': readyForBusinessTrips ?? false,
        'address': address,
        'date_of_birth': dateOfBirth,
        'citizenship': citizenship != null && citizenship.isNotEmpty ? citizenship.join(',') : 'RU',
        'work_permit': workPermit ?? true,
        'photo_url': photoUrl,
        'additional_photo_urls': jsonEncode(additionalPhotoUrls ?? []),
        'contact_profile_id': contactProfileId,
        'current_position': currentPosition,
        'current_company': currentCompany,
        'total_experience_months': totalExperienceMonths,
        'flight_hours_total': flightHoursTotal,
        'flight_hours_pic': flightHoursPic,
        'licenses': licenses,
        'type_ratings': typeRatings,
        'medical_class': medicalClass,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create resume');
    }

    return result.first.toColumnMap();
  }

  /// Обновить резюме
  Future<Map<String, dynamic>?> updateResume({
    required int resumeId,
    required int userId,
    String? title,
    String? about,
    int? desiredSalary,
    String? currency,
    String? employmentTypes,
    String? schedules,
    bool? readyToRelocate,
    bool? readyForBusinessTrips,
    String? address,
    DateTime? dateOfBirth,
    List<String>? citizenship,
    bool? workPermit,
    String? photoUrl,
    List<String>? additionalPhotoUrls,
    int? contactProfileId,
    bool? clearContactProfileId,
    String? currentPosition,
    String? currentCompany,
    int? totalExperienceMonths,
    int? flightHoursTotal,
    int? flightHoursPic,
    String? licenses,
    String? typeRatings,
    String? medicalClass,
    String? status,
    bool? isVisibleForEmployers,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT user_id FROM jobs_resumes WHERE id = @id'),
      parameters: {'id': resumeId},
    );
    if (ownerResult.isEmpty) return null;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != userId) {
      throw Exception('You do not have permission to update this resume');
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{'id': resumeId};

    void setField(String column, String param, dynamic value) {
      updates.add('$column = @$param');
      parameters[param] = value;
    }

    if (title != null) setField('title', 'title', title);
    if (about != null) setField('about', 'about', about);
    if (desiredSalary != null) setField('desired_salary', 'desired_salary', desiredSalary);
    if (currency != null) setField('currency', 'currency', currency);
    if (employmentTypes != null) setField('employment_types', 'employment_types', employmentTypes);
    if (schedules != null) setField('schedules', 'schedules', schedules);
    if (readyToRelocate != null) setField('ready_to_relocate', 'ready_to_relocate', readyToRelocate);
    if (readyForBusinessTrips != null) {
      setField('ready_for_business_trips', 'ready_for_business_trips', readyForBusinessTrips);
    }
    if (address != null) setField('address', 'address', address);
    if (dateOfBirth != null) setField('date_of_birth', 'date_of_birth', dateOfBirth);
    if (citizenship != null) {
      updates.add('citizenship = string_to_array(@citizenship, \',\')::text[]');
      parameters['citizenship'] = citizenship.join(',');
    }
    if (workPermit != null) setField('work_permit', 'work_permit', workPermit);
    if (photoUrl != null) setField('photo_url', 'photo_url', photoUrl);
    if (additionalPhotoUrls != null) {
      updates.add('additional_photo_urls = @additional_photo_urls::jsonb');
      parameters['additional_photo_urls'] = jsonEncode(additionalPhotoUrls);
    }
    if (contactProfileId != null) setField('contact_profile_id', 'contact_profile_id', contactProfileId);
    if (clearContactProfileId == true) {
      updates.add('contact_profile_id = NULL');
    }
    if (currentPosition != null) {
      setField('current_position', 'current_position', currentPosition);
    }
    if (currentCompany != null) {
      setField('current_company', 'current_company', currentCompany);
    }
    if (totalExperienceMonths != null) {
      setField('total_experience_months', 'total_experience_months', totalExperienceMonths);
    }
    if (flightHoursTotal != null) {
      setField('flight_hours_total', 'flight_hours_total', flightHoursTotal);
    }
    if (flightHoursPic != null) {
      setField('flight_hours_pic', 'flight_hours_pic', flightHoursPic);
    }
    if (licenses != null) setField('licenses', 'licenses', licenses);
    if (typeRatings != null) setField('type_ratings', 'type_ratings', typeRatings);
    if (medicalClass != null) setField('medical_class', 'medical_class', medicalClass);
    if (status != null) setField('status', 'status', status);
    if (isVisibleForEmployers != null) {
      setField('is_visible_for_employers', 'is_visible_for_employers', isVisibleForEmployers);
    }

    if (updates.isEmpty) {
      return await getResumeById(resumeId);
    }

    updates.add('updated_at = NOW()');
    updates.add('last_active_at = NOW()');

    await _connection.execute(
      Sql.named('UPDATE jobs_resumes SET ${updates.join(', ')} WHERE id = @id'),
      parameters: parameters,
    );

    return await getResumeById(resumeId);
  }

  /// Удалить резюме
  Future<bool> deleteResume({
    required int resumeId,
    required int userId,
  }) async {
    final ownerResult = await _connection.execute(
      Sql.named('SELECT user_id FROM jobs_resumes WHERE id = @id'),
      parameters: {'id': resumeId},
    );
    if (ownerResult.isEmpty) return false;
    final ownerId = ownerResult.first[0] as int;
    if (ownerId != userId) {
      throw Exception('You do not have permission to delete this resume');
    }

    await _connection.execute(
      Sql.named('DELETE FROM jobs_resumes WHERE id = @id'),
      parameters: {'id': resumeId},
    );
    return true;
  }

  // ============================================
  // ИЗБРАННЫЕ РЕЗЮМЕ
  // ============================================

  Future<void> addResumeToFavorites(int userId, int resumeId) async {
    await _connection.execute(
      Sql.named('''
        INSERT INTO user_favorite_resumes (user_id, resume_id, created_at)
        VALUES (@user_id, @resume_id, NOW())
        ON CONFLICT (user_id, resume_id) DO NOTHING
      '''),
      parameters: {'user_id': userId, 'resume_id': resumeId},
    );
  }

  Future<void> removeResumeFromFavorites(int userId, int resumeId) async {
    await _connection.execute(
      Sql.named('DELETE FROM user_favorite_resumes WHERE user_id = @user_id AND resume_id = @resume_id'),
      parameters: {'user_id': userId, 'resume_id': resumeId},
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteResumes(int userId, {int limit = 20, int offset = 0}) async {
    final result = await _connection.execute(
      Sql.named('''
        SELECT
          r.*,
          p.first_name AS user_first_name,
          p.last_name AS user_last_name,
          p.phone AS user_phone,
          p.telegram AS user_telegram
        FROM jobs_resumes r
        INNER JOIN user_favorite_resumes fr ON r.id = fr.resume_id
        LEFT JOIN profiles p ON r.user_id = p.id
        WHERE fr.user_id = @user_id
        ORDER BY fr.created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {'user_id': userId, 'limit': limit, 'offset': offset},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  // ============================================
  // ОПЫТ РАБОТЫ В РЕЗЮМЕ
  // ============================================

  Future<List<Map<String, dynamic>>> getResumeExperiences(int resumeId, {int? userId}) async {
    // Просмотр опыта доступен всем (работодатель смотрит резюме кандидата по отклику)
    final result = await _connection.execute(
      Sql.named('''
        SELECT *
        FROM jobs_resume_experiences
        WHERE resume_id = @resume_id
        ORDER BY start_date DESC NULLS LAST, id DESC
      '''),
      parameters: {'resume_id': resumeId},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>> createResumeExperience({
    required int resumeId,
    required int userId,
    required String companyName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? responsibilitiesAndAchievements,
  }) async {
    // Проверяем, что резюме принадлежит пользователю
    final ownerResult = await _connection.execute(
      Sql.named('SELECT user_id FROM jobs_resumes WHERE id = @id'),
      parameters: {'id': resumeId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      throw Exception('You do not have permission to modify this resume');
    }

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO jobs_resume_experiences (
          resume_id, company_name,
          start_date, end_date, is_current,
          responsibilities_and_achievements
        ) VALUES (
          @resume_id, @company_name,
          @start_date, @end_date, @is_current,
          @responsibilities_and_achievements
        )
        RETURNING *
      '''),
      parameters: {
        'resume_id': resumeId,
        'company_name': companyName,
        'start_date': startDate,
        'end_date': endDate,
        'is_current': isCurrent ?? false,
        'responsibilities_and_achievements': responsibilitiesAndAchievements,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create resume experience');
    }

    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> updateResumeExperience({
    required int experienceId,
    required int resumeId,
    required int userId,
    String? companyName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    String? responsibilitiesAndAchievements,
  }) async {
    // Проверяем, что резюме принадлежит пользователю и опыт связан с этим резюме
    final ownerResult = await _connection.execute(
      Sql.named('''
        SELECT r.user_id
        FROM jobs_resumes r
        INNER JOIN jobs_resume_experiences e ON e.resume_id = r.id
        WHERE r.id = @resume_id AND e.id = @experience_id
      '''),
      parameters: {'resume_id': resumeId, 'experience_id': experienceId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      return null;
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{
      'id': experienceId,
    };

    void setField(String column, String param, dynamic value) {
      updates.add('$column = @$param');
      parameters[param] = value;
    }

    if (companyName != null) setField('company_name', 'company_name', companyName);
    if (startDate != null) setField('start_date', 'start_date', startDate);
    if (endDate != null) setField('end_date', 'end_date', endDate);
    if (isCurrent != null) setField('is_current', 'is_current', isCurrent);
    if (responsibilitiesAndAchievements != null) setField('responsibilities_and_achievements', 'responsibilities_and_achievements', responsibilitiesAndAchievements);

    if (updates.isEmpty) {
      final res = await _connection.execute(
        Sql.named('SELECT * FROM jobs_resume_experiences WHERE id = @id'),
        parameters: {'id': experienceId},
      );
      if (res.isEmpty) return null;
      return res.first.toColumnMap();
    }

    await _connection.execute(
      Sql.named('UPDATE jobs_resume_experiences SET ${updates.join(', ')} WHERE id = @id'),
      parameters: parameters,
    );

    final res = await _connection.execute(
      Sql.named('SELECT * FROM jobs_resume_experiences WHERE id = @id'),
      parameters: {'id': experienceId},
    );
    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  Future<bool> deleteResumeExperience({
    required int experienceId,
    required int resumeId,
    required int userId,
  }) async {
    // Проверяем, что резюме принадлежит пользователю и опыт связан с этим резюме
    final ownerResult = await _connection.execute(
      Sql.named('''
        SELECT r.user_id
        FROM jobs_resumes r
        INNER JOIN jobs_resume_experiences e ON e.resume_id = r.id
        WHERE r.id = @resume_id AND e.id = @experience_id
      '''),
      parameters: {'resume_id': resumeId, 'experience_id': experienceId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      return false;
    }

    await _connection.execute(
      Sql.named('DELETE FROM jobs_resume_experiences WHERE id = @id'),
      parameters: {'id': experienceId},
    );

    return true;
  }

  // ============================================
  // ОБРАЗОВАНИЕ В РЕЗЮМЕ
  // ============================================

  Future<List<Map<String, dynamic>>> getResumeEducations(int resumeId, {int? userId}) async {
    // Просмотр образования доступен всем (работодатель смотрит резюме кандидата по отклику)
    final result = await _connection.execute(
      Sql.named('''
        SELECT *
        FROM jobs_resume_educations
        WHERE resume_id = @resume_id
        ORDER BY year_end DESC NULLS LAST, year_start DESC NULLS LAST, id DESC
      '''),
      parameters: {'resume_id': resumeId},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>> createResumeEducation({
    required int resumeId,
    required int userId,
    required String institution,
    String? speciality,
    int? yearStart,
    int? yearEnd,
    bool? isCurrent,
  }) async {
    // Проверяем, что резюме принадлежит пользователю
    final ownerResult = await _connection.execute(
      Sql.named('SELECT user_id FROM jobs_resumes WHERE id = @id'),
      parameters: {'id': resumeId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      throw Exception('You do not have permission to modify this resume');
    }

    final result = await _connection.execute(
      Sql.named('''
        INSERT INTO jobs_resume_educations (
          resume_id, institution, speciality, year_start, year_end, is_current
        ) VALUES (
          @resume_id, @institution, @speciality, @year_start, @year_end, @is_current
        )
        RETURNING *
      '''),
      parameters: {
        'resume_id': resumeId,
        'institution': institution,
        'speciality': speciality,
        'year_start': yearStart,
        'year_end': yearEnd,
        'is_current': isCurrent ?? false,
      },
    );

    if (result.isEmpty) {
      throw Exception('Failed to create resume education');
    }

    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> updateResumeEducation({
    required int educationId,
    required int resumeId,
    required int userId,
    String? institution,
    String? speciality,
    int? yearStart,
    int? yearEnd,
    bool? isCurrent,
  }) async {
    // Проверяем, что резюме принадлежит пользователю и образование связано с этим резюме
    final ownerResult = await _connection.execute(
      Sql.named('''
        SELECT r.user_id
        FROM jobs_resumes r
        INNER JOIN jobs_resume_educations e ON e.resume_id = r.id
        WHERE r.id = @resume_id AND e.id = @education_id
      '''),
      parameters: {'resume_id': resumeId, 'education_id': educationId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      return null;
    }

    final updates = <String>[];
    final parameters = <String, dynamic>{
      'id': educationId,
    };

    void setField(String column, String param, dynamic value) {
      updates.add('$column = @$param');
      parameters[param] = value;
    }

    if (institution != null) setField('institution', 'institution', institution);
    if (speciality != null) setField('speciality', 'speciality', speciality);
    if (yearStart != null) setField('year_start', 'year_start', yearStart);
    if (yearEnd != null) setField('year_end', 'year_end', yearEnd);
    if (isCurrent != null) setField('is_current', 'is_current', isCurrent);

    if (updates.isEmpty) {
      final res = await _connection.execute(
        Sql.named('SELECT * FROM jobs_resume_educations WHERE id = @id'),
        parameters: {'id': educationId},
      );
      if (res.isEmpty) return null;
      return res.first.toColumnMap();
    }

    await _connection.execute(
      Sql.named('UPDATE jobs_resume_educations SET ${updates.join(', ')} WHERE id = @id'),
      parameters: parameters,
    );

    final res = await _connection.execute(
      Sql.named('SELECT * FROM jobs_resume_educations WHERE id = @id'),
      parameters: {'id': educationId},
    );
    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  Future<bool> deleteResumeEducation({
    required int educationId,
    required int resumeId,
    required int userId,
  }) async {
    // Проверяем, что резюме принадлежит пользователю и образование связано с этим резюме
    final ownerResult = await _connection.execute(
      Sql.named('''
        SELECT r.user_id
        FROM jobs_resumes r
        INNER JOIN jobs_resume_educations e ON e.resume_id = r.id
        WHERE r.id = @resume_id AND e.id = @education_id
      '''),
      parameters: {'resume_id': resumeId, 'education_id': educationId},
    );
    if (ownerResult.isEmpty || (ownerResult.first[0] as int) != userId) {
      return false;
    }

    await _connection.execute(
      Sql.named('DELETE FROM jobs_resume_educations WHERE id = @id'),
      parameters: {'id': educationId},
    );

    return true;
  }
}
