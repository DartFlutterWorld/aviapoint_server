### Jobs API (Вакансии и резюме)

Все эндпоинты требуют `Authorization: Bearer <token>` (кроме общих списков, если вы решите сделать их публичными).
Ответы — `application/json`.

---

### 1. Вакансии

#### 1.1. Получить список вакансий

- **GET** `/api/jobs/vacancies`
- **Query-параметры** (все опциональные):
  - `employer_id` — ID работодателя (вернёт только вакансии этого пользователя, включая неопубликованные)
  - `search` — строка поиска (по `title`, `description`, `responsibilities`)
  - `city`
  - `experience_level` — `no_experience | 1_3 | 3_6 | 6_plus`
  - `employment_type` — `full_time | part_time | project | internship`
  - `schedule` — `office | remote | hybrid | shift | fly_in_fly_out`
  - `salary_from`, `salary_to` — числа
  - `include_inactive` — `true/false` (по умолчанию `false`, тогда отдаются только опубликованные и активные)
  - `limit`, `offset`

**Пример ответа (массив объектов):**

```json
{
  "id": 12,
  "employer_id": 5,
  "title": "Инженер по ТОиР ВС",
  "description": "Описание компании и позиции",
  "responsibilities": "Список обязанностей...",
  "requirements": "Требования...",
  "conditions": "Условия...",
  "salary_from": 150000,
  "salary_to": 220000,
  "currency": "RUB",
  "is_gross": true,
  "employment_type": "full_time",
  "schedule": "shift",
  "experience_level": "3_6",
  "education_level": "higher",
  "city": "Москва",
  "region": "Московская область",
  "airport_code": "UUEE",
  "is_remote": false,
  "relocation_allowed": true,
  "business_trips": "rarely",
  "aircraft_category": "commercial",
  "required_license": "AML",
  "min_flight_hours": null,
  "required_type_rating": null,
  "is_published": true,
  "is_active": true,
  "status": "published",
  "published_until": "2026-03-01T12:00:00.000Z",
  "views_count": 23,
  "responses_count": 4,
  "created_at": "2026-02-04T10:00:00.000Z",
  "updated_at": "2026-02-04T10:00:00.000Z",
  "employer_first_name": "Иван",
  "employer_last_name": "Иванов",
  "employer_phone": "+7...",
  "employer_telegram": "@ivan",
  "employer_max": "maxid"
}
```

#### 1.2. Детали вакансии

- **GET** `/api/jobs/vacancies/{id}`

Ответ — один объект, как выше. Внутри контроллера автоматически инкрементируется `views_count`.

#### 1.3. Создать вакансию

- **POST** `/api/jobs/vacancies`
- **Body (JSON)**:

```json
{
  "title": "Инженер по ТОиР ВС",
  "description": "Текст о компании",
  "responsibilities": "Текст обязанностей",
  "requirements": "Текст требований",
  "conditions": "Текст условий",
  "salary_from": 150000,
  "salary_to": 220000,
  "currency": "RUB",
  "is_gross": true,
  "employment_type": "full_time",
  "schedule": "shift",
  "experience_level": "3_6",
  "education_level": "higher",
  "city": "Москва",
  "region": "Московская область",
  "airport_code": "UUEE",
  "is_remote": false,
  "relocation_allowed": true,
  "business_trips": "rarely",
  "aircraft_category": "commercial",
  "required_license": "AML",
  "min_flight_hours": null,
  "required_type_rating": null,
  "skills": ["CAMO", "EASA Part-145"]
}
```

Минимально обязательно поле: `title`.
Созданная вакансия уходит в статус `moderation`, `is_published = false`, `is_active = true`, `published_until` считается по `publication_settings` (по умолчанию 1 месяц).

#### 1.4. Обновить вакансию

- **PUT** `/api/jobs/vacancies/{id}`
- **Body (JSON)** — те же поля, все опциональны (patch-style).

Ответ — обновлённый объект вакансии.

#### 1.5. Публикация / снятие

- **POST** `/api/jobs/vacancies/{id}/publish`
- **POST** `/api/jobs/vacancies/{id}/unpublish`

Без тела. Ответ — объект вакансии после изменения статуса.

#### 1.6. Удаление вакансии

- **DELETE** `/api/jobs/vacancies/{id}`

Ответ:

```json
{ "message": "Vacancy deleted successfully" }
```

#### 1.7. Отклик на вакансию

- **POST** `/api/jobs/vacancies/{id}/responses`
- **Body (JSON)**:

```json
{
  "resume_id": 3,
  "cover_letter": "Текст сопроводительного письма"
}
```

Ответ — созданный отклик:

```json
{
  "id": 10,
  "vacancy_id": 5,
  "resume_id": 3,
  "candidate_id": 7,
  "status": "new",
  "cover_letter": "Текст сопроводительного письма",
  "created_at": "2026-02-04T10:10:00.000Z",
  "updated_at": "2026-02-04T10:10:00.000Z"
}
```

#### 1.8. Список откликов по вакансии (для работодателя)

- **GET** `/api/jobs/vacancies/{id}/responses`

Ответ — массив откликов с данными кандидата:

```json
{
  "id": 10,
  "vacancy_id": 5,
  "resume_id": 3,
  "candidate_id": 7,
  "status": "new",
  "cover_letter": "Текст...",
  "created_at": "...",
  "updated_at": "...",
  "candidate_first_name": "Иван",
  "candidate_last_name": "Иванов",
  "candidate_phone": "+7...",
  "candidate_telegram": "@ivan"
}
```

#### 1.9. Избранные вакансии

- **POST** `/api/jobs/vacancies/{id}/favorite`
- **DELETE** `/api/jobs/vacancies/{id}/favorite`
- **GET** `/api/jobs/vacancies/favorites?limit=&offset=`

Ответ GET — массив вакансий в том же формате, что `/api/jobs/vacancies`.

---

### 2. Резюме (общая карточка)

#### 2.1. Список резюме (поиск работодателем)

- **GET** `/api/jobs/resumes`
- **Query-параметры**:
  - `user_id` — ID пользователя (вернёт только резюме этого пользователя, все статусы — для раздела «Мои резюме»)
  - `search` — строка (по `title`, `about`, `current_position`)
  - `city`
  - `license` — фильтр по строке `licenses` (LIKE)
  - `aircraft_type` — фильтр по строке `type_ratings` (LIKE)
  - `limit`, `offset`

Ответ — массив объектов:

```json
{
  "id": 3,
  "user_id": 7,
  "title": "Пилот-инструктор C172",
  "about": "Краткое описание",
  "status": "active",
  "is_visible_for_employers": true,
  "desired_salary": 200000,
  "currency": "RUB",
  "employment_types": "full_time,project",
  "schedules": "office,remote",
  "ready_to_relocate": true,
  "ready_for_business_trips": true,
  "city": "Санкт-Петербург",
  "preferred_locations": "Москва, Европа",
  "current_position": "Пилот-инструктор",
  "current_company": "Аэроклуб",
  "total_experience_months": 72,
  "flight_hours_total": 2500,
  "flight_hours_pic": 1800,
  "licenses": "PPL, CPL, ATPL",
  "type_ratings": "C172, A320",
  "medical_class": "ВЛЭК 1",
  "allow_show_contacts_to_all": true,
  "created_at": "...",
  "updated_at": "...",
  "last_active_at": "...",
  "user_first_name": "Иван",
  "user_last_name": "Иванов",
  "user_phone": "+7...",
  "user_telegram": "@ivan"
}
```

#### 2.2. Детали резюме

- **GET** `/api/jobs/resumes/{id}`

Ответ — один объект как выше.

#### 2.3. Создание резюме

- **POST** `/api/jobs/resumes`
- **Body (JSON)**:

```json
{
  "title": "Инженер по ТОиР ВС",
  "about": "О себе...",
  "desired_salary": 150000,
  "currency": "RUB",
  "employment_types": "full_time,project",
  "schedules": "office,remote",
  "ready_to_relocate": true,
  "ready_for_business_trips": true,
  "city": "Новосибирск",
  "preferred_locations": "Москва, СПб",
  "current_position": "Инженер по ТО",
  "current_company": "АО Авиакомпания",
  "total_experience_months": 60,
  "flight_hours_total": 0,
  "flight_hours_pic": 0,
  "licenses": "AML",
  "type_ratings": "B737",
  "medical_class": "ВЛЭК 2"
}
```

Минимально обязательно поле — `title`.

#### 2.4. Обновление резюме

- **PUT** `/api/jobs/resumes/{id}`
- **Body (JSON)** — те же поля, все опциональны.

#### 2.5. Удаление резюме

- **DELETE** `/api/jobs/resumes/{id}`

Ответ:

```json
{ "message": "Resume deleted successfully" }
```

#### 2.6. Избранные резюме (для работодателя)

- **POST** `/api/jobs/resumes/{id}/favorite`
- **DELETE** `/api/jobs/resumes/{id}/favorite`
- **GET** `/api/jobs/resumes/favorites?limit=&offset=`

Ответ GET — массив резюме в формате `/api/jobs/resumes`.

---

### 3. Резюме: опыт работы

Опыт/образование управляются через отдельные эндпоинты, чтобы фронту было удобно делать отдельные формы/модалки.

#### 3.1. Список опыта

- **GET** `/api/jobs/resumes/{resumeId}/experiences`

Ответ — массив:

```json
{
  "id": 1,
  "resume_id": 3,
  "company_name": "АО Авиакомпания",
  "position": "Инженер по ТОиР ВС",
  "industry": "МРО",
  "start_date": "2020-01-01",
  "end_date": "2023-12-31",
  "is_current": false,
  "responsibilities": "Описание обязанностей",
  "achievements": "Достижения в цифрах"
}
```

#### 3.2. Добавить опыт

- **POST** `/api/jobs/resumes/{resumeId}/experiences`
- **Body (JSON)**:

```json
{
  "company_name": "АО Авиакомпания",
  "position": "Инженер по ТОиР ВС",
  "industry": "МРО",
  "start_date": "2020-01-01",
  "end_date": "2023-12-31",
  "is_current": false,
  "responsibilities": "Описание обязанностей",
  "achievements": "Описание достижений"
}
```

Обязательные поля: `company_name`, `position`. Даты в формате ISO (`YYYY-MM-DD`).

#### 3.3. Обновить опыт

- **PUT** `/api/jobs/resumes/{resumeId}/experiences/{experienceId}`
- **Body (JSON)** — любые поля из структуры опыта, все опциональные.

Ответ — обновлённый объект опыта.

#### 3.4. Удалить опыт

- **DELETE** `/api/jobs/resumes/{resumeId}/experiences/{experienceId}`

Ответ:

```json
{ "message": "Experience deleted successfully" }
```

---

### 4. Резюме: образование

#### 4.1. Список образований

- **GET** `/api/jobs/resumes/{resumeId}/educations`

Ответ — массив:

```json
{
  "id": 1,
  "resume_id": 3,
  "institution": "МГТУ ГА",
  "faculty": "Инженерный",
  "speciality": "Техническая эксплуатация ЛА и ДВС",
  "degree": "инженер",
  "graduation_year": 2018
}
```

#### 4.2. Добавить образование

- **POST** `/api/jobs/resumes/{resumeId}/educations`
- **Body (JSON)**:

```json
{
  "institution": "МГТУ ГА",
  "faculty": "Инженерный",
  "speciality": "Техническая эксплуатация ЛА и ДВС",
  "degree": "инженер",
  "graduation_year": 2018
}
```

Обязательное поле: `institution`.

#### 4.3. Обновить образование

- **PUT** `/api/jobs/resumes/{resumeId}/educations/{educationId}`
- **Body (JSON)** — любые поля структуры, всё опциональное.

#### 4.4. Удалить образование

- **DELETE** `/api/jobs/resumes/{resumeId}/educations/{educationId}`

Ответ:

```json
{ "message": "Education deleted successfully" }
```

---

### 5. Авторизация и доступы

- Все изменения (создание/обновление/удаление) проверяют, что:
  - Вакансия принадлежит текущему пользователю (`employer_id == userId`),
  - Резюме/опыт/образование принадлежат текущему пользователю (`user_id == userId`).
- Работодатель может:
  - Искать резюме,
  - Добавлять резюме в избранное,
  - Смотреть отклики на свои вакансии.

Фронту достаточно:

- Всегда слать JWT в `Authorization` (как в других модулях),
- Использовать JSON-схемы из этого файла для форм,
- Для редактирования резюме:
  - Сначала создать/обновить резюме (общая карточка),
  - Потом отдельно дергать эндпоинты для опыта и образования.

