--
-- PostgreSQL database dump
--

\restrict LevZripLeAjYINmbPRgtUNJMyuxiUzXCdeAf57POi4ufKuGBtZbftt3no4hVW30

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: airspeeds_for_emergency_operations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.airspeeds_for_emergency_operations (
    id integer NOT NULL,
    title text,
    name text NOT NULL,
    doing text NOT NULL
);


ALTER TABLE public.airspeeds_for_emergency_operations OWNER TO postgres;

--
-- Name: category_news; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_news (
    id integer NOT NULL,
    title text NOT NULL
);


ALTER TABLE public.category_news OWNER TO postgres;

--
-- Name: emergency_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emergency_categories (
    id integer NOT NULL,
    title text NOT NULL,
    main_category_id integer NOT NULL,
    title_eng text NOT NULL,
    picture text,
    sub_title text NOT NULL,
    sub_title_eng text NOT NULL
);


ALTER TABLE public.emergency_categories OWNER TO postgres;

--
-- Name: hand_book_main_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hand_book_main_categories (
    main_category_id integer DEFAULT 1 NOT NULL,
    title text NOT NULL,
    sub_title text NOT NULL,
    picture text NOT NULL
);


ALTER TABLE public.hand_book_main_categories OWNER TO postgres;

--
-- Name: stories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stories (
    id integer NOT NULL,
    image text,
    video text,
    text_button text NOT NULL,
    hyperlink text NOT NULL,
    time_show integer NOT NULL,
    "position" integer NOT NULL,
    color_button text NOT NULL,
    logo_story text NOT NULL,
    text_color text NOT NULL
);


ALTER TABLE public.stories OWNER TO postgres;

--
-- Name: mini_stories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mini_stories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mini_stories_id_seq OWNER TO postgres;

--
-- Name: mini_stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mini_stories_id_seq OWNED BY public.stories.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.news (
    id integer NOT NULL,
    title text NOT NULL,
    source text NOT NULL,
    date text NOT NULL,
    body text NOT NULL,
    picture_mini text NOT NULL,
    picture_big text NOT NULL,
    is_big_news boolean NOT NULL,
    category_id integer NOT NULL,
    sub_title text NOT NULL
);


ALTER TABLE public.news OWNER TO postgres;

--
-- Name: normal_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.normal_categories (
    id integer NOT NULL,
    title text NOT NULL,
    main_category_id integer NOT NULL,
    title_eng text NOT NULL,
    picture text NOT NULL,
    sub_title text NOT NULL
);


ALTER TABLE public.normal_categories OWNER TO postgres;

--
-- Name: normal_check_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.normal_check_list (
    id integer NOT NULL,
    normal_category_id integer NOT NULL,
    title text NOT NULL,
    doing text NOT NULL,
    picture text NOT NULL,
    title_eng text NOT NULL,
    doing_eng text NOT NULL,
    check_list boolean NOT NULL,
    sub_category text,
    sub_category_eng text
);


ALTER TABLE public.normal_check_list OWNER TO postgres;

--
-- Name: preflight_inspection_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preflight_inspection_categories (
    id integer NOT NULL,
    title text NOT NULL,
    main_category_id integer NOT NULL,
    title_eng text NOT NULL,
    picture text NOT NULL,
    sub_title text NOT NULL
);


ALTER TABLE public.preflight_inspection_categories OWNER TO postgres;

--
-- Name: preflight_inspection_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preflight_inspection_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.preflight_inspection_categories_id_seq OWNER TO postgres;

--
-- Name: preflight_inspection_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preflight_inspection_categories_id_seq OWNED BY public.preflight_inspection_categories.id;


--
-- Name: preflight_inspection_check_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preflight_inspection_check_list (
    id integer NOT NULL,
    preflight_inspection_category_id integer NOT NULL,
    title text NOT NULL,
    doing text NOT NULL,
    picture text NOT NULL,
    title_eng text NOT NULL,
    doing_eng text NOT NULL
);


ALTER TABLE public.preflight_inspection_check_list OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    first_name text,
    phone text NOT NULL,
    last_name text,
    email text,
    id integer NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profiles_id_seq OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- Name: question_type_certificates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.question_type_certificates (
    question_id integer NOT NULL,
    type_certificate_id integer NOT NULL,
    category_id integer
);


ALTER TABLE public.question_type_certificates OWNER TO postgres;

--
-- Name: rosaviatest_answers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rosaviatest_answers (
    question_id integer NOT NULL,
    answer_text text NOT NULL,
    is_correct boolean NOT NULL,
    is_official boolean NOT NULL,
    "position" integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.rosaviatest_answers OWNER TO postgres;

--
-- Name: rosaviatest_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rosaviatest_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rosaviatest_answers_id_seq OWNER TO postgres;

--
-- Name: rosaviatest_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rosaviatest_answers_id_seq OWNED BY public.rosaviatest_answers.id;


--
-- Name: rosaviatest_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rosaviatest_category (
    id integer NOT NULL,
    title text NOT NULL,
    image text NOT NULL
);


ALTER TABLE public.rosaviatest_category OWNER TO postgres;

--
-- Name: rosaviatest_question_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rosaviatest_question_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rosaviatest_question_category_id_seq OWNER TO postgres;

--
-- Name: rosaviatest_question_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rosaviatest_question_category_id_seq OWNED BY public.rosaviatest_category.id;


--
-- Name: rosaviatest_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rosaviatest_questions (
    id integer NOT NULL,
    title text NOT NULL,
    explanation text,
    correct_answer integer
);


ALTER TABLE public.rosaviatest_questions OWNER TO postgres;

--
-- Name: rosaviatest_type_certificates_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rosaviatest_type_certificates_category (
    type_sertificates_id integer NOT NULL,
    category_id integer NOT NULL,
    "position" integer NOT NULL
);


ALTER TABLE public.rosaviatest_type_certificates_category OWNER TO postgres;

--
-- Name: type_certificates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_certificates (
    id integer NOT NULL,
    title text NOT NULL,
    image text NOT NULL
);


ALTER TABLE public.type_certificates OWNER TO postgres;

--
-- Name: type_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.type_certificates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_certificates_id_seq OWNER TO postgres;

--
-- Name: type_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.type_certificates_id_seq OWNED BY public.type_certificates.id;


--
-- Name: type_correct_answers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_correct_answers (
    id integer NOT NULL,
    title text NOT NULL
);


ALTER TABLE public.type_correct_answers OWNER TO postgres;

--
-- Name: video; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video (
    id integer NOT NULL,
    title text NOT NULL,
    file_name text NOT NULL,
    url text NOT NULL
);


ALTER TABLE public.video OWNER TO postgres;

--
-- Name: preflight_inspection_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preflight_inspection_categories ALTER COLUMN id SET DEFAULT nextval('public.preflight_inspection_categories_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: rosaviatest_answers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosaviatest_answers ALTER COLUMN id SET DEFAULT nextval('public.rosaviatest_answers_id_seq'::regclass);


--
-- Name: rosaviatest_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosaviatest_category ALTER COLUMN id SET DEFAULT nextval('public.rosaviatest_question_category_id_seq'::regclass);


--
-- Name: stories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stories ALTER COLUMN id SET DEFAULT nextval('public.mini_stories_id_seq'::regclass);


--
-- Name: type_certificates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_certificates ALTER COLUMN id SET DEFAULT nextval('public.type_certificates_id_seq'::regclass);


--
-- Data for Name: airspeeds_for_emergency_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.airspeeds_for_emergency_operations (id, title, name, doing) FROM stdin;
1	Отказ двигателя после взлёта	Закрылки в положение UP (убраны)	70 KIAS
2	Отказ двигателя после взлёта	Закрылки в положении 10 - FULL (полностью выпущены)	65 KIAS
3	Скорость маневрирования	2550 фунтов	105 KIAS
4	Скорость маневрирования	2200 фунтов	98 KIAS
5	Скорость маневрирования	1900 фунтов	90 KIAS
7	\N	Вынужденная посадка с работающим двигателем	65 KIAS
6	\N	Оптимальная скорость планирования	68 KIAS
8	Посадка с неработающим двигателем	Закрылки в положении UP (убраны)	70 KIAS
9	Посадка с неработающим двигателем	Закрылки в положении 10 - FULL (полностью выпущены)	69 KIAS
\.


--
-- Data for Name: category_news; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_news (id, title) FROM stdin;
1	Частная
2	Гражданская
3	Военная
0	Свежие
\.


--
-- Data for Name: emergency_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emergency_categories (id, title, main_category_id, title_eng, picture, sub_title, sub_title_eng) FROM stdin;
1	ВОЗДУШНЫЕ СКОРОСТИ	3	AIRSPEEDS	\N	ВОЗДУШНЫЕ СКОРОСТИ В АВАРИЙНЫХ СИТУАЦИЯХ	AIRSPEEDS FOR EMERGENCY OPERATIONS
2	ОТКАЗ ДВИГАТЕЛЯ	3	ENGINE FAILURES	\N		
3	ВЫНУЖДЕННАЯ ПОСАДКА	3	FORCED LANDINGS	\N		
4	ПОЖАР	3	FIRES	\N		
5	ОБЛЕДЕНЕНИЕ	3	ICING	\N		
6	ЗАКУПОРИВАНИЕ ПРИЕМНИКА СТАТИЧЕСКОГО ДАВЛЕНИЯ	3	STATIC SOURCE BLOCKAGE	\N		
7	ИЗБЫТОЧНОЕ КОЛИЧЕСТВО ПАРА В ТОПЛИВЕ	3	EXCESSIVE FUEL VAPOR	\N		
9	НЕИСПРАВНОСТИ СИСТЕМЫ ЭЛЕКТРОСНАБЖЕНИЯ	3	ELECTRICAL POWER SUPPLY SYSTEM MALFUNCTIONS	\N		
10	ОТКАЗ СИСТЕМЫ ВОЗДУШНЫХ СИГНАЛОВ	3	AIR DATA SYSTEM FAILURE	\N		
11	ОТКАЗ КУРСОВЕРТИКАЛИ (AHRS)	3	ATTITUDE AND HEADING REFERENCE SYSTEM (AHRS)	\N		
12	ОТКАЗ АВТОПИЛОТА ИЛИ ЭЛЕКТРИЧЕСКОЙ СИСТЕМЫ ТРИММИРОВАНИЯ	3	AUTOPILOT OR ELECTRIC TRIM FAILURE	\N		
13	ПРЕДУПРЕЖДЕНИЕ ОБ ОХЛАЖДЕНИИ ДИСПЛЕЕВ	3	DISPLAY COOLING ADVISORY	\N		
14	ОТКАЗ ВАКУУМНОЙ СИСТЕМЫ	3	VACUUM SYSTEM FAILURE	\N		
15	ПРЕДУПРЕЖДЕНИЕ О ПОВЫШЕННОМ СОДЕРЖАНИИ УГАРНОГО ГАЗА (CO)	3	HIGH CARBON MONOXIDE (CO) LEVEL ADVISORY	\N		
8	ОСОБЫЕ СЛУЧАИ ПРИ ПОСАДКЕ	3	ABNORMAL LANDINGS	\N		
\.


--
-- Data for Name: hand_book_main_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hand_book_main_categories (main_category_id, title, sub_title, picture) FROM stdin;
1	Предполётные процедуры	Предполётный осмотр	
2	Нормальные процедуры	Нормальные процедуры и карты контрольных проверок	
3	Аварийные процедуры	Аварийные процедуры	
4	Эксплуатационные ограничения	Эксплуатационные ограничения	
5	Лётные характеристики	Лётные характеристики	
\.


--
-- Data for Name: news; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.news (id, title, source, date, body, picture_mini, picture_big, is_big_news, category_id, sub_title) FROM stdin;
0	Неизвестные самолёты. Как Цессна погналась за Циррусом.	Дзен	03.08.2025	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна. Их машины летают давно и повсеместно. Цессну можно встретить в любом уголке мира.\r\n\r\nНо в основном это самолёты вроде знаменитой Цессна 172. \r\nТо есть цельнометаллические подкосные высокопланы, зачастую с неубирающимся шасси.\r\nКазалось бы, ну есть у вас модель- бестселлер, чего вы дёргаетесь? Клепайте ее побольше и получайте прибыль.\r\nНе тут-то было!\r\nУ боссов компании практически всегда чешутся руки сотворить что-то уникальное, неповторимое, да еще чтобы продавалось хорошо.\r\nЖаль, не всегда получается...\r\nТак было с моделью Цессна 177 Кардинал:\r\nЗамечательный в общем-то самолёт, но не пошел...\r\nПрошло пару десятков лет, и вот снова зачесалось. А тут еще и конкуренты не дремлют, выдавая на рынок всё новые и новые модели. Современные, красивые.	news/0/mini.png	news/0/big.png	t	1	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна.
1	Вертолёты. 	СуперДзен	04.08.2025	<p>Самая известная компания по производству легкомоторных самолётов конечно же, Цессна. Их машины летают давно и повсеместно. Цессну можно встретить в любом уголке мира.<p>\r\n\r\n<b>Но в основном это самолёты вроде знаменитой Цессна 172.</b> \r\nТо есть цельнометаллические подкосные высокопланы, зачастую с неубирающимся шасси.\r\nКазалось бы, ну есть у вас модель- бестселлер, чего вы дёргаетесь? Клепайте ее побольше и получайте прибыль.\r\nНе тут-то было!\r\nУ боссов компании практически всегда чешутся руки сотворить что-то уникальное, неповторимое, да еще чтобы продавалось хорошо.\r\nЖаль, не всегда получается...\r\nТак было с моделью Цессна 177 Кардинал:\r\nЗамечательный в общем-то самолёт, но не пошел...\r\nПрошло пару десятков лет, и вот снова зачесалось. А тут еще и конкуренты не дремлют, выдавая на рынок всё новые и новые модели. Современные, красивые.	news/1/mini.png	news/1/big.png	f	1	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна.
2	Неизвестные самолёты. Как Цессна погналась за Циррусом.	Дзен	03.08.2025	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна. Их машины летают давно и повсеместно. Цессну можно встретить в любом уголке мира.\r\n\r\nНо в основном это самолёты вроде знаменитой Цессна 172. \r\nТо есть цельнометаллические подкосные высокопланы, зачастую с неубирающимся шасси.\r\nКазалось бы, ну есть у вас модель- бестселлер, чего вы дёргаетесь? Клепайте ее побольше и получайте прибыль.\r\nНе тут-то было!\r\nУ боссов компании практически всегда чешутся руки сотворить что-то уникальное, неповторимое, да еще чтобы продавалось хорошо.\r\nЖаль, не всегда получается...\r\nТак было с моделью Цессна 177 Кардинал:\r\nЗамечательный в общем-то самолёт, но не пошел...\r\nПрошло пару десятков лет, и вот снова зачесалось. А тут еще и конкуренты не дремлют, выдавая на рынок всё новые и новые модели. Современные, красивые.	news/0/mini.png	news/0/big.png	t	1	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна.
3	Неизвестные самолёты. Как Цессна погналась за Циррусом.	Дзен	03.08.2025	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна. Их машины летают давно и повсеместно. Цессну можно встретить в любом уголке мира.\r\n\r\nНо в основном это самолёты вроде знаменитой Цессна 172. \r\nТо есть цельнометаллические подкосные высокопланы, зачастую с неубирающимся шасси.\r\nКазалось бы, ну есть у вас модель- бестселлер, чего вы дёргаетесь? Клепайте ее побольше и получайте прибыль.\r\nНе тут-то было!\r\nУ боссов компании практически всегда чешутся руки сотворить что-то уникальное, неповторимое, да еще чтобы продавалось хорошо.\r\nЖаль, не всегда получается...\r\nТак было с моделью Цессна 177 Кардинал:\r\nЗамечательный в общем-то самолёт, но не пошел...\r\nПрошло пару десятков лет, и вот снова зачесалось. А тут еще и конкуренты не дремлют, выдавая на рынок всё новые и новые модели. Современные, красивые.	news/0/mini.png	news/0/big.png	t	1	Самая известная компания по производству легкомоторных самолётов конечно же, Цессна.
\.


--
-- Data for Name: normal_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.normal_categories (id, title, main_category_id, title_eng, picture, sub_title) FROM stdin;
10	Процедура крейсерского полёта	2	Cruise procedure		Процедура крейсерского полёта
11	Процедура перед снижением	2	Before descent procedure		Процедура перед снижением
12	Процедура снижения	2	Descent procedure		Процедура снижения
13	Процедура снижения перед посадкой	2	Descent procedure before landing		Процедура снижения перед посадкой
14	Процедура перед посадкой	2	Before landing procedure		Процедура перед посадкой
15	Процедура нормальной посадки	2	Normal landing procedure		Процедура нормальной посадки
1	Процедура перед запуском двигателя	2	Before starting engine procedure		Процедура перед запуском двигателя самолёта
2	Процедура запуска двигателя (от аккумулятора)	2	Starting engine (with battery) procedure		Процедура запуска двигателя (от аккумулятора)
3	Процедура перед взлетом	2	Before take off procedure		Процедура перед взлетом
4	Процедура перед выруливанием	2	Before take off procedure		Процедура перед выруливанием
5	Процедура руления	2	Taxiing procedure		Процедура руления
6	Процедура на предварительном старте	2	At holding position procedure		Процедура на предварительном старте
7	Процедура на исполнительном старте	2	Lining up procedure		Процедура на исполнительном старте
8	Процедура нормального взлёта	2	Normal take off procedure		Процедура нормального взлёта
9	Процедура набора высоты	2	Climbing procedure		Процедура набора высоты
16	Процедура ухода на второй круг	2	Balked landing procedure		Процедура ухода на второй круг
17	Процедура после посадки	2	After landing procedure		Процедура после посадки
18	Процедура выключения двигателя	2	Engine shutdown procedure		Процедура выключения двигателя
19	Процедура обеспечения безопасности самолёта	2	Secure procedure		Процедура обеспечения безопасности самолёта
\.


--
-- Data for Name: normal_check_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.normal_check_list (id, normal_category_id, title, doing, picture, title_eng, doing_eng, check_list, sub_category, sub_category_eng) FROM stdin;
3	2	ВОЛЬТМЕТР ОСНОВНОЙ\r\nШИНЫ BUS E VOLTS	ПРОВЕРИТЬ\r\n(убедитесь в наличии показаний 24 VOLTS или более)	normal/starting_engine/3.png	BUS E VOLTS	CHECK\r\n(verify 24 VOLTS minimum shown)	f		
4	2	ВОЛЬТМЕТР ГЛАВНОЙ\r\nШИНЫ M BUS VOLTS	ПРОВЕРИТЬ (убедитесь в наличии показаний 1,5 VOLTS или менее)	normal/starting_engine/4.png	M BUS VOLTS	CHECK (verify 1.5 VOLTS or less shown)	f		
5	2	АМПЕРМЕТР РЕЗЕРВНОЙ БАТАРЕИ BATT S AMPS	ПРОВЕРИТЬ (убедиться в наличии тока разряда (отрицательного))	normal/starting_engine/5.png	BATT S AMPS	CHECK (verify discharge shown (negative))	f		
6	2	СИГНАЛ-Р РЕЗЕРВНОЙ БАТАРЕИ STBY BATT	ПРОВЕРИТЬ (убедитесь, что символ сигнал-ра горит на экране)	normal/starting_engine/6.png	STBY BATT ANNUNCIATOR	CHECK (verify annunciator is shown)	f		
7	2	ОСНОВНОЙ ПЕРЕКЛЮЧАТЕЛЬ MASTER (ГЕН-Р И АККУМ-Р)	ON (вкл.)	normal/starting_engine/7.png	MASTER SWITCH (ALT and BAT)	ON	f		
8	2	ВЫКЛЮЧАТЕЛЬ ПРОБЛЕСКОВОГО МАЯКА BEACON	ON (вкл.)	normal/starting_engine/8.png	BEACON LIGHT SWITCH	ON	f		
4	1	ТОРМОЗА	ПРОВЕРИТЬ И УСТАНОВИТЬ	normal/preflight/4.png			f		
9	2	УПРАВЛЕНИЕ ГАЗОМ	ОТКРЫТЬ НА 1/4 INCH	normal/starting_engine/9.png	THROTTLE CONTROL	OPEN 1/4 INCH	f		
6	1	ЭЛЕКТРИЧЕСКОЕ ОБОРУДОВАНИЕ	ОТКЛЮЧИТЬ	normal/preflight/6.png			f		
7	1	ПЕРЕКЛЮЧАТЕЛИ АВИОНИКИ	OFF (выкл.)	normal/preflight/7.png			f		
8	1	ПЕРЕКЛЮЧАТЕЛЬ ТОПЛИВНЫХ БАКОВ FUEL SELECTOR	ВОТН (оба)	normal/preflight/8.png			f		
9	1	ТОПЛИВНЫЙ КРАН FUEL SHUTOFF	ON (вкл.) (от себя до упора)	normal/preflight/9.png			f		
10	1	ПРЕДПОЛЕТНЫЙ ОСМОТР	ВЫПОЛНЕН	normal/preflight/10.png			t		
16	2	УПРАВЛЕНИЕ ГАЗОМ	УСТАНОВЛЕНО		THROTTLE CONTROL	SET	t		
17	2	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ПОДАЧА ПРЕКРАЩЕНА		MIXTURE CONTROL	IDLE CUTOFF	t		
10	2	ФРИКЦ-Й СТОПОР РЫЧАГА УПР-Я ГАЗОМ	ОТРЕГУЛИРОВАТЬ	normal/starting_engine/10.png	THROTTLE CONTROL FRICTION	ADJUST	f		
11	2	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ПРЕКРАЩЕНИЕ ПОДАЧИ\r\n(на себя до упора)	normal/starting_engine/11.png	MIXTURE CONTROL	IDLE CUTOFF (pull full out)	f		
12	2	ВЫКЛЮЧАТЕЛЬ РЕЗЕРВНОГО АККУМУЛЯТОРА	ARM		STBY BATT SWITCH	ARM	t		
13	2	ОСНОВНОЙ ПЕРЕКЛЮЧАТЕЛЬ MASTER	ВКЛЮЧЕН		MASTER SWITCH	ON	t		
14	2	ВЫКЛЮЧАТЕЛЬ ПРОБЛЕСКОВОГО МАЯКА	ВКЛЮЧЕН		BEACON LIGHT	ON	t		
15	2	ПАРАМЕТРЫ ДВИГАТЕЛЯ	НЕТ КРАСНЫХ Х'в		ENGINE INDICATIONS	NO RED X's	t		
18	2	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ЗАПУСК	ЗАПРОСИТЬ	normal/starting_engine/12.png	ATC START UP CLEARANCE	Request	f		
19	2	РАДИО ЧАСТОТА АТИС	УСТАНОВИТЬ	normal/starting_engine/13.png	COM ATIS Frequency	SET	f		
20	2	ИНФОРМАЦИЯ АТИС	ЗАПИСАТЬ	normal/starting_engine/14.png	ATIS Information	COPY	f		
21	2	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	УСТАНОВИТЬ И ЗАПРОСИТЬ	normal/starting_engine/15.png	COM ATC «GROUND»	SET AND REQUEST	f		
2	1	ИНСТРУКТАЖ ПАССАЖИРОВ	ПРОВЕСТИ	normal/preflight/2.png			f		
22	2	ЗОНА ВИНТА 	СВОБОДНА (убедитесь, что все люди и оборудование находятся на безопасном расстоянии от винта)	normal/starting_engine/16.png	PROPELLER AREA	CLEAR (verify that all people and equipment are at a safe distance from the propeller)	f		
23	2	Откройте окно, громко и чётко крикните "ОТ ВИНТА"	ВЫПОЛНИТЬ	normal/starting_engine/17.png	Open the window, shout loudly and clearly "CLEAR PROP"	DO	f		
3	1	КРЕСЛА И РЕМНИ БЕЗОПАСНОСТИ	ОТРЕГУЛИРОВАТЬ И ЗАСТЕГНУТЬ	normal/preflight/3.png			f		
1	1	ПРЕДПОЛЕТНАЯ ПРОВЕРКА	ВЫПОЛНИТЬ	normal/preflight/1.png			f		
17	1	ПОЖАРНЫЙ КРАН	ОТ СЕБЯ ДО УПОРА, ОТКРЫТ	normal/preflight/17.png			t		
4	4	РЕЗЕРВНЫЙ ВЫСОТОМЕР	ПРОВЕРИТЬ	normal/before_taxi/4.png	BACKUP ALTIMETER	CHECK	f	РЕЗЕРВНЫЕ ПИЛОТАЖНЫЕ ПРИБОРЫ	STANDBY FLIGHT INSTRUMENTS
5	1	АВТОМАТЫ ЗАЩИТЫ СЕТИ	ПРОВЕРИТЬ ВКЛЮЧЕНИЕ	normal/preflight/5.png			f		
11	1	СТОЯНОЧНЫЙ ТОРМОЗ	УСТАНОВЛЕН	normal/preflight/11.png			t		
12	1	ДВЕРИ	ЗАКРЫТЫ И ЗАБЛОКИРОВАНЫ	normal/preflight/12.png			t		
13	1	РУЛИ УПРАВЛЕНИЯ	СВОБОДНО И ПРАВИЛЬНО	normal/preflight/13.png			t		
14	1	ВЫКЛЮЧАТЕЛИ АВИОНИКИ	ВЫКЛЮЧЕНЫ	normal/preflight/14.png			t		
15	1	ПРЕДОХРАНИТЕЛИ	ВКЛЮЧЕНЫ, ОТ СЕБЯ ДО УПОРА	normal/preflight/15.png			t		
16	1	РЕЗЕРВНАЯ СТАТИКА	ОТ СЕБЯ ДО УПОРА, ЗАКРЫТ	normal/preflight/16.png			t		
18	1	ТОПЛИВНЫЙ КРАН	ПОЛОЖЕНИЕ ОБА	normal/preflight/18.png			t		
19	1	СИДЕНЬЯ И РЕМНИ	ПРОВЕРЕНЫ	normal/preflight/19.png			t		
2	2	СИСТЕМА ИНДИКАЦИИ ПАРАМЕТРОВ ДВИГАТЕЛЯ	ПРОВЕРИТЬ ПАРАМЕТРЫ\r\n(убедитесь в отсутствии красных символов Х на индикаторах страницы ENGINE (двигатель))	normal/starting_engine/2.png	ENGINE INDICATING SYSTEM	CHECK PARAMETERS\r\n(verify no red X's through ENGINE page indicators)	f		
1	3	СРОК ДЕЙСТВИЯ НАВИГАЦИОННЫХ БАЗ	ПРОВЕРИТЬ	normal/before_take_off/1.png	DATA BASES on MFD	CHECK	f		
8	4	УКАЗАТЕЛЬ ВАКУУМА - В ЗЕЛЕНОМ СЕКТОРЕ	ПРОВЕРИТЬ	normal/before_taxi/8.png	VAC INDICATOR - IN GREEN BAND	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
13	4	ВОЛЬТМЕТР (M - BUS - E) - 27-29 В	ПРОВЕРИТЬ	normal/before_taxi/13.png	VOLTMS (M - BUS - E) - 27-29 V	CHECK	f	ПРОВЕРКА ГЕНЕРАТОРА	ALTERNATOR CHECK
15	4	ЭЛЕКТРИЧЕСКОЕ ОБОРУДОВАНИЕ	OFF (выкл.) (при необходимости)	normal/before_taxi/15.png	SWITCHED ELECTRICAL EQUIPMENT	OFF	f	ПРОВЕРКА ГЕНЕРАТОРА	ALTERNATOR CHECK
17	4	ДВИГАТЕЛЬ РАБОТАЕТ УСТОЙЧИВО п≥675 ОБ/МИН	ПРОВЕРИТЬ	normal/before_taxi/17.png	ENGINE IS RUNNING SMOOTHLY n≥675	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
18	4	«LOW VOLTS» СИГНАЛИЗАЦИЯ ОТСУТСТВУЕТ	ПРОВЕРИТЬ	normal/before_taxi/18.png	«LOW VOLTS» ANNUNCIATOR IS NOT	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
19	4	ОБОРОТЫ 850...950 ОБ/МИН	УСТАНОВИТЬ	normal/before_taxi/19.png	REVOLUTION 850...950 RPM	SET	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
22	4	ИНФОРМАЦИЯ АТИС	ЗАПИСАТЬ	normal/before_taxi/22.png	ATIS Information	COPY	f		
25	4	СТОЯНОЧНЫЙ ТОРМОЗ	СНЯТЬ	normal/before_taxi/25.png	PARKING BRAKE	CLEAR	f		
24	2	ПРИМЕЧАНИЕ! Если двигатель прогрет, пропустите пункты 24-26.\r\n\r\nВЫКЛЮЧАТЕЛЬ ТОПЛИВНОГО НАСОСА FUEL PUMP	ON (вкл.)	normal/starting_engine/18.png	NOTE! If engine is warm, omit priming procedure steps 24 thru 26 below.\r\n\r\nFUEL PUMP SWITCH	ON	f		
26	2	ПРИМЕЧАНИЕ! Если двигатель прогрет, пропустите пункт\r\n\r\nВЫКЛЮЧАТЕЛЬ ТОПЛИВНОГО НАСОСА	OFF (выкл.)	normal/starting_engine/20.png	FUEL PUMP SWITCH	OFF	f		
27	2	ПЕРЕКЛЮЧАТЕЛЬ МАГНЕТО MAGNETOS	START (запуск)\r\n(Отпустите после запуска двигателя)	normal/starting_engine/21.png	MAGNETOS SWITCH	START\r\n(release when engine starts)	f		
28	2	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ПЛАВНО ПЕРЕВЕСТИ В ПОЛОЖЕНИЕ ОБОГАЩЕННОГО СОСТАВА (после запуска двигателя)	normal/starting_engine/22.png	MIXTURE CONTROL	ADVANCE SMOOTHLY TO RICH\r\n(when engine starts)	f		
32	2	Выключатель авионики AVIONICS (BUS 1 и BUS 2) (Шина 1 и Шина 2)	ON (вкл.)	normal/starting_engine/26.png	AVIONICS SWITCH (BUS 1 и BUS 2)	ON	f		
2	3	КНОПКА ВКЛЮЧЕНИЯ MFD	НАЖАТЬ	normal/before_take_off/2.png	MFD «FMS Key»	PRESS	f		
3	3	APK KR 87	ВКЛЮЧИТЬ	normal/before_take_off/3.png	ADF KR 87	ON	f		
2	4	РЕЗЕРВНЫЙ УКАЗАТЕЛЬ СКОРОСТИ	ПРОВЕРИТЬ	normal/before_taxi/2.png	BACKUP AIRSPEED INDICATOR	CHECK	f	РЕЗЕРВНЫЕ ПИЛОТАЖНЫЕ ПРИБОРЫ	STANDBY FLIGHT INSTRUMENTS
5	4	ТЕМПЕРАТУРА МАСЛА - В ЗЕЛЕНОМ СЕКТОРЕ	ПРОВЕРИТЬ	normal/before_taxi/5.png	OIL TEMPERATURE - IN GREEN BAND	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
7	4	ПЕРЕКЛЮЧАТЕЛЬ МАГНЕТО - ПРАВ И ЛЕВ (уменьшение количества оборотов в минуту не должно превышать 175 ОБ/МИН на любом из магнето и разницы 50 ОБ/МИН	ПРОВЕРИТЬ	normal/before_taxi/7.png	MAGNETOS SWITCH - R AND L (RPM drop should not exceed 175 RPM on either magneto or 50 RPM differential between magnetos)	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
1	2	ВЫКЛЮЧАТЕЛЬ РЕЗЕРВНОЙ АККУМУЛЯТОРНОЙ БАТАРЕИ STBY BATT	а) положение TEST (проверка) - (удерживайте в течение 10 секунд, убедитесь, что зеленая лампа TEST не выключается)\r\n\r\nb) положение ARM (состояние готовности) - (убедитесь, что основной пилотажный дисплей включается)	normal/starting_engine/1.png	1. STBY BATT SWITCH:	a) TEST - (hold for 10 seconds, verify that green TEST lamp does not go off)\r\n\r\nb) ARM - (verify that PFD comes on)	f		
33	2	Выключатель навигационных огней NAV	ВКЛЮЧИТЬ\r\n(при необходимости)	normal/starting_engine/27.png	NAV LIGHT SWITCH	ON AS REQUIRED	f		
10	4	ПОКАЗАНИЯ АМПЕРМЕТРА И ВОЛЬТМЕТРА	ПРОВЕРИТЬ	normal/before_taxi/10.png	AMMETERS AND VOLTMETERS	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
12	4	АМПЕРМЕТР (M - BATT - S) - ТОК ЗАРЯДА	ПРОВЕРИТЬ	normal/before_taxi/12.png	AMPS (M - BATT - S) - POSITIVE	CHECK	f	ПРОВЕРКА ГЕНЕРАТОРА	ALTERNATOR CHECK
16	4	УПРАВЛЕНИЕ ГАЗОМ - МГ	УСТАНОВИТЬ	normal/before_taxi/16.png	THROTTLE CONTROL - IDLE	SET	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
4	3	ПИЛОТАЖНЫЕ ПРИБОРЫ	ПРОВЕРИТЬ (отсутствие красных символов Х)	normal/before_take_off/4.png	PFD, MFD FLIGHT INSTRUMENTS	CHECK (no red X's)	f		
1	4	РЕЗЕРВНЫЙ КОМПАС	ПРОВЕРИТЬ	normal/before_taxi/1.png	BACKUP COMPASS	CHECK	f	РЕЗЕРВНЫЕ ПИЛОТАЖНЫЕ ПРИБОРЫ	STANDBY FLIGHT INSTRUMENTS
29	3	ПОКАЗАНИЯ АМПЕРМЕТРА И ВОЛЬТМЕТРА	ПРОВЕРИТЬ	normal/before_take_off/29.png	AMMETERS AND VOLTMETERS	CHECK	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
31	3	ОКНО СТАТУСА НАВИГАЦИИ	НАСТРОИТЬ	normal/before_take_off/31.png	MFD DATA BAR FIELDS	SELECT	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
32	3	РАДИУС КАРТЫ	НАСТРОИТЬ	normal/before_take_off/32.png	RANGE	SET	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
33	3	GPS-OBS ИЛИ FPL	НАСТРОИТЬ	normal/before_take_off/33.png	GPS-OBS OR FPL	SET	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
34	3	ВЕКТОР ПУТЕВОЙ СКОРОСТИ	НАСТРОИТЬ	normal/before_take_off/34.png	TRACK VECTOR	SET	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
35	3	СИГНАЛ СПУТНИКОВ GPS	ПРОВЕРИТЬ	normal/before_take_off/35.png	GPS VALID SIGNALS	CHECK	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
3	4	РЕЗЕРВНЫЙ АВИАГОРИЗОНТ	ПРОВЕРИТЬ	normal/before_taxi/3.png	BACKUP GYRO	CHECK	f	РЕЗЕРВНЫЕ ПИЛОТАЖНЫЕ ПРИБОРЫ	STANDBY FLIGHT INSTRUMENTS
6	4	УПРАВЛЕНИЕ ГАЗОМ - 1800 ОБ/МИН	УСТАНОВИТЬ	normal/before_taxi/6.png	THROTTLE CONTROL - 1800 RPM	SET	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
9	4	ПАРАМЕТРЫ ДВИГАТЕЛЯ - В ЗЕЛЕНОМ СЕКТОРЕ	ПРОВЕРИТЬ	normal/before_taxi/9.png	ENGINE INDICATORS - IN GREEN BAND	CHECK	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
11	4	ВСЕ ЭЛЕКТРИЧЕСКОЕ ОБОРУДОВАНИЕ	ON (вкл.)	normal/before_taxi/11.png	ALL ELECTRICAL EQUIPMENT	ON	f	ПРОВЕРКА ГЕНЕРАТОРА	ALTERNATOR CHECK
21	4	РАДИО ЧАСТОТА АТИС	УСТАНОВИТЬ	normal/before_taxi/21.png	COM ATIS Frequency	SET	f		
23	4	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	УСТАНОВИТЬ	normal/before_taxi/23.png	COM ATC «GROUND»	SET	f		
30	2	АМПЕРМЕТР ГЛАВНОЙ И РЕЗЕРВНОЙ БАТАРЕИ AMPS (М ВАТТ И BATT S)	ПРОВЕРИТЬ (убедиться в наличии тока заряда (положительного))	normal/starting_engine/24.png	AMPS (M BATT and BATT S)	CHECK\r\n(verify charge shown (positive))	f		
31	2	СИГНАЛИЗАТОР НИЗКОГО НАПРЯЖЕНИЯ LOW VOLTS	ПРОВЕРИТЬ\r\n(убедитесь, что предупреждение сигнализатора отсутствует на экране)	normal/starting_engine/25.png	LOW VOLTS ANNUNCIATOR	CHECK\r\n(verify annunciator is not shown)	f		
5	3	АУДИОПАНЕЛЬ	НАСТРОИТЬ	normal/before_take_off/5.png	AUDIOPANEL (COM Sources)	SELECT	f		
6	3	АВТОПИЛОТ	ВКЛЮЧИТЬ	normal/before_take_off/6.png	AUTOPILOT	ENGAGE	f		
7	3	ОРГАНЫ УПРАВЛЕНИЯ	ПРОВЕРИТЬ (убедитесь в возможности пересилить автопилот по каналам крена и тангажа)	normal/before_take_off/7.png	FLIGHT CONTROLS	CHECK (autopilot can be overpowered in pitch and roll axes)	f		
9	3	КОМАНДНЫЕ ПЛАНКИ FD	УБРАТЬ	normal/before_take_off/9.png	FLIGHT DIRECTOR BY «FD KEY» on MFD	OFF	f		
10	3	УПРАВЛЕНИЕ ТРИММИРОВАНИЕМ РУЛЯ высоты	УСТАНОВИТЬ (в положение для взлета)	normal/before_take_off/10.png	ELEVATOR TRIM CONTROL - T/O POSITION	SET	f		
11	3	ЗАКРЫЛКИ В ПОЛОЖЕНИИ «0-10°-20°-ПОЛНОСТЬЮ»	ПРОВЕРИТЬ	normal/before_take_off/11.png	FLAPS CONTROL «UP-10°-20°-FULL»	CHECK	f		
12	3	ЧАСТОТЫ АРК KR 87	НАСТРОИТЬ И ПРОВЕРИТЬ	normal/before_take_off/12.png	ADF KR 87 FREQUENCY(S)	SET and CHECK	f		
27	3	НАВИГАЦИОННЫЕ И РАДИО ЧАСТОТЫ	ПРОВЕРИТЬ	normal/before_take_off/27.png	NAV AND COM FREQUENCY(S)	CHECK	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
28	3	ПАРАМЕТРЫ ДВИГАТЕЛЯ - В ЗЕЛЕНОМ СЕКТОРЕ	ПРОВЕРИТЬ	normal/before_take_off/28.png	ENGINE INDICATORS - IN GREEN BAND	CHECK	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
13	3	НАВИГАЦИОННЫЕ ЧАСТОТЫ	НАСТРОИТЬ	normal/before_take_off/13.png	NAV FREQUENCY(S)	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
14	3	КАРТА ВСТАВКА, РАДИУС	НАСТРОИТЬ	normal/before_take_off/14.png	INSET, RANGE	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
15	3	ТЕМПЕРАТУРА НАРУЖНОГО ВОЗДУХА	ПРОВЕРИТЬ	normal/before_take_off/15.png	OAT	CHECK	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
16	3	КУРС ВЗЛЕТА	УСТАНОВИТЬ	normal/before_take_off/16.png	HDG - T/O HEADING	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
17	3	ПАРАМЕТРЫ ВЕТРА	ВЫБРАТЬ	normal/before_take_off/17.png	OPTION WIND	SELECT	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
18	3	ДАЛЬНОМЕР	ВЫБРАТЬ	normal/before_take_off/18.png	DME	SELECT	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
19	3	ПЕЛЕНГ 1	ВЫБРАТЬ	normal/before_take_off/19.png	BERING 1	SELECT	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
21	3	НАВИГАЦИОННЫЙ ИСТОЧНИК	ВЫБРАТЬ	normal/before_take_off/21.png	CDI - NAV Source	SELECT	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
22	3	ЗАДАТЧИК ТРЕБУЕМОЙ ВЫСОТЫ	УСТАНОВИТЬ	normal/before_take_off/22.png	ALT SELECTED - AS DESIRED	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
24	3	КОД ОТВЕТЧИКА	УСТАНОВИТЬ И ПРОВЕРИТЬ	normal/before_take_off/24.png	XPDR CODE	SET and CHECK	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
25	3	БАРОМИНИМУМ	УСТАНОВИТЬ	normal/before_take_off/25.png	MINIMUNS BARO	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
26	3	РАДИОЧАСТОТЫ	НАСТРОИТЬ	normal/before_take_off/26.png	COM FREQUENCY(S)	SET	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
33	4	РЕЗЕРВНЫЕ ПРИБОРЫ	ПРОВЕРЕНЫ		STBY INSTRUMENTS	CHECKED	t		
36	4	ЗАКРЫЛКИ	ПРОВЕРЕНЫ		FLAPS	CHECKED	t		
1	5	ЗОНА РУЛЕНИЯ	ПРОВЕРИТЬ	normal/taxiing/1.png	AREA TAXIING	CHECK	f		
2	5	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	ЗАПРОСИТЬ	normal/taxiing/2.png	COM ATC «GROUND»	REQUEST	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ВЫРУЛИВАНИЕ	ATC TAXI CLEARANCE
5	6	ТОРМОЗА	ПРОВЕРЕНЫ		BRAKES	CHECKED	t		
13	6	СЕКТОР ПОДХОДА	СВОБОДЕН	normal/at_holding_position/13.png	APPROACH SECTOR	CLEAR	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ЗАНЯТИЕ ИСПОЛНИТЕЛЬНОГО СТАРТА	ATC LINE UP CLEARANCE
17	6	ТОРМОЗА	РАСТОРМОЗИТЬ	normal/at_holding_position/17.png	BRAKES	RELEASE	f		
18	6	ОБОРОТЫ ≤ 1000 ОБ/МИН	УСТАНОВИТЬ И ПРОДОЛЖИТЬ РУЛЕНИЕ	normal/at_holding_position/18.png	REVOLUTION ≤ 1000 RPM	SET AND CONTINUE TAXI	f		
1	7	САМОЛЕТ	ОСТАНОВИТЬ ИСПОЛЬЗУЯ ТОРМОЗА	normal/lining_up/1.png	PLANE	STOP TO APPLY THE BRAKE	f		
4	7	СТРОБОСКОПИЧЕСКИЕ ОГНИ	ON (вкл.)		STROBE LIGHT	ON	t		
3	8	УПРАВЛЕНИЕ ГАЗОМ	FULL (полный газ) (от себя до упора)	normal/normal_take_off/3.png	THROTTLE CONTROL	FULL (push full in)	f		
27	4	НАВИГАЦИОННЫЕ ОГНИ	ON (вкл.)		NAV LIGHT	ON	t		
30	4	ОСТАТОК ТОПЛИВА	 ...ГАЛ, УСТАНОВЛЕН		FUEL QUANTITY	... GLS, SET	t		
31	4	АВТОПИЛОТ	ПРОВЕРЕН		AUTOPILOT	CHECKED	t		
34	4	СИСТЕМА УПРАВЛЕНИЯ ПОЛЁТОМ (НАВИГАЦИОННЫЙ ИСТОЧНИК, ВЫСОТА)	УСТАНОВЛЕНЫ		FMS (NAV SOURCE, ALTS)	SET	t		
37	4	ВНЕШНИЙ ИСТОЧНИК ПИТАНИЯ	ОТКЛЮЧЕН		EXTERNAL POWER	CLEAR	t		
3	5	ОБОРОТЫ 1200 ОБ/МИН	УСТАНОВИТЬ	normal/taxiing/3.png	REVOLUTION 1200 RPM	SET	f	ПРОВЕРКА ТОРМОЗОВ	CHECK BRAKES
4	5	ТОРМОЗА	ПРОВЕРИТЬ	normal/taxiing/4.png	BRAKES	CHECK	f	ПРОВЕРКА ТОРМОЗОВ	CHECK BRAKES
5	5	ОБОРОТЫ ≤ 1000 ОБ/МИН	УСТАНОВИТЬ И ПРОДОЛЖИТЬ РУЛЕНИЕ	normal/taxiing/5.png	REVOLUTION ≤ 1000 RPM	SET AND CONTINUE TAXI	f	ПРОВЕРКА ТОРМОЗОВ	CHECK BRAKES
1	6	САМОЛЕТ	ОСТАНОВИТЬ ИСПОЛЬЗУЯ ТОРМОЗА	normal/at_holding_position/1.png	PLANE	STOP TO APPLY THE BRAKE	f		
2	6	СТОЯНОЧНЫЙ ТОРМОЗ	УСТАНОВИТЬ (при необходимости)	normal/at_holding_position/2.png	PARKING BRAKE	SET (if necessary)	f		
8	6	ОКНА	ЗАКРЫТЫ И ЗАБЛОКИРОВАНЫ		WINDOWS	CLOSED AND LOCKED	t		
3	7	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	ON (вкл.)		LANDING (TAXI) LIGHT	ON	t		
6	7	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	ЗАПРОСИТЬ	normal/lining_up/6.png	COM ATC «GROUND»	REQUEST	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ВЗЛЕТ	ATC TAKE OFF CLEARANCE
1	8	ТОРМОЗА	ОТПУСТИТЬ	normal/normal_take_off/1.png	BRAKES	RELEASE	f		
2	8	ПЯТКИ	ОПУСТИТЬ НА ПОЛ	normal/normal_take_off/2.png	HEELS	PUT DOWN	f		
14	4	СИГНАЛИЗАТОРЫ - ОТСУТСТВУЮТ	ПРОВЕРИТЬ	normal/before_taxi/14.png	NO ANY ELECTRICAL ANNUNCIATORS	CHECK	f	ПРОВЕРКА ГЕНЕРАТОРА	ALTERNATOR CHECK
20	4	ФРИКЦИОННЫЙ СТОПОР РЫЧАГА УПРАВЛЕНИЯ ГАЗОМ	ОТРЕГУЛИРОВАТЬ (при необходимости)	normal/before_taxi/20.png	THROTTLE CONTROL FRICTION LOCK	ADJUST (if necessary)	f	ПРОВЕРКА ДВИГАТЕЛЯ	ENGINE CHECK
6	6	ТРИММЕР РУЛЯ ВЫСОТЫ	В ПОЛОЖЕНИИ ДЛЯ ВЗЛЕТА		ELEVATOR TRIM	T/O POSITION	t		
26	4	«LOW VOLTS»	ОТСУТСТВУЕТ		«LOW VOLTS»	OUT	t		
28	4	ПИЛОТАЖНЫЕ ПРИБОРЫ	НЕТ КРАСНЫХ Х'в		FLIGHT INSTRUMENTS	NO RED X'S	t		
32	4	ВЫСОТОМЕР	0, ... M6		ALTIMETERS	 0, ... Mb	t		
35	4	ФЛАЙТПЛАН	АКТИВИРОВАН		FPL	ACTIVATED	t		
38	4	ПАРКОВОЧНЫЙ ТОРМОЗ	СНЯТ		PARKING BRAKE	CLEAR	t		
3	6	ЗАКРЫЛКИ - 10°	УСТАНОВИТЬ	normal/at_holding_position/3.png	FLAPS - 10°	SET	f		
4	6	ОБОГРЕВ ПВД	ВКЛЮЧИТЬ (при необходимости)	normal/at_holding_position/4.png	PITOT HEAT	SET (if necessary)	f		
7	6	ПАРАМЕТРЫ ДВИГАТЕЛЯ	В ЗЕЛЕНОМ СЕКТОРЕ		ENGINE PARAMETERS	GREEN BANDS	t		
9	6	ЗАКРЫЛКИ	КАК ТРЕБУЕТСЯ		FLAPS	AS DESIRED	t		
15	6	РУЛЕЖНАЯ ФАРА	ON (вкл.)	normal/at_holding_position/15.png	TAXI LIGHT	ON	f		
16	6	СТРОБОСКОПИЧЕСКИЕ ОГНИ	ON (вкл.)	normal/at_holding_position/16.png	STROBE LIGHT	ON	f		
29	4	ПАРАМЕТРЫ ДВИГАТЕЛЯ	В ЗЕЛЕНОМ СЕКТОРЕ		ENGINE PARAMETERS	GREEN BANDS	t		
10	6	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ПОЛНОСТЬЮ ОБОГАЩЕНА		MIXTURE CONTROL	RICH	t		
4	8	НАПРАВЛЕНИЕ	ВЫДЕРЖИВАТЬ	normal/normal_take_off/4.png	DIRECTION	CONTROL	f		
11	6	ОБОГРЕВ ПВД	КАК ТРЕБУЕТСЯ		PITOT HEAT	AS REQUIRED	t		
12	6	БРИФИНГ ПЕРЕД ВЗЛЁТОМ	ПРОВЕСТИ		TAKE OFF BRIEFING	COMPLETED	t		
14	6	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	ЗАПРОСИТЬ	normal/at_holding_position/14.png	COM ATC «GROUND»	REQUEST	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ЗАНЯТИЕ ИСПОЛНИТЕЛЬНОГО СТАРТА	ATC LINE UP CLEARANCE
4	11	ВЫСОТОМЕР/РЕЗЕР-Й ВЫСОТ-Р (при ПВП)	СЛИЧИТЬ	normal/before_descent/4.png	ALTIMETER /STBY ALT (when VFR)	COLLATE	f		
5	11	СИСТЕМА УПРАВЛЕНИЯ ПОЛЕТОМ FMS/GPS	ПРОАНАЛИЗИРОВАТЬ И НАСТРОИТЬ	normal/before_descent/5.png	FMS/GPS	REVIEW and BRIEF	f		
6	11	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	RICH (обогащенная смесь)	normal/before_descent/6.png	MIXTURE CONTROL	RICH	f		
7	11	ПЕРЕКЛЮЧАТЕЛЬ ТОПЛИВНЫХ БАКОВ FUEL SELECTOR	ВОТН (оба)	normal/before_descent/7.png	FUEL SELECTOR VALVE	BOTH	f		
8	11	КРЕСЛА И РЕМНИ БЕЗОПАСНОСТИ	ОТРЕГУЛИРОВАТЬ И ПРИСТЕГНУТЬ	normal/before_descent/8.png	SEATS AND BELTS	ADJUST and LOCK	f		
7	18	ТРИММЕР РУЛЯ ВЫСОТЫ - ВЗЛ ПОЛОЖЕНИЕ	ПРОВЕРИТЬ	normal/engine_shutdown/7.png	ELEVATOR TRIM - T/O POSITION	CHECK	f		
9	18	ЭЛЕКТРИЧЕСКОЕ ОБОРУДОВАНИЕ (КРОМЕ ПРОБЛЕСКОВОГО МАЯКА)	OFF (выкл.)	normal/engine_shutdown/9.png	ELECTRICAL EQUIPMENT (WITHOUT BEACON LIGHT)	OFF	f		
10	18	ПОДСВЕТКА	OFF (выкл.)	normal/engine_shutdown/10.png	DIMMING	OFF	f		
11	18	ПЕРЕКЛЮЧАТЕЛИ АВИОНИКИ	OFF (выкл.)	normal/engine_shutdown/11.png	AVIONICS SWITCHES	OFF	f		
12	18	ОСТАТОК ТОПЛИВА И НАРАБОТКУ ДВИГАТЕЛЯ	ЗАПИСАТЬ	normal/engine_shutdown/12.png	FUEL QUANTITY AND ENG HRS	COPY	f		
13	18	УПРАВЛЕНИЕ ГАЗОМ	ХОЛОСТОЙ ХОД (на себя до упора)	normal/engine_shutdown/13.png	THROTTLE CONTROL	IDLE (pull full out)	f		
14	18	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ПРЕКРАЩЕНИЕ ПОДАЧИ (на себя до упора)	normal/engine_shutdown/14.png	MIXTURE CONTROL	IDLE CUTOFF (pull full out)	f		
15	18	ОБОРОТЫ = 0	КЛЮЧ - В ПОЛОЖЕНИЕ OFF (выкл) и ВЫНУТЬ ИЗ ЗАМКА	normal/engine_shutdown/15.png	RPM = 0	KEY - OFF AND PULL OUT	f		
16	18	ВЫКЛЮЧАТЕЛЬ ПРОБЛЕСКОВОГО МАЯКА BEACON	OFF (выкл.)	normal/engine_shutdown/16.png	BEACON LIGHT SWITCH	OFF	f		
2	9	V набора высоты 80 КТ	УСТАНОВИТЬ	normal/climbing/2.png	V climb 80 KT	SET	f		
3	11	РЕЗЕРВНЫЙ ВЫСОТОМЕР (при ПВП)	QFE ... Мб	normal/before_descent/3.png	STBY ALT (when VFR)	QFE ... Mb	f		
18	18	ВЫКЛЮЧАТЕЛЬ РЕЗЕРВНОЙ БАТАРЕИ STBY BATT	OFF (выкл.)	normal/engine_shutdown/18.png	STBY BATT SWITCH	OFF	f		
19	18	МЕХАНИЗМ СТОПОРЕНИЯ РУЛЕЙ	УСТАНОВИТЬ	normal/engine_shutdown/19.png	CONTROL LOCK	SET	f		
20	18	ВЫКЛЮЧАТЕЛЬ РЕЗЕРВНОЙ БАТАРЕИ STBY BATT	OFF (выкл.)		STBY BATT SWITCH	OFF	t		
21	18	ОСНОВНОЙ ПЕРЕКЛЮЧАТЕЛЬ MASTER (генератор и аккумулятор)	OFF (выкл.)		MASTER SWITCH	OFF	t		
22	18	ПЕРЕКЛЮЧАТЕЛИ АВИОНИКИ	OFF (выкл.)		AVIONICS SWITCHES	OFF	t		
23	18	ЭЛЕКТРИЧЕСКОЕ ОБОРУДОВАНИЕ	OFF (выкл.)		ELECTRICAL EQUIPMENT	OFF	t		
24	18	МЕХАНИЗМ СТОПОРЕНИЯ РУЛЕЙ	УСТАНОВЛЕН		CONTROL LOCK	INSTALLED	t		
25	18	КЛЮЧ ЗАЖИГАНИЯ	ВЫНУТ		MAGNETOS KEY	PULL OUT	t		
26	18	СТОЯНОЧНЫЙ ТОРМОЗ	УСТАНОВЛЕН		PARKING BRAKE	SET	t		
27	18	ПЕРЕКЛЮЧАТЕЛЬ ТОПЛИВНЫХ БАКОВ	В ЛЕВОЕ ИЛИ ПРАВОЕ ПОЛОЖЕНИЕ		FUEL SELECTOR	LEFT OR RICHT	t		
2	7	ПОСАДОЧНЫЕ ФАРЫ	ON (вкл.) (если необходимо)	normal/lining_up/2.png	LANDING LIGHT	ON (if necessary)	f		
5	7	ВЗЛЕТНЫЙ СЕКТОР	СВОБОДЕН	normal/lining_up/5.png	TAKE OFF SECTOR	CLEAR	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ВЗЛЕТ	ATC TAKE OFF CLEARANCE
5	8	ПАРАМЕТРЫ ДВИГАТЕЛЯ - В ЗЕЛЕНОМ СЕКТОРЕ	ПРОВЕРИТЬ	normal/normal_take_off/5.png	ENGINE PARAMETERS - IN GREEN BANDS	CHECK	f		
6	8	РУЛЬ ВЫСОТЫ	ПОДНЯТЬ ПЕРЕДНЕЕ КОЛЕСО НА СКОРОСТИ 55 KIAS	normal/normal_take_off/6.png	ELEVATOR CONTROL	LIFT NOSE WHEEL AT 55 KIAS	f		
7	8	V набора высоты 70 КТ	УСТАНОВИТЬ	normal/normal_take_off/7.png	V climb 70 KT	SET	f		
1	9	ЗАКРЫЛКИ	УБРАТЬ (Н ≥ 60 m)	normal/climbing/1.png	WING FLAPS	RETRACT (H ≥ 60 m)	f		
3	9	УПРАВЛЕНИЕ ТРИМ РУЛЯ ВЫСОТЫ	ОТРЕГУЛИРОВАТЬ	normal/climbing/3.png	ELEVATOR TRIM CONTROL	ADJUST	f		
6	9	ВЫСОТА ПЕРЕХОДА - ВЫСОТОМЕР/РЕЗЕР-Й ВЫС-Р	СТАНДАРТ	normal/climbing/6.png	ON TRANSITION ALT - ALTIMETER/STBY ALT	STANDARD	f		
7	9	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	OFF (выкл.)		LANDING (TAXI LIGHT)	OFF	t		
8	9	ЗАКРЫЛКИ	УБРАНЫ		FLAPS	UP	t		
9	9	ВЫСОТОМЕР - СТАНДАРТ	Х-ПРОВЕРЕНО		ALTIMETER - STANDARD	X-CHECKED	t		
10	9	РЕЗЕРВНЫЙ ВЫСОТОМЕР - СТАНДАРТ	Х-ПРОВЕРЕНО		STBY ALT - STANDARD	X-CHECKED	t		
1	10	МОЩНОСТЬ - 2150 - 2400 ОБ/МИН	УСТАНОВИТЬ	normal/cruise/1.png	THROTTLE CONTROL - 2150 - 2400 RPM	SET	f		
2	10	УПРАВЛЕНИЕ ТРИМ РУЛЯ ВЫСОТЫ	ОТРЕГУЛИРОВАТЬ	normal/cruise/2.png	ELEVATOR TRIM CONTROL	ADJUST	f		
4	10	СИСТЕМА УПРАВЛЕНИЯ ПОЛЕТОМ FMS/GPS	ПРОАНАЛИЗИРОВАТЬ	normal/cruise/4.png	FMS/GPS	REVIEW and BRIEF	f		
5	10	РАДИОЧАСТОТА АТИС	УСТАНОВИТЬ	normal/cruise/5.png	COM ATIS Frequency	SET	f		
6	10	ИНФОРМАЦИЯ АТИС	ЗАПИСАТЬ	normal/cruise/6.png	ATIS Information	COPY	f		
7	10	РАДИОЧАСТОТА ДИСПЕТЧЕРА	УСТАНОВИТЬ	normal/cruise/7.png	COM ATC	SET	f		
1	11	ЗАДАТЧИК ВЫСОТЫ ALT SEL	УСТАНОВИТЬ	normal/before_descent/1.png	ALT SEL	SET	f		
2	11	ВЫСОТОМЕР (при ПВП)	QFE ... Мб	normal/before_descent/2.png	ALTIMETER (when VFR)	QFE ... Mb	f		
1	17	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	OFF (выкл.)	normal/after_landing/1.png	LANDING (TAXI)* LIGHT	OFF (if necessary)	f		
2	17	СТРОБОСКОПИЧЕСКИЕ ОГНИ	OFF (выкл.)	normal/after_landing/2.png	STROBE LIGHT	OFF	f		
4	17	ЗАКРЫЛКИ	UP (убрать)	normal/after_landing/4.png	WING FLAPS	UP	f		
6	17	СТРОБОСКОПИЧЕСКИЕ ОГНИ	OFF (выкл.)		STROBE LIGHT	OFF	t		
7	17	ОБОГРЕВ ПВД	OFF (выкл.)		PITOT HEAT	OFF	t		
8	17	ЗАКРЫЛКИ	UP (убраны)		FLAPS	UP	t		
1	18	ТОРМОЗА	ЗАЖАТЬ	normal/engine_shutdown/1.png	BRAKES	PRESS	f		
2	18	СТОЯНОЧНЫЙ ТОРМОЗ	УСТАНОВИТЬ	normal/engine_shutdown/2.png	PARKING BRAKE	SET	f		
3	18	РАДИО ЧАСТОТА ДИСПЕТЧЕРА ВЫШКИ	ЗАПРОСИТЬ	normal/engine_shutdown/3.png	COM ATC «GROUND»	REQUEST	f	ДИСПЕТЧЕРСКОЕ РАЗРЕШЕНИЕ НА ВЫКЛЮЧЕНИЕ ДВИГАТЕЛЯ	ATC ENGINE SHUTDOWN CLEARANCE
4	18	APK KR 87	OFF (выкл.)	normal/engine_shutdown/4.png	ADF KR 87	OFF	f		
5	18	РУЧКИ ОБОГРЕВА И ВЕНТИЛЯЦИИ КАБИНЫ	ОТ СЕБЯ ДО УПОРА	normal/engine_shutdown/5.png	CABIN HIT/AIR KNOBS	PUSH OFF	f		
6	18	ЗАКРЫЛКИ - UP (УБРАНЫ)	ПРОВЕРИТЬ	normal/engine_shutdown/6.png	FLAPS - UP	CHECK	f		
11	11	СИСТЕМА УПРАВЛЕНИЯ ПОЛЕТОМ (при ППП)	ЗАГРУЖЕНА		FMS SETUP (when IFR)	LOADED	t		
12	11	ВЫСОТОМЕР (при ПВП)	QFE ... Мб. Х-ПРОВЕРЕНО		ALTIMETER (when VFR)	QFE .... Mb. X-CHECKED	t		
13	11	РЕЗЕР-Й ВЫСОТ-Р (при ПВП)	QFE ... Мб. Х-ПРОВЕРЕНО		STBY ALT (when VFR)	QFE ... Mb. X-CHECKED	t		
14	11	ПОСАДОЧНЫЙ МИНИМУМ (при ППП)	УСТАНОВЛЕН		LANDING MINIMUMS (when IFR)	LOADED	t		
15	11	КРЕСЛА И РЕМНИ БЕЗОПАСНОСТИ	ПРОВЕРЕНЫ		SEATS AND BELTS	CHECKED	t		
1	12	УПРАВЛЕНИЕ ГАЗОМ	КАК ТРЕБУЕТСЯ	normal/descent/1.png	THROTTLE CONTROL	AS DESIRED	f		
2	12	V снижения 90 КТ	УСТАНОВИТЬ	normal/descent/2.png	V descent 90 KT	SET	f		
3	12	НА ЭШЕЛОНЕ ПЕРЕХОДА - ВЫСОТОМЕР - QFE (при ППП)	УСТАНОВИТЬ	normal/descent/3.png	ON TRANSITION FL - ALTIMETER - QFE (when IFR)	SET	f		
4	12	НА ЭШЕЛОНЕ ПЕРЕХОДА - РЕЗЕР ВЫСОТ-Р - QFE (при ППП)	УСТАНОВИТЬ	normal/descent/4.png	ON TRANSITION FL - STBY ALT - QFE (when IFR)	SET	f		
5	12	ВЫСОТОМЕР/РЕЗЕР-Й ВЫСОТ-Р (при ППП)	СЛИЧИТЬ	normal/descent/5.png	ALTIMETER/STBY ALT (when IFR)	COLLATE	f		
6	12	НАВИГАЦИОННЫЙ ИСТОЧНИК (при ППП)	ВЫБРАТЬ	normal/descent/6.png	NAV SOURCE (when IFR)	SELECT	f		
7	12	СПИНКИ КРЕСЕЛ ПИЛОТОВ И ПАССАЖИРОВ	МАКСИМАЛЬНО ВЕРТИКАЛЬНОЕ ПОЛОЖЕНИЕ	normal/descent/7.png	PILOT AND PASSENGER SEAT BACKS	MOST UPRIGHT POSITION	f		
8	12	ВЫСОТОМЕР/РЕЗЕРВНЫЙ ВЫСОТОМЕР	ПРОВЕРЕНЫ		ALTIMETER/STBY ALT	CHECKED	t		
9	12	НАВИГАЦИОННЫЙ ИСТОЧНИК	ВЫБРАН		NAV SOURCE	SELECTED	t		
10	12	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	RICH (обогащенная смесь)		MIXTURE CONTROL	RICH	t		
11	12	ПЕРЕКЛЮЧАТЕЛЬ ТОПЛИВНЫХ БАКОВ	ВОТН (оба)		FUEL SELECTOR	BOTH	t		
1	13	ЗАКРЫЛКИ 10°, V - 90 KT	УСТАНОВИТЬ		WING FLAPS 10°, V - 90 KT	SET	f		
2	13	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	ON (вкл.)		LANDING (TAXI) LIGHT	ON	f		
3	13	ЗАКРЫЛКИ 20°, V - 80 КТ	УСТАНОВИТЬ		WING FLAPS 20°, V - 80 KT	SET	f		
1	14	АВТОПИЛОТ	OFF (выкл.) (если включался)	normal/before_landing/1.png	AUTOPILOT	OFF (if installed)	f		
2	14	ВЫКЛЮЧАТЕЛЬ ЭЛЕКТРОПИТАНИЯ 12 В	OFF (выкл.) (если использовался)	normal/before_landing/1.png	CABIN PWR 12 V	OFF (if used)	f		
3	14	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	ON (вкл.)		LANDING (TAXI) LIGHT	ON	t		
4	14	ЗАКРЫЛКИ	20° (двадцать) УСТАНОВЛЕНЫ		FLAPS	20° (twenty) SET	t		
1	15	УПРАВЛЕНИЕ ТРИМ РУЛЯ ВЫСОТЫ	ОТРЕГУЛИРОВАТЬ	normal/normal_landing/1.png	ELEVATOR TRIM CONTROL	ADJUST	f		
2	15	УПРАВЛЕНИЕ ГАЗОМ	ХОЛОСТОЙ ХОД (на себя до упора)	normal/normal_landing/2.png	THROTTLE CONTROL	IDLE	f		
3	15	ПРИЗЕМЛЕНИЕ	СНАЧАЛА ОСНОВНЫМИ КОЛЕСАМИ	normal/normal_landing/3.png	TOUCHDOWN	MAIN WHEELS FIRST	f		
4	15	ПРОБЕГ	ПЛАВНО ОПУСТИТЬ ПЕРЕДНЕЕ КОЛЕСО	normal/normal_landing/4.png	LANDING ROLL	LOWER NOSE WHEEL GENTLY	f		
5	15	ТОРМОЖЕНИЕ	МИНИМАЛЬНО НЕОБХОДИМОЕ	normal/normal_landing/5.png	BRAKING	MINIMUM REQUIRED	f		
1	16	УПРАВЛЕНИЕ ГАЗОМ	FULL (полный газ) (от себя до упора)	normal/balked_landing/1.png	THROTTLE CONTROL	FULL (push full in)	f		
2	16	ЗАКРЫЛКИ	УБРАТЬ до 20°	normal/balked_landing/2.png	WING FLAPS	RETRACT to 20°	f		
3	16	СКОРОСТЬ НАБОРА ВЫСОТЫ	СКОРОСТЬ ЗАХОДА	normal/balked_landing/3.png	CLIMB SPEED	SPEED APPROACH	f		
3	17	ОБОГРЕВ ПВД	OFF (выкл.) (если необходимо)	normal/after_landing/3.png	PITOT HEAT	OFF (if necessary)	f		
5	17	ПОСАДОЧНЫЕ (РУЛЕЖНЫЕ) ФАРЫ	OFF (выкл.)		LANDING (TAXI) LIGHT	OFF	t		
10	11	ПРЕДПОСАДОЧНЫЙ БРИФИНГ	ВЫПОЛНЕН		LANDING BRIEFING	CONFIRMED	t		
28	18	ЗАКРЫЛКИ	UP (убраны)		FLAPS	UP	t		
29	18	РУЧКИ ОБОГРЕВА И ВЕНТИЛЯЦИИ	ОТ СЕБЯ ДО УПОРА, ЗАКРЫТЫ		CABIN HIT/AIR KNOBS	PUSH OFF	t		
29	2	ДАВЛЕНИЕ МАСЛА	ПРОВЕРИТЬ \r\n(убедитесь, что показания давления масла увеличиваются до диапазона ЗЕЛЕНОЙ ЗОНЫ в течение 30 - 60 секунд)	normal/starting_engine/23.png	OIL PRESSURE	CHECK\r\n(verify that oil pressure increases into the\r\nGREEN BAND range in 30 to 60 seconds)	f		
8	3	КНОПКА ОТКЛЮЧЕНИЯ ТРИММИ-РОВАНИЯ АВТОПИЛОТА А/P TRIM DISC	НАЖАТЬ (убедитесь, что автопилот отключается и слышно звуковое предупреждение)	normal/before_take_off/8.png	AUTOPILOT BY AP TRIM DISC BUTTON	DISENGAGE (autopilot disengages and aural alert is heard)	f		
20	3	ПЕЛЕНГ 2	ВЫБРАТЬ	normal/before_take_off/20.png	BERING 2	SELECT	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
23	3	БАРОМЕТРИЧЕСКОЕ ДАВЛЕНИЕ	УСТАНОВИТЬ И ПРОВЕРИТЬ	normal/before_take_off/23.png	PFD (BARO) - «0» Height - QFE	SET and CHECK	f	НА ПИЛОТАЖНОМ ДИСПЛЕЕ	ON PFD
30	18	АРК	OFF (выкл.)		ADF	OFF	t		
1	19	ЧЕХОЛ ОБОГРЕВА ПВД	НАДЕТЬ	normal/secure/1.png	PITOT TUBE COVER	INSTALL	f		
2	19	ВНЕШНИЙ ОСМОТР САМОЛЕТА	ВЫПОЛНИТЬ	normal/secure/2.png	EXTERNAL INSPECTION OF THE PLANE	MAKE	f		
3	19	ВОЗДУХОЗАБОРНИКИ	ЗАКРЫТЬ	normal/secure/3.png	COOLING AIR INLETS	CLOSE	f		
30	3	ОСТАТОК ТОПЛИВА	ПРОВЕРИТЬ И УСТАНОВИТЬ (при необходимости)	normal/before_take_off/30.png	FUEL QUANTITY	CHECK AND SET (if necessary)	f	НА НАВИГАЦИОННОМ ДИСПЛЕЕ	ON MFD
24	4	«ВЗЛЕТНЫЙ БРИФИНГ»\r\nРЕЙС Nº _, ЭШ (ВЫС) __, ПП-ПК, ВПП __, КУРС __, ИНФ-Я АТИС __, ТОП/ВЗЛ ВЕС/ ЗАКР/СКОР __, СХЕМА ВЫХОДА __, РАДИО ВСПОМ СР-ВА, АП __, МИН БЕЗ ВЫС __, ВЫС ПЕРЕХ__, СПИС МИН ОБОР__, ДОП ИНФО__, СИСТ УПР ПОЛ__, АВАР ПРОЦ__.	ПРОВЕСТИ	normal/before_taxi/24.png	«TAKE OFF BRIEFING»\r\nFLIGHT Nº__, FL (ALT) __, PF-PM, RW __, HDG __, ATIS info __, Qt/T/O WEIGHT/FLAPS/Vr __, SID__, RADIO AIDS (NAV, ILS, DME, COM, ADF), AP __, MSA __, TRANS ALT __, MEL __, ADD INFO __, FMC __, EMERG PROCED __.	COMPLETE	f		
4	9	ПОКАЗАНИЯ РАСХОДА ТОПЛИВА В КРАЙНЕМ ПРАВОМ УСТАНОВИТЬ ПОЛОЖЕНИИ	УСТАНОВИТЬ	normal/climbing/4.png	FFLOW GAL IN RIGHT POSITION OF GREEN BANDS	SET	f		
4	19	САМОЛЕТ, СТОЯНОЧНЫЙ ТОРМОЗ	ПОСТАВИТЬ КОЛОДКИ, ПРИШВАРТОВАТЬ, СНЯТЬ СТОЯНОЧНЫЙ ТОРМОЗ, ЗАЧЕХЛИТЬ	normal/secure/4.png	PLANE, PARKING BRAKE	TIE, CLEAR	f		
5	19	ЧЕХОЛ ОБОГРЕВА ПВД	НАДЕТ		PITOT TUBE COVER	INSTALLED	t		
6	19	ВОЗДУХОЗАБОРНИКИ	ЗАКРЫТЫ		COOLING AIR INLETS	CLOSED	t		
7	19	САМОЛЕТ	ПРИШВАРТОВАН, ЗАЧЕХЛЕН		PLANE	TIED	t		
25	2	ПРИМЕЧАНИЕ! Если двигатель прогрет, пропустите пункт\r\n\r\nУПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	УСТАНОВИТЬ в положение FULL RICH \r\n(наиболее обогащенная рабочая смесь) (от себя до упора) до индикации стабильного расхода топлива (приблизительно через 3-5 секунд), затем установить в положение IDLE CUTOFF (прекращение подачи) (на себя до упора)	normal/starting_engine/19.png	NOTE! If engine is warm, omit priming procedure step\r\n\r\nMIXTURE CONTROL	SET to FULL RICH\r\n(full forward) until stable fuel flow is indicated (approximately 3 to 5 seconds), then set to\r\nIDLE CUTOFF (full aft) position.	f		
5	9	ПОСАДОЧНЫЕ (РУЛЁЖНЫЕ) ФАРЫ	OFF (выкл.)	normal/climbing/5.png	LANDING (TAXI) LIGHT	OFF	f		
3	10	УПРАВЛЕНИЕ СОСТАВОМ СМЕСИ	ОБЕДНИТЬ (для желаемых летных характеристик или экономии топлива)	normal/cruise/3.png	MIXTURE CONTROL	LEAN (for desired performance or economy)	f		
9	11	АЭР-Т __, ПП-ПК, ВПП __, КУРС __, ИНФ АТИС __, ТИП ЗАХ __, РАДИО ВСПОМ СР-ВА, ВПР (MBC) __, БАРО МИНИМУМ __, ПРЕВЫШ АЭР-МА __, МИН БЕЗ ВЫС __, ЭШЕЛОН\r\nПЕРЕХОДА __, СХЕМА ПРИБЫТИЯ __, ТОП/ПОС-Й ВЕС/ЗАКР/СКОР __, УХОД НА 2-Й ЗА/ТОПЛИВО__, МАРКИР-КА ВПП __, СТО ВПП __, ТОРМОЗА __, ДОП ИНФ-Я __.	ПРОВЕСТИ		AIRPORT _, PF-PM, RW __, HDG __, ATIS info __, APPROACH TYPE __, RADIO AIDS (NAV, ILS, DME, COM, ADF), DA/H (MDA/H), MINIMUNS BARO __, AIRPORT ELEVATION __, MSA __, TRANS LEVEL __, STAR__, Qt/LANDING WEIGHT/FLAPS/Vref __, GA __,\r\nALTERNATE AIRPORT/FUEL __, RW markings __, RW lights__, BRAKES __, ADD INFO __.	COMPLETED	f	«ПРЕДПОСАДОЧНЫЙ БРИФИНГ»	«LANDING BRIEFING»
4	16	ЗАКРЫЛКИ	10° (после того, как препятствия останутся на безопасном расстоянии), затем UP (убрать) (после набора без-й высоты и скор-ти ≥ 65 KIAS)	normal/balked_landing/4.png	WING FLAPS	10° (as obstacle is cleared), then UP (after reaching a safe altitude and ≥ 65 KIAS)	f		
8	18	ПЕРЕКЛЮЧАТЕЛЬ ТОПЛИВНЫХ БАКОВ	ЛЕВОЕ ИЛИ ПРАВОЕ ПОЛОЖЕНИЕ УСТАНОВИТЬ	normal/engine_shutdown/8.png	FUEL SELECTOR	LEFT OR RICHT SET	f		
17	18	ОСНОВНОЙ ПЕРЕКЛЮЧАТЕЛЬ MASTER (генератор и аккумулятор)	OFF (выкл.)	normal/engine_shutdown/17.png	MASTER SWITCH	OFF	f		
\.


--
-- Data for Name: preflight_inspection_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.preflight_inspection_categories (id, title, main_category_id, title_eng, picture, sub_title) FROM stdin;
1	Кабина	1	Cabin		Проведите осмотр кабины самолёта
7	Левое крыло	1	Left wing		Внимательно осмотрите левое крыло
8	Левое крыло. Задняя кромка	1	Left wing. Trailing edge		Внимательно осмотрите левое крыло, заднюю кромку
6	Левое крыло. Передняя кромка	1	Left wing. Leading edge		Внимательно осмотрите левое крыло, переднюю кромку
5	Носовая часть	1	Nose		Проведите осмотр носовой части самолёта
3	Правое крыло. Задняя кромка	1	Right wing. Trailing edge		Внимательно осмотрите правое крыло, заднюю кромку
4	Правое крыло	1	Right wing		Внимательно осмотрите левое крыло
2	Хвостовое оперение	1	Empennage		Проведите осмотр хвостового оперения самолёта
\.


--
-- Data for Name: preflight_inspection_check_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.preflight_inspection_check_list (id, preflight_inspection_category_id, title, doing, picture, title_eng, doing_eng) FROM stdin;
27	1	Клапан резервного источника статического давления ALT STATIC AIR	OFF (выкл.) (от себя до упора)	preflight/cabin/27.png	ALT STATIC AIR Valve	OFF (push full in)
28	1	Огнетушитель	ПРОВЕРИТЬ (убедитесь, что стрелка индикатора находится в пределах зеленой дуги)	preflight/cabin/28.png	Fire Extinguisher	CHECK (verify gage pointer in green arc)
14	1	Сигнализатор LOW VACUUM (низкий уровень вакуума)	ПРОВЕРИТЬ (убедитесь, что символ сигнализатора горит на экране)	preflight/cabin/14.png	LOW VACUUM Annunciator	CHECK (verify annunciator is shown)
1	4	Швартовочный трос крыла	ОТСОЕДИНИТЬ	preflight/right_wing/1.png	Wing Tie down	DISCONNECT
18	1	Переключатель AVIONICS (BUS 2)	ON (вкл.)	preflight/cabin/18.png	AVIONICS Switch (BUS 2)	ON
8	1	Переключатель авионики AVIONICS (BUS 1 и BUS 2 (шина 1 и шина 2))	OFF (выкл.)	preflight/cabin/8.png	AVIONICS Switch (BUS 1 and BUS 2)	OFF
22	1	Переключатель РІТОТ НЕАТ (обогрев ПВД)	OFF (выкл.)	preflight/cabin/22.png	PITOT HEAT Switch	OFF
23	1	Сигнализатор LOW VOLTS (низкое напряжение)	ПРОВЕРИТЬ (убедитесь, что символ сигнализатора горит на экране)\r\n	preflight/cabin/23.png	LOW VOLTS Annunciator	CHECK (verify annunciator is shown)
24	1	Основной переключатель MASTER (ALT и ВАТ) (генератор и аккумулятор)	OFF (выкл.)	preflight/cabin/24.png	MASTER Switch (ALT and BAT)	OFF
25	1	Управление триммированием руля высоты	положение TAKE OFF (взлет)	preflight/cabin/25.png	Elevator Trim Control	TAKE OFF position
26	1	Переключатель топливных баков FUEL SELECTOR	ВОТН (оба)	preflight/cabin/26.png	FUEL SELECTOR Valve	BOTH
16	1	Передний вентилятор обдува	ПРОВЕРИТЬ (убедитесь в наличии шума авионики работающего вентилятора)	preflight/cabin/16.png	Forward Avionics Fan	CHECK (verify fan is heard)
15	1	Переключатель AVIONICS (BUS 1)	ON (вкл.)	preflight/cabin/15.png	AVIONICS Switch (BUS 1)	ON
1	2	Дверь багажного отсека	ПРОВЕРИТЬ (закройте ключом)	preflight/empennage/1.png	Baggage Compartment Door	CHECK (lock with key)
2	2	Механизм стопорения руля направления (при наличии)	СНЯТЬ	preflight/empennage/2.png	Rudder Gust Lock (if installed)	REMOVE
3	2	Швартовочный трос хвостового оперения	ОТСОЕДИНИТЬ	preflight/empennage/3.png	Tail Tie down	DISCONNECT
4	2	Поверхности рулей	ПРОВЕРИТЬ (свободное перемещение и надежность\r\nкрепления)	preflight/empennage/4.png	Control Surfaces	CHECK (freedom of movement and security)
5	2	Триммер руля высоты	ПРОВЕРИТЬ (надежность крепления)	preflight/empennage/5.png	Elevator Trim Tab	CHECK (security)
6	2	Антенны	ПРОВЕРИТЬ (надежность крепления и общее состояние)	preflight/empennage/6.png	Antennas	CHECK (security of attachment and general condition)
1	3	Закрылок	ПРОВЕРИТЬ (надежность крепления и состояние)	preflight/right_wing_trailing_edge/1.png	Flap	CHECK (security and condition)
20	1	Переключатель AVIONICS (BUS 2)	OFF (выкл.)	preflight/cabin/20.png	AVIONICS Switch (BUS 2)	OFF
2	3	Элерон	ПРОВЕРИТЬ (свободное перемещение и надежность крепления)	preflight/right_wing_trailing_edge/2.png	Aileron	CHECK (freedom of movement and security)
13	1	Сигнализатор OIL PRESSURE (давление масла)	ПРОВЕРИТЬ (убедитесь, что символ сигнализатора горит на экране)	preflight/cabin/13.png	OIL PRESSURE Annunciator	CHECK (verify annunciator is shown)
9	1	Основной переключатель MASTER (ALT и ВАТ (генератор и аккумулятор))	ON (вкл.)	preflight/cabin/9.png	MASTER Switch (ALT and BAT)	ON
1	1	Чехол приемника воздушного давления	СНЯТЬ (убедитесь, что приемник воздушного давления не засорен)	preflight/cabin/1.png	Pitot Tube Cover	REMOVE (check for pitot blockage)
3	1	Справочное руководство пилота Garmin G1000	ДОСТУПНО ДЛЯ ПИЛОТА	preflight/cabin/3.png	Garmin G1000 Cockpit Reference Guide	ACCESSIBLE TO PILOT
6	1	Стопор руля направления	Снять	preflight/cabin/6.png	Control Wheel Lock	REMOVE
5	1	Стояночный тормоз	УСТАНОВИТЬ	preflight/cabin/5.png	Parking Brake	SET
4	1	Масса и центровка самолета	ПРОВЕРЕНО	preflight/cabin/4.png	Airplane Weight and Balance	CHECKED
7	1	Переключатель магнето MAGNETOS	OFF (выкл.)	preflight/cabin/7.png	MAGNETOS Switch	OFF
19	1	Задний вентилятор обдува	ПРОВЕРИТЬ (убедитесь в наличии шума авионики работающего вентилятора)	preflight/cabin/19.png	Aft Avionics Fan	CHECK (verify fan is heard)
17	1	Переключатель AVIONICS (BUS 1)	OFF (выкл.)	preflight/cabin/17.png	AVIONICS Switch (BUS 1)	OFF
11	1	Запас топлива FUEL QTY (L and R) (левый и правый бак)	ПРОВЕРИТЬ	preflight/cabin/11.png	FUEL QTY (L and R)	CHECK
2	1	Справочное руководство пилота	ДОСТУПНО ДЛЯ ПИЛОТА	preflight/cabin/2.png	Pilot's Operating Handbook	ACCESSIBLE TO PILOT
10	1	Основной пилотажный дисплей (PFD)	ПРОВЕРИТЬ (убедитесь, что PFD включен)	preflight/cabin/10.png	Primary Flight Display (PFD)	CHECK (verify PFD is ON)
12	1	Сигнализаторы LOW FUEL L (низкий остаток\r\nтоплива в левом баке) и LOW FUEL R (низкий остаток топлива в правом баке)	ПРОВЕРИТЬ (убедитесь, что предупреждения о низком остатке топлива отсутствуют на PFD	preflight/cabin/12.png	LOW FUEL L and LOW FUEL R Annunciators	CHECK (verify annunciators are not shown on PFD)
2	4	Пневматик основного	ПРОВЕРИТЬ (правильное давление и общее состояние (трещины, глубина протектора, износ и т.д.))	preflight/right_wing/2.png	Main Wheel Tire	CHECK (proper inflation and general condition (weather checks, tread depth and wear, etc.))
3	4	Дренажные клапаны слива отстоя топлива	Слить	preflight/right_wing/3.png	Fuel Tank Sump Quick Drain Valves	DRAIN
4	4	Количество топлива	ПРОВЕРИТЬ ВИЗУАЛЬНО (необходимый уровень)	preflight/right_wing/4.png	Fuel Quantity	CHECK VISUALLY (for desired level)
5	4	Крышка заправочного отверстия	НАДЕЖНО ЗАКРЫТЬ и ПРОВЕРИТЬ ВЕНТИЛ-Ю	preflight/right_wing/5.png	Fuel Filler Cap	SECURE and VENT CLEAR
1	5	Дренажный клапан топливного фильтра (расположен на нижней поверхности фюзеляжа)	Слить	preflight/nose/1.png	Fuel Strainer Quick Drain Valve (located on bottom of fuselage)	DRAIN
3	5	Воздухозаборники охлаждения двигателя	ПРОВЕРИТЬ (отсутствие засорения)	preflight/nose/3.png	Engine Cooling Air Inlets	CHECK (clear of obstructions)
4	5	Винт и обтекатель втулки	ПРОВЕРИТЬ (отсутствие трещин и надежность крепления)	preflight/nose/4.png	Propeller and Spinner	CHECK (for nicks and security)
1	6	Вентиляционное отверстие топливного бака	ПРОВЕРИТЬ (отсутствие засорения)	preflight/left_wing_leading_edge/1.png	Fuel Tank Vent Opening	CHECK (blockage)
2	6	Отверстие системы сигнализации критических углов атаки	ПРОВЕРИТЬ (отсутствие засорения)	preflight/left_wing_leading_edge/2.png	Stall Warning Opening	CHECK (blockage)
3	6	Посадочные рулежные фары	ПРОВЕРИТЬ (состояние и чистота плафонов)	preflight/left_wing_leading_edge/3.png	Landing/Taxi Lights)	CHECK (condition and cleanliness of cover)
1	7	Швартовочный трос крыла	ОТСОЕДИНИТЬ	preflight/left_wing/1.png	Wing Tie down	DISCONNECT
2	7	Количество топлива	ПРОВЕРИТЬ ВИЗУАЛЬНО (необходимый уровень)	preflight/left_wing/2.png	Fuel Quantity	CHECK VISUALLY (for desired level)
3	7	Крышка заправочного отверстия	НАДЕЖНО ЗАКРЫТЬ И ПРОВЕРИТЬ ВЕНТИЛ-Ю	preflight/left_wing/3.png	Fuel Filler Cap	SECURE and VENT CLEAR
1	8	Элерон	ПРОВЕРИТЬ (свободное перемещение и надежность крепления)	preflight/left_wing_trailing_edge/1.png	Aileron	CHECK (freedom of movement and security)
2	8	Закрылок	ПРОВЕРИТЬ (надежность крепления и состояние)	preflight/left_wing_trailing_edge/2.png	Flap	CHECK (security and condition)
21	1	Переключатель PITOT HEAT (обогрев ПВД)	ON (вкл) (убедитесь прикосновением, что приёмник воздушного давления нагревается за 30 секунд)	preflight/cabin/21.png	PITOT HEAT Switch	ON (carefully check that pitot tube is warm to the\r\ntouch within 30 seconds)
2	5	Масляный щуп двигателя/Крышка заправочного отверстия:\\nа) Уровень масла \r\n\\nб) Масляный щуп/крышка заправочного отверстия	а)ПРОВЕРИТЬ\\nб)ЗАКРЫТЬ	preflight/nose/2.png	2. Engine Oil Dipstick/Filler Cap:\\na. Oil level\\nb. Dipstick/filler cap\r\n	a. CHECK\\nb. SECURE
5	5	Воздушный фильтр	ПРОВЕРИТЬ (отсутствие засорения пылью и\r\nпосторонними частицами)	preflight/nose/5.png	Air Filter	CHECK (for restrictions by dust or other foreign matter)
6	5	Пневматик и стойка носового	ПРОВЕРИТЬ (правильное давление в стойке и шасси общее состояние пневматика (трещины, глубина протектора, износ и т.д.))	preflight/nose/6.png	Tire	Nose wheel Strut andCHECK (proper inflation of strut and general condition\r\nof tire (weather checks, tread depth and wear, etc.))
7	5	Отверстие приемника статического давления (на левой стороне фюзеляжа)	ПРОВЕРИТЬ (убедитесь, что отверстие не засорено)	preflight/nose/7.png	Static Source Opening (left side of fuselage)	CHECK (verify opening is clear)
4	7	Дренажные клапаны слива отстоя топлива	СЛИТЬ	preflight/left_wing/4.png	Fuel Tank Sump Quick Drain Valves	DRAIN
5	7	Пневматик основного колеса	ПРОВЕРИТЬ (правильное давление и общее состояние (трещины, глубина протектора, износ и т.д.))	preflight/left_wing/5.png	Main Wheel Tire	CHECK (proper inflation and general condition (weather checks, tread depth and wear, etc.))
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (first_name, phone, last_name, email, id) FROM stdin;
Artem	+79990697289	Lobazin	lobazin.artem@gmail.com	1
\N	+79990607289	\N	\N	3
\.


--
-- Data for Name: question_type_certificates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.question_type_certificates (question_id, type_certificate_id, category_id) FROM stdin;
3	1	1
4	1	1
5	1	1
15	1	1
16	1	1
24	1	1
55	1	1
56	1	1
58	1	1
59	1	1
60	1	1
61	1	1
62	1	1
63	1	1
64	1	1
65	1	1
78	1	1
79	1	1
83	1	1
84	1	1
85	1	1
86	1	1
87	1	1
91	1	1
117	1	1
118	1	1
119	1	1
120	1	1
121	1	1
152	1	1
210	1	1
211	1	1
212	1	1
213	1	1
214	1	1
215	1	1
216	1	1
217	1	1
218	1	1
219	1	1
220	1	1
221	1	1
222	1	1
223	1	1
224	1	1
225	1	1
226	1	1
227	1	1
228	1	1
229	1	1
230	1	1
231	1	1
305	1	1
308	1	1
443	1	1
444	1	1
445	1	1
446	1	1
447	1	1
448	1	1
449	1	1
450	1	1
451	1	1
452	1	1
453	1	1
454	1	1
455	1	1
456	1	1
457	1	1
458	1	1
459	1	1
460	1	1
461	1	1
462	1	1
463	1	1
464	1	1
465	1	1
466	1	1
467	1	1
468	1	1
805	1	1
811	1	1
1476	1	1
8	1	2
9	1	2
10	1	2
11	1	2
12	1	2
13	1	2
14	1	2
17	1	2
18	1	2
19	1	2
20	1	2
21	1	2
22	1	2
23	1	2
33	1	2
48	1	2
51	1	2
52	1	2
67	1	2
68	1	2
69	1	2
70	1	2
71	1	2
72	1	2
73	1	2
74	1	2
75	1	2
76	1	2
112	1	2
113	1	2
114	1	2
243	1	2
244	1	2
246	1	2
247	1	2
387	1	2
388	1	2
389	1	2
390	1	2
391	1	2
392	1	2
393	1	2
394	1	2
395	1	2
396	1	2
399	1	2
400	1	2
401	1	2
402	1	2
403	1	2
404	1	2
405	1	2
406	1	2
412	1	2
413	1	2
416	1	2
417	1	2
418	1	2
419	1	2
420	1	2
421	1	2
422	1	2
424	1	2
425	1	2
426	1	2
428	1	2
429	1	2
430	1	2
431	1	2
432	1	2
433	1	2
434	1	2
435	1	2
436	1	2
437	1	2
438	1	2
439	1	2
440	1	2
442	1	2
614	1	2
824	1	2
825	1	2
826	1	2
827	1	2
828	1	2
829	1	2
830	1	2
831	1	2
832	1	2
833	1	2
834	1	2
835	1	2
836	1	2
1389	1	2
1390	1	2
1392	1	2
25	1	3
190	1	3
191	1	3
192	1	3
382	1	3
383	1	3
384	1	3
385	1	3
564	1	3
565	1	3
566	1	3
567	1	3
568	1	3
569	1	3
570	1	3
571	1	3
572	1	3
1477	1	3
1478	1	3
1479	1	3
27	1	4
28	1	4
34	1	4
35	1	4
37	1	4
40	1	4
41	1	4
42	1	4
54	1	4
132	1	4
135	1	4
139	1	4
207	1	4
753	1	4
754	1	4
1256	1	4
29	1	5
30	1	5
31	1	5
32	1	5
245	1	5
248	1	5
249	1	5
250	1	5
1	1	6
2	1	6
6	1	6
7	1	6
26	1	6
43	1	6
44	1	6
57	1	6
66	1	6
90	1	6
138	1	6
184	1	6
49	1	7
50	1	7
98	1	7
99	1	7
100	1	7
101	1	7
102	1	7
103	1	7
122	1	7
123	1	7
124	1	7
125	1	7
126	1	7
127	1	7
128	1	7
129	1	7
232	1	7
233	1	7
234	1	7
236	1	7
307	1	7
309	1	7
310	1	7
53	1	8
130	1	8
131	1	8
185	1	8
186	1	8
187	1	8
188	1	8
1463	1	8
77	1	9
80	1	9
81	1	9
82	1	9
89	1	9
115	1	9
116	1	9
150	1	9
151	1	9
153	1	9
154	1	9
155	1	9
156	1	9
197	1	9
238	1	9
239	1	9
240	1	9
252	1	9
253	1	9
254	1	9
255	1	9
256	1	9
257	1	9
258	1	9
259	1	9
260	1	9
261	1	9
262	1	9
263	1	9
264	1	9
265	1	9
266	1	9
267	1	9
268	1	9
269	1	9
270	1	9
271	1	9
272	1	9
273	1	9
274	1	9
275	1	9
276	1	9
277	1	9
278	1	9
279	1	9
280	1	9
281	1	9
282	1	9
283	1	9
284	1	9
285	1	9
286	1	9
287	1	9
288	1	9
289	1	9
290	1	9
291	1	9
292	1	9
293	1	9
294	1	9
295	1	9
296	1	9
297	1	9
298	1	9
407	1	9
408	1	9
409	1	9
410	1	9
411	1	9
500	1	9
501	1	9
502	1	9
503	1	9
504	1	9
505	1	9
506	1	9
507	1	9
508	1	9
509	1	9
510	1	9
511	1	9
512	1	9
513	1	9
514	1	9
515	1	9
516	1	9
517	1	9
518	1	9
519	1	9
520	1	9
1209	1	9
1243	1	9
1244	1	9
1245	1	9
1246	1	9
1247	1	9
1248	1	9
1249	1	9
1250	1	9
1253	1	9
1255	1	9
1257	1	9
1258	1	9
1259	1	9
1260	1	9
1261	1	9
1262	1	9
1263	1	9
1264	1	9
1265	1	9
1266	1	9
1267	1	9
1268	1	9
1269	1	9
1270	1	9
1271	1	9
1272	1	9
1273	1	9
1274	1	9
1275	1	9
1276	1	9
1277	1	9
1278	1	9
1279	1	9
1280	1	9
1281	1	9
1282	1	9
1283	1	9
1284	1	9
1285	1	9
1286	1	9
1287	1	9
1288	1	9
1289	1	9
1290	1	9
1292	1	9
1293	1	9
1294	1	9
1295	1	9
1296	1	9
1298	1	9
1299	1	9
1485	1	9
1486	1	9
1487	1	9
1488	1	9
1489	1	9
1490	1	9
1491	1	9
1492	1	9
1493	1	9
1494	1	9
1495	1	9
1498	1	9
1499	1	9
1500	1	9
1501	1	9
1502	1	9
1503	1	9
1504	1	9
1519	1	9
1520	1	9
92	1	10
93	1	10
94	1	10
105	1	10
106	1	10
107	1	10
111	1	10
133	1	10
134	1	10
140	1	10
143	1	10
144	1	10
145	1	10
146	1	10
148	1	10
149	1	10
157	1	10
163	1	10
165	1	10
168	1	10
169	1	10
170	1	10
171	1	10
172	1	10
189	1	10
313	1	10
314	1	10
315	1	10
316	1	10
317	1	10
318	1	10
319	1	10
320	1	10
321	1	10
322	1	10
323	1	10
324	1	10
325	1	10
326	1	10
327	1	10
328	1	10
329	1	10
330	1	10
331	1	10
332	1	10
333	1	10
334	1	10
335	1	10
336	1	10
337	1	10
338	1	10
339	1	10
340	1	10
341	1	10
342	1	10
343	1	10
344	1	10
345	1	10
346	1	10
347	1	10
348	1	10
349	1	10
350	1	10
351	1	10
352	1	10
353	1	10
354	1	10
355	1	10
356	1	10
357	1	10
358	1	10
359	1	10
360	1	10
361	1	10
362	1	10
363	1	10
364	1	10
365	1	10
366	1	10
367	1	10
368	1	10
369	1	10
370	1	10
371	1	10
372	1	10
373	1	10
374	1	10
375	1	10
376	1	10
377	1	10
378	1	10
379	1	10
380	1	10
381	1	10
601	1	10
602	1	10
612	1	10
802	1	10
803	1	10
804	1	10
97	1	11
177	1	11
178	1	11
108	1	12
109	1	12
110	1	12
200	1	12
201	1	12
202	1	12
203	1	12
1480	1	12
1481	1	12
1482	1	12
173	1	13
174	1	13
175	1	13
176	1	13
311	1	13
312	1	13
179	1	14
193	1	14
194	1	14
195	1	14
196	1	14
208	1	14
209	1	14
469	1	14
470	1	14
471	1	14
472	1	14
473	1	14
474	1	14
475	1	14
476	1	14
477	1	14
478	1	14
479	1	14
481	1	14
482	1	14
483	1	14
484	1	14
485	1	14
486	1	14
487	1	14
488	1	14
489	1	14
490	1	14
491	1	14
492	1	14
493	1	14
494	1	14
495	1	14
496	1	14
497	1	14
498	1	14
499	1	14
813	1	14
1210	1	14
1211	1	14
1212	1	14
1213	1	14
1214	1	14
1215	1	14
1216	1	14
1217	1	14
1218	1	14
1219	1	14
1220	1	14
1221	1	14
1222	1	14
1223	1	14
1224	1	14
1225	1	14
1226	1	14
1227	1	14
1228	1	14
1229	1	14
1230	1	14
1231	1	14
1232	1	14
1233	1	14
1234	1	14
1235	1	14
1236	1	14
1237	1	14
1238	1	14
1239	1	14
1240	1	14
1241	1	14
1242	1	14
1251	1	14
1397	1	14
1398	1	14
1399	1	14
1400	1	14
1401	1	14
1402	1	14
1403	1	14
1404	1	14
1405	1	14
180	1	15
182	1	15
183	1	16
1254	1	16
199	1	17
237	1	17
1530	1	17
1531	1	17
1535	1	17
1536	1	17
1537	1	17
1538	1	17
235	1	18
299	1	18
300	1	18
301	1	18
302	1	18
303	1	18
304	1	18
306	1	18
241	1	19
242	1	19
386	1	19
414	1	19
532	1	19
534	1	19
561	1	19
562	1	19
563	1	19
837	1	19
1406	1	19
1407	1	19
1408	1	19
1409	1	19
1410	1	19
1412	1	19
1413	1	19
1416	1	19
1417	1	19
1418	1	19
1419	1	19
1420	1	19
97	2	11
177	2	11
178	2	11
97	4	11
177	4	11
178	4	11
173	4	13
174	4	13
175	4	13
176	4	13
173	2	13
174	2	13
175	2	13
176	2	13
311	2	13
312	2	13
497	2	14
498	2	14
499	2	14
813	2	14
1210	2	14
1252	1	21
1297	1	21
1421	1	22
1422	1	22
1423	1	22
1211	2	14
1212	2	14
1213	2	14
1214	2	14
1215	2	14
1216	2	14
1217	2	14
1218	2	14
1219	2	14
1220	2	14
1221	2	14
1222	2	14
1223	2	14
1224	2	14
1225	2	14
1226	2	14
1227	2	14
1228	2	14
1229	2	14
1230	2	14
1231	2	14
1232	2	14
1233	2	14
1234	2	14
1235	2	14
1236	2	14
1237	2	14
1238	2	14
1239	2	14
1240	2	14
1241	2	14
1242	2	14
1251	2	14
1397	2	14
1398	2	14
1399	2	14
1400	2	14
1401	2	14
1402	2	14
1403	2	14
1404	2	14
1405	2	14
180	2	15
181	2	15
98	2	7
99	2	7
101	2	7
102	2	7
122	2	7
123	2	7
124	2	7
125	2	7
126	2	7
127	2	7
128	2	7
129	2	7
232	2	7
233	2	7
234	2	7
307	2	7
521	1	20
522	1	20
523	1	20
524	1	20
525	1	20
526	1	20
527	1	20
528	1	20
529	1	20
530	1	20
531	1	20
1464	1	20
1465	1	20
1470	1	20
1471	1	20
1472	1	20
1473	1	20
1474	1	20
8	2	2
9	2	2
10	2	2
11	2	2
12	2	2
13	2	2
14	2	2
17	2	2
18	2	2
19	2	2
20	2	2
21	2	2
22	2	2
23	2	2
33	2	2
48	2	2
51	2	2
52	2	2
67	2	2
68	2	2
69	2	2
70	2	2
71	2	2
72	2	2
73	2	2
74	2	2
75	2	2
76	2	2
112	2	2
113	2	2
114	2	2
243	2	2
244	2	2
246	2	2
247	2	2
387	2	2
388	2	2
389	2	2
390	2	2
391	2	2
392	2	2
393	2	2
394	2	2
395	2	2
396	2	2
397	2	2
398	2	2
399	2	2
400	2	2
401	2	2
402	2	2
403	2	2
404	2	2
405	2	2
406	2	2
412	2	2
413	2	2
416	2	2
417	2	2
418	2	2
419	2	2
420	2	2
421	2	2
422	2	2
424	2	2
425	2	2
428	2	2
429	2	2
430	2	2
431	2	2
432	2	2
433	2	2
434	2	2
435	2	2
436	2	2
437	2	2
438	2	2
439	2	2
440	2	2
442	2	2
614	2	2
824	2	2
825	2	2
826	2	2
827	2	2
828	2	2
829	2	2
830	2	2
831	2	2
832	2	2
833	2	2
834	2	2
835	2	2
836	2	2
1389	2	2
1390	2	2
1392	2	2
24	2	1
55	2	1
56	2	1
58	2	1
59	2	1
60	2	1
62	2	1
63	2	1
64	2	1
65	2	1
78	2	1
79	2	1
84	2	1
85	2	1
86	2	1
87	2	1
91	2	1
117	2	1
118	2	1
119	2	1
152	2	1
210	2	1
211	2	1
212	2	1
213	2	1
214	2	1
215	2	1
216	2	1
217	2	1
218	2	1
219	2	1
220	2	1
221	2	1
222	2	1
223	2	1
224	2	1
225	2	1
226	2	1
227	2	1
443	2	1
444	2	1
445	2	1
452	2	1
453	2	1
454	2	1
456	2	1
458	2	1
461	2	1
465	2	1
466	2	1
467	2	1
468	2	1
811	2	1
1476	2	1
25	2	3
190	2	3
191	2	3
192	2	3
382	2	3
383	2	3
384	2	3
385	2	3
564	2	3
565	2	3
566	2	3
567	2	3
568	2	3
569	2	3
570	2	3
571	2	3
572	2	3
1477	2	3
1478	2	3
1479	2	3
27	2	4
28	2	4
34	2	4
35	2	4
37	2	4
40	2	4
41	2	4
42	2	4
54	2	4
132	2	4
135	2	4
139	2	4
207	2	4
753	2	4
754	2	4
1256	2	4
29	2	5
30	2	5
31	2	5
32	2	5
245	2	5
248	2	5
249	2	5
250	2	5
1	2	6
6	2	6
7	2	6
45	2	6
46	2	6
47	2	6
57	2	6
90	2	6
184	2	6
53	2	8
130	2	8
131	2	8
185	2	8
186	2	8
187	2	8
188	2	8
1463	2	8
77	2	9
80	2	9
81	2	9
82	2	9
89	2	9
115	2	9
116	2	9
150	2	9
151	2	9
153	2	9
154	2	9
155	2	9
156	2	9
197	2	9
238	2	9
239	2	9
240	2	9
252	2	9
253	2	9
254	2	9
255	2	9
256	2	9
257	2	9
258	2	9
259	2	9
260	2	9
261	2	9
262	2	9
263	2	9
264	2	9
265	2	9
266	2	9
267	2	9
268	2	9
269	2	9
270	2	9
271	2	9
272	2	9
273	2	9
274	2	9
275	2	9
276	2	9
277	2	9
278	2	9
279	2	9
280	2	9
281	2	9
282	2	9
283	2	9
284	2	9
285	2	9
286	2	9
287	2	9
288	2	9
289	2	9
290	2	9
291	2	9
292	2	9
293	2	9
294	2	9
295	2	9
296	2	9
297	2	9
298	2	9
407	2	9
408	2	9
409	2	9
410	2	9
411	2	9
500	2	9
501	2	9
502	2	9
503	2	9
504	2	9
505	2	9
506	2	9
507	2	9
508	2	9
509	2	9
510	2	9
511	2	9
512	2	9
513	2	9
514	2	9
515	2	9
516	2	9
517	2	9
518	2	9
519	2	9
520	2	9
1209	2	9
1243	2	9
1244	2	9
1245	2	9
1246	2	9
1247	2	9
1248	2	9
1249	2	9
1250	2	9
1253	2	9
1255	2	9
1257	2	9
1258	2	9
1259	2	9
1260	2	9
1261	2	9
1262	2	9
1263	2	9
1264	2	9
1265	2	9
1266	2	9
1267	2	9
1268	2	9
1269	2	9
1270	2	9
1271	2	9
1272	2	9
1273	2	9
1274	2	9
1275	2	9
1276	2	9
1277	2	9
1278	2	9
1279	2	9
1280	2	9
1281	2	9
1282	2	9
1283	2	9
1284	2	9
1285	2	9
1286	2	9
1287	2	9
1288	2	9
1289	2	9
1290	2	9
1292	2	9
1293	2	9
1294	2	9
1295	2	9
1296	2	9
1298	2	9
1299	2	9
1485	2	9
1486	2	9
1487	2	9
1488	2	9
1489	2	9
1490	2	9
1491	2	9
1492	2	9
1493	2	9
1494	2	9
1495	2	9
1498	2	9
1499	2	9
1500	2	9
1501	2	9
1502	2	9
1503	2	9
1504	2	9
1519	2	9
1520	2	9
88	2	23
96	2	23
92	2	10
93	2	10
94	2	10
105	2	10
106	2	10
107	2	10
111	2	10
133	2	10
134	2	10
140	2	10
143	2	10
144	2	10
145	2	10
146	2	10
148	2	10
149	2	10
157	2	10
163	2	10
165	2	10
168	2	10
169	2	10
170	2	10
171	2	10
172	2	10
189	2	10
313	2	10
314	2	10
315	2	10
316	2	10
317	2	10
318	2	10
319	2	10
320	2	10
321	2	10
322	2	10
323	2	10
324	2	10
325	2	10
326	2	10
327	2	10
328	2	10
329	2	10
330	2	10
331	2	10
332	2	10
333	2	10
334	2	10
335	2	10
336	2	10
337	2	10
338	2	10
339	2	10
340	2	10
341	2	10
342	2	10
343	2	10
344	2	10
345	2	10
346	2	10
347	2	10
348	2	10
349	2	10
350	2	10
351	2	10
352	2	10
353	2	10
354	2	10
355	2	10
356	2	10
357	2	10
358	2	10
359	2	10
360	2	10
361	2	10
362	2	10
363	2	10
364	2	10
365	2	10
366	2	10
367	2	10
368	2	10
369	2	10
370	2	10
371	2	10
372	2	10
373	2	10
374	2	10
375	2	10
376	2	10
377	2	10
378	2	10
379	2	10
380	2	10
381	2	10
601	2	10
602	2	10
612	2	10
802	2	10
803	2	10
804	2	10
310	2	7
108	2	12
109	2	12
110	2	12
200	2	12
201	2	12
202	2	12
203	2	12
1480	2	12
1481	2	12
1482	2	12
179	2	14
193	2	14
194	2	14
195	2	14
196	2	14
208	2	14
209	2	14
469	2	14
470	2	14
471	2	14
472	2	14
473	2	14
474	2	14
475	2	14
476	2	14
477	2	14
478	2	14
479	2	14
481	2	14
482	2	14
483	2	14
484	2	14
485	2	14
486	2	14
487	2	14
488	2	14
489	2	14
490	2	14
491	2	14
492	2	14
493	2	14
494	2	14
495	2	14
496	2	14
182	2	15
183	2	16
1254	2	16
199	2	17
237	2	17
1530	2	17
1531	2	17
1535	2	17
1536	2	17
1537	2	17
1538	2	17
241	2	19
242	2	19
386	2	19
414	2	19
532	2	19
534	2	19
561	2	19
562	2	19
563	2	19
837	2	19
1406	2	19
1407	2	19
1408	2	19
1409	2	19
1410	2	19
1412	2	19
1413	2	19
1416	2	19
1417	2	19
1418	2	19
1419	2	19
1420	2	19
98	4	7
99	4	7
101	4	7
102	4	7
122	4	7
123	4	7
124	4	7
125	4	7
126	4	7
127	4	7
128	4	7
129	4	7
232	4	7
233	4	7
234	4	7
307	4	7
310	4	7
311	4	13
312	4	13
193	4	14
195	4	14
196	4	14
208	4	14
209	4	14
469	4	14
470	4	14
471	4	14
472	4	14
473	4	14
474	4	14
475	4	14
476	4	14
477	4	14
478	4	14
479	4	14
480	4	14
481	4	14
482	4	14
483	4	14
484	4	14
486	4	14
487	4	14
488	4	14
489	4	14
490	4	14
491	4	14
492	4	14
493	4	14
495	4	14
496	4	14
497	4	14
498	4	14
813	4	14
1210	4	14
1211	4	14
1212	4	14
1213	4	14
1214	4	14
1215	4	14
1216	4	14
521	2	20
522	2	20
523	2	20
524	2	20
525	2	20
526	2	20
527	2	20
528	2	20
529	2	20
530	2	20
531	2	20
1464	2	20
1465	2	20
1470	2	20
1471	2	20
1472	2	20
1473	2	20
1474	2	20
1252	2	21
1297	2	21
1421	2	22
1422	2	22
1423	2	22
104	2	18
299	2	18
300	2	18
301	2	18
302	2	18
303	2	18
304	2	18
3	3	1
4	3	1
5	3	1
15	3	1
16	3	1
24	3	1
55	3	1
56	3	1
58	3	1
59	3	1
60	3	1
61	3	1
62	3	1
63	3	1
64	3	1
65	3	1
78	3	1
79	3	1
83	3	1
84	3	1
85	3	1
86	3	1
87	3	1
91	3	1
117	3	1
118	3	1
119	3	1
120	3	1
121	3	1
152	3	1
210	3	1
211	3	1
212	3	1
213	3	1
214	3	1
215	3	1
216	3	1
217	3	1
218	3	1
219	3	1
220	3	1
221	3	1
222	3	1
223	3	1
224	3	1
225	3	1
226	3	1
227	3	1
228	3	1
229	3	1
230	3	1
231	3	1
305	3	1
308	3	1
443	3	1
444	3	1
445	3	1
446	3	1
447	3	1
448	3	1
449	3	1
450	3	1
451	3	1
452	3	1
453	3	1
454	3	1
455	3	1
456	3	1
457	3	1
458	3	1
459	3	1
460	3	1
461	3	1
462	3	1
463	3	1
464	3	1
465	3	1
466	3	1
467	3	1
468	3	1
805	3	1
811	3	1
1476	3	1
8	3	2
9	3	2
10	3	2
11	3	2
12	3	2
13	3	2
14	3	2
17	3	2
18	3	2
19	3	2
20	3	2
21	3	2
22	3	2
23	3	2
33	3	2
48	3	2
51	3	2
52	3	2
67	3	2
68	3	2
69	3	2
70	3	2
71	3	2
72	3	2
73	3	2
74	3	2
75	3	2
76	3	2
112	3	2
113	3	2
114	3	2
243	3	2
244	3	2
246	3	2
247	3	2
387	3	2
388	3	2
389	3	2
390	3	2
391	3	2
392	3	2
393	3	2
394	3	2
395	3	2
396	3	2
399	3	2
400	3	2
401	3	2
402	3	2
403	3	2
404	3	2
405	3	2
406	3	2
412	3	2
413	3	2
416	3	2
417	3	2
418	3	2
419	3	2
420	3	2
421	3	2
422	3	2
423	3	2
424	3	2
425	3	2
426	3	2
427	3	2
428	3	2
429	3	2
430	3	2
431	3	2
432	3	2
433	3	2
434	3	2
435	3	2
436	3	2
437	3	2
438	3	2
439	3	2
440	3	2
442	3	2
613	3	2
614	3	2
615	3	2
616	3	2
617	3	2
824	3	2
825	3	2
826	3	2
827	3	2
828	3	2
829	3	2
830	3	2
831	3	2
832	3	2
833	3	2
834	3	2
835	3	2
836	3	2
1389	3	2
1390	3	2
1392	3	2
25	3	3
190	3	3
191	3	3
192	3	3
382	3	3
383	3	3
384	3	3
385	3	3
564	3	3
565	3	3
566	3	3
567	3	3
568	3	3
569	3	3
570	3	3
571	3	3
572	3	3
573	3	3
574	3	3
575	3	3
576	3	3
1477	3	3
1478	3	3
1479	3	3
27	3	4
28	3	4
34	3	4
35	3	4
36	3	4
37	3	4
38	3	4
39	3	4
40	3	4
41	3	4
42	3	4
54	3	4
132	3	4
135	3	4
139	3	4
204	3	4
205	3	4
206	3	4
207	3	4
753	3	4
754	3	4
757	3	4
758	3	4
1256	3	4
29	3	5
30	3	5
31	3	5
32	3	5
245	3	5
248	3	5
249	3	5
250	3	5
1	3	6
2	3	6
6	3	6
7	3	6
26	3	6
43	3	6
44	3	6
57	3	6
66	3	6
90	3	6
138	3	6
184	3	6
49	3	7
50	3	7
98	3	7
99	3	7
100	3	7
101	3	7
102	3	7
103	3	7
122	3	7
123	3	7
124	3	7
125	3	7
126	3	7
127	3	7
128	3	7
129	3	7
232	3	7
233	3	7
234	3	7
236	3	7
307	3	7
309	3	7
310	3	7
53	3	8
130	3	8
131	3	8
185	3	8
186	3	8
187	3	8
188	3	8
1463	3	8
77	3	9
80	3	9
81	3	9
82	3	9
89	3	9
115	3	9
116	3	9
150	3	9
151	3	9
153	3	9
154	3	9
155	3	9
156	3	9
197	3	9
238	3	9
239	3	9
240	3	9
252	3	9
253	3	9
254	3	9
255	3	9
256	3	9
257	3	9
258	3	9
259	3	9
260	3	9
261	3	9
262	3	9
263	3	9
264	3	9
265	3	9
266	3	9
267	3	9
268	3	9
269	3	9
270	3	9
271	3	9
272	3	9
273	3	9
274	3	9
275	3	9
276	3	9
277	3	9
278	3	9
279	3	9
280	3	9
281	3	9
282	3	9
283	3	9
284	3	9
285	3	9
286	3	9
287	3	9
288	3	9
289	3	9
290	3	9
291	3	9
292	3	9
293	3	9
294	3	9
295	3	9
296	3	9
297	3	9
298	3	9
407	3	9
408	3	9
409	3	9
410	3	9
411	3	9
500	3	9
501	3	9
502	3	9
503	3	9
504	3	9
505	3	9
506	3	9
507	3	9
508	3	9
509	3	9
510	3	9
511	3	9
512	3	9
513	3	9
514	3	9
515	3	9
516	3	9
517	3	9
518	3	9
519	3	9
520	3	9
1209	3	9
1243	3	9
1244	3	9
1245	3	9
1246	3	9
1247	3	9
1248	3	9
1249	3	9
1250	3	9
1253	3	9
1255	3	9
1257	3	9
1258	3	9
1259	3	9
1260	3	9
1261	3	9
1262	3	9
1263	3	9
1264	3	9
1265	3	9
1266	3	9
1267	3	9
1268	3	9
1269	3	9
1270	3	9
1271	3	9
1272	3	9
1273	3	9
1274	3	9
1275	3	9
1276	3	9
1277	3	9
1278	3	9
1279	3	9
1280	3	9
1281	3	9
1282	3	9
1283	3	9
1284	3	9
1285	3	9
1286	3	9
1287	3	9
1288	3	9
1289	3	9
1290	3	9
1292	3	9
1293	3	9
1294	3	9
1295	3	9
1296	3	9
1298	3	9
1299	3	9
1485	3	9
1486	3	9
1487	3	9
1488	3	9
1489	3	9
1490	3	9
1491	3	9
1492	3	9
1493	3	9
1494	3	9
1495	3	9
1498	3	9
1499	3	9
1500	3	9
1501	3	9
1502	3	9
1503	3	9
1504	3	9
1519	3	9
1520	3	9
351	3	10
346	3	10
370	3	10
146	3	10
607	3	10
350	3	10
162	3	10
378	3	10
341	3	10
314	3	10
322	3	10
582	3	10
364	3	10
170	3	10
169	3	10
330	3	10
605	3	10
345	3	10
92	3	10
379	3	10
323	3	10
348	3	10
337	3	10
320	3	10
375	3	10
589	3	10
583	3	10
149	3	10
577	3	10
329	3	10
189	3	10
161	3	10
601	3	10
590	3	10
376	3	10
328	3	10
147	3	10
338	3	10
587	3	10
358	3	10
578	3	10
610	3	10
349	3	10
592	3	10
579	3	10
160	3	10
602	3	10
172	3	10
324	3	10
357	3	10
331	3	10
599	3	10
584	3	10
353	3	10
171	3	10
315	3	10
366	3	10
165	3	10
604	3	10
347	3	10
361	3	10
321	3	10
333	3	10
325	3	10
105	3	10
804	3	10
107	3	10
134	3	10
334	3	10
144	3	10
168	3	10
163	3	10
598	3	10
93	3	10
373	3	10
352	3	10
363	3	10
343	3	10
596	3	10
362	3	10
327	3	10
581	3	10
167	3	10
340	3	10
158	3	10
594	3	10
356	3	10
133	3	10
609	3	10
608	3	10
317	3	10
342	3	10
111	3	10
368	3	10
372	3	10
369	3	10
339	3	10
600	3	10
326	3	10
166	3	10
360	3	10
344	3	10
595	3	10
371	3	10
367	3	10
374	3	10
588	3	10
335	3	10
365	3	10
355	3	10
603	3	10
591	3	10
586	3	10
157	3	10
336	3	10
318	3	10
606	3	10
381	3	10
313	3	10
359	3	10
597	3	10
354	3	10
140	3	10
593	3	10
164	3	10
377	3	10
159	3	10
94	3	10
611	3	10
316	3	10
580	3	10
332	3	10
319	3	10
106	3	10
380	3	10
145	3	10
148	3	10
143	3	10
612	3	10
585	3	10
97	3	11
177	3	11
178	3	11
108	3	12
109	3	12
110	3	12
200	3	12
201	3	12
202	3	12
203	3	12
1480	3	12
1481	3	12
1482	3	12
173	3	13
174	3	13
175	3	13
176	3	13
311	3	13
312	3	13
180	3	15
182	3	15
183	3	16
1254	3	16
193	3	14
195	3	14
196	3	14
208	3	14
209	3	14
469	3	14
470	3	14
471	3	14
472	3	14
473	3	14
474	3	14
475	3	14
476	3	14
477	3	14
478	3	14
479	3	14
480	3	14
481	3	14
482	3	14
483	3	14
484	3	14
486	3	14
487	3	14
488	3	14
489	3	14
490	3	14
491	3	14
492	3	14
493	3	14
495	3	14
496	3	14
497	3	14
498	3	14
813	3	14
1210	3	14
1211	3	14
1212	3	14
1213	3	14
1214	3	14
1215	3	14
1216	3	14
1217	3	14
1218	3	14
1219	3	14
1220	3	14
1221	3	14
1222	3	14
1223	3	14
1224	3	14
1225	3	14
1226	3	14
1227	3	14
1228	3	14
1229	3	14
1230	3	14
1231	3	14
1232	3	14
1233	3	14
1234	3	14
1235	3	14
1236	3	14
1237	3	14
1238	3	14
1239	3	14
1240	3	14
1241	3	14
1242	3	14
1251	3	14
1395	3	14
1397	3	14
1398	3	14
1399	3	14
1400	3	14
1401	3	14
1402	3	14
1403	3	14
1404	3	14
1405	3	14
235	3	18
299	3	18
300	3	18
301	3	18
302	3	18
303	3	18
304	3	18
306	3	18
237	3	17
1530	3	17
1531	3	17
241	3	19
242	3	19
386	3	19
414	3	19
532	3	19
533	3	19
534	3	19
535	3	19
536	3	19
537	3	19
538	3	19
539	3	19
540	3	19
541	3	19
542	3	19
543	3	19
544	3	19
545	3	19
546	3	19
547	3	19
548	3	19
549	3	19
550	3	19
551	3	19
552	3	19
553	3	19
554	3	19
555	3	19
556	3	19
557	3	19
558	3	19
559	3	19
560	3	19
561	3	19
562	3	19
563	3	19
837	3	19
1406	3	19
1407	3	19
1408	3	19
1409	3	19
1410	3	19
1412	3	19
1413	3	19
1416	3	19
1417	3	19
1418	3	19
1419	3	19
1420	3	19
104	4	18
299	4	18
300	4	18
301	4	18
302	4	18
303	4	18
304	4	18
180	4	15
181	4	15
182	4	15
1217	4	14
1218	4	14
1219	4	14
1220	4	14
1221	4	14
1222	4	14
1223	4	14
1224	4	14
1225	4	14
1226	4	14
1227	4	14
1228	4	14
1229	4	14
1230	4	14
1231	4	14
1232	4	14
1233	4	14
1234	4	14
1235	4	14
1236	4	14
1237	4	14
1238	4	14
1239	4	14
1240	4	14
1241	4	14
1242	4	14
1251	4	14
1395	4	14
1397	4	14
1398	4	14
521	3	20
522	3	20
523	3	20
524	3	20
525	3	20
526	3	20
527	3	20
528	3	20
529	3	20
530	3	20
531	3	20
1464	3	20
1465	3	20
1470	3	20
1471	3	20
1472	3	20
1473	3	20
1474	3	20
1252	3	21
1297	3	21
1421	3	22
1422	3	22
1423	3	22
8	4	2
9	4	2
10	4	2
11	4	2
12	4	2
13	4	2
14	4	2
17	4	2
18	4	2
19	4	2
20	4	2
21	4	2
22	4	2
23	4	2
33	4	2
48	4	2
51	4	2
52	4	2
67	4	2
68	4	2
69	4	2
70	4	2
71	4	2
72	4	2
73	4	2
74	4	2
75	4	2
76	4	2
112	4	2
113	4	2
114	4	2
243	4	2
244	4	2
246	4	2
247	4	2
387	4	2
388	4	2
389	4	2
390	4	2
391	4	2
392	4	2
393	4	2
394	4	2
395	4	2
396	4	2
397	4	2
398	4	2
399	4	2
400	4	2
401	4	2
402	4	2
403	4	2
404	4	2
405	4	2
406	4	2
412	4	2
413	4	2
416	4	2
417	4	2
418	4	2
419	4	2
420	4	2
421	4	2
422	4	2
423	4	2
424	4	2
425	4	2
427	4	2
428	4	2
429	4	2
430	4	2
431	4	2
432	4	2
433	4	2
434	4	2
435	4	2
436	4	2
437	4	2
438	4	2
439	4	2
440	4	2
442	4	2
613	4	2
614	4	2
615	4	2
616	4	2
617	4	2
824	4	2
825	4	2
826	4	2
827	4	2
828	4	2
829	4	2
830	4	2
831	4	2
832	4	2
833	4	2
834	4	2
835	4	2
836	4	2
1389	4	2
1390	4	2
1392	4	2
24	4	1
55	4	1
56	4	1
58	4	1
59	4	1
60	4	1
62	4	1
63	4	1
64	4	1
65	4	1
78	4	1
79	4	1
84	4	1
85	4	1
86	4	1
87	4	1
117	4	1
118	4	1
119	4	1
152	4	1
210	4	1
211	4	1
212	4	1
213	4	1
214	4	1
215	4	1
216	4	1
217	4	1
218	4	1
219	4	1
220	4	1
221	4	1
222	4	1
223	4	1
224	4	1
225	4	1
226	4	1
227	4	1
443	4	1
444	4	1
445	4	1
452	4	1
453	4	1
454	4	1
456	4	1
458	4	1
461	4	1
465	4	1
466	4	1
467	4	1
468	4	1
811	4	1
1476	4	1
25	4	3
190	4	3
191	4	3
192	4	3
382	4	3
383	4	3
384	4	3
385	4	3
564	4	3
565	4	3
566	4	3
567	4	3
568	4	3
569	4	3
570	4	3
571	4	3
572	4	3
573	4	3
574	4	3
575	4	3
576	4	3
1477	4	3
1478	4	3
1479	4	3
27	4	4
28	4	4
34	4	4
35	4	4
36	4	4
37	4	4
38	4	4
39	4	4
40	4	4
41	4	4
42	4	4
54	4	4
132	4	4
135	4	4
139	4	4
204	4	4
205	4	4
206	4	4
207	4	4
753	4	4
754	4	4
757	4	4
758	4	4
1256	4	4
29	4	5
30	4	5
31	4	5
32	4	5
245	4	5
248	4	5
249	4	5
250	4	5
1	4	6
2	4	6
6	4	6
7	4	6
45	4	6
46	4	6
47	4	6
57	4	6
90	4	6
184	4	6
53	4	8
130	4	8
131	4	8
185	4	8
186	4	8
187	4	8
188	4	8
1463	4	8
77	4	9
80	4	9
81	4	9
82	4	9
89	4	9
115	4	9
116	4	9
150	4	9
151	4	9
153	4	9
154	4	9
155	4	9
156	4	9
197	4	9
238	4	9
239	4	9
240	4	9
252	4	9
253	4	9
254	4	9
255	4	9
256	4	9
257	4	9
258	4	9
259	4	9
260	4	9
261	4	9
262	4	9
263	4	9
264	4	9
265	4	9
266	4	9
267	4	9
268	4	9
269	4	9
270	4	9
271	4	9
272	4	9
273	4	9
274	4	9
275	4	9
276	4	9
277	4	9
278	4	9
279	4	9
280	4	9
281	4	9
282	4	9
283	4	9
284	4	9
285	4	9
286	4	9
287	4	9
288	4	9
289	4	9
290	4	9
291	4	9
292	4	9
293	4	9
294	4	9
295	4	9
296	4	9
297	4	9
298	4	9
407	4	9
408	4	9
409	4	9
410	4	9
411	4	9
500	4	9
501	4	9
502	4	9
503	4	9
504	4	9
505	4	9
506	4	9
507	4	9
508	4	9
509	4	9
510	4	9
511	4	9
512	4	9
513	4	9
514	4	9
515	4	9
516	4	9
517	4	9
518	4	9
519	4	9
520	4	9
1209	4	9
1243	4	9
1244	4	9
1245	4	9
1246	4	9
1247	4	9
1248	4	9
1249	4	9
1250	4	9
1253	4	9
1255	4	9
1257	4	9
1258	4	9
1259	4	9
1260	4	9
1261	4	9
1262	4	9
1263	4	9
1264	4	9
1265	4	9
1266	4	9
1267	4	9
1268	4	9
1269	4	9
1270	4	9
1271	4	9
1272	4	9
1273	4	9
1274	4	9
1275	4	9
1276	4	9
1277	4	9
1278	4	9
1279	4	9
1280	4	9
1281	4	9
1282	4	9
1283	4	9
1284	4	9
1285	4	9
1286	4	9
1287	4	9
1288	4	9
1289	4	9
1290	4	9
1292	4	9
1293	4	9
1294	4	9
1295	4	9
1296	4	9
1298	4	9
1299	4	9
1485	4	9
1486	4	9
1487	4	9
1488	4	9
1489	4	9
1490	4	9
1491	4	9
1492	4	9
1493	4	9
1494	4	9
1495	4	9
1498	4	9
1499	4	9
1500	4	9
1501	4	9
1502	4	9
1503	4	9
1504	4	9
1519	4	9
1520	4	9
88	4	23
96	4	23
351	4	10
346	4	10
370	4	10
146	4	10
607	4	10
350	4	10
162	4	10
378	4	10
341	4	10
314	4	10
322	4	10
582	4	10
364	4	10
170	4	10
169	4	10
330	4	10
605	4	10
345	4	10
92	4	10
379	4	10
323	4	10
348	4	10
337	4	10
320	4	10
375	4	10
589	4	10
583	4	10
149	4	10
577	4	10
329	4	10
189	4	10
161	4	10
601	4	10
590	4	10
376	4	10
328	4	10
147	4	10
338	4	10
587	4	10
358	4	10
578	4	10
610	4	10
349	4	10
592	4	10
579	4	10
160	4	10
602	4	10
172	4	10
324	4	10
357	4	10
331	4	10
599	4	10
584	4	10
353	4	10
171	4	10
315	4	10
366	4	10
165	4	10
604	4	10
347	4	10
361	4	10
321	4	10
333	4	10
325	4	10
105	4	10
804	4	10
107	4	10
134	4	10
334	4	10
144	4	10
168	4	10
163	4	10
598	4	10
93	4	10
373	4	10
352	4	10
363	4	10
343	4	10
596	4	10
362	4	10
327	4	10
581	4	10
167	4	10
340	4	10
158	4	10
594	4	10
356	4	10
133	4	10
609	4	10
608	4	10
317	4	10
342	4	10
111	4	10
368	4	10
372	4	10
369	4	10
339	4	10
600	4	10
326	4	10
166	4	10
360	4	10
344	4	10
595	4	10
371	4	10
367	4	10
374	4	10
588	4	10
335	4	10
365	4	10
355	4	10
603	4	10
591	4	10
586	4	10
157	4	10
336	4	10
318	4	10
606	4	10
381	4	10
313	4	10
359	4	10
597	4	10
354	4	10
140	4	10
593	4	10
164	4	10
377	4	10
159	4	10
94	4	10
611	4	10
316	4	10
580	4	10
332	4	10
319	4	10
106	4	10
380	4	10
145	4	10
148	4	10
143	4	10
612	4	10
585	4	10
108	4	12
109	4	12
110	4	12
200	4	12
201	4	12
202	4	12
203	4	12
1480	4	12
1481	4	12
1482	4	12
183	4	16
1254	4	16
1399	4	14
1400	4	14
1401	4	14
1402	4	14
1403	4	14
1404	4	14
1405	4	14
237	4	17
1530	4	17
1531	4	17
241	4	19
242	4	19
386	4	19
414	4	19
532	4	19
533	4	19
534	4	19
535	4	19
536	4	19
537	4	19
538	4	19
539	4	19
540	4	19
541	4	19
542	4	19
543	4	19
544	4	19
545	4	19
546	4	19
547	4	19
548	4	19
549	4	19
550	4	19
551	4	19
552	4	19
553	4	19
554	4	19
555	4	19
556	4	19
557	4	19
558	4	19
559	4	19
560	4	19
561	4	19
562	4	19
563	4	19
837	4	19
1406	4	19
1407	4	19
1408	4	19
1409	4	19
1410	4	19
1412	4	19
1413	4	19
1416	4	19
1417	4	19
1418	4	19
1419	4	19
1420	4	19
24	7	1
55	7	1
56	7	1
58	7	1
59	7	1
60	7	1
62	7	1
63	7	1
64	7	1
65	7	1
78	7	1
79	7	1
84	7	1
85	7	1
86	7	1
87	7	1
117	7	1
118	7	1
119	7	1
152	7	1
521	4	20
522	4	20
523	4	20
524	4	20
525	4	20
526	4	20
527	4	20
528	4	20
529	4	20
530	4	20
531	4	20
1464	4	20
1465	4	20
1470	4	20
1471	4	20
1472	4	20
1473	4	20
1474	4	20
1252	4	21
1297	4	21
1421	4	22
1422	4	22
1423	4	22
8	5	2
9	5	2
10	5	2
11	5	2
12	5	2
13	5	2
14	5	2
17	5	2
18	5	2
19	5	2
20	5	2
21	5	2
22	5	2
23	5	2
33	5	2
48	5	2
51	5	2
52	5	2
67	5	2
68	5	2
69	5	2
70	5	2
71	5	2
72	5	2
73	5	2
74	5	2
75	5	2
76	5	2
112	5	2
113	5	2
114	5	2
243	5	2
244	5	2
246	5	2
247	5	2
387	5	2
388	5	2
389	5	2
390	5	2
391	5	2
392	5	2
393	5	2
394	5	2
395	5	2
396	5	2
399	5	2
400	5	2
401	5	2
402	5	2
403	5	2
404	5	2
405	5	2
406	5	2
412	5	2
413	5	2
416	5	2
417	5	2
418	5	2
419	5	2
420	5	2
421	5	2
422	5	2
423	5	2
424	5	2
425	5	2
426	5	2
427	5	2
428	5	2
429	5	2
430	5	2
431	5	2
432	5	2
433	5	2
434	5	2
435	5	2
436	5	2
437	5	2
438	5	2
439	5	2
440	5	2
442	5	2
613	5	2
614	5	2
615	5	2
616	5	2
617	5	2
824	5	2
825	5	2
826	5	2
827	5	2
828	5	2
829	5	2
830	5	2
831	5	2
832	5	2
833	5	2
834	5	2
835	5	2
836	5	2
1389	5	2
1390	5	2
1392	5	2
15	5	1
16	5	1
24	5	1
55	5	1
56	5	1
58	5	1
59	5	1
60	5	1
61	5	1
62	5	1
63	5	1
64	5	1
65	5	1
78	5	1
79	5	1
83	5	1
84	5	1
85	5	1
86	5	1
87	5	1
91	5	1
117	5	1
118	5	1
119	5	1
120	5	1
121	5	1
152	5	1
210	5	1
211	5	1
212	5	1
213	5	1
214	5	1
215	5	1
216	5	1
217	5	1
218	5	1
219	5	1
220	5	1
221	5	1
222	5	1
223	5	1
224	5	1
225	5	1
226	5	1
227	5	1
228	5	1
229	5	1
230	5	1
231	5	1
305	5	1
308	5	1
443	5	1
444	5	1
445	5	1
446	5	1
447	5	1
448	5	1
449	5	1
450	5	1
452	5	1
453	5	1
454	5	1
455	5	1
456	5	1
457	5	1
458	5	1
459	5	1
460	5	1
461	5	1
462	5	1
463	5	1
464	5	1
465	5	1
466	5	1
467	5	1
468	5	1
805	5	1
811	5	1
1476	5	1
25	5	3
190	5	3
191	5	3
192	5	3
382	5	3
383	5	3
384	5	3
385	5	3
564	5	3
565	5	3
566	5	3
567	5	3
568	5	3
569	5	3
570	5	3
571	5	3
572	5	3
573	5	3
574	5	3
575	5	3
576	5	3
1477	5	3
1478	5	3
1479	5	3
27	5	4
28	5	4
34	5	4
35	5	4
36	5	4
37	5	4
38	5	4
39	5	4
40	5	4
41	5	4
42	5	4
54	5	4
132	5	4
135	5	4
139	5	4
204	5	4
205	5	4
206	5	4
753	5	4
754	5	4
757	5	4
758	5	4
1256	5	4
29	5	5
30	5	5
31	5	5
32	5	5
245	5	5
248	5	5
249	5	5
250	5	5
1	5	6
6	5	6
7	5	6
26	5	6
43	5	6
44	5	6
57	5	6
90	5	6
138	5	6
184	5	6
53	5	8
130	5	8
131	5	8
185	5	8
186	5	8
187	5	8
188	5	8
1463	5	8
77	5	9
80	5	9
81	5	9
82	5	9
89	5	9
115	5	9
116	5	9
150	5	9
151	5	9
153	5	9
154	5	9
155	5	9
156	5	9
197	5	9
238	5	9
239	5	9
252	5	9
253	5	9
254	5	9
255	5	9
256	5	9
257	5	9
258	5	9
259	5	9
260	5	9
261	5	9
262	5	9
263	5	9
264	5	9
265	5	9
266	5	9
267	5	9
268	5	9
269	5	9
270	5	9
271	5	9
272	5	9
273	5	9
274	5	9
275	5	9
276	5	9
277	5	9
278	5	9
279	5	9
280	5	9
281	5	9
282	5	9
283	5	9
284	5	9
285	5	9
286	5	9
287	5	9
288	5	9
290	5	9
291	5	9
292	5	9
293	5	9
294	5	9
295	5	9
296	5	9
297	5	9
298	5	9
407	5	9
408	5	9
409	5	9
410	5	9
411	5	9
500	5	9
501	5	9
502	5	9
503	5	9
504	5	9
505	5	9
506	5	9
507	5	9
508	5	9
509	5	9
510	5	9
511	5	9
512	5	9
513	5	9
514	5	9
515	5	9
516	5	9
517	5	9
518	5	9
519	5	9
520	5	9
1209	5	9
1243	5	9
1244	5	9
1245	5	9
1246	5	9
1247	5	9
1248	5	9
1249	5	9
1250	5	9
1253	5	9
1255	5	9
1257	5	9
1258	5	9
1259	5	9
1260	5	9
1261	5	9
1262	5	9
1263	5	9
1264	5	9
1265	5	9
1266	5	9
1267	5	9
1268	5	9
1269	5	9
1270	5	9
1271	5	9
1272	5	9
1273	5	9
1274	5	9
1275	5	9
1276	5	9
1277	5	9
1278	5	9
1279	5	9
1280	5	9
1281	5	9
1282	5	9
1283	5	9
1284	5	9
1285	5	9
1286	5	9
1287	5	9
1288	5	9
1289	5	9
1290	5	9
1292	5	9
1293	5	9
1294	5	9
1295	5	9
1296	5	9
1298	5	9
1299	5	9
1485	5	9
1486	5	9
1487	5	9
1488	5	9
1489	5	9
1490	5	9
1491	5	9
1492	5	9
1493	5	9
1494	5	9
1495	5	9
1501	5	9
1502	5	9
1503	5	9
1504	5	9
1519	5	9
1520	5	9
351	5	10
346	5	10
370	5	10
146	5	10
607	5	10
350	5	10
162	5	10
378	5	10
341	5	10
314	5	10
322	5	10
582	5	10
364	5	10
170	5	10
169	5	10
330	5	10
605	5	10
345	5	10
92	5	10
379	5	10
323	5	10
348	5	10
337	5	10
320	5	10
375	5	10
589	5	10
583	5	10
149	5	10
577	5	10
329	5	10
189	5	10
161	5	10
601	5	10
590	5	10
376	5	10
328	5	10
147	5	10
338	5	10
587	5	10
358	5	10
578	5	10
610	5	10
349	5	10
592	5	10
579	5	10
160	5	10
602	5	10
172	5	10
324	5	10
357	5	10
331	5	10
599	5	10
584	5	10
353	5	10
171	5	10
315	5	10
366	5	10
165	5	10
604	5	10
347	5	10
361	5	10
321	5	10
333	5	10
325	5	10
804	5	10
107	5	10
134	5	10
334	5	10
144	5	10
168	5	10
163	5	10
598	5	10
93	5	10
373	5	10
352	5	10
363	5	10
343	5	10
596	5	10
362	5	10
327	5	10
581	5	10
167	5	10
340	5	10
158	5	10
594	5	10
356	5	10
133	5	10
609	5	10
608	5	10
317	5	10
342	5	10
111	5	10
368	5	10
372	5	10
369	5	10
339	5	10
600	5	10
326	5	10
166	5	10
360	5	10
344	5	10
595	5	10
371	5	10
367	5	10
374	5	10
588	5	10
335	5	10
365	5	10
355	5	10
603	5	10
591	5	10
586	5	10
157	5	10
336	5	10
318	5	10
606	5	10
381	5	10
313	5	10
359	5	10
597	5	10
354	5	10
140	5	10
593	5	10
164	5	10
377	5	10
159	5	10
94	5	10
611	5	10
316	5	10
580	5	10
332	5	10
319	5	10
106	5	10
380	5	10
145	5	10
148	5	10
143	5	10
612	5	10
585	5	10
97	5	11
177	5	11
178	5	11
108	5	12
109	5	12
110	5	12
200	5	12
201	5	12
202	5	12
203	5	12
1480	5	12
1481	5	12
1482	5	12
128	5	7
129	5	7
307	5	7
310	5	7
173	5	13
174	5	13
175	5	13
176	5	13
311	5	13
312	5	13
180	5	15
182	5	15
183	5	16
1254	5	16
193	5	14
195	5	14
196	5	14
208	5	14
209	5	14
469	5	14
470	5	14
471	5	14
472	5	14
473	5	14
474	5	14
475	5	14
476	5	14
477	5	14
478	5	14
479	5	14
480	5	14
481	5	14
482	5	14
483	5	14
484	5	14
486	5	14
487	5	14
488	5	14
489	5	14
490	5	14
491	5	14
492	5	14
493	5	14
495	5	14
496	5	14
497	5	14
498	5	14
813	5	14
1210	5	14
1211	5	14
1212	5	14
1213	5	14
1214	5	14
1215	5	14
1216	5	14
1217	5	14
1218	5	14
1219	5	14
1220	5	14
1221	5	14
1222	5	14
1223	5	14
1224	5	14
1225	5	14
1226	5	14
1227	5	14
1228	5	14
1229	5	14
1230	5	14
1231	5	14
1232	5	14
1233	5	14
1234	5	14
1235	5	14
1236	5	14
1237	5	14
1238	5	14
1239	5	14
1240	5	14
1241	5	14
1242	5	14
1251	5	14
1395	5	14
1397	5	14
1398	5	14
1400	5	14
1401	5	14
1402	5	14
1403	5	14
1404	5	14
1405	5	14
235	5	18
299	5	18
300	5	18
301	5	18
302	5	18
303	5	18
304	5	18
306	5	18
241	5	19
242	5	19
386	5	19
414	5	19
532	5	19
533	5	19
534	5	19
535	5	19
536	5	19
537	5	19
538	5	19
539	5	19
540	5	19
541	5	19
542	5	19
543	5	19
544	5	19
545	5	19
546	5	19
547	5	19
548	5	19
549	5	19
550	5	19
551	5	19
552	5	19
553	5	19
554	5	19
555	5	19
556	5	19
557	5	19
558	5	19
559	5	19
560	5	19
561	5	19
562	5	19
563	5	19
837	5	19
1406	5	19
1407	5	19
1408	5	19
1409	5	19
1410	5	19
1412	5	19
1413	5	19
1416	5	19
1417	5	19
1418	5	19
1419	5	19
1420	5	19
210	7	1
211	7	1
212	7	1
213	7	1
214	7	1
215	7	1
216	7	1
217	7	1
218	7	1
219	7	1
220	7	1
221	7	1
222	7	1
223	7	1
224	7	1
225	7	1
226	7	1
227	7	1
443	7	1
444	7	1
445	7	1
452	7	1
453	7	1
454	7	1
456	7	1
458	7	1
461	7	1
465	7	1
466	7	1
467	7	1
468	7	1
805	7	1
811	7	1
1476	7	1
27	7	4
28	7	4
34	7	4
35	7	4
36	7	4
521	5	20
522	5	20
523	5	20
524	5	20
525	5	20
526	5	20
527	5	20
528	5	20
529	5	20
530	5	20
531	5	20
1464	5	20
1465	5	20
1470	5	20
1471	5	20
1472	5	20
1473	5	20
1474	5	20
1252	5	21
1297	5	21
1421	5	22
1422	5	22
1423	5	22
1424	5	22
1451	5	22
1530	5	17
3	6	1
4	6	1
5	6	1
15	6	1
16	6	1
24	6	1
55	6	1
56	6	1
58	6	1
59	6	1
60	6	1
61	6	1
62	6	1
63	6	1
64	6	1
65	6	1
78	6	1
79	6	1
83	6	1
84	6	1
85	6	1
86	6	1
87	6	1
91	6	1
117	6	1
118	6	1
119	6	1
120	6	1
121	6	1
152	6	1
210	6	1
211	6	1
212	6	1
213	6	1
214	6	1
215	6	1
216	6	1
217	6	1
218	6	1
219	6	1
220	6	1
221	6	1
222	6	1
223	6	1
224	6	1
225	6	1
226	6	1
227	6	1
228	6	1
229	6	1
230	6	1
231	6	1
305	6	1
308	6	1
443	6	1
444	6	1
445	6	1
446	6	1
447	6	1
448	6	1
449	6	1
450	6	1
452	6	1
453	6	1
454	6	1
455	6	1
456	6	1
457	6	1
458	6	1
459	6	1
460	6	1
461	6	1
462	6	1
463	6	1
464	6	1
465	6	1
466	6	1
467	6	1
468	6	1
805	6	1
811	6	1
1476	6	1
8	6	2
9	6	2
10	6	2
11	6	2
12	6	2
13	6	2
14	6	2
17	6	2
18	6	2
19	6	2
20	6	2
21	6	2
22	6	2
23	6	2
33	6	2
48	6	2
51	6	2
52	6	2
67	6	2
68	6	2
69	6	2
70	6	2
71	6	2
72	6	2
73	6	2
74	6	2
75	6	2
76	6	2
112	6	2
113	6	2
114	6	2
243	6	2
244	6	2
246	6	2
247	6	2
387	6	2
388	6	2
389	6	2
390	6	2
391	6	2
392	6	2
393	6	2
394	6	2
395	6	2
396	6	2
397	6	2
398	6	2
399	6	2
400	6	2
401	6	2
402	6	2
403	6	2
404	6	2
405	6	2
406	6	2
412	6	2
413	6	2
416	6	2
417	6	2
418	6	2
419	6	2
420	6	2
421	6	2
422	6	2
423	6	2
424	6	2
425	6	2
426	6	2
427	6	2
428	6	2
429	6	2
430	6	2
431	6	2
432	6	2
433	6	2
434	6	2
435	6	2
436	6	2
437	6	2
438	6	2
439	6	2
440	6	2
442	6	2
613	6	2
614	6	2
615	6	2
616	6	2
617	6	2
824	6	2
825	6	2
826	6	2
827	6	2
828	6	2
829	6	2
830	6	2
831	6	2
832	6	2
833	6	2
834	6	2
835	6	2
836	6	2
1389	6	2
1390	6	2
1392	6	2
25	6	3
190	6	3
191	6	3
192	6	3
382	6	3
383	6	3
384	6	3
385	6	3
564	6	3
565	6	3
566	6	3
567	6	3
568	6	3
569	6	3
570	6	3
571	6	3
572	6	3
573	6	3
574	6	3
575	6	3
576	6	3
1477	6	3
1478	6	3
1479	6	3
27	6	4
28	6	4
34	6	4
35	6	4
36	6	4
37	6	4
38	6	4
39	6	4
40	6	4
41	6	4
42	6	4
54	6	4
132	6	4
135	6	4
139	6	4
204	6	4
205	6	4
206	6	4
753	6	4
754	6	4
757	6	4
758	6	4
1256	6	4
29	6	5
30	6	5
31	6	5
32	6	5
245	6	5
248	6	5
249	6	5
250	6	5
1	6	6
2	6	6
6	6	6
7	6	6
26	6	6
43	6	6
44	6	6
57	6	6
90	6	6
138	6	6
184	6	6
53	6	8
130	6	8
131	6	8
185	6	8
186	6	8
187	6	8
188	6	8
1463	6	8
77	6	9
80	6	9
81	6	9
82	6	9
89	6	9
115	6	9
116	6	9
150	6	9
151	6	9
153	6	9
154	6	9
155	6	9
156	6	9
197	6	9
238	6	9
239	6	9
252	6	9
253	6	9
254	6	9
255	6	9
256	6	9
257	6	9
258	6	9
259	6	9
260	6	9
261	6	9
262	6	9
263	6	9
264	6	9
265	6	9
266	6	9
267	6	9
268	6	9
269	6	9
270	6	9
271	6	9
272	6	9
273	6	9
274	6	9
275	6	9
276	6	9
277	6	9
278	6	9
279	6	9
280	6	9
281	6	9
282	6	9
283	6	9
284	6	9
285	6	9
286	6	9
287	6	9
288	6	9
290	6	9
291	6	9
292	6	9
293	6	9
294	6	9
295	6	9
296	6	9
297	6	9
298	6	9
407	6	9
408	6	9
409	6	9
410	6	9
411	6	9
500	6	9
501	6	9
502	6	9
503	6	9
504	6	9
505	6	9
506	6	9
507	6	9
508	6	9
509	6	9
510	6	9
511	6	9
512	6	9
513	6	9
514	6	9
515	6	9
516	6	9
517	6	9
518	6	9
519	6	9
520	6	9
1209	6	9
1243	6	9
1244	6	9
1245	6	9
1246	6	9
1247	6	9
1248	6	9
1249	6	9
1250	6	9
1253	6	9
1255	6	9
1257	6	9
1258	6	9
1259	6	9
1260	6	9
1261	6	9
1262	6	9
1263	6	9
1264	6	9
1265	6	9
1266	6	9
1267	6	9
1268	6	9
1269	6	9
1270	6	9
1271	6	9
1272	6	9
1273	6	9
1274	6	9
1275	6	9
1276	6	9
1277	6	9
1278	6	9
1279	6	9
1280	6	9
1281	6	9
1282	6	9
1283	6	9
1284	6	9
1285	6	9
1286	6	9
1287	6	9
1288	6	9
1289	6	9
1290	6	9
1292	6	9
1293	6	9
1294	6	9
1295	6	9
1296	6	9
1298	6	9
1299	6	9
1485	6	9
1486	6	9
1487	6	9
1488	6	9
1489	6	9
1490	6	9
1491	6	9
1492	6	9
1493	6	9
1494	6	9
1495	6	9
1501	6	9
1502	6	9
1503	6	9
1504	6	9
1519	6	9
1520	6	9
351	6	10
346	6	10
370	6	10
146	6	10
607	6	10
350	6	10
162	6	10
378	6	10
341	6	10
314	6	10
322	6	10
582	6	10
364	6	10
170	6	10
169	6	10
330	6	10
605	6	10
345	6	10
92	6	10
379	6	10
323	6	10
348	6	10
337	6	10
320	6	10
375	6	10
589	6	10
583	6	10
149	6	10
577	6	10
329	6	10
189	6	10
161	6	10
601	6	10
590	6	10
376	6	10
328	6	10
147	6	10
338	6	10
587	6	10
358	6	10
578	6	10
610	6	10
349	6	10
592	6	10
579	6	10
160	6	10
602	6	10
172	6	10
324	6	10
357	6	10
331	6	10
599	6	10
584	6	10
353	6	10
171	6	10
315	6	10
366	6	10
165	6	10
604	6	10
347	6	10
361	6	10
321	6	10
333	6	10
325	6	10
804	6	10
107	6	10
134	6	10
334	6	10
144	6	10
168	6	10
163	6	10
598	6	10
93	6	10
373	6	10
352	6	10
363	6	10
343	6	10
596	6	10
362	6	10
327	6	10
581	6	10
167	6	10
340	6	10
158	6	10
594	6	10
356	6	10
133	6	10
609	6	10
608	6	10
317	6	10
342	6	10
111	6	10
368	6	10
372	6	10
369	6	10
339	6	10
600	6	10
326	6	10
166	6	10
360	6	10
344	6	10
595	6	10
371	6	10
367	6	10
374	6	10
588	6	10
335	6	10
365	6	10
355	6	10
603	6	10
591	6	10
586	6	10
157	6	10
336	6	10
318	6	10
606	6	10
381	6	10
313	6	10
359	6	10
597	6	10
354	6	10
140	6	10
593	6	10
164	6	10
377	6	10
159	6	10
94	6	10
611	6	10
316	6	10
580	6	10
332	6	10
319	6	10
106	6	10
380	6	10
145	6	10
148	6	10
143	6	10
612	6	10
585	6	10
97	6	11
177	6	11
178	6	11
108	6	12
109	6	12
110	6	12
200	6	12
201	6	12
202	6	12
203	6	12
1480	6	12
1481	6	12
1482	6	12
128	6	7
129	6	7
307	6	7
310	6	7
173	6	13
174	6	13
175	6	13
176	6	13
311	6	13
312	6	13
180	6	15
182	6	15
183	6	16
1254	6	16
193	6	14
195	6	14
196	6	14
208	6	14
209	6	14
469	6	14
470	6	14
471	6	14
472	6	14
473	6	14
474	6	14
475	6	14
476	6	14
477	6	14
478	6	14
479	6	14
480	6	14
481	6	14
482	6	14
483	6	14
484	6	14
486	6	14
487	6	14
488	6	14
489	6	14
490	6	14
491	6	14
492	6	14
493	6	14
495	6	14
496	6	14
497	6	14
498	6	14
813	6	14
1210	6	14
1211	6	14
1212	6	14
1213	6	14
1214	6	14
1215	6	14
1216	6	14
1217	6	14
1218	6	14
1219	6	14
1220	6	14
1221	6	14
1222	6	14
1223	6	14
1224	6	14
1225	6	14
1226	6	14
1227	6	14
1228	6	14
1229	6	14
1230	6	14
1231	6	14
1232	6	14
1233	6	14
1234	6	14
1235	6	14
1236	6	14
1237	6	14
1238	6	14
1239	6	14
1240	6	14
1241	6	14
1242	6	14
1251	6	14
1395	6	14
1397	6	14
1398	6	14
1400	6	14
1401	6	14
1402	6	14
1403	6	14
1404	6	14
1405	6	14
235	6	18
299	6	18
300	6	18
301	6	18
302	6	18
303	6	18
304	6	18
306	6	18
241	6	19
242	6	19
386	6	19
414	6	19
532	6	19
533	6	19
534	6	19
535	6	19
536	6	19
537	6	19
538	6	19
539	6	19
540	6	19
541	6	19
542	6	19
543	6	19
544	6	19
545	6	19
546	6	19
547	6	19
548	6	19
549	6	19
550	6	19
551	6	19
552	6	19
553	6	19
554	6	19
555	6	19
556	6	19
557	6	19
558	6	19
559	6	19
560	6	19
561	6	19
562	6	19
563	6	19
837	6	19
1406	6	19
1407	6	19
1408	6	19
1409	6	19
1410	6	19
1412	6	19
1413	6	19
1416	6	19
1417	6	19
1418	6	19
1419	6	19
1420	6	19
25	7	3
190	7	3
191	7	3
192	7	3
382	7	3
383	7	3
384	7	3
385	7	3
564	7	3
565	7	3
566	7	3
567	7	3
568	7	3
569	7	3
570	7	3
571	7	3
572	7	3
573	7	3
574	7	3
575	7	3
521	6	20
522	6	20
523	6	20
524	6	20
525	6	20
526	6	20
527	6	20
528	6	20
529	6	20
530	6	20
531	6	20
1464	6	20
1465	6	20
1470	6	20
1471	6	20
1472	6	20
1473	6	20
1474	6	20
1252	6	21
1297	6	21
1421	6	22
1422	6	22
1423	6	22
1424	6	22
1451	6	22
1530	6	17
8	7	2
9	7	2
10	7	2
11	7	2
12	7	2
13	7	2
14	7	2
17	7	2
18	7	2
19	7	2
20	7	2
21	7	2
22	7	2
23	7	2
33	7	2
48	7	2
51	7	2
52	7	2
67	7	2
68	7	2
69	7	2
70	7	2
71	7	2
72	7	2
73	7	2
74	7	2
75	7	2
76	7	2
112	7	2
113	7	2
114	7	2
243	7	2
244	7	2
246	7	2
247	7	2
387	7	2
388	7	2
389	7	2
390	7	2
391	7	2
392	7	2
393	7	2
394	7	2
395	7	2
396	7	2
399	7	2
400	7	2
401	7	2
402	7	2
403	7	2
404	7	2
405	7	2
406	7	2
412	7	2
413	7	2
416	7	2
417	7	2
418	7	2
419	7	2
420	7	2
421	7	2
422	7	2
423	7	2
424	7	2
425	7	2
427	7	2
428	7	2
429	7	2
430	7	2
431	7	2
432	7	2
433	7	2
434	7	2
435	7	2
436	7	2
437	7	2
438	7	2
439	7	2
440	7	2
442	7	2
613	7	2
614	7	2
615	7	2
616	7	2
617	7	2
824	7	2
825	7	2
826	7	2
827	7	2
828	7	2
829	7	2
830	7	2
831	7	2
832	7	2
833	7	2
834	7	2
835	7	2
836	7	2
1389	7	2
1390	7	2
1392	7	2
576	7	3
1477	7	3
1478	7	3
1479	7	3
37	7	4
38	7	4
39	7	4
40	7	4
41	7	4
42	7	4
54	7	4
132	7	4
135	7	4
139	7	4
204	7	4
205	7	4
206	7	4
753	7	4
754	7	4
757	7	4
758	7	4
1256	7	4
29	7	5
30	7	5
31	7	5
32	7	5
245	7	5
248	7	5
249	7	5
250	7	5
1	7	6
2	7	6
6	7	6
7	7	6
26	7	6
45	7	6
46	7	6
47	7	6
57	7	6
90	7	6
138	7	6
184	7	6
53	7	8
130	7	8
131	7	8
185	7	8
186	7	8
187	7	8
188	7	8
1463	7	8
77	7	9
80	7	9
81	7	9
82	7	9
89	7	9
115	7	9
116	7	9
150	7	9
151	7	9
153	7	9
154	7	9
155	7	9
156	7	9
197	7	9
238	7	9
239	7	9
252	7	9
253	7	9
254	7	9
255	7	9
256	7	9
257	7	9
258	7	9
259	7	9
260	7	9
261	7	9
262	7	9
263	7	9
264	7	9
265	7	9
266	7	9
267	7	9
268	7	9
269	7	9
270	7	9
271	7	9
272	7	9
273	7	9
274	7	9
275	7	9
276	7	9
277	7	9
278	7	9
279	7	9
280	7	9
281	7	9
282	7	9
283	7	9
284	7	9
285	7	9
286	7	9
287	7	9
288	7	9
290	7	9
291	7	9
292	7	9
293	7	9
294	7	9
295	7	9
296	7	9
297	7	9
298	7	9
407	7	9
408	7	9
409	7	9
410	7	9
411	7	9
500	7	9
501	7	9
502	7	9
503	7	9
504	7	9
505	7	9
506	7	9
507	7	9
508	7	9
509	7	9
510	7	9
511	7	9
512	7	9
513	7	9
514	7	9
515	7	9
516	7	9
517	7	9
518	7	9
519	7	9
520	7	9
1209	7	9
1243	7	9
1244	7	9
1245	7	9
1246	7	9
1247	7	9
1248	7	9
1249	7	9
1250	7	9
1253	7	9
1255	7	9
1257	7	9
1258	7	9
1259	7	9
1260	7	9
1261	7	9
1262	7	9
1263	7	9
1264	7	9
1265	7	9
1266	7	9
1267	7	9
1268	7	9
1269	7	9
1270	7	9
1271	7	9
1272	7	9
1273	7	9
1274	7	9
1275	7	9
1276	7	9
1277	7	9
1278	7	9
1279	7	9
1280	7	9
1281	7	9
1282	7	9
1283	7	9
1284	7	9
1285	7	9
1286	7	9
1287	7	9
1288	7	9
1289	7	9
1290	7	9
1292	7	9
1293	7	9
1294	7	9
1295	7	9
1296	7	9
1298	7	9
1299	7	9
1485	7	9
1486	7	9
1487	7	9
1488	7	9
1489	7	9
1490	7	9
1491	7	9
1492	7	9
1493	7	9
1494	7	9
1495	7	9
1501	7	9
1502	7	9
1503	7	9
1504	7	9
1519	7	9
1520	7	9
88	7	23
96	7	23
351	7	10
346	7	10
370	7	10
146	7	10
607	7	10
350	7	10
162	7	10
378	7	10
341	7	10
314	7	10
322	7	10
582	7	10
364	7	10
170	7	10
169	7	10
330	7	10
605	7	10
345	7	10
92	7	10
379	7	10
323	7	10
348	7	10
337	7	10
320	7	10
375	7	10
589	7	10
583	7	10
149	7	10
577	7	10
329	7	10
189	7	10
161	7	10
601	7	10
590	7	10
376	7	10
328	7	10
147	7	10
338	7	10
587	7	10
358	7	10
578	7	10
610	7	10
349	7	10
592	7	10
579	7	10
160	7	10
602	7	10
172	7	10
324	7	10
357	7	10
331	7	10
599	7	10
584	7	10
353	7	10
171	7	10
315	7	10
366	7	10
165	7	10
604	7	10
347	7	10
361	7	10
321	7	10
333	7	10
325	7	10
804	7	10
107	7	10
134	7	10
334	7	10
144	7	10
168	7	10
163	7	10
598	7	10
93	7	10
373	7	10
352	7	10
363	7	10
343	7	10
596	7	10
362	7	10
327	7	10
581	7	10
167	7	10
340	7	10
158	7	10
594	7	10
356	7	10
133	7	10
609	7	10
608	7	10
317	7	10
342	7	10
111	7	10
368	7	10
372	7	10
369	7	10
339	7	10
600	7	10
326	7	10
166	7	10
360	7	10
344	7	10
595	7	10
371	7	10
367	7	10
374	7	10
588	7	10
335	7	10
365	7	10
355	7	10
603	7	10
591	7	10
586	7	10
157	7	10
336	7	10
318	7	10
606	7	10
381	7	10
313	7	10
359	7	10
597	7	10
354	7	10
140	7	10
593	7	10
164	7	10
377	7	10
159	7	10
94	7	10
611	7	10
316	7	10
580	7	10
332	7	10
319	7	10
106	7	10
380	7	10
145	7	10
148	7	10
143	7	10
612	7	10
585	7	10
97	7	11
177	7	11
178	7	11
108	7	12
109	7	12
110	7	12
200	7	12
201	7	12
202	7	12
203	7	12
1480	7	12
1481	7	12
1482	7	12
128	7	7
129	7	7
310	7	7
173	7	13
174	7	13
175	7	13
176	7	13
311	7	13
312	7	13
180	7	15
181	7	15
182	7	15
183	7	16
1254	7	16
193	7	14
195	7	14
196	7	14
208	7	14
209	7	14
469	7	14
470	7	14
471	7	14
472	7	14
473	7	14
474	7	14
475	7	14
476	7	14
477	7	14
478	7	14
479	7	14
480	7	14
481	7	14
482	7	14
483	7	14
484	7	14
486	7	14
487	7	14
488	7	14
489	7	14
490	7	14
491	7	14
492	7	14
493	7	14
495	7	14
496	7	14
497	7	14
498	7	14
813	7	14
1210	7	14
1211	7	14
1212	7	14
1213	7	14
1214	7	14
1215	7	14
1216	7	14
1217	7	14
1218	7	14
1219	7	14
1220	7	14
1221	7	14
1222	7	14
1223	7	14
1224	7	14
1225	7	14
1226	7	14
1227	7	14
1228	7	14
1229	7	14
1230	7	14
1231	7	14
1232	7	14
1233	7	14
1234	7	14
1235	7	14
1236	7	14
1237	7	14
1238	7	14
1239	7	14
1240	7	14
1241	7	14
1242	7	14
1251	7	14
1395	7	14
1397	7	14
1398	7	14
1400	7	14
1401	7	14
1402	7	14
1403	7	14
1404	7	14
1405	7	14
241	7	19
242	7	19
386	7	19
414	7	19
532	7	19
533	7	19
534	7	19
535	7	19
536	7	19
537	7	19
538	7	19
539	7	19
540	7	19
541	7	19
542	7	19
543	7	19
544	7	19
545	7	19
546	7	19
547	7	19
548	7	19
549	7	19
550	7	19
551	7	19
552	7	19
553	7	19
554	7	19
555	7	19
556	7	19
557	7	19
558	7	19
559	7	19
560	7	19
561	7	19
562	7	19
563	7	19
837	7	19
1406	7	19
1407	7	19
1408	7	19
1409	7	19
1410	7	19
1412	7	19
1413	7	19
1416	7	19
1417	7	19
1418	7	19
1419	7	19
1420	7	19
299	7	18
300	7	18
301	7	18
302	7	18
303	7	18
304	7	18
25	11	3
190	11	3
191	11	3
192	11	3
382	11	3
383	11	3
384	11	3
385	11	3
564	11	3
565	11	3
566	11	3
567	11	3
568	11	3
569	11	3
570	11	3
571	11	3
572	11	3
573	11	3
574	11	3
575	11	3
521	7	20
522	7	20
523	7	20
524	7	20
525	7	20
526	7	20
527	7	20
528	7	20
529	7	20
530	7	20
531	7	20
1464	7	20
1465	7	20
1470	7	20
1471	7	20
1472	7	20
1473	7	20
1474	7	20
1252	7	21
1297	7	21
1421	7	22
1422	7	22
1423	7	22
1424	7	22
1451	7	22
1530	7	17
3	8	1
4	8	1
5	8	1
15	8	1
16	8	1
24	8	1
56	8	1
60	8	1
61	8	1
62	8	1
63	8	1
64	8	1
65	8	1
78	8	1
79	8	1
83	8	1
84	8	1
85	8	1
86	8	1
87	8	1
91	8	1
117	8	1
118	8	1
119	8	1
120	8	1
121	8	1
152	8	1
210	8	1
211	8	1
212	8	1
213	8	1
214	8	1
215	8	1
216	8	1
217	8	1
218	8	1
219	8	1
220	8	1
221	8	1
222	8	1
223	8	1
224	8	1
225	8	1
227	8	1
228	8	1
229	8	1
230	8	1
231	8	1
305	8	1
308	8	1
443	8	1
444	8	1
445	8	1
446	8	1
447	8	1
448	8	1
449	8	1
450	8	1
452	8	1
454	8	1
455	8	1
456	8	1
457	8	1
458	8	1
459	8	1
460	8	1
461	8	1
462	8	1
463	8	1
464	8	1
465	8	1
466	8	1
467	8	1
468	8	1
805	8	1
811	8	1
1476	8	1
8	8	2
9	8	2
10	8	2
11	8	2
12	8	2
13	8	2
14	8	2
17	8	2
18	8	2
19	8	2
20	8	2
21	8	2
22	8	2
23	8	2
33	8	2
48	8	2
51	8	2
52	8	2
67	8	2
112	8	2
113	8	2
114	8	2
243	8	2
244	8	2
246	8	2
247	8	2
387	8	2
388	8	2
389	8	2
390	8	2
391	8	2
392	8	2
393	8	2
394	8	2
395	8	2
396	8	2
399	8	2
400	8	2
401	8	2
402	8	2
403	8	2
404	8	2
405	8	2
406	8	2
412	8	2
413	8	2
416	8	2
417	8	2
418	8	2
419	8	2
420	8	2
421	8	2
422	8	2
424	8	2
425	8	2
426	8	2
428	8	2
429	8	2
430	8	2
431	8	2
432	8	2
433	8	2
434	8	2
435	8	2
436	8	2
437	8	2
438	8	2
439	8	2
440	8	2
442	8	2
614	8	2
824	8	2
825	8	2
826	8	2
827	8	2
828	8	2
829	8	2
830	8	2
831	8	2
832	8	2
833	8	2
834	8	2
835	8	2
836	8	2
1389	8	2
1390	8	2
1392	8	2
25	8	3
190	8	3
191	8	3
192	8	3
382	8	3
383	8	3
384	8	3
385	8	3
564	8	3
565	8	3
566	8	3
567	8	3
568	8	3
569	8	3
570	8	3
571	8	3
572	8	3
1477	8	3
1478	8	3
1479	8	3
29	8	5
30	8	5
31	8	5
32	8	5
245	8	5
248	8	5
249	8	5
250	8	5
34	8	4
35	8	4
40	8	4
41	8	4
42	8	4
54	8	4
132	8	4
135	8	4
139	8	4
207	8	4
753	8	4
754	8	4
1256	8	4
53	8	8
130	8	8
131	8	8
185	8	8
186	8	8
187	8	8
188	8	8
1463	8	8
1	8	6
2	8	6
6	8	6
7	8	6
26	8	6
57	8	6
90	8	6
138	8	6
184	8	6
77	8	9
80	8	9
81	8	9
82	8	9
89	8	9
115	8	9
116	8	9
153	8	9
154	8	9
155	8	9
197	8	9
238	8	9
239	8	9
252	8	9
253	8	9
254	8	9
255	8	9
256	8	9
257	8	9
258	8	9
259	8	9
260	8	9
261	8	9
262	8	9
263	8	9
264	8	9
265	8	9
266	8	9
267	8	9
268	8	9
269	8	9
270	8	9
271	8	9
272	8	9
273	8	9
274	8	9
275	8	9
276	8	9
277	8	9
278	8	9
279	8	9
280	8	9
281	8	9
282	8	9
283	8	9
284	8	9
285	8	9
286	8	9
287	8	9
288	8	9
289	8	9
290	8	9
291	8	9
292	8	9
293	8	9
294	8	9
295	8	9
296	8	9
297	8	9
298	8	9
407	8	9
408	8	9
409	8	9
410	8	9
411	8	9
500	8	9
501	8	9
502	8	9
503	8	9
504	8	9
505	8	9
506	8	9
507	8	9
508	8	9
509	8	9
510	8	9
511	8	9
512	8	9
513	8	9
514	8	9
515	8	9
516	8	9
517	8	9
518	8	9
519	8	9
520	8	9
807	8	9
808	8	9
809	8	9
810	8	9
814	8	9
815	8	9
816	8	9
817	8	9
818	8	9
819	8	9
820	8	9
821	8	9
822	8	9
823	8	9
1209	8	9
1243	8	9
1244	8	9
1245	8	9
1246	8	9
1247	8	9
1248	8	9
1249	8	9
1250	8	9
1253	8	9
1255	8	9
1257	8	9
1258	8	9
1259	8	9
1260	8	9
1261	8	9
1262	8	9
1263	8	9
1264	8	9
1265	8	9
1266	8	9
1267	8	9
1268	8	9
1269	8	9
1270	8	9
1271	8	9
1272	8	9
1273	8	9
1274	8	9
1275	8	9
1276	8	9
1277	8	9
1278	8	9
1279	8	9
1280	8	9
1281	8	9
1282	8	9
1283	8	9
1284	8	9
1285	8	9
1286	8	9
1287	8	9
1288	8	9
1289	8	9
1290	8	9
1292	8	9
1293	8	9
1294	8	9
1295	8	9
1296	8	9
1298	8	9
1299	8	9
1485	8	9
1486	8	9
1487	8	9
1488	8	9
1489	8	9
1490	8	9
1491	8	9
1492	8	9
1493	8	9
1494	8	9
1495	8	9
1498	8	9
1499	8	9
1500	8	9
1501	8	9
1502	8	9
1503	8	9
1504	8	9
1519	8	9
1520	8	9
351	8	10
347	8	10
803	8	10
346	8	10
370	8	10
361	8	10
321	8	10
146	8	10
350	8	10
333	8	10
325	8	10
378	8	10
341	8	10
314	8	10
804	8	10
322	8	10
364	8	10
107	8	10
134	8	10
334	8	10
144	8	10
170	8	10
169	8	10
330	8	10
168	8	10
163	8	10
345	8	10
92	8	10
93	8	10
373	8	10
352	8	10
363	8	10
343	8	10
379	8	10
362	8	10
323	8	10
348	8	10
337	8	10
327	8	10
320	8	10
375	8	10
340	8	10
356	8	10
133	8	10
317	8	10
342	8	10
111	8	10
368	8	10
372	8	10
369	8	10
339	8	10
329	8	10
326	8	10
360	8	10
344	8	10
371	8	10
367	8	10
189	8	10
601	8	10
374	8	10
335	8	10
365	8	10
376	8	10
355	8	10
328	8	10
157	8	10
336	8	10
318	8	10
338	8	10
358	8	10
381	8	10
313	8	10
802	8	10
359	8	10
354	8	10
140	8	10
349	8	10
377	8	10
602	8	10
172	8	10
94	8	10
316	8	10
324	8	10
357	8	10
332	8	10
319	8	10
331	8	10
106	8	10
380	8	10
353	8	10
171	8	10
315	8	10
366	8	10
145	8	10
148	8	10
165	8	10
143	8	10
612	8	10
97	8	11
177	8	11
178	8	11
108	8	12
109	8	12
110	8	12
200	8	12
201	8	12
202	8	12
203	8	12
1480	8	12
1481	8	12
1482	8	12
173	8	13
174	8	13
175	8	13
176	8	13
311	8	13
312	8	13
179	8	14
193	8	14
194	8	14
195	8	14
196	8	14
208	8	14
209	8	14
469	8	14
470	8	14
471	8	14
472	8	14
473	8	14
474	8	14
475	8	14
476	8	14
477	8	14
478	8	14
479	8	14
481	8	14
482	8	14
483	8	14
484	8	14
485	8	14
486	8	14
487	8	14
488	8	14
489	8	14
490	8	14
491	8	14
492	8	14
493	8	14
494	8	14
495	8	14
496	8	14
497	8	14
498	8	14
813	8	14
1210	8	14
1211	8	14
1212	8	14
1213	8	14
1214	8	14
1215	8	14
1216	8	14
1217	8	14
1218	8	14
1219	8	14
1220	8	14
1221	8	14
1222	8	14
1223	8	14
1224	8	14
1225	8	14
1226	8	14
1227	8	14
1228	8	14
1229	8	14
1230	8	14
1231	8	14
1232	8	14
1233	8	14
1234	8	14
1235	8	14
1236	8	14
1237	8	14
1238	8	14
1239	8	14
1240	8	14
1241	8	14
1242	8	14
1251	8	14
1397	8	14
1398	8	14
1400	8	14
1401	8	14
1402	8	14
1403	8	14
1404	8	14
1405	8	14
180	8	15
182	8	15
183	8	16
1254	8	16
199	8	17
1530	8	17
1531	8	17
1535	8	17
1536	8	17
1537	8	17
1538	8	17
235	8	18
299	8	18
300	8	18
301	8	18
302	8	18
304	8	18
306	8	18
806	8	18
812	8	18
241	8	19
242	8	19
386	8	19
414	8	19
532	8	19
561	8	19
562	8	19
563	8	19
837	8	19
1406	8	19
1407	8	19
1408	8	19
1409	8	19
1410	8	19
1412	8	19
1413	8	19
1416	8	19
1417	8	19
1418	8	19
1419	8	19
1420	8	19
307	8	7
310	8	7
576	11	3
1477	11	3
1478	11	3
1479	11	3
55	11	1
56	11	1
58	11	1
59	11	1
60	11	1
65	11	1
78	11	1
79	11	1
216	11	1
218	11	1
222	11	1
225	11	1
452	11	1
97	11	11
177	11	11
178	11	11
351	11	10
347	11	10
346	11	10
370	11	10
361	11	10
321	11	10
607	11	10
350	11	10
333	11	10
325	11	10
378	11	10
341	11	10
314	11	10
27	11	4
28	11	4
37	11	4
40	11	4
41	11	4
42	11	4
54	11	4
521	8	20
522	8	20
523	8	20
524	8	20
525	8	20
526	8	20
527	8	20
528	8	20
529	8	20
530	8	20
531	8	20
1464	8	20
1465	8	20
1470	8	20
1471	8	20
1472	8	20
1473	8	20
1474	8	20
1297	8	21
1421	8	22
1422	8	22
1423	8	22
1424	8	22
20	9	2
21	9	2
22	9	2
23	9	2
33	9	2
387	9	2
388	9	2
389	9	2
390	9	2
391	9	2
392	9	2
393	9	2
394	9	2
395	9	2
396	9	2
399	9	2
401	9	2
402	9	2
403	9	2
404	9	2
405	9	2
406	9	2
417	9	2
418	9	2
428	9	2
429	9	2
430	9	2
431	9	2
440	9	2
442	9	2
824	9	2
825	9	2
826	9	2
827	9	2
836	9	2
1388	9	2
1389	9	2
1390	9	2
1391	9	2
1392	9	2
1393	9	2
1394	9	2
25	9	3
190	9	3
191	9	3
192	9	3
382	9	3
383	9	3
1477	9	3
1478	9	3
1479	9	3
30	9	5
31	9	5
34	9	4
35	9	4
37	9	4
41	9	4
135	9	4
139	9	4
207	9	4
77	9	9
238	9	9
239	9	9
252	9	9
288	9	9
289	9	9
292	9	9
293	9	9
294	9	9
295	9	9
407	9	9
408	9	9
409	9	9
500	9	9
503	9	9
506	9	9
507	9	9
510	9	9
511	9	9
512	9	9
514	9	9
515	9	9
516	9	9
517	9	9
518	9	9
519	9	9
520	9	9
1250	9	9
1485	9	9
1486	9	9
1487	9	9
1488	9	9
1489	9	9
1490	9	9
1491	9	9
1492	9	9
1493	9	9
1494	9	9
1495	9	9
1496	9	9
1497	9	9
1498	9	9
1499	9	9
1500	9	9
1501	9	9
1502	9	9
1503	9	9
1504	9	9
1505	9	9
1506	9	9
1507	9	9
1508	9	9
1509	9	9
1510	9	9
1511	9	9
1512	9	9
1513	9	9
1514	9	9
1515	9	9
1516	9	9
1517	9	9
1518	9	9
1519	9	9
1520	9	9
1521	9	9
1522	9	9
1523	9	9
1524	9	9
1525	9	9
1526	9	9
1527	9	9
1528	9	9
1529	9	9
107	9	10
133	9	10
134	9	10
140	9	10
148	9	10
157	9	10
163	9	10
165	9	10
168	9	10
169	9	10
171	9	10
172	9	10
189	9	10
313	9	10
314	9	10
315	9	10
316	9	10
317	9	10
318	9	10
320	9	10
321	9	10
322	9	10
323	9	10
324	9	10
325	9	10
326	9	10
327	9	10
328	9	10
329	9	10
330	9	10
331	9	10
332	9	10
333	9	10
334	9	10
335	9	10
336	9	10
337	9	10
340	9	10
341	9	10
342	9	10
343	9	10
344	9	10
345	9	10
346	9	10
347	9	10
348	9	10
349	9	10
350	9	10
351	9	10
352	9	10
353	9	10
354	9	10
355	9	10
356	9	10
357	9	10
358	9	10
359	9	10
360	9	10
361	9	10
362	9	10
363	9	10
365	9	10
366	9	10
367	9	10
370	9	10
371	9	10
372	9	10
373	9	10
374	9	10
375	9	10
380	9	10
602	9	10
612	9	10
804	9	10
1371	9	10
1372	9	10
1373	9	10
1374	9	10
1375	9	10
1376	9	10
1377	9	10
1378	9	10
1379	9	10
1380	9	10
1381	9	10
1382	9	10
1383	9	10
1384	9	10
1385	9	10
1386	9	10
1387	9	10
108	9	12
109	9	12
110	9	12
200	9	12
202	9	12
1480	9	12
1481	9	12
1482	9	12
1483	9	12
179	9	14
193	9	14
194	9	14
195	9	14
209	9	14
469	9	14
470	9	14
471	9	14
472	9	14
473	9	14
478	9	14
479	9	14
481	9	14
482	9	14
483	9	14
484	9	14
486	9	14
487	9	14
488	9	14
489	9	14
490	9	14
492	9	14
495	9	14
496	9	14
497	9	14
1210	9	14
1211	9	14
1212	9	14
1213	9	14
1214	9	14
1216	9	14
1223	9	14
1225	9	14
1229	9	14
1232	9	14
1233	9	14
1237	9	14
1238	9	14
1239	9	14
1251	9	14
1395	9	14
1396	9	14
1397	9	14
1398	9	14
1399	9	14
1400	9	14
1401	9	14
1402	9	14
1403	9	14
1404	9	14
1405	9	14
182	9	15
1356	9	15
1357	9	15
1358	9	15
1359	9	15
1360	9	15
1361	9	15
1362	9	15
1363	9	15
1364	9	15
1365	9	15
1366	9	15
1367	9	15
1368	9	15
1369	9	15
1370	9	15
183	9	16
187	9	8
188	9	8
1458	9	8
1459	9	8
1460	9	8
1461	9	8
1462	9	8
1463	9	8
241	9	19
386	9	19
414	9	19
562	9	19
1406	9	19
1407	9	19
1408	9	19
1409	9	19
1410	9	19
1411	9	19
1412	9	19
1413	9	19
1414	9	19
1415	9	19
1416	9	19
1417	9	19
1418	9	19
1419	9	19
1420	9	19
135	11	4
204	11	4
205	11	4
206	11	4
753	11	4
754	11	4
757	11	4
758	11	4
1256	11	4
57	11	6
184	11	6
108	11	12
29	11	5
30	11	5
31	11	5
32	11	5
245	11	5
248	11	5
249	11	5
250	11	5
77	11	9
80	11	9
81	11	9
82	11	9
115	11	9
116	11	9
197	11	9
240	11	9
252	11	9
253	11	9
254	11	9
255	11	9
256	11	9
257	11	9
258	11	9
259	11	9
260	11	9
261	11	9
262	11	9
263	11	9
521	9	20
522	9	20
523	9	20
524	9	20
525	9	20
526	9	20
528	9	20
529	9	20
530	9	20
531	9	20
1464	9	20
1465	9	20
1466	9	20
1470	9	20
1471	9	20
1472	9	20
1473	9	20
1474	9	20
1421	9	22
1422	9	22
1423	9	22
1424	9	22
1425	9	25
1426	9	25
1427	9	25
1428	9	25
1429	9	25
1430	9	25
1431	9	25
1432	9	25
1433	9	25
1434	9	25
1435	9	25
1436	9	25
1437	9	25
1438	9	25
1439	9	25
1440	9	25
1441	9	25
1442	9	25
1443	9	25
1444	9	25
1445	9	25
1446	9	25
1447	9	25
1448	9	25
1449	9	25
1450	9	25
1452	9	25
1453	9	25
1454	9	25
1455	9	25
1456	9	25
1457	9	25
1475	9	1
1476	9	1
1530	9	17
1531	9	17
1532	9	17
1533	9	17
1534	9	17
1535	9	17
1536	9	17
1537	9	17
1538	9	17
1539	9	17
1540	9	17
1541	9	17
1542	9	17
1543	9	17
1544	9	17
1545	9	17
1546	9	17
1547	9	26
1548	9	26
1549	9	26
1550	9	26
1551	9	26
1552	9	26
1553	9	26
1554	9	26
1555	9	26
1556	9	26
1557	9	26
1558	9	26
1559	9	26
1560	9	26
1561	9	26
1562	9	26
1564	9	26
1565	9	26
1566	9	26
1567	9	26
1568	9	26
1569	9	26
1570	9	26
1571	9	26
1572	9	26
1573	9	26
1574	9	26
1575	9	26
1576	9	26
1577	9	26
1578	9	26
1579	9	26
1580	9	26
1581	9	26
1582	9	26
1583	9	26
1584	9	26
1585	9	26
1586	9	26
1587	9	26
1588	9	26
1589	9	26
1590	9	26
1591	9	26
1592	9	26
1593	9	26
1594	9	26
1595	9	26
1596	9	26
1597	9	27
1598	9	27
1599	9	27
1600	9	27
1601	9	27
1602	9	27
1603	9	27
1604	9	27
3	10	1
4	10	1
5	10	1
24	10	1
59	10	1
60	10	1
63	10	1
83	10	1
84	10	1
85	10	1
86	10	1
87	10	1
117	10	1
118	10	1
119	10	1
120	10	1
121	10	1
152	10	1
210	10	1
211	10	1
212	10	1
213	10	1
214	10	1
215	10	1
220	10	1
221	10	1
222	10	1
223	10	1
224	10	1
225	10	1
226	10	1
229	10	1
230	10	1
231	10	1
305	10	1
308	10	1
443	10	1
444	10	1
445	10	1
446	10	1
447	10	1
450	10	1
456	10	1
457	10	1
458	10	1
459	10	1
460	10	1
462	10	1
464	10	1
465	10	1
466	10	1
467	10	1
468	10	1
811	10	1
11	10	2
12	10	2
19	10	2
20	10	2
21	10	2
22	10	2
23	10	2
67	10	2
243	10	2
244	10	2
246	10	2
247	10	2
251	10	2
395	10	2
396	10	2
399	10	2
400	10	2
401	10	2
402	10	2
403	10	2
404	10	2
405	10	2
406	10	2
412	10	2
413	10	2
416	10	2
418	10	2
419	10	2
420	10	2
425	10	2
426	10	2
428	10	2
429	10	2
430	10	2
431	10	2
435	10	2
436	10	2
437	10	2
438	10	2
439	10	2
824	10	2
825	10	2
826	10	2
827	10	2
831	10	2
832	10	2
833	10	2
834	10	2
835	10	2
836	10	2
25	10	3
190	10	3
191	10	3
192	10	3
382	10	3
383	10	3
384	10	3
385	10	3
564	10	3
565	10	3
566	10	3
567	10	3
568	10	3
569	10	3
570	10	3
571	10	3
572	10	3
1477	10	3
1478	10	3
1479	10	3
27	10	4
28	10	4
34	10	4
35	10	4
37	10	4
40	10	4
41	10	4
42	10	4
54	10	4
132	10	4
135	10	4
139	10	4
207	10	4
753	10	4
754	10	4
1256	10	4
29	10	5
30	10	5
31	10	5
32	10	5
245	10	5
248	10	5
249	10	5
250	10	5
43	10	6
44	10	6
90	10	6
138	10	6
184	10	6
50	10	7
129	10	7
233	10	7
234	10	7
236	10	7
53	10	8
130	10	8
131	10	8
185	10	8
186	10	8
187	10	8
89	10	9
197	10	9
238	10	9
239	10	9
240	10	9
252	10	9
258	10	9
259	10	9
270	10	9
275	10	9
276	10	9
277	10	9
409	10	9
410	10	9
411	10	9
514	10	9
516	10	9
517	10	9
518	10	9
1245	10	9
1259	10	9
1269	10	9
1285	10	9
134	10	10
143	10	10
146	10	10
148	10	10
168	10	10
172	10	10
320	10	10
325	10	10
329	10	10
330	10	10
331	10	10
332	10	10
333	10	10
334	10	10
362	10	10
375	10	10
378	10	10
4	10	18
235	10	18
299	10	18
300	10	18
301	10	18
302	10	18
303	10	18
304	10	18
306	10	18
108	10	12
109	10	12
110	10	12
200	10	12
201	10	12
202	10	12
203	10	12
1480	10	12
1481	10	12
1482	10	12
173	10	13
174	10	13
175	10	13
176	10	13
178	10	13
311	10	13
312	10	13
179	10	14
193	10	14
194	10	14
195	10	14
196	10	14
208	10	14
209	10	14
469	10	14
470	10	14
471	10	14
472	10	14
473	10	14
474	10	14
475	10	14
476	10	14
477	10	14
478	10	14
479	10	14
481	10	14
482	10	14
483	10	14
484	10	14
486	10	14
487	10	14
488	10	14
489	10	14
490	10	14
491	10	14
492	10	14
493	10	14
494	10	14
495	10	14
496	10	14
497	10	14
498	10	14
813	10	14
1210	10	14
1211	10	14
1212	10	14
1213	10	14
1214	10	14
1215	10	14
1216	10	14
1217	10	14
1218	10	14
1219	10	14
1220	10	14
1221	10	14
1222	10	14
1223	10	14
1224	10	14
1225	10	14
1226	10	14
1227	10	14
1228	10	14
1229	10	14
1230	10	14
1231	10	14
1232	10	14
1233	10	14
1234	10	14
1235	10	14
1236	10	14
1237	10	14
1238	10	14
1239	10	14
1240	10	14
1241	10	14
1242	10	14
1251	10	14
1397	10	14
1398	10	14
1400	10	14
1401	10	14
1402	10	14
1403	10	14
1404	10	14
1405	10	14
180	10	15
182	10	15
199	10	17
237	10	17
1530	10	17
1531	10	17
1535	10	17
1536	10	17
1537	10	17
1538	10	17
241	10	19
242	10	19
386	10	19
414	10	19
562	10	19
521	10	20
522	10	20
523	10	20
524	10	20
525	10	20
526	10	20
527	10	20
528	10	20
529	10	20
530	10	20
531	10	20
10	11	2
11	11	2
12	11	2
13	11	2
14	11	2
17	11	2
18	11	2
19	11	2
20	11	2
21	11	2
22	11	2
23	11	2
33	11	2
48	11	2
51	11	2
52	11	2
67	11	2
68	11	2
69	11	2
70	11	2
71	11	2
72	11	2
73	11	2
74	11	2
75	11	2
76	11	2
112	11	2
113	11	2
114	11	2
243	11	2
244	11	2
246	11	2
247	11	2
387	11	2
388	11	2
389	11	2
390	11	2
391	11	2
392	11	2
393	11	2
394	11	2
395	11	2
396	11	2
397	11	2
398	11	2
399	11	2
400	11	2
401	11	2
402	11	2
403	11	2
404	11	2
405	11	2
406	11	2
412	11	2
413	11	2
416	11	2
417	11	2
418	11	2
419	11	2
420	11	2
421	11	2
422	11	2
423	11	2
424	11	2
425	11	2
426	11	2
427	11	2
428	11	2
429	11	2
430	11	2
431	11	2
432	11	2
433	11	2
434	11	2
435	11	2
436	11	2
437	11	2
438	11	2
439	11	2
440	11	2
442	11	2
613	11	2
614	11	2
615	11	2
616	11	2
617	11	2
824	11	2
825	11	2
826	11	2
827	11	2
828	11	2
829	11	2
830	11	2
831	11	2
832	11	2
833	11	2
834	11	2
835	11	2
836	11	2
1389	11	2
1390	11	2
1392	11	2
53	11	8
185	11	8
186	11	8
187	11	8
188	11	8
1463	11	8
264	11	9
265	11	9
266	11	9
267	11	9
268	11	9
269	11	9
270	11	9
271	11	9
272	11	9
273	11	9
274	11	9
275	11	9
276	11	9
277	11	9
278	11	9
279	11	9
280	11	9
281	11	9
282	11	9
283	11	9
284	11	9
285	11	9
286	11	9
287	11	9
288	11	9
290	11	9
291	11	9
292	11	9
293	11	9
294	11	9
295	11	9
296	11	9
297	11	9
298	11	9
407	11	9
408	11	9
409	11	9
410	11	9
411	11	9
1209	11	9
1243	11	9
1244	11	9
1245	11	9
1246	11	9
1247	11	9
1248	11	9
1249	11	9
1250	11	9
1253	11	9
1255	11	9
1257	11	9
1258	11	9
1259	11	9
1260	11	9
1261	11	9
1262	11	9
1263	11	9
1264	11	9
1265	11	9
1266	11	9
1267	11	9
1268	11	9
1269	11	9
1270	11	9
1271	11	9
1272	11	9
1273	11	9
1274	11	9
1275	11	9
1276	11	9
1277	11	9
1278	11	9
1279	11	9
1280	11	9
1281	11	9
1282	11	9
1283	11	9
1284	11	9
1285	11	9
1286	11	9
1287	11	9
1288	11	9
1289	11	9
1290	11	9
1292	11	9
1293	11	9
1294	11	9
1295	11	9
1296	11	9
1298	11	9
1299	11	9
1486	11	9
1487	11	9
1488	11	9
1489	11	9
1490	11	9
1491	11	9
1492	11	9
1493	11	9
1494	11	9
1495	11	9
1501	11	9
1519	11	9
1520	11	9
109	11	12
110	11	12
200	11	12
201	11	12
202	11	12
203	11	12
1480	11	12
1481	11	12
1482	11	12
322	11	10
582	11	10
364	11	10
134	11	10
334	11	10
330	11	10
605	11	10
598	11	10
345	11	10
373	11	10
352	11	10
363	11	10
343	11	10
596	11	10
379	11	10
362	11	10
323	11	10
348	11	10
337	11	10
327	11	10
320	11	10
375	11	10
581	11	10
340	11	10
594	11	10
356	11	10
589	11	10
609	11	10
608	11	10
317	11	10
583	11	10
342	11	10
111	11	10
368	11	10
372	11	10
369	11	10
339	11	10
600	11	10
577	11	10
329	11	10
326	11	10
360	11	10
344	11	10
595	11	10
371	11	10
367	11	10
189	11	10
601	11	10
374	11	10
590	11	10
588	11	10
335	11	10
365	11	10
376	11	10
355	11	10
603	11	10
591	11	10
328	11	10
586	11	10
336	11	10
318	11	10
606	11	10
338	11	10
587	11	10
358	11	10
381	11	10
313	11	10
578	11	10
359	11	10
610	11	10
597	11	10
354	11	10
593	11	10
349	11	10
592	11	10
377	11	10
579	11	10
602	11	10
611	11	10
316	11	10
324	11	10
580	11	10
357	11	10
332	11	10
319	11	10
331	11	10
599	11	10
584	11	10
380	11	10
353	11	10
315	11	10
366	11	10
612	11	10
604	11	10
585	11	10
173	11	13
174	11	13
175	11	13
176	11	13
311	11	13
312	11	13
180	11	15
182	11	15
183	11	16
1254	11	16
193	11	14
195	11	14
196	11	14
209	11	14
469	11	14
470	11	14
471	11	14
472	11	14
473	11	14
474	11	14
475	11	14
476	11	14
477	11	14
478	11	14
479	11	14
481	11	14
482	11	14
483	11	14
484	11	14
486	11	14
487	11	14
488	11	14
489	11	14
490	11	14
491	11	14
495	11	14
496	11	14
497	11	14
498	11	14
1210	11	14
1211	11	14
1212	11	14
1213	11	14
1214	11	14
1215	11	14
1216	11	14
1217	11	14
1218	11	14
1219	11	14
1220	11	14
1221	11	14
1222	11	14
1223	11	14
1224	11	14
1225	11	14
1226	11	14
1227	11	14
1228	11	14
1229	11	14
1230	11	14
1231	11	14
1232	11	14
1233	11	14
1234	11	14
1235	11	14
1236	11	14
1237	11	14
1238	11	14
1239	11	14
1240	11	14
1241	11	14
1242	11	14
1251	11	14
1397	11	14
1398	11	14
1402	11	14
1404	11	14
1405	11	14
241	11	19
242	11	19
386	11	19
414	11	19
536	11	19
537	11	19
538	11	19
539	11	19
540	11	19
541	11	19
542	11	19
543	11	19
544	11	19
545	11	19
546	11	19
547	11	19
548	11	19
549	11	19
550	11	19
551	11	19
552	11	19
553	11	19
554	11	19
555	11	19
556	11	19
557	11	19
558	11	19
559	11	19
560	11	19
561	11	19
562	11	19
563	11	19
837	11	19
1406	11	19
1407	11	19
1408	11	19
1409	11	19
1410	11	19
1412	11	19
1413	11	19
1416	11	19
1417	11	19
1418	11	19
1419	11	19
1420	11	19
299	11	18
300	11	18
1252	11	21
1297	11	21
1424	11	22
1451	11	22
1464	11	20
1465	11	20
1470	11	20
1471	11	20
1472	11	20
1473	11	20
1474	11	20
1530	11	17
27	12	4
28	12	4
41	12	4
135	12	4
204	12	4
206	12	4
753	12	4
754	12	4
757	12	4
758	12	4
52	12	2
112	12	2
113	12	2
114	12	2
613	12	2
614	12	2
615	12	2
616	12	2
617	12	2
109	12	12
110	12	12
1480	12	12
1481	12	12
1482	12	12
180	12	15
182	12	15
183	12	16
193	12	14
209	12	14
488	12	14
489	12	14
1397	12	14
1398	12	14
1402	12	14
283	12	9
284	12	9
285	12	9
286	12	9
287	12	9
288	12	9
290	12	9
291	12	9
292	12	9
293	12	9
294	12	9
295	12	9
296	12	9
297	12	9
561	12	19
562	12	19
563	12	19
564	12	3
565	12	3
566	12	3
567	12	3
568	12	3
569	12	3
570	12	3
571	12	3
572	12	3
573	12	3
574	12	3
575	12	3
576	12	3
577	12	10
578	12	10
579	12	10
580	12	10
581	12	10
582	12	10
583	12	10
584	12	10
585	12	10
586	12	10
587	12	10
588	12	10
589	12	10
590	12	10
591	12	10
592	12	10
593	12	10
594	12	10
595	12	10
596	12	10
597	12	10
598	12	10
599	12	10
600	12	10
601	12	10
602	12	10
603	12	10
604	12	10
605	12	10
606	12	10
607	12	10
608	12	10
609	12	10
610	12	10
611	12	10
612	12	10
1423	12	22
1424	12	22
1451	12	22
27	13	4
28	13	4
41	13	4
135	13	4
204	13	4
206	13	4
753	13	4
754	13	4
757	13	4
758	13	4
299	13	18
300	13	18
301	13	18
302	13	18
303	13	18
304	13	18
306	13	18
1104	13	18
1106	13	18
1107	13	18
1108	13	18
1109	13	18
1110	13	18
1111	13	18
1112	13	18
1113	13	18
1123	13	18
1125	13	18
1126	13	18
1127	13	18
1128	13	18
1129	13	18
1130	13	18
1131	13	18
1132	13	18
1133	13	18
1134	13	18
1135	13	18
1136	13	18
1137	13	18
1138	13	18
1139	13	18
1140	13	18
1141	13	18
1142	13	18
1143	13	18
1144	13	18
1145	13	18
1146	13	18
307	13	7
309	13	7
310	13	7
1114	13	7
1152	13	7
1153	13	7
1154	13	7
1155	13	7
1156	13	7
1157	13	7
1158	13	7
1159	13	7
1160	13	7
1161	13	7
1162	13	7
1163	13	7
1164	13	7
1165	13	7
1166	13	7
1167	13	7
1168	13	7
1169	13	7
1170	13	7
1171	13	7
1172	13	7
1173	13	7
1174	13	7
1175	13	7
1176	13	7
1177	13	7
1178	13	7
1179	13	7
1180	13	7
1181	13	7
1182	13	7
1183	13	7
1184	13	7
1185	13	7
1186	13	7
1187	13	7
1188	13	7
1189	13	7
1190	13	7
1191	13	7
1192	13	7
1193	13	7
1194	13	7
1195	13	7
1196	13	7
1197	13	7
1198	13	7
1199	13	7
1200	13	7
1201	13	7
1202	13	7
1203	13	7
1204	13	7
1205	13	7
1206	13	7
1207	13	7
1208	13	7
1051	13	4
1052	13	4
1053	13	4
1054	13	4
1055	13	4
1056	13	4
1057	13	4
1058	13	4
1059	13	4
1060	13	4
1061	13	4
1062	13	4
1063	13	4
1064	13	4
1065	13	4
1066	13	4
1067	13	4
1068	13	4
1069	13	4
1070	13	4
1071	13	4
1072	13	4
1073	13	4
1074	13	4
1075	13	4
1076	13	4
1077	13	4
1078	13	4
1079	13	4
1080	13	4
1081	13	4
1082	13	4
1083	13	4
1084	13	4
1085	13	4
1086	13	4
1087	13	4
1088	13	4
1089	13	4
1090	13	4
1091	13	4
1092	13	4
1093	13	4
1094	13	4
1095	13	4
1096	13	4
1097	13	4
1098	13	4
1099	13	4
1100	13	4
1101	13	4
1102	13	4
1103	13	4
1124	13	4
1147	13	28
1148	13	28
1149	13	28
1150	13	28
1151	13	28
180	13	15
182	13	15
193	13	14
209	13	14
488	13	14
489	13	14
1397	13	14
1398	13	14
1402	13	14
283	13	9
284	13	9
285	13	9
286	13	9
287	13	9
288	13	9
290	13	9
291	13	9
292	13	9
293	13	9
294	13	9
295	13	9
296	13	9
297	13	9
561	13	19
562	13	19
563	13	19
10	14	2
11	14	2
12	14	2
13	14	2
14	14	2
17	14	2
18	14	2
33	14	2
27	14	4
28	14	4
41	14	4
135	14	4
204	14	4
206	14	4
753	14	4
754	14	4
757	14	4
758	14	4
29	14	5
30	14	5
31	14	5
32	14	5
180	14	15
182	14	15
183	14	16
193	14	14
209	14	14
488	14	14
489	14	14
1397	14	14
1398	14	14
1402	14	14
283	14	9
284	14	9
285	14	9
286	14	9
287	14	9
288	14	9
290	14	9
291	14	9
292	14	9
293	14	9
294	14	9
295	14	9
296	14	9
297	14	9
18	15	2
19	15	2
20	15	2
27	15	4
28	15	4
41	15	4
135	15	4
204	15	4
206	15	4
753	15	4
754	15	4
757	15	4
758	15	4
180	15	15
182	15	15
193	15	14
209	15	14
488	15	14
489	15	14
1397	15	14
1398	15	14
1402	15	14
283	15	9
284	15	9
285	15	9
286	15	9
287	15	9
288	15	9
290	15	9
291	15	9
292	15	9
293	15	9
294	15	9
295	15	9
296	15	9
297	15	9
27	16	4
28	16	4
41	16	4
135	16	4
204	16	4
206	16	4
753	16	4
754	16	4
180	16	15
182	16	15
193	16	14
209	16	14
488	16	14
489	16	14
283	16	9
284	16	9
285	16	9
286	16	9
287	16	9
288	16	9
290	16	9
291	16	9
292	16	9
293	16	9
294	16	9
295	16	9
296	16	9
297	16	9
60	17	1
305	17	1
308	17	1
180	17	15
182	17	15
185	17	8
193	17	14
195	17	14
488	17	14
489	17	14
491	17	14
492	17	14
493	17	14
495	17	14
496	17	14
497	17	14
498	17	14
1397	17	14
1398	17	14
66	17	17
199	17	17
618	17	17
619	17	17
620	17	17
621	17	17
622	17	17
623	17	17
624	17	17
625	17	17
626	17	17
628	17	17
629	17	17
630	17	17
631	17	17
632	17	17
633	17	17
634	17	17
635	17	17
636	17	17
637	17	17
638	17	17
639	17	17
640	17	17
641	17	17
642	17	17
643	17	17
644	17	17
645	17	17
646	17	17
647	17	17
648	17	17
649	17	17
650	17	17
651	17	17
652	17	17
653	17	17
654	17	17
655	17	17
656	17	17
657	17	17
658	17	17
659	17	17
660	17	17
661	17	17
662	17	17
663	17	17
664	17	17
665	17	17
666	17	17
667	17	17
668	17	17
669	17	17
670	17	17
671	17	17
672	17	17
673	17	17
674	17	17
675	17	17
676	17	17
677	17	17
678	17	17
679	17	17
680	17	17
681	17	17
682	17	17
683	17	17
684	17	17
685	17	17
686	17	17
687	17	17
688	17	17
689	17	17
690	17	17
691	17	17
692	17	17
693	17	17
694	17	17
695	17	17
696	17	17
697	17	17
698	17	17
699	17	17
700	17	17
701	17	17
702	17	17
703	17	17
704	17	17
705	17	17
706	17	17
707	17	17
708	17	17
709	17	17
710	17	17
711	17	17
712	17	17
713	17	17
714	17	17
715	17	17
716	17	17
717	17	17
718	17	17
719	17	17
720	17	17
721	17	17
722	17	17
723	17	17
724	17	17
725	17	17
726	17	17
727	17	17
728	17	17
729	17	17
730	17	17
731	17	17
732	17	17
733	17	17
734	17	17
735	17	17
736	17	17
737	17	17
738	17	17
739	17	17
740	17	17
741	17	17
742	17	17
743	17	17
744	17	17
745	17	17
746	17	17
747	17	17
748	17	17
749	17	17
750	17	17
751	17	17
752	17	17
838	17	17
839	17	17
840	17	17
841	17	17
842	17	17
843	17	17
844	17	17
845	17	17
846	17	17
847	17	17
848	17	17
849	17	17
850	17	17
851	17	17
852	17	17
853	17	17
854	17	17
855	17	17
856	17	17
857	17	17
858	17	17
859	17	17
860	17	17
861	17	17
862	17	17
863	17	17
864	17	17
865	17	17
866	17	17
897	17	17
898	17	17
899	17	17
900	17	17
901	17	17
902	17	17
903	17	17
904	17	17
905	17	17
906	17	17
907	17	17
908	17	17
909	17	17
910	17	17
911	17	17
912	17	17
913	17	17
914	17	17
915	17	17
916	17	17
917	17	17
918	17	17
919	17	17
920	17	17
921	17	17
922	17	17
923	17	17
924	17	17
925	17	17
926	17	17
927	17	17
928	17	17
929	17	17
930	17	17
931	17	17
932	17	17
933	17	17
934	17	17
935	17	17
936	17	17
937	17	17
938	17	17
939	17	17
940	17	17
941	17	17
942	17	17
943	17	17
944	17	17
945	17	17
946	17	17
947	17	17
948	17	17
949	17	17
950	17	17
951	17	17
952	17	17
953	17	17
954	17	17
955	17	17
991	17	17
992	17	17
993	17	17
994	17	17
995	17	17
996	17	17
997	17	17
998	17	17
999	17	17
1000	17	17
1001	17	17
1002	17	17
1003	17	17
1004	17	17
1005	17	17
1006	17	17
1007	17	17
1008	17	17
1009	17	17
1010	17	17
1011	17	17
1012	17	17
1014	17	17
1015	17	17
1016	17	17
1017	17	17
1018	17	17
1019	17	17
1020	17	17
1021	17	17
1022	17	17
1023	17	17
1024	17	17
1025	17	17
1026	17	17
1027	17	17
1028	17	17
1029	17	17
1030	17	17
1031	17	17
1032	17	17
1033	17	17
1034	17	17
1035	17	17
1036	17	17
1037	17	17
1038	17	17
1039	17	17
1040	17	17
1041	17	17
1042	17	17
1043	17	17
1044	17	17
1045	17	17
1046	17	17
1047	17	17
1048	17	17
1049	17	17
1050	17	17
1105	17	17
1115	17	17
1116	17	17
1117	17	17
1118	17	17
1119	17	17
1120	17	17
1121	17	17
1122	17	17
238	17	9
239	17	9
240	17	9
283	17	9
284	17	9
285	17	9
286	17	9
287	17	9
288	17	9
289	17	9
290	17	9
291	17	9
293	17	9
294	17	9
295	17	9
296	17	9
297	17	9
298	17	9
299	17	18
300	17	18
301	17	18
302	17	18
303	17	18
304	17	18
306	17	18
1104	17	18
1106	17	18
1107	17	18
1108	17	18
1109	17	18
1110	17	18
1111	17	18
1112	17	18
1113	17	18
1123	17	18
1125	17	18
1126	17	18
1127	17	18
1128	17	18
1129	17	18
1130	17	18
1131	17	18
1132	17	18
1133	17	18
1134	17	18
1135	17	18
1136	17	18
1137	17	18
1138	17	18
1139	17	18
1140	17	18
1141	17	18
1142	17	18
1143	17	18
1144	17	18
1145	17	18
1146	17	18
307	17	7
309	17	7
310	17	7
1114	17	7
1152	17	7
1153	17	7
1154	17	7
1155	17	7
1156	17	7
1157	17	7
1158	17	7
1159	17	7
1160	17	7
1161	17	7
1162	17	7
1163	17	7
1164	17	7
1165	17	7
1166	17	7
1167	17	7
1168	17	7
1169	17	7
1170	17	7
1171	17	7
1172	17	7
1173	17	7
1174	17	7
1175	17	7
1176	17	7
1177	17	7
1178	17	7
1179	17	7
1180	17	7
1181	17	7
1182	17	7
1183	17	7
1184	17	7
1185	17	7
1186	17	7
1187	17	7
1188	17	7
1189	17	7
1190	17	7
1191	17	7
1192	17	7
1193	17	7
1194	17	7
1195	17	7
1196	17	7
1197	17	7
1198	17	7
1199	17	7
1200	17	7
1201	17	7
1202	17	7
1203	17	7
1204	17	7
1205	17	7
1206	17	7
1207	17	7
1208	17	7
867	17	30
868	17	30
869	17	30
870	17	30
871	17	30
872	17	30
873	17	30
874	17	30
875	17	30
876	17	30
877	17	30
878	17	30
879	17	30
880	17	30
881	17	30
882	17	30
883	17	30
884	17	30
885	17	30
886	17	30
887	17	30
888	17	30
889	17	30
890	17	30
891	17	30
892	17	30
893	17	30
894	17	30
895	17	30
896	17	30
956	17	31
957	17	31
958	17	31
959	17	31
960	17	31
961	17	31
962	17	31
963	17	31
964	17	31
965	17	31
966	17	31
967	17	31
968	17	31
969	17	31
970	17	31
971	17	31
972	17	31
973	17	31
974	17	31
975	17	31
976	17	31
977	17	31
978	17	31
979	17	31
980	17	31
981	17	31
982	17	31
983	17	31
984	17	31
985	17	31
986	17	31
987	17	31
988	17	31
989	17	31
990	17	31
1051	17	4
1052	17	4
1053	17	4
1054	17	4
1055	17	4
1056	17	4
1057	17	4
1058	17	4
1059	17	4
1060	17	4
1061	17	4
1062	17	4
1063	17	4
1064	17	4
1065	17	4
1066	17	4
1067	17	4
1068	17	4
1069	17	4
1070	17	4
1071	17	4
1072	17	4
1073	17	4
1074	17	4
1075	17	4
1076	17	4
1077	17	4
1078	17	4
1079	17	4
1080	17	4
1081	17	4
1082	17	4
1083	17	4
1084	17	4
1085	17	4
1086	17	4
1087	17	4
1088	17	4
1089	17	4
1090	17	4
1091	17	4
1092	17	4
1093	17	4
1094	17	4
1095	17	4
1096	17	4
1097	17	4
1098	17	4
1099	17	4
1100	17	4
1101	17	4
1102	17	4
1103	17	4
1124	17	4
1147	17	28
1148	17	28
1149	17	28
1150	17	28
1151	17	28
1300	17	32
1301	17	32
1302	17	32
1303	17	32
1304	17	32
1305	17	32
1306	17	32
1307	17	32
1308	17	32
1309	17	32
1310	17	32
1311	17	32
1312	17	32
1313	17	32
1314	17	32
1315	17	32
1316	17	32
1317	17	32
1318	17	32
1319	17	32
1320	17	32
1321	17	32
1322	17	32
1323	17	32
1324	17	32
1325	17	32
1326	17	32
1327	17	32
1328	17	32
1329	17	32
1330	17	32
1331	17	32
1332	17	32
1333	17	32
1334	17	32
1335	17	32
1336	17	32
1337	17	32
1338	17	32
1339	17	32
1340	17	32
1341	17	32
1342	17	32
1343	17	32
1344	17	32
1345	17	32
1346	17	32
1347	17	32
1348	17	32
1349	17	32
1350	17	32
1351	17	32
1352	17	32
1353	17	32
1354	17	32
1355	17	32
8	18	2
9	18	2
10	18	2
11	18	2
12	18	2
13	18	2
14	18	2
17	18	2
18	18	2
19	18	2
20	18	2
21	18	2
22	18	2
23	18	2
33	18	2
243	18	2
244	18	2
246	18	2
247	18	2
387	18	2
388	18	2
389	18	2
390	18	2
391	18	2
392	18	2
393	18	2
394	18	2
398	18	2
613	18	2
614	18	2
615	18	2
616	18	2
617	18	2
25	18	3
190	18	3
191	18	3
192	18	3
382	18	3
383	18	3
384	18	3
385	18	3
564	18	3
565	18	3
566	18	3
567	18	3
568	18	3
569	18	3
570	18	3
571	18	3
572	18	3
573	18	3
574	18	3
575	18	3
576	18	3
6	18	9
7	18	9
41	18	9
57	18	9
77	18	9
115	18	9
252	18	9
253	18	9
254	18	9
255	18	9
256	18	9
259	18	9
283	18	9
284	18	9
285	18	9
286	18	9
287	18	9
288	18	9
290	18	9
291	18	9
295	18	9
93	18	10
94	18	10
106	18	10
107	18	10
133	18	10
186	18	10
187	18	10
188	18	10
189	18	10
313	18	10
314	18	10
315	18	10
316	18	10
317	18	10
318	18	10
319	18	10
320	18	10
321	18	10
322	18	10
323	18	10
324	18	10
325	18	10
326	18	10
327	18	10
328	18	10
329	18	10
330	18	10
331	18	10
332	18	10
333	18	10
334	18	10
335	18	10
336	18	10
337	18	10
338	18	10
339	18	10
340	18	10
341	18	10
342	18	10
343	18	10
344	18	10
345	18	10
346	18	10
347	18	10
348	18	10
349	18	10
350	18	10
351	18	10
352	18	10
353	18	10
354	18	10
355	18	10
356	18	10
357	18	10
358	18	10
359	18	10
360	18	10
361	18	10
362	18	10
363	18	10
364	18	10
365	18	10
366	18	10
367	18	10
368	18	10
369	18	10
370	18	10
371	18	10
372	18	10
373	18	10
374	18	10
375	18	10
376	18	10
377	18	10
378	18	10
379	18	10
380	18	10
381	18	10
577	18	10
578	18	10
579	18	10
580	18	10
581	18	10
582	18	10
583	18	10
584	18	10
585	18	10
586	18	10
587	18	10
588	18	10
589	18	10
590	18	10
591	18	10
592	18	10
593	18	10
594	18	10
595	18	10
596	18	10
597	18	10
598	18	10
599	18	10
600	18	10
604	18	10
605	18	10
606	18	10
607	18	10
608	18	10
609	18	10
610	18	10
611	18	10
612	18	10
193	18	14
488	18	14
489	18	14
491	18	14
492	18	14
493	18	14
495	18	14
496	18	14
497	18	14
498	18	14
1397	18	14
1398	18	14
241	18	19
242	18	19
386	18	19
537	18	19
538	18	19
539	18	19
540	18	19
541	18	19
542	18	19
543	18	19
544	18	19
545	18	19
546	18	19
547	18	19
548	18	19
549	18	19
550	18	19
558	18	19
837	18	19
521	18	20
522	18	20
523	18	20
524	18	20
525	18	20
526	18	20
527	18	20
528	18	20
529	18	20
530	18	20
\.


--
-- Data for Name: rosaviatest_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rosaviatest_answers (question_id, answer_text, is_correct, is_official, "position", id) FROM stdin;
9	ВПП 24	f	f	1	4971
9	ВПП 14	t	f	2	4972
9	ВПП 10	f	f	3	4973
10	019°, 12 узлов	f	f	1	4974
10	246°, 13 узлов	t	f	2	4975
10	200°, 13 узлов	f	f	3	4976
11	9	f	f	1	4977
11	11	f	f	2	4978
11	8	t	f	3	4979
12	60	t	f	1	4980
12	50	f	f	2	4981
12	56	f	f	3	4982
13	10 м/с	f	f	1	4983
13	13 м/с	f	f	2	4984
13	12 м/с	f	t	3	4985
14	в равномерном горизонтальном полёте	t	f	1	4986
14	при постоянном равномерном снижении	f	f	2	4987
14	при минимальной приборной скорости	f	f	3	4988
15	1200 фунтов	f	f	1	4989
15	3100 фунтов	f	f	2	4990
15	3960 фунтов	t	f	3	4991
16	6750 фунтов	t	f	1	4992
16	7200 фунтов	f	f	2	4993
16	4500 фунтов	f	f	3	4994
17	1013 ГпА	f	f	1	4995
17	981 гПа	f	f	2	4996
17	1011 гПа	t	f	3	4997
18	3556 фут MSL	f	f	1	4998
18	3639 фут MSL	f	f	2	4999
18	3527 фут MSL	t	f	3	5000
19	Высота над стандартной плоскостью отсчета	f	f	1	5001
19	Расстояние по вертикали от воздушного судна до поверхности	f	f	2	5002
19	Высота над средним уровнем моря	t	f	3	5003
20	Непосредственно считываемое с высотомера значение	f	f	1	5004
20	Расстояние по вертикали от воздушного судна до поверхности	t	f	2	5005
20	Высота над стандартной плоскостью отсчета	f	f	3	5006
21	На уровне моря при стандартной атмосфере	t	f	1	5007
21	При исправном высотомере - всегда	f	f	2	5008
21	На высоте перехода при QNH=1013.2 hPa	f	f	3	5009
22	При стандартном давлении	f	t	1	5010
22	При стандартных атмосферных условиях	f	f	2	5011
22	Когда приборная высота равна высоте по давлению	f	f	3	5012
23	При температуре ниже стандартной	t	f	1	5013
23	При температуре выше стандартной	f	f	2	5014
23	Когда высота по плотности выше приборной высоты	f	f	3	5015
24	Для каждого действия есть равное противодействие	f	f	1	5016
24	Дополнительная направленная вверх сила создаётся если нижняя поверхность крыла отражает набегающий поток воздуха вниз	f	f	2	5017
24	Воздух движущийся с большей скоростью вдоль изогнутой верхней поверхности крыла создаёт над крылом область пониженного давления	t	f	3	5018
25	Ливневой дождь	t	f	1	5019
25	Ожидается изменение направления ветра	f	f	2	5020
25	Ожидается значительное изменение характера осадков	f	f	3	5021
26	1.2 VS0	f	f	1	5022
26	1.7 VS0	f	t	2	5023
26	половина скорости сваливания	f	f	3	5024
27	с ростом высоты	t	f	1	5025
27	с понижением высоты	f	f	2	5026
27	с увеличением атмосферного давления	f	f	3	5027
28	потере мышечной силы	t	f	1	5028
28	улучшению самочуствия	f	f	2	5029
28	давлению в висках	f	f	3	5030
29	Медленное сканирование небольших секторов для использования периферического зрения	f	f	1	5031
29	Регулярно концентрироваться на 3-,9-,12- часовых позициях	f	f	2	5032
29	Последовательность коротких, равномерно распределённых движений глаз для поиска в каждом 10-градусом секторе	t	f	3	5033
30	Смотреть только на дальние, тусклые огни	f	f	1	5034
30	Медленное сканирование для использования периферического зрения	t	f	2	5035
30	Концентрироваться непосредственно на каждом объекте по нескольку секунд	f	f	3	5036
31	Смотреть в сторону от объектов и выполнять быстрое сканирование поля зрения	f	f	1	5037
31	Очень быстрое сканирование поля зрения	f	f	2	5038
31	Концентрироваться непосредственно на каждом объекте по нескольку секунд	f	t	3	5039
32	Регулярно концентрироваться на 3-,9-,12- часовых позициях	f	f	1	5040
32	Медленное сканирование небольших секторов для использования периферического зрения	f	t	2	5041
32	Последовательность коротких, равномерно распределённых движений глаз для поиска в каждом 30-градусом секторе	f	f	3	5042
33	Меридианы параллельны экватору	f	f	1	5043
33	Меридианы пересекают экватор под прямыми углами	t	f	2	5044
179	на СВС. На лёгкое ВС - нет	f	f	2	5413
179	на СВС, и на лёгкое ВС	f	f	3	5414
180	немедленно эвакуировать всех пассажиров и пострадавших членов экипажа из ВС в безопасное место и оказать помощь пострадавшим пассажирам и членам экипажа	t	f	1	5415
180	сообщить об авиационном происшествии в Службу экстренного вызова «112»	f	f	2	5416
180	подготовить аварийные радиостанции и передать сообщение о бедствии, при наличии аварийных радиобуев системы Коспас-Сарсат - включить их в работу	f	f	3	5417
182	уложить пострадавшего на жесткую поверхность, восстановить проходимость дыхательных путей, начать искусственное дыхание «рот в рот» или «рот в нос» и одновременно наружный массаж сердца	t	f	1	5418
182	немедленно вызвать скорую помощь и полицию, попытаться привести пострадавшего в чувство пощечинами и тряской	f	f	2	5419
182	немедленно попытаться найти среди прохожих медицинского работника и попросить его оказать помощь пострадавшему	f	f	3	5420
183	406,0 МГц	t	f	1	5421
183	121,5 МГц	f	f	2	5422
183	243,0 МГц	f	f	3	5423
184	возрастают	t	f	1	5424
184	уменьшаются	f	f	2	5425
184	скорость отрыва возрастает, длина разбега не меняется	f	f	3	5426
185	запрещается	f	t	1	5427
185	разрешается, исходя из условий экономической целесообразности (высоких коммерческих рисков)	f	f	2	5428
185	не допускается в полёт продолжительностью более 20 минут	f	f	3	5429
186	низкая облачность, интенсивные осадки, ограниченная видимость (туман, дымка), обледенение, турбулентность, гроза, порывистый ветер	f	t	1	5430
186	перистые облака, ливневые осадки, конденсационный след, гололёд, радуга, встречный ветер	f	f	2	5431
186	спутный след, гало, штормовое предупреждение, «наковальня» грозового облака, струйное течение	f	f	3	5432
187	грозы и шквалы, туманы, обледенение, метели, пыльные бури	f	t	1	5433
187	температура воздуха, атмосферное давление, влажность воздуха, барометрическая высота	f	f	2	5434
187	барическое поле, изменение ветра с высотой, слой трения, горизонтальный градиент давления, фронтальная поверхность	f	f	3	5435
188	перистые, являющиеся передней наиболее тонкой и высоко расположенной частью фронтальной системы облаков тёплого фронта	f	t	1	5436
188	разорванно-дождевые облака, образующиеся под фронтальными облаками вследствие испарения выпадающих осадков	f	f	2	5437
188	слоисто-дождевые, из которых выпадают интенсивные обложные осадки	f	f	3	5438
189	стадия развития барической системы, время года и суток, положение маршрута полёта относительно центра (оси) барического образования, характер рельефа местности и др	f	t	1	5439
189	метод прогноза погоды, профиль полёта, активность Солнца, эксплуатационные ограничения ВС	f	f	2	5440
189	классификация воздушных масс, эволюция барической системы, фаза Луны, взлётно-посадочные характеристики ВС	f	f	3	5441
190	горизонтальная видимость у поверхности земли 10 км и более. Нет облаков ниже 1500 м (5000 футов и отсутствуют кучево-дождевые облака. + Нет осадков, грозы, пыльной или песчаной бури, приземного тумана, пыльного, песчаного или снежного позёмка	t	f	1	5442
190	ожидаются временные изменения метеоусловий с частотой менее часа, а в сумме менее половины периода прогноза «тренда»	f	f	2	5443
190	вулканический пепел	f	f	3	5444
191	прогнозируемое количество облаков в слое или облачной массе - «Отдельные облака, 1-4 октанта»	t	f	1	5445
191	явления, ухудшаемые видимость - «Туман»	f	f	2	5446
191	интенсивность или близость - «Вблизи»	f	f	3	5447
192	Cb	t	f	1	5448
192	Ci	f	f	2	5449
192	As	f	f	3	5450
193	Воздушный кодекс, федеральные законы, указы Президента Российской Федерации, постановления Правительства Российской Федерации, федеральные правила использования воздушного пространства, федеральные авиационные правила, а также принимаемые в соответствии с ними иных нормативные правовые акты Российской Федерации	t	f	1	5451
231	трудности в восстановлении нормального полёта на скорости сваливания	f	t	2	5554
1	ЦТ переместится назад на 0,25 метра	f	f	1	4947
1	ЦТ переместится назад на 0,45 метра	f	t	2	4948
1	ЦТ переместится назад на 0,75 метра	f	f	3	4949
2	Разбег станет длиннее	f	f	1	4950
2	Сваливание на скорости выше нормальной	f	f	2	4951
2	Трудности с выводом из режима сваливания	f	t	3	4952
3	1840 фут	f	f	1	4953
3	2750 фут	f	f	2	4954
3	2100 фут	t	f	3	4955
4	18	t	f	1	4956
4	28	f	f	2	4957
4	39	f	f	3	4958
5	24	f	f	1	4959
5	28	t	f	2	4960
5	30	f	f	3	4961
6	35 узлов	f	t	1	4962
6	29 узлов	f	f	2	4963
6	25 узлов	f	f	3	4964
7	16 узлов	f	f	1	4965
7	20 узлов	f	f	2	4966
7	24 узла	f	t	3	4967
8	32	t	f	1	4968
8	6	f	f	2	4969
8	29	f	f	3	4970
33	Нулевая линия широт проходит через Гринвич, Англия	f	f	3	5045
34	Исполнить задуманное быстрее и перейти к следующему шагу	f	f	1	5046
34	«Не торопись! Подумай»	t	f	2	5047
34	«Это может случиться со мной»	f	f	3	5048
35	«Это со мной не случится»	f	f	1	5049
35	завершение полёта точно как он запланирован, удовлетворение пассажиров, выполнение расписания, и демонстрация «правильных вещей»	t	f	2	5050
35	«Это не может быть настолько плохо»	f	f	3	5051
37	неадекватной подготовки к полёту	f	t	1	5052
37	импульсивности	f	f	2	5053
37	стресса	f	f	3	5054
40	верить показаниям приборов	f	t	1	5055
40	сознательно снизить частоту вдохов пока симптомы не прекратятся, затем восстановить нормальную частоту дыхания	f	f	2	5056
40	сконцентрироваться на ощущениях тангажа, крена и рыскания	f	f	3	5057
41	отказ авиатехники	f	f	1	5058
41	разрушение конструкции	f	f	2	5059
41	человеческая ошибка	t	f	3	5060
42	продолжение полёта в приборных метеорологических условиях	f	t	1	5061
42	синдром «Отставания принятия решений и действий от развития ситуации»	f	f	2	5062
42	синдром «Снижения на опасные высоты для установления визуального контакта с ориентирами»	f	f	3	5063
43	левый элерон вверх, руль высоты вниз	f	f	1	5064
43	левый элерон вниз, руль высоты нейтрально	f	f	2	5065
43	левый элерон вверх, руль высоты нейтрально	t	f	3	5066
44	нейтральное	f	f	1	5067
44	элерон поднят вверх со стороны ветра	f	f	2	5068
44	элерон опущен вниз со стороны ветра	t	f	3	5069
48	все части воздушного судна пересекли линию ожидания	t	f	1	5070
48	кабина воздушного судна пересекла линию ожидания	f	f	2	5071
48	хвост воздушного судна пересек край ВПП	f	f	3	5072
49	немного уменьшить тангаж для увеличения воздушной скорости	f	t	1	5073
49	обеднить смесь	f	f	2	5074
49	включить обогрев карбюратора	f	f	3	5075
50	когда топливовоздушная смесь воспламеняется мгновенно, вместо того, чтобы сгорать последовательно и равномерно	f	t	1	5076
50	переобогащенная смесь вызывает взрывную добавку к мощности	f	f	2	5077
50	смесь воспламеняется слишком рано на горячих угольных отложениях в цилиндре	f	f	3	5078
51	пересекает ваш курс слева направо	f	f	1	5079
51	движется от вас	t	f	2	5080
51	пересекает ваш курс справа налево	f	f	3	5081
52	Другое воздушное судно движется от вас	f	f	1	5082
52	Другое воздушное судно движется прямо на вас	t	f	2	5083
52	Другое воздушное судно пересекает ваш курс справа налево	f	f	3	5084
53	Молния	f	f	1	5085
53	Сдвиг ветра и турбулентность	f	t	2	5086
53	Статическое электричество	f	f	3	5087
54	Дисциплинированного и компетентного пилота	f	t	1	5088
54	Пилота обладающего неполными знаниями	f	f	2	5089
54	Пилота с малым налётом	f	f	3	5090
55	Vy	t	f	1	5091
55	Va	f	f	2	5092
55	Vx	f	f	3	5093
56	над поверхностью земли	t	f	1	5094
56	относительно воздуха	f	f	2	5095
56	в развороте	f	f	3	5096
57	Никакого	f	f	1	5097
57	Ухудшает лётные характеристики	t	f	2	5098
57	Улучшает лётные характеристики	f	f	3	5099
58	Избытка мощности	t	f	1	5100
58	аэродинамического качества	f	f	2	5101
58	мощности двигателя для крейсерского режима	f	f	3	5102
59	Низкая температура, низкая относительная влажность и низкая высота по давлению	f	f	1	5103
59	Высокая температура, низкая относительная влажность и низкая высота по давлению	f	f	2	5104
59	Высокая температура, высокая относительная влажность и большая высота по давлению	t	f	3	5105
60	Иней изменяет аэродинамическую форму поверхностей, следовательно уменьшает подъёмную силу	f	f	1	5106
60	Иней снижает скорость потока вдоль аэродинамических поверхностей, приводя к изменению управляемости	f	f	2	5107
60	Иней разрушает плавный поток воздуха вдоль поверхности крыла, снижая подъёмную силу и повышая сопротивление	f	t	3	5108
230	увеличится	f	t	1	5550
61	На высоте равной двойному размаху крыльев над поверхностью	f	f	1	5109
61	на высоте менее чем размах крыльев над поверхностью	f	t	2	5110
61	при больше чем обычном угле атаки	f	f	3	5111
62	Вихри на законцовках крыла усиливают генерируемый спутный след, что создаёт проблемы для взлетающих и приземляющихся воздушных судов	f	f	1	5112
62	Посадка при полностью срывном обтекании потребует меньшего отклонения руля высоты, чем если бы экранный эффект земли отсутствовал	f	f	2	5113
62	Индуктивное сопротивление уменьшается, вследствие чего избыточная скорость в точке выравнивания может привести к существенному перелёту намеченной точки приземления	t	f	3	5114
63	Внезапная посадка на землю при приземлении	f	f	1	5115
63	Отрыв от земли до достижения рекомендуемой скорости отрыва	t	f	2	5116
63	Невозможность отрыва от земли хотя скорость достаточна для потребностей взлёта	f	f	3	5117
64	Увеличивается угол скоса потока каждой лопасти несущего винта	f	f	1	5118
64	Вектор подъёмной силы становится более горизонтальным	f	t	2	5119
64	Увеличивается угол атаки, генерирующий подъёмную силу	f	f	3	5120
65	неблагоприятного ветра	t	f	1	5121
65	препятствия рядом с ВПП	f	f	2	5122
65	параметры двигательной установки	f	f	3	5123
66	подверженными обледенению только при наличии видимой влаги	f	f	1	5124
66	одинаково подверженными обледенению	f	f	2	5125
66	более подверженными обледенению	f	t	3	5126
67	Посадка разрешена	t	f	1	5127
67	Уступите путь другим воздушным судам и продолжайте полет по кругу	f	f	2	5128
67	Вернитесь для посадки	f	f	3	5129
68	008° и 026° истинный	f	f	1	5130
68	080° и 260° истинный	f	f	2	5131
68	080° и 260° магнитный	t	f	3	5132
69	Обозначают места, куда воздушное судно не имеет права двигаться без диспетчерского разрешения от диспетчера руления	f	f	1	5133
69	Обозначают места, где воздушное судно должно остановиться при отсутствии диспетчерского разрешения от диспетчера руления	t	f	2	5134
69	Являются разрешением для воздушного судна следовать на ВПП	f	f	3	5135
70	что воздушное судно находится на РД «B»	f	f	1	5136
70	что воздушное судно приближается к РД «B»	t	f	2	5137
70	указывает местонахождение зоны ожидания «B»	f	f	3	5138
71	ВПП 22	t	f	1	5139
71	на маршруте на ВПП 22	f	f	2	5140
71	РД 22	f	f	3	5141
72	на ВПП 22	f	f	1	5142
72	перед въездом на ВПП с пересечения двух ВПП	f	f	2	5143
72	перед покиданием РД и входом на ВПП для взлёта с места пересечения	t	f	3	5144
73	можете следовать далее этой точки на свой собственный риск	f	f	1	5145
73	должны ожидать у этой точки до получения диспетчерского разрешения следовать далее	t	f	2	5146
73	имеете право пересекать линию, если не поступило запрета от органа ОВД	f	f	3	5147
74	маркировки, содержащей обязательные для исполнения инструкции	t	f	1	5148
74	уведомление о направлении ВПП	f	f	2	5149
74	направляющий знак	f	f	3	5150
75	выдерживать высоту так, чтобы оказаться на глиссаде не ближе 2 миль от торца ВПП	f	f	1	5151
75	выдерживать высоту на или выше глиссады	f	t	2	5152
75	оставаться на глиссаде и коснуться ВПП между двумя световыми полосами	f	f	3	5153
76	четыре белых сигнала	f	f	1	5154
76	два белых и два красных сигнала	f	f	2	5155
76	три белых и один красный сигнал	f	t	3	5156
77	Класс G	f	f	1	5157
77	Класс A	t	f	2	5158
77	Класс C	f	f	3	5159
78	при температуре ниже стандартной	f	f	1	5160
78	при атмосферном давлении ниже стандартного	f	f	2	5161
78	при температуре выше стандартной	t	f	3	5162
79	повышенная температура «раздвигает» уровни давления и приборная высота оказывается выше, чем абсолютная	f	f	1	5163
79	пониженная температура понижает уровни давления и приборная высота оказывается меньше, чем абсолютная	f	f	2	5164
79	уровни давления поднимаются в тёплые дни, и приборная высота оказывается ниже, чем абсолютная	t	f	3	5165
80	текущее значение QNH, если имеется, либо на превышение аэродрома	t	f	1	5166
80	скорректированное значение высоты по давлению	f	f	2	5167
80	скорректированное значение высоты по плотности	f	f	3	5168
81	фактическую высоту	f	f	1	5169
81	ниже, чем фактическую высоту	t	f	2	5170
81	выше, чем фактическую высоту	f	f	3	5171
82	фактическую высоту	f	f	1	5172
82	ниже, чем фактическую высоту	f	f	2	5173
82	выше, чем фактическую высоту	t	f	3	5174
83	увеличивается при перемещении центра масс вперед	f	f	1	5175
83	изменяется при увеличении загрузки воздушного судна	f	f	2	5176
83	остаётся неизменным при увеличении загрузки воздушного судна	t	f	3	5177
84	между линией, образованной хордой крыла и вектором скорости потока	t	f	1	5178
84	образованный между продольной осью самолёта и углом, с которым поток воздуха направлен на аэродинамическую поверхность крыла	f	f	2	5179
84	образованный между продольной осью самолёта и направлением набегающего потока воздуха	f	f	3	5180
85	угол тангажа	f	f	1	5181
85	вектором скорости потока	t	f	2	5182
85	плоскостью вращения несущего винта	f	f	3	5183
86	подъёмной силы	f	f	1	5184
86	атаки	t	f	2	5185
86	установки	f	f	3	5186
87	между хордой крыла и вектором скорости потока	t	f	1	5187
87	между углом набора высоты и горизонтом	f	f	2	5188
87	образованный между продольной осью самолёта и хордой крыла	f	f	3	5189
89	не должен предприниматься, кроме случаев, когда это абсолютно необходимо	f	f	1	5190
89	более предпочтителен по сравнению с попытками исправить ситуацию в последний момент	t	f	2	5191
89	не должен предприниматься после начала выравнивания независимо от скорости	f	f	3	5192
90	Нейтральное	f	f	1	5193
90	Элерон поднят вверх со стороны ветра	t	f	2	5194
90	Элерон опущен вниз со стороны ветра	f	f	3	5195
91	направление полёта вдоль ВПП	f	f	1	5196
91	продольную ось самолёта параллельно направлению полёта	t	f	2	5197
91	создание крена на подветренную сторону, чтобы предотвратить смещение самолёта	f	f	3	5198
92	Фактическая интенсивность падения температуры	t	f	1	5199
92	Атмосферное давление	f	f	2	5200
92	Температура поверхности	f	f	3	5201
93	Охлаждение нижних слоёв	f	f	1	5202
93	Уменьшение испарения воды	f	f	2	5203
93	Разогрев нижних слоёв	t	f	3	5204
94	Слоистые облака	t	f	1	5205
94	Неограниченная видимость	f	f	2	5206
94	Кучевые облака	f	f	3	5207
97	Положение воздушного судна по отношению к продольной оси	f	f	1	5208
97	движение воздушного судна относительно вертикальной оси	t	f	2	5209
97	угол крена не превышающий 30°	f	f	3	5210
98	большему количеству воздуха проходящему через карбюратор	f	f	1	5211
98	обогатит смесь топлива с воздухом	f	t	2	5212
98	не повлияет на смесь топлива с воздухом	f	f	3	5213
99	Не влияет	f	f	1	5214
99	Снижает мощность	f	t	2	5215
99	Увеличивает мощность	f	f	3	5216
100	уменьшением оборотов и затем постепенным повышением оборотов	f	t	1	5217
100	увеличением оборотов и затем постепенным уменьшением оборотов	f	f	2	5218
100	уменьшением оборотов и затем показанием неизменных оборотов	f	f	3	5219
101	равна -18°C при высокой влажности воздуха	f	f	1	5220
101	35°C и имеется видимая влага	f	f	2	5221
101	20°С и высокая влажность воздуха	f	t	3	5222
102	любая температура ниже 0°C и относительной влажности менее 50%	f	f	1	5223
102	температура от 0°C до 10°C и низкая влажность	f	f	2	5224
102	температура от -6°C до 21°C и высокая влажность	f	t	3	5225
103	перебои двигателя	f	f	1	5226
103	падение температуры масла и температуры головок цилиндров	f	f	2	5227
103	потеря оборотов двигателя	f	t	3	5228
105	36°C и при видимой влаге	f	f	1	5229
105	20°C и высокой влажности	t	f	2	5230
105	24°C и низкой влажности	f	f	3	5231
106	облака с существенным вертикальным развитием и связанной с этим турбулентностью	t	f	1	5232
106	слоистые облака с минимальным вертикальным развитием	f	f	2	5233
230	уменьшится	f	f	2	5551
106	слоистые облака со значительной связанной с ними турбулентностью	f	f	3	5234
107	кучево-дождевые облака	t	f	1	5235
107	башенкообразные кучевые облака	f	f	2	5236
107	слоисто-дождевые облака	f	f	3	5237
108	Восток	f	f	1	5238
108	Юг	t	f	2	5239
108	Запад	f	f	3	5240
109	Северо-восток	f	f	1	5241
109	Северо-запад	t	f	2	5242
109	Юго-запад	f	f	3	5243
110	Запад	t	f	1	5244
110	Юг	f	f	2	5245
110	Север	f	f	3	5246
111	зрение имеет тенденцию пропускать объекты в дымке и не обнаруживать относительное движение	f	f	1	5247
111	дымка приводит к тому, что зрение фокусируется на бесконечность	f	f	2	5248
111	другие воздушные суда или объекты на поверхности земли кажутся дальше, чем они есть на самом деле	f	t	3	5249
112	встречное воздушное судно с большой скоростью становится больше и ближе	f	f	1	5250
112	не заметно никакого относительного движения встречного воздушного судна в поле вашего зрения	f	t	2	5251
112	нос каждого воздушного судна направлен в одну и ту же точку в пространстве	f	f	3	5252
113	днём в дымке в окрестностях аэродрома	f	f	1	5253
113	во время ясных дней около навигационных точек маршрутов	t	f	2	5254
113	во время ночных полётов с имитируемых приборных метеорологических условиях	f	f	3	5255
114	днём в дымке	f	f	1	5256
114	во время ясных дней	t	f	2	5257
114	облачными ночами	f	f	3	5258
115	равна барометрической высоте	f	f	1	5259
115	ниже, чем барометрическая высота	f	f	2	5260
115	выше, чем барометрическая высота	t	f	3	5261
116	на повышенной скорости	f	f	1	5262
116	по более крутой глиссаде	f	f	2	5263
116	так же, как и днём	t	f	3	5264
117	вертикальная компонента подъёмной силы	f	f	1	5265
117	центробежная сила	f	f	2	5266
117	горизонтальная компонента подъёмной силы	t	f	3	5267
118	подъемная сила, вес, тяга, сопротивление	t	f	1	5268
118	подъемная сила, гравитация, мощность, трение	f	f	2	5269
118	подъемная сила, вес, гравитация, тяга	f	f	3	5270
119	увеличения воздушной скорости	f	f	1	5271
119	увеличения мощности	f	f	2	5272
119	уменьшения угла атаки	t	f	3	5273
120	частичное сваливание с опущенным одним крылом	f	f	1	5274
120	сваливание	t	f	2	5275
120	в крутую снижающуюся спираль	f	f	3	5276
121	оба крыла	t	f	1	5277
121	только левое	f	f	2	5278
121	никакое	f	f	3	5279
122	уменьшение воздушной скорости	f	f	1	5280
122	увеличение оборотов	f	f	2	5281
122	обогащение смеси	f	t	3	5282
123	смесь станет беднее	f	f	1	5283
123	смесь станет богаче	f	t	2	5284
123	уменьшение оборотов происходит из-за более бедной смеси	f	f	3	5285
124	смесь станет избыточно бедной	f	t	1	5286
124	в цилиндры будет поступать больше топлива, чем требуется для нормального сгорания и избыточное топливо будет лучше охлаждать двигатель	f	f	2	5287
124	избыточно богатая смесь приведет к повышению температуры головок цилиндров, что может привести к детонации	f	f	3	5288
125	уменьшить поток топлива, чтобы скомпенсировать уменьшенную плотность воздуха	f	t	1	5289
125	уменьшить поток топлива чтобы скомпенсировать увеличенную плотность воздуха	f	f	2	5290
125	увеличить количество подаваемого топлива в смеси чтобы скомпенсировать уменьшение давления и плотности воздуха	f	f	3	5291
126	использование топлива с октановым числом менее чем указано производителем	f	t	1	5292
126	эксплуатация двигателя с повышенным давлением масла	f	f	2	5293
126	использование топлива с октановым числом большим, чем указано производителем	f	f	3	5294
127	смешение топлива с воздухом будет неравномерным между цилиндрами	f	f	1	5295
127	температура головок цилиндров понизится	f	f	2	5296
127	детонации	f	t	3	5297
128	предотвращается конденсация влаги заполнением свободного пространства в баках	f	t	1	5298
128	вытеснение избыточной влаги наверх баков подальше от топливопроводов к двигателям	f	f	2	5299
230	останется неизменной	f	f	3	5552
128	исключение расширения топлива методом устранения свободного места в баках	f	f	3	5300
129	выполнить нормальную коробочку на ВПП 08, т.к. гроза еще достаточно далеко, чтобы повлиять на ветер на аэродроме	f	f	1	5301
129	выполнить нормальную коробочку на ВПП 08, т.к. гроза находится на западе, сдвигается к северу и неожиданный ветер будет с востока или юго-востока по направлению к грозе	f	f	2	5302
129	выполнить заход на ВПП 26 т.к. неожиданный ветер из-за грозы будет западным	f	t	3	5303
130	переохлаждённый дождь	f	f	1	5304
130	переохлаждённая морось	f	f	2	5305
130	кучевые облака с температурой ниже точки замерзания	f	t	3	5306
131	видимая влага	f	t	1	5307
131	малая разница между температурой и точкой росы	f	f	2	5308
131	слоистые облака	f	f	3	5309
132	на собственные ощущения и использование внешних ориентиров	f	f	1	5310
132	адекватное питание, отдых, и адаптацию к временной зоне	f	f	2	5311
132	профессиональное использование приборного оборудования	f	t	3	5312
133	Болтанка, ограниченная видимость, туман, низковысотные слоистые облака, ливневые осадки	f	f	1	5313
133	Спокойный воздух, ограниченная видимость, туман, дымка или низкие облака	t	f	2	5314
133	Незначительный сдвиг ветра, ограниченная видимость, дымка, слабый дождь	f	f	3	5315
134	наличия грозы	f	f	1	5316
134	температурная инверсия с ледяным дождём на высоте	t	f	2	5317
134	прохождение холодного фронта	f	f	3	5318
135	потому что оно приводит к замедлению действий	f	f	1	5319
135	потому что его наличие может быть не очевидно до момента когда серьёзная ошибка уже сделана	f	t	2	5320
135	потому что оно зависит от физической натренированности и остроты ума	f	f	3	5321
138	менее устойчивым на малых скоростях, но более устойчивым на высоких скоростях	f	f	1	5322
138	менее устойчивым на высоких скоростях, но более устойчивым на низких скоростях	f	f	2	5323
138	менее устойчивым во всем диапазоне скоростей	f	t	3	5324
139	необычное увеличение объёма вдыхаемого воздуха	f	f	1	5325
139	состояние дефицита кислорода в теле человека	f	t	2	5326
139	состояние образования пузырьков газа в суставах или мышцах	f	f	3	5327
140	0°K и 1013.2 миллибар	f	f	1	5328
140	15°C и 1013.2 миллибар	t	f	2	5329
140	0°C и 760 мм.рт.ст	f	f	3	5330
143	максимальная скорость роста облаков	f	f	1	5331
143	начало осадков	t	f	2	5332
143	появление вершин облаков в виде наковальни	f	f	3	5333
144	10000 ft AGL	t	f	1	5334
144	11000 ft AGL	f	f	2	5335
144	9000 ft AGL	f	f	3	5336
145	молния	f	t	1	5337
145	град	f	f	2	5338
145	проливной дождь	f	f	3	5339
146	кучевого облака	f	f	1	5340
146	зрелого грозового облака	f	t	2	5341
146	распада	f	f	3	5342
148	перистые облака	f	f	1	5343
148	слоисто-дождевые облака и хорошая приземная видимость	f	f	2	5344
148	башенкообразные кучевые облака	t	f	3	5345
149	восходящие потоки воздуха, влажный воздух, существенная облачность	f	f	1	5346
149	высокая влажность, восходящие потоки воздуха, нестабильная воздушная масса	t	f	2	5347
149	высокая влажность, высокая температура, дождевые облака	f	f	3	5348
150	0700, 1700, 7000	f	f	1	5349
150	7500, 7600, 7700	t	f	2	5350
150	1200, 1500, 7000	f	f	3	5351
151	7200	f	f	1	5352
151	4000	f	f	2	5353
151	7500	t	f	3	5354
152	летит с большой скоростью	f	f	1	5355
152	тяжело загружено	f	f	2	5356
152	создаёт подъёмную силу	t	f	3	5357
153	удостоверьтесь, что вы слегка ниже и перпендикулярно курсу реактивного самолёта	f	f	1	5358
153	снизить скорость до Va и сохраняйте высоту и скорость	f	f	2	5359
153	увеличить высоту полета и удостовериться, что вы слегка выше пути реактивного самолёта	t	f	3	5360
154	подниматься к взлётному или посадочному пути пересекающейся ВПП	f	f	1	5361
154	опускаться ниже воздушного судна, производящего спутный след	t	f	2	5362
154	подниматься на уровень коробочки	f	f	3	5363
155	ниже и с наветренной стороны от большого воздушного судна	f	f	1	5364
1454	0.5 h х V	f	f	1	7578
155	ниже и с подветренной стороны от большого воздушного судна	f	f	2	5365
155	выше и с наветренной стороны от большого воздушного судна	t	f	3	5366
156	выше линии пути конечного участка захода на посадку и приземляться дальше точки приземления большого воздушного судна	t	f	1	5367
156	ниже линии пути конечного участка захода на посадку и приземляться перед точкой приземления большого воздушного судна	f	f	2	5368
156	выше линии пути конечного участка захода на посадку и приземляться перед точкой приземления большого воздушного судна	f	f	3	5369
157	теплообмена	f	t	1	5370
157	движением воздуха	f	f	2	5371
157	разницей в давлении	f	f	3	5372
163	кучевообразные облаков без или с минимальной турбулентностью	f	f	1	5373
163	слоистые облака с умеренной турбулентностью	f	f	2	5374
163	слоистые облака без или с минимальной турбулентностью	t	f	3	5375
165	пары воды присутствуют в воздухе	f	f	1	5376
165	пары воды конденсируются	f	t	2	5377
165	относительная влажность достигает 100%	f	f	3	5378
168	температура, при которой конденсация и испарение уравновешены	f	f	1	5379
168	температура при которой всегда образуется роса	f	f	2	5380
168	температура, до которой должен быть охлаждён воздух, чтобы стать насыщенным	t	f	3	5381
169	ледяной дождь	f	f	1	5382
169	гроза	f	f	2	5383
169	туман или низкая облачность	t	f	3	5384
170	5000 ft MSL	f	f	1	5385
170	6000 ft MSL	t	f	2	5386
170	4000 ft MSL	f	f	3	5387
171	в областях низкотемпературной инверсии, фронтальных зонах, и при турбулентности в ясном небе	t	f	1	5388
171	после прохода фронтальных зон, когда возникают слоистокучевые облака, что показывает механическое перемешивание атмосферы	f	f	2	5389
171	когда стабильный воздух пересекает горный барьер, где возникает тенденция потоков в слоях и образование лентикулярных облаков	f	f	3	5390
172	только на малых высотах	f	f	1	5391
172	только на больших высотах	f	f	2	5392
172	на любых высотах	t	f	3	5393
173	1) 0 м; 2) Высота аэродрома над уровнем моря	t	f	1	5394
173	1) Высота аэродрома над уровнем моря; 2) 0 м	f	f	2	5395
173	1) 0 м; 2) Высота относительно изобары 760 мм рт. ст	f	f	3	5396
174	в обоих случаях показания изменяться практически не будут, и сохранятся равными около 1000 м (при снижении незначительно, на несколько метров уменьшатся, а при наборе высоты так же незначительно увеличатся)	t	f	1	5397
174	при наборе высоты уменьшатся до 500 м, при снижении увеличатся до 1500 м	f	f	2	5398
174	в обоих случаях показания будут соответствовать фактической высоте полёта	f	f	3	5399
175	1) Останутся равными 150 км/ч; 2) будут меньше 150 км/ч; 3) будут больше 150 км/ч	t	f	1	5400
175	1) Останутся равными 150 км/ч; 2) будут больше 150 км/ч; 3) будут меньше 150 км/ч	f	f	2	5401
175	Во всех трёх случаях будут соответствовать фактической приборной скорости полёта	f	f	3	5402
176	показания вариометра будут по модулю заниженными	f	t	1	5403
176	показания вариометра будут по модулю завышенными	f	f	2	5404
176	стрелка вариометра установится на делении 0 м	f	f	3	5405
177	да, справедливо. Коррекцию от маятника с целью постоянного приведения вектора кинетического момента гироскопа к гравитационной вертикали необходимо отключать при маневрировании ЛА (разворотах, продольных и боковых ускорениях)	t	f	1	5406
177	да, справедливо. Коррекцию от маятника с целью постоянного приведения вектора кинетического момента гироскопа к гравитационной вертикали необходимо отключать при выполнении полёта на предельно малых высотах с огибанием рельефа	f	f	2	5407
177	нет, несправедливо. Коррекция гироскопа в авиагоризонте осуществляется вручную экипажем, при визуальной видимости линии горизонта, в остальное время отключена	f	f	3	5408
178	нет, компасный курс, отличающийся от магнитного курса на величину девиации	t	f	1	5409
178	да, магнитный курс, отличающийся от истинного на величину магнитного склонения	f	f	2	5410
178	нет, гироскопический курс, отличающийся от истинного на величину азимута гироскопа	f	f	3	5411
179	на лёгкое ВС. На СВС - нет	t	f	1	5412
193	Воздушный кодекс, ФП ИВП, Инструкции по производству полётов, Руководства по лётной эксплуатации	f	f	2	5452
193	Воздушный кодекс, ФАПы, Свидетельства о регистрации ВС, Сертификаты лётной годности ВС, Свидетельства пилотов ВС	f	f	3	5453
194	последние места, 13-е и 14-е	t	f	1	5454
194	высокое, в первой «тройке» мест	f	f	2	5455
194	в средней части списка приоритетов	f	f	3	5456
195	ВС, имеющее государственный и регистрационный или учетный опознавательные знаки, прошедшее необходимую подготовку и имеющее на борту соответствующую документацию	t	f	1	5457
195	исправное ВС, прошедшее необходимую подготовку и имеющее на борту соответствующую документацию	f	f	2	5458
195	исправное ВС, прошедшее необходимую подготовку с экипажем на борту согласно РЛЭ, имеющим необходимые сертификаты	f	f	3	5459
196	использование ВП без разрешения центра ЕС ОрВД при разрешительном порядке ИВП	t	f	1	5460
196	запуск двигателя на контролируемом аэродроме без разрешения РП	f	f	2	5461
196	уход на 2-й круг вследствие допущенной при расчёте на посадку ошибки	f	f	3	5462
197	на установленном рубеже или по указанию органа ОВД	t	f	1	5463
197	на удалении 9-7 км от КТА аэродрома	f	f	2	5464
197	при выполнении 3-го разворота, или на высоте 150 м при заходе с прямой	f	f	3	5465
199	да, ВС, на котором он выполняет полёты	t	f	1	5466
199	да, всех ВС данного класса, на ВС которого он выполняет полёты	f	f	2	5467
199	нет, не может	f	f	3	5468
200	УСТАНОВИТЬ СВЯЗЬ с ...	t	f	1	5469
200	ПРОСЛУШИВАЙТЕ НА ЧАСТОТЕ...	f	f	2	5470
200	ПРОДОЛЖАЙТЕ ПЕРЕДАВАТЬ ВАШЕ СООБЩЕНИЕ (Относится к ВС, находящимся на земле)	f	f	3	5471
201	да, обязан при любых обстоятельствах	t	f	1	5472
201	по усмотрению члена экипажа ВС, ведущего радиообмен с диспетчером	f	f	2	5473
201	Повторение сообщений о рабочем направлении ВПП, установке высотомера и др. при получении диспетчерских указаний запрещено с целью исключения избыточности радиообмена	f	f	3	5474
202	при передаче сообщений о времени используется всемирное координированное время - UTC	t	f	1	5475
202	при передаче сообщений о времени используется московское время - МСК	f	f	2	5476
202	при передаче сообщений о времени используется время часового пояса, над территорией которого выполняется полёт	f	f	3	5477
203	во время взлета, при заходе на посадку с момента визуального обнаружения ВС после пролета БПРМ и до окончания пробега за исключением случаев, когда этого требуют условия обеспечения безопасности полета воздушного судна	t	f	1	5478
203	во время взлета, при заходе на посадку с момента визуального обнаружения ВС после пролета БПРМ и до окончания пробега по ВПП, без каких-либо исключений	f	f	2	5479
203	от запуска двигателя и до уборки взлётно-посадочной механизации ВС на взлёте, и на посадке от выпуска взлётно-посадочной механизации до окончания пробега ВС по ВПП за исключением случаев, когда этого требуют условия обеспечения авиационной безопасности	f	f	3	5480
207	недостатки в организации полётов, недостаточная квалификация, непрофессиональное отношение (халатность, пренебрежение к подготовке, отношение к ВС как к летающей игрушке), несоответствие психофизиологического состояния пилота полётной ситуации	f	t	1	5481
207	отказы СУ и усложнение метеоусловий (ухудшение видимости, обледенение, турбулентность, боковой ветер на посадке)	f	f	2	5482
207	недостатки в организации полётов, отказы спасательного оборудования и отсутствие у владельца ВС необходимых материально-финансовых средств для технического обслуживания и ремонта ВС	f	f	3	5483
208	имеет право проводить предполётный досмотр ВС, его бортовых запасов, членов экипажа, пассажиров, находящихся при них вещей, багажа, груза и почты	t	f	1	5484
208	имеет право проводить предполётный досмотр ВС, его бортовых запасов, членов экипажа, груза и почты	f	f	2	5485
208	не имеет права проводить досмотр без наличия письменного разрешения органов авиатранспортной прокуратуры	f	f	3	5486
209	состояние защищенности авиации от незаконного вмешательства в деятельность в области авиации	t	f	1	5487
231	увеличение длины разбега	f	f	1	5553
1454	h х V	f	t	2	7579
209	комплексная характеристика установленного порядка ИВП, определяющая его способность обеспечить выполнение всех видов деятельности по ИВП без угрозы жизни и здоровью людей, материального ущерба государству, гражданам и юридическим лицам	f	f	2	5488
209	комплексная характеристика деятельности авиации в части возможности её осуществления без угрозы жизни и здоровью людей, материального ущерба государству, гражданам и юридическим лицам	f	f	3	5489
210	способность крыла создавать максимальную подъёмную силу	f	f	1	5490
210	степень аэродинамической чистоты поверхности крыла	f	f	2	5491
210	отношение подъемной силы к силе лобового сопротивления	t	f	3	5492
211	значения максимального качества, построенные для различных углов атаки	f	f	1	5493
211	значения коэффициента подъёмной силы, построенные в полярных координатах	f	f	2	5494
211	зависимости Су и Сх для различных углов атаки	t	f	3	5495
212	угол атаки, при котором аэродинамическое качество крыла максимальное	t	f	1	5496
212	угол атаки, при котором коэффициент сопротивления имеет минимальное значение	f	f	2	5497
212	угол атаки, при котором коэффициент подъёмной силы имеет максимальное значение	f	f	3	5498
213	угол атаки, при котором Су достигает максимального значения	t	f	1	5499
213	угол атаки, при котором на крыле начинают наблюдаться местные срывные явления	f	f	2	5500
213	угол атаки, при котором перегрузка при маневрировании достигает критического значения	f	f	3	5501
214	останется неизменной	f	f	1	5502
214	увеличится	t	f	2	5503
214	уменьшится	f	f	3	5504
215	останется неизменной	f	f	1	5505
215	увеличится	f	f	2	5506
215	уменьшится	t	f	3	5507
216	растёт	f	f	1	5508
216	уменьшается	f	f	2	5509
216	вначале падает, а затем растёт	t	f	3	5510
217	в 2 раза	f	f	1	5511
217	в 4 раза	f	f	2	5512
217	в 8 раз	t	f	3	5513
218	скорость полёта при значении максимального аэродинамического качества	t	f	1	5514
218	скорость полёта с минимальным часовым расходом топлива	f	f	2	5515
218	скорость полёта с минимальным километровым расходом топлива	f	f	3	5516
219	характеристикой ЛА	f	t	1	5517
219	характеристикой двигателя	f	f	2	5518
219	обобщённый параметр для ЛА и двигателя	f	f	3	5519
220	растёт	f	f	1	5520
220	уменьшается	t	f	2	5521
220	не изменяется	f	f	3	5522
221	разность значений между скоростью отрыва и максимально возможной скоростью	f	f	1	5523
221	разность между максимальной и практической минимальной скоростями на одной и той же высоте полета	t	f	2	5524
221	разность между максимальной и эволютивной скоростями на одной и той же высоте полета	f	f	3	5525
222	вираж с постоянными креном и скоростью	t	f	1	5526
222	вираж без потери и набора высоты	f	f	2	5527
222	маневр в горизонтальной плоскости с траекторией в виде замкнутой окружности	f	f	3	5528
223	растёт	f	f	1	5529
223	уменьшается	f	t	2	5530
223	остаётся неизменным	f	f	3	5531
224	возможен	f	f	1	5532
224	возможен на ЛА с ВИШ	f	f	2	5533
224	не возможен	f	t	3	5534
225	растёт	f	f	1	5535
225	остаётся неизменной	f	f	2	5536
225	падает	t	f	3	5537
226	300 м	f	t	1	5538
226	450 м	f	f	2	5539
226	600 м	f	f	3	5540
227	уменьшить скорость полёта	f	t	1	5541
227	увеличить скорость полёта, чтобы быстрее преодолеть зону повышенной турбулентности	f	f	2	5542
227	проверить степень затяжки привязных ремней и продолжить полёт, уделив повышенное внимание устранению возникающих отклонений	f	f	3	5543
228	расположение центра масс по отношению к аэродинамическому фокусу (точке приращения подъёмной силы)	f	t	1	5544
228	эффективность стабилизатора, руля высоты и его триммера	f	f	2	5545
228	отношение тяги и подъемной силы к весу и лобовому сопротивлению	f	f	3	5546
229	увеличится, если центр масс перемещается вперед	f	f	1	5547
229	уменьшится с увеличением полётной массы	f	f	2	5548
229	остаётся тем же, независимо от изменения массы ЛА и положения центра масс	f	t	3	5549
231	сваливание при более высокой, чем обычно, скорости полета	f	f	3	5555
232	показатель, характеризующий способность топлива противостоять самовоспламенению при сжатии (детонационная стойкость топлива)	f	t	1	5556
232	показатель, характеризующий количество лёгких углеводородов в топливе	f	f	2	5557
232	показатель, характеризующий наличие вредных примесей	f	f	3	5558
233	впуск, сжатие, рабочий ход, выпуск	f	t	1	5559
233	запуск, прогрев, работа, охлаждение, остановка	f	f	2	5560
233	малый газ, номинал, взлётный режим	f	f	3	5561
234	повышение температуры цилиндров, падение мощности, появление «звона»	f	t	1	5562
234	увеличение мощности за счёт более быстрого сгорания топлива, повышенный шум работы двигателя	f	f	2	5563
234	падение оборотов, температуры, неравномерность работы	f	f	3	5564
235	изгибную, перерезывающую	t	f	1	5565
235	изгибную, крутильную	f	f	2	5566
235	распределённую воздушную нагрузку, передаваемую обшивке крыла	f	f	3	5567
236	более полно использовать мощность силовой установки	f	t	1	5568
236	расширить диапазон скорости ЛА	f	f	2	5569
236	упростить управление тягой СУ	f	f	3	5570
237	нет	f	t	1	5571
237	да	f	f	2	5572
237	да, при наличии заземления ЛА	f	f	3	5573
238	да, перед каждым вылетом	t	f	1	5574
238	только перед первым вылетом	f	f	2	5575
238	по решению КВС в зависимости от задачи на полёт	f	f	3	5576
239	на КВС	t	f	1	5577
239	на техника (механика), обслуживающего ВС	f	f	2	5578
239	на владельца ВС	f	f	3	5579
240	в соответствии с РТЭ и РТО	t	f	1	5580
240	по мере необходимости	f	f	2	5581
240	после выявления замечаний в работе	f	f	3	5582
241	широта - по значениям на линии меридиана (вертикальная линия), от нулевой параллели (горизонтальная линия) на экваторе и до 90 градусов к северному полюсу	f	t	1	5583
241	широта - по значениям на линии параллели, от нулевого Гринвичского меридиана (вертикальная линия) на восток до 180 градусов	f	f	2	5584
241	широта - по вертикальным линиям сетки координат на карте с увеличением значений снизу вверх от нуля до 180 градусов	f	f	3	5585
242	долгота - по значениям на линии параллели, от нулевого Гринвичского меридиана на восток до 180 градусов	f	t	1	5586
242	долгота - по значениям на линии меридиана, от нулевой параллели на экваторе и до 90 градусов к северному полюсу	f	f	2	5587
242	долгота - по горизонтальным линиям отсчет от левого обреза карты на восток от нулевого до 360-го градуса	f	f	3	5588
243	МК - угол, замеренный магнитными приборами по часовой стрелке от 0 гр до 360 гр в горизонтальной плоскости от северного магнитного меридиана до проекции продольной оси ВС на горизонтальную плоскость	t	f	1	5589
243	МК - угол в горизонтальной плоскости от продольной оси ВС и направлением на ориентир с учетом дельта М, замеренный по ходу Солнца от 0 гр до 357гр.	f	f	2	5590
243	МК - угол между направлением на ориентир, взятого за начало отсчета с учетом магнитного склонения и осью ВС, замеренный по часовой стрелке от 0 гр до 360 гр	f	f	3	5591
244	ИПУ - угол, замеренный на карте от истинного меридиана до линии пути. По изогоне определяем значение магнитного склонения (дельта М). МК=МПУ= ИПУ-(±дельта М)	t	f	1	5592
244	угол между линией меридиана на карте и линией пути является значением МПУ. Значение МПУ на карте является значением МК следования без учета ветра	f	f	2	5593
244	ИПУ - угол, замеренный на карте от параллели до линии пути. Определяем значение магнитного склонения (дельта М) на полях карты. МК=МПУ= ИПУ+(±дельта М)	f	f	3	5594
245	карта сориентирована по странам света. Следить за курсом и вести счисление пути по скорости и времени. Ожидать появления ориентира. Опознавать крупные ориентиры, а затем вести детализацию в определении местоположения ВС относительно ЗЛП. Использовать инструментальные средства навигации GPS и АРК	f	t	1	5595
245	угол между продольной осью ВС и направлением на ориентир, замеренный по часовой стрелке и примерная дальность до ориентира дадут местоположение ВС относительно ориентира, а значит и относительно линии пути	f	f	2	5596
322	снижение температуры воздуха	f	f	1	5823
245	постоянный контроль пути по инструментальным средствам навигации GPS и АРК, а так же по курсовым углам двух и более ориентиров, дают возможность определить удаление ВС до поворотного пункта маршрута и посадочной площадки	f	f	3	5597
246	результат: путевая скорость W = 130 км/ч, подлетное время t = 18 мин.	t	f	1	5598
246	результат: путевая скорость W = 110 км/ч, подлетное время t = 21 мин.	f	f	2	5599
246	результат: путевая скорость W = 135 км/ч, подлетное время t = 17 мин.	f	f	3	5600
247	сличаю карту с местностью по характерным ориентирам на удалении 4,5см от ИПМ	t	f	1	5601
247	сличаю карту с местностью по характерным ориентирам на удалении 9см от ИПМ	f	f	2	5602
247	ввиду ограниченного времени на сличение карты с местностью ищу характерные ориентиры на протяжении всех 6см от ИПМ до вероятного места ВС	f	f	3	5603
248	как правило, справа от препятствий на удалении 500 м и более	t	f	1	5604
248	на дальности 800 м и более от препятствий	f	f	2	5605
248	справа или слева в зависимости от ситуации, но не ближе 250 м от препятствий	f	f	3	5606
249	КВС, не имеющий допуска к полетам по приборам, возвращается на аэродром (площадку) вылета или следует на запасной аэродром (площадку)	t	f	1	5607
249	КВС, усилив осмотрительность, продолжает полет в условиях ограниченной видимости на предельно малой высоте, исключая вход в облака	f	f	2	5608
249	КВС, усилив контроль за приборами, продолжает полет по возможности с набором высоты выше верхней границы облаков, даже если нет связи с диспетчером	f	f	3	5609
250	объекты, находящиеся на земной поверхности, или отдельные характерные участки, отличающиеся от окружающей местности, изображенные на полетной карте и видимые с воздушного судна. Линейные (дороги), точечные (трубы, мосты) и площадные	t	f	1	5610
250	все объекты, находящиеся на Земле, изображенные на полетной карте и видимые с воздушного судна. Основными признаками ориентиров являются маркировка, размеры, конфигурация, специальная окраска	f	f	2	5611
250	объекты, находящиеся на Земле и установленные для решения задач навигации и исключения опасного сближения с поверхностью и искусственными сооружениями, характерные участки, имеющие маркировку, изображенные на полетной карте	f	f	3	5612
252	при скорости полета не более 300 км/ч - 4 км	t	f	1	5613
252	при скорости полета не более 250 км/ч - 3 км	f	f	2	5614
252	при скорости полета не более 200 км/ч - 2 км	f	f	3	5615
253	данные ВПП в намеченных к использованию местах взлета и посадки; потребный запас топлива; данные о взлетной и посадочной дистанции, содержащиеся в РЛЭ; все известные задержки движения, о которых КВС был уведомлен органом ОВД	t	f	1	5616
253	данные аэропортов, места посадки (высадки) пассажиров (погрузки и выгрузки грузопотребный запас топлива; данные о взлетной и посадочной дистанции, содержащиеся в РЛЭ; все известные задержки движения, о которых КВС был уведомлен органом ОВД	f	f	2	5617
253	данные аэропортов, места посадки (высадки) пассажиров (погрузки и выгрузки грузопотребный запас топлива; данные о взлетной и посадочной дистанции, глиссаде снижения содержащиеся в РЛЭ; все известные задержки движения на земле, о которых КВС был уведомлен органом ОВД и другую необходимую для выполнения полёта информацию	f	f	3	5618
254	прогнозируемые метеорологические условия; предполагаемые отклонения от маршрута по указанию органов управления воздушным движением и задержки, связанные с воздушным движением; необходимость, при выполнении полета по ППП, выполнения одного захода на посадку по приборам на аэродроме намеченной посадки, включая уход на второй круг; повышенный расход топлива при разгерметизации кабин воздушного судна или при отказе одного двигателя во время полета по маршруту; любые другие известные условия, которые могут задержать посадку или вызвать повышенный расход топлива и (или) масла	t	f	1	5619
268	авиатопливное, аварийно-спасательное, авиационное медицинское, аэродромное, метеорологическое, орнитологическое, обеспечение авиационной безопасности	f	f	3	5663
277	заметивший воздушное судно слева - уменьшить, а справа - увеличить высоту полета, так, чтобы разность высот обеспечивала безопасное расхождение воздушных судов	t	f	1	5688
322	конденсация влаги и появление капель росы	f	t	2	5824
254	прогнозируемые метеорологические условия; предполагаемой протяжённостью маршрута и задержки, связанные с воздушным движением; необходимость, при выполнении полета по ППП, выполнения одного захода на посадку по приборам на аэродроме намеченной посадки, включая уход на второй круг; повышенный расход топлива при отказе одного двигателя во время полета по маршруту; любые другие известные условия, которые могут задержать посадку или вызвать повышенный расход топлива и (или) масла	f	f	2	5620
254	прогнозируемые метеорологические условия; предполагаемые отклонения от маршрута по указанию органов управления воздушным движением и задержки, связанные с воздушным движением; необходимость, при выполнении полета по ППП, выполнения одного захода на посадку по приборам на аэродроме намеченной посадки, включая уход на второй круг; повышенный расход топлива при разгерметизации кабин воздушного судна или при отказе одного двигателя во время полета по маршруту; эшелон полёта, направление и скорость ветра, центровку самолёта и состояние ВПП	f	f	3	5621
255	магнитный компас, гирополукомпас, хронометр или часы, (указывающие время в часах, минутах и секундах), барометрический высотомер, указатель приборной воздушной скорости	f	f	1	5622
255	магнитный компас, хронометр или часы, (указывающие время в часах, минутах и секундах), барометрический высотомер, указатель приборной воздушной скорости	t	f	2	5623
255	магнитный компас, гирополукомас, хронометр или часы, (указывающие время в часах, минутах и секундах), барометрический высотомер, указатель приборной воздушной скорости, указатель вертикальной скорости	f	f	3	5624
256	второй указатель пространственного положения (авиагоризонт)	f	f	1	5625
256	второй переносной фонарь	f	t	2	5626
256	второй барометрический высотомер	f	f	3	5627
257	да, если ВС не относится к сверхлёгким	t	f	1	5628
257	нет	f	f	2	5629
257	при наличии места размещения	f	f	3	5630
258	стандартное - QNE - 760 мм.рт.ст (1013 мбар); на аэродроме - давление на уровне рабочего порога ВПП - QFE; на аэродроме или в районе полётов - давление, приведенное к среднему уровню моря по стандартной атмосфере, при установке которого на шкале давления барометрического высотомера барометрическая высота аэродрома, вертодрома, пункта совпадает с его абсолютной высотой - QNH	f	f	1	5631
258	стандартное - QNE - 760 мм.рт.ст (1013 мбар); на аэродроме (площадке) - давление на уровне рабочего порога ВПП - QFE; на аэродроме или среднее по маршруту полёта - давление, приведенное к среднему уровню моря по стандартной атмосфере, при установке которого на шкале давления барометрического высотомера барометрическая высота аэродрома, вертодрома, пункта совпадает с его абсолютной высотой - QNH	f	f	2	5632
258	стандартное - QNE - 760 мм.рт.ст (1013 мбар); на аэродроме - давление на уровне рабочего порога ВПП - QFE; на аэродроме или в пункте - давление, приведенное к среднему уровню моря по стандартной атмосфере, при установке которого на шкале давления барометрического высотомера барометрическая высота аэродрома, вертодрома, пункта совпадает с его абсолютной высотой (далее - QNH)	t	f	3	5633
259	над территориями населенных пунктов и над местами скопления людей при проведении массовых мероприятий - ниже высоты, допускающей в случае отказа двигателя аварийную посадку без создания чрезмерной опасности для людей и имущества на земле, и ниже высоты 300 м над самым высоким препятствием в пределах горизонтального радиуса в 500 м вокруг данного воздушного судна; вне населенных пунктов и мест скопления людей при проведении массовых мероприятий на расстоянии менее 150 м от людей, транспортных средств или строений	t	f	1	5634
259	над территориями населенных пунктов если это не вызвано необходимостью и над местами скопления людей при проведении массовых мероприятий - ниже высоты, допускающей в случае отказа двигателя аварийную посадку без создания чрезмерной опасности для людей и имущества на земле, и ниже высоты 100 м над самым высоким препятствием в пределах горизонтального радиуса в 1500 м вокруг данного воздушного судна; не населенных пунктов и мест скопления людей при проведении массовых мероприятий на расстоянии менее 150 м от людей, транспортных средств или строений	f	f	2	5635
288	сертификата летной годности (удостоверения о годности к полетам)	t	f	3	5723
259	над территориями населенных пунктов если это не вызвано необходимостью и над местами скопления людей при проведении массовых мероприятий - ниже высоты, допускающей в случае отказа двигателя аварийную посадку без создания чрезмерной опасности для людей и имущества на земле, и ниже высоты 100 м над самым высоким препятствием в пределах горизонтального радиуса в 1500 м вокруг данного воздушного судна, за исключением случаев выполнения демонстрационных полётов; не населенных пунктов и мест скопления людей при проведении массовых мероприятий на расстоянии менее 150 м от людей, транспортных средств или строений	f	f	3	5636
260	при видимости водной или земной поверхности	f	f	1	5637
260	вне облаков днем, при видимости не менее 2000 м для самолетов и не менее 1000 м для вертолетов; ночью, при видимости не менее 4000 м	f	f	2	5638
260	все перечисленные варианты	t	f	3	5639
261	если расстояние по вертикали от воздушного судна до нижней границы облаков не менее 100 м и расстояние по горизонтали до облаков не менее 1500 м; днем, при видимости не менее 1000 м; ночью, при видимости не менее 2000 м	f	f	1	5640
261	если расстояние по вертикали от воздушного судна до нижней границы облаков не менее 150 м и расстояние по горизонтали до облаков не менее 1000 м; днем, при видимости не менее 2000 м; ночью, при видимости не менее 4000 м	t	f	2	5641
261	если расстояние по вертикали от воздушного судна до нижней границы облаков не менее 200 м и расстояние по горизонтали до облаков не менее 2000 м; днем, при видимости не менее 1000 м; ночью, при видимости не менее 2000 м	f	f	3	5642
262	при полете по воздушной трассе - ниже опубликованной в аэронавигационной информации минимальной абсолютной высоты полета по данной трассе	f	f	1	5643
262	при полете вне опубликованных в аэронавигационной информации воздушных трасс в равнинной и холмистой местности - ниже 300 м истинной высоты в радиусе 8000 м от препятствия, а в горной местности - ниже 600 м истинной высоты в радиусе 8000 м от препятствия	f	f	2	5644
262	оба варианта	t	f	3	5645
263	по необходимости, если давление в тормозной системе соответствует рабочему и отсутствует информация от наземного персонала о утечке гидрожидкости или воздуха	f	f	1	5646
263	не должен	f	f	2	5647
263	должен	t	f	3	5648
264	50 км/ч на прямолинейных участках, 5 км/ч на разворотах, если видимость на рулении не менее 2 км и 20 км/ч на прямолинейных участках, 5 км/ч на разворотах при видимости не рулении менее 2 км	f	f	1	5649
264	скорость руления ограничена РЛЭ ВС	f	f	2	5650
264	скорость руления выбирается КВС в зависимости от состояния поверхности, по которой производится руление, наличия препятствий и условий видимости	t	f	3	5651
265	если экипаж воздушного судна получил информацию, что взлет создаст помеху воздушному судну, которое выполняет прерванный заход на посадку (уход на второй круг)	f	f	1	5652
265	ночью на аэродроме, не имеющем действующего светосигнального оборудования, за исключением случаев, предусмотренных в главе VII ФАП-128	f	f	2	5653
265	оба варианта	t	f	3	5654
266	перевести шкалы давления барометрических высотомеров на стандартное атмосферное давление (QNE) и сличить их показания	t	f	1	5655
266	перевести один из барометрических высотомеров на стандартное атмосферное давление (QNE) и запомнить разницу показаний и выполнять полёт по основному барометрическому высотомеру с учётом поправки	f	f	2	5656
266	рассчитать поправку по давлению аэродрома и выполнять полёт на высоте с учётом поправки	f	f	3	5657
267	из заблаговременной, предварительной и предполётной подготовок	f	f	1	5658
267	общей, предварительной, предполётной подготовок	f	f	2	5659
267	наземной и лётной подготовок	t	f	3	5660
268	авиатопливное, аварийно-спасательное, авиационное медицинское, аэродромное, метеорологическое, орнитологическое, обеспечение авиационной безопасности, электросветотехническое, аэронавигационное, морально-психологическое	f	f	1	5661
268	авиатопливное, аварийно-спасательное, авиационное медицинское, аэродромное, метеорологическое, орнитологическое, обеспечение авиационной безопасности, электросветотехническое	t	f	2	5662
321	показатель содержания взвешенных капель воды в воздухе	f	f	2	5821
1454	2 h х V	f	f	3	7580
269	по правилам выполнения, по использованию элементов структуры воздушного пространства, по метеорологическим условиям, по количеству ВС, по времени суток, по физико-географическим условиям, месту и способам выполнения, по высоте выполнения	t	f	1	5664
269	по правилам выполнения, по использованию элементов структуры воздушного пространства, по метеорологическим условиям, по времени суток, по физико-географическим условиям, месту и способам выполнения, по высоте выполнения	f	f	2	5665
269	по правилам выполнения, по использованию элементов структуры воздушного пространства, по метеорологическим условиям, по количеству ВС, по времени суток, по физико-географическим условиям	f	f	3	5666
270	для аэродромов и командира воздушного судна	f	f	1	5667
270	для аэродромов, вида авиационных работ и командира воздушного судна	f	f	2	5668
270	для аэродромов, воздушного судна, вида авиационных работ и командира воздушного судна	t	f	3	5669
271	устанавливается по минимально допустимому значению видимости на ВПП и, при необходимости, по высоте нижней границы облаков, при которых командиру воздушного судна разрешается выполнять взлет на воздушном судне данного типа	t	f	1	5670
271	устанавливается по минимально допустимому значению видимости на ВПП и, при необходимости, по высоте нижней границы облаков, при которых командир воздушного судна когда-то выполнял полёты	f	f	2	5671
271	устанавливается по минимально допустимому значению видимости на ВПП, при которой командиру воздушного судна разрешается выполнять взлет на воздушном судне данного типа	f	f	3	5672
272	по минимально допустимым значениям высоты нижней границы облачности и ВПР (МВС), при которых командиру воздушного судна разрешается выполнять посадку на воздушном судне данного типа	f	f	1	5673
272	по минимально допустимым значениям видимости на ВПП и ВПР (МВС), при которых командиру воздушного судна разрешается выполнять посадку на воздушном судне данного типа	t	f	2	5674
272	по минимально допустимым значениям видимости на ВПП и ВПР (МВС), при которых командиру воздушного судна принял решение на выполнение посадки	f	f	3	5675
273	по ПВП - не менее 100м, по ППП - не менее 200м	t	f	1	5676
273	по ПВП - не менее 150м, по ППП - не менее 300м	f	f	2	5677
273	по ПВП - не менее 200м, по ППП - не менее 600м	f	f	3	5678
274	по давлению на аэродроме - при полетах в районе аэродрома в радиусе не более 50 км от КТА (районе аэроузла), от взлета до набора высоты перехода и от эшелона перехода аэродрома (аэроузлдо посадки; по приведенному давлению по стандартной атмосфере - на аэродромах, открытых для международных полетов и горных (по запросу экипажа); по минимальному давлению, приведенному к уровню моря, - при полетах на высотах ниже нижнего (безопасного) эшелона (эшелона перехода); по стандартному давлению - при полетах на высотах выше высоты перехода	t	f	1	5679
274	по приведенному давлению по стандартной атмосфере - на аэродромах, открытых для международных полетов и горных (по запросу экипажа); по минимальному давлению, приведенному к уровню моря, - при полетах на высотах ниже нижнего (безопасного) эшелона (эшелона перехода); по стандартному давлению - при полетах на высотах выше высоты перехода	f	f	2	5680
274	по давлению на аэродроме - при полетах в районе аэродрома в радиусе не более 50 км от КТА (районе аэроузла), от взлета до набора высоты перехода и от эшелона перехода аэродрома (аэроузла) до посадки; по приведенному давлению по стандартной атмосфере - на аэродромах, открытых для международных полетов и горных (по запросу экипажа)	f	f	3	5681
275	После взлета в ходе набора высоты с давления на аэродроме на стандартное давление производится при пересечении высоты перехода	t	f	1	5682
275	После взлета в ходе набора высоты с давления на аэродроме на стандартное давление производится при пересечении эшелона перехода	f	f	2	5683
275	После взлета в ходе набора высоты с давления на аэродроме на стандартное давление производится при пересечении минимально - безопасной высоты аэродрома	f	f	3	5684
276	летящее впереди, слева или ниже	t	f	1	5685
276	летящее слева или ниже	f	f	2	5686
276	летящее выше, но имеющее большую вертикальную скорость снижения	f	f	3	5687
322	резкое снижение тяги двигателя	f	f	3	5825
277	заметивший воздушное судно слева - увеличить, а справа - уменьшить высоту полета, так, чтобы разность высот обеспечивала безопасное расхождение воздушных судов	f	f	2	5689
277	заметивший воздушное судно слева - выполнить отворот вправо, а справа - выполнить отворот влево, так, чтобы разность высот обеспечивала безопасное расхождение воздушных судов	f	f	3	5690
278	наблюдаются опасные метеорологические явления или скопления птиц, представляющие угрозу для выполнения посадки; до ВПР был установлен необходимый визуальный контакт с ориентирами для продолжения захода на посадку, а положение воздушного судна в пространстве или параметры его движения не обеспечивают безопасности посадки; в воздушном пространстве или на ВПП появились препятствия, угрожающие безопасности полета(посадки)	f	f	1	5691
278	наблюдаются опасные метеорологические явления или скопления птиц, представляющие угрозу для выполнения посадки; до ВПР не был установлен необходимый визуальный контакт с ориентирами для продолжения захода на посадку или если положение воздушного судна в пространстве или параметры его движения не обеспечивают безопасности посадки; в воздушном пространстве или на ВПП появились препятствия, угрожающие безопасности полета(посадки)	t	f	2	5692
278	наблюдаются опасные метеорологические явления или скопления птиц, представляющие угрозу для выполнения посадки; до ВПР не был установлен необходимый визуальный контакт с ориентирами для продолжения захода на посадку или если положение воздушного судна в пространстве или параметры его движения не обеспечивают безопасности посадки; в полосе подхода есть препятствия, угрожающие безопасности полета (посадки)	f	f	3	5693
279	на всех воздушных судах находящихся в полёте	f	f	1	5694
279	На всех воздушных судах, находящихся в полете, кроме воздушных судов, выполняющих боевую задачу или специальное задание, в период между заходом и восходом солнца, а также по указанию соответствующего органа ОВД (управления полетами)	t	f	2	5695
279	На всех воздушных судах, находящихся в полете, кроме воздушных судов, выполняющих боевую задачу или специальное задание, по указанию соответствующего органа ОВД (управления полетами)	f	f	3	5696
280	В случае, когда к моменту прибытия воздушного судна погода в районе аэродрома оказалась ниже установленного минимума для выполнения посадки и состоянию авиационной техники произвести посадку на запасном аэродроме или использовать спасательные средства	f	f	1	5697
280	В случае, когда к моменту прибытия воздушного судна погода в районе аэродрома оказалась ниже установленного минимума для выполнения посадки и нет возможности по запасу топлива произвести посадку на запасном аэродроме или использовать спасательные средства	f	f	2	5698
280	В случае, когда к моменту прибытия воздушного судна погода в районе аэродрома оказалась ниже установленного минимума для выполнения посадки и нет возможности по запасу топлива и состоянию авиационной техники произвести посадку на запасном аэродроме или использовать спасательные средства	t	f	3	5699
281	включить сигнал «Бедствие»; передать по радио сигнал «Полюс»; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; с разрешения органа ОВД (управления полетами) занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетов способ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке	t	f	1	5700
289	аттестата о годности к эксплуатации или акта оценки конкретного воздушного судна на соответствие конкретного воздушного судна требованиям к летной годности гражданских воздушных судов и природоохранным требованиям	f	f	1	5724
289	сертификата типа (аттестата о годности к эксплуатации) или акта оценки конкретного воздушного судна на соответствие конкретного воздушного судна требованиям к летной годности гражданских воздушных судов и природоохранным требованиям	t	f	2	5725
281	включить сигнал «Бедствие» на частоте 121.5 Ггц; передать по радио сигнал «Полюс»; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетоспособ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке	f	f	2	5701
281	включить сигнал «Бедствие» на частоте 121.5 Ггц; передать по радио сигнал «Полюс»; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетов способ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке, уточнить своё место методом опроса граждан и продолжить выполнение полёта	f	f	3	5702
282	граждане и юридические лица, наделенные в установленном порядке правом на осуществление деятельности по использованию воздушного пространства	t	f	1	5703
282	граждане, прошедшие специальную подготовку и юридические лица имеющие в пользовании авиационную технику	f	f	2	5704
282	авиационный персонал, выполняющий обязанности по эксплуатации, обслуживанию и ремонту авиационной техники	f	f	3	5705
283	государственная, гражданская и экспериментальная	t	f	1	5706
283	государственная, коммерческая, авиация общего назначения, экспериментальная	f	f	2	5707
283	авиация МО, МВД, ФСБ,МЧС, гражданская и частная	f	f	3	5708
284	авиация, используемая в целях обеспечения потребностей граждан и экономики	t	f	1	5709
284	авиация, используемая для предоставления услуг (по осуществлению воздушных перевозок пассажиров, багажа, грузов, почты) и (или) выполнения авиационных работ	f	f	2	5710
284	авиация, не используемая для осуществления коммерческих воздушных перевозок	f	f	3	5711
285	обеспечение безопасности полетов воздушных судов, контроль состояния авиационной техники гражданской авиации работ и оказываемых услуг	f	f	1	5712
285	обеспечение безопасности полетов воздушных судов, авиационной безопасности и качества выполняемых в гражданской авиации работ и оказываемых услуг	t	f	2	5713
285	обеспечение безопасности воздушных перевозок, авиационной безопасности и качества выполняемых в гражданской авиации работ и оказываемых услуг	f	f	3	5714
286	средство передвижения, поддерживаемое в атмосфере за счет взаимодействия с воздухом, отличного от взаимодействия с воздухом, отраженным от поверхности земли или воды	f	f	1	5715
286	летательный аппарат, поддерживаемый в атмосфере за счет тяги силовой установки и наличия аэродинамических поверхностей, отличного от взаимодействия с воздухом, отраженным от поверхности земли или воды	f	f	2	5716
286	летательный аппарат, поддерживаемый в атмосфере за счет взаимодействия с воздухом, отличного от взаимодействия с воздухом, отраженным от поверхности земли или воды	t	f	3	5717
287	воздушное судно, максимальный взлетный вес которого составляет менее 6700 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 2100 килограмм	f	f	1	5718
287	воздушное судно, максимальный взлетный вес которого составляет менее 5700 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 3100 килограмм	t	f	2	5719
287	воздушное судно, максимальный взлетный вес которого составляет менее 5500 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 3200 килограмм	f	f	3	5720
288	акта технического состояния	f	f	1	5721
288	удостоверения о годности к полетам	f	f	2	5722
289	сертификата типа или акта оценки конкретного воздушного судна на соответствие конкретного воздушного судна требованиям к летной годности гражданских воздушных судов и природоохранным требованиям	f	f	3	5726
290	участок земли или акватория с расположенными на нем зданиями, сооружениями и оборудованием, предназначенный для взлета, посадки, руления и стоянки воздушных судов	t	f	1	5727
290	участок земли или акватория с расположенными на нем зданиями, сооружениями и оборудованием, предназначенный для взлета и посадки воздушных судов	f	f	2	5728
290	участок земли или акватория с расположенными на нем зданиями, сооружениями и оборудованием, предназначенный для посадки, руления и стоянки воздушных судов	f	f	3	5729
291	участок земли, льда, поверхности сооружения, в том числе поверхности плавучего сооружения, либо акватория, длинной не менее 400м, шириной не менее 20м, предназначенные для взлета, посадки или для взлета, посадки, руления и стоянки воздушных судов	f	f	1	5730
291	участок земли, льда, поверхности сооружения, в том числе поверхности плавучего сооружения, либо акватория, предназначенные для взлета, посадки или для взлета, посадки, руления и стоянки воздушных судов	t	f	2	5731
291	участок земли, льда, поверхности сооружения, в том числе поверхности плавучего сооружения, либо акватория, длинной и шириной не менее 20м на 20м, предназначенные для взлета, посадки или для взлета, посадки, руления и стоянки воздушных судов	f	f	3	5732
292	лицо, имеющее действующее свидетельство пилота (летчика), а также подготовку и опыт, необходимые для самостоятельного управления воздушным судном определенного типа	t	f	1	5733
292	лицо, прошедшее специальную подготовку, обладающее знаниями и опытом, необходимым для самостоятельного управления воздушным судном определенного типа	f	f	2	5734
292	лицо, имеющее действующее свидетельство пилота (летчика), а также достаточный опыт, необходимые для самостоятельного управления воздушным судном определенного типа	f	f	3	5735
293	принимать окончательное решение о составе экипажа	f	f	1	5736
293	принимать окончательные решения о взлете, полете и посадке воздушного судна	t	f	2	5737
293	принимать решения о десантировании пассажиров с использованием спасательных парашютов, если это необходимо для обеспечения безопасности полета воздушного судна и его посадки	f	f	3	5738
294	имеющее государственный и регистрационный или учетный опознавательные знаки, прошедшее необходимую подготовку и имеющее на борту соответствующую документацию	t	f	1	5739
294	бортовой номер и учетный опознавательные знаки, прошедшее необходимую подготовку и имеющее на борту соответствующую документацию.	f	f	2	5740
294	имеющее государственный и регистрационный или учетный опознавательные знаки, прошедшее необходимую подготовку и имеющее на борту бортовую карту, бортовой и санитарный журнал, журнал подготовки самолёта	f	f	3	5741
295	свидетельство о государственной регистрации; сертификат (свидетельство) эксплуатанта (копия), за исключением случаев, предусмотренных пунктом 4 статьи 61 настоящего Кодекса; сертификат летной годности (удостоверение о годности к полетам); бортовой и санитарный журналы, руководство по летной эксплуатации (при эксплуатации сверхлегких гражданских воздушных судов наличие бортового и санитарного журналов, руководства по летной эксплуатации необязательно); разрешение на бортовую радиостанцию, если воздушное судно оборудовано радиоаппаратурой	t	f	1	5742
295	свидетельство о государственной регистрации; сертификат (свидетельство) эксплуатанта (копия); сертификат летной годности (удостоверение о годности к полетам); бортовой и санитарный журналы, руководство по летной эксплуатации (при эксплуатации сверхлегких гражданских воздушных судов наличие бортового и санитарного журналов, руководства по летной эксплуатации необязательно); разрешение на бортовую радиостанцию, если воздушное судно оборудовано радиоаппаратурой	f	f	2	5743
304	автоколебания носового колеса, возникающие на большой скорости	t	f	2	5770
304	автоколебания носового колеса, возникающие на большой скорости, из-за неустойчивой обдувки колеса набегающим потоком	f	f	3	5771
321	показатель видимости в облаках и тумане	f	f	3	5822
295	свидетельство о государственной регистрации; сертификат (свидетельство) эксплуатанта (копия), за исключением случаев, предусмотренных пунктом 4 статьи 61 настоящего Кодекса; акт технического состояния воздушного судна; бортовой и санитарный журналы, руководство по летной эксплуатации (при эксплуатации сверхлегких гражданских воздушных судов наличие бортового и санитарного журналов, руководства по летной эксплуатации необязательно); разрешение на бортовую радиостанцию, если воздушное судно оборудовано радиоаппаратурой	f	f	3	5744
296	работы, выполняемые с использованием полетов частных воздушных судов в сельском хозяйстве, строительстве, для охраны окружающей среды, оказания медицинской помощи и других целей, перечень которых устанавливается уполномоченным органом в области гражданской авиации	f	f	1	5745
296	работы, выполняемые с использованием полетов гражданских воздушных судов в народном хозяйстве, для охраны окружающей среды, оказания медицинской помощи и других целей в интересах органов муниципального, регионального управления и силовых ведомств, перечень которых устанавливается уполномоченным органом в области гражданской авиации	f	f	2	5746
296	работы, выполняемые с использованием полетов гражданских воздушных судов в сельском хозяйстве, строительстве, для охраны окружающей среды, оказания медицинской помощи и других целей, перечень которых устанавливается уполномоченным органом в области гражданской авиации	t	f	3	5747
297	воздушное судно, предназначенное для полётов в атмосфере с помощью силовой установки, создающей тягу и неподвижного относительно других частей аппарата крыла, создающего подъемную силу	t	f	1	5748
297	Летательный аппарат, предназначенный для полётов в атмосфере с помощью силовой установки, и предназначенный для перевозки пассажиров, грузов, почты или иных целей	f	f	2	5749
297	воздушное судно, предназначенное для полётов в атмосфере с помощью неподвижно стоящим крылом относительно других частей создающим подъёмную силу и предназначенный для размещения экипажа, пассажиров и багажа, или иного оборудования для его доставки из одной точки в другую	f	f	3	5750
298	фюзеляжа, крыльев, хвостового оперения и шасси	f	f	1	5751
298	фюзеляжа, крыла, оперения	t	f	2	5752
298	фюзеляжа, крыльев, хвостового горизонтального и вертикального оперения, силовой установки и шасси	f	f	3	5753
299	Числу крыльев, по расположению крыла, по расположению хвостового оперения, по типу, размеру и этажности фюзеляжа, по типу шасси, по скорости полёта, по роду посадочных органов, по типу взлёта и посадки, по стадии разработки и освоения модели, по способу управления	t	f	1	5754
299	Числу крыльев, по расположению крыла, по расположению хвостового оперения, по типу, размеру и этажности фюзеляжа, по типу шасси, по скорости полёта, по роду посадочных органов, по типу взлёта и посадки, по стадии разработки и освоения модели, по способу управления, по схеме силовой установки	f	f	2	5755
299	Числу крыльев, по расположению крыла, по расположению хвостового оперения, по типу, размеру и этажности фюзеляжа, по типу шасси, по скорости полёта, по роду посадочных органов, по типу взлёта и посадки, по стадии разработки и освоения модели, по способу управления, по схеме силовой установки, назначению самолёта	f	f	3	5756
300	Моноплан, биплан, триплан, тетраплан, элиплоидоплан	f	f	1	5757
300	Моноплан, биплан, триплан	t	f	2	5758
300	Многоплан, моноплан, планер, винтокрыл	f	f	3	5759
301	Шпангоутов, лонжеронов, стрингеров, балок и нервюр	f	f	1	5760
301	Шпангоутов, силовых балок, стрингеров, обшивки	t	f	2	5761
301	Шпангоутов, лонжеронов, стрингеров, нервюр, нервюр и обшивки	f	f	3	5762
302	Монокок, полумонокок, стрингерно - балочный	f	f	1	5763
302	Монокок, полумонокок, четвертьмонокок	f	f	2	5764
302	Монокок, полумонокок	t	f	3	5765
303	для проверки отсутствия воды и посторонних примесей в топливе	f	f	1	5766
303	для проверки октанового числа	f	t	2	5767
303	для хранения, если при выполнении полёта произойдёт отказ силовой установки	f	f	3	5768
304	автоколебания, возникающие в результате воздействия скоростного напора на крыло самолёта	f	f	1	5769
321	показатель содержания водяного пара в воздухе	t	f	1	5820
305	резкие, неустановившиеся колебания хвостового оперения, вызванные аэродинамическими импульсами от спутной струи воздуха за крылом	f	t	1	5772
305	резкие, неустановившиеся колебания хвостового колеса, вызванные неровностями поверхности аэродрома или неисправным амортизатором	f	f	2	5773
305	резкие, неустановившиеся колебания киля и стабилизатора, вызванные аэродинамическими импульсами от спутной струи воздуха за крылом из-за ослабления узлов навески этих поверхностей	f	f	3	5774
306	сочетание самовозбуждающихся незатухающих изгибающих и крутящих автоколебаний элементов конструкции летательного аппарата	f	t	1	5775
306	незатухающие автоколебания, вызванные скоростным напором, ведущие к разрушению конструкции крыла	f	f	2	5776
306	незатухающие автоколебания, вызванные большим скоростным напором, ведущие к разрушению конструкции крыла, стабилизатора или других аэродинамических поверхностей	f	f	3	5777
307	бензиновые, дизельные, турбореактивные	f	f	1	5778
307	двигатели внутреннего сгорания, двигатели внешнего сгорания, двигатели на паровой тяге	f	f	2	5779
307	поршневые, газотурбинные, турбовинтовые, турбовентиляторные, воздушно-реактивные(реактивные)	f	t	3	5780
308	обеспечения путевой и продольной устойчивости самолёта	f	f	1	5781
308	обеспечения путевой и продольной устойчивости и управляемости самолёта	f	t	2	5782
308	обеспечения размещения рулевых поверхностей и проводки управляющего момента от органов управления к рулевым поверхностям	f	f	3	5783
309	по необходимости	f	t	1	5784
309	при проведении регламентных работ через каждые 100ч налёта	f	f	2	5785
309	после удара о поверхность и при выполнении регламентных работ каждые 100 часов	f	f	3	5786
310	допускается	f	f	1	5787
310	допускается если есть возможность закрыть их в движении	f	f	2	5788
310	не допускается	f	t	3	5789
311	закупорки посторонними предметами отверстий статического и динамического давления	f	f	1	5790
311	образования льда на ПВД и его закупорки	f	t	2	5791
311	образования льда на ПВД и его закупорки, а также сжигания попавших посторонних предметов в каналы ПВД	f	f	3	5792
312	будет	f	t	1	5793
312	не будет	f	f	2	5794
312	будет, но только при нулевой скорости	f	f	3	5795
313	азот - 78%, кислород - 12%, метан - 1%, другие газы - 8%, пары воды - 1%	f	f	1	5796
313	азот - 78%, кислород - 21%, углекислый газ - 0,03%, инертные газы - 0,94%, пары воды - 0,03%	t	f	2	5797
313	азот - 50%, кислород - 40%, углекислый газ - 8%, инертные газы - 0,94%, пары воды - 0,03%	f	f	3	5798
314	тропосфера+тропопауза, стратосфера+стратопауза, мезосфера+мезопауза, термосфера	t	f	1	5799
314	тропосфера+тропопауза, мезосфера+мезопауза, стратосфера+стратопауза, термосфера	f	f	2	5800
314	тропсфера+тропопауза, моносфера+монопауза, биосфера+биопауза, ионосфера	f	f	3	5801
315	биосфера	f	f	1	5802
315	тропосфера	t	f	2	5803
315	стратосфера	f	f	3	5804
316	температура 25 гр., давление 760 мб, температура с высотой падает на 6,5 гр. до уровня тропопаузы	f	f	1	5805
316	температура 15 гр., давление 1013 мб, температура с высотой падает на 6,5 гр. до уровня тропопаузы	t	f	2	5806
316	температура 0 гр., давление 1013 мб, температура с высотой падает на 10 гр. до уровня тропопаузы	f	f	3	5807
317	8 км	f	f	1	5808
317	5 км	f	f	2	5809
317	11 км	t	f	3	5810
318	весом воздуха, давящим на поверхности тел, в нем находящихся	t	f	1	5811
318	производной плотности водяного пара в атмосфере	f	f	2	5812
318	силой давления воздуха на горизонтальные поверхности	f	f	3	5813
319	величина, определяющая изменение давления в зависимости от относительной влажности воздуха	f	f	1	5814
319	величина, определяющая изменение высоты в зависимости от изменения атмосферного давления	t	f	2	5815
319	величина, определяющая изменение абсолютной влажности с высотой	f	f	3	5816
320	расстояние, на котором еще можно увидеть горизонт	f	f	1	5817
320	расстояние, на котором еще можно обнаружить предмет (ориентир) по форме, цвету, яркости	t	f	2	5818
320	дальность, на которой видны воздушные суда 1-го класса	f	f	3	5819
323	переход воды из жидкого состояния в парообразное	f	f	1	5826
323	переход воды из жидкого состояние в твердое	f	f	2	5827
323	переход воды из газообразного состояния в жидкое	f	t	3	5828
324	количество водяного пара в граммах в 1 м3 воздуха	t	f	1	5829
324	количество капель росы на 1 м2 поверхности	f	f	2	5830
324	количество взвешенных капель воды в 1 м3 воздуха	f	f	3	5831
325	отношение количества водяного пара к тому количеству водяного пара, которое воздух может содержать в данной местности	f	f	1	5832
325	отношение количества водяного пара к тому количеству водяного пара, которое воздух может содержать при данной температуре	t	f	2	5833
325	отношение количества водяного пара к количеству воздуха в кубометре атмосферы	f	f	3	5834
326	растет	f	f	1	5835
326	падает	t	f	2	5836
326	остается неизменной	f	f	3	5837
327	аномальный характер изменения температуры воздуха с высотой	t	f	1	5838
327	аномальный характер изменения температуры в кабине с высотой	f	f	2	5839
327	нагревание воздуха с высотой	f	f	3	5840
328	температурные инверсии плотности и температурные инверсии давления	f	f	1	5841
328	приземные температурные инверсии и температурные инверсии свободной атмосферы	t	f	2	5842
328	постоянные температурные инверсии и сезонные температурные инверсии	f	f	3	5843
329	снега, дождя, ветра, метелей	f	f	1	5844
329	тумана, смога, дымки, облаков, миражей	t	f	2	5845
329	увеличению дальности полета ВС	f	f	3	5846
330	горизонтальная полетная видимость, вертикальная полетная видимость, наклонная полетная видимость	t	f	1	5847
330	видимость минимальной дальности, видимость максимальной дальности, видимость нулевой дальности	f	f	2	5848
330	продольная видимость, поперечная видимость, диагональная видимость	f	f	3	5849
331	вертикальные перемещения воздуха в атмосфере	f	f	1	5850
331	горизонтальные перемещения воздуха	t	f	2	5851
331	сила, с которой воздух перемещает воздушное судно	f	f	3	5852
332	направление, куда дует ветер	f	f	1	5853
332	у метеорологического ветра нет направления, только сила	f	f	2	5854
332	направление, откуда дует ветер	t	f	3	5855
333	возникают из-за разной влажности воздуха на местности	f	f	1	5856
333	возникают в результате неравномерного распределения в горизонтальном направлении атмосферного давления	t	f	2	5857
333	возникают из-за суточных колебаний температур	f	f	3	5858
334	возникают из-за разной влажности воздуха на местности	f	f	1	5859
334	возникают в результате неравномерного распределения в горизонтальном направлении атмосферного давления	t	f	2	5860
334	возникают из-за суточных колебаний температур	f	f	3	5861
335	вектор, характеризующий степень изменения атмосферного давления в пространстве	t	f	1	5862
335	вектор, характеризующий изменение скорости ветра	f	f	2	5863
335	вектор, характеризующий направление ветра	f	f	3	5864
336	перпендикулярно изобарам, в сторону изобары меньшего давления	f	f	1	5865
336	перпендикулярно изобарам, в сторону изобары большего давления	f	f	2	5866
336	вдоль изобар, оставляя изобару меньшего давления слева	t	f	3	5867
337	равномерное горизонтальное движение воздуха при отсутствии силы трения	t	f	1	5868
337	равномерное вертикальное движение воздуха при отсутствии силы трения	f	f	2	5869
337	ускоренное горизонтальное движение воздуха при отсутствии силы трения	f	f	3	5870
338	отклоняет частицы воздуха влево от направления их движения	f	f	1	5871
338	отклоняет частицы воздуха вправо от направления их движения	t	f	2	5872
338	никак не влияет	f	f	3	5873
339	в среднем под углом 10-20 гр. к изобаре	f	f	1	5874
339	в среднем под углом 60-70 гр. к изобаре	f	t	2	5875
339	в пограничном слое горизонтальных движений нет	f	f	3	5876
340	сила трения, Кориолисова сила, барический градиент	t	f	1	5877
340	сила трения, магнитные поля, осмотический градиент	f	f	2	5878
340	центробежная сила, солнечный ветер, осмотический градиент	f	f	3	5879
341	1013 Мб или 760 мм.рт.ст	t	f	1	5880
341	760 Мб или 1013 мм.рт.ст	f	f	2	5881
341	700 Мб или 1000 мм.рт.ст	f	f	3	5882
342	перистые, слоистые, когтеобразные	f	f	1	5883
342	перламутровые, слоистые, кучевые	f	f	2	5884
342	перистые, слоистые, кучевые	t	f	3	5885
343	температура, при которой воздух достиг бы состояния насыщения при данном влагосодержании и неизменном давлении	t	f	1	5886
343	температура, при которой воздух достиг бы состояния насыщения при данном влагосодержании и падении давления	f	f	2	5887
343	температура, при которой воздух достиг бы состояния насыщения при данном влагосодержании и повышении давления	f	f	3	5888
344	скопление взвешенных в атмосфере капель воды, или ледяных кристаллов, или смеси тех и других, возникших в результате конденсации водяного пара	f	f	1	5889
344	скопление взвешенных в атмосфере капель воды, или ледяных кристаллов, или смеси тех и других, возникших в результате конвекции водяного пара	f	f	2	5890
344	пар в воздухе	f	t	3	5891
345	облака белого цвета с плоским основанием и куполообразной вершиной, дают обильные осадки	f	f	1	5892
345	облака белого цвета с плоским основанием и куполообразной вершиной, осадков не дают	t	f	2	5893
345	отдельные белые волокнистые облака, тонкие и прозрачные	f	f	3	5894
346	радиационные, адвективные, фронтальные, туманы испарения	t	f	1	5895
346	радиоактивные, вертикальные, утренние, ветровые туманы	f	f	2	5896
346	утренние, ночные, дневные, туманы плохой погоды	f	f	3	5897
347	явление, когда взвешенные в воздухе капли воды или кристаллы льда уменьшают дальность видимости до 10 км и менее	f	f	1	5898
347	явление, когда взвешенные в воздухе капли воды или кристаллы льда уменьшают дальность видимости до 1 км и менее	t	f	2	5899
347	явление, когда взвешенные в воздухе водяной пар уменьшают дальность видимости до 1 км и менее	f	f	3	5900
348	это мелкие насекомые выпадающие из верхних слоев атмосферы	f	f	1	5901
348	это вода в жидком или твёрдом состоянии, выпадающая из облаков или осаждающаяся из воздуха на земную поверхность и какие-либо предметы	t	f	2	5902
348	это вода в жидком состоянии, выпадающая из облаков или осаждающаяся из воздуха на земную поверхность и какие-либо предметы	f	f	3	5903
349	большие объемы воздуха в тропосфере, имеющие горизонтальные размеры в сотни и тысячи км. и характеризующиеся резкими изменениями температур по вертикали	f	f	1	5904
349	большие объемы воздуха в тропосфере, имеющие горизонтальные размеры в сотни и тысячи км. и характеризующиеся примерной однородностью температур и влагосодержания	t	f	2	5905
349	небольшие объемы воздуха, характеризующиеся однородностью температур	f	f	3	5906
350	ложбина, цикловина, седловина, антицикловина	f	f	1	5907
350	циклон, антициклон, полуциклон, молодой циклон	f	f	2	5908
350	циклон, антициклон, ложбина, седловина, гребень	t	f	3	5909
351	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от периферии к центру	t	f	1	5910
351	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от центра к периферии	f	f	2	5911
351	барическая система, очерченная на карте замкнутыми изобарами, в которой давление на всех изобарах одинаково	f	f	3	5912
352	буквой С	f	f	1	5913
352	буквой Н	t	f	2	5914
352	буквой Ц	f	f	3	5915
353	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от периферии к центру	f	f	1	5916
353	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от центра к периферии	t	f	2	5917
353	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает с севера на юг	f	f	3	5918
354	буквой В	t	f	1	5919
354	буквой А	f	f	2	5920
354	буквой F	f	f	3	5921
355	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от центра к периферии	f	f	1	5922
355	узкая вытянутая полоса пониженного давления, вклинивающаяся между двумя областями более высокого давления	t	f	2	5923
408	свыше 15 и до 300 м над рельефом местности или водной поверхностью	f	f	3	6077
355	узкая вытянутая полоса повышенного давления, вклинивающаяся между двумя областями более низкого давления	f	f	3	5924
356	узкая вытянутая полоса повышенного давления, вклинивающаяся между двумя областями более низкого давления	t	f	1	5925
356	узкая вытянутая полоса пониженного давления, вклинивающаяся между двумя областями более высокого давления	f	f	2	5926
356	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от периферии к центру	f	f	3	5927
357	барическая система, заключенная между двумя областями более высокого давления (антициклонами) и двумя областями более низкого давления (циклонами)	t	f	1	5928
357	узкая вытянутая полоса пониженного давления, вклинивающаяся между двумя областями более высокого давления	f	f	2	5929
357	барическая система, очерченная на карте замкнутыми изобарами, в которой давление убывает от центра к периферии	f	f	3	5930
358	Теплый фронт, смежный фронт, устойчивый фронт, неустойчивый фронт	f	f	1	5931
358	Циклический фронт, горизонтальный фронт, вертикальный фронт	f	f	2	5932
358	Теплый фронт, холодный фронт, фронт окклюзии, стационарный фронт	t	f	3	5933
359	Теплый фронт, смежный фронт, устойчивый фронт, неустойчивый фронт	f	f	1	5934
359	Циклический фронт, горизонтальный фронт, вертикальный фронт	f	f	2	5935
359	Теплый фронт, холодный фронт, фронт окклюзии, стационарный фронт	t	f	3	5936
360	Это поверхность раздела между двумя воздушными массами	t	f	1	5937
360	Это поверхность раздела между двумя различными направлениями ветра	f	f	2	5938
360	Это граница развития кучево-дождевой облачности	f	f	3	5939
361	Это поверхность раздела между двумя воздушными массами с различными свойствами	t	f	1	5940
361	Это поверхность раздела между двумя различными направлениями ветра	f	f	2	5941
361	Это граница развития кучево-дождевой облачности	f	f	3	5942
362	Это горизонтальное движение воздуха из области высоких температур в область низких температур	f	f	1	5943
362	Это вертикальный подъем воздуха, нагретого над отдельными участками поверхности	f	t	2	5944
362	Это вертикальный подъем воздуха из области повышенного давления в область пониженного	f	f	3	5945
363	Вертикальные движения воздушных масс, в результате которого теплый воздух оказывается над холодным	f	f	1	5946
363	Конвекция	f	f	2	5947
363	Горизонтальный перенос воздушных масс на встречу друг другу	f	t	3	5948
364	Фронт, разделяющий две холодные воздушные массы	f	f	1	5949
364	Фронт, разделяющий основные географические типы воздушных масс	f	t	2	5950
364	Фронт между двумя циклонами	f	f	3	5951
365	Участок главного фронта, смещающийся в сторону холодного воздуха	f	t	1	5952
365	Участок главного фронта, смещающийся в сторону теплого воздуха	f	f	2	5953
365	Перегретый воздух, натекающий на теплую воздушную массу	f	f	3	5954
366	Участок главного фронта, смещающийся в сторону холодного воздуха	f	f	1	5955
366	Участок главного фронта, смещающийся в сторону теплого воздуха	f	t	2	5956
366	Переохлажденный воздух, натекающий на теплую воздушную массу	f	f	3	5957
367	Участок главного фронта, смещающийся в сторону холодного воздуха	f	f	1	5958
367	Участок главного фронта, смещающийся в сторону теплого воздуха	f	f	2	5959
367	Фронт, образовавшийся в результате смыкания теплого и холодного фронтов	f	t	3	5960
368	Участок главного фронта, остающийся без движения	f	t	1	5961
368	Участок главного фронта, медленно подтекающий под теплый фронт	f	f	2	5962
368	Фронт, в котором не наблюдается изменений температур в течение трех дней	f	f	3	5963
369	Участок главного фронта, остающийся без движения	f	t	1	5964
369	Участок главного фронта, медленно подтекающий под теплый фронт	f	f	2	5965
369	Фронт, в котором не наблюдается изменений температур в течение трех дней	f	f	3	5966
370	Слоисто-дождевые, высоко-слоистые облака на нижнем и среднем ярусах до 5-6 км	f	t	1	5967
370	Вечерние перламутровые облака	f	f	2	5968
370	Мощно-кучевые низкие облака	f	f	3	5969
1465	заданный план полета	f	f	3	6911
371	Последовательностью появления облаков: слоисто-дождевые с выпадением осадков, перистые, перисто-слоистые, высоко-слоистые	f	f	1	5970
371	Последовательностью появления облаков: перистые, перисто-слоистые, высоко-слоистые, слоисто-дождевые с выпадением осадков	t	f	2	5971
371	Движением навстречу «стене» мощно-кучевых облаков	f	f	3	5972
372	Медленно движущийся холодный фронт (не более 30 км/ч)	f	t	1	5973
372	Быстродвижущийся холодный фронт (более 30 км/ч)	f	f	2	5974
372	Неподвижный холодный фронт	f	f	3	5975
373	Карты циклонов, Карты антициклонов, карты опасных явлений погоды	f	f	1	5976
373	Основные карты погоды, кольцевые карты погоды, карты барической топографии, вспомогательные карты	f	t	2	5977
373	Карты циклонов и антициклонов, карты фронтов, карты влажности, карты температур	f	f	3	5978
374	Туманы, пыльные бури, мгла, осадки	f	t	1	5979
374	Запотевание стекла кабины, задымление салона	f	f	2	5980
374	Темное время суток	f	f	3	5981
375	Иней внутри кабины при сильном морозе	f	f	1	5982
375	Скопление льда на лопастях и фюзеляже во время стоянки	f	f	2	5983
375	Отложение льда на различных частях ЛА в полете	f	t	3	5984
376	Отложением льда со скоростью 0,01 - 0,5 мм/мин	t	f	1	5985
376	Отложением льда со скоростью 0,5 - 1,0 мм/мин	f	f	2	5986
376	Отложением льда со скоростью менее 1 мм/мин	f	f	3	5987
377	Отложением льда со скоростью 0,01 - 0,5 мм/мин	f	f	1	5988
377	Отложением льда со скоростью 0,5 - 1,0 мм/мин	f	f	2	5989
377	Отложением льда со скоростью более 1 мм/мин	t	f	3	5990
378	При температурах от -10 до -20 градусов	f	f	1	5991
378	При температурах от 0 до -10 градусов	f	t	2	5992
378	При любых минусовых температурах	f	f	3	5993
379	Мощный лед, слабый лед, умеренный лед	f	f	1	5994
379	Снежинки, ледяные узоры, шероховатый лед	f	f	2	5995
379	Прозрачный (стекловидный лед), матовый (смешанный) лед, белый лед, иней, изморозь	f	t	3	5996
380	Плавное нарастание скорости ветра с высотой	f	f	1	5997
380	Изменение направления и(или) скорости ветра в атмосфере на очень небольшом расстоянии	f	t	2	5998
380	Внезапный вертикальный поток воздуха на пути ВС	f	f	3	5999
381	Нисходящие движения воздуха имеющие в поперечном измерении диаметр от 1 до 3 км и вертикальную скорость до 125 км/ч	f	t	1	6000
381	Нисходящие движения воздуха имеющие в поперечном измерении диаметр от 100 до 200 м и вертикальную скорость до 400 км/ч	f	f	2	6001
381	Узкий горизонтальный поток воздуха со скоростью ветра до 200 км/ч	f	f	3	6002
382	Обозначение единицы измерения «метр» для пилотов	f	f	1	6003
382	Mетеорологический код для передачи сводок о фактической погоде на аэродроме	t	f	2	6004
382	Метеорологический код для передачи прогноза погоды на аэродроме	f	f	3	6005
383	Обозначение единицы измерения «метр» для пилотов	f	f	1	6006
383	Mетеорологический код для передачи сводок о фактической погоде на аэродроме	f	f	2	6007
383	Метеорологический код для передачи прогноза погоды на аэродроме	t	f	3	6008
384	Метеорологический код для передачи прогноза погоды на аэродроме	f	f	1	6009
384	Информация о фактическом или ожидаемом изменении погоды по маршруту опасных явлений погоды	t	f	2	6010
384	Обозначение снега c дождем в коде METAR	f	f	3	6011
385	Метеорологический код для передачи прогноза погоды на аэродроме	f	f	1	6012
385	Информация о фактическом или ожидаемом изменении погоды по маршруту опасных явлений погоды	f	t	2	6013
385	Обозначение снега c дождем в коде METAR	f	f	3	6014
386	в 1 см карты соответствует 20 км на местности	f	f	1	6015
386	в 1 см карты соответствует 2 км на местности	t	f	2	6016
386	в 1 см карты соответствует 5 км на местности	f	f	3	6017
387	величина центрального угла или дуги меридиана	f	f	1	6018
387	угол между плоскостью экватора и направлением нормали к поверхности эллипсоида в данной точке	t	f	2	6019
387	угол в плоскости экватора или параллели от Гринвичского меридиана	f	f	3	6020
388	двугранный угол, заключенный между плоскостью Гринвичского меридиана и плоскостью меридиана данной точки	t	f	1	6021
388	угол между плоскостью меридиана и направлением нормали к поверхности эллипсоида в данной точке	f	f	2	6022
388	угол между плоскостью экватора и направлением нормали к поверхности эллипсоида в данной точке	f	f	3	6023
389	эллипсоид вращения	t	f	1	6024
389	поверхность геоида	f	f	2	6025
389	шар	f	f	3	6026
390	точки пересечения плоскости эклиптики с осью вращения Земли	f	f	1	6027
390	точки, через которые проходит ось суточного вращения Земли	t	f	2	6028
390	точки, через которые проходит ось годового вращения Земли	f	f	3	6029
391	окружность большого круга в плоскости перпендикулярной оси вращения Земли проходящей через центр	f	f	1	6030
391	окружность большого круга в плоскости которого лежит ось вращения Земли	t	f	2	6031
391	полуокружность от географического северного полюса до географического южного полюса	f	f	3	6032
392	полуокружность малого круга в плоскости перпендикулярной оси вращения Земли, не проходящей через центр	f	f	1	6033
392	окружность большого круга, в плоскости которого лежит ось вращения Земли	f	f	2	6034
392	полуокружность от географического северного полюса до географического южного полюса проходящая через заданную точку на земной поверхности	t	f	3	6035
393	множество меридианов	f	f	1	6036
393	2 меридиана	f	f	2	6037
393	1 меридиан	t	f	3	6038
394	окружность большого круга в плоскости перпендикулярной оси вращения Земли проходящей через центр	f	f	1	6039
394	окружность малого круга в плоскости перпендикулярной оси вращения Земли проходящая через заданную точку на земной поверхности	t	f	2	6040
394	окружность большого круга, в плоскости которого лежит ось вращения Земли	f	f	3	6041
395	когда центр солнечного диска находится на 6° ниже горизонта	t	f	1	6042
395	когда центр солнечного диска находится на горизонте	f	f	2	6043
395	когда центр солнечного диска находится на 6° выше горизонта	f	f	3	6044
396	когда центр солнечного диска находится на горизонте	f	f	1	6045
396	когда центр солнечного диска находится на 6° выше горизонта	f	f	2	6046
396	когда центр солнечного диска находится на 6° ниже горизонта	t	f	3	6047
399	угол между условным и истинным меридианом в данной точке	f	f	1	6048
399	угол между магнитным меридианом и продольной осью воздушного судна	f	f	2	6049
399	угол между северным направлением истинного и магнитного меридиана в данной точке	t	f	3	6050
400	вариацией компаса	f	f	1	6051
400	девиацией компаса	t	f	2	6052
400	компасным курсом	f	f	3	6053
401	азимутом	t	f	1	6054
401	заданным путевым углом	f	f	2	6055
401	истинным курсом	f	f	3	6056
402	превышение одной точки местности над другой	f	f	1	6057
402	превышение точки местности над аэродромом	f	f	2	6058
402	высоту в метрах или в футах над уровнем моря	t	f	3	6059
403	расстояние по вертикали от уровня моря до нижней точки вертолета	f	f	1	6060
403	высота, отсчитываемая от изобарической поверхности атмосферного давления, установленного на барометрическом высотомере	f	f	2	6061
403	расстояние по вертикали от точки местности, над которой находится вертолет в данный момент	t	f	3	6062
404	истинного меридиана	t	f	1	6063
404	магнитного меридиана	f	f	2	6064
404	линии заданного пути	f	f	3	6065
405	высота, отсчитываемая по давлению аэродрома	f	f	1	6066
405	расстояние, по вертикали отсчитываемое от уровня моря до нижней точки вертолета	t	f	2	6067
405	высота, измеряемая с помощью радиовысотомера	f	f	3	6068
406	999гПа(750 мм.рт.ст.)	f	f	1	6069
406	1013гПА(760 мм.рт.ст.)	t	f	2	6070
406	999мбар(750 мм.рт.ст.)	f	f	3	6071
407	до 200 м включительно над рельефом местности или водной поверхностью	t	f	1	6072
407	до 15 м включительно над рельефом местности или водной поверхностью	f	f	2	6073
407	до 50 м включительно над рельефом местности или водной поверхностью	f	f	3	6074
408	свыше 200 и до 1000 м над рельефом местности или водной поверхностью	t	f	1	6075
408	до 200 м над рельефом местности или водной поверхностью	f	f	2	6076
1470	REGION	f	f	1	6912
1470	ZONA	t	f	2	6913
409	давления на точке местности(аэродрома)	t	f	1	6078
409	давления на уровне моря	f	f	2	6079
409	поверхности по радиовысотомеру	f	f	3	6080
410	измеряемая с помощью указателя скорости	f	f	1	6081
410	перемещения вертолета относительно воздушной среды	t	f	2	6082
410	перемещения вертолета относительно земной поверхности	f	f	3	6083
411	перемещения вертолета относительно воздушной среды	f	f	1	6084
411	измеряемая с помощью указателя скорости	f	f	2	6085
411	перемещения вертолета относительно земной поверхности	t	f	3	6086
412	воздушной скорости, путевой скорости, линией заданного пути	f	f	1	6087
412	воздушной скорости, путевой скорости, вектором ветра	t	f	2	6088
412	воздушной скорости, путевой скорости, вертикальной скорости	f	f	3	6089
413	путевая скорость	f	f	1	6090
413	воздушная скорость	t	f	2	6091
413	инструментальная скорость	f	f	3	6092
414	малые ориентиры	f	f	1	6093
414	большие характерные ориентиры	f	t	2	6094
414	линии электропередач	f	f	3	6095
416	предварительный расчет	t	f	1	6096
416	окончательный расчет	f	f	2	6097
416	общая подготовка	f	f	3	6098
417	высота перехода	f	f	1	6099
417	эшелонирование	t	f	2	6100
417	безопасная высота	f	f	3	6101
418	московское время - МСК	f	f	1	6102
418	местное время	f	f	2	6103
418	всемирное координированное время - УТЦ (UTC)	t	f	3	6104
419	путем запроса у диспетчера соответствующего органа обслуживания воздушного движения (управления полетами) текущего времени	t	f	1	6105
419	путем прослушивания сигналов точного времени	f	f	2	6106
419	путем сравнения данных с GPS	f	f	3	6107
420	до ближайшей половины минуты	t	f	1	6108
420	до 2-х секунд	f	f	2	6109
420	до 1-ой минуты	f	f	3	6110
421	максимальной продолжительности полета	t	f	1	6111
421	максимальной скорости полета	f	f	2	6112
421	максимального набора высоты	f	f	3	6113
422	включить сигнал "Бедствие"; передать по радио сигнал "Полюс"; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; с разрешения органа ОВД (управления полетами) занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетов способ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке	f	f	1	6114
422	включить сигнал "Бедствие" на частоте 121.5 Ггц; передать по радио сигнал "Полюс"; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетоспособ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке	f	t	2	6115
422	включить сигнал "Бедствие" на частоте 121.5 Ггц; передать по радио сигнал "Полюс"; доложить органу ОВД (управления полетами) об остатке топлива и условиях полета; занять наивыгоднейшую высоту для обнаружения воздушного судна наземными радиотехническими средствами и экономичного расхода топлива; применить наиболее эффективный в данных условиях (рекомендованный для данного района полетов способ восстановления ориентировки, согласуя свои действия с органом ОВД (управления полетами); в случаях, когда восстановить ориентировку не удалось, заблаговременно, не допуская полной выработки топлива и до наступления темноты, произвести посадку на любом аэродроме или выбранной с воздуха площадке, уточнить своё место методом опроса граждан и продолжить выполнение полёта	f	f	3	6116
1470	KRUG	f	f	3	6914
424	линия, описываемая ВС в процессе его движения в воздушном пространстве	f	f	1	6117
424	линия, описываемая центром масс ЛА в процессе его движения в воздушном пространстве	t	f	2	6118
424	проекция воздушного судна на земную поверхность	f	f	3	6119
425	Фактическая траектория полета соответствует линия фактического пути (ЛФП), заданной траектории — линия заданного пути (ЛЗП)	f	f	1	6120
425	ЛП — проекция траектории полета ЛА на земную поверхность. Фактической траектории полета соответствует линия фактического пути (ЛФП), заданной траектории — линия заданного пути (ЛЗП)	t	f	2	6121
425	ЛП — проекция траектории полета ЛА на земную (водную) поверхность. Фактической траектории полета соответствует линия фактического пути (ЛФП), заданной траектории — линия заданного пути (ЛЗП)	f	f	3	6122
426	проекция его центра масс на земную поверхность к определенному моменту времени	t	f	1	6123
426	проекция самолёта в плане на земную поверхность к определенному моменту времени	f	f	2	6124
426	отметка самолёта на индикаторе кругового обзора, или планшете навигационной обстановки или на полётной карте	f	f	3	6125
428	расстояние от земной (водной) поверхности до ВС	f	f	1	6126
428	расстояние по вертикали от начального уровня ее отсчета до ВС	t	f	2	6127
428	расстояние по вертикали от максимального препятствия до ВС	f	f	3	6128
429	высота от выбранного уровня (уровня аэродрома, цели и др.) до объекта (воздушного судна), относительно которого измеряется высота	t	f	1	6129
429	высота, измеряемая относительно стандартного уровня барометрического давления (760 мм.рт.ст.)	f	f	2	6130
429	высота, от пролетаемого в данный момент препятствия до объекта (воздушного судна), относительно которого измеряется высота	f	f	3	6131
430	высота полета над земной (водной) поверхностью	f	f	1	6132
430	высота полета над препятствием	f	f	2	6133
430	высота полета над уровнем моря	t	f	3	6134
431	установленная поверхность постоянного атмосферного давления, отнесенная к давлению 760,0 мм.рт.ст. (1013,2 гПа) и отстоящая от других таких поверхностей на величину установленных интервалов	t	f	1	6135
431	высота, отсчитываемая от уровня, который соответствует атмосферному давлению 1050 гПа., в предположении, что распределение температуры с высотой соответствует стандартным условиям	f	f	2	6136
431	установленная поверхность постоянного атмосферного давления, отнесенная к давлению на уровне моря в текущих условиях и отстоящая от других таких поверхностей на величину установленных интервалов	f	f	3	6137
432	фактическая скорость, с которой ВС движется относительно воздушной среды с учётом ветра	f	f	1	6138
432	фактическая скорость, с которой ВС движется относительно земной (водной) поверхностью	f	f	2	6139
432	фактическая скорость, с которой ВС движется относительно воздушной среды	t	f	3	6140
433	скорость, которую показывает прибор, измеряющий воздушную скорость	t	f	1	6141
433	скорость, которую показывает прибор с учётом аэродинамической и барометрической поправки	f	f	2	6142
433	скорость, которую показывает прибор с учётом аэродинамической, барометрической и температурной поправки	f	f	3	6143
434	в горизонтальной плоскости между выбранным опорным направлением и проекцией на эту плоскость продольной оси ВС	t	f	1	6144
434	в горизонтальной плоскости между Северным направлением истинного меридиана и проекцией на эту плоскость продольной оси ВС	f	f	2	6145
434	в горизонтальной плоскости между выбранным опорным направлением и линией заданного пути ВС	f	f	3	6146
435	0 до 360° в зависимости от курса ВС со знаком «плюс», против хода часовой стрелки — со знаком «минус»	f	f	1	6147
435	0 до 180° по ходу часовой стрелки со знаком «плюс», против хода часовой стрелки — со знаком «минус»	t	f	2	6148
435	0 до 160° по ходу часовой стрелки	f	f	3	6149
436	скорость горизонтального перемещения воздушных масс относительно земной поверхности	t	f	1	6150
436	скорость вертикального и горизонтального перемещения воздушных масс относительно земной поверхности	f	f	2	6151
436	скорость перемещения воздушных масс относительно земной (водной) поверхности	f	f	3	6152
437	угол в горизонтальной плоскости, заключенный между тем же опорным направлением, от которого измеряется курс, и вектором ветра	t	f	1	6153
437	угол в горизонтальной плоскости, заключенный между продольной осью ВС и вектором ветра	f	f	2	6154
437	угол в горизонтальной плоскости, заключенный между тем же опорным направлением, от которого измеряется курс, и вектором ветра отсчитываемым от 0 до 1800	f	f	3	6155
438	скорость перемещения ВС относительно земной поверхности	t	f	1	6156
438	приборная скорость с учётом скорости ветра	f	f	2	6157
438	истинная скорость с учётом скорости ветра, измеряемая в узлах, милях на километр, в километрах в час	f	f	3	6158
439	угол, заключенный между векторами скорости ветра и воздушной скорости	f	f	1	6159
439	угол, заключенный между векторами скорости ветра и путевой скорости	f	t	2	6160
439	угол, заключенный между векторами воздушной и путевой скоростей	f	f	3	6161
440	это минимальная высота, гарантирующая ВС от столкновения его с земной (водной) поверхностью и расположенными на ней препятствиями	t	f	1	6162
440	это минимальная высота, гарантирующая ВС выполнение посадки с учётом расположенными препятствиями на земле с учётом температурной, барометрической и аэродинамической поправок	f	f	2	6163
440	это минимальная высота, гарантирующая ВС от столкновения его с земной (водной) поверхностью с учётом рельефа местности	f	f	3	6164
442	двугранный угол, заключенный между плоскостями начального меридиана и меридиана данной точки. Долгота измеряется центральным углом в плоскости экватора или дугой экватора от начального меридиана до меридиана точки С в пределах от 0 до 180° к востоку или к западу	f	f	1	6165
442	двугранный угол, заключенный между плоскостями начального меридиана и меридиана данной точки. Долгота измеряется центральным углом в плоскости экватора или дугой экватора от начального меридиана до меридиана точки С в пределах от 0 до 180° к востоку или к западу. При решении некоторых задач долгота отсчитывается только на восток от 0 до 360°	t	f	2	6166
442	двугранный угол, заключенный между плоскостями начального меридиана и меридиана данной точки. Долгота измеряется центральным углом в плоскости экватора или дугой экватора от начального меридиана до меридиана точки С в пределах от 0 до 180° к востоку или к западу. При решении некоторых задач долгота отсчитывается только на восток от 0 до 360°. За начальный меридиан принимают Гринвичский меридиан, проходящий через центр Гринвичской астрономической обсерватории возле Лондона	f	f	3	6167
443	равнодействующая силы давления воздуха, направленная под прямым углом к поверхности самолёта или его части, и силы трения, касательной к поверхности	t	f	1	6168
443	равнодействующая силы давления воздуха, направленная под прямым углом к поверхности самолёта	f	f	2	6169
443	равнодействующая силы давления воздуха перпендикулярная к направлению набегающего потока	f	f	3	6170
444	составляющая полной аэродинамической силы, направленная перпендикулярно к направлению набегающего потока воздуха	t	f	1	6171
444	составляющая полной аэродинамической силы, направленная против движения самолёта	f	f	2	6172
444	сила перпендикулярная плоскости крыла и направленная вниз	f	f	3	6173
445	сумма подъемной силы и силы трения	f	f	1	6174
445	сумма сил профильного сопротивления, индуктивного сопротивления и волнового сопротивления	t	f	2	6175
445	сумма сил волнового и индуктивного сопротивлений	f	f	3	6176
446	отношение лобового сопротивления к подъёмной силе	f	f	1	6177
446	отношение подъёмной силы к лобовому сопротивлению	f	t	2	6178
446	отношение полной аэродинамической силы к силе лобового сопротивления	f	f	3	6179
447	графическая взаимозависимость между Су и Сх	f	t	1	6180
447	графическая взаимозависимость между углом атаки α и Сх	f	f	2	6181
447	графическая взаимозависимость между углом атаки α и Су	f	f	3	6182
448	хорда такого прямоугольного крыла, которое имеет одинаковую с данным крылом площадь при равных углах атаки	f	f	1	6183
465	не влияет на скорость отрыва и увеличивает длину разбега	f	f	3	6236
466	уменьшает запас устойчивости по перегрузке	t	f	1	6237
448	хорда такого прямоугольного крыла, которое имеет одинаковые с данным крылом площадь, величину полной аэродинамической силы и положение центра давления (ЦД) при равных углах атаки	f	t	2	6184
448	хорда такого прямоугольного крыла, которое имеет одинаковую с данным крылом величину полной аэродинамической силы при равных углах атаки	f	f	3	6185
449	в центре давления	f	t	1	6186
449	в центре тяжести	f	f	2	6187
449	в аэродинамическом фокусе	f	f	3	6188
450	для увеличения подъёмной силы на минимальной скорости	f	t	1	6189
450	для увеличения силы лобового сопротивления на минимальной скорости	f	f	2	6190
450	для увеличения маневренных характеристик на больших скоростях	f	f	3	6191
451	2	f	f	1	6192
451	4	f	t	2	6193
451	6	t	f	3	6194
452	прямолинейный полет с постоянной скоростью без набора высоты и снижения	t	f	1	6195
452	прямолинейный полет с произвольной скоростью без набора высоты и снижения	f	f	2	6196
452	прямолинейный полет с постоянной скоростью с набором высоты или снижением	f	f	3	6197
453	тяга, необходимая для уравновешивания подъёмной силы самолета на данном угле атаки	f	f	1	6198
453	тяга, необходимая для установившегося горизонтального полета	f	t	2	6199
453	тяга, необходимая для установившегося набора высоты	f	f	3	6200
454	тягу, которая необходима для горизонтального полёта	f	f	1	6201
454	наибольшую тягу, которую может развить силовая установка на данной высоте и скорости полета	f	t	2	6202
454	тягу, которую может развить силовая установка в наборе высоты	f	f	3	6203
455	этап полёта с момента отделения воздушного судна от земной или искусственной поверхности до момента набора установленной высоты и скорости полета применительно к конкретному воздушному судну	f	f	1	6204
455	этап полёта с момента начала ускоренного движения воздушного судна с линии старта на земной или искусственной поверхности до момента набора высоты 15 метров	f	f	2	6205
455	этап полёта с момента начала ускоренного движения воздушного судна с линии старта на земной или искусственной поверхности до момента набора установленной высоты и скорости полета применительно к конкретному воздушному судну	f	t	3	6206
456	увеличиваются	f	t	1	6207
456	уменьшаются	f	f	2	6208
456	не изменяются	f	f	3	6209
457	увеличивает скорость отрыва	f	f	1	6210
457	уменьшает скорость отрыва	f	f	2	6211
457	не влияет	f	t	3	6212
458	увеличивается	f	t	1	6213
458	уменьшается	f	f	2	6214
458	не изменяется	f	f	3	6215
459	выход самолета на закритические углы атаки	f	f	1	6216
459	авторотация крыла на закритических углах атаки	f	t	2	6217
459	авторотация крыла на критических углах атаки	f	f	3	6218
460	управляемое движение самолёта на углах атаки близких к критическим или критических	f	f	1	6219
460	самопроизвольное движение самолёта на углах атаки близких к критическим или критических	f	t	2	6220
460	неуправляемое движение самолёта, на закритических углах атаки	f	f	3	6221
461	кривые потребной тяги и располагаемой тяги	t	f	1	6222
461	графическая взаимозависимость коэффициентов подъёмной силы и лобового сопротивления	f	f	2	6223
461	графическая зависимость аэродинамического качества от угла атаки	f	f	3	6224
462	расстояние от центра тяжести до начала САХ, выраженное в процентах ее длины	t	f	1	6225
462	расстояние от центра давления до начала САХ, выраженное в процентах ее длины	f	f	2	6226
462	расстояние от фокуса самолёта до начала САХ, выраженное в процентах ее длины	f	f	3	6227
463	положением его центра тяжести относительно центра давления	f	f	1	6228
463	положением его центра тяжести относительно фокуса	f	t	2	6229
463	положением его центра давления относительно фокуса	f	f	3	6230
464	его устойчивостью и управляемостью	f	f	1	6231
464	его балансировкой	f	f	2	6232
464	его балансировкой, устойчивостью и управляемостью	f	t	3	6233
465	уменьшает скорость отрыва и длину разбега	f	f	1	6234
465	увеличивает скорость отрыва и длину разбега	f	t	2	6235
535	расчетное время посадки	f	f	1	7107
466	увеличивает запас устойчивости по перегрузке	f	f	2	6238
466	не влияет на запас устойчивости по перегрузке.	f	f	3	6239
467	из условий, при которых самолет еще может выйти на посадочные углы атаки (Супос) с данным отклонением руля высоты	f	t	1	6240
467	из условий создания большей продольной устойчивости самолёта	f	f	2	6241
467	из условий создания большей продольной управляемости	f	f	3	6242
468	из условий создания запаса продольной устойчивости самолёта по перегрузке	t	f	1	6243
468	из условий создания большей продольной устойчивости самолёта	f	f	2	6244
468	из условий создания меньшей продольной управляемости самолёта	f	f	3	6245
469	верхнее, среднее, нижнее	f	f	1	6246
469	нижнее, стратосфера, верхнее	f	f	2	6247
469	нижнее и верхнее	t	f	3	6248
470	зоны и районы (зоны и районы Единой системы, районы полетной информации, диспетчерские районы, диспетчерские зоны); маршруты обслуживания воздушного движения; районы аэродромов (аэроузлов, вертодромов); специальные зоны (зоны отработки техники пилотирования, пилотажные зоны, зоны испытательных полетов, зоны полетов воздушных судов на малых и предельно малых высотах, зоны полетов воздушных судов на скоростях, превышающих скорость звука, полетов воздушных судов на дозаправку топливом в воздухе, полетов воздушных судов с переменным профилем и т.д.); маршруты полетов воздушных судов; запретные зоны; опасные зоны; зоны ограничения полетов; другие элементы, устанавливаемые для осуществления деятельности в воздушном пространстве	t	f	1	6249
470	зоны и районы (зоны и районы Единой системы, районы полетной информации, диспетчерские районы, диспетчерские зоны); маршруты обслуживания воздушного движения; районы аэродромов (аэроузлов, вертодромов); пилотажные зоны, зоны испытательных полетов, зоны полетов воздушных судов на малых и предельно малых высотах, зоны полетов воздушных судов на скоростях, превышающих скорость звука, полетов воздушных судов на дозаправку топливом в воздухе, полетов воздушных судов с переменным профилем и т.д.); маршруты полетов воздушных судов; запретные зоны; опасные зоны; зоны ограничения полетов; другие элементы, устанавливаемые для осуществления деятельности в воздушном пространстве	f	f	2	6250
470	зоны и районы (зоны и районы Единой системы, районы полетной информации, диспетчерские районы, диспетчерские зоны); маршруты обслуживания воздушного движения; районы аэродромов (аэроузлов, вертодромов); зоны полетов воздушных судов на скоростях, превышающих скорость звука, полетов воздушных судов на дозаправку топливом в воздухе, полетов воздушных судов с переменным профилем и т.д.); маршруты полетов воздушных судов; запретные зоны; опасные зоны; зоны ограничения полетов; другие элементы, устанавливаемые для осуществления деятельности в воздушном пространстве	f	f	3	6251
471	класс А, класс С, класс В, класс G, класс D	f	f	1	6252
471	класс В, класс А, класс G	f	f	2	6253
471	класс G, класс А, класс С	t	f	3	6254
472	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Все воздушные суда обеспечиваются диспетчерским обслуживанием. Воздушные суда, выполняющие полеты по правилам полетов по приборам, эшелонируются относительно других воздушных судов, выполняющих полеты по правилам полетов по приборам и правилам визуальных полетов. Воздушные суда, выполняющие полеты по правилам визуальных полетов, эшелонируются относительно воздушных судов, выполняющих полеты по правилам полетов по приборам, и получают информацию о движении в отношении других воздушных судов, выполняющих полеты по правилам визуальных полетов. Для воздушных судов, выполняющих полеты по правилам визуальных полетов, на высотах ниже 3050 м действует ограничение по скорости, составляющее не более 450 км/ч. Наличие постоянной двухсторонней радиосвязи с органом обслуживания воздушного движения (управления полетами) обязательно. Все полеты выполняются при наличии разрешения на использование воздушного пространства, за исключением случаев, предусмотренных пунктом 114 настоящих Федеральных правил	t	f	1	6255
490	максимальный взлетный вес которого составляет менее 3500 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 2300 килограмм	f	f	2	6307
537	только номер эшелона FL	f	f	1	7113
472	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Воздушные суда, выполняющие полеты по правилам визуальных полетов, эшелонируются относительно воздушных судов, выполняющих полеты по правилам полетов по приборам, и получают информацию о движении в отношении других воздушных судов, выполняющих полеты по правилам визуальных полетов. Для воздушных судов, выполняющих полеты по правилам визуальных полетов, на высотах ниже 3050 м действует ограничение по скорости, составляющее не более 450 км/ч. Наличие постоянной двухсторонней радиосвязи с органом обслуживания воздушного движения (управления полетами) обязательно. Все полеты выполняются при наличии разрешения на использование воздушного пространства, за исключением случаев, предусмотренных пунктом 114 настоящих Федеральных правил	f	f	2	6256
472	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Воздушные суда, выполняющие полеты по правилам полетов по приборам, эшелонируются относительно других воздушных судов, выполняющих полеты по правилам полетов по приборам и правилам визуальных полетов. Воздушные суда, выполняющие полеты по правилам визуальных полетов, эшелонируются относительно воздушных судов, выполняющих полеты по правилам полетов по приборам, и получают информацию о движении в отношении других воздушных судов, выполняющих полеты по правилам визуальных полетов. Для воздушных судов, выполняющих полеты по правилам визуальных полетов, на высотах ниже 3050 м действует ограничение по скорости, составляющее не более 450 км/ч. Все полеты выполняются при наличии разрешения на использование воздушного пространства, за исключением случаев, предусмотренных пунктом 114 настоящих Федеральных правил	f	f	3	6257
473	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Эшелонирование воздушных судов не производится. Все полеты по запросу обеспечиваются полетно-информационным обслуживанием. Для всех полетов на высотах ниже 3050м действует ограничение по скорости, составляющее не более 450 км/ч. Воздушные суда, выполняющие полеты по правилам полетов по приборам, обязаны иметь постоянную двухстороннюю радиосвязь с органом обслуживания воздушного движения (управления полетами). При полетах воздушных судов по правилам визуальных полетов наличие постоянной двухсторонней радиосвязи с органом обслуживания воздушного движения (управления полетами) не требуется. При выполнении всех полетов воздушных судов наличие разрешения на использование воздушного пространства обязательно	f	f	1	6258
473	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Эшелонирование воздушных судов не производится. Все полеты по запросу обеспечиваются полетно-информационным обслуживанием. Для всех полетов на высотах ниже 3050м действует ограничение по скорости, составляющее не более 450 км/ч. Воздушные суда, выполняющие полеты по правилам полетов по приборам, обязаны иметь постоянную двухстороннюю радиосвязь с органом обслуживания воздушного движения (управления полетами). При полетах воздушных судов по правилам визуальных полетов наличие постоянной двухсторонней радиосвязи с органом обслуживания воздушного движения (управления полетами) не требуется. При выполнении всех полетов воздушных судов наличие разрешения на использование воздушного пространства не требуется	t	f	2	6259
473	выполняемые по правилам полетов по приборам и правилам визуальных полетов. Эшелонирование воздушных судов не производится. Все полеты обеспечиваются полетно-информационным обслуживанием. Для всех полетов на высотах ниже 3050м действует ограничение по скорости, составляющее не более 450 км/ч. Воздушные суда, выполняющие полеты по правилам полетов по приборам, обязаны иметь постоянную двухстороннюю радиосвязь с органом обслуживания воздушного движения (управления полетами). При полетах воздушных судов по правилам визуальных полетов наличие постоянной двухсторонней радиосвязи с органом обслуживания воздушного движения (управления полетами) не требуется. При выполнении всех полетов воздушных судов наличие разрешения на использование воздушного пространства не требуется	f	f	3	6260
490	максимальный взлетный вес которого составляет менее 2700 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 1800 килограмм	f	f	3	6308
1455	10-20 м	f	f	1	7581
474	10км (по 5км в обе стороны от оси воздушной трассы) - при использовании системы наблюдения обслуживания воздушного движения; 20 км (по 10км в обе стороны от оси воздушной трассы) - без использования системы наблюдения обслуживания воздушного движения. Расстояние между границами параллельных воздушных трасс в горизонтальной плоскости при использовании системы наблюдения обслуживания воздушного движения должно быть не менее 20км, а без использования системы наблюдения обслуживания воздушного движения - не менее 40км	t	f	1	6261
474	15км (по 7,5км в обе стороны от оси воздушной трассы) - при использовании системы наблюдения обслуживания воздушного движения; 20 км (по 10км в обе стороны от оси воздушной трассы) - без использования системы наблюдения обслуживания воздушного движения. Расстояние между границами параллельных воздушных трасс в горизонтальной плоскости при использовании системы наблюдения обслуживания воздушного движения должно быть не менее 20км, а без использования системы наблюдения обслуживания воздушного движения - не менее 40км	f	f	2	6262
474	10км (по 5км в обе стороны от оси воздушной трассы) - при использовании системы наблюдения обслуживания воздушного движения; 20 км (по 10км в обе стороны от оси воздушной трассы) - без использования системы наблюдения обслуживания воздушного движения. Расстояние между границами параллельных воздушных трасс в горизонтальной плоскости при использовании системы наблюдения обслуживания воздушного движения должно быть не менее 10км, а без использования системы наблюдения обслуживания воздушного движения - не менее 20км	f	f	3	6263
475	на удалении до 30 км, а вне полос воздушных подходов - до 15 км от контрольной точки аэродрома объекты выбросов (размещения) отходов, животноводческие фермы, скотобойни и другие объекты, способствующие привлечению и массовому скоплению птиц	t	f	1	6264
475	на удалении до 20 км, а вне полос воздушных подходов - до 15 км от контрольной точки аэродрома объекты выбросов (размещения) отходов, животноводческие фермы, скотобойни и другие объекты, способствующие привлечению и массовому скоплению птиц	f	f	2	6265
475	на удалении до 30 км, а вне полос воздушных подходов - до 20 км от контрольной точки аэродрома объекты выбросов (размещения) отходов, животноводческие фермы, скотобойни и другие объекты, способствующие привлечению и массовому скоплению птиц	f	f	3	6266
476	300 м - до эшелона полета 12500 м (эшелона полета 410); 600 м - выше эшелона полета 12500 м (эшелона полета 410).»	t	f	1	6267
476	300 м - до эшелона полета 11500 м (эшелона полета 400); 600 м - выше эшелона полета 11500 м (эшелона полета 410).»	f	f	2	6268
476	300 м - до эшелона полета 11500 м (эшелона полета 400); 500 м - выше эшелона полета 11500 м (эшелона полета 400).»	f	f	3	6269
477	не менее 200 м	f	f	1	6270
477	не менее 300 м	t	f	2	6271
477	не менее 400 м	f	f	3	6272
478	отражения воздушного нападения или вооруженного вторжения на территорию РФ; предотвращения и пресечения нарушений государственной границы РФ, защиты и охраны экономических и иных законных интересов РФ в пределах приграничной полосы, исключительной экономической зоны и континентального шельфа РФ; пресечения и раскрытия преступлений; поиска и спасания пассажиров и экипажей воздушных судов, терпящих или потерпевших бедствие, поиска и эвакуации с места посадки космонавтов и спускаемых космических объектов или их аппаратов; предотвращения и пресечения нарушений порядка использования воздушного пространства	f	f	1	6273
478	отражения воздушного нападения или вооруженного вторжения на территорию РФ; предотвращения и пресечения нарушений государственной границы РФ, защиты и охраны экономических и иных законных интересов РФ в пределах приграничной полосы, исключительной экономической зоны и континентального шельфа РФ; пресечения и раскрытия преступлений; оказания помощи при чрезвычайных ситуациях природного и техногенного характера; поиска и спасания пассажиров и экипажей воздушных судов, терпящих или потерпевших бедствие, поиска и эвакуации с места посадки космонавтов и спускаемых космических объектов или их аппаратов; предотвращения и пресечения нарушений порядка использования воздушного пространства	t	f	2	6274
491	право на передвижение в воздушном пространстве РФ	f	f	1	6309
491	национальную принадлежность Российской Федерации	t	f	2	6310
478	отражения воздушного нападения или вооруженного вторжения на территорию РФ; предотвращения и пресечения нарушений государственной границы, защиты и охраны экономических и иных законных интересов РФ в пределах приграничной полосы, исключительной экономической зоны и континентального шельфа РФ; пресечения и раскрытия преступлений; оказания помощи при чрезвычайных ситуациях природного и техногенного характера; поиска и спасания пассажиров и экипажей воздушных судов, терпящих или потерпевших бедствие, поиска и эвакуации с места посадки космонавтов и спускаемых космических объектов или их аппаратов	f	f	3	6275
479	для пользователей воздушного пространства, чья деятельность не связана с выполнением полетов воздушных судов и осуществляется на основании планов использования воздушного пространства (графиков) во всем воздушном пространстве РФ; для пользователей воздушного пространства, выполняющих полеты в воздушном пространстве классов А и С, а также в воздушном пространстве класса G - для полетов беспилотных летательных аппаратов	t	f	1	6276
479	для пользователей воздушного пространства, чья деятельность не связана с выполнением полетов воздушных судов и осуществляется на основании планов использования воздушного пространства (графиков) во всем воздушном пространстве РФ; для пользователей воздушного пространства, выполняющих полеты в воздушном пространстве классов А и С, а также в воздушном пространстве класса G - для полетов лёгких летательных аппаратов	f	f	2	6277
479	для пользователей воздушного пространства, чья деятельность не связана с выполнением полетов воздушных судов и осуществляется на основании планов использования воздушного пространства (графиков) во всем воздушном пространстве РФ; для пользователей воздушного пространства, выполняющих полеты в воздушном пространстве классов А и С, а также в воздушном пространстве класса G - для полетов сверхлёгких летательных аппаратов	f	f	3	6278
481	Единым центром единой системы	f	f	1	6279
481	Главным центром единой системы	t	f	2	6280
481	Местным центром единой системы	f	f	3	6281
482	3 часа	f	f	1	6282
482	не менее 3 часов, но не более суток	f	f	2	6283
482	не более 3 часов	t	f	3	6284
483	Министерством обороны Российской Федерации и Федеральным агентством воздушного транспорта	f	f	1	6285
483	Федеральным агентством воздушного транспорта, органами обслуживания воздушного движения (управления полетами) в установленных для них зонах и районах	t	f	2	6286
483	Министерством внутренних дел Российской Федерации и Федеральным агентством воздушного транспорта	f	f	3	6287
484	Министерством обороны РФ	t	f	1	6288
484	Министерством обороны и Министерством внутренних дел РФ	f	f	2	6289
484	Федеральной службой безопасности, Министерством обороны и Министерством внутренних дел РФ	f	f	3	6290
485	применяются правила Российского законодательства	f	f	1	6291
485	применяются правила международного договора	t	f	2	6292
485	применяются указы Президента РФ	f	f	3	6293
486	предотвращение и прекращение нарушений федеральных правил использования воздушного пространства	t	f	1	6294
486	выполнение полетов воздушных судов или иная деятельность по использованию воздушного пространства, осуществляемые в целях удовлетворения потребностей граждан	f	f	2	6295
486	осуществление регулярных воздушных перевозок пассажиров и багажа	f	f	3	6296
487	установленном указами Президента Российской Федерации	f	f	1	6297
487	установленном Правительством Российской Федерации	t	f	2	6298
487	установленном сообщением NOTAM на сайте ЗЦ ЕС ОрВД РФ	f	f	3	6299
488	гражданскую, военную и ведомственную авиацию	f	f	1	6300
488	гражданскую, государственную и экспериментальную авиацию	t	f	2	6301
488	гражданскую, общего назначения и специальную авиацию	f	f	3	6302
489	к коммерческой авиации	f	f	1	6303
489	к авиации общего назначения	f	f	2	6304
489	к гражданской авиации	t	f	3	6305
490	максимальный взлетный вес которого составляет менее 5700 килограмм, в том числе вертолет, максимальный взлетный вес которого составляет менее 3100 килограмм	t	f	1	6306
1423	118-136 МГц	t	f	2	6901
1423	136-174 МГц	f	f	3	6902
491	право на передвижение в воздушном пространстве всех государств, связанных с РФ соглашениями ИКАО	f	f	3	6311
492	сертификата (аттестата о годности к эксплуатации) фирмы производителя воздушного судна	f	f	1	6312
492	сертификата типа (аттестата о годности к эксплуатации) или акта оценки конкретного воздушного судна на соответствие конкретного воздушного судна требованиям к летной годности гражданских воздушных судов и природоохранным требованиям	t	f	2	6313
492	международного сертификата (аттестата о годности к эксплуатации) воздушного судна	f	f	3	6314
493	в военное время и (или) при введении военного, чрезвычайного положения	t	f	1	6315
493	Решением старшего авиационного начальника на аэродроме(посадочной площадке)	f	f	2	6316
493	Решением административной комиссии Федерального агентства воздушного транспорта (Росавиации)	f	f	3	6317
494	только в сертифицированных АУЦ, внесенных в реестр АУЦ Федерального агенства воздушного транспорта (Росавиации)	f	f	1	6318
494	в порядке индивидуальной подготовки у лица, имеющего свидетельство с внесенной в него записью о праве проведения такой подготовки	t	f	2	6319
494	только в летных училищах ГА РФ	f	f	3	6320
495	лицо, имеющее действующее свидетельство об окончании АУЦ или диплом летного училища	f	f	1	6321
495	лицо, имеющее действующее свидетельство пилота (летчика) любого государства, присоединившегося к Чикагской конвенции о международной гражданской авиации 1944 года	f	f	2	6322
495	лицо, имеющее действующее свидетельство пилота (летчика), а также подготовку и опыт, необходимые для самостоятельного управления воздушным судном определенного типа	t	f	3	6323
496	должен выполняться на высоте, позволяющей в случае неисправности воздушного судна произвести посадку за пределами населенных пунктов или на специально предусмотренных для этих целей взлетно-посадочных площадках в пределах населенных пунктов	t	f	1	6324
496	должен выполняться на высоте, не менее минимальной безопасной для данного района полетов	f	f	2	6325
496	должен выполняться на высоте не менее 150 метров над рельефом местности	f	f	3	6326
497	полет воздушного судна с пересечением государственной границы РФ	f	f	1	6327
497	полет воздушного судна в воздушном пространстве более чем одного государства	t	f	2	6328
497	полет воздушного судна в воздушном пространстве иностранного государства	f	f	3	6329
498	самодеятельные поисково-спасательные отряды и пилоты любители	f	f	1	6330
498	поисковые и аварийно-спасательные силы и средства авиационных предприятий и организаций государственной и экспериментальной авиации	t	f	2	6331
498	отряды волонтеров-спасателей некоммерческих организаций и владельцы частных воздушных судов АОН	f	f	3	6332
499	может осуществлять функции командира или второго пилота воздушного судна соответствующего вида и типа (класса), занятого в коммерческих воздушных перевозках	f	f	1	6333
499	может осуществлять функции командира или второго пилота воздушного судна соответствующего вида и типа (класса), не занятого в коммерческих воздушных перевозках	t	f	2	6334
499	может осуществлять функции командира или второго пилота воздушного судна соответствующего вида и типа (класса), занятого в любых воздушных перевозках	f	f	3	6335
500	иметь действующее медицинское заключение, выданное в соответствии с требованиями ИКАО	f	f	1	6336
500	иметь разрешение, выдаваемое уполномоченным органом, которое является неотъемлемой частью свидетельства	t	f	2	6337
500	иметь действующее медицинское заключение, выданное в соответствии с требованиями Федеральных авиационных правил и отметку в свидетельстве о сроках его действия	f	f	3	6338
501	КВС имеет достоверную информацию о ней, полученную от друзей или знакомых	f	f	1	6339
501	она осмотрена с земли или с воздуха и признана КВС безопасной для посадки	f	f	2	6340
501	она осмотрена с земли или с воздуха и признана удовлетворяющей требованиям РЛЭ	t	f	3	6341
502	выполнить полет до вертодрома назначения и затем продолжить его на запланированной крейсерской скорости в течение 10 минут	f	f	1	6342
1455	20-30 м	f	f	2	7582
502	выполнить полет до вертодрома назначения и затем продолжить его на запланированной крейсерской скорости в течение 20 минут	t	f	2	6343
502	выполнить полет до вертодрома назначения и затем продолжить его на запланированной крейсерской скорости в течение 30 минут	f	f	3	6344
503	предписанных уполномоченным органом фирмы производителя воздушного судна	f	f	1	6345
503	предписанных уполномоченным органом государства регистрации воздушного судна	t	f	2	6346
503	предписанных РЛЭ воздушного судна	f	f	3	6347
504	магнитный компас, хронометр или часы, указывающие время в часах, минутах и секундах, барометрический высотомер, указатель приборной воздушной скорости	t	f	1	6348
504	магнитный компас, хронометр или часы, указывающие время в часах, минутах и секундах, барометрический высотомер, указатель приборной воздушной скорости, авиагоризонт, указатель оборотов двигателя, указатель температуры силовой установки, исправная радиостанция авиационного диапазона	f	f	2	6349
504	магнитный компас, хронометр или часы, указывающие время в часах, минутах и секундах, исправный навигатор GPS c подключенным питанием, барометрический высотомер, указатель приборной воздушной скорости,	f	f	3	6350
505	днем при видимости не менее 1000 м для самолетов и не менее 500 м для вертолетов	f	f	1	6351
505	днем при видимости не менее 3000 м для самолетов и не менее 2000 м для вертолетов	f	f	2	6352
505	днем при видимости не менее 2000 м для самолетов и не менее 1000 м для вертолетов	t	f	3	6353
506	расстояние по вертикали от облаков до воздушного судна не менее 300 м; в случае полета между слоями облачности расстояние между слоями не менее 1000 м; видимость в полете не менее 5000 м	t	f	1	6354
506	расстояние по вертикали от облаков до воздушного судна не менее 100 м; в случае полета между слоями облачности расстояние между слоями не менее 500 м; видимость в полете не менее 2000 м	f	f	2	6355
506	расстояние по вертикали от облаков до воздушного судна не менее 500 м; в случае полета между слоями облачности расстояние между слоями не менее 2000 м; видимость в полете не менее 10000 м	f	f	3	6356
507	ниже 50 м над поверхностью земли и ближе 200 м по горизонтали от препятствия	f	f	1	6357
507	ниже 100 м над поверхностью земли и ближе 150 м по горизонтали от препятствия	t	f	2	6358
507	ниже 150 м над поверхностью земли и ближе 100 м по горизонтали от препятствия	f	f	3	6359
508	ночью в равнинной и холмистой местности - ниже 100 м над любым препятствием в пределах горизонтального радиуса 1000 м от препятствия, а в горной местности - ниже 300 м над любым препятствием в пределах горизонтального радиуса 2000 м от препятствия	f	f	1	6360
508	ночью в равнинной и холмистой местности - ниже 300 м над любым препятствием в пределах горизонтального радиуса 8000 м от препятствия, а в горной местности - ниже 600 м над любым препятствием в пределах горизонтального радиуса 8000 м от препятствия	t	f	2	6361
508	запрещается выполнять полет воздушного судна по ПВП ночью	f	f	3	6362
509	имеющего низкий уровень испарения (реактивное топливо)	t	f	1	6363
509	имеющего высокий уровнем испарения (авиационный бензин)	f	f	2	6364
509	Любым	f	f	3	6365
510	нижнее и верхнее воздушное пространство	t	f	1	6366
510	класс-А; класс-C; класс-G	f	f	2	6367
510	класс-C; класс-G	f	f	3	6368
511	нижнее и верхнее воздушное пространство	f	f	1	6369
511	класс-C; класс-G	f	f	2	6370
511	класс-А; класс-C; класс-G	t	f	3	6371
512	ниже эшелона перехода	t	f	1	6372
512	выше минимальной безопасной высоты района полетов	f	f	2	6373
512	ниже нижнего эшелона полетов	f	f	3	6374
513	вертикальный интервал должен быть не менее 50 м при продольном интервале не менее 2 км	f	f	1	6375
513	вертикальный интервал должен быть не менее 100 м при продольном интервале не менее 3 км	f	f	2	6376
513	вертикальный интервал должен быть не менее 150 м при продольном интервале не менее 5 км	t	f	3	6377
514	Разрешительным или запретительным	f	f	1	6378
514	Разрешительным или уведомительным	t	f	2	6379
514	обязательным и не обязательным	f	f	3	6380
515	для полетов беспилотных летательных аппаратов	t	f	1	6381
1452	одинаково для обоих аэростатов	f	f	3	7574
515	для полетов беспилотных и сверхлегких летательных аппаратов	f	f	2	6382
515	для полетов летательных аппаратов, не зарегистрированных в установленном порядке на территории РФ	f	f	3	6383
516	предоставление пользователям воздушного пространства возможности выполнения полетов без уведомления Зонального центра посредством ФПЛ	f	f	1	6384
516	предоставление пользователям воздушного пространства возможности выполнения полетов без получения диспетчерского разрешения	t	f	2	6385
516	предоставление пользователям воздушного пространства возможности выполнения полетов без диспетчерского сопровождения и без двусторонней радиосвязи	f	f	3	6386
517	в воздушном пространстве класса G и в воздушном пространстве класса С ниже нижнего эшелона полетов района ОВД	f	f	1	6387
517	в воздушном пространстве класса G	t	f	2	6388
517	в любом воздушном пространстве, кроме воздушного пространства класса С	f	f	3	6389
518	уведомляют соответствующие органы обслуживания воздушного движения (управления полетами) о своей деятельности в целях организации контроля органами ОВД за их перемещениями в воздушном пространстве РФ	f	f	1	6390
518	уведомляют соответствующие органы обслуживания воздушного движения (управления полетами) о своей деятельности в целях получения полетно-информационного обслуживания и аварийного оповещения	t	f	2	6391
518	не уведомляют соответствующие органы обслуживания воздушного движения (управления полетами) о своей деятельности в целях сохранения её конфиденциальности	f	f	3	6392
519	выполнение полетов беспилотным летательным аппаратом в воздушном пространстве классов C и G	f	f	1	6393
519	выполнение полетов воздушных судов литера «A»	t	f	2	6394
519	выполнение полетов на проверку боевой готовности сил и средств противовоздушной обороны	f	f	3	6395
520	выполнение полетов беспилотным летательным аппаратом в воздушном пространстве классов C и G	t	f	1	6396
520	выполнение полетов воздушных судов для обеспечения специальных международных договоров Российской Федерации	f	f	2	6397
520	проведение учений, воздушных парадов и показов авиационной техники, а также осуществление иной деятельности, которая может представлять угрозу безопасности использования воздушного пространства (радиоизлучения, световые и электромагнитные излучения и т.п.)	f	f	3	6398
521	K0018 М0250	f	f	1	6399
521	K0180 М0025	t	f	2	6400
521	K180 М250	f	f	3	6401
522	DEST(ДЕСТ)	f	f	1	6402
522	DEP(ДЕП)	t	f	2	6403
522	DOF(ДОФ)	f	f	3	6404
523	DEST(ДЕСТ)	t	f	1	6405
523	DEP(ДЕП)	f	f	2	6406
523	DOF(ДОФ)	f	f	3	6407
524	DEST(ДЕСТ)	f	f	1	6408
524	DEP(ДЕП)	f	f	2	6409
524	DOF(ДОФ)	t	f	3	6410
525	23	t	f	1	6411
525	8	f	f	2	6412
525	HUM	f	f	3	6413
526	основные точки или четырехбуквенные обозначения (индексы) районов Единой системы и нарастающее расчетное истекшее время с момента взлета до таких точек или границ районов ответственности	t	f	1	6414
526	районы полетной информации, через которые выполняется полет (в хронологической последовательности), и расчетное истекшее время до пролета (пересечения) их границ	f	f	2	6415
526	четырехбуквенные обозначения (индексы) районов аэродромов(аэроузлов) пересекаемых в процессе выполнения полета по маршруту, указанному в поле 13 ФПЛ и нарастающее расчетное истекшее время с момента взлета до границ районов	f	f	3	6416
527	название и местоположение аэродрома вылета, если в поле 13 вставлено ZZZZ	f	f	1	6417
527	название и местоположение аэродрома назначения, если в поле 16 вставлено ZZZZ	f	f	2	6418
527	название запасного(ых) аэродрома(ов) пункта назначения, если в поле 16 вставлено ZZZZ	t	f	3	6419
528	М(М)	f	f	1	6420
528	N(Н)	f	f	2	6421
528	G(Г)	t	f	3	6422
529	от 5 суток до 1-го часа	t	f	1	6423
529	от 1-х суток до 30-ти минут	f	f	2	6424
529	не менее чем за 20 минут до времени вылета	f	f	3	6425
530	от 5 суток до 3-го часа	t	f	1	6426
530	от 3-х суток до 1-го часа	f	f	2	6427
530	не менее чем за 1-ни сутки до времени вылета	f	f	3	6428
531	не менее чем за 30 минут до времени вылета	t	f	1	6429
531	от 3-х суток до 1-го часа	f	f	2	6430
531	не менее чем за 1 час до времени вылета	f	f	3	6431
532	установление системы маршрутов полетов воздушных судов по фиксированным траекториям внутри зон УВД/районов полетной информации	f	f	1	6432
532	выполнение полета по согласованному с органом УВД маршруту в пределах зоны ответственности наземного диспетчера	f	f	2	6433
532	метод навигации, позволяющий выполнять полеты по любой желаемой траектории	t	f	3	6434
534	20 км/ч	f	f	1	6435
534	15 kt	f	f	2	6436
534	5%	t	f	3	6437
561	3	t	f	1	6438
561	8	f	f	2	6439
561	5	f	f	3	6440
562	катастрофам	t	f	1	6441
562	авариям	f	f	2	6442
562	чрезвычайным происшествиям	f	f	3	6443
563	ПРАПИ-98	f	f	1	6444
563	РПП АК	t	f	2	6445
563	Приложение 13 ИКАО «Расследование авиационных событий»	f	f	3	6446
564	кучево-дождевые облака	t	f	1	6447
564	грозовое положение	f	f	2	6448
564	гроза внутримассовая	f	f	3	6449
565	изолированная	t	f	1	6450
565	редкая	f	f	2	6451
565	замаскированная	f	f	3	6452
566	достаточно разделенные	t	f	1	6453
566	отдельная	f	f	2	6454
566	замаскированная	f	f	3	6455
567	с небольшим разделением или без разделения (частые)	t	f	1	6456
567	редкая	f	f	2	6457
567	замаскированная	f	f	3	6458
568	достаточно разделенные	f	f	1	6459
568	редкие	f	f	2	6460
568	содержащиеся в слоях других облаков или скрытые мглой (включенные)	t	f	3	6461
569	к увеличению	f	f	1	6462
569	к уменьшению	t	f	2	6463
569	без изменения	f	f	3	6464
570	прогноз изменен	t	f	1	6465
570	прогноз продлен	f	f	2	6466
570	прогноз, содержащий улучшение погоды	f	f	3	6467
571	5-7 октантов	f	f	1	6468
571	8 октантов	t	f	2	6469
571	более 7 октантов	f	f	3	6470
572	2000м	f	f	1	6471
572	400 м	f	f	2	6472
572	более 10 км	t	f	3	6473
601	равный 4-6 м/с и более на 30 м. высоты	t	f	1	6474
601	равный 2-4 м/с и более на 30 м. высоты	f	f	2	6475
601	равный 0-2 м/с и более на 30 м. высоты	f	f	3	6476
602	фронтальные разделы, развитие конвективных облаков, инверсионные слои, другие местные особенности	f	t	1	6477
602	наличие ветра и облачности	f	f	2	6478
602	наличие облачности, осадков, ветра	f	f	3	6479
612	менее чем 1000м	t	f	1	6480
612	от 500м до 1500м	f	f	2	6481
612	от 1000м до 3000м	f	f	3	6482
614	информация является повторением предыдущего сообщения	t	f	1	6483
614	информация дана для всех ВПП	f	f	2	6484
614	данные отсутствуют	f	f	3	6485
753	CRM	f	f	1	6486
753	Ситуационная осведомлённость (ведение осмотрительности)	f	t	2	6487
753	ADM (Принятие решений)	f	f	3	6488
754	Управление рисками	f	f	1	6489
754	Принятие решение (ADM)	f	f	2	6490
754	Стресс	t	f	3	6491
802	Как минимум 2 фута в секунду	f	f	1	6492
802	Такой же, как у соседнего нисходящего потока	f	f	2	6493
802	Такой же по скорости, как и скорость снижения планера	f	t	3	6494
803	Сразу после восхода солнца	f	f	1	6495
803	В утреннее время	f	f	2	6496
803	После полудня	f	t	3	6497
804	Только волновые	f	f	1	6498
804	Волновые и динамические	f	f	2	6499
804	Термические, динамические, волновые	f	t	3	6500
805	Планер более скоростной	f	f	1	6501
805	Это добавляет поперечной устойчивости планеру	t	f	2	6502
805	Позволяет планеру садиться на площадки	f	f	3	6503
811	Снизить скорость	f	t	1	6504
811	Использовать триммер	f	f	2	6505
811	Выполнить разворот против ветра	f	f	3	6506
813	Планер	t	f	1	6507
813	Вертолёт	f	f	2	6508
813	Самолёт	f	f	3	6509
824	расстояние от земной (водной) поверхности до ВС	f	f	1	6510
824	расстояние по вертикали от начального уровня ее отсчета до ВС	t	f	2	6511
824	расстояние по вертикали от максимального препятствия до ВС	f	f	3	6512
825	высота полета над условно выбранным уровнем (уровнем аэродрома, цели и др.)	t	f	1	6513
825	высота полета над определённым уровнем (уровнем аэродрома, цели и др.)	f	f	2	6514
1455	40-80 м	f	t	3	7583
825	высота полета над условно выбранным уровнем препятствия (уровнем аэродрома, цели и др.)	f	f	3	6515
826	высота полета над земной (водной) поверхностью	f	f	1	6516
826	высота полета над препятствием	f	f	2	6517
826	высота полета над уровнем моря	t	f	3	6518
827	высота, отсчитываемая от уровня, который соответствует атмосферному давлению 760 ммРт.ст., в предположении, что распределение температуры с высотой соответствует стандартным условиям	t	f	1	6519
827	высота, отсчитываемая от уровня, который соответствует атмосферному давлению 1050М , в предположении, что распределение температуры с высотой соответствует стандартным условиям	f	f	2	6520
827	высота, отсчитываемая от уровня моря, который соответствует атмосферному давлению 1050М по стандартному атмосферному давлению, в предположении, что распределение температуры с высотой соответствует стандартным условиям	f	f	3	6521
828	это фактическая скорость, с которой ВС движется относительно воздушной среды с учётом ветра	f	f	1	6522
828	это фактическая скорость, с которой ВС движется относительно земной (водной) поверхностью	f	f	2	6523
828	это фактическая скорость, с которой ВС движется относительно воздушной среды	t	f	3	6524
829	скорость, которую показывает прибор, измеряющий воздушную скорость	t	f	1	6525
829	скорость, которую показывает прибор с учётом аэродинамической и барометрической поправки	f	f	2	6526
829	скорость, которую показывает прибор с учётом аэродинамической, барометрической и температурной поправки	f	f	3	6527
830	угол в горизонтальной плоскости между выбранным опорным направлением и проекцией на эту плоскость продольной оси ВС	t	f	1	6528
830	угол в горизонтальной плоскости между Северным направлением истинного меридиана и проекцией на эту плоскость продольной оси ВС	f	f	2	6529
830	угол в горизонтальной плоскости между выбранным опорным направлением и линией заданного пути ВС	f	f	3	6530
831	0 до 360° в зависимости от курса ВС со знаком «плюс», против хода часовой стрелки — со знаком «минус»	f	f	1	6531
831	0 до 180° по ходу часовой стрелки со знаком «плюс», против хода часовой стрелки — со знаком «минус»	t	f	2	6532
831	0 до 160° по ходу часовой стрелки	f	f	3	6533
832	скорость горизонтального перемещения воздушных масс относительно земной поверхности	t	f	1	6534
832	скорость вертикального и горизонтального перемещения воздушных масс относительно земной поверхности	f	f	2	6535
832	скорость перемещения воздушных масс относительно земной (водной) поверхности	f	f	3	6536
833	угол в горизонтальной плоскости, заключенный между тем же опорным направлением, от которого измеряется курс, и вектором ветра	t	f	1	6537
833	угол в горизонтальной плоскости, заключенный между продольной осью ВС и вектором ветра	f	f	2	6538
833	угол в горизонтальной плоскости, заключенный между тем же опорным направлением, от которого измеряется курс, и вектором ветра отсчитываемым от 0 до 180 град.	f	f	3	6539
834	скорость перемещения ВС относительно земной поверхности	t	f	1	6540
834	приборная скорость с учётом скорости ветра	f	f	2	6541
834	истинная скорость с учётом скорости ветра, измеряемая в узлах, милях на километр, в километрах в час	f	f	3	6542
835	угол, заключенный между векторами воздушной и путевой скоростью ветра	f	f	1	6543
835	угол, заключенный между векторами скорости ветра и путевой скоростей	f	f	2	6544
835	угол, заключенный между векторами воздушной и путевой скоростей	t	f	3	6545
836	это минимальная высота, гарантирующая ВС от столкновения его с земной (водной) поверхностью и расположенными на ней препятствиями	t	f	1	6546
836	это минимальная высота, гарантирующая ВС выполнение посадки с учётом расположенными препятствиями на земле с учётом температурной, барометрической и аэродинамической поправок	f	f	2	6547
836	это минимальная высота, гарантирующая ВС от столкновения его с земной (водной) поверхностью с учётом рельефа местности	f	f	3	6548
837	эллипса	f	f	1	6549
837	шара	f	f	2	6550
837	геоида	t	f	3	6551
1463	любые источники получения информации	f	f	1	6903
1453	усилие уменьшится	f	f	1	7575
1209	В случае отказа в работе режима «RBS» обслуживание осуществляется путем передачи органами ОВД экипажам диспетчерских указаний, рекомендаций и информации	f	f	1	6552
1209	По указанию органа ОВД обслуживание осуществляется с использованием режима «УВД»	t	f	2	6553
1209	Полёты осуществляются в режиме полётно-информационного обслуживания	f	f	3	6554
1210	Правила подготовки ВС и его экипажа к полету, обеспечения и выполнения полетов в ГА и аэронавигационного обслуживания полетов в РФ	f	f	1	6555
1210	Порядок использования воздушного пространства (ВП) РФ в интересах экономики и обороны страны, в целях удовлетворения потребностей его пользователей, обеспечения безопасности использования ВП	t	f	2	6556
1210	Правила подготовки ВС и его экипажа к полету, выполнения полетов в ГА на основе нормативных актов, регулирующих использование воздушного пространства РФ	f	f	3	6557
1211	Это обслуживание воздушного движения в целях оптимизации воздушного пространства в соответствии с государственными приоритетами использования воздушного пространства	f	f	1	6558
1211	Это обслуживание (управление) воздушного движения в пределах диспетчерской зоны	f	f	2	6559
1211	Это управление воздушным движением в целях предотвращения столкновений между ВС и ВС с препятствиями, а также в целях регулирования воздушного движения	t	f	3	6560
1212	Это разрешение экипажу ВС на пролет воздушного коридора государственной границы РФ, определенного для выполнения международных полетов	f	f	1	6561
1212	Это разрешение экипажу на ограниченное использование воздушного пространства РФ в отдельных его районах	f	f	2	6562
1212	Это разрешение экипажу действовать в соответствии с условиями, доведенными органом обслуживания воздушного движения (управления полетами)	t	f	3	6563
1213	Это аэродром, на котором обеспечивается диспетчерское обслуживание аэродромного движения вне зависимости от наличия диспетчерской зоны	t	f	1	6564
1213	Это аэродром, на котором гражданские ВС используют воздушное пространство ограниченно с целью обеспечения безопасного выполнения полетов воздушных судов	f	f	2	6565
1213	Это аэродром, на котором существует кратковременное ограничение использования воздушного пространства для обеспечения безопасного выполнения полетов воздушных судов	f	f	3	6566
1214	Это предоставление информации только ВС, оборудованным аппаратурой государственной радиолокационной системы опознавания РФ	f	f	1	6567
1214	Это предоставление консультаций и информации экипажам ВС для обеспечения безопасного и эффективного выполнения полетов	t	f	2	6568
1214	Это предоставление экипажам сведений об аэродромах и средствах радиотехнического обеспечения полетов	f	f	3	6569
1215	20 км (по 10 км в обе стороны от оси воздушной трассы)	f	f	1	6570
1215	10 км (по 5 км в обе стороны от оси) - при использовании системы наблюдения ОВД и 20 км (по 10 км в обе стороны от оси) - без системы наблюдения ОВД	t	f	2	6571
1215	10 км (по 5 км в обе стороны от оси воздушной трассы)	f	f	3	6572
1216	25 км	t	f	1	6573
1216	30 км	f	f	2	6574
1216	Приграничная полоса вдоль государственной границы РФ не устанавливается	f	f	3	6575
1217	500 м	f	f	1	6576
1217	300 м	t	f	2	6577
1217	1000 м	f	f	3	6578
1218	300 м	f	f	1	6579
1218	150 м - для ВС, выполняющих полеты со скоростью полета 300 км/ч и менее	f	f	2	6580
1218	Не менее 150 м при продольном интервале не менее 5 км – для ВС, выполняющих полеты со скоростью полета 300 км/ч и менее	t	f	3	6581
1219	20 км - с системой опознавания ВС, 10 км - с АС УВД и 5 мин без системы опознавания ВС	f	f	1	6582
1219	30 км - с системой опознавания ВС, 20 км - с АС УВД и 10 мин - без системы опознавания ВС	t	f	2	6583
1219	25 км - с системой опознавания ВС, 15 км - с АС УВД и 7 мин без системы опознавания ВС	f	f	3	6584
1220	40 км - с системой опознавания ВС, 25 км - с АС УВД и 15 мин - без системы опознавания ВС	t	f	1	6585
1220	30 км - с системой опознавания ВС, 20 км - с АС УВД и 10 мин - без системы опознавания ВС	f	f	2	6586
1220	25 км - с системой опознавания ВС, 15 км - с АС УВД и 7 мин - без системы опознавания ВС	f	f	3	6587
1463	только официальные государственные источники получения информации	f	f	2	6904
1221	30 км - с системой опознавания ВС при наличии бокового интервала 10 км, 30 км - с АС УВД с вертикальным интервалом; и 20 мин - без системы опознавания ВС	t	f	1	6588
1221	40 км - с системой опознавания ВС, 25 км - с АС УВД и 15 мин - без системы опознавания ВС	f	f	2	6589
1221	25 км - с системой опознавания ВС, 15 км - с АС УВД и 7 мин - без системы опознавания ВС	f	f	3	6590
1222	30 км - с системой опознавания ВС, 20 км - с АС УВД и 10 мин - без системы опознавания ВС	f	f	1	6591
1222	20 км - с системой опознавания ВС, 10 км - с АС УВД и 10 мин - без системы опознавания ВС	t	f	2	6592
1222	25 км - с системой опознавания ВС, 15 км - с АС УВД и 7 мин - без системы опознавания ВС	f	f	3	6593
1223	Разрешение на выполнение международного полета	f	t	1	6594
1223	Разрешение на использование воздушного пространства	f	f	2	6595
1223	Код опознавания, установленный на пульте управления TCAS	f	f	3	6596
1224	Да	f	f	1	6597
1224	Да, за исключением случаев возникновения на борту ВС аварийной ситуации, требующей немедленного изменения профиля и режима полета	t	f	2	6598
1224	Нет	f	f	3	6599
1225	Федеральные правила полётов, ФП использования воздушного пространства РФ и ФАП «Подготовка и выполнение полётов в ГА РФ»	f	f	1	6600
1225	ВК РФ, федеральные законы, указы Президента, постановления Правительства, ФП использования воздушного пространства, другие ФАП и нормативные правовые акты	t	f	2	6601
1225	Федеральные правила использования воздушного пространства, ФАП и нормативные акты, принимаемые Правительством РФ	f	f	3	6602
1226	Государственный приоритет № 1 перед всеми ВС при использовании воздушного пространства РФ	f	f	1	6603
1226	Перед ВС МЧС и ВС, выполняющими полёты в интересах обороноспособности и безопасности государства	f	f	2	6604
1226	Перед ВС государственной авиации (корме боевых учений и перебазирования); экспериментальными ВС; ВС, выполняющими перевозку грузов и почты, полёты вне расписания, учебные, спортивные и демонстрационные полёты	t	f	3	6605
1227	К коммерческой гражданской авиации	t	f	1	6606
1227	К авиации общего назначения	f	f	2	6607
1227	К авиации общего назначения и к коммерческой гражданской авиации	f	f	3	6608
1228	КВС, имеющий действующее свидетельство пилота, подготовку и опыт для самостоятельного управления ВС и другие лица летного состава	f	f	1	6609
1228	КВС, другие лица летного состава и кабинный экипаж	f	f	2	6610
1228	Только граждане РФ. Иностранный гражданин может включаться только на период подготовки к перевозкам, не исполняя обязанностей КВС	t	f	3	6611
1229	Любые меры принуждения вплоть до применения оружия, если отказываются подчиняться распоряжениям КВС	f	f	1	6612
1229	Необходимые меры принуждения, если создают непосредственную угрозу безопасности полета и отказываются подчиняться распоряжениям КВС	t	f	2	6613
1229	Удалить с ВС и передать правоохранительным органам по прибытии на ближайший аэродром, если совершают деяния с признаками преступления	f	f	3	6614
1230	КВС и экипаж обязаны принять все меры по сохранению жизни людей, сохранности ВС и бортового имущества	t	f	1	6615
1230	КВС руководит действиями лиц на борту, до передачи своих полномочий представителям служб поиска и спасания ВС	f	f	2	6616
1230	КВС обязан принять меры по обеспечению безопасного завершения полета ВС	f	f	3	6617
1231	Оказать помощь, если это не сопряжено с опасностью для ВС, пассажиров и экипажа	f	f	1	6618
1231	Оказать помощь, если это не сопряжено с опасностью для ВС, пассажиров и экипажа, отметить на карте место (зону) бедствия и сообщить об этом органу ОВД	t	f	2	6619
1231	Принять все возможные меры по спасению людей и судна	f	f	3	6620
1232	Судовые документы и документы, предусмотренные уполномоченным органом в области ГА	f	f	1	6621
1232	Перечень документов, устанавливаемый уполномоченным органом в области ГА	f	f	2	6622
1232	Судовые документы, документы членов экипажа и документы, предусмотренные уполномоченным органом ГА РФ	t	f	3	6623
1233	Уведомления соответствующего органа ОВД	f	f	1	6624
1233	Отступление от плана полета ВС не допускается	f	f	2	6625
1463	источники, которые пилот посчитает достоверными	f	t	3	6905
1233	Разрешения органа ОВД, за исключением явной угрозы безопасности полета в целях спасения жизни людей, предотвращения нанесения ущерба окружающей среде	t	f	3	6626
1234	Если ВС или лицам на борту угрожает опасность, неустранимая экипажем, либо ВС, потеряло связь и его местонахождение неизвестно	t	f	1	6627
1234	Если продолжение полета небезопасносно для ВС, экипажа, пассажиров, а своевременное оказание помощи невозможно	f	f	2	6628
1234	Если на борту ВС возникла угроза безопасности полета, в том числе связанная с актом незаконного вмешательства	f	f	3	6629
1235	Которому требуются неотложные меры по спасанию людей, оказанию им медицинской и другой помощи	f	f	1	6630
1235	Получившее при рулении, взлете, полете, посадке или при падении повреждение либо разрушенное или ВС, совершившее вынужденную посадку вне аэродрома	t	f	2	6631
1235	Которое передало сообщение о бедствии и просьбу об оказании помощи людям, находящимся на борту ВС	f	f	3	6632
1236	Орган местного самоуправления, уполномоченные органы в области использования воздушного пространства, в области ГА, в области обороны или оборонной промышленности	f	f	1	6633
1236	Руководство АК, авиапредприятие, на территории которого потерпело бедствие ВС, или уполномоченный орган в области ГА	f	f	2	6634
1236	Орган местного самоуправления, организацию или воинскую часть	t	f	3	6635
1237	Установление виновных лиц и принятие мер по их не допущению к полётам до устранения недостатков, повлекших данное событие	f	f	1	6636
1237	Установление причин АП или инцидента и принятие мер по их предотвращению в будущем	t	f	2	6637
1237	Установление причин АП или инцидента и определение виновных должностных лиц, осуществлявших подготовку экипажа к данному полёту	f	f	3	6638
1238	Сохранить ВС, его части и обломки, носители полётной информации, предметы, находящиеся на борту ВС, документы по эксплуатации ВС и обеспечению его полета	t	f	1	6639
1238	Сохранить ВС, людей, находящихся на борту, а также личные вещи пассажиров и экипажа	f	f	2	6640
1238	Сохранить ВС, бортовые носители полётной информации и полётную документацию	f	f	3	6641
1239	Не менее чем одна тысяча минимальных размеров оплаты труда, установленных федеральным законом на момент заключения договора страхования	t	f	1	6642
1239	Не менее чем двадцать пять тысяч долларов США по курсу Центробанка РФ на момент наступления страхового случая	f	f	2	6643
1239	Не менее чем пять тысяч минимальных размеров оплаты труда, установленных Правительством РФ на момент заключения договора страхования	f	f	3	6644
1240	Полеты по правилам визуальных полетов (именуются как ПВП) и полеты по правилам полетов по приборам (именуются как ППП)	f	f	1	6645
1240	Полёты в визуальных метеорологических условиях и в приборных метеорологических условиях	t	f	2	6646
1240	Полёты в визуальных, в приборных условиях и смешанные, когда взлет и посадка происходят в визуальных, а полёт по трассе - в приборных метеорологических условиях	f	f	3	6647
1241	Не более 10 км от КТА	f	f	1	6648
1241	Не более 25 км от КТА	f	f	2	6649
1241	Не более 50 км от КТА	t	f	3	6650
1242	Чтобы запас высоты над наивысшим препятствием был не менее 300 м	t	f	1	6651
1242	Чтобы истинная высота полета ВС над наивысшим препятствием (запас высоты над препятствием) была не менее 200 м	f	f	2	6652
1242	Чтобы запас высоты над наивысшим препятствием был не менее 100 м при полёте на скоростях 300 км/ч и менее, и не менее 200 м - на скоростях более 300 км/ч	f	f	3	6653
1243	Не менее 300 м	t	f	1	6654
1243	Не менее 600 м	f	f	2	6655
1243	Не менее 900 м	f	f	3	6656
1244	Обгоняющее воздушное судно	f	f	1	6657
1244	Воздушное судно, выполняющее полет на большую дальность	t	f	2	6658
1244	Обгоняемое воздушное судно	f	f	3	6659
1245	Отвернуть воздушные суда вправо для их расхождения левыми бортами	t	f	1	6660
1245	Отвернуть воздушные суда влево, обеспечить их безопасное расхождение	f	f	2	6661
1245	Разойтись так, чтобы не терять другое воздушное судно из вида	f	f	3	6662
1246	Немедленно изменить высоту (эшелон) полета, не покидая воздушной трассы, и сообщить об этом органу ОВД	f	f	1	6663
1456	уменьшается	f	f	1	7584
1246	Не изменяя высоты, отвернуть ВС вправо на 30° от воздушной трассы, сообщить органу ОВД и, пройдя 30 км от оси трассы, взять прежний курс с изменением высоты полета до избранной	t	f	2	6664
1246	Немедленно изменить высоту (эшелон) полета, не покидая воздушной трассы	f	f	3	6665
1247	ВС, справа от которого находится другое воздушное судно	t	f	1	6666
1247	ВС, находящееся справа от другого воздушного судна	f	f	2	6667
1247	ВС, пересекающее магистральную РД	f	f	3	6668
1248	Перечень УКВ-частот аварийной радиосвязи с органами ОВД в воздушном пространстве приграничной полосы	f	f	1	6669
1248	Оборудование системой радиолокационного опознавания «Я свой»	f	f	2	6670
1248	Карту установленного масштаба с обозначенными на ней линией Государственной границы РФ, приграничной полосы и с указанием ограничительных пеленгов	t	f	3	6671
1249	Немедленно сообщить о местонахождении воздушного судна органу ОВД	f	f	1	6672
1249	Прекратить выполнение задания, принять решение о возврате на аэродром вылета или производстве посадки на ближайшем запасном аэродроме с немедленным докладом органу ОВД	t	f	2	6673
1249	Выполнить полёт в сторону от Государственной границы РФ и запросить сопровождение у органа ПВО на соответствующих радиочастотах	f	f	3	6674
1250	Правила подготовки ВС и его экипажа к полету, обеспечения и выполнения полетов в ГА и аэронавигационного обслуживания полетов в РФ	t	f	1	6675
1250	Правила подготовки и выполнения полётов в воздушном пространстве РФ и других стран на основе Международных договоров	f	f	2	6676
1250	Правила подготовки ВС и его экипажа к полету, выполнения полетов в ГА на основе нормативных актов, регулирующих использование воздушного пространства РФ	f	f	3	6677
1251	Федеральные правила использования воздушного пространства РФ	f	f	1	6678
1251	Применяются требования законов и правил этого государства	t	f	2	6679
1251	Применяются Международные правила полётов (ИКАО)	f	f	3	6680
1252	Службу авиационной безопасности (Security) в аэропорту	f	f	1	6681
1252	ПДС (ЦОП) АК и службу авиационной безопасности (САБ) АК	f	f	2	6682
1252	Орган ОВД, а при отсутствии связи с ним - по возможности орган внутренних дел	t	f	3	6683
1253	Если присутствует иней, мокрый снег, лед на крыльях, фюзеляже, органах управления, оперении, лобовом стекле, силовой установке или на ПВД	t	f	1	6684
1253	Если ВС не обработано противообледенительной жидкостью на земле	f	f	2	6685
1253	В условиях сильного обледенения в облаках в районе аэродрома вылета и по маршруту полёта, если иное не сказано в РЛЭ	f	f	3	6686
1254	Соответствующем более 30 мин полета, а для ВС с тремя или более двигателями - 120 мин полета	t	f	1	6687
1254	Превышающем дальность планирования ВС с одним оказавшим двигателем на ВС с двумя двигателями и с двумя оказавшими - на ВС с тремя и более двигателями	f	f	2	6688
1254	На расстоянии соответствующем более 30 мин полета	f	f	3	6689
1255	Экипаж выполняет подготовку ВС к полету в объеме, программы TRANSIT CHECK. Данные работы выполняются экипажами в пределах времени действия DAILY CHECK	f	f	1	6690
1255	Экипаж проводит подготовку ВС к полету с соблюдением процедуры Preflight Inspection, определенной эксплуатационной документацией	t	f	2	6691
1255	Полёт планируется в пределах времени действия DAILY CHECK. Если время действия его не истекло, экипаж никакие работы не выполняет	f	f	3	6692
1256	Неспособности выполнять обязанности из-за телесного повреждения, болезни, утомления, воздействия психоактивного вещества или недостатка кислорода	t	f	1	6693
1256	Неспособности выполнять обязанности вследствие воздействия алкоголя или травмы, или значительного утомления	f	f	2	6694
1256	Неспособности выполнять обязанности по причине того, что считает полёт непосильным для себя или не уверен в безопасности его выполнения	f	f	3	6695
1257	На своих рабочих местах, за исключением периодов покидания для удовлетворения своих естественных потребностей	f	f	1	6696
1257	На своих рабочих местах в течение всего полёта, за исключением покидания на эшелоне для исполнения обязанностей по эксплуатации самолета или удовлетворения естественных потребностей	t	f	2	6697
1570	одинаково	f	f	3	7790
1257	На своих рабочих местах при выполнении взлета и посадки, а в полёте по маршруту - на своих рабочих местах, за исключением периодов покидания для исполнения обязанностей по эксплуатации самолета	f	f	3	6698
1258	При выполнении руления, взлета, захода на посадку, ухода на второй круг и посадки	t	f	1	6699
1258	На протяжении всего полета	f	f	2	6700
1258	На этапах снижения и набора высоты ниже 3000 м	f	f	3	6701
1259	На шкалах давлений барометрических высотомеров устанавливается QNH аэродрома и показания всех высотомеров сравниваются с превышением места взлета	f	f	1	6702
1259	На шкалах давлений барометрических высотомеров устанавливается QFE и показания всех высотомеров сравниваются с отметкой «0» на высотомере	f	f	2	6703
1259	На шкалах давлений барометрических высотомеров устанавливается QFE или QNH аэродрома и показания всех высотомеров сравниваются с отметкой «0» на высотомере при установке QFE или с превышением места взлета при установке QNH аэродрома	t	f	3	6704
1260	Ниже 300 м истинной высоты в радиусе 8000 м от препятствий в равнинной и холмистой местности или ниже 600 м истинной высоты в радиусе 8000 м от препятствий в горной местности	f	f	1	6705
1260	Ниже опубликованной в АНИ минимальной абсолютной высоты полета	t	f	2	6706
1260	Ниже опубликованного в АНИ эшелона перехода	f	f	3	6707
1261	Запросом члена летного экипажа на запуск двигателей ВС, произведенным с целью выполнения полета	t	f	1	6708
1261	Подписью КВС в диспетчерском решении на выполнение полета (Dispatch Release)	f	f	2	6709
1261	Подачей полётным диспетчером диспетчерского решения на выполнение полета (Dispatch Release) органу ОВД	f	f	3	6710
1262	Если не получено разрешение органа ОВД или органа управления движением на перроне	f	f	1	6711
1262	Если давление в тормозах не соответствует норме или не получено разрешение органа ОВД, или не обеспечивается безопасность руления из-за препятствий, неудовлетворительного состояния МС или РД	t	f	2	6712
1262	Если не получено разрешение лица, обеспечивающего выпуск воздушного судна	f	f	3	6713
1263	Менее 600 м без использования бортового радиолокатора и системы заблаговременного предупреждения о сдвиге ветра	t	f	1	6714
1263	Менее 600 м в сильном дожде	f	f	2	6715
1263	Менее 800 м в осадках в виде сильного дождя	f	f	3	6716
1264	Решение о выполнении повторного взлета может быть принято органом ОВД после выяснения и устранения причин, вызвавших прекращение взлета	f	f	1	6717
1264	Решение о выполнении повторного взлета может быть принято КВС после проведения работ, если они предусмотрены в эксплуатационной документации ВС	t	f	2	6718
1264	Решение о выполнении повторного взлета может быть принято экипажем в зависимости от состояния ВС	f	f	3	6719
1265	До высоты, не менее установленной схемой вылета или РЛЭ	t	f	1	6720
1265	До высоты перехода	f	f	2	6721
1265	До высоты над аэродромом не менее 120 м, если иное не установлено РЛЭ	f	f	3	6722
1266	За 600 м до заданного эшелона уменьшить вертикальную скорость набора высоты до 10 м/с, далее за 500 м – до 7,5 м/с, затем за 300 м – до 5 м/с	f	f	1	6723
1266	Не более 7 м/с и сличить показания высотомеров в соответствии с РЛЭ	f	f	2	6724
1266	7 м/с за 300 м до заданного эшелона	t	f	3	6725
1267	Корректирует курс, если ВС отклонилось от линии пути, информирует орган ОВД, если время пролета очередного пункта отличается более чем на 2 минуты от расчётного	t	f	1	6726
1267	Может произвести посадку на ближайшем аэродроме из-за опасных метеорологических явлениях на маршруте	f	f	2	6727
1267	Выполняет полёт по плану, корректируя параметры полета. Если ВС отклонилось от линии пути, корректирует курс для выхода на ЛЗП и информирует об этом орган ОВД	f	f	3	6728
1268	К расчетному времени прилета ВС метеорологические условия на аэродроме посадки должны соответствовать эксплуатационным минимумам аэродрома для посадки	f	f	1	6729
1268	Начиная с места, где было произведено изменение маршрута полета, соблюдаются требования по наличию на борту ВС топлива в количестве достаточном для завершения полёта	t	f	2	6730
1464	градусы, минуту, секунды	f	f	1	6906
1464	градусы, минуты	t	f	2	6907
1464	градусы с десятичными долями	f	f	3	6908
1268	Прогноз погоды на аэродроме назначения ко времени прилета соответствует требованиям для запасного аэродрома и есть техническая готовность аэродрома назначения	f	f	3	6731
1269	Об остатке топлива (в часах), минимуме КВС и выбранном запасном аэродроме	f	f	1	6732
1269	О расчетном времени прибытия на аэродром назначения, минимуме КВС и остатке топлива на ВПР аэродрома назначения	f	f	2	6733
1269	О расчетном времени пролета рубежа ухода и выбранном запасном аэродроме	t	f	3	6734
1270	В момент доворота ВС для выхода на траекторию конечного этапа захода на посадку	t	f	1	6735
1270	В момент получения разрешения на заход на посадку от органа ОВД	f	f	2	6736
1270	В момент возобновления экипажем самостоятельного захода на посадку	f	f	3	6737
1271	Если по прибытию на запасной аэродром остаток топлива меньше, чем на 30 минут полета со скоростью ожидания на абсолютной высоте 450 м в условиях стандартной атмосферы	f	f	1	6738
1271	Если экипаж сообщил органу ОВД о недостаточном остатке топлива для ожидания посадки в порядке общей очереди	f	f	2	6739
1271	Если требуется немедленная посадка	t	f	3	6740
1272	Информации о RVR	t	f	1	6741
1272	Информации о DH	f	f	2	6742
1272	Видимости огней приближения, порога ВПП, входных огней ВПП, огней порога ВПП, визуальной индикации глиссады, огней зоны приземления	f	f	3	6743
1273	При метеорологической видимости менее 600 м без использования бортового радиолокатора и системы предупреждения о сдвиге ветра	t	f	1	6744
1273	Если, по мнению КВС безопасность посадки не гарантируется	f	f	2	6745
1273	Если до установления необходимого визуального контакта с наземными ориентирами система TCAS выдала рекомендацию RA на снижение или набор высоты	f	f	3	6746
1274	Если получена информация, свидетельствующая о несоответствии состояния ВПП ограничениям летно-технических характеристик ВС	f	f	1	6747
1274	Если значение сообщенной метеорологической видимости RVR ниже эксплуатационного минимума для посадки	f	f	2	6748
1274	Если пилот не наблюдает ни одного наземного ориентира в течение времени, достаточного для оценки местоположения ВС и его изменения относительно заданной траектории полета	t	f	3	6749
1275	При достижении высоты 60 м над аэродромом, которая не ниже DA/H	t	f	1	6750
1275	До достижения MDA при заходе по схеме точного захода на посадку	f	f	2	6751
1275	До достижения DA при заходе на посадку с применением визуального маневрирования ("circle-to-land")	f	f	3	6752
1276	Полеты при неблагоприятных атмосферных условиях и полеты в горной местности при безопасной высоте полета 3000 м и более	t	f	1	6753
1276	Полеты в условиях воздействия солнечной космической радиации, полеты по перевозке опасных грузов, учебные и тренировочные полеты	f	f	2	6754
1276	Полеты по ПВП в условиях сложной орнитологической обстановки, полёты по организации поиска и спасания терпящих или потерпевших бедствие воздушных судов	f	f	3	6755
1277	При пожаре на ВС, отказе дв-ля, захвате или угрозе взрыва ВС, вынужденной посадке вне аэ-ма, экстренном снижении, нарушении прочности ВС, потери управляемости ВС, потери ориентировки	t	f	1	6756
1277	При захвате ВС, угрозе применения взрывного устройства на борту ВС, при пожаре двигателя, при потере радиосвязи в полете и при вынужденной посадке	f	f	2	6757
1277	При потере радиосвязи, попадании в зону опасных метеоявлений, ухудшении здоровья лица на борту ВС, при отказах систем ВС, при которых невозможен полет до аэродрома назначения	f	f	3	6758
1278	Метеорологические условия, к полетам в которых экипаж не подготовлен	f	f	1	6759
1278	Грозовая деятельность, сильные осадки, повышенная электрическая активность атмосферы, обледенение, турбулентность, сдвиг ветра, облака вулканического пепла, пыльные и песчаные бури	t	f	2	6760
1278	Метеорологические явления, полёты в которых не предусмотрены в РЛЭ	f	f	3	6761
1279	Указанные в РЛЭ метеорологические явления и условия, полеты в которых запрещаются	t	f	1	6762
1279	Гроза, град, сильная болтанка, сильный сдвиг ветра, гололед, сильное обледенение, смерч, сильная пыльная буря, вулканический пепел, дождь ухудшающий видимость менее 800 м при взлете и посадке	f	f	2	6763
700	запрещается	f	t	1	8586
1279	К опасным метеорологическим явлениям и условиям для полета относятся гроза, град, сильное обледенение, сильная болтанка, вулканический пепел	f	f	3	6764
1280	Фактическая погода соответствует эксплуатационному минимуму для посадки, с учетом ограничений в случае отказа одного двигателя	f	f	1	6765
1280	Фактическая погода или прогноз за 1 час до и после расчетного времени прибытия соответствует эксплуатационному минимуму для посадки, с учетом ограничений в случае отказа одного двигателя	f	t	2	6766
1280	Запасной аэродром для взлета выбирается при соответствии прогноза погоды на нем эксплуатационному минимуму для посадки	f	f	3	6767
1281	Видимость не менее 5000 м, а нижняя граница облаков - не ниже 450 м	f	t	1	6768
1281	Нижняя граница облаков превышает MDH не менее чем на 150 м	f	f	2	6769
1281	Нижняя граница облаков не ниже безопасной высоты в районе аэродрома (в секторе захода на посадку)	f	f	3	6770
1282	Должен быть не менее чем на 60 минут полета после посадки ВС	f	f	1	6771
1282	Должен обеспечивать полет до аэродрома назначения и затем продолжить его в течение 1 часа при нормальном расходе топлива в крейсерском режиме	f	f	2	6772
1282	Должен обеспечивать полет после прибытия на аэродром назначения в течение не менее 60 минут на высоте 450 м над аэродромом при стандартных температурных условиях	t	f	3	6773
1283	Должно обеспечивать полет в течение не менее 60 минут на высоте 450 м над аэродромом при стандартных температурных условиях	f	f	1	6774
1283	Должно позволять продолжать полёт 2 часа в крейсерском режиме либо 1 час при прогнозе погоды на аэродроме назначения выше требований к запасному по НГО на 50 м, по видимости на 500 м	t	f	2	6775
1283	Остаток топлива после посадки ВС на аэродроме назначения должен быть не менее чем на 60 минут полёта	f	f	3	6776
1284	Должно позволять продолжать полёт еще в течение 30 минут со скоростью полета в зоне ожидания на высоте 450 м над аэродромом назначения при стандартных температурных условиях	t	f	1	6777
1284	Должно обеспечивать полет в течение не менее 60 минут на высоте 450 м над аэродромом при стандартных температурных условиях	f	f	2	6778
1284	Остаток топлива после посадки ВС должен быть не менее чем на 60 минут полёта	f	f	3	6779
1285	При обеспечении приемлемого уровня безопасности полётов	f	f	1	6780
1285	При отсутствии взаимосвязей между неработающими компонентами, приводящих к снижению уровня безопасности ниже допустимого предела	f	f	2	6781
1285	При отсутствии взаимосвязей между неработающими компонентами, приводящих к снижению уровня безопасности или к чрезмерному увеличению нагрузки на летный экипаж	t	f	3	6782
1286	Экипаж не выключает бортовые самописцы до передачи их комиссии по расследованию авиационного события	f	f	1	6783
1286	По завершении полета и не включает вновь до тех пор, пока они не будут переданы в порядке, предусмотренном ПРАПИ-98	t	f	2	6784
1286	Экипаж выключает их в порядке, предусмотренном РЛЭ (FCOM)	f	f	3	6785
1287	90 дней – не выполнено три взлета и посадки на ВС	t	f	1	6786
1287	12 месяцев – не выполнено шесть полетов на ВС или лётном тренажёре	f	f	2	6787
1287	30 дней – не выполнен ни один полёт на ВС	f	f	3	6788
1288	30 дней – не выполнен ни один полёт в качестве КВС, второго пилота или сменного пилота на ВС или лётном тренажёре	f	f	1	6789
1288	90 дней – не исполнялись обязанности КВС, в том числе в роли пилота, непилотирующего ВС или сменного пилота на ВС или лётном тренажёре	t	f	2	6790
1288	7 месяцев – не выполнено шесть полетов на летном тренажере по отработке действий в стандартных, нештатных и аварийных ситуациях, специфических для крейсерского этапа полета	f	f	3	6791
1289	Дважды в течение любых последовательных 12 месяцев, с интервалом не менее 120 дней	f	f	1	6792
1289	Дважды в течение любых последовательных 12 месяцев, с интервалом не более 180 дней	f	f	2	6793
1289	Один раз в 7 месяцев	f	t	3	6794
1290	С момента уборки трапа после посадки пассажиров до открытия любой двери для высадки пассажиров, за исключением случаев покидания рабочего места членом экипажа	f	t	1	6795
1290	С момента запуска двигателей до выключения двигателей после заруливания на стоянку	f	f	2	6796
700	разрешается	f	f	2	8587
1290	С момента закрытия всех внешних дверей после посадки пассажиров до открытия любой двери для их высадки, за исключением случаев покидания рабочего места членом экипажа	f	f	3	6797
1292	Запрещается	f	f	1	6798
1292	Запрещается также и при предъявлении заверенной копии Паспорта качества	f	t	2	6799
1292	Разрешается, если это не противоречит РЛЭ (AFM)	f	f	3	6800
1293	Разрешается без трапов, если это не противоречит РЛЭ (AFM)	f	t	1	6801
1293	Как минимум один трап должен находиться у самолёта	f	f	2	6802
1293	Не менее двух трапов при двух и более входных дверях ВС	f	f	3	6803
1294	Предполетный медосмотр не проводится, решение о допуске членов экипажа к полетам принимает КВС	t	f	1	6804
1294	Предполетный медосмотр не проводится, решение о допуске членов экипажа к полетам принимает Представитель АК	f	f	2	6805
1294	Предполетный медосмотр членов экипажа проводится выборочно, решение о допуске экипажа к полетам принимает Представитель АК	f	t	3	6806
1295	Время окончания работ в аэропорту	f	t	1	6807
1295	Информация Представителя АК	f	f	2	6808
1295	Информация о времени окончания работ является основанием для вылета с расчетом прилета на данный аэродром не ранее указанного времени окончания работ	f	f	3	6809
1296	КВС, при этом службы обеспечения полетов принимают все возможные меры для обеспечения безопасности при посадке	f	f	1	6810
1296	Экипажи прибывающих воздушных судов	f	f	2	6811
1296	Службы обеспечения полетов аэропорта	f	t	3	6812
1297	Служба авиационной безопасности аэропорта в соответствии с законами и правилами государства пребывания	f	t	1	6813
1297	Представитель АК совместно с КВС в соответствии с законами и правилами государства пребывания	f	f	2	6814
1297	Органы авиационной безопасности государства пребывания	f	f	3	6815
1298	Ночью за 15 минут до захода солнца или до прибытия ВС. Днём - при видимости 2000 м и менее. Выключается с восходом солнца, днем при видимости более 2000 м., и перерыве в полётах более 15 минут	f	f	1	6816
1298	Ночью за 20 минут до захода солнца. Днём при видимости 1000 м и менее. Выключается через 20 минут после восхода солнца, днем при видимости более 1000 м., и при перерыве в полётах более 20 минут	f	t	2	6817
1298	Ночью за 5 минут до захода солнца или до прибытия ВС. Днём при видимости 3000 м и менее. Выключается с восходом солнца, днем при видимости более 3000 м., и при перерыве в полётах более 5 минут	f	f	3	6818
1299	-  45 сек. – между взлетом и посадкой;-  2 мин. – при взлете ВС менее 136 т, за ВС 136 т и более;-  3 мин. – при взлёте ВС менее 136 т со средины ВПП за ВС 136 т и более - от ее начала; -  1 мин. –  во всех остальных случаях	t	f	1	6819
1299	-  30 сек. –  между взлетом и посадкой;-  1 мин. – при взлете ВС менее 136 т, за ВС 136 т и более;-  3 мин. – при взлёте ВС менее 136 т со средины ВПП за ВС 136 т и более - от ее начала; -  2 мин. –  во всех остальных случаях	f	f	2	6820
1299	-  1 мин. –  между взлетом и посадкой;-  3 мин. –  при взлете ВС менее 136 т, за ВС 136 т и более; -  1 мин. –  при взлёте ВС менее 136 т со средины ВПП за ВС 136 т и более - от ее начала; -  2 мин. – во всех остальных случаях	f	f	3	6821
1389	склонение	f	f	1	6822
1389	уклонение	f	f	2	6823
1389	магнитное склонение	t	f	3	6824
1390	нулевого меридиана	f	f	1	6825
1390	ближайшего целого значения меридиана	f	f	2	6826
1390	начала географической зоны	t	f	3	6827
1392	нельзя	f	f	1	6828
1392	с помощью азимутов на двух известных ориентиров	t	f	2	6829
1392	с помощью солнца	f	f	3	6830
1397	гражданскую и государственную	f	f	1	6831
1397	гражданскую, государственную и частную	f	f	2	6832
1397	гражданскую, государственную и экспериментальную	t	f	3	6833
1398	авиация, используемая в целях удовлетворения потребностей граждан	f	f	1	6834
1398	авиация, используемая для предоставления услуг и (или) выполнения авиационных работ	f	f	2	6835
1398	авиация, не используемая для коммерческих воздушных перевозок и выполнения авиационных работ	t	f	3	6836
1399	воздушное судно, максимальный взлетный вес которого составляет 1200 кг, в том числе вертолет, максимальный взлетный вес которого менее 800 кг	f	f	1	6837
1465	поданный план полета	f	f	1	6909
1465	представленный план полета	t	f	2	6910
1399	воздушное судно, максимальный взлетный вес которого составляет 3500 кг, в том числе вертолет, максимальный взлетный вес которого менее 2700 кг	f	f	2	6838
1399	воздушное судно, максимальный взлетный вес которого составляет 5700 кг, в том числе вертолет, максимальный взлетный вес которого менее 3100 кг	t	f	3	6839
1400	воздушное судно, максимальный взлетный вес которого составляет не более 115 кг	f	f	1	6840
1400	воздушное судно, максимальный взлетный вес которого составляет не более 495 кг	f	f	2	6841
1400	воздушное судно, максимальный взлетный вес которого составляет не более 495 кг без учета веса авиационных средств спасения	t	f	3	6842
1401	государственный опознавательный знак	f	f	1	6843
1401	государственный и регистрационный опознавательные знаки	f	f	2	6844
1401	государственный и регистрационный опознавательные знаки и изображение государственного флага	t	f	3	6845
1402	имеющие задолженности по уплате штрафов и алиментов	f	f	1	6846
1402	привлекавшиеся к ответственности по Уголовному кодексу Российской Федерации	f	f	2	6847
1402	имеющие непогашенную или неснятую судимость за совершение умышленного преступления	t	f	3	6848
1403	полис страхования ответственности перед третьими лицами	f	f	1	6849
1403	полис страхования ответственности перед третьими лицами и полис страхования жизни и здоровья членов экипажа воздушного судна	t	f	2	6850
1403	полис страхования ответственности перед третьими лицами, полис страхования жизни и здоровья членов экипажа воздушного судна, полис страхования жизни и здоровья лиц, находящихся на борту воздушного судна	f	f	3	6851
1404	от уровня моря	f	t	1	6852
1404	от уровня земли	f	f	2	6853
1404	от превышения контрольной точки аэродрома	f	f	3	6854
1405	в состоянии алкогольного или наркотического опьянения	f	f	1	6855
1405	без прохождения предполетного медосмотра	f	f	2	6856
1405	в состоянии алкогольного опьянения или под влиянием любых психоактивных веществ	t	f	3	6857
1406	от уровня земли	f	f	1	6858
1406	от уровня 760 мм.р.ст	f	f	2	6859
1406	от среднего уровня моря	t	f	3	6860
1407	от уровня земли	t	f	1	6861
1407	от уровня 760 мм. р.ст	f	f	2	6862
1407	от среднего уровня моря	f	f	3	6863
1408	атмосферное давление в данной точке, приведенное к уровню моря	t	f	1	6864
1408	стандартное атмосферное давление на уровне моря	f	f	2	6865
1408	атмосферное давление аэродрома на уровне порога ВПП	f	f	3	6866
1409	атмосферное давление в данной точке, приведенное к уровню моря	f	f	1	6867
1409	стандартное атмосферное давление на уровне моря	f	f	2	6868
1409	атмосферное давление аэродрома на уровне порога ВПП	t	f	3	6869
1410	атмосферное давление в данной точке, приведенное к уровню моря	f	f	1	6870
1410	стандартное атмосферное давление на уровне моря	t	f	2	6871
1410	атмосферное давление аэродрома на уровне порога ВПП	f	f	3	6872
1412	сотни метров	f	f	1	6873
1412	десятки метров	f	t	2	6874
1412	метры	f	f	3	6875
1413	на истинный север	f	f	1	6876
1413	на магнитный север	f	f	2	6877
1413	нет правильного ответа	f	t	3	6878
1416	уровень моря	f	f	1	6879
1416	уровень земли	t	f	2	6880
1416	неограниченную высоту	f	f	3	6881
1417	уровень моря	f	f	1	6882
1417	уровень земли	f	f	2	6883
1417	неограниченную высоту	t	f	3	6884
1418	название	f	f	1	6885
1418	расположение	f	f	2	6886
1418	четырехбуквенный индекс	f	t	3	6887
1419	оперативно распространяемая информация об изменениях в правилах проведения и обеспечения полетов и аэронавигационной информации	f	t	1	6888
1419	сборник аэронавигационной информации, издающийся в Российской федерации как государственный документ	f	f	2	6889
1419	передаваемая пилоту аэронавигационная информация после подачи плана полета	f	f	3	6890
1420	серии А	f	f	1	6891
1420	серии С	f	f	2	6892
1420	серии Ж	f	t	3	6893
1421	высоты	f	f	1	6894
1421	температуры	f	f	2	6895
1421	давления	t	f	3	6896
1422	1 мБар	t	f	1	6897
1422	10 мБар	f	f	2	6898
1422	20 мБар	f	f	3	6899
1423	116-132 МГц	f	f	1	6900
1471	14 часов дня, предшествующего дню выполнения полета	f	f	1	6915
1471	24 часа до полета	t	f	2	6916
1471	2 часа до полета	f	f	3	6917
1472	6 часов до полета	f	f	1	6918
1472	1 час до полета	f	f	2	6919
1472	30 минут до полета	t	f	3	6920
1473	сообщить о завершении полета незамедлительно после посадки	f	f	1	6921
1473	не позднее 5 минут после расчетного времени окончания полета, указанного в плане полета, чтобы не начинать операции по поиску и спасанию	f	t	2	6922
1473	не позднее 30 минут после расчетного времени окончания полета, указанного в плане полета, чтобы не начинать операции по поиску и спасанию	f	f	3	6923
1474	АФТН, телеграф, нарочный, АДП аэродрома вылета	f	f	1	6924
1474	АФТН, телефон, интернет	f	f	2	6925
1474	АФТН, АДП аэродрома вылета, телеграф, телефон, факс, интернет, нарочный	t	f	3	6926
1476	Законе Архимеда	t	f	1	6927
1476	Законе Бойля-Мариотта	f	f	2	6928
1476	Законе Бернули	f	f	3	6929
1477	RA:	f	f	1	6930
1477	SN	f	f	2	6931
1477	TS	f	t	3	6932
1478	TEMPO	f	f	1	6933
1478	NOSIG	f	f	2	6934
1478	STB	f	t	3	6935
1479	NOSIG	f	f	1	6936
1479	CLR	f	f	2	6937
1479	CAVOK	t	f	3	6938
1480	rome & alfa	f	f	1	6939
1480	rock & alyaska	f	f	2	6940
1480	romeo & alfa	t	f	3	6941
1481	PERMIT	f	f	1	6942
1481	ALLOW	f	f	2	6943
1481	CLEARED TO	t	f	3	6944
1482	GO DOWN (GO UP)	f	f	1	6945
1482	GO LOW (GO HIGH)	f	f	2	6946
1482	DESCEND (CLIMB)	t	f	3	6947
1485	требуется	f	f	1	6948
1485	не требуется	t	f	2	6949
1485	требуется, в случае выполнения полетов по приборам	f	f	3	6950
1486	в верхнем воздушном пространстве, где предоставляется диспетчерское обслуживание воздушного движения и осуществляется управление полетами	f	f	1	6951
1486	в нижнем воздушном пространстве, где предоставляется диспетчерское обслуживание воздушного движения и осуществляется управление полетами	t	f	2	6952
1486	в воздушном пространстве, где не установлен класс А	f	f	3	6953
1487	в нижнем воздушном пространстве, где предоставляется диспетчерское обслуживание воздушного движения и осуществляется управление полетами	f	f	1	6954
1487	в нижнем воздушном пространстве, где не предоставляется диспетчерское обслуживание воздушного движения и не осуществляется управление полетами	f	f	2	6955
1487	в воздушном пространстве, где не установлены классы А и С	t	f	3	6956
1488	Федеральной службой по надзору в сфере транспорта	f	f	1	6957
1488	постановлением Правительства	f	f	2	6958
1488	Министерством транспорта	t	f	3	6959
1489	от уровня земли	t	f	1	6960
1489	от уровня абсолютной высоты 300 м	f	f	2	6961
1489	от уровня моря	f	f	3	6962
1490	300 м абсолютной высоты	f	f	1	6963
1490	200 м от земной или водной поверхности в пределах района полетной информации	t	f	2	6964
1490	от уровня земли	f	f	3	6965
1491	2 км	f	f	1	6966
1491	4 км	t	f	2	6967
1491	8 км	f	f	3	6968
1492	класс А	f	f	1	6969
1492	класс С	t	f	2	6970
1492	класс G	f	f	3	6971
1493	в классе С	f	f	1	6972
1493	в классах; А и С	t	f	2	6973
1493	в классе G	f	f	3	6974
1494	для получения диспетчерского разрешения	f	f	1	6975
1494	для получения аэронавигационной и метеорологической информации	f	f	2	6976
1494	для получения полетно-информционного обслуживания и аварийного оповещения	t	f	3	6977
1495	не требуется	t	f	1	6978
1495	требуется, если необходимо пересечение диспетчерской зоны	f	f	2	6979
1495	требуется, если необходимо пересечение местной воздушной линии	f	f	3	6980
1498	в качестве бортового журнала может использоваться формуляр воздушного судна	f	f	1	6981
1498	в качестве санитарного журнала может использоваться формуляр воздушного судна	f	f	2	6982
1498	в качестве бортового журнала может использоваться летная книжка пилота	t	f	3	6983
1499	в качестве санитарного журнала может использоваться бортовой журнал	t	f	1	6984
1499	в качестве бортового журнала может использоваться летная книжка пилота	f	f	2	6985
535	расчетное время выхода на начальную точку STAR	f	f	2	7108
1499	в качестве бортового и санитарного журналов может использоваться формуляр воздушного судна	f	f	3	6986
1500	поддержание воздушного судна в пригодном для выполнения полетов состоянии	f	f	1	6987
1500	поддержание воздушного судна в пригодном для выполнения полетов состоянии, исправность воздушного судна и его компонентов	f	f	2	6988
1500	поддержание воздушного судна в пригодном для выполнения полетов состоянии, исправность воздушного судна и его компонентов, наличие действительного сертификата летной годности	t	f	3	6989
1501	QNE	f	f	1	6990
1501	QFE	f	f	2	6991
1501	QNH	t	f	3	6992
1502	при пересечении высоты района в наборе высоты	t	f	1	6993
1502	при пересечении эшелона перехода района в снижении	f	f	2	6994
1502	при пересечении высоты района в наборе высоты, при пересечении эшелона перехода района в снижении	f	f	3	6995
1503	на расстоянии 50 м от людей, транспортных средств и строений	f	f	1	6996
1503	на расстоянии 150 м от строений и транспортных средств	f	f	2	6997
1503	на расстоянии 150 м от людей, транспортных средств и строений	t	f	3	6998
1504	при видимости водной или земной поверхности	f	f	1	6999
1504	при видимости водной или земной поверхности, при расстоянии от воздушного судна до облаков не менее 150 м	f	f	2	7000
1504	при видимости водной или земной поверхности, при расстоянии от воздушного судна до облаков не менее 150 м, днем при видимости не менее 2000 м	t	f	3	7001
1519	0.5 м/с	f	f	1	7002
1519	1.5 м/с	f	t	2	7003
1519	3 м/с	f	f	3	7004
1520	обязательно	f	t	1	7005
1520	по желанию пилота	f	f	2	7006
1520	обязательно при скоростях ветра более 3 м/с	f	f	3	7007
1530	только полеты по приборам	f	f	1	7008
1530	только полеты по правилам визуальных полетов	f	f	2	7009
1530	полеты по правилам визуальных полетов и полеты по приборам	t	f	3	7010
1531	общего времени наработки воздушного судна, данных о модификациях и ремонтах	f	f	1	7011
1531	общего времени наработки воздушного судна, данных о модификациях и ремонтах, времени эксплуатации после последнего капитального ремонта воздушного судна	f	f	2	7012
1531	общего времени наработки воздушного судна, данных о модификациях и ремонтах, времени эксплуатации после последнего капитального ремонта воздушного судна, данных о техническом обслуживании	t	f	3	7013
1535	1 год	t	f	1	7014
1535	2 года	f	f	2	7015
1535	3 года	f	f	3	7016
1536	не чаще 2 раз в 1 год	t	f	1	7017
1536	не чаще 1 раза в 1 год	f	f	2	7018
1536	не чаще 1 раза в 2 года	f	f	3	7019
1537	информационная табличка	f	f	1	7020
1537	информационный плакат	f	f	2	7021
1537	информационная огнестойкая табличка	t	f	3	7022
1538	наименование и обозначение ЕЭВС	f	f	1	7023
1538	наименование, назначение ЕЭВС, государственный и регистрационный опознавательные знаки ЕЭВС	f	f	2	7024
1538	наименование, назначение ЕЭВС, государственный и регистрационный опознавательные знаки ЕЭВС, номер сертификата летной годности ЕЭВС	t	f	3	7025
46	маршрутом;	f	f	1	7026
46	скоростью;	t	t	2	7027
46	смещением при боковом ветре;	f	f	3	7028
47	перемещением вперёд;	f	f	1	7029
47	высотой;	t	t	2	7030
47	курсом;	f	f	3	7031
88	Необходимо выполнить гашение горизонтальной скорости до нуля и затем вертикальное приземление;	f	f	1	7032
88	Должна быть выполнена нормальная посадка с пробегом;	f	f	2	7033
88	Непосредственно перед касанием добавить имеющийся газ для поворота носа вправо;	t	t	3	7034
96	Как правило, только ручка циклического шага используется для поворотов;	t	t	1	7035
96	Как правило, управление скорость осуществляется общим шагом;	f	f	2	7036
96	Не позволять скорости снижения становиться слишком низкой при малой или нулевой воздушной\r\n                        скорости;	f	f	3	7037
104	помогает выполнять скоординированные повороты;	f	f	1	7038
104	противодействовать реактивному моменту от несущего винта;	t	t	2	7039
104	поддерживать курс при горизонтальном полёте;	f	f	3	7040
535	расчетное время выхода на радионавигационную точку захода на посадку	t	f	3	7109
733	АК	f	f	3	8687
181	во избежание поражения статическим электричеством не прикасаться к спускаемому оборудованию до\r\n                        касания земной (водной) поверхности разрядником, укрепленным на вертлюге лебедки вертолета;	t	f	1	7041
181	при раскачке спускаемого оборудования попытаться поймать его руками и отвести в сторону от\r\n                        вертикального направления, далее после касания тросом поверхности вернуть спускаемое\r\n                        оборудование в точку, находящуюся непосредственно под вертолетом, и приступить к его\r\n                        использованию;	f	f	2	7042
181	в процессе подъема необходимо держаться руками за трос и вертлюг бортовой лебедки, а в момент\r\n                        подхода непосредственно к кабине вертолета оказать помощь бортовому технику по втаскиванию Вас в\r\n                        кабину;	f	f	3	7043
397	угол в горизонтальной плоскости между северным направлением меридиана проходящего через вертолет\r\n                        и проекцией продольной оси на эту плоскость;	t	t	1	7044
397	угол в горизонтальной плоскости между направлением северного магнитного меридиана проходящего\r\n                        через вертолет и проекцией продольной оси на эту плоскость;	f	f	2	7045
397	угол, заключенный между направлением северного меридиана отсчета и направлением линии заданного\r\n                        пути;	f	f	3	7046
398	угол между северным направлением магнитного меридиана и продольной осью вертолета;	t	t	1	7047
398	угол между северным направлением компасного меридиана и продольной осью вертолета;	f	f	2	7048
398	угол между северным направлением условного меридиана и продольной осью вертолета;	f	f	3	7049
36	«Я не беспомощен!»	f	t	1	7050
36	«Виноват кто-то иной»	f	f	2	7051
36	«Что в этом проку?»	f	f	3	7052
38	Принятие разумных решений	f	f	1	7053
38	Распознавание опасных мыслей	f	t	2	7054
38	Распознавание неуязвимости ситуации	f	f	3	7055
39	пространственная дезориентация	f	t	1	7056
39	гипоксия	f	f	2	7057
39	гипервентиляция	f	f	3	7058
147	стадия кучевого облака	f	f	1	7059
147	стадию зрелого грозового облака	f	f	2	7060
147	стадия распада	f	t	3	7061
158	турбулентность и плохая приземная видимость	f	f	1	7062
158	слоисто-дождевые облака и хорошая приземная видимость	f	f	2	7063
158	турбулентность и хорошая приземная видимость	f	t	3	7064
159	плохую приземную видимость	t	f	1	7065
159	ливневые осадки	f	f	2	7066
159	турбулентность	f	f	3	7067
160	фронт	f	t	1	7068
160	фронтолиз	f	f	2	7069
160	фронтогенезис	f	f	3	7070
161	увеличение облачности	f	f	1	7071
161	увеличение относительной влажности	f	f	2	7072
161	изменение температуры воздуха	f	t	3	7073
162	вида осадков	f	f	1	7074
162	стабильности воздушных масс	f	f	2	7075
162	направления ветра	f	t	3	7076
164	точки росы	f	f	1	7077
164	температуры	f	t	2	7078
164	стабильности воздуха	f	f	3	7079
166	нагрев и конденсация	f	f	1	7080
166	испарение и сублимация	f	t	2	7081
166	перенасыщение и испарение	f	f	3	7082
167	испарения и сублимации	t	f	1	7083
167	сублимации и конденсации	f	f	2	7084
167	испарения и конденсации	f	f	3	7085
204	технология CRM основана на положениях науки о ЧФ в авиации; представляет собой систему мер\r\n                        повышения безопасности и эффективности полетов с помощью правильного применения людских,\r\n                        технических и информационных ресурсов, а также улучшения взаимодействия, как в экипаже, так и\r\n                        экипажа с персоналом других компонентов системы	f	t	1	7086
204	технология CRM основана на положениях общей психологии; представляет собой систему мер для\r\n                        обеспечения психологического комфорта VIP-пассажиров на борту ВС	f	f	2	7087
204	технология CRM основана на положениях гражданского права и рыночной экономики; представляет\r\n                        собой систему мер в целях предоставления пассажирам максимальных удобств при авиаперевозках и\r\n                        достижения высоких экономических показателей авиатранспортной системы	f	f	3	7088
536	приборную скорость IAS	f	f	1	7110
536	истинную скорость TAS	f	f	2	7111
205	главной причиной вестибулярных иллюзий в полёте являются недостатки профотбора кандидатов на\r\n                        лётное обучение	f	t	1	7089
205	ощущая ускорение в полёте, тело человека не способно однозначно определить, вызвано оно\r\n                        гравитацией или маневрами ЛА	f	f	2	7090
205	во время полёта в ПМУ основным источником ориентационной информации, корректирующей ложные\r\n                        данные вестибулярной и соматосенсорной систем, являются глаза. Но если совсем отсутствуют\r\n                        визуальные ориентиры, и нет приборной информации, - очень быстро наступает полная потеря\r\n                        пространственной ориентации	f	f	3	7091
206	выраженное снижение активности пилота (расслабление) в момент, когда основная деятельность еще\r\n                        не завершена. Наблюдается на относительно менее сложных этапах полета после выполнения\r\n                        ответственной задачи	t	f	1	7092
206	проявляется в том, что пилот, будучи уверенным, докладывает об исполнении действия при\r\n                        отсутствии его реального исполнения, то есть, имеет место псевдодействие	f	f	2	7093
206	оцепенение и полная бездеятельность в течение определенного времени (или наоборот, повышенная\r\n                        двигательная активность при потере целесообразности действий). Возникает при действии единичных\r\n                        сверхсильных раздражителей	f	f	3	7094
423	комплекс действий экипажа, направленных на достижение целей вождения летательного аппарата	f	f	1	7095
423	комплекс действий экипажа, направленных на достижение наибольшей точности, надежности и\r\n                        безопасности вождения летательного аппарата	f	f	2	7096
423	комплекс действий экипажа, направленных на достижение наибольшей точности, надежности и\r\n                        безопасности вождения летательного аппарата	f	t	3	7097
427	параметры, характеризующие положение и движение ВС. Они включают координаты места ВС, высоту\r\n                        полета, воздушную скорость, курс самолета, скорость ветра, направление ветра, угол ветра,\r\n                        курсовой угол ветра, путевую скорость, путевой угол, угол сноса	t	f	1	7098
427	параметры, характеризующие движение ВС. Они включают координаты места ВС, высоту полета,\r\n                        воздушную скорость, курс самолета, скорость ветра, направление ветра, угол ветра, курсовой угол\r\n                        ветра, путевую скорость, путевой угол, угол сноса, вертикальную скорость набора и снижения, крен\r\n                        и тангаж ВС, остаток топлива и центровка	f	f	2	7099
427	параметры, характеризующие положение ВС в пространстве. Они включают координаты места ВС, высоту\r\n                        полета, курс самолета, скорость ветра, направление ветра, угол ветра, курсовой угол ветра,\r\n                        путевую скорость, путевой угол, угол сноса	f	f	3	7100
480	полного запрещения использования воздушного пространства, за исключением деятельности\r\n                        пользователей воздушного пространства, в интересах которых устанавливаются временный и местный\r\n                        режимы, а также кратковременные ограничения; частичного запрещения деятельности по использованию\r\n                        воздушного пространства (место, время, высота)	f	t	1	7101
480	частичного запрещения использования воздушного пространства, за исключением деятельности\r\n                        пользователей воздушного пространства, в интересах которых устанавливаются временный и местный\r\n                        режимы, а также кратковременные ограничения; частичного запрещения деятельности по использованию\r\n                        воздушного пространства (место, время, высота)	f	f	2	7102
480	полного запрещения использования воздушного пространства, за исключением деятельности\r\n                        пользователей воздушного пространства, в интересах которых устанавливаются временный и местный\r\n                        режимы, а также кратковременные ограничения; полного запрещения деятельности по использованию\r\n                        воздушного пространства (место, время, высота)	f	f	3	7103
533	при полетах по установленным маршрутам региональной сети УВД в течение времени полета	f	f	1	7104
533	при полетах в районах повышенной плотности воздушного движения, преимущественно FIR/UIR Западной\r\n                        Европы	f	f	2	7105
533	при любых полетах в установленном пространстве в течение 95% полетного времени	f	t	3	7106
536	число М	f	t	3	7112
537	только значение высоты в футах (ft)	f	f	2	7114
537	номер эшелона FL или значение высоты в футах (ft)	f	t	3	7115
538	если фактическое значение давления в районе аэродрома менее среднестатистического по результатам\r\n                        наблюдений за многолетний срок	f	f	1	7116
538	при введении ограничений по высоте в нижнем секторе района аэродрома (при проведении\r\n                        поисково-спасательных работ, учений и т.д.)	f	f	2	7117
538	при наблюдении низких температур (в зимний период)	f	t	3	7118
539	MGA всегда больше MSA	f	f	1	7119
539	MSA всегда больше MGA	f	f	2	7120
539	соотношение указанных высот зависит от географического расположения аэродрома и особенностей\r\n                        рельефа	f	t	3	7121
540	по всему участку трассы	f	f	1	7122
540	на удалении 22n.m. от навигационного средства, на которое выполняется полет	f	f	2	7123
540	учет приема сигнала навигационного средства не производится	t	f	3	7124
541	5000ft	f	f	1	7125
541	6000ft	f	t	2	7126
541	7000ft	f	f	3	7127
542	100ft х 5000ft	f	t	1	7128
542	150ft x 5500ft	f	f	2	7129
542	125ft x 6000ft	f	f	3	7130
543	8 минут	f	f	1	7131
543	12 минут	f	f	2	7132
543	15 минут	f	t	3	7133
544	запланированного времени вылета	f	f	1	7134
544	фактического времени вылета при изменении времени взлета от запланированного более чем на 30\r\n                        минут	f	f	2	7135
544	момента составления OFP	f	t	3	7136
545	заблаговременного уведомления о внесении изменений в эксплуатационную практику на основании\r\n                        общих дат вступления в силу	t	f	1	7137
545	разработки дат вступления в силу/аннулирования всех изменений в процедурах обслуживания и\r\n                        выполнения полетов	f	f	2	7138
545	контроля ввода в действие/аннулирования и контроля текущего состояния всех введенных изменений в\r\n                        процедуры, связанные с обслуживанием и выполнением полетов	f	f	3	7139
546	21 день	f	f	1	7140
546	28 дней	t	f	2	7141
546	1 календарный месяц	f	f	3	7142
547	ICAO	t	f	1	7143
547	IATA	f	f	2	7144
547	возможны оба варианта (ICAO или IATA), при этом в п. 18 плана полета «Remarks»\r\n                        указывается примечание «AD Code ICAO/..IATA»	f	f	3	7145
548	начало первого срока AIRAC приходится на первое января наступившего года	f	f	1	7146
548	дата не является фиксированной и в каждом году приходится на разные числа	f	t	2	7147
548	изменение последовательных сроков приходится на последнее воскресенье каждого месяца	f	f	3	7148
549	после входа в зону RVSM и перед выходом их нее	f	f	1	7149
549	только по запросу диспетчера АТС при появлении у него сомнений в правильности выдерживания\r\n                        экипажем назначенного эшелона RVSM	f	f	2	7150
549	не реже одного раза в час полета	f	t	3	7151
550	290-280	f	f	1	7152
550	300-390	f	f	2	7153
550	290-410	t	f	3	7154
551	150 ft	f	f	1	7155
551	180 ft	f	f	2	7156
551	200 ft	f	t	3	7157
552	40 ft	f	f	1	7158
552	50 ft	f	f	2	7159
552	65 ft	t	f	3	7160
553	до границы первого океанического РПИ	f	t	1	7161
553	до всех указанных в плане полета основных точек маршрута	f	f	2	7162
553	до границ каждого океанического РПИ	f	f	3	7163
554	до всех точек маршрута	f	t	1	7164
554	только до тех точек, которых нет в текущем трековом сообщении	f	f	2	7165
554	до точки входа в первый РПИ и выхода из последнего РПИ океанического пространства	f	f	3	7166
555	число М	f	t	1	7167
555	истинную воздушную скорость TAS	f	f	2	7168
555	приборную скорость IAS	f	f	3	7169
556	в левую сторону	f	f	1	7170
556	в правую сторону	f	t	2	7171
556	в обе стороны	f	f	3	7172
557	при полете по организованным трекам OTS	f	f	1	7173
557	при полете по неорганизованным трекам	f	t	2	7174
557	при полете по полярным трекам за линией Северного полярного круга	f	f	3	7175
558	выхода из последнего, в соответствии с планом полета, океанического РПИ	f	f	1	7176
558	входа в первый, в соответствии с планом полета, океанический РПИ	f	f	2	7177
558	время прохода границы смежных океанических РПИ	f	t	3	7178
1453	усилие увеличится	f	t	2	7576
559	экипажу следует запросить разрешение на использование процедуры смещения	f	f	1	7179
559	экипажу следует информировать диспетчера о применяемой процедуре	f	f	2	7180
559	диспетчерское разрешение не требуется и информирование необязательно	f	t	3	7181
560	X - воздушное судно сертифицировано для полетов для полетов в MNPS	t	f	1	7182
560	А - воздушное судно сертифицировано для полетов в Арктическом районе	f	f	2	7183
560	С - воздушное судно сертифицировано для полетов в воздушном пространстве Северной Канады и\r\n                        Аляски	f	f	3	7184
573	гроза в облачности	t	f	1	7185
573	гроза с дождем	f	f	2	7186
573	гроза с градом	f	f	3	7187
574	до эшелона полета 230	t	f	1	7188
574	до высоты 6000м	f	f	2	7189
574	до высоты 9000м	f	f	3	7190
575	усиление	t	f	1	7191
575	ослабление	f	f	2	7192
575	без изменения	f	f	3	7193
576	на восток	t	f	1	7194
576	на северо-восток	f	f	2	7195
576	с востока	f	f	3	7196
577	мощная система слоистообразной облачности всех ярусов	f	t	1	7197
577	мощное развитие кучево- дождевой облачности	f	f	2	7198
577	развитие слабой кучевой облачности	f	f	3	7199
578	зимой ночью	f	f	1	7200
578	летом во второй половине ночи и утром	f	t	2	7201
578	летом днем	f	f	3	7202
579	за линией фронта	f	f	1	7203
579	перед линией фронта	f	t	2	7204
579	на линии фронта	f	f	3	7205
580	скорости перемещения и метеоусловий	t	f	1	7206
580	системы облачности	f	f	2	7207
580	опасных явлений погоды	f	f	3	7208
581	10-20 км/ч	f	f	1	7209
581	не более 30 км/ч	f	t	2	7210
581	40-50 км/ч	f	f	3	7211
582	только слоистообразной облачности всех ярусов	f	f	1	7212
582	только кучево- дождевой облачности	f	f	2	7213
582	слоистообразной и кучево- дождевой облачности	f	t	3	7214
583	10-20 км/ч	f	f	1	7215
583	15-25 км/ч	f	f	2	7216
583	более 30 км/ч (обычно 50-70 км/ч)	f	t	3	7217
584	теплого воздуха	t	f	1	7218
584	холодного воздуха	f	f	2	7219
584	воздуха умеренных широт	f	f	3	7220
585	несколько десятков километров	f	t	1	7221
585	несколько сот километров	f	f	2	7222
585	100-200км	f	f	3	7223
586	на линии фронта	f	f	1	7224
586	перед линией фронта 100-200км	f	f	2	7225
586	за линией фронта 100-300км	f	t	3	7226
587	теплые и холодные	f	t	1	7227
587	неустойчивые и холодные	f	f	2	7228
587	устойчивые и неустойчивые	f	f	3	7229
588	воздух перед фронтом более холодный, чем за фронтом	t	f	1	7230
588	воздух перед фронтом более теплый, чем за фронтом	f	f	2	7231
588	воздух перед фронтом и за фронтом теплый	f	f	3	7232
589	различными по температуре порциями одной и той же воздушной массы	f	t	1	7233
589	различными по температуре порциями различных воздушных масс	f	f	2	7234
589	различными по образованию воздушными массами	f	f	3	7235
590	в тыловой части циклона	f	t	1	7236
590	в передней части циклона	f	f	2	7237
590	в теплом секторе циклона	f	f	3	7238
591	северного и южного полушарий	f	t	1	7239
591	умеренных и субтропических	f	f	2	7240
591	теплых и холодных	f	f	3	7241
592	грозы, шквалы, ливни, ухудшение видимости	f	t	1	7242
592	ливни, дымка, песчаная буря	f	f	2	7243
592	град, морось, песчаная мгла	f	f	3	7244
593	20-50 м/с	f	f	1	7245
593	50-70 м/с	f	f	2	7246
593	50-100 м/с	f	t	3	7247
594	20-30 км/ч	f	f	1	7248
594	10-20 км/ч	f	f	2	7249
594	100-120 км/ч	f	t	3	7250
595	тыловая часть циклона	f	f	1	7251
595	правая сторона	f	t	2	7252
595	левая сторона	f	f	3	7253
596	5-10 км	f	f	1	7254
596	10-20км	f	f	2	7255
596	около 30 км	f	t	3	7256
597	в СВ. в теплое время года, над сушей днем, над водной поверхностью - ночью	f	t	1	7257
597	в СВ, в переходный сезон, ночью	f	f	2	7258
597	в СВ ночью над сушей, в теплое время года	f	f	3	7259
598	4-6 км	f	f	1	7260
598	10-12км	f	t	2	7261
598	12-16км	f	f	3	7262
599	передней части и зоне выпадения осадков грозового облака	f	t	1	7263
599	в тыловой части грозового облака	f	f	2	7264
599	под слоистыми облаками	f	f	3	7265
600	от плюс 5 градусов до минус 10 градусов	t	f	1	7266
600	от минус 5 градусов до минус 15 градусов	f	f	2	7267
600	от нуля градусов и минус 20 градусов	f	f	3	7268
603	в зоне видимых полос выпадения осадков	f	t	1	7269
603	в средней части кучево-дождевого облака	f	f	2	7270
603	в тыловой части кучево-дождевого облака	f	f	3	7271
604	струйного течения, слоя инверсии, зон расходимости или сходимости воздушных потоков	f	t	1	7272
604	контрастов температуры и влажности	f	f	2	7273
604	вертикального градиента плотности воздуха	f	f	3	7274
605	до 2-3 км	f	t	1	7275
605	до нескольких сотен метров	f	f	2	7276
605	более 5 км	f	f	3	7277
606	8-10 км	f	f	1	7278
606	10-12 км	f	t	2	7279
606	12-14 км	f	f	3	7280
607	8-10 км	f	t	1	7281
607	10-12 км	f	f	2	7282
607	12-14 км	f	f	3	7283
608	16-18 км	t	f	1	7284
608	10-12 км	f	f	2	7285
608	12-14 км	f	f	3	7286
609	средней тропосфере	f	f	1	7287
609	верхней тропосфере и нижней стратосфере	f	t	2	7288
609	средней стратосфере	f	f	3	7289
610	более 30м/с (60 узлов) или 100 км/ч	f	t	1	7290
610	более 10м/с	f	f	2	7291
610	менее 30м/с (60 узлов) или 100 км/ч	f	f	3	7292
611	высота от 1-1.5км, ширина 500-1000км, длина тысячи км	f	t	1	7293
611	высота не более сотен метров, ширина 500-1000км, длина 1-2 км	f	f	2	7294
611	высота от 500-1000км, ширина 100-300м, длина 2-3км	f	f	3	7295
613	60 градусов 7 м/сек порывы 12м/с	f	t	1	7296
613	110 градусов 5 м/с	f	f	2	7297
613	060 - 110 градусов 7м/с порывы 12м/с	f	f	3	7298
615	устойчивое изменение метеорологических элементов	t	f	1	7299
615	неустойчивое изменение метеорологических элементов	f	f	2	7300
615	быстрое изменение метеорологических элементов	f	f	3	7301
616	без существенных изменений метеорологических элементов	t	f	1	7302
616	значительное изменение метеорологических элементов	f	f	2	7303
616	неустойчивое изменение метеорологических элементов	f	f	3	7304
617	500 м	t	f	1	7305
617	400 м	f	f	2	7306
617	1200 м	f	f	3	7307
757	Физиологический	f	f	1	7308
757	Психологический	f	f	2	7309
757	Окружающей среды	f	t	3	7310
758	Психологические, физиологические, окружающей среды	f	t	1	7311
758	Психологические, физиологические, биологические	f	f	2	7312
758	Физические, психологические, окружающей среды	f	f	3	7313
1395	ознакомительных и демонстрационных полетов авиации общего назначения	f	f	1	7314
1395	авиационных работ	f	f	2	7315
1395	коммерческих воздушных перевозок	f	t	3	7316
45	опустить общий шаг	f	t	1	7317
45	увеличить газ	f	f	2	7318
45	поднять общий шаг	f	f	3	7319
1424	четверти длины волны	f	t	1	7320
1424	половине длины волны	f	f	2	7321
1424	длине волны	f	f	3	7322
1451	амплитудная модуляция	f	t	1	7323
1451	частотная модуляция	f	f	2	7324
1451	фазовая модуляция	f	f	3	7325
806	Посадка на площадку	f	t	1	7326
806	Взлёте	f	f	2	7327
806	Посадке	f	f	3	7328
807	Только лицам с соответствующим допуском	f	f	1	7329
807	Не разрешается	f	t	2	7330
807	При соблюдении разрешенного диапазона центровки	f	f	3	7331
808	Доложить пилоту буксировщика, а затем выпустить интерцепторы	f	f	1	7332
808	Произвести отцепку	f	t	2	7333
808	Перейти в режим приборного полёта	f	f	3	7334
809	По барометрическому высотомеру	f	f	1	7335
809	По соответствующей отметке на карте	f	f	2	7336
809	Визуально	f	t	3	7337
810	Интерцепторы	f	f	1	7338
810	Опускание консоли до касания поверхности	f	t	2	7339
810	Тормоз колеса	f	f	3	7340
812	Для достижения больших скоростей	f	f	1	7341
812	Для изменения наивыгоднейшей скорости	f	t	2	7342
812	Увеличения аэродинамического качества	f	f	3	7343
814	Нет	f	f	1	7344
814	Зависит от характеристик планера	f	t	2	7345
814	Только в спокойной атмосфере	f	f	3	7346
1453	усилие не изменится	f	f	3	7577
815	Создается усилие для приведения в действие разрывного кольца на фале	f	f	1	7347
815	Производится совместная посадка планера и самолёта	f	t	2	7348
815	Планеристу выпустить полностью интерцептора с тем чтобы создать повышенное сопротивление	f	f	3	7349
816	По касательной к нижней части спирали	f	f	1	7350
816	Вход осуществляется по касательной, направление спирали, как у планеров уже в ней находящихся	f	t	2	7351
816	Вход в поток может осуществляться, если по высоте вы находитесь выше остальных пилотов-планеристов	f	f	3	7352
817	Отцепиться	f	t	1	7353
817	Энергичным движением ноги и руки в обратную сторону «поднять» планер	f	f	2	7354
817	Произвести отрыв на пониженной скорости и перевести планер на выдерживание в метре над землей	f	f	3	7355
818	Отцепиться	f	t	1	7356
818	Продолжать взлёт в пеленге	f	f	2	7357
818	Исправить пеленг энергичными движениями органов управления	f	f	3	7358
819	Взлет запрещается	f	f	1	7359
819	Слабина выбрана	f	t	2	7360
819	Слабина фала должна быть выбрана лётчиком-буксировщиком	f	f	3	7361
820	Имеющий меньшее аэродинамическое качество	f	f	1	7362
820	Находящийся на меньшей высоте	f	f	2	7363
820	Находящийся на меньшей высоте, а также идущий на посадку с фалом	f	t	3	7364
821	Многократное покачивание крыльями	f	t	1	7365
821	Однократное покачивание крыльев	f	f	2	7366
821	Уход планериста в правый пеленг и покачивание крыльев	f	f	3	7367
822	Создавая небольшой отрицательный тангаж	f	f	1	7368
822	Покачиванием крыльев	f	t	2	7369
822	Всегда решение об отцепке принимает только планерист	f	f	3	7370
823	Использовать для выдерживания курса только педали	f	f	1	7371
823	Движения органами управления должны быть более плавными	f	f	2	7372
823	Манипулировать органами управления с большей амплитудой	f	t	3	7373
1356	5-6 м/с	f	t	1	7374
1356	7-8 м/с	f	f	2	7375
1356	10-11 м/с	f	f	3	7376
1357	зажигалку	f	f	1	7377
1357	бесшумную горелку	f	t	2	7378
1357	основной огневой клапан	f	f	3	7379
1358	открыть полностью парашютный клапан, чтобы быстрее приземлиться	f	f	1	7380
1358	закрыть баллоны и приземлиться за счет естественного остывания оболочки	f	f	2	7381
1358	продолжить полет и совершить безопасную посадку, используя для включения горелки вентили на баллонах	f	t	3	7382
1359	пойти затаптывать огонь ногами/ветошью	f	f	1	7383
1359	пойти за огнетушителем	f	f	2	7384
1359	выключить вентилятор	f	t	3	7385
1360	привязать гайдроп к карабину, размотать его до самой земли, спустить по нему на землю	f	f	1	7386
1360	привязать гайдроп к ручке гондолы, размотать его до высота 1-1.5 м до земли, спустить до конца гайдропа, затем спрыгнуть	f	t	2	7387
1360	привязать гайдроп к ручке гондолы, размотать его до самой земли, спустить по нему на землю	f	f	3	7388
1361	дополнительно к стандартным действиям при посадке сбросить баллоны из корзины перед посадкой	f	t	1	7389
1361	дополнительно к стандартным действиям при посадке посадить всех пассажиров на дно корзины	f	f	2	7390
1361	выполнить действия как при обычном приземлении	f	f	3	7391
1362	утонет	f	f	1	7392
1362	останется на плаву	f	t	2	7393
1362	растворится	f	f	3	7394
1363	оболочку нужно погасить	f	f	1	7395
1363	оболочку нужно оставить наполненной	f	t	2	7396
1363	отрезать стропы от корзины	f	f	3	7397
1364	чтобы не заржавели	f	f	1	7398
1364	чтобы впоследствии быстрее отцепить оболочку, т.к. намокшая она не обладает положительной плавучестью	f	t	2	7399
1364	чтобы можно было отстегнуть оболочку и улететь на ней самостоятельно	f	f	3	7400
1365	можно просто прыгнуть вниз, 10 м – небольшая высота	f	f	1	7401
1365	можно воспользоваться гайдропом	f	t	2	7402
1365	можно расплести гондолу	f	f	3	7403
1366	согнуть ноги в коленках, держаться за ручки внутри корзины	f	f	1	7404
1366	присесть ниже бортов корзины, закрыть лицо руками, держаться за ручки внутри корзины	f	t	2	7405
1366	перед касанием деревьев выпрыгнуть из корзины на дерево	f	f	3	7406
1367	за 2-3 секунды перед касанием земли полностью открыть парашютный клапан	f	t	1	7407
1367	как можно ровнее коснуться земли и открыть парашютный клапан после касания	f	f	2	7408
1367	посадить пассажиров на дно корзины	f	f	3	7409
1368	открыть парашютный клапан, чтобы компенсировать подъем	f	f	1	7410
1368	ничего не делать	f	f	2	7411
1368	продолжать работать горелкой как при горизонтальном полете	f	t	3	7412
1369	при спуске гондола наклонилось	f	f	1	7413
1369	при спуске увеличилась горизонтальная скорость движения	f	f	2	7414
1369	появилось дуновение ветра в корзине	f	t	3	7415
1370	ничего не делать, ждать пока аэростат сам пройдет этот слой	f	f	1	7416
1370	резко воспользоваться горелкой, т.к. в противном случае из оболочки может выйти большая часть воздуха	f	f	2	7417
1370	компенсировать «ложку» по мере ее возникновения подогревом оболочки	f	t	3	7418
1371	в 12 дня и в 12 ночи	f	f	1	7419
1371	в 10 дня и в 10 вечера	f	f	2	7420
1371	через 1 час после восхода и за 1 час до заката	f	t	3	7421
1372	скорость ветра ближе к заходу солнца уменьшается	f	t	1	7422
1372	скорость ветра ближе к заходу солнца увеличивается	f	f	2	7423
1372	скорость ветра ближе к заходу солнца не изменяется	f	f	3	7424
1373	от восхода солнца до 2 часов после восхода	f	f	1	7425
1373	от восхода солнца до 3 часов после восхода	f	f	2	7426
1373	от восхода солнца до 4 часов после восхода	f	t	3	7427
1374	от 3 часов до 1 часа до заката	f	f	1	7428
1374	от 1 часа до заката солнца до самого заката	f	f	2	7429
1374	от 1.5 часов до заката солнца до 30 минут до заката	f	t	3	7430
1375	ротор	f	t	1	7431
1375	термик	f	f	2	7432
1375	смерч	f	f	3	7433
1376	не меняется	f	f	1	7434
1376	поворачивает направо	f	t	2	7435
1376	поворачивает налево	f	f	3	7436
1377	температурой конденсации	f	f	1	7437
1377	температурой испарения	f	f	2	7438
1377	точкой росы	f	t	3	7439
1378	радиационный	f	t	1	7440
1378	тепловой	f	f	2	7441
1378	переохлажденный	f	f	3	7442
1379	ожидать сильного ветра	f	f	1	7443
1379	ожидать тумана	f	t	2	7444
1379	ожидать дождь	f	f	3	7445
1380	в послеполуденное время вследствие солнечного прогрева	f	t	1	7446
1380	за 2-3 часа перед закатом солнца	f	f	2	7447
1380	утром после восхода солнца	f	f	3	7448
1381	1000-1500 м	f	f	1	7449
1381	3-7 км	f	t	2	7450
1381	10-12 км	f	f	3	7451
1382	приближении холодного фронта	f	f	1	7452
1382	приближении смены погоды	f	t	2	7453
1382	приближении дождя	f	f	3	7454
1383	слой, в котором ветер меняет направление	f	f	1	7455
1383	слой, в котором температура повышается с высотой	f	t	2	7456
1383	слой, в котором давление повышается с высотой	f	f	3	7457
1384	образование туманов	f	t	1	7458
1384	выпадение осадков	f	f	2	7459
1384	смена направления ветра	f	f	3	7460
1385	муссон	f	f	1	7461
1385	бриз	f	t	2	7462
1385	струйный ветер	f	f	3	7463
1386	через 2 часа	f	f	1	7464
1386	через 4 часа	f	t	2	7465
1386	через 6 часов	f	f	3	7466
1387	резкое изменение вертикальной скорости движения аэростата без адекватных действий горелкой	f	f	1	7467
1387	изменение скорости ветра более чем на 5 м/с на перепаде высот около 50 м	f	t	2	7468
1387	изменение направления ветра более чем на 50 градусов на перепаде высот около 50 м	f	f	3	7469
1388	положительно для всех географических точек в пределах России	f	f	1	7470
1388	различается в разных географических точках России	f	t	2	7471
1388	равно 8 градусам на восток для всех географических точек России	f	f	3	7472
1391	по направлению умозрительной линии движения	f	t	1	7473
1391	перпендикулярно умозрительной линии движения	f	f	2	7474
1391	вдоль магнитной стрелки компаса	f	f	3	7475
1393	1 км	f	f	1	7476
1393	2,4 км	f	f	2	7477
1393	3,6 км	t	f	3	7478
1394	измерив расстояние, пройденное при полете на примерно одной высоте за фиксированное время	f	t	1	7479
1394	сравнив скорость аэростата со скоростью движущихся по земле автомобилей	f	f	2	7480
1394	измерив углы между вертикальной осью аэростата и направлением на солнечный диск через фиксированный промежуток времени	f	f	3	7481
1396	высоким	f	f	1	7482
1396	низким	f	f	2	7483
1396	самым низким	f	t	3	7484
1411	1:20 000	f	f	1	7485
1411	1: 50 000	f	t	2	7486
1411	1: 200 000	f	f	3	7487
1414	45 м	f	f	1	7488
1414	175 м	f	t	2	7489
1414	625 м	f	f	3	7490
1415	распоряжением Росавиации	f	f	1	7491
1415	приказом Минтранса	f	t	2	7492
1415	главным центром ЕС ОрВд	f	f	3	7493
1425	не более 0,03 л/сек	f	f	1	7494
1425	не более 0,02 л/сек	f	t	2	7495
1425	не более 0,01 л/сек	f	f	3	7496
1426	к повышенному расходу газа	f	t	1	7497
1426	к снижению грузоподъемности	f	f	2	7498
1426	к уменьшению температуры в оболочке	f	f	3	7499
1427	в горизонтальном полете при отрицательных температурах и полной загрузке	f	f	1	7500
1427	в горизонтальном полете при положительных температурах и средней нагрузке	f	f	2	7501
1427	в горизонтальном полете при спокойной атмосфере и температуре окружающего воздуха +10:+25 градусов с нагрузкой, близкой к максимальной	f	t	3	7502
1428	при поступлении жалоб от пассажиров на сильный шум основной горелки	f	f	1	7503
1428	при горячем наполнении аэростата возле жилых строений	f	f	2	7504
1428	при пролете над скоплениями домашних животных на малой высоте	f	t	3	7505
1429	0,1	f	f	1	7506
1429	0,15	f	t	2	7507
1429	0,2	f	f	3	7508
1430	1 раз в год	f	f	1	7509
1430	1 раз в 2 года	f	f	2	7510
1430	1 раз в 10 лет	f	t	3	7511
1431	10 атм	f	t	1	7512
1431	20 атм	f	f	2	7513
1431	30 атм	f	f	3	7514
1432	5…10 атм	f	f	1	7515
1432	10…16 атм	f	f	2	7516
1432	25…30 атм	f	t	3	7517
1433	12 атм	f	f	1	7518
1433	15 атм	f	t	2	7519
1433	20 атм	f	f	3	7520
1434	специальный клапан	f	t	1	7521
1434	специальный уровнемер	f	f	2	7522
1434	специальный манометр	f	f	3	7523
1435	из контрольного клапана пошла жидкая фаза	f	t	1	7524
1435	внутреннее давление достигло 5 атм,	f	f	2	7525
1435	сработал предохранительный клапан	f	f	3	7526
1436	литола	f	f	1	7527
1436	силикона	f	t	2	7528
1436	вазелина	f	f	3	7529
1437	проверить присоединение рукавов горелки ко всем баллонам	f	t	1	7530
1437	проверить присоединение рукавов горелки к двум баллонам	f	f	2	7531
1437	можно не проверять при наличии действующего СЛГ	f	f	3	7532
1438	выложить данный баллон перед полетом	f	f	1	7533
1438	замотать соединение тряпкой	f	f	2	7534
1438	заменить прокладки в штуцере баллона	f	t	3	7535
1439	до упора	f	f	1	7536
1439	не доводя полоборота-оборот до упора	f	t	2	7537
1439	в соответствии с нормами летной годности АП-31	f	f	3	7538
1440	35% и менее	f	f	1	7539
1440	50% и менее	f	f	2	7540
1440	1	f	t	3	7541
1441	0 м/с	f	f	1	7542
1441	1-2 м/с	f	t	2	7543
1441	3-5 м/с	f	f	3	7544
1442	Установлен РЭ на аэростат	f	t	1	7545
1442	-20°С …+40°С	f	f	2	7546
1442	0°С …+40°С	f	f	3	7547
1443	3 м/с вверх и 3 м/с вниз	f	f	1	7548
1443	5 м/с вверх и 5 м/с вниз	f	f	2	7549
1443	установлен РЭ на аэростат	f	t	3	7550
1444	110 °С	f	f	1	7551
1444	120 °С	f	t	2	7552
1444	140 °С	f	f	3	7553
1445	30% максимальной взлетной массы	f	f	1	7554
1445	50% максимальной взлетной массы	f	t	2	7555
1445	70% максимальной взлетной массы	f	f	3	7556
1446	с помощью таблицы из РЛЭ	f	t	1	7557
1446	с помощью приборного блока, установленного в аэростате	f	f	2	7558
1446	руководствуясь рекомендациями ФАИ	f	f	3	7559
1447	500 м	f	t	1	7560
1447	1500 м	f	f	2	7561
1447	одинакова во всех случаях	f	f	3	7562
1448	увеличивается	f	f	1	7563
1448	уменьшается	f	t	2	7564
1448	не изменяется	f	f	3	7565
1449	увеличивается	f	t	1	7566
1449	уменьшается	f	f	2	7567
1449	не изменяется	f	f	3	7568
1450	с большей загрузкой гондолы	f	t	1	7569
1450	с меньшей загрузкой гондолы	f	f	2	7570
1450	оба одинаково	f	f	3	7571
1452	больше у аэростата объемом 2200 куб.м	f	f	1	7572
1452	больше для аэростата объемом 4000 куб.м	f	t	2	7573
1456	увеличивается	f	t	2	7585
1456	не изменяется	f	f	3	7586
1457	более 3 м/с	f	t	1	7587
1457	более 5 м/с	f	f	2	7588
1457	более 7 м/с	f	f	3	7589
1458	слоистые	f	f	1	7590
1458	перистые	f	f	2	7591
1458	кучевые	f	t	3	7592
1459	лесом	f	f	1	7593
1459	скошенным полем	f	f	2	7594
1459	распаханным полем	f	t	3	7595
1460	при значительных скоростях ветра при обтекании неровностей подстилающей поверхности	f	f	1	7596
1460	при атмосферной конвекции	f	t	2	7597
1460	при высоком вертикальном температурном градиенте	f	f	3	7598
1461	антициклонов	f	f	1	7599
1461	циклонов	f	t	2	7600
1461	горных седловин	f	f	3	7601
1462	внутримассовые и фронтальные	f	t	1	7602
1462	туманы охлаждения и испарения	f	f	2	7603
1462	радиационные и нерадицационные	f	f	3	7604
1466	АСТ	f	f	1	7605
1466	БАЛЛ	f	t	2	7606
1466	АЕЭР	f	f	3	7607
1475	нет возможности закрепить ПВД на аэростате так, чтобы не повредить ПВД при посадке	f	f	1	7608
1475	у свободного аэростата небольшие скорости относительно земли, при этом ПВД имеет большую погрешность и неэффективен	f	f	2	7609
1475	приемник воздушного давления служит для определения воздушной скорости, которой свободный аэростат, перемещаясь вместе с воздушной массой, не обладает	f	t	3	7610
1483	5 м/с	f	f	1	7611
1483	7 м/с	t	f	2	7612
1483	9 м/с	f	f	3	7613
1496	местных органов МВД	f	f	1	7614
1496	органов местного самоуправления	f	t	2	7615
1496	местного управления ФСБ	f	f	3	7616
1497	требования к минимальному приборному оборудованию свободного аэростата не установлены	f	t	1	7617
1497	магнитный компас и барометрический высотомер	f	f	2	7618
1497	магнитный компас, барометрический высотомер, хронометр с секундной стрелкой	f	f	3	7619
1505	теплового аэростата	f	f	1	7620
1505	аэростатического летательного аппарата	f	f	2	7621
1505	свободного аэростата	f	t	3	7622
1506	действующее медицинское заключение второго класса и отметка в свидетельстве о его продлении	f	f	1	7623
1506	действующее медицинское заключение второго класса, отметка в свидетельстве его о продлении и запись пилота-инструктора в летной книжке о положительном прохождении теоретической и практической проверок, выполненная не ранее 24 месяцев	f	f	2	7624
1506	действующее медицинское заключение второго класса, справка пилота-инструктора о положительном результате прохождении практической проверок, выполненная не ранее 24 месяцев	f	t	3	7625
1507	14 лет	f	f	1	7626
1507	16 лет	f	t	2	7627
1507	18 лет	f	f	3	7628
1508	12 часов	f	f	1	7629
1508	16 часов	f	t	2	7630
1508	20 часов	f	f	3	7631
1509	троса оболочки закреплены к карабину с перехлестом	f	f	1	7632
1509	резьбовые муфты карабинов не завернуты	f	t	2	7633
1509	горячее наполнение начато при не полностью закрепленном парашютном клапане	f	f	3	7634
1510	свободный конец фала управления не прикреплен к аэростату до начала горячего наполнения	f	f	1	7635
1510	холодное наполнение проведено не полностью, горячее наполнение начато, как только появилась возможность производить подогрев воздуха	f	t	2	7636
1510	В начале горячего наполнения в вентиляторе закончился бензин	f	f	3	7637
1511	пилот не проверил парашютный клапан перед стартом и не сделал этого до окончательной посадки	f	t	1	7638
1511	пилот не проверил парашютный клапан перед стартом, но сделал это сразу после отрыва корзины от земли	f	f	2	7639
1511	пилот не проверил парашютный клапан перед стартом, но сделал это в полете на высоте 300 метров AGL	f	f	3	7640
1512	оболочка разложена под углом к приземному ветру	f	f	1	7641
1512	оболочка разложена против приземного ветра	f	f	2	7642
1512	оболочка разложена близко к препятствиям	f	t	3	7643
1513	загрузить аэростат и, подняв его на стартовом фале на время не менее 5 минут, сделать вывод о возможности полета	f	f	1	7644
1513	спокойно начинать полет, такт как оболочка аэростат «прощает» и большие повреждения, но принять во внимание повышенный расход газа	f	f	2	7645
1547	горизонтальные силовые ленты	f	f	2	7723
1513	прекратить полет, сложить оболочку и отремонтировать ее собственными силами, использую ЗИП. При отсутствии такой возможности – отказаться от полета	f	t	3	7646
1514	150 м. Х 1500 м	f	f	1	7647
1514	150 м. Х 2000 м	f	t	2	7648
1514	200 м Х 2000 м	f	f	3	7649
1515	30-50 м	f	f	1	7650
1515	70-100 м	f	f	2	7651
1515	200-300 м	f	t	3	7652
1516	скорость ветра у земли	f	f	1	7653
1516	скорость ветра на максимальной планируемой высоте полета	f	f	2	7654
1516	среднюю скорость ветра по высотам	f	t	3	7655
1517	тот, который ниже	f	f	1	7656
1517	тот, который выше	f	t	2	7657
1517	пилоты должны договориться по радиосвязи	f	f	3	7658
1518	аэростаты	f	f	1	7659
1518	моторные воздушные суда	f	t	2	7660
1518	пилоты, должны договориться по радиосвязи	f	f	3	7661
1521	у задней стенки гондолы	f	f	1	7662
1521	у передней стенки гондолы	f	f	2	7663
1521	у боковой стенки между баллонами со стороны фала управления парашютным клапаном	f	t	3	7664
1522	сесть на дно гондолы	f	f	1	7665
1522	согнуть ноги в коленках и встать у передней стенки гондолы	f	f	2	7666
1522	согнуть ноги в коленках, встать спиной по ходу движения и взяться за ручки внутри гондолы	f	t	3	7667
1523	в любых перчатках	f	f	1	7668
1523	без перчаток	f	f	2	7669
1523	в кожаных перчатках	f	t	3	7670
1524	200 м	f	f	1	7671
1524	500 м	f	f	2	7672
1524	1000 м	f	t	3	7673
1525	термик	f	f	1	7674
1525	ротор	f	t	2	7675
1525	циклон	f	f	3	7676
1526	в конце февраля	f	f	1	7677
1526	в начале-середине марта	f	t	2	7678
1526	в начале апреля	f	f	3	7679
1527	надевать респиратор	f	f	1	7680
1527	ставить рядом ведро с водой	f	f	2	7681
1527	установить воздухозаборник в полетное положение	f	t	3	7682
1528	нужно не работать горелкой	f	f	1	7683
1528	нужно работать горелкой как при горизонтальном полете	f	t	2	7684
1528	нужно открыть парашютный клапан, чтобы сохранить желаемую высоту полета	f	f	3	7685
1529	может порваться ткань	f	f	1	7686
1529	может выдавить парашютный клапан	f	t	2	7687
1529	может схлопнуться горловина	f	f	3	7688
1532	да	f	t	1	7689
1532	нет	f	f	2	7690
1532	При наличии специальной квалификационной отметки	f	f	3	7691
1533	объемом оболочки не более 3500 куб.м	f	t	1	7692
1533	объемом оболочки не более 4000 куб.м	f	f	2	7693
1533	объемом оболочки не более 4500 куб.м	f	f	3	7694
1534	массой незагруженного аэростата не более 350 кг и количеством людей не более 4	f	f	1	7695
1534	массой незагруженного аэростата не более 450 кг и количеством людей не более 5	f	t	2	7696
1534	массой незагруженного аэростата не более 550 кг и количеством людей не более 6	f	f	3	7697
1539	один раз в год или через 100 летных часов при проведении ТО силами специалистов	f	f	1	7698
1539	после каждого полета, условия которого вызывают подозрения в сохранении прочности оболочки (например, перегреве, силами пилота	f	f	2	7699
1539	в соответствии с Регламентом ТО конкретного ВС	f	t	3	7700
1540	по самой темной ткани по утку	f	f	1	7701
1540	по каждому цвету	f	f	2	7702
1540	по каждому цвету по утку и основе	f	t	3	7703
1541	представить вырезанные образцы ткани сертифицированную организацию	f	f	1	7704
1541	представить вырезанные образцы на завод-изготовитель аэростата	f	f	2	7705
1541	иметь рекомендуемое заводом-изготовителем аэростата приспособление	f	t	3	7706
1542	10 кг	f	f	1	7707
1542	14 кг	f	t	2	7708
1542	20 кг	f	f	3	7709
1543	первой горизонтальной силовой ленты	f	t	1	7710
1543	второй горизонтальной силовой ленты	f	f	2	7711
1543	выше первой горизонтальной силовой ленты рекламного пояса	f	f	3	7712
1544	водой	f	t	1	7713
1544	воздухом	f	f	2	7714
1544	азотом	f	f	3	7715
1545	водой	f	f	1	7716
1545	воздухом или азотом	f	t	2	7717
1545	метаном	f	f	3	7718
1546	да	f	f	1	7719
1546	да, если это сочетание оговорено в РЛЭ	f	t	2	7720
1546	нет, они не совместимы	f	f	3	7721
1547	вертикальные силовые ленты	f	t	1	7722
1570	меньше	f	f	2	7789
1547	ткань оболочки	f	f	3	7724
1548	восприятия нагрузки от внутреннего давления	f	f	1	7725
1548	восприятия нагрузки от боковых порывов ветра, турбулентности	f	f	2	7726
1548	локализации возможного разрыва оболочки	f	t	3	7727
1549	чем больше скорость подъема и загрузка аэростата, тем меньше усилие на фале управления	f	f	1	7728
1549	чем больше скорость подъема и загрузка аэростата, тем больше усилие на фале управления	f	f	2	7729
1549	чем больше скорость подъема и меньше загрузка аэростата, тем меньше усилие на фале управления	f	t	3	7730
1550	за такелажные петли в нижней части гондолы	f	f	1	7731
1550	за силовые карабины оболочки или гондолы	f	f	2	7732
1550	за силовые карабины гондолы и оболочки одновременно	f	t	3	7733
1551	автомобилю сопровождения аэростата с желтым проблесковым маячком	f	f	1	7734
1551	автомобилю сопровождения ГИБДД с синим и красным проблесковыми маячками	f	f	2	7735
1551	любому подходящему удерживающему устройству, способному безопасно выдерживать нагрузку не менее 4 тонн	f	t	3	7736
1552	разрывная нагрузка не менее 4 тонн	f	f	1	7737
1552	гибкость и эластичность	f	f	2	7738
1552	любой материал, удовлетворяющий условиям А и Б	f	t	3	7739
1553	измеритель температуры	f	f	1	7740
1553	термометр	f	f	2	7741
1553	индикатор перегрева	f	t	3	7742
1554	тепловизор	f	t	1	7743
1554	беспроводной измеритель температуры	f	f	2	7744
1554	индикатор перегрева	f	f	3	7745
1555	чтобы при сильном ударе о землю не разрушалась вся гондола сразу	f	f	1	7746
1555	чтобы гондола лучше держалась на плаву при приводнении	f	f	2	7747
1555	чтобы пассажиры были безопасно размещены и имели больше опоры и защиты	f	t	3	7748
1556	пластик	f	f	1	7749
1556	виноградная лоза	f	f	2	7750
1556	ротанг	f	t	3	7751
1557	мгновенный расход топлива	f	f	1	7752
1557	давление на срезе форсунок	f	f	2	7753
1557	давление топлива в газовых баллонах	f	t	3	7754
1558	недостаточная мощность нагрева	f	f	1	7755
1558	короткое обжигающее пламя	f	f	2	7756
1558	возможность обмерзания и заклинивания огневого клапана	f	t	3	7757
1559	у однофазной горелки на раме размещена одна горелка, а у двухфазной две	f	f	1	7758
1559	в двухфазной схеме питание основной горелки происходит от жидкой фазы, а дежурной – от газовой, в однофазной схеме - обе горелки питаются от жидкой фазы	f	t	2	7759
1559	для двухфазной горелки необходимо четыре газовых баллона, а для однофазной только два	f	f	3	7760
1560	могут использоваться только однофазные баллоны	f	f	1	7761
1560	могут использоваться только двухфазные баллоны	f	f	2	7762
1560	могут использоваться любые баллоны	f	t	3	7763
1561	могут использоваться только двухфазные баллоны	f	f	1	7764
1561	количество двухфазных баллонов определено РЭ на аэростат	f	t	2	7765
1561	могут использоваться любые баллоны при условии, что среди них имеется хотя бы один двухфазный баллон	f	f	3	7766
1562	потому, что избыточное давление азота сразу падает при открытии крана дежурной горелки	f	f	1	7767
1562	потому, что смесь азота и пропана не горит	f	t	2	7768
1562	потому, что азот не смешивается с жидким пропаном	f	f	3	7769
1564	да	f	f	1	7770
1564	нет, при исправном обратном клапане	f	t	2	7771
1564	нет, ни при каких обстоятельствах	f	f	3	7772
1565	прямой клапан	f	f	1	7773
1565	обратный клапан	f	t	2	7774
1565	двухсторонний клапан	f	f	3	7775
1566	индикатор, показывающий максимальную достигнутую температуру за период эксплуатации оболочки	f	t	1	7776
1566	индикатор, показывающий среднюю температуру за период эксплуатации оболочки	f	f	2	7777
1566	индикатор, показывающий максимальную достигнутую температуру за предыдущий полет	f	f	3	7778
1567	5-10 м	f	f	1	7779
1567	10-30 м	f	t	2	7780
1567	50-100 м	f	f	3	7781
1568	3-7 м	f	t	1	7782
1568	10-30 м	f	f	2	7783
1568	50-100 м	f	f	3	7784
1569	от среднего уровня моря	f	f	1	7785
1569	от уровня земли	f	f	2	7786
1569	от уровня установленного эллипсоида	f	t	3	7787
1570	больше	f	t	1	7788
1571	чтобы поворачиваться лучшим ракурсом в объективы фотокамер	f	f	1	7791
1571	чтобы дать возможность всем пассажирам рассмотреть окрестности со всех сторон	f	f	2	7792
1571	чтобы ориентировать гондолу при посадке	f	t	3	7793
1572	увеличивается	f	f	1	7794
1572	уменьшается	f	t	2	7795
1572	не изменяется	f	f	3	7796
1573	увеличивается	f	f	1	7797
1573	уменьшается	f	t	2	7798
1573	не изменяется	f	f	3	7799
1574	увеличивается	f	f	1	7800
1574	уменьшается	f	t	2	7801
1574	не изменяется	f	f	3	7802
1575	увеличивается	f	t	1	7803
1575	уменьшается	f	f	2	7804
1575	не изменяется	f	f	3	7805
1576	никак	f	f	1	7806
1576	с увеличением загрузки потребная температура уменьшается	f	f	2	7807
1576	с увеличением загрузки потребная температура увеличивается	f	t	3	7808
1577	3.5 °С	f	f	1	7809
1577	5.5 °С	f	f	2	7810
1577	6.5 °С	f	t	3	7811
1578	увеличивается к верхней части оболочки аэростата	f	t	1	7812
1578	уменьшается к верхней части оболочки аэростата	f	f	2	7813
1578	не изменяется по всей высоте оболочки аэростата	f	f	3	7814
1579	увеличивается	f	t	1	7815
1579	уменьшается	f	f	2	7816
1579	не изменяется	f	f	3	7817
1580	одна, сила тяжести	f	f	1	7818
1580	две, сила тяжести и подъемная сила	f	t	2	7819
1580	три, сила тяжести, центробежная сила и подъемная сила	f	f	3	7820
1581	одна, сила тяжести	f	f	1	7821
1581	две, сила тяжести и подъемная сила	f	t	2	7822
1581	три, сила тяжести, сила, возникающая от воздействия набегающего воздушного потока, и подъемная сила	f	f	3	7823
1582	обтекание невозмущенным воздухом без деформации оболочки	f	f	1	7824
1582	обтекание турбулентным воздушным потоком без деформации оболочки	f	f	2	7825
1582	обтекание турбулентным потоком с образованием на аэростате «ложки»	f	t	3	7826
1583	три, сила тяжести, подъемная сила ,сила, возникающая из-за привязного фала	f	f	1	7827
1583	четыре, сила тяжести, подъемная сила ,сила, возникающая из-за привязного фала, сила Кориолиса	f	f	2	7828
1583	четыре, сила тяжести, подъемная сила ,сила, возникающая из-за привязного фала, сила, возникающая от воздействия набегающего воздушного потока	f	t	3	7829
1584	да	f	t	1	7830
1584	нет	f	f	2	7831
1584	Как единица деленная но косинус угла	f	f	3	7832
1585	аэростат не поднимется	f	f	1	7833
1585	при больших углах отклонения привязного фала относительно земли возможен перегрев оболочки	f	t	2	7834
1585	будет больше «ложка»	f	f	3	7835
1586	при взлете в любую погоду	f	f	1	7836
1586	в случаях, когда скорость ветра у земли и скорость ветра на высоте 20-30 м значительно различаются	f	t	2	7837
1586	когда взлет производится с механизма отцепки	f	f	3	7838
1587	увеличивается	f	t	1	7839
1587	уменьшается	f	f	2	7840
1587	в данных условиях ложная подъемная сила не возникает	f	f	3	7841
1588	потери из-за конвективного теплообмена	f	t	1	7842
1588	потери тепла из-за продуваемости оболочки	f	f	2	7843
1588	потери тепла из-за лучистого теплообмена	f	f	3	7844
1589	увеличивается	f	t	1	7845
1589	уменьшается	f	f	2	7846
1589	не изменяется	f	f	3	7847
1590	увеличивается	f	t	1	7848
1590	уменьшается	f	f	2	7849
1590	не изменяется	f	f	3	7850
1591	оболочке большего объема	f	t	1	7851
1591	оболочке меньшего объема	f	f	2	7852
1591	будет одинаковым	f	f	3	7853
1592	0.25 литра	f	f	1	7854
1592	0.5 литр	f	f	2	7855
1592	1 литр	f	t	3	7856
1593	во время ночного полета	f	t	1	7857
1593	во время утреннего полета	f	f	2	7858
1593	одинаков	f	f	3	7859
1594	почти у самой ее верхушки	f	t	1	7860
1594	на высоте 0.3 от полной высоты	f	f	2	7861
1594	на высоте 0.5. от полной высоты	f	f	3	7862
1595	1-2%	f	f	1	7863
1595	2-3%	f	f	2	7864
1595	4-7%	f	t	3	7865
1596	меньше, чем внутри оболочки	f	t	1	7866
1596	больше, чем внутри оболочки	f	f	2	7867
1596	равна температуре внутри оболочки	f	f	3	7868
1597	азотом	f	f	1	7869
1597	метаном	f	t	2	7870
1597	Углекислым газом	f	f	3	7871
1598	водород	f	t	1	7872
1598	гелий	f	f	2	7873
1598	теплый воздух	f	f	3	7874
1599	гелий	f	f	1	7875
1599	водород	f	t	2	7876
1599	оба	f	f	3	7877
1600	пропан	f	f	1	7878
1600	бутан	f	f	2	7879
1600	воздух	f	t	3	7880
1601	перевернуть баллон за сутки до полета	f	f	1	7881
1601	сильно потрясти баллон перед полетом	f	f	2	7882
1601	дозаправить баллон метаном или азотом	f	t	3	7883
1602	азот	f	f	1	7884
1602	метан	f	t	2	7885
1602	водород	f	f	3	7886
1603	азот	f	f	1	7887
1603	метан	f	t	2	7888
1603	аргон	f	f	3	7889
1604	мастер-баллоне (баллоне, питающем дежурную горелку)	f	t	1	7890
1604	обычном баллоне	f	f	2	7891
1604	в обоих одинаково	f	f	3	7892
251	высота от выбранного уровня, например ВПП, до объекта (воздушного судна), относительно которого производится измерение	t	f	1	7893
251	высота, выдерживаемая по барометрическому высотомеру относительно стандартного давления (760 мм.рт.ст. или 1013 мбар)	f	f	2	7894
251	высота относительно точки на земной поверхности, расположенной непосредственно под воздушным судном (самолетом, вертолетом, автожиром и т.п.) в момент пролета	f	f	3	7895
1051	структура и функционирование научного знания	f	f	1	7896
1051	потенциальные и реальные возможности человека	f	t	2	7897
1051	массовидные социально-психологические явления	f	f	3	7898
1052	квалификация руководителей всех уровней управления	f	f	1	7899
1052	система планирования организации	f	f	2	7900
1052	оптимизация отношений между персоналом по обслуживанию	f	t	3	7901
1053	любое участие человека в авиации	f	t	1	7902
1053	гибкое регулирование и своевременные изменения в организации	f	f	2	7903
1053	профессиональное взаимодействие конкретной социальной обстановки	f	f	3	7904
1054	волевое поведение	f	f	1	7905
1054	деловое поведение	f	f	2	7906
1054	ролевое поведение	f	t	3	7907
1055	оказание помощи всему персоналу в области обслуживания	f	f	1	7908
1055	повышение уровня жизни	f	f	2	7909
1055	понимание своих ограниченных возможностей в трудовой деятельности, а также других людей	f	t	3	7910
1056	критика и самокритика	f	f	1	7911
1056	личный пример руководителя	f	t	2	7912
1056	информирование и инструктирование	f	f	3	7913
1057	неточности в переговорах между экипажем и диспетчером	f	f	1	7914
1057	деятельность человека	f	t	2	7915
1057	недостаточный или неправильный прогноз погоды	f	f	3	7916
1058	кофе	f	f	1	7917
1058	алкоголь	f	t	2	7918
1058	газированная вода	f	f	3	7919
1059	красного и зеленого	f	t	1	7920
1059	зеленого и желтого	f	f	2	7921
1059	красного и синего	f	f	3	7922
1060	этноцентризм	f	f	1	7923
1060	конформизм	f	f	2	7924
1060	доброжелательная и деловая критика	f	t	3	7925
1061	искусство фокусировать внимание на одном источнике, не отвлекаясь	f	f	1	7926
1061	возможность рассматривать несколько источников информации, уделяя внимание одному или нескольким наиболее важным источникам	f	t	2	7927
1061	состояние поддерживать внимание и оставаться наготове длительное время при выполнении одного задания	f	f	3	7928
1062	состояние поддерживать внимание и оставаться наготове длительное время при выполнении одного задания	f	f	1	7929
1062	возможность выполнить множество заданий в одно время	f	t	2	7930
1062	искусство фокусировать внимание на одном источнике, не отвлекаясь	f	f	3	7931
1063	состояние поддерживать внимание и оставаться наготове длительное время при выполнении одного задания	f	f	1	7932
1063	возможность выполнить множество заданий в одно время	f	f	2	7933
1063	искусство фокусировать внимание на одном источнике, не отвлекаясь	f	t	3	7934
1064	состояние поддерживать внимание и оставаться наготове длительное время при выполнении одного задания	f	t	1	7935
1064	возможность выполнить множество заданий в одно время	f	f	2	7936
1064	искусство фокусировать внимание на одном источнике, не отвлекаясь	f	f	3	7937
1065	знания текущей ситуации	f	t	1	7938
1065	взглядов человека	f	f	2	7939
1065	кодификации	f	f	3	7940
1066	регистрации	f	t	1	7941
1066	коммуникации	f	f	2	7942
1066	интуиции	f	f	3	7943
1067	содержание информации	f	f	1	7944
1067	поток непосредственных переживаний	f	f	2	7945
1067	ввод информации в память	f	t	3	7946
1068	восстановление хранящейся информации	f	f	1	7947
1068	содержание информации	f	t	2	7948
1068	поток непосредственных переживаний	f	f	3	7949
1069	ввод информации в память	f	f	1	7950
1069	формирование художественных образов	f	f	2	7951
1069	восстановление хранящейся информации	f	t	3	7952
1070	6 секунд	f	f	1	7953
1070	8 секунд	f	t	2	7954
1070	10 секунд	f	f	3	7955
1071	от 2-х до 8 секунд	f	t	1	7956
1071	от 3-х до 5 секунд	f	f	2	7957
1071	от 5-ти до 10 секунд	f	f	3	7958
1072	от 1 до 2 секунд	f	f	1	7959
1072	от 0,5 до 1 секунды	f	t	2	7960
1072	от 2-х до 8 секунд	f	f	3	7961
1073	от 10 до 20 секунд	f	t	1	7962
1073	от 5 до 10 секунд	f	f	2	7963
1073	от 20 до 30 секунд	f	f	3	7964
1074	об особых событиях (предыдущий опыт)	f	f	1	7965
1074	общего плана	f	t	2	7966
1074	негативного характера	f	f	3	7967
1075	фактическое знание окружающего мира (концепции, правила)	f	f	1	7968
1075	не связанную с местом и временем	f	f	2	7969
1075	об особых событиях (предыдущий опыт)	f	t	3	7970
1076	страх потерять работу	f	f	1	7971
1076	страх нахождения в замкнутом пространстве	f	t	2	7972
1076	боязнь высоты	f	f	3	7973
1077	внутренняя политика компании по техническому обслуживанию	f	t	1	7974
1077	качество работы сотрудников	f	f	2	7975
1077	хорошие взаимоотношения на производстве	f	f	3	7976
1078	личную безопасность	f	f	1	7977
1078	страх потерять работу	f	f	2	7978
1078	плохие отношения на производстве	f	t	3	7979
1079	знание потенциала работников	f	f	1	7980
1079	чувство ответственности каждого члена группы за конечный результат работы группы	f	t	2	7981
1079	чувство ответственности членов группы за часть проделанной работы	f	f	3	7982
1080	все члены группы отвечают за конечный результат	f	f	1	7983
1080	ни один из работников не чувствует лично себя ответственным за безопасность	f	t	2	7984
1080	один из членов группы несет ответственность за конечный результат	f	f	3	7985
1081	внутригрупповой конфликт	f	f	1	7986
1081	достижение цели	f	f	2	7987
1081	применение группового мышления	f	t	3	7988
1082	игнорированием опасности при выполнении работы	f	f	1	7989
1082	желанием обеспечивать безопасность	f	t	2	7990
1082	дополнительной оплатой труда	f	f	3	7991
1083	культура, пол, самоуважение	f	t	1	7992
1083	бесцельная работа, спорные приказы и инструкции	f	f	2	7993
1083	монотонная и повторяющаяся работа, работа в изоляции	f	f	3	7994
1084	личной культуры	f	f	1	7995
1084	культуры безопасности	f	t	2	7996
1084	культуры быта	f	f	3	7997
1085	социальные роли и техническая практика	f	t	1	7998
1085	процесс перцепции	f	f	2	7999
1085	побуждение к деятельности	f	f	3	8000
1086	положительная мотивация	f	f	1	8001
1086	стимулирование	f	f	2	8002
1086	постоянная система информации (Reporting)	f	t	3	8003
1087	культура общения	f	f	1	8004
1087	культура быта	f	f	2	8005
1087	культура информирования	f	t	3	8006
1088	альтруизм	f	f	1	8007
1088	конформизм	f	f	2	8008
1088	кооперация	f	t	3	8009
1089	обучение навыкам планирования, экономического анализа	f	f	1	8010
1089	обеспечение безопасности при временном недостатке рабочей силы	f	t	2	8011
1089	обучение манере вести себя в ситуациях делового общения	f	f	3	8012
1090	улучшение условий жизни и труда	f	f	1	8013
1090	знание сильных и слабых сторон работников	f	t	2	8014
1090	стремление к инновациям	f	f	3	8015
1091	мотивирует членов бригады на выполнение работ	f	t	1	8016
1091	обладает пассивной стратегией	f	f	2	8017
1091	отсутствует стратегическое мышление	f	f	3	8018
698	используется в особых случаях	f	f	3	8582
1092	отвечать требованиям в процессе коммуникации	f	f	1	8019
1092	отвечать требованиям в отношении возраста	f	t	2	8020
1092	наличие креативности	f	f	3	8021
1093	моральное состояние	f	t	1	8022
1093	рефлексия	f	f	2	8023
1093	дождливая погода	f	f	3	8024
1094	психологические препятствия на пути эффективной организации взаимодействия	f	f	1	8025
1094	психологическое напряжение, возникающее при воздействии внутренних или внешних раздражителей	f	t	2	8026
1094	астеническое состояние (отрицательные чувства)	f	f	3	8027
1095	одиночество: физическое и психологическое	f	t	1	8028
1095	дефицит или переизбыток информации	f	f	2	8029
1095	отсутствие креативного мышления	f	f	3	8030
1096	перцепция – процесс взаимного восприятия партнеров, формирование отношений между ними	f	f	1	8031
1096	защита – процесс, включающий технику релаксации, а также медикаментозное лечение	f	t	2	8032
1096	коммуникация – процесс взаимодействия людей	f	f	3	8033
1097	динамические характеристики работы	f	f	1	8034
1097	временные ограничения или проблема недостатка времени	f	t	2	8035
1097	тарифное рабочее время	f	f	3	8036
1098	стремление подчинить своему влиянию партнеров	f	f	1	8037
1098	нормы культуры, при которой вырабатываются методы сокращения времени при выполнении операций	f	t	2	8038
1098	ориентация на достижение успеха в деятельности	f	f	3	8039
1099	приоритет работ, которые должны быть выполнены	f	t	1	8040
1099	высокую самооценку и стремление к самореализации	f	f	2	8041
1099	боязнь ответственности за принятие (или непринятие) решений	f	f	3	8042
1100	умения культурно вести себя	f	f	1	8043
1100	правил, законов и принципов, выработанных группой	f	f	2	8044
1100	условий, при которых выполняется работа	f	t	3	8045
1101	заданиями, которые инженер воспринимает как монотонные, очень простые, или просто отсутствием заданий	f	t	1	8046
1101	недостаточным производственным опытом	f	f	2	8047
1101	невысоким уровнем профессиональной подготовки	f	f	3	8048
1102	необходимые навыки, профессионализм и опыт для выполнения задач в отведенное время	f	t	1	8049
1102	наличие управленческих способностей	f	f	2	8050
1102	систему мер контроля и регуляции индивидов в группе	f	f	3	8051
1103	умение пользоваться авторитетом и властью	f	f	1	8052
1103	гуманное отношение к работникам	f	f	2	8053
1103	двойную предполетную проверку пилотом всех систем самолета	f	t	3	8054
1104	производился аварийный выпуск шасси	f	f	1	8055
1104	полное обжатие амортизатора – «грубая» посадка	f	t	2	8056
1104	избыточное давление газа в амортизаторе	f	f	3	8057
1106	системы управления рулём высоты, рулём направления и стабилизатором	f	f	1	8058
1106	системы управления рулём высоты, рулём направления и элеронами	f	f	2	8059
1106	системы управления рулём высоты, рулём направления, внутренними элеронами и интерцепторами	f	t	3	8060
1107	фюзеляж, крыло, хвостовое оперение, гондолы двигателей, гондолы шасси	f	t	1	8061
1107	фюзеляж, хвостовое оперение, гондолы шасси, гондолы двигателей	f	f	2	8062
1107	крыло, хвостовое оперение, гондолы двигателей, гондолы шасси	f	f	3	8063
1108	резиновыми профилями	f	t	1	8064
1108	резиновыми профилями и герметиком	f	f	2	8065
1108	герметиком	f	f	3	8066
1109	штурвальная колонка	f	f	1	8067
1109	педали	f	t	2	8068
1109	штурвал	f	f	3	8069
1110	болтом	f	f	1	8070
1110	сектором	f	f	2	8071
1110	тендерами	t	f	3	8072
1111	создают нагрузки на командных органах системы пропорциональные управлению руля	f	t	1	8073
1111	ограничивают отклонение	f	f	2	8074
1111	уменьшают шарнирный момент на рулях	f	f	3	8075
1112	быстрого запуска ВСУ на земле	f	t	1	8076
1112	быстрого запуска в полете	f	f	2	8077
1112	исключения образования конденсата	f	f	3	8078
1113	после каждого полета	f	t	1	8079
1113	в базовом порту	f	f	2	8080
1113	после 10 часов полета	f	f	3	8081
1114	обратным клапаном	f	f	1	8082
1114	датчиком топливомера	f	f	2	8083
1114	предохранительным поплавковым клапаном	f	t	3	8084
1123	сначала в воздухо-воздушном теплообменнике, затем в турбохолодильнике	f	f	1	8085
1123	сначала в турбохолодильнике, потом в воздухо-воздушном теплообменнике	f	f	2	8086
1123	в турбохолодильнике	f	t	3	8087
1124	4,5 км	f	t	1	8088
1124	8 км	f	f	2	8089
1124	12 км	f	f	3	8090
1125	температуры стеновых панелей гермокабины	f	f	1	8091
1125	температуры панелей пола	f	f	2	8092
1125	температуры воздуха в системе кондиционирования	f	t	3	8093
1126	термопара	f	t	1	8094
1126	мембрана	f	f	2	8095
1126	фотоэлемент	f	f	3	8096
1127	переносной огнетушитель	f	f	1	8097
1127	стационарная пожарная система	f	t	2	8098
1127	система нейтрального газа	f	f	3	8099
1128	переносной огнетушитель	f	f	1	8100
1128	стационарная пожарная система	f	t	2	8101
1128	система нейтрального газа	f	f	3	8102
1129	углекислота	f	f	1	8103
1129	состав «3,5»	f	f	2	8104
1129	фреон (хладон)	f	t	3	8105
1130	автоматически	f	f	1	8106
1130	вручную в момент касания	f	f	2	8107
1130	вручную по команде командира ВС	f	t	3	8108
1131	воздушно-тепловая	f	f	1	8109
1131	электротепловая	f	t	2	8110
1131	электроимпульсная	f	f	3	8111
1132	защиты от коррозии	f	f	1	8112
1132	для исключения поражения током людей	f	f	2	8113
1132	исключения искровых разрядов	f	t	3	8114
1133	автоматом тяги	f	f	1	8115
1133	автоштурвалом	f	f	2	8116
1133	автопилотом	f	t	3	8117
1134	оба	f	f	1	8118
1134	левый	f	t	2	8119
1134	правый	f	f	3	8120
1135	опора убрана и зафиксирована	f	f	1	8121
1135	опора снята с замка и находится в движении	f	f	2	8122
1135	опора выпущена и зафиксирована	f	t	3	8123
1136	возможность аварийного выпуска «собственным весом»	f	t	1	8124
1136	простота конструкции опоры	f	f	2	8125
1136	улучшение аэродинамики крыла	f	f	3	8126
1137	рулевые приводы	f	t	1	8127
1137	стеклоочистители	f	f	2	8128
1137	механизм поворота колес передней опоры шасси	f	f	3	8129
1138	выброс жидкости из гидробака	f	f	1	8130
1138	ударный характер работы гидроцилиндров	f	f	2	8131
1138	эрозийный износ гидронасоса и пульсация давления	f	t	3	8132
1139	дисковых	f	t	1	8133
1139	камерных	f	f	2	8134
1139	колодочных	f	f	3	8135
1140	воспринимать посадочные нагрузки	f	t	1	8136
1140	смягчать удар	f	f	2	8137
1140	рассеивать энергию удара	f	f	3	8138
1141	воспринимать посадочные нагрузки	f	f	1	8139
1141	смягчать удар	f	t	2	8140
1141	рассеивать энергию удара	f	f	3	8141
1142	крыла	f	f	1	8142
1142	передней стойки шасси	f	t	2	8143
1142	основных стоек шасси	f	f	3	8144
1143	жидкостно-газовые	f	t	1	8145
1143	пружинно-фрикционные	f	f	2	8146
1143	резиново-фрикционные	f	f	3	8147
1144	предохранительный клапан	f	t	1	8148
1144	порционер	f	f	2	8149
1144	дозатор	f	f	3	8150
1145	гидроаккумулятора	f	t	1	8151
1145	бортовой насосной станции	f	f	2	8152
1145	аэродромной тележки	f	f	3	8153
1146	силовая межлонжеронная коробка крыла	f	f	1	8154
1146	топливная емкость в крыле	f	t	2	8155
1146	внутрифюзеляжная часть крыла	f	f	3	8156
1147	обдув стекол и стеклоочистители	f	f	1	8157
1147	система осушения	f	f	2	8158
1147	обдув стекол, электрообогрев, стеклоочистители	f	t	3	8159
1148	компенсацией	f	f	1	8160
1148	кавитацией	f	t	2	8161
1148	конвекцией	f	f	3	8162
1149	Снижает гидравлические потери потока на входе в первое РК	f	f	1	8163
1149	Направляет поток под определённым углом на первое РК	f	f	2	8164
1149	Создаёт предварительную закрутку воздуха с целью увеличения окружной скорости и напорности компрессора	f	t	3	8165
1150	Выявляет условия обледенения воздухозаборника и ВНА компрессора	f	t	1	8166
1150	Подаёт горячий воздух компрессора на обогрев воздухозаборника и ВНА	f	f	2	8167
1150	Уменьшает режим работы двигателя	f	f	3	8168
699	в ПДО	f	f	1	8583
699	в цехе ОТО	f	f	2	8584
1151	Недостаточная поперечная жёсткость, склонность к вибрации и изменению зазоров и уплотнений, сложность производства, монтажа и демонтажа	f	t	1	8169
1151	Ограниченная окружная скорость, недостаточная прочность, невозможность менять число лопаток	f	f	2	8170
1151	Плохая ремонтопригодность, повышенный уровень шума	f	f	3	8171
1152	Хорошая ремонтопригодность, низкие требования к точности обработки	f	f	1	8172
1152	Хорошо согласует диаметр турбины с диаметром компрессора, надёжность работы при больших окружных скоростях	f	f	2	8173
1152	Высокая изгибная жёсткость, простота конструкции и технологии изготовления, невысокая стоимость	f	t	3	8174
1153	Совокупность ВНА и НА	f	f	1	8175
1153	Совокупность НА и РК	f	f	2	8176
1153	Совокупность РК и НА	f	t	3	8177
1154	Увеличивается	f	f	1	8178
1154	Уменьшается	f	t	2	8179
1154	Остаётся постоянной	f	f	3	8180
1155	Достаточная прочность крепления, простота изготовления, надёжность в работе, малая масса; позволяет разместить большое число лопаток	f	t	1	8181
1155	Могут работать при высоких температурах и нагрузках	f	f	2	8182
1155	Имеют хорошие демпфирующие свойства	f	f	3	8183
1156	Температур наружного воздуха меньше 0°С	f	f	1	8184
1156	Большая влажность воздуха	f	f	2	8185
1156	Температура воздуха 3-5°С и ниже; большая влажность воздуха	f	t	3	8186
1157	На принципе увеличения перепада давления на каждом гребешке	f	f	1	8187
1157	На многократном дросселировании газа, протекающего через каналы с резко изменяющимися проходными сечениями	f	t	2	8188
1157	На принципе уменьшения перепада давления на каждом гребешке	f	f	3	8189
1158	Задевание рабочих лопаток за корпус или НА, дефекты подшипников ротора	f	t	1	8190
1158	Разрушение лопаток компрессора, коррозия и эрозия лопаток	f	f	2	8191
1158	Выработка ресурса ротора	f	f	3	8192
1159	Центробежные	f	f	1	8193
1159	Осевые	f	t	2	8194
1159	Комбинированные	f	f	3	8195
1160	Создаёт закрутку воздуха и увеличивает скорость потока	f	f	1	8196
1160	Преобразует механическую энергию в энергию давления и изменение кинетической энергии	f	t	2	8197
1160	Увеличивает скорость и снижает давление потока	f	f	3	8198
1161	Ограниченная окружная скорость, недостаточная прочность барабана, несогласованность в диаметрах компрессора, камеры сгорания и турбины, увеличенная масса и длина компрессора при заданном πк	f	t	1	8199
1161	Малая изгибная жёсткость, сложность производства, монтажа и демонтажа	f	f	2	8200
1161	Сложность изготовления, большая масса	f	f	3	8201
1162	Стремится совместить по кратчайшему пути вектор угловой скорости вращения ротора с вектором угловой скорости вращения самолёта	f	t	1	8202
1162	Стремится совместить вектор угловой скорости самолёта с вектором угловой скорости вращения ротора	f	f	2	8203
1162	Направление гироскопического момента совпадет с направлением эволюции самолёта в пространстве	f	f	3	8204
1163	Преобразуют энергию газового потока в механическую работу	f	t	1	8205
1163	Преобразуют тепловую энергию в кинетическую энергию	f	f	2	8206
1163	Направляют поток к сопловому аппарату следующей ступени	f	f	3	8207
1164	Предназначена для преобразования части энтальпии газа в механическую энергию	f	t	1	8208
1164	Предназначена для преобразования кинетической энергии в механическую энергию	f	f	2	8209
1164	Служит для преобразования части энтальпии в кинетическую энергию	f	f	3	8210
1165	Удерживают жаровую трубу от температурных расширений в радиальном и осевом направлении	f	f	1	8211
1165	Удерживают жаровую трубу от осевых и поперечных перемещений	f	t	2	8212
1165	Фиксируют воспламенители и форсунки	f	f	3	8213
1166	Кожух включён в силовую схему двигателя, а корпус нет	f	f	1	8214
1166	Корпус включён в силовую схему двигателя, а кожух нет	f	t	2	8215
1166	Кожух не образует проточной части КС	f	f	3	8216
1167	Возникают из-за вибрационных напряжений; вследствие попадания посторонних предметов; нарушения работы уплотнений	f	f	1	8217
1202	Поддерживает постоянное давление на выходе из насоса	f	f	1	8322
1167	Недостаточная жаропрочности материала, перегрева во время запуска или длительной работы на повышенных режимах; из-за нарушения закона подачи топлива	f	t	2	8218
1167	Происходят по причине резких колебаний температуры газов	f	f	3	8219
1168	Упрощается доводка и испытания, лёгкость снятия для осмотра и замены в эксплуатации без разборки двигателя	f	f	1	8220
1168	Обеспечивают экономичность двигателя, допускают охлаждение горячей части, обладает повышенной жёсткостью	f	f	2	8221
1168	Компактные, имеют малую массу и диаметральные размеры, располагают равномерным полем температур и давлений, обеспечивают наилучший повторный запуск, имеют малые гидравлические сопротивления	f	t	3	8222
1169	Большая масса, неравномерное поле температур и давлений, повышенные гидросопротивления, усложнён повторный запуск	f	f	1	8223
1169	Сложность доводки и испытания, затруднён осмотр и замена в эксплуатации, малая жёсткость	f	t	2	8224
1169	Не экономичны, не могут входить в состав силовой схемы двигателя, не имеют устойчивых параметров рабочего процесса	f	f	3	8225
1170	20-30% подаётся в зону горения и принимает участие в горении	f	t	1	8226
1170	70-80% снижает температуру газов до нужной величины	f	f	2	8227
1170	около 50%. необходимо для обеспечения догорания топливовоздушной смеси	f	f	3	8228
1171	Необходимы для размещения рабочих лопаток и передачи на вал осевой силы	f	f	1	8229
1171	Служат для размещения рабочих лопаток и передачи с них на вал крутящего момента и осевой силы	f	t	2	8230
1171	Обеспечивают размещение рабочих лопаток и передачу с них на вал крутящего момента	f	f	3	8231
1172	Для отвода газа в атмосферу с наименьшими тепловыми и гидравлическими потерями	f	f	1	8232
1172	Для преобразования теплоперепада, оставшегося за турбиной, в кинетическую энергию и для отвода газа в атмосферу с наименьшими тепловыми и гидравлическими потерями; для защиты элементов конструкции самолёта от нагрева	f	t	2	8233
1172	Для преобразования оставшегося теплоперепада в механическую работу на валу двигателя	f	f	3	8234
1173	Площадь выходного сечения	f	t	1	8235
1173	Площадь критического сечения	f	f	2	8236
1173	Площади критического и выходного сечений	f	f	3	8237
1174	Применением подвижной иглы	f	f	1	8238
1174	Применением створок и силовым кольцом	f	f	2	8239
1174	С помощью иглы и створок	f	t	3	8240
1175	Fрс увеличивается	f	t	1	8241
1175	Fрс уменьшается	f	f	2	8242
1175	Fрс = const.	f	f	3	8243
1176	Для наивыгоднейшего преобразования химической энергии топлива в тепловую энергию	f	t	1	8244
1176	Для преобразования тепловой энергии в кинетическую энергию газовой струи	f	f	2	8245
1176	Для преобразования полученного теплоперепада в механическую работу на валу двигателя	f	f	3	8246
1177	20-30% подаётся в зону горения и принимает участие в горении	f	f	1	8247
1177	70-80% снижает температуру газов до нужной величины	f	t	2	8248
1177	Около 50%. Необходим для обеспечения догорания топливовоздушной смеси	f	f	3	8249
1178	Для предотвращения трещин от температурных расширений	f	t	1	8250
1178	Для уменьшения жёсткости стенок и облегчения конструкции	f	f	2	8251
1178	С целью удобства сборки камеры сгорания	f	f	3	8252
1179	Получение гладкой поверхности и уменьшение гидропотерь	f	f	1	8253
1179	Создание теплоизоляции, выравнивание температуры по толщине и предупреждения растрескивания	f	t	2	8254
1179	Увеличение диапазона температурных расширений	f	f	3	8255
1180	Для привода компрессора, агрегатов	f	f	1	8256
1180	Для привода воздушного винта	f	f	2	8257
1180	Для привода компрессора, агрегатов, воздушного винта	f	t	3	8258
1181	Осевые и радиальные	f	t	1	8259
1181	Прямоточные и противоточные	f	f	2	8260
1181	Одно- и многоступенчатые	f	f	3	8261
1182	Преобразует часть энтальпии газа в кинетическую энергию с малыми потерями и большой степенью равномерности потока	f	t	1	8262
1182	Предназначен для преобразования кинетической энергии газа в механическую работу и поворота потока газов	f	f	2	8263
1202	Обеспечивает перепуск топлива на вход в насос	f	f	2	8323
1182	Служит для преобразования кинетической энергии газа в потенциальную	f	f	3	8264
1183	ЦТ диска расположен над осью вращения в самой высокой точке	f	f	1	8265
1183	ЦТ диска расположен на оси вращения	f	f	2	8266
1183	ЦТ диска расположен под осью вращения в самой низкой точке	f	t	3	8267
1184	Снятие материала с лёгкой стороны или добавление балансировочного груза с тяжёлой стороны	f	f	1	8268
1184	Снятие материала с тяжёлой стороны или добавление балансировочного груза с лёгкой стороны	f	t	2	8269
1184	Добавление балансировочных грузов с обеих сторон диска	f	f	3	8270
1185	Когда частота вынужденных колебаний больше частоты собственных колебаний ротора	f	f	1	8271
1185	Когда частота вынужденных колебаний совпадает с частотой собственных колебаний ротора	f	t	2	8272
1185	Когда частота вынужденных колебаний больше частоты вынужденных колебаний ротора	f	f	3	8273
1186	Комбинированные, с преобладающей осевой нагрузкой	f	t	1	8274
1186	Осевые нагрузки	f	f	2	8275
1186	Радиальные нагрузки	f	f	3	8276
1187	Предотвращает перетекание масла из бака в двигатель при неработающем двигателе	f	f	1	8277
1187	Поддерживает постоянное давление масла на выходе, равное давлению масла на входе в фильтр	f	f	2	8278
1187	Обеспечивает проход масла при засорении фильтра	f	t	3	8279
1188	Для уменьшения расхода масла	f	f	1	8280
1188	Для отделения воздуха от масла	f	f	2	8281
1188	Для предотвращения повышения давления в этих полостях и для уменьшения расхода масла	f	t	3	8282
1189	Уменьшение трения и износа	f	f	1	8283
1189	Отвод тепла от трущихся деталей	f	t	2	8284
1189	Предохранение от коррозии и наклёпа	f	f	3	8285
1190	20-40°С	f	f	1	8286
1190	105-115°С	f	f	2	8287
1190	40-80°С	f	t	3	8288
1191	Из-за малого коэффициента трения в подшипниках опор двигателя	f	f	1	8289
1191	Из-за увеличения контактных напряжений на шестернях редуктора	f	t	2	8290
1191	Из-за применения масла в автоматах системы автоматического регулирования	f	f	3	8291
1192	Маслобак — маслонасос — двигатель — маслорадиатор — маслонасос откачки — маслобак	f	t	1	8292
1192	Маслобак — маслонасос — двигатель — маслорадиатор — маслобак	f	f	2	8293
1192	Маслобак — маслонасос — двигатель — маслорадиатор — воздухоотделитель — маслобак.	f	f	3	8294
1193	МС-20, МК-22	f	f	1	8295
1193	25% МС-20 и 75% МК-8	f	f	2	8296
1193	МК-6, МК-8, МК-8П, МС-8П	f	t	3	8297
1194	Из-за низкой стоимости	f	f	1	8298
1194	Из-за низкой температуры застывания	f	f	2	8299
1194	Из-за высокой термоокислительной стабильности	f	t	3	8300
1195	От массы и жёсткости ротора, его дины, способа соединения валов	f	t	1	8301
1195	От конструкции ротора, способа смазки опор и их охлаждения	f	f	2	8302
1195	От частоты вращения ротора, осевых зазоров	f	f	3	8303
1196	Систему жёстко связанных между собой неподвижных деталей	f	t	1	8304
1196	Систему опор, связи и осевой фиксации роторов компрессора и турбины	f	f	2	8305
1196	Ротор компрессора и ротор турбины, соединённые между собой	f	f	3	8306
1197	Повышает КПД турбины, уменьшается масса лопаток	f	f	1	8307
1197	Можно увеличить рабочую температуру перед турбиной, применять менее дефицитные материалы, повысить долговечность лопаток	f	t	2	8308
1197	Снижается стоимость и упрощается технология изготовления	f	f	3	8309
1198	Теплоотвод в диск	f	t	1	8310
1198	Конвективное радиальное охлаждение	f	f	2	8311
1198	Заградительное охлаждение	f	f	3	8312
1199	За счёт поворота потока в сторону выходящих газов	f	f	1	8313
1199	За счёт торможения потока газа после турбины	f	f	2	8314
1199	За счёт поворота потока газа под некоторым углом в сторону движения самолёта	f	t	3	8315
1200	Струйная	f	f	1	8316
1200	Центробежная	f	t	2	8317
1200	Испарительная	f	f	3	8318
1201	Изменением площади сопла и величины перепада ΔРф	f	f	1	8319
1201	Изменением коэффициента расхода и величины перепада ΔРф	f	f	2	8320
1201	Изменением площади сопла, коэффициента расхода и величины перепада ΔРф	f	t	3	8321
630	комплексные бригады по ТО ВС	f	f	1	8376
1202	Обеспечивает перепуск топлива при заливке системы на неработающем двигателе, а так же перепускает топливо при отказе качающего узла	f	t	3	8324
1203	Создаёт низкое давление	f	f	1	8325
1203	Изменяет подачу топлива при постоянной частоте вращения качающего узла без перепуска и дросселирования топлива	f	f	2	8326
1203	Сложность конструкции, чувствительность к чистоте топлива, к его малой вязкости и высокой температуре	f	t	3	8327
1204	Уменьшением числа плунжеров	f	f	1	8328
1204	Применением нечётного числа плунжеров	f	t	2	8329
1204	Увеличением силы пружин плунжеров	f	f	3	8330
1205	Поддерживает заданный режим работы двигателя	f	t	1	8331
1205	Задаёт режим работы двигателя	f	f	2	8332
1205	Обеспечивает хорошую приёмистость двигателя	f	f	3	8333
1206	Воздействует на регулирующий фактор	f	f	1	8334
1206	Поддерживает режим работы двигателя	f	f	2	8335
1206	Воспринимает изменение режима работы двигателя и условий полёта	f	t	3	8336
1207	Способность двигателя быстро переходить с режима МАЛЫЙ ГАЗ на МАКСИМАЛЬНЫЙ РЕЖИМ без помпажа и заброса температуры газа	f	t	1	8337
1207	Способность двигателя переходить с одного режима на другой в процессе его разгона	f	f	2	8338
1207	Способность двигателя резко уменьшать режим работы	f	f	3	8339
1208	Создаёт усилия для перемещения регулирующего органа	f	f	1	8340
1208	Измеряет частоту вращения ротора двигателя, преобразуя её отклонение от заданного значения в перемещение золотника	f	t	2	8341
1208	Измеряет частоту вращения ротора	f	f	3	8342
618	специализации ИТП - производственной (бригадно-поточная и закрепленная) или индивидуальной (системная, зонная, системно-зонная)	f	f	1	8343
618	планирования - циклов производства работ ТО (одноэтапное и поэтапное обслуживание) или организации технологического процесса производства работ ТО (сетевые методы, экспертно-директивные решения)	f	f	2	8344
618	всеми перечисленными выше	t	f	3	8345
619	владелец воздушного судна в соответствии с требованиями ЭД ВС и в порядке, указанном в РОТО, РД, с учётом особенностей производственной деятельности авиапредприятия	f	t	1	8346
619	главный инженер АТБ	f	f	2	8347
619	начальник цеха периодического ТО	f	f	3	8348
620	высокую производительность труда	f	f	1	8349
620	координацию работы специалистов и бригад смены	f	f	2	8350
620	высокое качество ТО, минимальные затраты времени и материальных средств	f	t	3	8351
621	разновидность подходов к организации работ по ТО	f	f	1	8352
621	разновидности форм и работ по ТО	f	t	2	8353
621	разновидности организации технического процесса производства работ по ТО	f	f	3	8354
622	раздельно в различных сочетаниях	f	t	1	8355
622	индивидуально для конкретного авиапредприятия	f	f	2	8356
622	раздельно для всех авиапредприятий	f	f	3	8357
623	только базовые ВС	f	f	1	8358
623	только транзитные ВС	f	f	2	8359
623	только единичные ВС, полёту которого ему поручено обеспечивать	f	t	3	8360
624	определённый комплекс работ при ТО или всё обслуживание самолёта выполняется отдельными специалистами не входящие в состав бригады	f	t	1	8361
624	определённый комплекс работ при ТО или всё обслуживание самолёта выполняется только в составе бригады	f	f	2	8362
624	определённый комплекс работ при ТО или всё обслуживание самолёта выполняется только в составе специализированной бригады	f	f	3	8363
625	транспортной авиации	f	f	1	8364
625	при выполнении авиационных работ на посадочных площадках	f	t	2	8365
625	спортивной авиации	f	f	3	8366
626	авиамеханик	f	f	1	8367
626	авиатехник	f	f	2	8368
626	авиамеханик, авиатехник (группа специалистов технического состава)	f	t	3	8369
628	авиатехники-бригадиры по специальности	f	f	1	8370
628	инженеры ОТК по специальности	f	f	2	8371
628	авиатехники-бригадиры, инженеры смены по специальности, начальник смены	f	t	3	8372
629	только определённый парк ВС	f	t	1	8373
629	все ВС находящиеся на балансе авиапредприятия	f	f	2	8374
629	только единичное ВС	f	f	3	8375
698	используется	f	t	1	8580
630	специализированные бригады по типам ВС	f	t	2	8377
630	группа специалистов ИТП	f	f	3	8378
631	специальном ТО ВС	f	f	1	8379
631	периодических формах ТО ВС	f	f	2	8380
631	оперативных формах ТО ВС	f	t	3	8381
632	полное ТО самолёта, двигателей и спецоборудования	f	t	1	8382
632	частичное ТО самолёта и двигателей	f	f	2	8383
632	выборочное ТО спецоборудования и систем ВС	f	f	3	8384
633	авиатехники-бригадиры по специальности	f	f	1	8385
633	инженеры ОТК по специальности	f	f	2	8386
633	авиатехники-бригадиры, инженеры смены по специальности, начальник смены	f	t	3	8387
634	определённую зону на ВС, в которой он выполняет работы предусмотренные РТО	f	t	1	8388
634	отдельную систему на ВС	f	f	2	8389
634	отдельный узел или элемент системы на ВС	f	f	3	8390
635	количества ВС	f	f	1	8391
635	объёма работ	f	t	2	8392
635	ограниченности и оснащённости мест стоянок ВС	f	f	3	8393
636	ВС первого и второго класса	f	f	1	8394
636	ВС с максимальной взлётной массой 75 и более тонн	f	f	2	8395
636	ВС всех классов	f	t	3	8396
637	да	f	t	1	8397
637	нет	f	f	2	8398
637	подготовка не обязательна	f	f	3	8399
638	да	f	t	1	8400
638	нет	f	f	2	8401
638	допуск оформляется только на руководителя выполняемых работ по ТО ВС	f	f	3	8402
639	только на специализированном участке	f	f	1	8403
639	только в лаборатории авиапредприятия	f	f	2	8404
639	только непосредственно на системах ВС	f	t	3	8405
640	да	f	f	1	8406
640	нет	f	t	2	8407
640	эксплуатационной технической документацией определено	f	f	3	8408
641	за 1 этап	f	t	1	8409
641	за 2 этапа	f	f	2	8410
641	за 3 этапа	f	f	3	8411
642	любая форма на ОТО и ПТО, выполняется по частям (этапам) в промежутках между полётами	f	f	1	8412
642	форма на ОТО выполняется по частям (этапам) в промежутках между полётами	f	f	2	8413
642	форма ТО или её модификация выполняется по частям (этапам) в промежутках между полётами в течении наработки определяемой границами допусков на периодичность работ	t	f	3	8414
643	с фиксированными этапами	f	f	1	8415
643	с нерегламентированными этапами	f	f	2	8416
643	с фиксированными и нерегламентированными этапами	t	f	3	8417
644	ГосНИИ ГА	f	f	1	8418
644	авиапредприятия	f	t	2	8419
644	Госстандарта	f	f	3	8420
645	с технолого-конструкторским бюро авиапредприятия	f	f	1	8421
645	с разработчиком ВС и ГОУВТ	f	t	2	8422
645	с министерством транспорта РФ	f	f	3	8423
646	требованиям общей и типовой эксплуатационной документации	f	t	1	8424
646	требованиям государственного стандарта	f	f	2	8425
646	требованиям ЕСКД	f	f	3	8426
647	трудоёмких форм ТО	f	f	1	8427
647	малотрудоёмких форм ТО	f	t	2	8428
647	средней трудности форм ТО	f	f	3	8429
648	на ВС выполнены работы, предусмотренные пооперационной ведомостью данного этапа	f	f	1	8430
648	на ВС устранены выявленные неисправности и выполнены доработки по бюллетеням	f	f	2	8431
648	на ВС выполнены и проконтролированы все работы, предусмотренные пооперационной ведомостью данного этапа, устранены неисправности, ведомости и карты нарядов подписаны инженером ОТК	f	t	3	8432
649	в формуляр ВС	f	t	1	8433
649	в карту-наряд на ОТО	f	f	2	8434
649	в паспорт агрегата	f	f	3	8435
650	инженеры ОТК по специальности	f	f	1	8436
650	авиатехники-бригадиры по специальности	f	f	2	8437
650	должностные лица, предусмотренные руководством по обслуживанию ВС или назначенные начальником АТБ	f	t	3	8438
651	выполнение отдельных этапов более трудоёмких форм ТО совмещается с обслуживанием менее трудоёмких форм ТО	f	t	1	8439
651	выполнение отдельных этапов более трудоёмких форм ТО восполняется при любом ТО	f	f	2	8440
651	выполнение отдельных этапов трудоёмких форм ТО выполняется независимо от форм ТО	f	f	3	8441
652	из трудоёмкости первой формы ТО (Ф-1)	f	f	1	8442
652	из трудоёмкости всех дополнительных работ	f	f	2	8443
698	не используется	f	f	2	8581
652	из трудоёмкости Ф-1 и части дополнительных работ присущих последующим формам ТО	f	t	3	8444
653	на каждый отдельный этап	f	t	1	8445
653	на каждую операцию	f	f	2	8446
653	на каждую выполненную работу	f	f	3	8447
654	эксплуатационной документации	f	f	1	8448
654	инструкциях и ведомостях на поэтапное ТО	f	t	2	8449
654	в бортовом журнале ВС	f	f	3	8450
655	да	f	t	1	8451
655	нет	f	f	2	8452
655	только к поэтапному	f	f	3	8453
656	формирование этапа на малообъёмные, технологические автономные блоки работ	f	f	1	8454
656	формирование этапов и их документирование	f	f	2	8455
656	оперативную согласованность содержания этапа ТО с конкретными возможностями его производства	f	t	3	8456
657	да	f	t	1	8457
657	нет	f	f	2	8458
657	только для поэтапного	f	f	3	8459
658	постоянное совершенствование производственно-технической базы предприятия	f	f	1	8460
658	повышение квалификации работников АТБ, их теоретических знаний и практических навыков по ТО	f	f	2	8461
658	сократить продолжительность разовых простоев при ТО, увеличить годовой налёт часов, улучшить обеспечение регулярности полётов, иметь резерв, обеспечить равномерную загрузку работой технического состава и более чётко планировать использование авиатехники	f	t	3	8462
659	определение диагностических параметров агрегатов при выполнении различных форм ТО	f	f	1	8463
659	снижение эксплуатационных расходов при обеспечении безопасности и регулярности полётов	f	t	2	8464
659	получение необходимой, достоверной информации о техническом состоянии агрегатов функциональных систем ВС	f	f	3	8465
660	перечень периодичность выполнения операций определяется техническим состояние изделия в момент начала ТО	f	t	1	8466
660	перечень и периодичность выполнения операций определяются значением наработки изделия с начала эксплуатации	f	f	2	8467
660	перечень операций определяются по результатам диагностирования изделия в момент начала ремонта	f	f	3	8468
661	назначение перечня и периодичности операций ТО по результатам контроля технического состояния изделия	f	t	1	8469
661	назначение перечня замены агрегатов по результатам контроля технического состояния	f	f	2	8470
661	наличие информационной базы	f	f	3	8471
662	производственно-технической документации	f	f	1	8472
662	организационно-распорядительной документации	f	f	2	8473
662	документов ГОУВТ, определяющих необходимые условности готовности производственной базы	f	t	3	8474
663	выполнены условия готовности производственной базы	f	f	1	8475
663	выполнены условия готовности специалистов	f	f	2	8476
663	выполнены организационно-технические мероприятия по подготовке производства, эксплуатационной документации и инженерно-технического персонала	f	t	3	8477
664	высоким уровнем эксплуатационной технологичности	f	f	1	8478
664	высокой безопасностью, уровнем контролепригодности, позволяющим определить предотказное состояние с помощью встроенных и наземных средств диагностирования	f	t	2	8479
664	высоким уровнем контролепригодности	f	f	3	8480
665	отказы, которых влияют на безопасность полётов	f	t	1	8481
665	отказы, которых не оказывают прямого влияния на безопасность полётов	f	f	2	8482
665	для всех изделий	f	f	3	8483
666	отказы влияют на безопасность полётов	f	f	1	8484
666	отказы не влияют на безопасность полётов	f	t	2	8485
666	для всех изделий	f	f	3	8486
667	выборочным или разовым	f	f	1	8487
667	непрерывным или периодическим	f	t	2	8488
667	постоянным	f	f	3	8489
668	только в характере технологически процессов ТО ВС	f	f	1	8490
668	только в распределении ресурсов потребных на развитие производственно-технической базы соответствующей той или иной методике ТО ВС	f	t	2	8491
668	только развитие экспериментальной базы предприятия промышленности	f	f	3	8492
669	что каждое из изделий эксплуатируется (используется) до отказа.	f	t	1	8493
669	что каждое из изделий эксплуатируется до ремонта	f	f	2	8494
699	на борту ВС	f	t	3	8585
669	что каждое изделие эксплуатируется до выработки межремонтного ресурса	f	f	3	8495
670	да	f	t	1	8496
670	нет	f	f	2	8497
670	в особых случаях	f	f	3	8498
671	данных по наработке агрегата до появления отказа	f	f	1	8499
671	данных состояния агрегатов за время отработки межремонтного ресурса	f	f	2	8500
671	данных об отказах и неисправностях агрегатов	f	t	3	8501
672	бортовой журнал и формуляр самолёта	f	f	1	8502
672	бортовой журнал, карточка КУН АТ, справка о работе АТ в рейсе	f	t	2	8503
672	бортовой журнал, формуляры, паспорта и этикетки, бюллетени на доработки	f	f	3	8504
673	не все	f	f	1	8505
673	нет	f	f	2	8506
673	да	f	t	3	8507
674	после отработки гарантийного ресурса непрерывного контроля и измерения параметров	f	f	1	8508
674	после отработки гарантийного ресурса и периодического контроля и измерение параметров	f	f	2	8509
674	после отработки гарантийного ресурса и постоянного контроля и измерения параметров, определяющих техническое состояние тех или иных агрегатов	f	t	3	8510
675	по результатам контроля	f	t	1	8511
675	по результатам разовой проверки	f	f	2	8512
675	по результатам текущей проверки	f	f	3	8513
676	эксплуатационной проверке	f	f	1	8514
676	экспериментальным исследованиям	f	t	2	8515
676	в совершенствовании производственной базы	f	f	3	8516
677	снижения трудоёмкости работ, связанных с заменой агрегатов и контролем их технического состояния, а так же увеличения их наработки до ремонта	f	t	1	8517
677	сокращения возвратно-обменного фонда агрегатов	f	f	2	8518
677	уменьшение затрат на капремонт	f	f	3	8519
678	разрешается	f	f	1	8520
678	запрещается	f	f	2	8521
678	запрещается, за исключением случаев, оговоренных в отдельном нормативном документе ГОУВТ	f	t	3	8522
679	не менее 0,5м	f	f	1	8523
679	не менее 1м	f	f	2	8524
679	не менее 1,5	f	t	3	8525
680	контрольный талон	f	t	1	8526
680	карта-нард на оперативное ТО	f	f	2	8527
680	карта-наряд на периодическое ТО	f	f	3	8528
681	при дожде	f	f	1	8529
681	при сильном ветре с пылью	f	f	2	8530
681	при грозовых разрядах	f	t	3	8531
682	ПКФ	f	f	1	8532
682	ПОЗ-Т	f	t	2	8533
682	КПУ-3	f	f	3	8534
683	запрещается	f	t	1	8535
683	разрешается	f	f	2	8536
683	разрешается, указанием инженера смены	f	f	3	8537
684	паспорт	f	f	1	8538
684	формуляр	f	t	2	8539
684	контрольный талон	f	f	3	8540
685	моторные подогреватели	f	f	1	8541
685	тепловые обдувочные машины	f	f	2	8542
685	аэродромные кондиционеры и бортовые системы кондиционирования	f	t	3	8543
686	запрещается	f	t	1	8544
686	разрешается при подогреве системы ВС	f	f	2	8545
686	разрешается	f	f	3	8546
687	разрешается	f	f	1	8547
687	запрещается	f	t	2	8548
687	разрешается при подогреве двигателей	f	f	3	8549
688	не ближе 3 м	f	f	1	8550
688	не ближе 2,5м	f	f	2	8551
688	не ближе 3.5м	t	f	3	8552
689	3	f	f	1	8553
689	2	f	f	2	8554
689	1	f	t	3	8555
690	разрешается	f	f	1	8556
690	запрещается	f	t	2	8557
690	разрешается только контейнеры	f	f	3	8558
691	разрешается	f	t	1	8559
691	запрещается	f	f	2	8560
691	разрешается только в ангаре	f	f	3	8561
692	запрещается	f	f	1	8562
692	разрешается, при применении визуальной схемы обеспечения запуска, разработанную авиапредприятием	f	t	2	8563
692	разрешается	f	f	3	8564
693	разрешается	f	f	1	8565
693	запрещается	f	t	2	8566
693	разрешается в особых случаях	f	f	3	8567
694	начальник смены	f	f	1	8568
694	инженер смены	f	f	2	8569
694	диспетчер службы движения	f	t	3	8570
695	1	f	f	1	8571
695	2	f	t	2	8572
695	3	f	f	3	8573
696	разрешается	f	f	1	8574
696	запрещается	f	t	2	8575
696	разрешается в особых случаях	f	f	3	8576
697	разрешается для удалении трудновыводимых загрязнений	f	f	1	8577
697	запрещается	f	t	2	8578
697	разрешается	f	f	3	8579
700	разрешается в особых случаях	f	f	3	8588
701	разрешается спиртом	f	f	1	8589
701	запрещается	f	t	2	8590
701	разрешается растворителем	f	f	3	8591
702	по звуку	f	f	1	8592
702	авиационным бензином	f	f	2	8593
702	мыльной эмульсией	f	t	3	8594
703	руководство по эксплуатации	f	f	1	8595
703	НТЭРАТ ГА-93	f	f	2	8596
703	инструкция по организации движения спецтранспорта и средств механизации на гражданских аэродромах?	f	t	3	8597
704	запрещается	f	t	1	8598
704	разрешается в особых случаях	f	f	2	8599
704	разрешается	f	f	3	8600
705	не более 15 км/ч	f	f	1	8601
705	не более 10 км/ч	f	f	2	8602
705	не более 5 км/ч	f	t	3	8603
706	разрешается	f	f	1	8604
706	запрещается	f	t	2	8605
706	разрешается в особых случаях	f	f	3	8606
707	запрещается	f	t	1	8607
707	разрешается	f	f	2	8608
707	разрешается в особых случаях	f	f	3	8609
708	стопорение с помощью повышения сил трения в резьбе	f	f	1	8610
708	стопорение специальными фиксаторами	f	f	2	8611
708	стопорение наглухо	f	t	3	8612
709	ИН-11	f	f	1	8613
709	КПУ-3	f	t	2	8614
709	КО-1	f	f	3	8615
710	ЦИАТИМ-201	f	f	1	8616
710	ЦИАТИМ-203	f	f	2	8617
710	НК-50	f	t	3	8618
711	10 мин	f	f	1	8619
711	15 мин	f	t	2	8620
711	сразу после заправки	f	f	3	8621
712	на местах стоянки ВС	f	f	1	8622
712	на площадках для запуска и опробования двигателей	f	t	2	8623
712	в ангаре	f	f	3	8624
713	стопорение специальными фиксаторами	f	t	1	8625
713	стопорение наглухо	f	f	2	8626
713	стопорени с помощью повышении сил трения в резьбе	f	f	3	8627
714	контрольные лунки	f	f	1	8628
714	термоизвещатели	f	t	2	8629
714	подтекание гидравлической жидкости АМГ-10	f	f	3	8630
715	0,25 кгс/см2	f	t	1	8631
715	1.0 кгс/см2	f	f	2	8632
715	1,5 кгс/см2	f	f	3	8633
716	2,5 м	f	f	1	8634
716	3 м	f	f	2	8635
716	5 м	f	t	3	8636
717	для вывешивания ВС	f	f	1	8637
717	для запуска двигателей	f	f	2	8638
717	для проверки антенных устройств, локаторов и внесения поправки в радиокомпасы	f	t	3	8639
718	КСАН	f	t	1	8640
718	ИН-11	f	f	2	8641
718	КО-1	f	f	3	8642
719	наряд на дефектацию	f	t	1	8643
719	пооперационная ведомость	f	f	2	8644
719	карта-наряд на оперативное ТО	f	f	3	8645
720	регламент ТО	f	f	1	8646
720	бюллетени	f	t	2	8647
720	формуляр	f	f	3	8648
721	КПУ-3	f	f	1	8649
721	тензометр ИН-11	f	t	2	8650
721	квадрант оптический КО-1	f	f	3	8651
722	разрешается	f	f	1	8652
722	только бензол	f	f	2	8653
722	не разрешается	f	t	3	8654
723	более 15 м/с	f	f	1	8655
723	более 20 м/с	f	f	2	8656
723	более 10 мс/	f	t	3	8657
724	для буксировки ВС	f	f	1	8658
724	для удержании ВС (при запуске двигателей)	f	t	2	8659
724	для вывешивания ВС	f	f	3	8660
725	допускаются без ограничений	f	f	1	8661
725	допускаются, но определенной величины	f	t	2	8662
725	не допускаются	f	f	3	8663
726	стопорение наглухо	f	f	1	8664
726	стопорение специальным фиксатором	f	f	2	8665
726	стопорение путём повышения сил трения в резьбе	f	t	3	8666
727	допускается	f	f	1	8667
727	не допускается	f	t	2	8668
727	только 2 нити	f	f	3	8669
728	можно	f	t	1	8670
728	нельзя	f	f	2	8671
728	можно только в равных пропорциях	f	f	3	8672
729	расходомер и мерная линейка	f	f	1	8673
729	ИП-21 (индикатор положения) и мерная линейка	f	f	2	8674
729	топливомер и мерная линейка	f	t	3	8675
730	отдел главного механика	f	f	1	8676
730	производительно-диспетчерский отдел	f	t	2	8677
730	лаборатория надёжности и технической диагностики	f	f	3	8678
731	можно	f	f	1	8679
731	нельзя	f	t	2	8680
731	можно при оперативном техническом обслуживании	f	f	3	8681
732	КО	f	t	1	8682
732	ПО	f	f	2	8683
732	ТО	f	f	3	8684
733	КПУ-3	f	f	1	8685
733	ПКФ	f	t	2	8686
734	1	f	f	1	8688
734	2	f	t	2	8689
734	3	f	f	3	8690
735	штангенциркуль	f	f	1	8691
735	индикаторное приспособление	f	t	2	8692
735	щуп	f	f	3	8693
736	жёлтого	f	f	1	8694
736	белого	f	t	2	8695
736	красного	f	f	3	8696
737	48 месяцев	f	f	1	8697
737	72 месяца	f	f	2	8698
737	24 месяца	f	t	3	8699
738	НТЭРАТ ГА-93	f	f	1	8700
738	Воздушного кодекса	f	f	2	8701
738	сертификата лётной годности	f	t	3	8702
739	в уполномоченный орган в области ГА или его территориальный орган	t	f	1	8703
739	в Правительство Российской Федерации	f	f	2	8704
739	в организацию по ТОиР авиационной техники	f	f	3	8705
740	не более 5 лет	f	f	1	8706
740	не более 3 лет	f	f	2	8707
740	не более 2 лет	f	t	3	8708
741	ФАП-132	f	t	1	8709
741	НТЭРАТ ГА-93	f	f	2	8710
741	Воздушном кодексе Российской Федерации	f	f	3	8711
742	уполномоченный орган в области ГА или его территориальный орган	f	t	1	8712
742	комиссия авиапредприятия	f	f	2	8713
742	предприятие изготовитель ВС	f	f	3	8714
743	руководство авиапредприятия	f	f	1	8715
743	руководство предприятия изготовителя ВС	f	f	2	8716
743	уполномоченный орган в области ГА или его территориальный орган	f	t	3	8717
744	не чаще одного раза в 3 года	f	f	1	8718
744	не чаще одного раза в год	f	t	2	8719
744	не чаще одного раза в 2 года	f	f	3	8720
745	внеочередной инспекционный контроль лётной годности экземпляра ВС	f	t	1	8721
745	отзыв сертификата лётной годности экземпляра ВС	f	f	2	8722
745	мероприятия по устранению недостатков	f	f	3	8723
746	контрольный запуск и опробование двигателей	f	f	1	8724
746	контрольный полёт и руление	f	t	2	8725
746	контрольная буксировка	f	f	3	8726
747	НТЭРАТ ГА-93	f	f	1	8727
747	ФАП-118	f	t	2	8728
747	руководство по эксплуатации	f	f	3	8729
748	сертификат лётной годности	f	t	1	8730
748	страховое свидетельство	f	f	2	8731
748	формуляр ВС	f	f	3	8732
749	в течении 3 лет	f	f	1	8733
749	в течении года	f	t	2	8734
749	в течении 2 лет	f	f	3	8735
750	орган по сертификации, выдавший сертификат лётной годности	f	t	1	8736
750	предприятие изготовитель ЕЭВС	f	f	2	8737
750	комиссия авиапредприятия	f	f	3	8738
751	не чаще двух раз в год	f	t	1	8739
751	не чаще двух раз в 2 года	f	f	2	8740
751	не чаще двух раз в 3 года	f	f	3	8741
752	наряд на дефектацию	f	f	1	8742
752	карта-наряд на периодическое ТО.	f	f	2	8743
752	акт инспекционного контроля лётной годности	f	t	3	8744
838	Местный контроль	f	f	1	8745
838	Разовый, контроль технического состояния и специальный контроль участков конструкции	f	f	2	8746
838	Общий контроль технического состояния и специальный контроль участков конструкции, требующих повышенного внимания	f	t	3	8747
839	Своевременное обнаружение повреждений и нарушений целостности конструкции	f	t	1	8748
839	Своевременное устранение повреждений и нарушений целостности конструкции	f	f	2	8749
839	Своевременное прогнозирование повреждений и нарушений целостности конструкции	f	f	3	8750
840	Устранение помех уровню контроля основных силовых элементов конструкции самолета и вертолета	f	f	1	8751
840	Выявления требуемого уровня контроля основных силовых элементов конструкции самолета и вертолета	f	f	2	8752
840	Обеспечение требуемого уровня контроля основных силовых элементов конструкции самолета и вертолета	f	t	3	8753
841	Разработчиком изделий к моменту начала регулярной эксплуатации	f	t	1	8754
841	Инженером к моменту начала регулярной эксплуатации	f	f	2	8755
841	Пилотом к моменту начала регулярной эксплуатации	f	f	3	8756
842	Простота выявлений повреждений заданного начального размера и минимальной трудоемкости контроля	f	f	1	8757
842	Надежное выявление повреждений заданного начального размера и минимальной трудоемкости контроля	f	t	2	8758
862	Регистрация индикаторных жидкостей	f	f	3	8819
889	0.045 мм	f	t	1	8898
842	Своевременность выявлений повреждений заданного начального размера и минимальной трудоемкости контроля	f	f	3	8759
843	Оценка состояния силовых элементов конструкции в местах возможного возможных усталостных повреждений	f	t	1	8760
843	Проведение одного из методов неразрушающего контроля	f	f	2	8761
843	Проведение нескольких видов неразрушающего контроля	f	f	3	8762
844	Реже производить контроль конструкций, сокращая тем самым затраты на обслуживание	f	t	1	8763
844	Чаще производить контроль конструкции, увеличив процент нахождения неисправностей	f	f	2	8764
844	Своевременный контроль	f	f	3	8765
845	Ультразвуковой, импедансный, метод свободных колебаний, велосимметрический	f	t	1	8766
845	Капиллярный, течеискание	f	f	2	8767
845	Ультразвуковой, метод свободных колебаний	f	f	3	8768
846	Простота конструкции	f	f	1	8769
846	Чувствительность	f	t	2	8770
846	Легкость использования	f	f	3	8771
847	Только для контролепригодных и инструментально-доступных конструкций	f	t	1	8772
847	Для любой конструкции	f	f	2	8773
847	Для инструментально-доступных конструкций	f	f	3	8774
848	Такие элементы не контролируются	f	f	1	8775
848	Специальная пометка данных элементов	f	f	2	8776
848	Создание люков, легкосъемных панелей, технологических отверстий	f	t	3	8777
849	Люки только для введения инструмента вручную	f	t	1	8778
849	Воздвигаемые лестницы, стремянки	f	f	2	8779
849	Буксир, наземную технику	f	f	3	8780
850	Оптический метод	f	f	1	8781
850	Акустический метод	f	f	2	8782
850	Радиографический метод	f	t	3	8783
851	Экспериментально или с помощью специальных графиков экспозиции	f	t	1	8784
851	Визуально, определяется непосредственно специалистом	f	f	2	8785
851	Зависит от типа самолета	f	f	3	8786
852	Двухсторонний подход с одной стороны устанавливается источник излучения, с другой регистратор	f	t	1	8787
852	Отверстие для пропускания электрического вихревого тока	f	f	2	8788
852	Лакокрасочное покрытие данной детали	f	f	3	8789
853	Качество метода	f	f	1	8790
853	Обеспечение высокой чувствительности метода	f	t	2	8791
853	Практичность метода	f	f	3	8792
854	Проникновение специальной жидкости в дефекты и удержание ее в них, после наносится проявляющий состав	f	t	1	8793
854	Регистрация индикаторных жидкостей	f	f	2	8794
854	Регистрация магнитных полей рассеяния дефектов	f	f	3	8795
855	Продельные волны ультразвуковой частоты	f	f	1	8796
855	Поперечные волны ультразвуковой частоты	f	f	2	8797
855	Упругие волны ультразвуковой частоты (высокочастотный импульс)	f	t	3	8798
856	Эхо-метод, теневой, резонансный	f	t	1	8799
856	Шумный, бесшумный, сбалансированный	f	f	2	8800
856	Проникающий, непроникающий	f	f	3	8801
857	можно проводить намагничивание, пропуская ток через стержень или толстый провод	f	t	1	8802
857	Благодаря легкости получения тока	f	f	2	8803
857	Благодаря менее прочной конструкции данного типа	f	f	3	8804
858	Проведением планового ТО	f	f	1	8805
858	Диагностированием ее технического состояния	f	t	2	8806
858	Обеспечением нормального технического состояния	f	f	3	8807
859	Регистрация магнитных полей	f	f	1	8808
859	Регистрация индикаторных жидкостей	f	f	2	8809
859	Взаимодействие оптического излучения с контролируемым объектом	f	t	3	8810
860	Контроль открытых, доступных для открытого просмотра мест	f	t	1	8811
860	Контроль деталей из ферромагнитных материалов	f	f	2	8812
860	Контроль деталей из немагнитных материалов	f	f	3	8813
861	Поверхностные трещины любого происхождения, раковины, рыхлости	f	f	1	8814
861	Закаты, заковы, волосовины и другие несплошности	f	t	2	8815
861	Механические повреждения	f	f	3	8816
862	Взаимодействие проникающего оптического луча с контролируемым объектом	f	t	1	8817
862	Взаимодействие проникающего ионизирующего излучения с контролируемым объектом	f	f	2	8818
888	Герц. Ом	f	f	3	8897
863	Определение дефектов, расположенных в глубине металлических материалов	f	f	1	8820
863	Контроль открытых, доступных для открытого просмотра мест	f	f	2	8821
863	Контроль деталей из немагнитных материалов	f	t	3	8822
864	Неперпендикулярность направлений	f	t	1	8823
864	Конструктивное совмещение деталей из алюминиевых сплавов с элементами	f	f	2	8824
864	Сложность отстройки зазора между датчиком и контролируемым материалом	f	f	3	8825
865	Лупы с увеличением от 2 до 10 раз	f	f	1	8826
865	Микроскопы с увеличение от 20 до 100 раз	f	t	2	8827
865	Лупы с уменьшением от 2 до 10 раз	f	f	3	8828
866	22-25˚С	f	f	1	8829
866	20-25 ˚С	f	f	2	8830
866	25-30 ˚С	f	t	3	8831
867	теория передачи размеров единиц физически величин	f	f	1	8832
867	теория исходных средств измерений(эталонов)	f	f	2	8833
867	наука об измерения, методах и средствах обеспечения их единства и способах достижения требуемой точности	f	t	3	8834
868	объект измерения	f	f	1	8835
868	величина, подлежащая измерению, измеряемая или измеренная в соответствии с основной целью измерительной задачи	f	f	2	8836
868	одно из свойств физического объекта, общее в качественном отношении для многих физических объектов, но в количественном отношении индивидуальное для каждого из них	f	t	3	8837
869	выбор технического средства, имеющего нормированные метрологические характеристики	f	f	1	8838
869	операция сравнения неизвестного с известным	f	f	2	8839
869	опытное нахождение значения физической величины с помощью технических средств	f	t	3	8840
870	отклонение результата измерения	f	f	1	8841
870	измеренное значение	f	f	2	8842
870	значение, идеально отражающее одно из свойств физического объекта	f	t	3	8843
871	цельсий, моль	f	f	1	8844
871	кельвин, моль	f	f	2	8845
871	кельвин, кандела	f	t	3	8846
872	5	f	f	1	8847
872	7	f	t	2	8848
872	10	f	f	3	8849
873	Произвольные единицы	f	f	1	8850
873	Второстепенные единицы	f	f	2	8851
873	Производные единицы	f	t	3	8852
874	прямые, косвенные	f	f	1	8853
874	непосредственной оценкой	f	f	2	8854
874	систематические, случайные, грубые	f	t	3	8855
875	предельные отклонения размера	f	t	1	8856
875	гарантированный натяг	f	f	2	8857
875	гарантированный зазор	f	f	3	8858
876	абсолютная, относительная	f	t	1	8859
876	приведенная, случайная	f	f	2	8860
876	систематическая, приведенная	f	f	3	8861
877	Δ = Хизм –Хист	f	f	1	8862
877	ХΝ= Хк- Хн	f	f	2	8863
877	δ= Δ/ Хист ∙ 100%	f	t	3	8864
878	Вольт	f	f	1	8865
878	Ом	f	f	2	8866
878	Ампер	f	t	3	8867
879	сравнение измеряемой величины с мерой	f	t	1	8868
879	измерение по отсчетному устройству	f	f	2	8869
879	отсчет по измерительному прибору сравнения	f	f	3	8870
880	по результатам измерений	f	f	1	8871
880	из опытных данных	f	f	2	8872
880	на основании математических зависимостей с основными единицами СИ	f	t	3	8873
881	штриховая шкала	f	f	1	8874
881	продольная и круговая шкала	f	t	2	8875
881	двусторонняя шкала	f	f	3	8876
882	измерение на основании известной математической зависимости	f	f	1	8877
882	способ нахождения искомого значения	f	f	2	8878
882	искомое значение находится непосредственно из эксперимента	f	t	3	8879
883	класс точности	f	f	1	8880
883	разность между измеренным и действительным значением физической величины	f	f	2	8881
883	отношение абсолютной погрешности к нормирующему значению	f	t	3	8882
884	Вольт	f	t	1	8883
884	Вебер	f	f	2	8884
884	Тесла	f	f	3	8885
885	значение, определенное экспериментально и приближающееся к истинному значению	f	t	1	8886
885	измеренное значение	f	f	2	8887
885	значение, определенное экспериментально	f	f	3	8888
886	Герц	f	f	1	8889
886	Фарад	f	f	2	8890
886	Ватт	f	t	3	8891
887	8	f	t	1	8892
887	44	f	f	2	8893
887	7	f	f	3	8894
888	Радиан. Стерадиан	f	t	1	8895
888	Ампер. Килограмм	f	f	2	8896
889	28 мм	f	f	2	8899
889	28.045 мм.	f	f	3	8900
890	Н 8	f	f	1	8901
890	℮ 9	f	f	2	8902
890	50 мм.	f	t	3	8903
891	отклонение результата от истинного значения	f	t	1	8904
891	приведенная погрешность	f	f	2	8905
891	систематическая погрешность	f	f	3	8906
892	Ватт	f	f	1	8907
892	Джоуль	f	f	2	8908
892	Герц	f	t	3	8909
893	размерность	f	t	1	8910
893	постоянство во времени	f	f	2	8911
893	погрешность измерения	f	f	3	8912
894	Первичной	f	f	1	8913
894	Вторичной	f	t	2	8914
894	Инспекционной	f	f	3	8915
895	да	f	f	1	8916
895	нет	f	t	2	8917
895	временно	f	f	3	8918
896	аттестат	f	f	1	8919
896	знак соответствия	f	f	2	8920
896	сертификат соответствия	f	t	3	8921
897	самостоятельно авиапредприятием	f	t	1	8922
897	предприятием изготовителем	f	f	2	8923
897	государственным органом управления воздушным транспортом	f	f	3	8924
898	ремонтным предприятием	f	f	1	8925
898	изготовитель АТ	f	t	2	8926
898	предприятием изготовителем АТ	f	f	3	8927
899	срок от даты подписания приёмо-сдаточного акта при сдаче в ремонт до даты его подписания заказчиком после ремонта	f	t	1	8928
899	общий срок нахождения АТ на территории производителя ремонта	f	f	2	8929
899	срок от даты убытия АТ с авиапредприятия до её возвращения	f	f	3	8930
900	производитель ремонта	f	f	1	8931
900	заказчик ремонта	f	t	2	8932
900	изготовитель АТ	f	f	3	8933
901	разрешается перелёт по решению командира ВС	f	f	1	8934
901	не допускается	f	t	2	8935
901	допускается	f	f	3	8936
902	да	f	t	1	8937
902	нет	f	f	2	8938
902	только груз	f	f	3	8939
903	заказчиком ремонта	f	f	1	8940
903	производителем ремонта	f	t	2	8941
903	изготовителем ВС	f	f	3	8942
904	согласно формуляра ВС	f	f	1	8943
904	согласно регламента	f	f	2	8944
904	согласно перечням (описям) в бортовом журнале	f	t	3	8945
905	могут, по технологическим документам заказчика	f	f	1	8946
905	не могут	f	f	2	8947
905	могут, по технологическим документам производителя ремонта после экспертизы и согласования с разработчиком действующего руководства по ремонту АТ	f	t	3	8948
906	оформлением карты-наряд	f	f	1	8949
906	оформление приёмо-сдаточного акта	f	t	2	8950
906	оформление сдаточного акта	f	f	3	8951
907	нет	f	f	1	8952
907	да, при производственной необходимости	f	f	2	8953
907	да, после метрологической экспертизы и аттестации	f	t	3	8954
908	нет	f	f	1	8955
908	да	f	t	2	8956
908	только технологические испытания	f	f	3	8957
909	3	f	f	1	8958
909	5	f	t	2	8959
909	10	f	f	3	8960
910	формуляр ВС	f	t	1	8961
910	бортовой журнал	f	f	2	8962
910	формуляр силовых элементов планера	f	f	3	8963
911	в удостоверение (сертификат) о годности гражданского ВС к полётам	f	f	1	8964
911	в формуляр ВС	f	t	2	8965
911	в бортовой журнал ВС	f	f	3	8966
912	в нивелировочные карты (нивелировочный паспорт)	f	t	1	8967
912	в формуляр ВС	f	f	2	8968
912	в формуляр силовых элементов планера	f	f	3	8969
913	в формуляр силовых элементов планера	f	f	1	8970
913	в формуляр ВС	f	t	2	8971
913	в бортовой журнал	f	f	3	8972
914	в одном	f	f	1	8973
914	в количестве экземпляров, предусмотренных Договором на ремонт	f	t	2	8974
914	в трёх	f	f	3	8975
915	приёмо-сдаточный акт	f	t	1	8976
915	оформленный формуляр ВС	f	f	2	8977
915	бортовой журнал ВС	f	f	3	8978
916	нет	f	f	1	8979
916	только с грузом	f	f	2	8980
916	да	f	t	3	8981
917	только в контейнере	f	t	1	8982
917	перелёт к месту назначения по согласованию сторон	f	f	2	8983
917	перелёт без пассажиров и груза	f	f	3	8984
918	да	f	f	1	8985
918	нет	f	f	2	8986
918	да, без нарушения заводских пломб	f	t	3	8987
919	планово-предупредительная система	f	f	1	8988
919	система регламентированного ремонта	f	f	2	8989
919	система ремонта по техническому состоянию	f	t	3	8990
920	система ремонта по техническому состоянию	f	f	1	8991
920	планово-предупредительная система	f	t	2	8992
920	система ремонта по уровню надёжности	f	f	3	8993
921	аварийный	f	f	1	8994
921	капитальный	f	t	2	8995
921	текущий	f	f	3	8996
922	текущий	f	t	1	8997
922	капитальный	f	f	2	8998
922	регламентированный	f	f	3	8999
923	система ремонта по техническому состоянию	f	t	1	9000
923	планово-предупредительная система	f	f	2	9001
923	регламентированная система	f	f	3	9002
924	смолы	f	f	1	9003
924	осадки	f	f	2	9004
924	нагар	f	t	3	9005
925	электролиз	f	f	1	9006
925	вибрация	f	f	2	9007
925	кавитация	f	t	3	9008
926	анодная очистка	f	f	1	9009
926	дробеструйная очистка	f	t	2	9010
926	ультразвуковая очистка	f	f	3	9011
927	пескоструйная очистка	f	f	1	9012
927	электролитическая очистка	f	t	2	9013
927	дробеструйная очистка	f	f	3	9014
928	кавитации	f	f	1	9015
928	электролиз	f	t	2	9016
928	вибрация	f	f	3	9017
929	с помощью тандера	f	t	1	9018
929	с помощью квадранта	f	f	2	9019
929	с помощью динамометра	f	f	3	9020
930	трещина	f	f	1	9021
930	гофр	f	t	2	9022
930	эрозия	f	f	3	9023
931	измерение усилий	f	f	1	9024
931	измерение натяжения тросов	f	f	2	9025
931	определение геометрических параметров ВС	f	t	3	9026
932	для крепления лебёдок	f	f	1	9027
932	для нивелировки ВС	f	t	2	9028
932	для установки подъёмников	f	f	3	9029
933	до отрыва всех колес от земли	f	t	1	9030
933	до полного разжатия всех амортизаторов	f	f	2	9031
933	высота не имеет значения	f	f	3	9032
934	определение остаточной деформации и правильности монтажа	f	t	1	9033
934	определение веса и центровки	f	f	2	9034
934	определение углов отклонения рулей	f	f	3	9035
935	определение центра тяжести ВС	f	f	1	9036
935	определение геометрических параметров ВС	f	t	2	9037
935	определение технических характеристик ВС	f	f	3	9038
936	заменить на новый	f	t	1	9039
936	установить хомут	f	f	2	9040
936	запаять	f	f	3	9041
937	заменить	f	f	1	9042
937	повернуть на 180° вокруг своей оси и восстановить покрытие	f	t	2	9043
937	восстановить покрытие	f	f	3	9044
938	напильник	f	f	1	9045
938	шлифовальный круг	f	f	2	9046
938	зубило	f	t	3	9047
939	отрихтовать	f	f	1	9048
939	заменить на новый	f	t	2	9049
939	продолжать эксплуатацию	f	f	3	9050
940	динамометр	f	f	1	9051
940	тензометр	f	t	2	9052
940	нивелир	f	f	3	9053
941	кавитация	f	f	1	9054
941	остаточная деформация	f	t	2	9055
941	коррозия	f	f	3	9056
942	нивелировочный паспорт ВС	f	t	1	9057
942	регламент технического обслуживания ВС	f	f	2	9058
942	формуляр ВС	f	f	3	9059
943	заменить	f	f	1	9060
943	продолжить эксплуатацию(без ограничений)	f	f	2	9061
943	отремонтировать и продолжать эксплуатацию, если глубина и площадь “серебра” не превышает допуски	f	t	3	9062
944	регламентированная, по техническому состоянию	f	t	1	9063
944	серийная, индивидуальная	f	f	2	9064
944	поточная, поточно-стендовая	f	f	3	9065
945	тензометр	f	f	1	9066
945	тарировочный ключ	f	t	2	9067
945	квадрант	f	f	3	9068
946	помутнение стекла	f	f	1	9069
946	мелкие царапины поверхности стекла	f	f	2	9070
946	поверхностные микроскопические трещины	f	t	3	9071
947	обработка внешних поверхностей цилиндров	f	f	1	9072
947	обработка внутренних поверхностей цилиндров	f	t	2	9073
947	обработка внешних и внутренних поверхностей цилиндров	f	f	3	9074
948	только для восстановления декоративных и антикоррозионных покрытий	f	f	1	9075
948	только для восстановления размеров изношенных поверхностей	f	f	2	9076
982	количеством нуклонов	f	f	3	9179
983	изомерами	f	f	1	9180
983	изобарами	f	f	2	9181
948	для восстановления антикоррозионных и декоративных покрытий, а так же для восстановления размеров изношенных поверхностей	f	t	3	9077
949	допускается	f	t	1	9078
949	не допускается	f	f	2	9079
949	не допускается подтяжка более 5 заклепок, находящихся рядом	f	f	3	9080
950	поточный	f	t	1	9081
950	серийный	f	f	2	9082
950	обезличенный	f	f	3	9083
951	индивидуальный	f	t	1	9084
951	обезличенный	f	f	2	9085
951	серийный	f	f	3	9086
952	допускается без ограничений	f	f	1	9087
952	не допускается	f	f	2	9088
952	допускается при определенной глубине вмятин	f	t	3	9089
953	отметить место и продолжить эксплуатацию	f	f	1	9090
953	заменить трос	f	t	2	9091
953	отремонтировать и продолжить эксплуатацию	f	f	3	9092
954	только антикоррозионная защита	f	f	1	9093
954	только обеспечение высокой адгезии ЛКП с окрашенной поверхностью	f	f	2	9094
954	антикоррозионная защита и обеспечение высокой адгезии ЛКП с окрашенной поверхностью	f	t	3	9095
955	разрешается без проведения летных испытаний	f	f	1	9096
955	не разрешается	f	t	2	9097
955	разрешается	f	f	3	9098
956	7/45	f	f	1	9099
956	1/5	f	f	2	9100
956	3/5	t	f	3	9101
957	0,5	f	f	1	9102
957	1,5	t	f	2	9103
957	2,5	f	f	3	9104
958	15π см^3	f	f	1	9105
958	25π см^3	t	f	2	9106
958	50π см^3	f	f	3	9107
959	4 см^2	f	f	1	9108
959	6 см^2	t	f	2	9109
959	22,5 см^2	f	f	3	9110
960	F1 = F2	f	t	1	9111
960	F1 > F2	f	f	2	9112
960	F1 < F2	f	f	3	9113
961	mv	f	t	1	9114
961	2mv	f	f	2	9115
961	3mv	f	f	3	9116
962	0 м/с^2	f	f	1	9117
962	1 м/с^2	f	t	2	9118
962	2 м/с^2	f	f	3	9119
963	0,5 Гц	f	f	1	9120
963	2 Гц	f	t	2	9121
963	72 Гц	f	f	3	9122
964	2 м	f	f	1	9123
964	4 м	f	t	2	9124
964	8 м	f	f	3	9125
965	изобарный	f	f	1	9126
965	изотермический	f	t	2	9127
965	адиабатический	f	f	3	9128
966	тело обладает высокой теплопроводностью	f	f	1	9129
966	энергия расходуется на разрушение связей молекул	f	t	2	9130
966	тело не получает количество теплоты	f	f	3	9131
967	40%	f	f	1	9132
967	57%	t	f	2	9133
967	93%	f	f	3	9134
968	200 Дж	f	t	1	9135
968	600 Дж	f	f	2	9136
968	1000 Дж	f	f	3	9137
969	при последовательном	f	f	1	9138
969	при параллельном	f	t	2	9139
969	тип соединения не играет роли	f	f	3	9140
970	10 Вт	f	t	1	9141
970	2,4 Вт	f	f	2	9142
970	0,16 Вт	f	f	3	9143
971	не пропускать электрический ток	f	f	1	9144
971	в направлении p→n пропускать ток хорошо, а в обратном – плохо	f	t	2	9145
971	в направлении n→p пропускать ток хорошо, а в обратном – плохо	f	f	3	9146
972	5 А	f	f	1	9147
972	28 А	f	f	2	9148
972	50 А	f	t	3	9149
973	4 В	f	f	1	9150
973	5 В	f	f	2	9151
973	3 В	f	t	3	9152
974	увеличится в 2 раза	f	f	1	9153
974	уменьшится в 2 раза	f	t	2	9154
974	уменьшится в 4 раза	f	f	3	9155
975	магнитный поток	f	f	1	9156
975	сила Ампера	f	f	2	9157
975	магнитная индукция	f	t	3	9158
976	100А	f	f	1	9159
976	10А	f	f	2	9160
976	6А	f	t	3	9161
977	под углом 45 градусов к лучу	f	t	1	9162
977	под углом 60 градусов к лучу	f	f	2	9163
977	под углом 30 градусов к лучу	f	f	3	9164
978	интерференцией	f	t	1	9165
978	дисперсией	f	f	2	9166
978	дифракцией	f	f	3	9167
979	2,5 см	f	t	1	9168
979	10 см	f	f	2	9169
979	25 см	f	f	3	9170
980	Ультрафиолетовое излучение	f	f	1	9171
980	Гамма излучение	f	t	2	9172
980	Рентгеновское излучение	f	f	3	9173
981	мельчайшая частица вещества, всё ещё обладающая свойствами начального вещества, по которым его можно идентифицировать	f	t	1	9174
981	мельчайшая частица, до которой можно разделить любое вещество химическим способом	f	f	2	9175
981	элементарная частица	f	f	3	9176
982	количеством протонов	f	t	1	9177
982	количеством нейтронов	f	f	2	9178
983	изотопами	f	t	3	9182
984	положительным ионом	f	t	1	9183
984	отрицательным ионом	f	f	2	9184
984	протоном	f	f	3	9185
985	ионной связью	f	f	1	9186
985	металлической связью	f	f	2	9187
985	ковалентной связью	f	t	3	9188
986	метр	f	t	1	9189
986	сантиметр	f	f	2	9190
986	миллиметр	f	f	3	9191
987	в килограммах	f	f	1	9192
987	в ньютонах	f	t	2	9193
987	в фунтах	f	f	3	9194
988	в ваттах (Вт)	f	t	1	9195
988	в джоулях (Дж)	f	f	2	9196
988	в лошадиных силах (л.с.)	f	f	3	9197
989	ньютон	f	f	1	9198
989	вольт	f	f	2	9199
989	ампер	f	t	3	9200
990	индуктивности	f	f	1	9201
990	магнитного потока	f	f	2	9202
990	магнитной индукции	f	t	3	9203
991	Визуально и по признакам (шумы, запахи, и т.д.), проверкой полноты выполнения регламентных работ	f	f	1	9204
991	Проверкой в действии, средствами. инструментального контроля, по органолептическим признакам	f	f	2	9205
991	Визуально, по органолептическим признакам, проверкой в действии, средствами инструментального контроля, проверкой полноты выполнения регламентных работ	f	t	3	9206
992	Определение исправности АТ, работоспособности и правильности функционирования систем и изделий, предупреждение отказов, неисправностей и нарушений правил технической эксплуатации	f	t	1	9207
992	Проверка работоспособности и правильности функционирования систем, предупреждение отказов и неисправностей, нарушений правил технической эксплуатации	f	f	2	9208
992	Предупреждение отказов, неисправностей и нарушений правил технической эксплуатации	f	f	3	9209
993	Экипаж воздушного судна (ВС)	f	f	1	9210
993	Непосредственные исполнители работ	f	t	2	9211
993	Технический персонал службы	f	f	3	9212
994	Перечни контрольных предъявлений по типам авиационной техники (АТ), стандартные положения о порядке предъявления и приёмки работ	f	f	1	9213
994	Перечни контрольных предъявлений по типам АТ, формам, видам и комплексам ТО и Р, стандарты (положения) о порядке предъявления и приёма работ, табели распределения контрольных предъявлений, типовой классификатор нарушений ИТП	f	t	2	9214
994	Перечни контрольных предъявлений по типам АТ, формам, видам и комплексам ТО и Р, стандарты (положения) о порядке предъявления и приёма работ, табели распределения контрольных предъявлений, типовой классификатор нарушений ИТП	f	f	3	9215
995	Проводить анализ результатов контроля состояния авиационной техники (АТ), принимать эффективные меры по устранению недостатков	f	f	1	9216
995	Принимать эффективные меры по устранению недостатков, в установленном порядке информировать вышестоящие органы ИАОП о неисправностях АТ и проблемах, угрожающих безопасности полётов	f	f	2	9217
995	Анализировать результаты контроля состояния авиационной техники (АТ), качества ТО и Р, принимать эффективные меры по устранению недостатков, в срочном порядке информировать вышестоящие органы ИАОП о неисправностях АТ и проблемах, угрожающих безопасности полётов	f	t	3	9218
996	Экипаж воздушного судна (ВС)	f	t	1	9219
996	Инженерно-технический персонал (ИТП)	f	f	2	9220
996	Непосредственно исполнители работ	f	f	3	9221
997	Когда исполнитель и контролирующий полёт лица поставили свои подписи в документе	f	t	1	9222
997	По отношению к проведенным для контроля работам нет замечаний	f	f	2	9223
997	Исполнитель поставил подпись в соответствующем документе	f	f	3	9224
998	Административную	f	f	1	9225
998	Дисциплинарную или иную ответственность	f	t	2	9226
998	Уголовную	f	f	3	9227
999	Разовые и регулярные проверки	f	f	1	9228
999	Регулярные проверки, инспекторские осмотры	f	f	2	9229
999	Разовые, инспекторские, контрольные осмотры	f	t	3	9230
1000	Для детальной проверки состояния отдельных частей и элементов конструкции, проверки работоспособности и правильности функционирования изделий и систем	f	t	1	9231
1000	Для контрольной проверки работоспособности изделий	f	f	2	9232
1000	Для детальной проверки функционирования изделий и систем	f	f	3	9233
1302	0÷6.67%	f	f	2	9415
1302	2÷6.67%	f	t	3	9416
1001	Для детальной проверки конструкции ВС	f	f	1	9234
1001	Для оценки технического состояния воздушного судна (ВС), состояния организации и качества их технического обслуживания	f	t	2	9235
1001	Для детальной проверки состояния отдельных частей и элементов, состояния организации и качества их технического обслуживания	f	f	3	9236
1002	При неисправности воздушного судна (ВС), при получении ВС из ремонта и в других случаях, определяемых руководителем ИАОП	f	f	1	9237
1002	Для оценки проведения специализированных работ, при продлении срока действия сертификата (удостоверения) о годности к полётам и ресурса АТ	f	f	2	9238
1002	При продлении срока действия удостоверения (сертификата) о годности ВС к полётам, продления ресурса, после восстановления повреждённого ВС, при получении ВС из ремонта и в других случаях, определяемых руководителем ИАОП	f	t	3	9239
1003	Выполнение периодического технического обслуживания (ПТО) воздушного судна (ВС)	f	f	1	9240
1003	Комиссию для определения объём осмотра и утверждения акта	f	t	2	9241
1003	Комиссию для осмотра и утверждения акта результатов	f	f	3	9242
1004	Выявления неисправностей, отказов АТ	f	f	1	9243
1004	Проверки работы систем и изделий, которая не может быть выполнена на земле	f	t	2	9244
1004	Оценки проведённого технического обслуживания (ТО и Р) АТ	f	f	3	9245
1005	3 месяцев	f	t	1	9246
1005	2 месяцев	f	f	2	9247
1005	5 месяцев	f	f	3	9248
1006	Разрешается	f	f	1	9249
1006	Разрешается при специальном решении	f	f	2	9250
1006	Запрещается	f	t	3	9251
1007	Цель, условия контрольного полёта, состав экипажа и других участников	f	f	1	9252
1007	Цель, условия, режимы, параметры контрольного полёта, подлежащие проверке, состав экипажа и других участников	f	t	2	9253
1007	Режимы и параметры контрольного полёта, подлежащие проверке, состав экипажа и других лиц	f	f	3	9254
1008	Вести постоянное наблюдение за работой авиационной техники (АТ), фиксировать в протоколе параметры проверяемых систем	f	t	1	9255
1008	Вести наблюдение за работой АТ	f	f	2	9256
1008	Выполнить наблюдение и контроль параметров систем	f	f	3	9257
1009	Принять меры по восстановлению нормальной работы системы	f	f	1	9258
1009	Немедленно доложить об этом командиру воздушного судна (КВС) и с его разрешения принять меры по восстановлению нормальной работы АТ	f	t	2	9259
1009	Оставить процесс изменений без внимания	f	f	3	9260
1010	Заключение об исправности воздушного судна (ВС) дают руководитель и исполнитель, ответственные за их качество	f	f	1	9261
1010	После устранения неисправностей заключение об исправности дают непосредственные исполнители и контролирующие лица	f	f	2	9262
1010	Заключение об исправности ВС, после выполнения работ технического обслуживания (ТО и Р) и устранения неисправностей дают непосредственный руководитель работ и специалист, ответственный за общий контроль их качества	f	t	3	9263
1011	Карта-наряд, бортовой журнал воздушного судна (ВС), производятся записи в карте контрольного полёта	f	t	1	9264
1011	Карта-наряд, бортовой журнал ВС, карта полёта	f	f	2	9265
1011	Карта-наряд, бортовой журнал ВС, справка о работе	f	f	3	9266
1012	Проверки работы систем и изделий, которая не может быть выполнена на стоянке	f	t	1	9267
1012	Проверки работоспособности систем и изделий	f	f	2	9268
1012	Проверки при каждом ТО и Р вне стоянки	f	f	3	9269
1014	Авиационным персоналом по ТО и РАТ после устранения неисправностей, требующих контрольного руления	f	f	1	9270
1014	Специалистом, ответственным за проведение ТО и Р, работ по устранению неисправности, обуславливающей необходимость контрольного руления утверждается руководителем ИАОП	f	t	2	9271
1014	Инженером по ТО и Р, руководящим выполнением работ по подготовке к контрольному рулению	f	f	3	9272
1015	В карту-наряд на ТО и Р АТ	f	f	1	9273
1015	В справку	f	f	2	9274
1015	В бортовом журнале ВС	f	t	3	9275
1016	Экипаж ВС	f	f	1	9276
1016	Непосредственный руководитель работ и специалист, ответственный за общий контроль их качества	f	t	2	9277
1016	Специалист и руководитель работ по ТО и Р АТ	f	f	3	9278
1017	Производится передача карт-нарядов на ТО и Р АТ	f	f	1	9279
1017	Производится передача инструментов на ТО и Р АТ	f	f	2	9280
1017	Производится передача ВС с незаконченным ТО и Р из смены в смену.	f	t	3	9281
1018	Проверить наличие ВС на стоянках	f	f	1	9282
1018	Проверить наличие подписей исполнителей и контролирующих лиц за каждую выполненную работу в предназначенном для оформления ТО и Р документе	f	t	2	9283
1018	Проверить подписи контролирующих лиц за работы в соответствующем документе на ТО и Р АТ	f	f	3	9284
1019	Запрещена	f	t	1	9285
1019	Разрешена	f	f	2	9286
1019	Разрешена соответствующими специальными документами	f	f	3	9287
1020	Применение карты-наряда на ТО и Р АТ	f	f	1	9288
1020	Применение технической документации, позволяющей каждому исполнителю оформлять выполненные им лично работы на момент передачи ВС	f	t	2	9289
1020	Применение бортжурнала, карты-наряда на ТО и Р АТ, позволяющих оформлять передачу ВС	f	f	3	9290
1021	Организуют передачу ВС руководители, ответственные за качество	f	f	1	9291
1021	Специалисты ТО и Р, контролирующие работы	f	f	2	9292
1021	Руководители работ и специалисты, ответственные за контроль качества ТО и Р	f	t	3	9293
1022	Обеспечить меры безопасности, записать и расписаться в журнале передачи смен причины невыполнения отдельной работы, незаконченных операциях, включённых в эту работу	f	t	1	9294
1022	Обеспечить меры безопасности, указать невыполнение отдельной работы, незаконченных операциях, включённых в эту работу	f	f	2	9295
1022	Принять смену без проведения процедур осмотра и контроля	f	f	3	9296
1023	Проверить соответствия выполненного объёма ТО и Р, передать руководителю, принимающей смены техническую документацию на ВС, обеспечить полноту и правильность передачи объектов ТО и Р своими подчинёнными	f	f	1	9297
1023	Проверить соответствия выполненного объёма ТО и Р, подтверждающих подписей исполнителей и контролирующих лиц, передать руководителю, принимающей смены техническую документацию на ВС, обеспечить полноту и правильность передачи объектов ТО и Р своими подчинёнными	f	t	2	9298
1023	Обеспечить правильность передачи, передать руководителю, принимающей смены техническую документацию на ВС, обеспечить полноту и правильность передачи объектов ТО и Р своим авиационным персоналом	f	f	3	9299
1024	Провести наружный осмотр принимаемых ВС, проверить наличие и правильность оформления документации на выполненные работы, проверить записи в журнале передачи смен, получить устную информацию обеспечить полноту и правильность приёмки ВС своими подчинёнными	f	t	1	9300
1024	Обеспечить полноту и правильность приёмки работ, проверить наличие и правильность оформления документации на выполненные работы, проверить записи в журнале передачи смен, получить устную информацию	f	f	2	9301
1024	Провести проверку документации о выполнении работ, наличие и правильность оформления документации на выполненные работы персоналом сдающей смену, записей в журнале передачи смен, получить устную информацию	f	f	3	9302
1025	Ознакомиться с информацией в заполненном журнале передачи смен	f	f	1	9303
1025	Ознакомиться с записями в журнале передачи смен и документаций на принимаемые ВС, провести их наружный осмотр	f	t	2	9304
1025	Провести наружный осмотр ВС, ознакомиться с информацией в заполненном журнале передачи смен	f	f	3	9305
1026	Визуально контролируют объекты АТ, исправность, работоспособность, правильность функционирования определяется с применением средств контроля	f	f	1	9306
1026	Визуально контролируют объекты АТ, исправность, работоспособность изделий не вызывает сомнения	f	f	2	9307
1026	Визуально контролируют объекты АТ, исправность, работоспособность и правильность функционирования которых может быть определена без применения инструментальных средств контроля	f	t	3	9308
1027	Внешние проявления отказа или неисправности АТ	f	t	1	9309
1027	Видимые причины проявление отказа	f	f	2	9310
1027	Невидимые причины проявления отказа изделия АТ	f	f	3	9311
1028	Внешним осмотром, с применением встроенных средств контроля АТ	f	f	1	9312
1303	К химическим	f	t	1	9417
1028	С применением переносных, передвижных, встроенных и стационарных средств	f	t	2	9313
1028	Визуальным осмотром, с применением переносных средств	f	f	3	9314
1029	Исправные инструменты и средства контроля	f	f	1	9315
1029	Исправные инструментальные средства, прошедшие метрологическую поверку и аттестацию, подтверждённую документацией установленного вида	f	t	2	9316
1029	Инструментальные средства, прошедшие метрологическую поверку, аттестацию и имеющие подтверждение	f	f	3	9317
1030	Полноту, достоверность контроля, за соответствие состояние АТ, содержания выполненного ТО и Р и его результатов требованиям ЭРД и производственного задания	f	t	1	9318
1030	Полноту и достоверность проведения ТО и Р и его результатов требованиям ЭРД и производственного задания	f	f	2	9319
1030	Соответствие состояния АТ результатов контроля требованиям ЭРД и производственного задания	f	f	3	9320
1031	Составляют основу деятельности органа по контролю качества (ОКК) в службе ИАОП	f	f	1	9321
1031	Являются частью специальных обязанностей специалистов ОКК в службе ИАОП	f	f	2	9322
1031	Являются частью служебных обязанностей специалистов, ответственных за организацию, производство работ в службе ИАОП и составляют основу деятельности ОКК	f	t	3	9323
1032	Экипаж ВС	f	f	1	9324
1032	Инженерно-технический персонал службы ИАОП	f	f	2	9325
1032	Непосредственные исполнители и руководители работ	f	t	3	9326
1033	Отстранять от выполнения работ подчинённых лиц	f	f	1	9327
1033	Выполнять часть работ без контроля другими должностными лицами	f	t	2	9328
1033	У авиационного предприятия нет права принимать решение	f	f	3	9329
1034	Документами авиационного предприятия	f	t	1	9330
1034	Желанием по этому праву авиационного предприятия	f	f	2	9331
1034	У авиационного предприятия нет такого права	f	f	3	9332
1035	В раздел VI «Бортового журнала самолёта»	f	f	1	9333
1035	В раздел «Выполнение доработок и осмотров по бюллетеням и указаниям» формуляра ВС	f	t	2	9334
1035	Не записываются в документации	f	f	3	9335
1036	Визуально	f	f	1	9336
1036	Выбранной типовой программой	f	f	2	9337
1036	Выбранной его типовой программой или отдельным указанием руководителя, дающего задание на осмотр	f	t	3	9338
1037	Проверка принятых мероприятий по устранению отклонений лётно-технических характеристик (ЛТХ) от требований РЛЭ, выполнения доработок, состояния качества ТО и Р, ведение ЭД, исправности измерительных средств, инструмента, средств наземного обслуживания	f	t	1	9339
1037	Состояние качества ТО и Р, ведение ЭД, исправности измерительных средств, инструмента, средств наземного обслуживания	f	f	2	9340
1037	Устранение отклонений от требований РЛЭ, состояния качества ТО и Р, ведение ЭД	f	f	3	9341
1038	Экипаж ВС, специалистов других служб, имеющих соответствующую подготовку и допуск к работе на АТ	f	f	1	9342
1038	Инструкторский состав лётных подразделений, членов экипажей ВС, специалистов других служб, имеющих соответствующую подготовку и допуск к работе на АТ	f	t	2	9343
1038	Инструкторский состав лётных подразделений, членов экипажей ВС, специалистов других служб	f	f	3	9344
1039	Наименование аэропорта и дату осмотра, фамилию должностного лица	f	f	1	9345
1039	Оценку технического состояния ВС. фамилию должностного лица	f	f	2	9346
1039	Наименование аэропорта, дату осмотра фамилию должностного лица, которому передан «Наряд на дефектацию», оценку технического состояния ВС	f	t	3	9347
1040	Журналах или иных формах учета, которые определяются и ведутся в службах авиапредприятии	f	t	1	9348
1040	Бортовом журнале самолёта и других документах	f	f	2	9349
1040	Карте-наряде на ТО и Р ВС	f	f	3	9350
1041	Бортовом журнале самолёта, карте-наряде	f	f	1	9351
1041	Документах по анализу качества ТО и Р АТ и в других документах, которыми определяются мероприятия по ликвидации выявленных недостатков	f	t	2	9352
1041	Бортовом журнале самолёта, карте-наряде и в других документах, которыми определяются мероприятия по ликвидации выявленных недостатков	f	f	3	9353
1301	Металлическим типом межатомной связи	f	t	3	9413
1302	0÷2%	f	f	1	9414
1042	С его программой с применением действующих технологий ( методик) расшифровки и анализа данных.	f	t	1	9354
1042	С его программой и анализом данных	f	f	2	9355
1042	С результатами контрольного полёта	f	f	3	9356
1043	Требованием руководителя авиапредприятия	f	f	1	9357
1043	Требованиями эксплуатационной документации (ЭД) и производственным заданием	f	t	2	9358
1043	Требованием специальной комиссии авиапредприятия	f	f	3	9359
1044	Авиапредприятие	f	t	1	9360
1044	Экипаж ВС	f	f	2	9361
1044	Специалист по ТО и Р АТ	f	f	3	9362
1045	Специалисту по ТО и Р	f	f	1	9363
1045	Экипажу ВС вместе с заданием на контрольное руление	f	t	2	9364
1045	Руководителю полётов	f	f	3	9365
1046	Экипажу ВС	f	f	1	9366
1046	Руководителю работ по ТО и Р АТ	f	f	2	9367
1046	Вышестоящему руководителю	f	t	3	9368
1047	Любых изделий авиационной техники	f	f	1	9369
1047	Изделий АТ, отказы которых влияют на безопасность полетов	f	t	2	9370
1047	Изделий АТ, отказы которых не влияют на безопасность полетов	f	f	3	9371
1048	Непрерывным	f	f	1	9372
1048	Периодическим	f	f	2	9373
1048	Непрерывным или периодическим	f	t	3	9374
1049	Состав контролируемых параметров изделий, предельно допустимые значения параметров, периодичность и технологию их контроля, необходимые технические средства, правила принятия решений по результатам контроля	f	t	1	9375
1049	Предельно допустимые значения параметров, периодичность и технологию их контроля, правила принятия решений по результатам контроля	f	f	2	9376
1049	Состав контролируемых параметров изделий, периодичность и технологию их контроля, правила принятия решений по результатам контроля	f	f	3	9377
1050	Изделий, отказы которых не оказывают прямого влияния на безопасность полётов	f	t	1	9378
1050	Любых изделий авиационной техники	f	f	2	9379
1050	К изделию, отказы которого влияют на безопасность полётов	f	f	3	9380
1105	амортизатор становится «жёстким» , ход штока уменьшается, происходит увеличение ускорения штока (перегрузка) и, как следствие, - поломка амортизатора	f	t	1	9381
1105	амортизатор становится «мягким», ход штока увеличивается, происходит увеличение ускорения штока (перегрузка) и, как следствие, - поломка амортизатора	f	f	2	9382
1105	амортизатор становится "жёстким", ход штока уменьшается, происходит соударение деталей и поломка амортизатора	f	f	3	9383
1115	централизованная для всех двигателей	f	t	1	9384
1115	раздельная на левую и правую подсистемы с кольцеванием	f	f	2	9385
1115	автономная для каждого двигателя с кольцеванием	f	f	3	9386
1116	насосная подача топлива	f	t	1	9387
1116	самотёчная подача топлива	f	f	2	9388
1116	уменьшение высоты полёта	f	f	3	9389
1117	подачи топлива к форсункам	f	t	1	9390
1117	выработки топлива из баков в требуемой последовательности	f	f	2	9391
1117	преодоления гидросопротивления на пути до насоса высокого давления и создания давления на входе в него для предотвращения кавитации	f	f	3	9392
1118	коррозия топливных баков	f	f	1	9393
1118	забивка топливных фильтров кристаллами льда и, как следствие, снижение прокачиваемости топлива вплоть до прекращения подачи	f	t	2	9394
1118	ухудшение распыления топлива и понижение температуры в камере	f	f	3	9395
1119	основными	f	f	1	9396
1119	дополнительными	f	f	2	9397
1119	расходными	f	t	3	9398
1120	разрывом баков	f	t	1	9399
1120	смятием баков	f	f	2	9400
1120	переполнением баков	f	f	3	9401
1121	переносной огнетушитель	f	f	1	9402
1121	стационарная пожарная система	f	f	2	9403
1121	система нейтрального газа	f	t	3	9404
1122	автономным бортовым компрессором	f	f	1	9405
1122	компрессорами самолетных двигателей	f	t	2	9406
1122	турбинами самолетных двигателей	f	f	3	9407
1300	Твердость, прочность, ударная вязкость	f	f	1	9408
1300	Жидкотекучесть, ковкость, свариваемость	f	f	2	9409
1300	Плотность, цвет, температура плавления	f	t	3	9410
1301	Дефектами упаковки кристаллической структуры	f	f	1	9411
1301	Наличием примесей и внутренних напряжений	f	f	2	9412
1303	К физическим	f	f	2	9418
1303	К механическим	f	f	3	9419
1304	На разрывной машине	f	f	1	9420
1304	На твердомере Роквелла	f	f	2	9421
1304	На маятниковом копре	f	t	3	9422
1305	ХГВ; 9ХС; ХВ5	f	f	1	9423
1305	12Х18Н9; 04Х1Н10; 12Х18Н9Т	f	t	2	9424
1305	ШХ6; ШХ9; 28ХА	f	f	3	9425
1306	Л28	f	f	1	9426
1306	Л62	f	t	2	9427
1306	Л80	f	f	3	9428
1307	Нагружение растяжением	f	f	1	9429
1307	Нагружение кручением	f	f	2	9430
1307	Нагружение ударным изгибом	f	t	3	9431
1308	σв	f	t	1	9432
1308	HB	f	f	2	9433
1308	HV	f	f	3	9434
1309	Ст1; Ст2; Ст4	f	f	1	9435
1309	30ХГСА; 25 ХГСА; 9ХС	f	f	2	9436
1309	Х23Н18; Х12Н20Т3; Х16Н25М6	f	t	3	9437
1310	HRA	f	f	1	9438
1310	HRB	f	t	2	9439
1310	HRC	f	f	3	9440
1311	Цементация	f	f	1	9441
1311	Азотирование	f	t	2	9442
1311	Алитирование	f	f	3	9443
1312	Фермы шасси, стыковые узлы, полки лонжеронов	f	t	1	9444
1312	Пружины амортизаторов, рессоры	f	f	2	9445
1312	Слесарные инструменты, молотки, зубила	f	f	3	9446
1313	ШХ9; ШХ15; ШХ20	f	f	1	9447
1313	50 ХФА; 12ХНЗА; 18ХГТ	f	f	2	9448
1313	15Х25Т; 08Х18Н10Т; 12Х18Н9	f	t	3	9449
1314	50ХФА, 60С2, 50ХГ	f	t	1	9450
1314	Р18, Р9, Р9Ф1	f	f	2	9451
1314	Ст.0, Ст.1, Ст.2	f	f	3	9452
1315	Сталь35, Сталь45, Сталь50	f	f	1	9453
1315	СтальУ8А, СтальУ10, СтальУ13	f	t	2	9454
1315	Сталь 20А; Сталь 35А, Сталь 45А	f	f	3	9455
1316	Повышение пластичности	f	f	1	9456
1316	Повышение твердости	f	t	2	9457
1316	Повышение качества поверхности	f	f	3	9458
1317	Сталь0, Сталь4, Сталь6	f	f	1	9459
1317	СтальА12, СтальА20, СтальА30	f	f	2	9460
1317	СтальУ7А, СтальУ8А, СтальУ10А	f	t	3	9461
1318	Для повышения прочности	f	f	1	9462
1318	Для увеличения коррозионной стойкости	f	t	2	9463
1318	Для повышении пластичности	f	f	3	9464
1319	Закалка и отпуск	f	t	1	9465
1319	Отжиг и нормализация	f	f	2	9466
1319	Нормализация и гомогенизация	f	f	3	9467
1320	5ХНТ, 30 ХГС, 9ХС	f	t	1	9468
1320	У7А, У10, У12А	f	f	2	9469
1320	А12, А20, А30	f	f	3	9470
1321	25ХГСА, 30ХА, 50ХФА	f	f	1	9471
1321	12ХН4А, 30ХГСА, 18ХГТ	f	f	2	9472
1321	Н60В, ХН78Т, ХН77ТЮР	f	t	3	9473
1322	HV	f	t	1	9474
1322	НВ	f	f	2	9475
1322	HRC	f	f	3	9476
1323	σв	f	f	1	9477
1323	δ	f	t	2	9478
1323	НВ	f	f	3	9479
1324	С целью подготовки детали к механической обработке	f	f	1	9480
1324	Получение неравновесной структуры с целью повышения прочности и твердости	f	t	2	9481
1324	С целью разложения аустенита на устойчивые перлитные структуры	f	f	3	9482
1325	А12, А20, А30	f	f	1	9483
1325	ШХ9, ШХ15, ШХ20	f	f	2	9484
1325	25ХГС-Ш, 30ХГС-Ш, 30ГХСН2-Ш	f	t	3	9485
1326	Определение предела прочности	f	f	1	9486
1326	Определение сопротивления металла разрушению от ударных нагрузок	f	t	2	9487
1326	Определение числа твердости	f	f	3	9488
1327	HB	f	t	1	9489
1327	HV	f	f	2	9490
1327	HRC	f	f	3	9491
1328	Температурой нагрева	f	f	1	9492
1328	Скоростью охлаждения	f	t	2	9493
1328	Длительностью выдержки	f	f	3	9494
1329	ХВ5,9ХС,ХВГ	f	f	1	9495
1329	Р9,Р18,Р9Ф	f	f	2	9496
1329	15ХФА, 12ХНЗА, 20ХА	f	t	3	9497
1330	Жидкотекучесть, свариваемость, ковкость, обрабатываемость резанием	f	t	1	9498
1330	Плотность, цвет, блеск, магнитные свойства	f	f	2	9499
1330	Свойства металлов взаимодействовать с электролитами, неэлектролитами, газами, другими элементами	f	f	3	9500
1331	HB	f	f	1	9501
1331	HV	f	f	2	9502
1331	HRC	f	t	3	9503
1332	В воде	f	f	1	9504
1332	В масле	f	t	2	9505
1332	На воздухе	f	f	3	9506
1333	Плотность, цвет, блеск, магнитные свойства	f	f	1	9507
1333	Жидкотекучесть, ковкость, свариваемость, обрабатываемость резанием	f	f	2	9508
1333	Прочность, твердость, ударная вязкость, выносливость	f	t	3	9509
1334	Перлит	f	f	1	9510
1334	Сорбит	f	f	2	9511
1334	Мартенсит	f	t	3	9512
1335	В воде	f	t	1	9513
1335	На воздухе	f	f	2	9514
1335	Вместе с печью	f	f	3	9515
1336	Число твердости	f	t	1	9516
1336	Ударную вязкость	f	f	2	9517
1336	Прочность металла	f	f	3	9518
1337	М	f	f	1	9519
1337	проценты	f	t	2	9520
1337	Мн/м2	f	f	3	9521
1338	28ХА, 10 Г2А, 55С2А	f	t	1	9522
1338	12Х18Н9, 08Х18Н10Т, 15Х25Т	f	f	2	9523
1338	Р18, Р9Ф1, Р9	f	f	3	9524
1339	На прессе Бринеля	f	t	1	9525
1339	На маятниковом копре	f	f	2	9526
1339	На разрывной машине	f	f	3	9527
1340	Камеры сгорания, лопатки газовых турбин	f	f	1	9528
1340	Шариковые, роликовые, игольчатые подшипники	f	t	2	9529
1340	Молотки, зубила, слесарные тиски	f	f	3	9530
1341	Определение предела прочности и показателей пластичности	f	t	1	9531
1341	Определение коэффициента ударной вязкости	f	f	2	9532
1341	Определение числа твердости	f	f	3	9533
1342	Сталь 15А, Сталь 20 А, Сталь 30А	f	f	1	9534
1342	Сталь У7А, СтальУ9А, Сталь У12А	f	t	2	9535
1342	Сталь 20, Сталь 20Г2, Сталь 30Г2	f	f	3	9536
1343	МH/М^2	f	t	1	9537
1343	проценты	f	f	2	9538
1343	Дж/М^2	f	f	3	9539
1344	СЧ12, СЧ18, СЧ25	f	f	1	9540
1344	КЧ37-12, КЧ35-10,КЧ56-8	f	f	2	9541
1344	ВЧ50-1, ВЧ40-2, ВЧ45-5	f	t	3	9542
1345	Универсальные стали, их номера №7, №8, №10	f	f	1	9543
1345	Железоуглеродистые сплавы с содержанием углерода С=7%, С=8%, С=10%	f	f	2	9544
1345	Углеродистые инструментальные стали качественные с содержанием углерода С=0.7%, С=0.8%, С=1%	f	t	3	9545
1346	У10А, У12А, У13А	f	f	1	9546
1346	Т5К10, Т15К6, Т30К4	f	t	2	9547
1346	ШХ15, Ш9, ШХ20	f	f	3	9548
1347	Р9, Р9Ф1, Р18	f	f	1	9549
1347	ШХ9, ШХ15, ШХ20	f	t	2	9550
1347	ВК6, ВК8, Т15К6	f	f	3	9551
1348	Закалка и отпуск	f	f	1	9552
1348	Закалка и высокий отпуск	f	t	2	9553
1348	Одновременно основной металл и покрытие	f	f	3	9554
1349	Основной металл	f	f	1	9555
1349	Покрытие	f	t	2	9556
1349	Одновременно основной металл и покрытие	f	f	3	9557
1350	Винипласт, пластикат	f	f	1	9558
1350	Текстолит, гетинакс	f	t	2	9559
1350	Полиэтилен, полистирол	f	f	3	9560
1351	Прозрачные пластмассы	f	f	1	9561
1351	Пластмассы с высокой ударной вязкостью	f	f	2	9562
1351	Пластмассы с высокой износоустойчивостью и большим коэффициентом трения	f	t	3	9563
1352	Первым слоем	f	t	1	9564
1352	Вторым слоем	f	f	2	9565
1352	Третьим слоем	f	f	3	9566
1353	Карболит, гетинакс	f	f	1	9567
1353	Гетинакс, стеклотекстолит	f	f	2	9568
1353	Винипласт, полиэтилен	f	t	3	9569
1354	Бумагу	f	t	1	9570
1354	Стекловолокно	f	f	2	9571
1354	Древесную муку	f	f	3	9572
1355	Основной металл	f	t	1	9573
1355	Покрытие	f	f	2	9574
1355	Основной металл и покрытие одновременно	f	f	3	9575
\.


--
-- Data for Name: rosaviatest_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rosaviatest_category (id, title, image) FROM stdin;
1	основ полета	
2	аэронавигации (самолетовождения)	
3	по получению и применению метеорологических сводок, карт и прогнозов, кодов и сокращений	
4	о возможностях человека, включая принципы контроля факторов угрозы и ошибок	
5	правил обеспечения безопасности при полетах в визуальных метеорологических условиях	
6	правил эксплуатации и ограничений воздушных судов	
7	основных принципов устройства силовых установок, газотурбинных и/или поршневых двигателей; характеристик топлива	
8	опасных для полетов метеорологических явлений, особых условий погоды	
9	правил полетов	
10	авиационной метеорологии; климатологии и ее влияния на авиацию	
11	компасов, гироскопических приборов, правил и порядка действий при неисправностях различных пилотажных приборов	
12	правил ведения радиосвязи и фразеологии	
13	использования авиационного электронного и приборного оборудования	
14	воздушного законодательства	
15	аварийных ситуаций и выживаемости	
16	назначений аварийно-спасательного снаряжения воздушных судов, правил его эксплуатации	
17	правил технического обслуживания воздушных судов	
18	планера, органов управления, колесных шасси, тормозов, систем	
19	использования аэронавигационной документации, авиационных кодов и сокращений	
20	подготовки и представления планов полета	
21	процедур, связанных с актами незаконного вмешательства в деятельность гражданской авиации	
22	оборудования воздушных судов	
23	о режимах вихревого кольца, земного резонанса, срыва на отступающей лопасти, динамического опрокидывания и других опасных ситуаций	
25	эксплуатационных ограничений воздушных судов	
26	принципов действия свободных аэростатов, систем и приборного оборудования	
27	физических характеристик газов, используемых в свободных аэростатах	
28	систем наддува и кондиционирования воздуха, кислородных систем	
30	основ математики; единиц измерения	
31	фундаментальных принципов и теоретических основ физики и химии	
32	характеристик материалов	
33	правил полетов судов	
\.


--
-- Data for Name: rosaviatest_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rosaviatest_questions (id, title, explanation, correct_answer) FROM stdin;
2	Загрузка самолёта произведена так, что центр тяжести находится за предельно задней центровкой. Одним из нежелательных эффектов, который пилот может испытать будет:	\N	\N
4	Аэродинамическое качество воздушного судна равно 30. Сколько километров оно пролетит без тяги двигателей, потеряв 2000 футов высоты?	\N	\N
5	Планер снизился на 2000 футов пролетев 17 километров. Аэродинамическое качество при этом:	\N	\N
6	Определите максимальную скорость ветра для встречно-бокового ветра в 45° если максимальная составляющая бокового ветра для данного BC равна 25 узлов.	\N	\N
7	Определите максимальную скорость ветра для встречно-бокового ветра в 30° если максимальная составляющая бокового ветра для данного самолёта равна 12 узлов.	\N	\N
8	При сообщённом северном ветре в 20 узлов, какая из ВПП: 6, 29 или 32, приемлема для самолёта с максимальным боковым ветром в 13 узлов?	\N	\N
9	При сообщённом южном ветре в 20 узлов, какая из ВПП: 10, 14 или 24, наиболее подходящая для самолёта с максимальным боковым ветром в 13 узлов?	\N	\N
10	Если магнитный курс равный 135° приводит к линии фактического пути в 130°, и истинная скорость в 135 узлов приводит к путевой скорости 140 узлов, то ветер:	\N	\N
11	Сколько километров пролетит воздушное судно за 3 минуты при путевой скорости в 160 км/ч?	\N	\N
12	Сколько километров пролетит воздушное судно за 10 минут при путевой скорости в 360 км/ч?	\N	\N
13	Чему равна встречная составляющая ветра при посадке на ВПП 18, если диспетчер вышки сообщил ветер 20 м/с и 220°?	\N	\N
14	Максимальная продолжительность полёта достигается в точке с минимальной мощностью при поддержании воздушного судна:	\N	\N
15	Масса самолёта равна 3300 фунтов. Приблизительно какой вес должна выдержать конструкция воздушного судна в повороте с креном 30° при выдерживании постоянной высоты?	\N	\N
16	Масса самолёта равна 4500 фунтов. Приблизительно какой вес должна выдержать конструкция воздушного судна в повороте с креном 45° при выдерживании постоянной высоты?	\N	\N
17	Переведите сообщенное давление QFE 996 гПа в ONH, если превышение торца аэродрома 410 футов:	\N	\N
18	Определите высоту по давлению на аэродроме с превышением 3563 MSL и QNH 29.96.	\N	\N
19	Что такое абсолютная высота?	\N	\N
20	Что такое истинная высота?	\N	\N
21	При каких условиях высота, непосредственно считываемая с барометрического высотомера равна абсолютной высоте?	\N	\N
22	При каких условиях высота по давлению равна истинной высоте?	\N	\N
23	При каких условиях истинная высота ниже, чем приборная высота?	\N	\N
24	Какое утверждение относится к принципу Бернулли?	\N	\N
25	KMEM 121720Z 121818 20012KT SSM HZ BKN030 PROB40 2022 ISM TSRA OVC008CB FM2200 33015G20KT P6SM BKN015 OVC025 PROB40 2202 3SM SHRA FM0200 35012KT OVC008 PROB40 0205 2SM -RASN BECMG 0608 02008KT BKN012 BECMG 1012 00000KT 3SM BR SKC TEMPO 1214 1/2SM FG FM1600 VRB06KT P6SM SKC=. Что в данном прогнозе означает SHRA?	\N	\N
26	Как приблизительно может быть вычислена маневренная скорость VA для современных самолётов?	\N	\N
27	Подверженность отравлению моноксидом углерода увеличивается ...	\N	\N
28	Высокая концентрация моноксида углерода в человеческом теле приводит	\N	\N
29	Какой наиболее эффективный способ поиска встречных воздушных судов в дневные часы с целью предотвращения столкновения?	\N	\N
30	Какой наиболее эффективный способ использовать глаза при ночном полёте?	\N	\N
31	Какой наиболее эффективный способ поиска встречных воздушных судов ночью?	\N	\N
32	Какой наиболее эффективный способ поиска встречных воздушных судов ночью с целью предотвращения столкновения?	\N	\N
33	Какое утверждение о широте и долготе верное?	\N	\N
34	Какое средство от опасной психологической установки у пилота, называемой импульсивность?	\N	\N
35	Какое средство от опасной психологической установки у пилота, называемой неуязвимость?	\N	\N
36	Какое средство против опасной психологической установки у пилота, называемой обречённость?	\N	\N
357	Что такое седловина?	\N	\N
37	Игнорирование минимального остатка топлива, как правило, является результатом самоуверенности, игнорирования правил, или:	\N	\N
38	В процессе принятия решений, какой первый шаг для нейтрализации опасных психологических установок?	\N	\N
39	Состояние временного замешательства, возникающего от несогласованной информации, поступающей в мозг от разных органов чувств называется как:	\N	\N
40	Если пилот испытывает пространственную дезориентацию в полёте в условиях низкой видимости, лучшим способом преодолеть это состояние является:	\N	\N
41	Какой фактор чаще влияет на большинство авиационных происшествий?	\N	\N
42	Что наиболее часто ведёт к потере пространственной ориентации и столкновениям с поверхностью / препятствиями при полётах по правилам визуальных полётов (ПВП)?	\N	\N
43	Какое положение органов управления самолёта с передним рулевым колесом рекомендуется использовать при рулении при левом-встречном ветре?	\N	\N
44	При рулении на самолёте в условиях сильного попутно-бокового ветра, какое положение элеронов рекомендуется использовать?	\N	\N
45	Какое начальное действие необходимо предпринять при падении оборотов несущего винта и высоком наддуве?	\N	\N
46	При рулении, ручка общего шага используется для управления:	\N	\N
47	При рулении, ручка циклического шага используется для управления:	\N	\N
48	Вы только что приземлились на контролируемом аэродроме, и диспетчер ОВД предложил связываться с рулением после освобождения ВПП. Считается, что воздушное судно освободило ВПП когда:	\N	\N
49	Если пилот подозревает, что двигатель (с винтом фиксированного шага) испытывает детонацию при наборе высоты после взлёта, начальное корректирующее действие должно быть:	\N	\N
50	Детонация может возникать при высокой мощности двигателя когда:	\N	\N
51	Во время ночного полёта вы наблюдаете немигающий белый и мигающий красный огни впереди на вашей же высоте. В каком направлении движется другое воздушное судно?	\N	\N
52	Во время ночного полёта вы наблюдаете немигающие красный и зеленый огни впереди на вашей же высоте. В каком направлении движется другое воздушное судно?	\N	\N
53	Какой фактор наиболее опасен при полётах вблизи грозы?	\N	\N
54	Регулярное использование карты контрольных проверок это признак:	\N	\N
55	Какую скорость после взлёта следует выдерживать, чтобы набрать максимум высоты за данный период времени?	\N	\N
56	Движение воздушных масс влияет на скорость, с которой воздушное судно движется	\N	\N
57	Оказывает ли влажность влияние на лётные характеристики воздушного судна и если оказывает, то какое именно?	\N	\N
58	Скороподъёмность зависит от:	\N	\N
59	Какая комбинация атмосферных условий ухудшает летные характеристики воздушного судна при взлёте и наборе высоты?	\N	\N
60	В чём заключается опасность инея на поверхности воздушного судна?	\N	\N
61	Взмывание, вызываемое экранным эффектом земли, будет наиболее заметным при заходе на посадку, когда:	\N	\N
62	Что нужно знать об экранном эффекте земли?	\N	\N
63	К какой проблеме наиболее вероятно приведёт экранный эффект земли?	\N	\N
64	К чему приводит экранный эффект земли?	\N	\N
65	Наиболее критические условия, влияющие на взлётные характеристики, являются результатом влияния высокой взлётной массы, превышения аэродрома, температуры и:	\N	\N
66	С точки зрения обледенения карбюратора, карбюраторы поплавкового типа по сравнению с инжекторными системами, как правило, считаются:	\N	\N
67	Зеленый сигнал постоянного свечения с диспетчерской вышки воздушному судну в полёте означает:	\N	\N
68	Надписи 8 и 26 на торцах ВПП указывают, что посадочный курс ВПП приблизительно:	\N	\N
69	Маркировка места ожидания у ВПП на рулёжных дорожках	\N	\N
70	Представьте себе прямоугольный знак с чёрным текстом на желтом фоне. На знаке нарисована стрелка слева направо, а за стрелкой буква B. Такой знак является визуальной подсказкой:	\N	\N
71	Представьте себе прямоугольный черный знак. На знаке нарисован желтый номер 22. Также присутствует тонкая желтая окантовка. Такой знак подтверждает ваше положение:	\N	\N
72	Представьте себе красный знак с белыми цифрами 4-22. Такой знак (и соответствующие знаки на поверхности) подтверждает, что вы:	\N	\N
73	Представьте себе знак на искусственном покрытии - желтый прямоугольник с четырьмя черными полосами пересекающие его. Две верхних линии пунктирные, две нижних - сплошные. Если вы видите такой знак из кабины воздушного судна, вы ...	\N	\N
74	Представьте себе знак с белым текстом 15-33 на красном фоне. Такой знак является примером:	\N	\N
75	При заходе на посадку на ВПП, имеющую систему визуальной индикации глиссады (VASI), пилот обязан:	\N	\N
76	Какое сочетание огней PAPI указывает, что воздушное судно находится немного выше глиссады?	\N	\N
77	В каком классе воздушном пространстве запрещены полёты по ПВП?	\N	\N
78	При каких условиях высотомер показывает высоту меньше, чем абсолютная высота?	\N	\N
79	Как изменения температуры влияют на показания высотомера?	\N	\N
80	Перед взлётом с аэродрома, не являющегося контролируемым, на какое значение должен быть установлен высотомер?	\N	\N
81	Если полёт проходит из области пониженного давления в область повышенного давления, без корректировки установки высотомера, то высотомер покажет:	\N	\N
82	Если полёт проходит из области повышенного давления в область пониженного давления, без корректировки установки высотомера, то высотомер покажет:	\N	\N
83	Угол атаки, при котором возникает сваливание крыла самолета:	\N	\N
84	Термин угол атаки определён как угол:	\N	\N
85	Термин угол атаки определён как угол между хордой аэродинамической поверхности и:	\N	\N
86	Угол между хордой крыла и вектором скорости потока известен как угол:	\N	\N
87	Термин угол атаки определён как угол:	\N	\N
88	Если отказ рулевого винта происходит при посадке, что может быть сделано для исправления левого вращения перед касанием?	\N	\N
89	Уход на второй круг после неудачного захода на посадку:	\N	\N
90	Какое положение элеронов наиболее предпочтительно при рулении при сильном встречно-боковом ветре?	\N	\N
91	С целью уменьшения боковой нагрузки на шасси непосредственно перед приземлением, пилот должен поддерживать:	\N	\N
92	Какое измерение может быть использовано для определения стабильности атмосферы?	\N	\N
93	Что приводит к уменьшению стабильности воздушной массы?	\N	\N
94	Каковы признаки стабильности воздушных масс?	\N	\N
95	Где и при каких условиях можно найти достаточно восходящих потоков для планирования при относительно стабильной атмосфере?	\N	\N
96	Какую предосторожность нужно соблюдать при снижении на авторотации?	\N	\N
97	Что показывает индикатор поворота?	\N	\N
98	Включение подогрева карбюратора приведет к ...	\N	\N
99	В общем случае, как влияет включение подогрева карбюратора на работу двигателя?	\N	\N
100	Присутствие льда в карбюраторе на самолёте с воздушным винтом фиксированного шага может быть проверено включением подогрева карбюратора и ...	\N	\N
101	Вероятность образования льда в карбюраторе существует, даже если температура окружающего воздуха ...	\N	\N
102	Какие условия наиболее благоприятны для образования льда в карбюраторе?	\N	\N
103	Если самолёт оборудован воздушным винтом фиксированного шага, и карбюратором поплавкового типа, первыми признаками обледенения карбюратора наиболее вероятно будет ...	\N	\N
104	Основное предназначение рулевого винта?	\N	\N
105	Обледенение карбюратора может произойти при температурах наружного воздуха вплоть до ...	\N	\N
106	Образование какого типа облаков можно ожидать при поднятии нестабильной воздушной массы?	\N	\N
107	Какой тип облаков обладают наибольшей турбулентностью?	\N	\N
108	Орган ОВД передаёт информацию воздушному судну, летящему с курсом 090°: Для информации, борт на 3 часах, удаление 4, движется в западном направлении. Куда должен смотреть пилот при поиске другого воздушного судна?	\N	\N
109	Орган ОВД передаёт информацию воздушному судну, летящему с курсом 360°: Для информации, борт на 10 часах, удаление 4, движется в южном направлении. Куда должен смотреть пилот при поиске другого воздушного судна?	\N	\N
110	Орган ОВД передаёт информацию воздушному судну, летящему на север при штилевом ветре: TRAFFIC 9 OCLOCK, 2 MILES, SOUTHBOUND.... Куда должен смотреть пилот при поиске другого воздушного судна?	\N	\N
111	Какой эффект оказывает дымка ночью на способность видеть другие воздушные суда или объекты на поверхности земли?	\N	\N
112	Как можно определить, что встречное воздушное судно находится на курсе столкновения с вашим воздушным судном?	\N	\N
113	Наибольшее количество столкновений в воздухе происходит ...	\N	\N
114	Наибольшее количество столкновений в воздухе происходит ...	\N	\N
115	Если температура наружного воздуха на данной высоте выше стандартной, то высота по барометрическому высотомеру:	\N	\N
116	Заход по ПВП для посадки ночью должен выполняться	\N	\N
117	Какая сила заставляет воздушное судно выполнять разворот?	\N	\N
118	Четыре силы, действующие на воздушное судно:	\N	\N
119	Выход из сваливания требует:	\N	\N
120	В какое состояние самолёт должен попасть, чтобы войти в штопор?	\N	\N
121	При штопоре с вращением влево, какое(-ие) консоли крыла находится в состоянии сваливания?	\N	\N
122	Какой из способов наиболее вероятно поможет охладить двигатель при перегреве?	\N	\N
123	Как изменится топливовоздушная смесь, если включить обогрев карбюратора?	\N	\N
124	В крейсерском полёте на высоте 9500 футов топливовоздушная смесь отрегулирована оптимально. Что произойдёт если снизиться до 4500 футов без регулирования смеси?	\N	\N
125	Основная цель регулирования топливовоздушной смеси с высотой:	\N	\N
126	Что из перечисленного наиболее вероятно приведёт к перегреву цилиндров и масла?	\N	\N
127	Если октановое число бензина менее чем указано для данного двигателя это, скорее всего, приведёт к:	\N	\N
128	При низких температурах воздуха рекомендуется заполнение топливных баков под пробки после последнего полёта в день в целях:	\N	\N
129	У аэродрома одна ВПП - 08-26 Ветра нет Обычный заход при посадке в штилевых условиях - левая коробочка на ВПП 08. Гроза с дождем формируется в 12 километрах к западу от аэродрома. Наиболее лучшим решением будет:	\N	\N
130	В каких условиях можно ожидать самого быстрого нарастания структурного льда?	\N	\N
131	Одно из условий необходимое для образования обледенения конструкции это:	\N	\N
132	Для борьбы с пространственной дезориентацией пилоты должны полагаться на:	\N	\N
133	Какие погодные условия могут ожидаться под слоем низковысотной температурной инверсии при высокой относительной влажности?	\N	\N
134	Наличие ледяной крупы на поверхности земли является признаком:	\N	\N
135	Утомление является наиболее коварной опасностью для безопасности полётов:	\N	\N
136	Угловая разница между истинным севером и магнитным севером это:	\N	\N
137	Необычно высокое показание прибора температуры масла двигателя может быть вызвано:	\N	\N
138	Загрузка самолёта так, что ЦТ смещён к хвостовой части в пределах диапазона центровок приведёт к тому, что самолёт будет:	\N	\N
139	Какое описание наилучшим образом определяет гипоксию?	\N	\N
140	Чему равны стандартная температура и давление на уровне моря?	\N	\N
141	Для какого воздушного судна пилот обязан иметь квалификационную отметку о типе?	\N	\N
142	Какие условия приводят к образованию инея?	\N	\N
143	Какое явление указывает на начало стадии зрелого грозового облака?	\N	\N
144	Приблизительно на какой высоте будет располагаться нижняя кромка кучевых облаков если температура воздуха у поверхности земли равна 28C и точка росы 3C?	\N	\N
145	Какой погодный феномен всегда сопровождает грозу?	\N	\N
146	Гроза достигает максимальной интенсивности во время стадии:	\N	\N
147	В течение жизни грозы, какая стадия характеризуется в основном ниспадающими потоками воздуха?	\N	\N
148	Какой тип облаков указывают на наличие конвективной турбулентности?	\N	\N
149	Какие условия необходимы для образования грозы?	\N	\N
150	Случайной установки каких кодов пилот должен избегать при установке кода транспондера?	\N	\N
151	Случайной установки каких кодов пилот должен избегать при установке кода транспондера?	\N	\N
152	Вихревой след от законцовок крыла создаётся только когда воздушное судно:	\N	\N
153	Что необходимо сделать для предотвращения попадания в спутный след большого реактивного самолёта, если он пересекает ваш путь слева направо приблизительно в 1 км впереди на вашей высоте?	\N	\N
154	Вихревой след от законцовок крыла, создаваемый тяжёлым воздушным судном имею тенденцию:	\N	\N
155	При взлёте позади большого воздушного судна, пилот должен избегать турбулентности спутного следа оставаясь:	\N	\N
156	При посадке позади большого воздушного судна, пилот должен избегать турбулентности спутного следа оставаясь:	\N	\N
157	Любой погодный процесс сопровождается или является результатом:	\N	\N
158	Каковы признаки нестабильности воздушных масс?	\N	\N
159	Какие характеристики наиболее вероятно имеет стабильная воздушная масса?	\N	\N
160	Граница между двумя воздушными массами обычно называется:	\N	\N
161	Одним из резких изменений, легко распознаваемых при полёте сквозь погодный фронт является:	\N	\N
162	Один из погодных феноменов, который всегда случается при полёте сквозь погодный фронт является изменение:	\N	\N
163	Равномерные осадки, идущие перед прохождением фронта, являются признаком	\N	\N
164	Количество влаги, которое может содержаться в воздухе зависит от:	\N	\N
165	Облака, туман, или роса всегда образуются когда:	\N	\N
166	С помощью каких процессов влага попадает в ненасыщенный воздух?	\N	\N
167	Влага попадает в воздух с помощью:	\N	\N
168	Что имеется в виду под термином точка росы?	\N	\N
169	Если разница между температурой и точкой росы небольшая и уменьшается, температура равна 17С, какую погоду можно ожидать?	\N	\N
170	Приблизительно на какой высоте будет располагаться нижняя кромка кучевых облаков если температура воздуха у поверхности земли на 1000 ft MSL равна 21C и точка росы 9C?	\N	\N
171	Где можно ожидать возникновения опасного сдвига ветра?	\N	\N
172	Где может возникать сдвиг ветра?	\N	\N
173	Каковы будут показания барометрического высотомера на аэродроме перед взлётом, если на его барометрической шкале установлен уровень отсчёта: 1)<br />QFE? 2) QNH?	\N	\N
174	В полёте на высоте 1000 м произошла закупорка магистрали статического давления на выходе ПВД. Как изменятся показания высотомера: 1) при снижении до 500 м? 2) при наборе высоты 1500 м?	\N	\N
175	В полёте на высоте 1000 м и приборной скорости 150 км/ч произошла закупорка системы полного давления. Каковы будут показания указателя скорости:	\N	\N
176	Если дюза вариометра засорится наполовину, показания прибора (по модулю) будут завышенными или заниженными?	\N	\N
177	Справедливо ли утверждение, что авиагоризонт - это гироскоп, корректируемый маятником? Когда эту коррекцию необходимо отключать?	\N	\N
178	Выполняя маршрутный полёт с использованием магнитного компаса, мы читаем и выдерживаем по шкале прибора магнитный или какой-то другой курс?	\N	\N
179	Обязательна ли в настоящее время установка АРМ на лёгкое и сверхлегкое ВС (СВС)?	\N	\N
180	Первоочередное действие экипажа, совершившего вынужденную посадку вне аэродрома	\N	\N
181	Основное условие безопасности эвакуации пострадавших спасательным вертолетом с режима висения при использовании спускаемого спасательного оборудования (подъемного кресла, люльки, пояса и т.п.).	\N	\N
182	Последовательность действий по оказанию первой помощи при клинической смерти:	\N	\N
183	На какой частоте спутниковой частью системы Коспас-Сарсат осуществляется обработка сигналов авиационных аварийных радиобуев:	\N	\N
184	С повышением температуры и понижением давления скорость отрыва и длина разбега (при прочих равных условиях):	\N	\N
185	Выпускать в полёт ВС, покрытое льдом, снегом или инеем:	\N	\N
186	Какие метеоэлементы могут осложнить полёты на малых высотах?	\N	\N
187	Назовите опасные для авиации явления погоды:	\N	\N
188	При полёте навстречу тёплому фронту какие облака являются предвестниками приближения к этому фронту?	\N	\N
189	От каких факторов зависят метеоусловия при полёте в той или иной барической системе?	\N	\N
358	Какие типы атмосферных фронтов различают?	\N	\N
190	Международные авиационные метеорологические коды TAF и METAR: значение кодового слова CAVOK:	\N	\N
191	Международные авиационные метеорологические коды TAF и METAR: значение кодового слова SCT	\N	\N
192	Как обозначаются кучево-дождевые облака?	\N	\N
193	Какова структура Воздушного законодательства РФ?	\N	\N
194	Какое место в системе приоритетов ИВП занимают полёты АОН?	\N	\N
195	Какое ВС может быть допущено к полёту?	\N	\N
196	Укажите, какие из перечисленных ниже Ваших действий будут отнесены к нарушениям порядка ИВП РФ, с последующим расследованием и привлечением к ответственности?	\N	\N
197	При посадке на аэродроме назначения после выполнения маршрутного полёта на высотах ниже нижнего эшелона, - когда выполняется перевод давления со значения QNH (маршрутного) на значение QFE или QNH аэродрома?	\N	\N
198	Для выполнения функций командира ВС каких 6-ти видов необходимо получение свидетельства, предусмотренного ФАП-147?	\N	\N
199	Может ли частный пилот осуществлять оперативное обслуживание ВС?	\N	\N
200	Значение при ведении радиообмена фразы РАБОТАЙТЕ (CONTACT)....	\N	\N
201	Обязан ли экипаж ВС при получении диспетчерских указаний повторить сообщение о рабочем направлении ВПП и установке высотомера?	\N	\N
202	Какое время используется в радиообмене при передаче сообщений о времени?	\N	\N
203	Согласно требованиям ФАП-362 Порядок осуществления радиосвязи в воздушном пространстве Российской Федерации, на каких этапах полёта диспетчер (РП) не должен вступать в радиообмен с экипажем ВС? Имеются ли здесь исключения?	\N	\N
204	На чём основана и что собой представляет концепция (технология) CRM?	\N	\N
205	Укажите НЕПРАВИЛЬНУЮ точку зрения на причины вестибулярных иллюзий в полёте.	\N	\N
206	Что такое преждевременная психическая демобилизация?	\N	\N
207	Наиболее часто указываемые в актах расследования причины АП по ЧФ в АОН:	\N	\N
208	При отсутствии служб авиационной безопасности командир ВС:	\N	\N
209	Дайте определение авиационной безопасности:	\N	\N
210	Аэродинамическим качеством крыла называется:	\N	\N
211	Поляра крыла это:	\N	\N
212	Наивыгоднейший угол атаки крыла альфа наив. это:	\N	\N
213	Критический угол атаки крыла альфа крит:	\N	\N
214	С увеличением высоты потребная скорость горизонтального полёта на данном угле атаки:	\N	\N
215	С уменьшением полётной массы потребная скорость горизонтального полёта:	\N	\N
216	Тяга потребная для горизонтального полёта с увеличением скорости от минимальной до максимальной:	\N	\N
217	Для увеличения скорости полёта в 2 раза потребную мощность необходимо увеличить:	\N	\N
218	Наивыгоднейшая скорость:	\N	\N
219	Потребная мощность является:	\N	\N
220	Располагаемая мощность у поршневого двигателя без нагнетателя с увеличением высоты:	\N	\N
221	Диапазоном скоростей горизонтального полета называется:	\N	\N
222	Установившийся вираж это:	\N	\N
223	Диапазон скорости дельта V с увеличением полётной массы ЛА:	\N	\N
224	В характеристиках ЛА указана максимальная скорость горизонтального полёта (работа СУ на максимальной мощности). Возможен ли подъём ЛА на этой скорости?	\N	\N
225	Скороподъемность ЛА (Vy) с увеличением высоты:	\N	\N
226	В режиме набора высоты в штиль за 1 минуту ВС достигло 300 м. При встречном ветре 10м/с за такое же время он наберёт:	\N	\N
227	При попадании в турбулентность необходимо:	\N	\N
228	Что определяет продольную устойчивость самолета?	\N	\N
229	Угол атаки, при котором возникает срыв на крыле самолета, будет:	\N	\N
230	С увеличением полётной массы скорость сваливания (минимально допустимая скорость):	\N	\N
231	Самолет был загружен таким образом, что ЦТ смещён к хвостовой части в пределах диапазона центровок. С какими нежелательными проявлениями в характеристиках самолёта может столкнуться пилот?	\N	\N
232	Октановое число топлива:	\N	\N
233	Рабочий цикл двигателя:	\N	\N
234	Чем характеризуется явление детонации:	\N	\N
235	Какую нагрузку воспринимает лонжерон крыла:	\N	\N
236	Винт изменяемого шага позволяет:	\N	\N
237	Допустима ли заправка ВС из пластмассовых канистр?	\N	\N
238	Должен ли осматривать ВС пилот, если предполётная подготовка уже выполнена техником?	\N	\N
239	На кого возложена ответственность за подготовку ВС к полёту?	\N	\N
240	Техническое обслуживание планера воздушного судна выполняется:	\N	\N
241	Порядок определения северной широты географической точки на картах по системе координат Гаусса.	\N	\N
242	Порядок определения восточной долготы географической точки на картах по Системе координат Гаусса.	\N	\N
243	Измерение направления полета. Магнитный курс (МК) - дать определение.	\N	\N
244	Определение значения МПУ и МК следования по замерам истинного путевого угла (ИПУ) на карте.	\N	\N
245	Правила ведения визуальной ориентировки. Укажите наиболее правильный и полный ответ.	\N	\N
246	Определить правильный расчет подлётного времени на этапе маршрута. Даны: ЗМПУ=045гр; воздушная скорость У=120км/ч; направление ветра НВ=360гр; скорость ветра U=15км/ч; расстояние до поворотного пункта S=39km.	\N	\N
247	Визуальная ориентировка. Пролетели 4,5 минуты на скорости 120км/ч от ИПМ в заданном направлении. Вероятное место ВС на карте масштаба 1см=2км.	\N	\N
248	При выполнении полета по ПВП обход искусственных препятствий, наблюдаемых впереди по курсу воздушного судна и превышающих высоту его полета производится:	\N	\N
249	Действия командира воздушного судна (КВС) при встрече с условиями, исключающими полеты по Правилам визуального полета.	\N	\N
250	Ориентиры это...	\N	\N
251	Укажите правильное определение термина Относительная высота.	\N	\N
252	Ширина маршрута в контролируемом воздушном пространстве ниже эшелона перехода:	\N	\N
253	Какую информацию должен иметь КВС перед выполнением любого полёта	\N	\N
254	Что необходимо учитывать при расчёте количества топлива и масла	\N	\N
255	Минимум наличия приборного оборудования на борту ВС при выполнении полётов по ПВП	\N	\N
256	Что из указанного входит в перечень минимально необходимого оборудования, находящегося на борту любого воздушного судна при выполнении полётов по ППП с экипажем из двух человек	\N	\N
257	Должен ли быть установлен на ВС аварийный радиомаяк	\N	\N
258	Какие значения давления должны быть установлены на барометрическом высотомере для соответствия уровням начала отсчетов высоты при выполнении различных видов полётов	\N	\N
259	Запрещается выполнять полёты	\N	\N
260	Полет по ПВП на истинных высотах менее 300 м выполняется:	\N	\N
261	Полет по ПВП на истинных высотах 300 м и выше выполняется	\N	\N
262	На каких высотах запрещается выполнять полёт по ППП	\N	\N
263	В начале движения должен ли КВС проверить работу тормозной системы	\N	\N
264	Скорость руления не должна превышать	\N	\N
265	Запрещается выполнять взлет	\N	\N
266	При пересечении высоты перехода при наборе высоты летный экипаж воздушного судна обязан	\N	\N
267	Из чего состоит подготовка экипажа к полёту	\N	\N
268	Виды обеспечения полётов:	\N	\N
269	Полёты ВС подразделяются	\N	\N
270	Минимумы выполнения полётов устанавливаются:	\N	\N
271	Минимум командира воздушного судна для взлета:	\N	\N
272	Минимум командира воздушного судна для посадки устанавливается:	\N	\N
273	Безопасная высота круга полетов над аэродромом определяется с таким расчетом, чтобы истинная высота полета воздушного судна над наивысшим препятствием (запас высоты над препятствием) в полосе шириной 10 км (по 5 км в обе стороны от оси маршрута полета по кругу) составляла:	\N	\N
274	Определение и выдерживание высоты (эшелон полета производится:	\N	\N
275	Перевод шкалы давления барометрического высотомера с давления на аэродроме на стандартное давление производится:	\N	\N
276	Преимущество при визуальном заходе на посадку двух однотипным ВС	\N	\N
277	При полёте на пересекающихся курсах на одной высоте, командир ВС:	\N	\N
278	При полете на предпосадочной прямой командир воздушного судна обязан прекратить снижение и уйти на второй круг (выполнить процедуру прерванного захода на посадку), если:	\N	\N
279	Аэронавигационные и проблесковые огни должны быть включены:	\N	\N
432	Истинная воздушная скорость это:	\N	\N
280	В каких случаях КВС имеет право принять решение на выполнение посадки в условиях, в которых он не подготовлен:	\N	\N
281	Действия КВС при потере ориентировки	\N	\N
282	Пользователи воздушного пространства	\N	\N
283	Виды авиации	\N	\N
284	Гражданская авиация:	\N	\N
285	Цель государственного надзора в области ГА:	\N	\N
286	Воздушное судно это:	\N	\N
287	Легкое воздушное судно:	\N	\N
288	Гражданские воздушные суда допускаются к эксплуатации при наличии:	\N	\N
289	Сертификат лётной годности выдается на основании:	\N	\N
290	Аэродром это:	\N	\N
291	Посадочная площадка это:	\N	\N
292	Командир воздушного судна -	\N	\N
293	Командир воздушного судна имеет право:	\N	\N
294	К полету допускается воздушное судно	\N	\N
295	Судовые документы это:	\N	\N
296	Авиационные работы -	\N	\N
297	Самолёт -	\N	\N
298	Планер самолёта состоит из	\N	\N
299	Компоновочные схемы делятся по:	\N	\N
300	Компоновка по числу крыльев:	\N	\N
301	Силовой набор фюзеляжа состоит из:	\N	\N
302	По схеме силового набора фюзеляж может быть:	\N	\N
303	Зачем необходимо сливать отстой топлива из баков	\N	\N
304	Шимми это:	\N	\N
305	Бафтинг это:	\N	\N
306	Флаттер это:	\N	\N
307	В настоящее время в авиации используются следующие двигатели:	\N	\N
308	Хвостовое оперение предназначено для:	\N	\N
309	В каких случаях балансируется воздушный винт?	\N	\N
310	Допускается ли выполнение полёта с незакрытыми дверьми, люками?	\N	\N
311	Обогрев приёмника воздушного давления нужен для предотвращения:	\N	\N
312	Будет ли барометрический высотомер показывать высоту полёта при закупорке магистрали полного давления	\N	\N
313	Газовый состав воздуха представлен:	\N	\N
314	Строение атмосферы начиная с нижних слоев:	\N	\N
315	Нижний слой атмосферы называется?	\N	\N
316	Параметры стандартной атмосферы на среднем уровне моря:	\N	\N
317	До какой высоты в среднем распространена тропосфера?	\N	\N
318	Чем по сути является атмосферное давление?	\N	\N
319	Что такое барическая ступень?	\N	\N
320	Что такое дальность видимости?	\N	\N
321	Что такое влажность воздуха?	\N	\N
322	Признаком насыщения воздуха влагой является?	\N	\N
323	Что такое конденсация водяного пара в воздухе?	\N	\N
324	Что такое абсолютная влажность воздуха?	\N	\N
325	Что такое относительная влажность воздуха?	\N	\N
326	Насыщенность воздуха влагой с увеличением температуры:	\N	\N
327	Что такое температурная инверсия?	\N	\N
328	Какие типы температурных инверсий различают?	\N	\N
329	Образованию каких явлений способствуют температурные инверсии?	\N	\N
330	Какие типы полетной видимости различают?	\N	\N
331	Что такое ветер?	\N	\N
332	Направление метеорологического ветра:	\N	\N
333	Причина возникновения горизонтальных движений воздуха?	\N	\N
334	Причина возникновения горизонтальных движений воздуха?	\N	\N
335	Барический градиент это?	\N	\N
336	Какое направление имеет ветер относительно изобар в северном полушарии вне влияния поверхности?	\N	\N
337	Что такое градиентный ветер?	\N	\N
338	Как влияет сила Кориолиса на движение воздуха в северном полушарии?	\N	\N
339	Как направлен ветер в пограничном слое?	\N	\N
340	Какие силы влияют на ветер?	\N	\N
341	Стандартное атмосферное давление на уровне моря?	\N	\N
342	Три основных типа облаков:	\N	\N
343	Что такое точка росы?	\N	\N
344	Что такое облака?	\N	\N
345	Кучевые облака это...	\N	\N
346	Какие виды туманов различают?	\N	\N
347	Что такое туман?	\N	\N
348	Что такое атмосферные осадки?	\N	\N
349	Что такое воздушная масса?	\N	\N
350	Какие барические системы различают?	\N	\N
351	Что такое циклон?	\N	\N
352	Как обозначается циклон на картах погоды?	\N	\N
353	Что такое антициклон?	\N	\N
354	Как обозначается антициклон на картах погоды?	\N	\N
355	Что такое ложбина?	\N	\N
356	Что такое гребень?	\N	\N
359	Какие типы атмосферных фронтов различают?	\N	\N
360	что такое атмосферный фронт?	\N	\N
361	Что такое атмосферный фронт?	\N	\N
362	Что такое термическая конвекция?	\N	\N
363	Что является основной причиной возникновения атмосферных фронтов?	\N	\N
364	Что такое главный фронт?	\N	\N
365	Что такое теплый фронт?	\N	\N
366	Что такое холодный фронт?	\N	\N
367	Что такое фронт окклюзии?	\N	\N
368	Что такое стационарный фронт?	\N	\N
369	Что такое стационарный фронт?	\N	\N
370	Основная облачная система теплого фронта?	\N	\N
371	Полет навстречу теплому фронту характерен?	\N	\N
372	Что такое холодный фронт 1-го рода?	\N	\N
373	Какие виды синоптических карт различают?	\N	\N
374	Какие явления ухудшают полетную видимость?	\N	\N
375	Что такое обледенение?	\N	\N
376	Слабое обледенение характеризуется?	\N	\N
377	Сильное обледенение характеризуется?	\N	\N
378	При каких температурах наружного воздуха наиболее вероятно обледенение?	\N	\N
379	Какие виды отлагающегося льда различают?	\N	\N
380	Что такое горизонтальный сдвиг ветра?	\N	\N
381	Что такое микропорыв?	\N	\N
382	Что такое METAR?	\N	\N
383	Что такое TAF?	\N	\N
384	Что такое SIGMET?	\N	\N
385	Что такое GAMET?	\N	\N
386	Что значит, если карта имеет масштаб 1/200000?	\N	\N
387	Географической широтой называется ...	\N	\N
388	Географической долготой называется ...	\N	\N
389	Какую действительную форму Земли используют в целях воздушной навигации?	\N	\N
390	Географическими полюсами Земли называются...	\N	\N
391	Географическими или истинным меридианом называется...	\N	\N
392	Меридианом места называется...	\N	\N
393	через заданную точку на земной поверхности можно провести...	\N	\N
394	Параллелью места называется...	\N	\N
395	Гражданские сумерки заканчиваются вечером...	\N	\N
396	Гражданские сумерки начинаются утром...	\N	\N
397	Курсом вертолета называется...	\N	\N
398	Магнитным курсом вертолета называется...	\N	\N
399	Магнитным склонением называется...	\N	\N
400	Как называется угол, заключенный между магнитным и компасным меридианами?	\N	\N
401	Как называется угол, заключенный между северным направлением меридиана, проходящего через данную точку, и направлением на наблюдаемый ориентир?	\N	\N
402	Абсолютной высотой точки местности называется...	\N	\N
403	Истиной высотой называется...	\N	\N
404	Магнитное склонение отсчитывается от...	\N	\N
405	Абсолютной высотой называется...	\N	\N
406	Высота эшелона отсчитывается от условного уровня...	\N	\N
407	Предельно малые высоты это...	\N	\N
408	Малые высоты это...	\N	\N
409	Относительная высота отсчитывается от...	\N	\N
410	Истинной воздушной скоростью называется скорость?	\N	\N
411	Путевой скоростью называется скорость...	\N	\N
412	Навигационный треугольник скоростей образован векторами:	\N	\N
413	Скорость перемещения вертолета относительно воздушной среды называется...	\N	\N
414	При сличении карты с местностью, используют в первую очередь:	\N	\N
416	Расчет полета по истинной воздушной скорости без учета ветра называется...	\N	\N
417	Термин, означающий вертикальное, продольное или боковое рассредоточение ВС в воздушном пространстве, обеспечивающее безопасность воздушного движения называется...	\N	\N
418	При передаче сообщений о времени используется ...	\N	\N
419	Проверка показаний бортовых часов в полете производится ...	\N	\N
420	При проверках время указывается с точностью ...	\N	\N
421	На какой режим обязан перейти экипаж, при потере ориентировки?	\N	\N
422	При потере ориентировки экипаж обязан:	\N	\N
423	Воздушная навигация - это	\N	\N
424	Траектория полета	\N	\N
425	Линия пути	\N	\N
426	Местоположение самолета	\N	\N
427	Навигационные элементы полета	\N	\N
428	Высота полета	\N	\N
429	Относительная высота …	\N	\N
430	Абсолютная высота	\N	\N
431	Эшелон полета …	\N	\N
433	Приборная скорость это:	\N	\N
434	Курс ВС это угол:	\N	\N
435	Угловые поправки отсчитываются от:	\N	\N
436	Скорость ветра V	\N	\N
437	Направление ветра д	\N	\N
438	Путевая скорость W:	\N	\N
439	Угол сноса б это:	\N	\N
440	Безопасная высота полета	\N	\N
441	Форма земли представлена в виде:	\N	\N
442	Геодезическая долгота это:	\N	\N
443	Полная аэродинамическая сила - это:	\N	\N
444	Подъёмной силой Y называется:	\N	\N
445	Силой лобового сопротивления Q называется:	\N	\N
446	Аэродинамическое качество самолёта это:	\N	\N
447	Поляра самолёта это:	\N	\N
448	Средней аэродинамической хордой крыла (САХ) называется:	\N	\N
449	Аэродинамическая сила самолета создается крылом и приложена:	\N	\N
450	Для чего необходима механизация крыла:	\N	\N
451	Сколько режимов работы имеет воздушный винт:	\N	\N
452	Установившимся горизонтальным полетом называется:	\N	\N
453	Потребной тягой для горизонтального полета называется:	\N	\N
454	Располагаемой тягой принято называть:	\N	\N
455	Взлёт самолёта - это:	\N	\N
456	С уменьшением атмосферного давления воздуха скорость отрыва и длина разбега:	\N	\N
457	Влияет ли угол наклона взлетно-посадочной полосы на скорость отрыва самолёта:	\N	\N
458	С ростом температуры воздуха посадочная скорость:	\N	\N
459	Что является основой штопора самолёта?	\N	\N
460	Сваливание самолета - это:	\N	\N
461	Кривые Н.Е. Жуковского это:	\N	\N
462	Центровкой самолета называется:	\N	\N
463	Продольная статическая устойчивость самолета определяется:	\N	\N
464	Центровка является важной характеристикой самолета, связанной с:	\N	\N
465	Увеличение массы воздушного судна:	\N	\N
466	Размещение груза на ВС позади центра тяжести:	\N	\N
467	Исходя из каких условий необходимо ограничить наиболее переднее положение центра тяжести:	\N	\N
468	Исходя из каких условий необходимо ограничить наиболее заднее положение центра тяжести:	\N	\N
469	Воздушное пространство РФ делится на:	\N	\N
470	Структура воздушного пространства включает в себя:	\N	\N
471	Воздушное пространство классифицируется следующим образом:	\N	\N
472	В классе С разрешаются полёты:	\N	\N
473	В классе G разрешаются полёты:	\N	\N
474	Ширина воздушной трассы устанавливается:	\N	\N
475	В полосах воздушных подходов запрещается размещать	\N	\N
476	Минимальные интервалы вертикального эшелонирования при полетах воздушных судов по правилам полетов по приборам:	\N	\N
477	Минимальный интервал между эшелоном перехода и высотой перехода должен быть:	\N	\N
478	Разрешение на использование воздушного пространства в классах А и С не требуется в случае:	\N	\N
479	Разрешительный порядок использования воздушного пространства устанавливается:	\N	\N
480	Цель установления временного и местного режимов:	\N	\N
481	Временный режим устанавливается:	\N	\N
482	Кратковременные ограничения устанавливаются на срок:	\N	\N
483	Контроль за соблюдением требований ФПИВП осуществляется:	\N	\N
484	Контроль за использованием воздушного пространства РФ в части выявления воздушных судов - нарушителей порядка использования воздушного пространства и воздушных судов - нарушителей правил пересечения государственной границы РФ осуществляется	\N	\N
485	Если международным договором Российской Федерации установлены иные правила, чем те, которые предусмотрены настоящим Кодексом:	\N	\N
486	Государственные приоритеты в использовании воздушного пространства по степени важности:	\N	\N
487	Использование воздушного пространства или отдельных его районов может быть запрещено или ограничено в порядке:	\N	\N
488	Авиация РФ подразделяется на:	\N	\N
489	Авиация, используемая в целях обеспечения потребностей граждан и экономики, относится:	\N	\N
490	Легкое воздушное судно - воздушное судно, максимальный взлетный вес которого составляет:	\N	\N
491	Воздушное судно, зарегистрированное или учтенное в установленном порядке в Российской Федерации, приобретает:	\N	\N
492	Сертификат летной годности (удостоверение о годности к полетам) выдается на основании:	\N	\N
493	Ограничение права пользования гражданскими воздушными судами (привлечение к воздушным перевозкам для государственных нужд, временное изъятие гражданских воздушных судов и иные ограничения) допускается:	\N	\N
494	Подготовка пилотов легких гражданских воздушных судов и пилотов сверхлегких гражданских воздушных судов авиации общего назначения может осуществляться:	\N	\N
495	Командиром воздушного судна является:	\N	\N
496	Полет воздушного судна над населенными пунктами:	\N	\N
497	Международный полет воздушного судна это:	\N	\N
498	К обеспечению и проведению поисковых и аварийно-спасательных работ могут привлекаться:	\N	\N
499	Обладатель свидетельства частного пилота:	\N	\N
500	Для выполнения предусмотренных настоящими Правилами функций члена экипажа воздушного судна, зарегистрированного в Государственном реестре гражданских воздушных судов Российской Федерации, к свидетельству, выданному другим государством - членом ИКАО, необходимо иметь:	\N	\N
501	КВС разрешается выбирать для взлета и посадки на вертолете площадку, о которой отсутствует аэронавигационная информация, в случае, если:	\N	\N
502	Перед полетом по ПВП количество топлива и масла на борту должно позволять:	\N	\N
503	Воздушное судно эксплуатируется в соответствии с его эксплуатационной документацией в пределах эксплуатационных ограничений:	\N	\N
504	Перед полетом экипаж удостоверяется в том, что на борту вертолета, выполняющего полеты по ПВП днем, имеются в работоспособном состоянии:	\N	\N
505	Полет по ПВП на истинных высотах менее 300 м выполняется	\N	\N
506	Полет по ПВП может осуществляться над облаками, если:	\N	\N
507	За исключением случаев, когда это необходимо при осуществлении взлета или посадки, запрещается выполнять полет воздушного судна по ПВП днем:	\N	\N
508	За исключением случаев, когда это необходимо при осуществлении взлета или посадки, запрещается выполнять полет воздушного судна по ПВП ночью:	\N	\N
509	Каким видом топлива допускается заправка вертолетов при вращающихся винтах, если это не противоречит РЛЭ.	\N	\N
510	Воздушное пространство над территорией Российской Федерации, а также за ее пределами, где ответственность за организацию воздушного движения возложена на Российскую Федерацию, делится на:	\N	\N
511	Воздушное пространство над территорией Российской Федерации, а также за ее пределами, где ответственность за организацию воздушного движения возложена на Российскую Федерацию, классифицируется следующим образом:	\N	\N
512	Местные воздушные линии открываются для полетов на высоте:	\N	\N
513	для воздушных судов, выполняющих полеты по правилам визуального полета В районе контролируемого аэродрома, ниже эшелона перехода:	\N	\N
514	порядок использования воздушного пространства является:	\N	\N
515	Разрешительный порядок использования воздушного пространства в воздушном пространстве класса G устанавливается:	\N	\N
516	Под уведомительным порядком использования воздушного пространства понимается:	\N	\N
517	Уведомительный порядок использования воздушного пространства устанавливается:	\N	\N
518	Пользователи воздушного пространства, осуществляющие полеты в воздушном пространстве класса G:	\N	\N
519	Временный режим устанавливается главным центром Единой системы для обеспечения следующих видов деятельности:	\N	\N
520	Местный режим устанавливается зональным центром Единой системы в нижнем воздушном пространстве для обеспечения следующих видов деятельности:	\N	\N
521	Как правильно заполняется поле 15 ФПЛ при подаче заявки на использование ВП РФ в пространстве С (полет со скоростью 180 км/ч на высоте 250 м):	\N	\N
522	Какое обозначение в поле 18 ФПЛ используется для название и местоположение аэродрома вылета, если в поле 13 вставлено ZZZZ:	\N	\N
523	какое обозначение в поле 18 ФПЛ используется для название и местоположение аэродрома назначения, если в поле 16 вставлено ZZZZ:	\N	\N
524	какое обозначение в поле 18 ФПЛ используется для обозначения даты вылета:	\N	\N
525	как заполняется окно в поле 18, имеющее обозначение SNS(СТС) при подаче ФПЛ, если воздушное судно выполняет полет в воздушном пространстве класса G:	\N	\N
526	какая информация заносится в окно обозначенное как ЕЕТ(ЕЕТ) в поле 18 ФПЛ при подаче заявки на использование ВП РФ в пространстве С:	\N	\N
527	какая информация заносится в окно обозначенное как ALTN(АЛТН) в поле 18 ФПЛ:	\N	\N
528	Как обозначается тип полета гражданской авиации общего назначения в поле 8 ФПЛ:	\N	\N
529	сроки подачи сообщения о представленном плане внутреннего полета (ФПЛ) в пределах одной зоны ЕС ОрВД:	\N	\N
530	сроки подачи сообщения о представленном плане внутреннего полета (ФПЛ) в двух и боле зонах ЕС ОрВД:	\N	\N
531	сроки подачи сообщения о представленном плане внутреннего полета (ФПЛ) в пространстве класса G:	\N	\N
532	Зональная навигация - это:	\N	\N
533	Установленное для континентального воздушного пространства значение RNP4 предполагает, что общая навигационная погрешность в горизонтальной плоскости не превышает значения 4 NM:	\N	\N
534	В процессе выполнения полета экипаж информирует органы УВД/АТС, если ему необходимо выдерживать скорость, которая отличается от указанной в плане полета более, чем на:	\N	\N
535	Расчетное время прибытия ETA (Estimated Time of Arrival) означает:	\N	\N
536	В некоторых регионах мирового воздушного пространства существует требование, что при полете по маршруту воздушные суда выдерживают заявленные в плане полета и согласованные с органом УВД/АТС:	\N	\N
537	Минимальная высота полета по маршруту МЕА выражается в следующих единицах:	\N	\N
538	На картах Minimum Radar Vectoring Chart (MRC) значение высоты, указанное в скобках, приводится на случай:	\N	\N
539	Известно, что Minimum Sector Altitude (MSA) предусматривает запас высоты над препятствиям не менее 300м (984 ft), a GRID MORA (MGA) обеспечивает запас 1000 ft (при высоте рельефа до 6000 ft) и 2000 ft (при высоте рельефа более 6000 ft). Какое утверждение можно считать верным:	\N	\N
540	При расчете Minimum Terrain Clearance Altitude (МТСА) учет приема радиосигналов навигационных средств NAV AID производится:	\N	\N
541	При расчете Minimum Terrain Clearance Altitude (МТСА) учет изменения рельефа местности производится изменением запаса высоты пролета препятствия с 1000 ft на 2000 ft для порогового значения высоты препятствия:	\N	\N
542	На картах Terminal Approach Charts (AFC, STAR, IAC, SID) изображаются гражданские аэродромы с размерами ВПП не менее:	\N	\N
543	При составлении рабочего плана полета OFP для расчета необходимого количества топлива учитывается общее время руления:	\N	\N
544	Срок действия рабочего плана полета OFP отсчитывается от:	\N	\N
545	Система AIRAC (Aeronautical Information Regulation And Control) предназначена для:	\N	\N
546	Период срока AIRAC составляет:	\N	\N
547	При подаче плана полета в п. 13 Аэродром вылета и п. 16 Аэродром назначения используются сокращения:	\N	\N
548	Начало отсчета первого срока AIRAC и последующие изменения:	\N	\N
549	При полете в зоне RVSM контроль показаний высотомеров производится:	\N	\N
550	Воздушные суда, не обладающие статусом RVSM, не могут планировать полет в диапазоне эшелонов полета FL:	\N	\N
551	Перед входом в воздушное пространство RVSM расхождение показаний основных высотомеров не должно превышать:	\N	\N
552	Для сохранения воздушным судном статуса допущенного к RVSM отклонения высоты выдерживания эшелона от заданного эшелона в режиме стабилизации высоты не должны превышать:	\N	\N
553	При полетах по одному из организованных треков NAT MNPS полностью (от точки входа в океанические районы полетной информации до точки выхода), в п. 18 плана полета следует указывать суммированное истекшее полетное время:	\N	\N
554	При полете полностью или частично вне системы организованных треков NAT MNPS в п.18 плана полетов указывается суммированное расчетное истекшее время:	\N	\N
555	При полетах в воздушном пространстве NAT MNPS необходимо выдерживать:	\N	\N
556	При полетах в воздушном пространстве MNPS разрешается использовать на соответственно оборудованных воздушных судах правило смешения от оси маршрута (трека). Смещение разрешается выполнять:	\N	\N
557	В воздушном пространстве NAT MNPS экипаж должен передавать метеодонесения без предварительного указания диспетчера:	\N	\N
558	Период действия дневной системы организованных треков OTS NAT MNPS - 11:30 UTC-18:00 UTC, ночной системы OTS - 01:00 UTC - 08:00 UTC. При этом учитывается время:	\N	\N
559	При выполнении полета со смещением в воздушном пространстве NAT MNPS и пересечении в океаническом пространстве района с радиолокационным обслуживанием:	\N	\N
560	При выполнении полетов в системе фиксированных полярных треков Северной Атлантики (PTS) и/или в воздушном пространстве Арктического района США и Канады в поле 10 плана полета необходимо вставить соответствующий символ означающий, что:	\N	\N
561	На сколько классов подразделяются авиационные события в ГА РФ?	\N	\N
562	Случаи гибели кого-либо из лиц, находившихся на борту, в процессе их аварийной эвакуации из воздушного судна относятся к:	\N	\N
563	В каком документе предусмотрены варианты дальнейших действий экипажа в случая наступления авиационного события:	\N	\N
564	На прогностических картах особых явлений погоды символ CB обозначает:	\N	\N
565	На прогностических картах особых явлений погоды символ ISOL обозначает:	\N	\N
566	На прогностических картах особых явлений погоды символ OCNL обозначает:	\N	\N
567	На прогностических картах особых явлений погоды символ FRQ обозначает:	\N	\N
568	На прогностических картах особых явлений погоды символ EMBD СВ обозначает:	\N	\N
569	Укажите тенденцию изменения видимости на ВПП: METAR URSS 070130Z 31003G07MPS 190V050 1300 R06/1000VP1500D TSRA BKN005 OVC027CB 18/17 Q1012 BECMG 3000 RMK QBB160 QFE758 06CLRD70=	\N	\N
570	Что означает термин TAF AMD:	\N	\N
571	Сокращение OVC означает количество облаков:	\N	\N
572	Какое значение видимости прогнозируется к 10.00: TAF URRR 070140Z 070312 VRB02MPS 2000 BR SCT007 SCT020CB TEMPO 0306 0400 FG BKN002 BKN020CB PROB40 TEMPO 0312 -TSRA FM0900 26005MPS 9999 BKN010 BKN020CB	\N	\N
573	Какие явления прогнозируются в данном сообщении SIGMET: WSRS31 RUSM 250200 UWWW SIGMET 1 VALID 250300/250700 UWWW UWWW SAMARA FIR EMBD TS FCST E OF E50 TOP FL230 MOV E 40 KMH INTSF=	\N	\N
574	Какая верхняя граница облачности прогнозируется в сообщении SIGMET: WSRS31 RUSM 250200 UWWW SIGMET 1 VALID 250300/250700 UWWW UWWW SAMARA FIR EMBD TS FCST E OF E50 TOP FL230 MOV E 40 KMH INTSF=	\N	\N
575	Охарактеризуйте тенденцию интенсивности грозы: WSRS31 RUSM 250200 UWWW SIGMET 1 VALID 250300/250700 UWWW - UWWW SAMARA FIR EMBD TS FCST E OF E50 TOP FL230 MOV E 40 KMH INTSF=	\N	\N
576	В каком направлении будет смещаться гроза: WSRS31 RUSM 250200 UWWW SIGMET 1 VALID 250300/250700 UWWW UWWW SAMARA FIR EMBD TS FCST E OF E50 TOP FL230 MOV E 40 KMH INTSF=	\N	\N
577	Какие метеорологические условия характерны для теплого фронта:	\N	\N
578	Кучево-дождевая облачность на теплом фронте образуется:	\N	\N
579	Зона струйного течения связанная с теплым фронтом находится:	\N	\N
580	Холодные фронт 1-го и 2-го рода различают в зависимости от:	\N	\N
581	Скорость перемещения холодного фронта 1-го рода:	\N	\N
582	Система облачности холодного фронта 1-го рода состоит из:	\N	\N
583	Скорость перемещения холодного фронта второго рода составляет:	\N	\N
584	В нижней (передней от земли до 1,5 - 2км) части фронтальной поверхности холодного фронта второго рода происходит интенсивное вытеснение:	\N	\N
585	Ширина зоны ливневых осадков холодного фронта второго рода составляет:	\N	\N
586	Зона струйного течения холодного фронта второго рода располагается:	\N	\N
587	Фронты окклюзии подразделяются на:	\N	\N
588	Теплый фронт окклюзии (по типу теплого фронта) образуется когда:	\N	\N
589	Вторичные фронты являются разделами между:	\N	\N
590	Вторичные фронты образуются в:	\N	\N
591	Тропический фронт это линия раздела воздушных масс:	\N	\N
592	В зоне тропического фронта чаще всего наблюдаются:	\N	\N
593	Скорость ветра в тропических циклонах может достигать:	\N	\N
594	Скорость перемещения тропических циклонов может достигать:	\N	\N
595	В тропических циклонах наиболее опасная зона является:	\N	\N
596	Ширина зоны глаза бури тропического циклона может достигать:	\N	\N
597	Внутримассовые грозы чаще всего образуются:	\N	\N
598	Верхний край грозовой облачности в умеренных широтах может достигать:	\N	\N
599	Шквал возникает в:	\N	\N
600	Наиболее вероятные значения температуры для возникновения электризации в слое облаков от:	\N	\N
601	К опасным для полетов метеорологическим явлениям в районе аэродрома относится вертикальный сдвиг ветра (включая нисходящие и восходящие потоки) равный:	\N	\N
602	К наиболее характерным синоптическим ситуациям и условиям возникновения сильного сдвига ветра относятся:	\N	\N
603	Чаще всего сильные сдвиги ветра возникают в зонах конвективных облаков в:	\N	\N
604	Турбулентность ясного неба (ТЯН, CAT) может возникнуть при наличии:	\N	\N
605	Тропопауза является переходным(задерживающим) слоем между тропосферой и стратосферой и может иметь толщину:	\N	\N
606	Высота тропопаузы в умеренных широтах в среднем изменяется в пределах:	\N	\N
607	Высота тропопаузы в высоких широтах в среднем изменяется в пределах:	\N	\N
608	Высота тропопаузы над экватором может находиться в пределах высот:	\N	\N
609	Струйные течения - сравнительно узкие зоны сильных ветров наблюдаются в:	\N	\N
610	Границей струйного течения является скорость ветра достигшая:	\N	\N
611	Струйные течения имеют в среднем размеры	\N	\N
612	Туманы ухудшают видимость до значений:	\N	\N
613	TAF EGGF 0715/0724 06007G12MPS BECMG 0719/0721 11005MPS Какое значение направления и скорости ветра следует учитывать в 20 часов?	\N	\N
614	Условный код 99, используемый для обозначения ВПП в 8-ми цифровой группе, указывает на:	\N	\N
615	Кодовое слово BECMG означает:	\N	\N
616	Кодовое слово NOSIG означает:	\N	\N
617	TAF 0615 0500 TEMPO 0400 BECMG 1012 1200. Какое значение видимости необходимо учитывать в период 10-12 часов?	\N	\N
618	Периодическое ТО ВС осуществляют методами:	\N	\N
619	Кто принимает решение о применении метода по организации ТО ВС?	\N	\N
620	Принятый метод организации ТО ВС должен обеспечивать:	\N	\N
621	Что составляет основы применения метода организации работ по ТО ВС?	\N	\N
622	Как разновидности методов подходов к организации ТО ВС могут применятся:	\N	\N
623	При закреплённом методе первичное звено обслуживает:	\N	\N
624	Закреплённый метод характеризуется тем, что:	\N	\N
625	Закреплённый метод, как правило, применяется при ТО ВС:	\N	\N
626	При закреплённом методе обслуживания ВС выполняют:	\N	\N
628	Работой специализированных бригад по ТО ВС руководят:	\N	\N
629	Сущность бригадно-поточного метода обслуживания ВС состоит в том, что производственное звено (бригада, смена) обслуживает:	\N	\N
630	При бригадном методе ТО ВС осуществляют:	\N	\N
631	Наибольшее распространение бригадный метод ТО ВС получил при:	\N	\N
632	Бригадный метод предусматривает:	\N	\N
633	Работой специализированных бригад по ТО ВС руководят:	\N	\N
634	При зонном методе ТО ВС за исполнителем работы закрепляют:	\N	\N
635	Число бригад и специалистов при зонном методе ТО ВС зависят от:	\N	\N
636	Зонный метод ТО ВС применяется для:	\N	\N
637	Должен ли ИТП бригады проходить специальную подготовку при зонном методе ТО ВС?	\N	\N
638	Нужно ли оформлять допуск к работе на каждого исполнителя при зонном методе ТО ВС?	\N	\N
639	При зонном методе ТО ВС исполнитель работ выполняет работы по ТО:	\N	\N
640	Закрепляет ли ВС за бригадой при зонном методе ТО ВС?	\N	\N
641	При одноэтапном методе ТО весь объём работ заданной формы ТО с момента их начала и до полного завершения выполняется до очередного полёта:	\N	\N
642	Сущность поэтапного метода ТО ВС состоит в том, что:	\N	\N
643	Применяются следующие разновидности поэтапного ТО ВС только:	\N	\N
644	Разработка документации на поэтапное ТО ВС относится к компетенции:	\N	\N
645	Раздела документации на поэтапное ТО ВС распределённой трудоёмкости подлежат согласованию:	\N	\N
646	Требования предъявляемые к разработке документации на поэтапное ТО ВС должны удовлетворять:	\N	\N
647	Поэтапный метод ТО ВС в пределах допусков по наработке применяют для:	\N	\N
648	Поэтапное ТО ВС считается законченным когда:	\N	\N
649	Данные о результатах выполнения ТО ВС этапа, техник по учёту в ПДО АТБ заносит:	\N	\N
650	Отдельные работы, этапы и формы ПТО выполняемые цехом ОТО, контролируют:	\N	\N
651	Особенность поэтапного метода ТО ВС состоит в том, что:	\N	\N
652	Трудоёмкость каждого этапа ТО при поэтапном методе ТО состоит:	\N	\N
653	При поэтапном методе обслуживания ВС пооперационные ведомости составляют в АТБ:	\N	\N
654	В каких документах фиксируются результаты при ТО ВС с фиксированными этапами?	\N	\N
655	Относится ли метод ТО ВС с нерегламентированными этапами к блочно-поэтапному ТО?	\N	\N
656	Блочно-поэтапный метод обслуживания обеспечивает:	\N	\N
657	Возможно ли использовать компьютерные технологии при блочно-поэтапном методе обслуживании?	\N	\N
658	Применение поэтапного метода для выполнения периодических форм обслуживания позволило:	\N	\N
659	Что является целью метода ТО авиатехники по состоянию?	\N	\N
660	Сущность методики ТО ВС по состоянию состоит в том, что:	\N	\N
661	Методика ТО по состоянию предусматривает:	\N	\N
662	Подготовка авиапредприятий к обслуживанию АТ по состоянию производится на основании:	\N	\N
663	АТБ считается подготовленной к обслуживанию АТ по состоянию если:	\N	\N
664	Авиационная техника признаётся пригодной к ТОиР по состоянию если она обладает:	\N	\N
665	Техническое обслуживание с контролем параметров применяют для изделий:	\N	\N
666	Техническое обслуживание с контролем уровня надёжности применяют для изделий:	\N	\N
667	При методике ТО ВС с контролем параметров функциональных систем контроль должен быть:	\N	\N
668	В чём отличие методики ТО по состоянию, от методики ТО по наработке:	\N	\N
669	К характерным особенностям методики ТО ВС с контролем уровня надёжности можно отнести следующее:	\N	\N
670	Можно ли осуществлять контроль уровня надёжности однотипных изделий с помощью статистических методов:	\N	\N
671	Статистических анализ надёжности производится на основе:	\N	\N
672	Что является источником информации при ТО ВС с контролем уровня надёжности?	\N	\N
673	Являются ли штатные приборы встроенного контроля источником информации при ТО ВС по состоянию?	\N	\N
674	Обслуживание по техническому состоянию с контролем параметров агрегатов предусматривает:	\N	\N
675	Решение о продолжении эксплуатации до момента следующей проверки или замены агрегата при ТО ВС по состоянию применяются:	\N	\N
676	В решении задач разработки и внедрения методов ТО ВС по состоянию особая роль принадлежит:	\N	\N
677	Экономический эффект внедрения методов обслуживания АТ по техническому состоянию получают за счёт:	\N	\N
678	Разрешается ли заправлять ВС ГСМ при наличии пассажиров на борту?	\N	\N
679	На каком расстоянии от горловины бака необходимо коснуться раздаточным кранов обшивки судна, при открытой заправке ВС топливом?	\N	\N
680	По какому документу проверяют пригодность ГСМ к заправке ВС?	\N	\N
681	В каких случаях запрещена закрытая заправка ВС топливом?	\N	\N
682	Каким прибором проверяют отстой топлива на отсутствие воды и примесей?	\N	\N
683	Разрешается ли применять ёмкости, в которых находится спецжидкости (газы) окрашенные в красный цвет и без маркировки?	\N	\N
684	Какой документ предоставляется на средство заправки ВС спецжидкостями, водой, зарядки газами?	\N	\N
685	Какими средствами осуществляется кондиционирование воздуха в пассажирских салонах и кабине экипажа на земле?	\N	\N
686	Разрешается ли при подогреве двигателей и системы ВС заправлять ВС и работающие подогреватели топливом?	\N	\N
687	Разрешается ли производить посадку пассажиров при подогреве двигателей и систем ВС?	\N	\N
688	На каком расстоянии от ближайших точек ВС располагают тепловые обдувочные машины?	\N	\N
689	Сколько раз можно использовать контровочную проволоку?	\N	\N
690	Разрешается ли допускать к погрузке в ВС груза в неисправной транспортной упаковке?	\N	\N
691	Разрешается ли производить запуск двигателей на МС, перроне и предварительном смотре?	\N	\N
692	Разрешается ли производить запуск двигателей без СПУ(радиосвязи)?	\N	\N
693	Разрешается ли при запуске и опробовании двигателей запускающему оставлять рабочее место?	\N	\N
694	Кто дает разрешение на буксировку ВС по РД и ВПП?	\N	\N
695	Сколько существует способов буксировки ВС?	\N	\N
696	Разрешается ли во время буксировки ВС находиться людям на поверхностях ВС?	\N	\N
697	Разрешается ли при мойке ВС применять для удаления загрязнений металлические щетки?	\N	\N
698	Используется ли буксировочное водило при буксировке ВС хвостом вперёд?	\N	\N
699	Где хранится бортовой журнал ВС?	\N	\N
700	Разрешается ли устанавливать на буксировочное водило не маркированные срезные болты?	\N	\N
701	Разрешается ли удалять коррозию с тросов систем управления ВС и двигателями ГСМ?	\N	\N
702	Каким образом производится проверка герметичности зарядных клапанов и штуцеров?	\N	\N
703	На основании какого документа организуется движение спецтранспорта и средств механизации на гражданских аэродромах?	\N	\N
704	Разрешается вывешивать ВС на гидроподъёмниках стоящих на колёсах?	\N	\N
705	Какая максимальная скорость движения спецтранспорта в зоне МС ВС?	\N	\N
706	Разрешается ли вытаскивать ВС, застрявший в грунте, за переднюю опору?	\N	\N
707	Разрешается ли производить запуск и опробование двигателей при неисправности систем торможения?	\N	\N
708	К какой группе стопорения разъёмных соединений относится стопорение с помощью сварки?	\N	\N
709	С помощью какого приспособления проверяется система стопорения дверей?	\N	\N
710	Какая смазка применяется в подшипниках колёс шасси?	\N	\N
711	Через какое время после заправки топливом производится слив отстоя?	\N	\N
712	Где производится запуск и опробование авиадвигателей при техническом обслуживании?	\N	\N
713	К какой группе стопорения разъёмных соединений относится стопорение шплинтом?	\N	\N
714	Что указывает на перегрев колёс основной опоры шасси?	\N	\N
715	Какая максимально допустимая разница давления воздуха в авиашинах колёс основной опоры шасси?	\N	\N
716	На какое расстояние от крайней точки самолёта устанавливается топливозаправщик при заправке?	\N	\N
717	С какой целью используется площадка девиации?	\N	\N
718	Какая марка тросов применяется в системе управления самолётом и двигателями?	\N	\N
719	Какой документ оформляется при дефектации систем ВС?	\N	\N
720	В соответствии с каким документом выполняются доработки на ВС?	\N	\N
721	Каким прибором проверяется натяжение тросов системы управления самолетом и двигателями?	\N	\N
722	Разрешается ли применять для протирки органического остекления самолёта растворители (ацетон, бензол и др.)?	\N	\N
723	При какой скорости ветра запрещается вывешивание самолёта на гидроподъёмниках?	\N	\N
724	С какой целью используется швартовочное приспособление при ТО ВС?	\N	\N
725	Допускаются ли потёртости на авиашинах колёс?	\N	\N
726	К какой группе стопорения разъёмных соединений относится стопорение при помощи самоконтрящих гаек?	\N	\N
727	Допускается ли обрыв нитей в пряди тросов систем управлении самолётом и двигателями?	\N	\N
728	Можно ли смешивать при заправке ВС топливо ТС-1 и РТ?	\N	\N
729	Какие способы замера количества топлива применяются на самолёте?	\N	\N
730	Где хранится формуляр ВС?	\N	\N
731	Можно ли использовать не маркированный инструмент при ТО ВС?	\N	\N
732	Какой марки применяют контровочную проволоку?	\N	\N
733	Каким прибором проверяют качество промывки фильтроэлементов?	\N	\N
734	Сколько существует способов проверки давления азота в амортизаторах шасси?	\N	\N
735	Какой прибор используется для измерения глубины царапин?	\N	\N
736	Какого цвета разметка для движения спецавтотранспорта по территории аэродрома?	\N	\N
737	На какой срок выдаётся сертификат технической подготовленности к обслуживанию АТ?	\N	\N
738	На основании какого документа экземпляр ВС допускается к эксплуатации?	\N	\N
739	Куда подаётся заявка на сертификацию экземпляра ВС?	\N	\N
740	На какой срок выдаётся сертификат лётной годности экземпляра ВС?	\N	\N
741	В каком документе указаны требования и процедуры сертификации ВС?	\N	\N
742	Кем приостанавливается действие сертификата лётной годности ВС?	\N	\N
743	Кто организует инспекционный контроль лётной годности экземпляра ВС?	\N	\N
744	Не чаще какого срока проводится плановый инспекционный контроль лётной годности экземпляра ВС?	\N	\N
785	Что является истиной относительно &ldquo;учебного плато "?	\N	\N
745	Что проводится при наличии информации о нарушениях правил по эксплуатации и поддержания лётной годности экземпляра ВС?	\N	\N
746	Что может использоваться для определения степени соответствия экземпляра ВС установленным требованиям?	\N	\N
747	Какой документ определяет положение о порядке допуска к эксплуатации единичных экземпляров воздушных судов (ЕЭВС) авиации общего назначения?	\N	\N
748	При наличии какого документа допускается к эксплуатации единичный экземпляр воздушного судна (ЕЭВС) авиации общего назначения?	\N	\N
749	В течении какого срока действует сертификат лётной годности единичного экземпляра ВС (ЕЭВС)?	\N	\N
750	Кто организует инспекторский контроль лётной годности единичного экземпляра ВС (ЕЭВС)?	\N	\N
751	Не чаще какого срока проводится плановый инспекционный контроль лётной годности единичного экземпляра ВС (ЕЭВС)?	\N	\N
752	Какой документ составляется по результатам инспекционного контроля лётной годности единичного экземпляра ВС (ЕЭВС)?	\N	\N
753	Какое из следующих определений описывает точное восприятие самолета и окружающей среды, которое действует на ВС и пассажиров в течение определенного времени?	\N	\N
754	Ответ организма на набор обстоятельств, которые вызывают в нем физиологические и психологические изменения, заставляя человека адаптироваться к ним, называется	\N	\N
755	Примеры методов, которые могут привлечь внимание студентов	\N	\N
756	Какой мешающий фактор из перечисленных имеет место у студента, который не участвует в процессе обучения и выглядит отвлеченным?	\N	\N
757	Авиационный шум, вибрация или условия освещения относятся к какому из мешающих факторов?	\N	\N
758	Помехи, отвлечение от процесса или деятельности могут быть выражены следующими факторами, которые находятся вне контроля инструктора	\N	\N
759	Что требуется для эффективных коммуникаций?	\N	\N
760	Вероятно, самым значительным препятствием в коммуникациях является:	\N	\N
762	Эффективная коммуникация имеет место тогда и только тогда, когда:	\N	\N
763	Для эффективной коммуникации, инструктор должен:	\N	\N
764	Основной метод демонстрации включает в себя несколько поэтапных шагов:	\N	\N
765	Какой пример положительного подхода при первом полете со студентом, который не имел предыдущего авиационного опыта?	\N	\N
766	Путаница, незаинтересованность и беспокойство со стороны студента может произойти в результате незнания:	\N	\N
767	Для ответа на вопрос студента, очень важно, чтобы инструктор:	\N	\N
768	Критика инструктором возможностей студента должна:	\N	\N
769	Основная забота при разработке плана занятий, это:	\N	\N
770	В отношении хорошо подготовленного занятия, каждое занятие должно содержать:	\N	\N
771	Профессиональные отношения между инструктором и студентом должны базироваться на:	\N	\N
772	Настоящие свойства профессионала это постоянное обучение и:	\N	\N
773	Авиационные инструктора должны быть постоянно наготове, чтобы улучшать услуги, предоставляемые студентам, их эффективность, а также:	\N	\N
774	При оценке инструктором летных навыков студента, инструктор должен:	\N	\N
775	Какое утверждение верное относительно позитивного или негативного подхода технике авиационного обучения?	\N	\N
776	Что может быть наиболее ярким индикатором того, что студент реагирует на стресс ненормально?	\N	\N
777	Если студент проявляет признаки морской болезни при выполнении полета с инструктором, то:	\N	\N
778	Под воздействием стресса, нормальный человек обычно реагирует следующим образом:	\N	\N
779	Инструктор может уменьшать беспокойство студента путем:	\N	\N
780	Какой термин определяет благоприятный взгляд на себя?	\N	\N
781	Преподаватель может помочь студенту справиться со страхами или тревогами:	\N	\N
782	Какая наилучшая стратегия помощи студенту, который испытывает острую усталость от учебного процесса?	\N	\N
783	Должен ли инструктор беспокоиться и корректировать студента, который делает очень мало ошибок?	\N	\N
784	Ухудшение возможностей студента в результате его самоуверенности должно быть скорректировано	\N	\N
786	Инструктор может обнаружить усталость студента, если заметит следующие факторы:	\N	\N
787	Что можно считать &ldquo;инструкцией "?	\N	\N
788	Студенты, которые понимают, что инструктор не подготовлен к занятиям, становятся	\N	\N
789	Какая польза от письменной оценки/критики/обсуждения при работе в группе?	\N	\N
790	Какое из утверждений относительно оценки студента является верным?	\N	\N
791	Какое утверждение относительно инструкторской критики является верным?	\N	\N
792	Когда инструктор критикует студента, это всегда должно быть	\N	\N
793	Какое утверждение относительно инструкторской критики является верным?	\N	\N
794	Разбор полетов - это этап в методике обучения:	\N	\N
795	Наилучший путь подготовки студента к выполнению задачи	\N	\N
796	Что является одним из преимуществ лекции?	\N	\N
797	Что является одним из преимуществ лекции?	\N	\N
798	Преимущество группового обучения:	\N	\N
799	Что является одним из преимуществ лекции?	\N	\N
800	В ходе лекции инструктор должен	\N	\N
801	Наиболее подходящая характеристика группового обучения	\N	\N
802	Какой поток требуется отыскать планеристу, чтобы планер летел без снижения	\N	\N
803	При наличии морского бриза, какая часть дня наиболее предпочтительная для парящего полёта?	\N	\N
804	Какие типы восходящих потоков можно встретить в горной местности?	\N	\N
805	На какие характеристики планера влияет V-образность крыла?	\N	\N
806	В каком случае верхнее расположение стабилизатора у планера является преимуществом?	\N	\N
807	Разрешается ли производить полеты из задней кабины планера?	\N	\N
808	При потере видимости самолёта-буксировщика (например, при попадании аэропоезда в облако) планерист обязан	\N	\N
809	При посадке на площадку высоту следует определять:	\N	\N
810	Средством экстренной остановки на пробеге/прерванном разбеге является	\N	\N
811	Если на больших скоростях ощущается тряска на рулях управления	\N	\N
812	Для чего используется водный балласт на планерах	\N	\N
813	В случае захода на посадку, какой тип ВС имеет преимущество	\N	\N
814	Разрешены ли на планере акробатические полёты?	\N	\N
815	При одновременном отказе буксировочного замка на самолете и планере применяется следующая методика	\N	\N
816	Подход к планерам, стоящим в восходящем потоке должен осуществляться:	\N	\N
817	Действия планериста, который допустил крен и касание земли при разбеге	\N	\N
818	Что следует делать, если планерист на разбеге ушел в пеленг свыше 20 градусов относительно самолёта буксировщика?	\N	\N
819	Что означает сигнал сопровождающего планер, когда права рука поднята вверх и распрямлена в локте?	\N	\N
820	Какой планер имеет преимущество при посадке	\N	\N
821	Каким образом планерист может подать сигнал лётчику-буксировщику при невозможности произвести отцепку?	\N	\N
822	Пилот-буксировщик сообщает пилоту-планеристу о необходимости произвести отцепку?	\N	\N
823	По мере замедления пробега планера с целью сохранения управляемости пилот должен:	\N	\N
824	Высота полета:	\N	\N
825	Относительная высота:	\N	\N
826	Абсолютная высота:	\N	\N
827	Высота эшелона:	\N	\N
828	Истинная воздушная скорость:	\N	\N
829	Скорость по прибору:	\N	\N
830	Курс ВС:	\N	\N
831	Угловые поправки отсчитываются от:	\N	\N
832	Скорость ветра V:	\N	\N
833	Направление ветра д:	\N	\N
834	Путевая скорость W:	\N	\N
835	Угол сноса б:	\N	\N
836	Безопасная высота полета:	\N	\N
837	Форма земли представлена в виде:	\N	\N
838	Какие виды неразрушающего контроля предусматриваются в указаниях?	\N	\N
839	Цель общего визуального контроля является?	\N	\N
840	Специальный контроль предназначен для?	\N	\N
841	Кем определяется объем и периодичность неразрушающего контроля элементов конструкции?	\N	\N
842	Средства неразрушающего контроля элементов выбирается исходя из каких категорий?	\N	\N
843	Какая цель у выборочного разового контроля?	\N	\N
898	Кем составляются планы и графики ремонта АТ?	\N	\N
844	Что позволяет надежное обнаружение повреждения наименьшей величины?	\N	\N
845	Методами акустического неразрушающего контроля являются?	\N	\N
846	Какой важный параметр оценки эффективности того или иного метода?	\N	\N
847	Для каких конструкций можно применять метод неразрушающего контроля?	\N	\N
848	Для обеспечения возможного контроля скрытых элементов предусматривается:	\N	\N
849	Что можно использовать в отдельных случаях для контроля?	\N	\N
850	Какой метод контроля является наиболее удобным в условиях эксплуатации?	\N	\N
851	Как находятся оптимальные режимы контроля?	\N	\N
852	Что должно быть обеспечено для проведений радиографического метода контроля?	\N	\N
853	При излучении рентгеновской пленки основным техническим требованием к месту является?	\N	\N
854	Какая сущность капиллярного метода?	\N	\N
855	Какие волны используются в ультразвуковом методе?	\N	\N
856	Какие методы известны в ультразвуковом методе?	\N	\N
857	Весьма удобен контроль деталей токовихревой метод, имеющий отверстия благодаря чему?	\N	\N
858	Чем обеспечивается уровень безотказности авиационной техники	\N	\N
859	Какая физическая основа у Оптического вида нк?	\N	\N
860	Область применения оптического вида нк ?	\N	\N
861	Какие дефекты можно выявить методом проникающих веществ нк?	\N	\N
862	Принцип работы радиационного метода нк?	\N	\N
863	Особенность применения Акустического метода нк?	\N	\N
864	Фактор, снижающий эффективность Токовихревого метода нк?	\N	\N
865	Что можно использовать при оптическо-визуальном контроле доступных объектов?	\N	\N
866	Какая желаемая температура детали должна быть для проведения Капиллярного контроля?	\N	\N
867	Метрология- это…	\N	\N
868	Физическая величина-это…	\N	\N
869	Измерением называется…	\N	\N
870	Приведите определение истинного значения физической величины.	\N	\N
871	Укажите основные единицы термодинамической температуры и силы света системы СИ.	\N	\N
872	Сколько основных единиц физических величин установлено международной системой СИ?	\N	\N
873	Как называются единицы образующиеся из основных единиц физических величин?	\N	\N
874	Укажите классификацию погрешностей по характеру проявления.	\N	\N
875	Что характеризует допуск на размер детали?	\N	\N
876	Укажите классификацию погрешностей по способу выражения.	\N	\N
877	Как определяется относительная погрешность измерения?	\N	\N
878	При описании электрических и магнитных явлений в СИ за основную единицу применяется…	\N	\N
879	В чем сущность измерения методом сравнения?	\N	\N
880	Какое правило образования производных единиц системы СИ?	\N	\N
881	Какое конструктивное исполнение отсчетного устройства микрометрического инструмента?	\N	\N
882	Приведите определение понятия прямые измерения:	\N	\N
883	Приведите определение понятия приведенная погрешность прибора	\N	\N
884	Укажите производную единицу электрического напряжения системы СИ:	\N	\N
885	Укажите определение понятия действительное значение измеряемой величины:	\N	\N
886	Укажите производную единицу измерения мощности системы СИ.	\N	\N
887	По какому квалитету точности изготовлено отверстие в сопряжении * 44 Н8/e7?	\N	\N
888	Какие дополнительные единицы системы СИ?	\N	\N
889	Какая величина допуска вала * 28 + 0,045 мм?	\N	\N
890	Чему равен номинальный размер в сопряжении * 50 Н8/e9?	\N	\N
891	Укажите определение погрешности измерений.	\N	\N
892	Какая производная единица частоты системы СИ?	\N	\N
893	Качественной характеристикой физической величины является…	\N	\N
894	Какой поверки средств измерений не бывает?	\N	\N
895	При обязательной сертификации продукции один из 10 анализируемых показателей оказался не соответствующим нормативной документации. Может ли быть выдан сертификат?	\N	\N
896	Документ, удостоверяющий соответствие объекта требованиям технических регламентов, положениям стандартов - это…	\N	\N
897	Кем определяется потребность в ремонте АТ?	\N	\N
899	Какой промежуток времени называется сроком ремонта АТ?	\N	\N
900	Кто в типовом случае при подготовке ВС в ремонт обязан при необходимости принять меры по обеспечению транспортировки ВС к производителю ремонта (разборка ВС, его упаковка, крепление на транспортном средстве)?	\N	\N
901	Допускается ли перелёт ВС к месту ремонта если остаток ресурса судна не достаточен для перелёта?	\N	\N
902	Могут ли перевозиться груз и пассажиры при перелёте ВС к месту ремонта?	\N	\N
903	Кем организуются и выполняются предварительные работы по подготовке ВС к запуску в ремонт (слив топлива и масла, консервация двигателей, обработка санузлов и т.п.)?	\N	\N
904	Согласно какого документа осуществляется передача съёмного оборудования и имущества при сдаче ВС в ремонт?	\N	\N
905	Могут ли при капитальном ремонте ВС проводиться работы не предусмотрённые типовой технологией ремонта?	\N	\N
906	Оформлением какого документа закрепляется передача ВС в ремонт?	\N	\N
907	Допускается ли при капитальном ремонте АТ использование оборудования, средств измерения и контроля, изготовленных на ремонтном предприятии?	\N	\N
908	Могут ли для оценки качества ремонта и эффективности технологических процессов в дополнение к испытаниям, предусмотренным технологией ремонта, производиться технологические испытания изделий АТ и их контрольные разборки?	\N	\N
909	Не позднее скольких дней до выхода ВС из ремонта производитель ремонта должен известить заказчика о готовности отремонтированного ВС к сдаче?	\N	\N
910	В каком документе делаются записи о межремонтном, гарантийном ресурсах и сроке службы ВС после капитального ремонта?	\N	\N
911	В каком документе записывается заключение о выполненном ремонте и годности ВС к эксплуатации?	\N	\N
912	В какой документ заносят данные о проверке герметичности параметров ВС после ремонта?	\N	\N
913	В какой документ заносят сведения о массе и центровке ВС после ремонта?	\N	\N
914	В скольких экземплярах оформляется приёмо-сдаточный акт при передаче ВС в ремонт?	\N	\N
915	Какой документ даёт право (является основанием) на перелёт отремонтированного ВС к месту назначения (вместо приостановленного в действии на время ремонта удостоверения годности гражданского ВС к полётам)?	\N	\N
916	Разрешается ли выполнять перелёт отремонтированного ВС на аэродром назначения с пассажирами и грузом?	\N	\N
917	Каким образом производится отправка заказчику отремонтированного ВС доставленного производителю ремонта в контейнере?	\N	\N
918	Вправе ли заказчик ремонта АТ самостоятельно восстанавливать дефектную АТ, находящуюся на гарантии производителя ремонта, с сохранением оснований для предъявления рекламаций производителю ремонта?	\N	\N
919	При какой из приведенных систем ремонта АТ межремонтный ресурс не назначается?	\N	\N
920	При какой системе капитального ремонта летательный аппарат полностью разбирается, диагностируется и ремонтируется без учёта его технического состояния?	\N	\N
921	Какой ремонт АТ относится к плановому?	\N	\N
922	Какой ремонт АТ относится к внеплановому?	\N	\N
923	Какая система ремонта АТ наиболее экономична, технически эффективна и учитывает резервы надёжности конкретного объекта ремонта?	\N	\N
924	Какое из загрязнений, подлежащих удалению при ремонте, обладает высокой адгезией (прочностью сцепления с поверхностью)?	\N	\N
925	На каком явлении основан ультразвуковой метод очистки деталей от загрязнений?	\N	\N
926	Какой метод очистки деталей от загрязнений (при капитальном ремонте) относится к механическим методам?	\N	\N
927	Какой метод очистки деталей от загрязнений (при капитальном ремонте) относится к физико-химическим методам?	\N	\N
928	На каком явлении основана электролитическая очистка?	\N	\N
929	С помощью чего выполняется регулировка натягивания тросов систем управления ВС?	\N	\N
930	Какой дефект появляется на обшивке ВС при наличии остаточной деформации?	\N	\N
931	С какой целью используется нивелир при ремонте АТ?	\N	\N
932	Какое назначение реперных точек на ВС?	\N	\N
933	На какую высоту необходимо поднять ВС на гидроподъемниках при его нивелировке?	\N	\N
934	Какая цель нивелировки при капитальном ремонте?	\N	\N
935	Что такое нивелировка ВС?	\N	\N
936	Что делать с трубопроводом гидросистемы при текущем ремонте, если на нем появилась трещина?	\N	\N
937	Что делать с тягой руля при текущем ремонте ,если на ней обнаружена выработка под направляющими роликами менее предельного допуска?	\N	\N
938	Какой инструмент запрещено использовать при &ldquo;разделывании " трещин перед их заваркой, если она предусмотрена технологией ремонта?	\N	\N
939	Что делать с трубопроводом, имеющим овальность более 20% от диаметра?	\N	\N
940	С помощью какого инструмента производится проверка натяжения тросов системы управления ВС?	\N	\N
941	Какова причина появления гофра на обшивке ВС?	\N	\N
942	В каком документе указаны места расположения базовых точек по которым выполняют нивелировку ВС?	\N	\N
943	Как поступить с органическим остеклением кабины экипажа при текущем ремонте, если оно имеет &ldquo;серебро "?	\N	\N
944	Какие системы ремонта А.Т. существуют?	\N	\N
945	К Какой инструмент применяется для проверки затяжки фитингов и других резьбовых соединений?	\N	\N
946	Что такое &ldquo;серебро " органического остекления ВС?	\N	\N
947	С какой целью при капитальном ремонте применяется хонингование?	\N	\N
948	С какой целью при капитальном ремонте применяется нанесение гальванических покрытий?	\N	\N
949	Допускается ли при ремонте производить подтяжку ослабленных заклепок?	\N	\N
950	Какой метод организации труда существует при капитальном ремонте ВС?	\N	\N
951	При каком методе ремонта все части ремонтируемого изделия должны использоваться для его комплектования и не могут быть установлены на другие изделия того же типа?	\N	\N
952	Допускается ли при ремонте правка трубопроводов имеющих вмятины?	\N	\N
953	Что делать с тросом управления ВС при обнаружении нагартовки?	\N	\N
954	С какой целью применяется грунтовочный слой типового лакокрасочного покрытия(ЛКП) металлической поверхности ВС?	\N	\N
955	Разрешается ли осуществлять передачу отремонтированного ВС от производителя ремонта заказчику без проведения наземных и летных испытаний?	\N	\N
956	Выполните действия 2/3 - 1/5 1/3	\N	\N
957	Площадь круга равна *. Радиус этого круга равен:	\N	\N
958	Радиус основания конуса равен 5 см, а высота - 3 см. Объём конуса равен:	\N	\N
959	В прямоугольном треугольнике гипотенуза равна 5 см, а катет - 3 см. Площадь треугольника равна:	\N	\N
960	Луна и Земля взаимодействуют гравитационными силами. Каково соотношение между модулями сил F1 действия Земли на Луну и F2 действия Луны на Землю?	\N	\N
961	Железнодорожный вагон массой m движущийся со скоростью v, сталкивается с неподвижным вагоном массой 2m и сцепляется с ним. Каким суммарным по модулю импульсом обладают два вагона после столкновения?	\N	\N
962	Автомобиль, движущийся прямолинейно равноускоренно, увеличил свою скорость с 3 м/с до 9 м/с за 6 секунд. С каким ускорением двигался автомобиль?	\N	\N
963	За 6 сек маятник совершает 12 колебаний. Чему равна частота колебаний маятника?	\N	\N
964	По поверхности воды распространяется волна. Расстояние между ближайшими горбом и впадиной 2 м. Какова длина волны?	\N	\N
965	Какой процесс произошел в идеальном газе, если изменение его внутренней энергии равно нулю?	\N	\N
966	Плавление твердого тела происходит при постоянной температуре. Это происходит потому, что:	\N	\N
967	Каков максимальный КПД тепловой машины, которая использует нагреватель с температурой 4270С и холодильник с температурой 270С?	\N	\N
968	В камере сгорания двигателя в результате сгорания топлива выделилась энергия, равная 600 Дж, а холодильник получил энергию, равную 400 Дж. Какую работу совершил двигатель?	\N	\N
969	Электрический чайник имеет две спирали. При каком соединении спиралей- параллельном или последовательном вода в чайнике закипит быстрее?	\N	\N
970	Аккумулятор с ЭДС 12 В и внутренним сопротивлением 0,2 Ом замкнут сопротивлением 1 Ом. Найдите мощность тока на внешнем участке цепи.	\N	\N
971	Р-n переход обладает свойством	\N	\N
1014	В типовом случае программа контрольного руления ВС составляется:	\N	\N
972	Проводник находится в однородном магнитном поле с индукцией 1 Тл. Длина проводника 0,1 м. Какой ток надо пропустить по проводнику, чтобы он выталкивался из этого поля с силой 2,5 Н. Угол между проводником с током и вектором магнитной индукции равен 30 градусам.	\N	\N
973	За 2 с магнитный поток, пронизывающий контур, равномерно уменьшился с 8 до 2 Вб. Чему равно при этом значение ЭДС индукции в контуре?	\N	\N
974	Если индуктивность катушки уменьшить в 4 раза, то период свободных электрических колебаний в колебательном контуре	\N	\N
975	Что является силовой характеристикой магнитного поля?	\N	\N
976	Сила тока в цепи изменяется по закону *. Амплитуда силы тока равна	\N	\N
977	Как нужно расположить плоское зеркало, чтобы вертикальный луч стал отражаться в горизонтальном направлении?	\N	\N
978	Перераспределение интенсивности света, возникающее в результате суперпозиции волн, возбуждаемых когерентными источниками, называется	\N	\N
979	При расстоянии от предмета до тонкой собирающей линзы 5 см, и от линзы до изображения 5 см, фокусное расстояние линзы равно	\N	\N
980	Какое из перечисленных видов электромагнитного излучения имеет наименьшую длину волны?	\N	\N
981	Молекулой называется	\N	\N
982	Порядковый номер элемента в таблице Д.И. Менделеева определяется	\N	\N
983	Элементы, которые имеют одинаковое число протонов в ядрах, но разные относительные атомные массы и, как следствие, разное количество нейтронов в ядре, называются	\N	\N
984	Когда атом отдаёт электрон, он становится	\N	\N
985	В кристалле кремния атомы связаны	\N	\N
986	Основной единицей длины в международной системе единиц (СИ) является:	\N	\N
987	В международной системе единиц вес тела измеряется	\N	\N
988	В международной системе единиц мощность измеряется	\N	\N
989	Единицей силы электрического тока в международной системе единиц является	\N	\N
990	Тесла - это единица измерения	\N	\N
991	Как определяют техническое состояние авиационной техники (АТ) и качество её технического обслуживания (ТО)?	\N	\N
992	Что является целью контроля авиационной техники (АТ)?	\N	\N
993	Кто несёт ответственность за полноту и качество технического обслуживания (ТО) и ремонта (Р)?	\N	\N
994	Что включает в себя технолого-методическая документация контроля качества?	\N	\N
995	Какие обязанности руководителя инженерно-авиационного обеспечения полётов (ИАОП), инженерно-технического персонала (ИТП) и руководителей подразделений?	\N	\N
996	Кто осуществляет контроль состояния авиационной техники (АТ) в полёте?	\N	\N
997	Контроль качества отдельной работы, ТО и Р воздушного судна в целом считается завершённым, при условии:	\N	\N
998	За каждый случай некачественного технического обслуживания (ТО и	\N	\N
999	К специальным видам осмотра относятся:	\N	\N
1000	Разовый осмотр проводится:	\N	\N
1001	Инспекторский осмотр проводится:	\N	\N
1002	Контрольный осмотр авиационной техники (АТ) проводится:	\N	\N
1003	Для проведения контрольного осмотра руководитель службы инженерно- авиационного обеспечения полётов (ИАОП) назначает:	\N	\N
1004	Контрольный полёт (облёт) воздушного судна (ВС) производится для:	\N	\N
1005	Для продления срока действия сертификата (удостоверения) о годности ВС к полётам контрольный полёт (облёт) выполняется после перерыва в полетах более:	\N	\N
1006	Совмещение контрольных полётов и выполнение производственных заданий, кроме разрешённых ФА ВТ случаев:	\N	\N
1007	При отсутствии типовой программы контрольного полёта авиационным предприятием разрабатывается и утверждается индивидуальная программа его проведения, в которой указаны:	\N	\N
1008	В контрольном полёте экипаж и специалисты-участники полёта обязаны?	\N	\N
1009	Каждый участник контрольного полёта, при обнаружении отклонений от норм АТ обязан:	\N	\N
1010	При подтверждении экспертами отсутствия отклонений в работе авиационной техники (АТ):	\N	\N
1011	На выполненные после контрольного полёта работы технического обслуживания (ТОиР) оформляется:	\N	\N
1012	Контрольное руление ВС производится для:	\N	\N
1015	О выполнении программы контрольного руления и её результатах записывают:	\N	\N
1016	Кто даёт заключение об исправности ВС после выполнения работ по ТО и Р и устранению неисправностей?	\N	\N
1017	При выполнении ТО и Р конкретного ВС различными и последовательно чередующимися сменами исполнителей:	\N	\N
1018	Лица принимающие и сдающие ВС с незаконченным ТО и Р, обязаны:	\N	\N
1019	Передачи ВС с начатой, но незаконченной отдельной работой и без подтверждающей подписи:	\N	\N
1020	Обязательным условием организации работ с передачей смены в смену ВС с незаконченным ТО и Р является:	\N	\N
1021	Передачу ВС с незаконченным ТО и Р организуют и контролируют:	\N	\N
1022	В исключительных случаях руководитель работ сдающей смены обязан:	\N	\N
1023	Руководитель работ смены, сдающий ВС с незаконченным ТО и Р, обязан:	\N	\N
1024	Руководитель работ принимающей смены обязан:	\N	\N
1025	Руководитель работ смены, принимающей ВС с незаконченным ТО и Р должен:	\N	\N
1026	Какие контролируют объекты АТ визуально?	\N	\N
1027	По органолептическим признакам определяют:	\N	\N
1028	Инструментальный контроль состояния АТ осуществляют:	\N	\N
1029	Какие инструменты допускаются к контролю состояние АТ?	\N	\N
1030	Специалисты, осуществляющие контроль качества, ответственны за:	\N	\N
1031	Что в себя включает функции контроля качеств?	\N	\N
1032	Кто несёт ответственность за контроль качества в нерегламентированных случаях?	\N	\N
1033	Решением авиационного предприятия по наиболее квалифицированным специальностям может предоставляться право:	\N	\N
1034	Порядок предоставления правил по выполнению части работ более квалифицированным специалистам и его прекращения определяется?	\N	\N
1035	Результаты разового осмотра записываются:	\N	\N
1036	Объём инспекторского осмотра определяется:	\N	\N
1037	В программы конкретных осмотров включаются при необходимости:	\N	\N
1038	К участию в осмотре разрешается привлекать:	\N	\N
1039	В Бортовом журнале самолёта записывают:	\N	\N
1040	Сведения об инспекторских осмотрах ВС и их результаты регистрируются в:	\N	\N
1041	Материалы по результатам осмотра отражаются в:	\N	\N
1042	Обработка результатов контрольного полёта производится в соответствии:	\N	\N
1043	Подготовка ВС к контрольному полету осуществляют в соответствии с:	\N	\N
1044	Кто в праве принимать решение о выполнении контрольного полёта и в других случаях, не входящих в состав обязательных, с учётом устанавливаемых ФА ВТ ограничений?	\N	\N
1045	Утверждённая программа контрольного руления вместе с заданием на контрольное руление передаётся:	\N	\N
1046	О выполненных при приёме ВС с незаконченным ТО и Р недостатках докладывают:	\N	\N
1047	Техническое обслуживание с контролем параметров применяют для?	\N	\N
1048	Контроль параметров может быть:	\N	\N
1049	Эксплуатационная документация на ТОиР по состоянию должна определять:	\N	\N
1050	Техническое обслуживание с контролем уровня надежности применимо для:	\N	\N
1051	Человеческий фактор - это	\N	\N
1052	Целью человеческого фактора является	\N	\N
1053	Термин Человеческий фактор обозначает	\N	\N
1054	Какое поведение осуществляется на основе норм, традиций, образов, ценностей общества	\N	\N
1055	Главная цель обучения Человеческому фактору	\N	\N
1056	Энергично и оперативно воздействовать на поведение сотрудников с целью их совершенствования позволяет такой метод воспитания, как	\N	\N
1057	Доминирующая роль в причинах инцидентов в гражданской авиации приходится на:	\N	\N
1058	Вредные вещества, влияющие на четкость зрения	\N	\N
1059	Дальтонизм - это неправильное определение цветов:	\N	\N
1060	Признаки благоприятного социально-психологического климата:	\N	\N
1061	Избирательное внимание	\N	\N
1062	Разделенное внимание	\N	\N
1063	Фокусное внимание	\N	\N
1064	Выдержанное внимание	\N	\N
1065	Процесс внимания, восприятия и оценки должен производиться на основе	\N	\N
1066	Память зависит от следующего процесса	\N	\N
1067	Регистрация как один из процессов памяти это:	\N	\N
1068	Хранение как один из процессов памяти	\N	\N
1069	Вызов как один из процессов памяти	\N	\N
1070	Сверхкороткая память имеет продолжительность	\N	\N
1071	Эхоическая память	\N	\N
1072	Иконическая память	\N	\N
1073	Краткосрочная (рабочая) память	\N	\N
1074	Семантическая память хранит информацию	\N	\N
1075	Эпизодическая память хранит информацию	\N	\N
1076	Клаустрофобия - это	\N	\N
1077	Организационная культура -	\N	\N
1078	Организационный стресс включает в себя:	\N	\N
1079	Групповая ответственность подразумевает	\N	\N
1080	Рассеивание ответственности - это ситуация, при которой	\N	\N
1081	Групповая поляризация - это	\N	\N
1082	Инженер по обслуживанию самолетов мотивирован	\N	\N
1083	Влияние, которому подвержен человек в коллективе, зависит от следующих факторов	\N	\N
1084	Культура промышленности авиационного обслуживания состоит из	\N	\N
1085	Аспекты культуры безопасности	\N	\N
1086	Основой культуры безопасности является	\N	\N
1087	Ключевой компонент культуры безопасности	\N	\N
1088	Важный элемент продуктивной и собранной работы в бригаде	\N	\N
1089	Роль руководства в организации	\N	\N
1090	Роль контролирования	\N	\N
1091	Характеристика лидера (бригадира)	\N	\N
1092	Требование к претенденту до получения лицензии (технический персонал)	\N	\N
1093	Условия, которые могут влиять на состояние здоровья инженера	\N	\N
1094	Стресс - это	\N	\N
1095	Социальные симптомы стресса:	\N	\N
1096	Стратегия управления стрессом:	\N	\N
1097	Фактор давления времени на работников в авиационном обслуживании - это:	\N	\N
1098	Что такое срезание углов?	\N	\N
1099	Персонал, управляющий планированием, должен учитывать:	\N	\N
1100	Рабочая нагрузка зависит от:	\N	\N
1101	Недостаточная рабочая нагрузка может быть вызвана	\N	\N
1102	Управление рабочей нагрузкой должно включать	\N	\N
1103	Концепция защиты против человеческих ошибок Ризона включает в себя	\N	\N
1104	Обрыв контрольной пломбы на лимбе указателя обжатия амортизатора означает:	\N	\N
1105	Возможные последствия избыточного давления газа в амортизаторе:	\N	\N
1106	К системам основного управления относят:	\N	\N
1107	Планер самолета включает в себя:	\N	\N
1108	Герметизация дверей обеспечивается:	\N	\N
1109	орган управления рулем направления	\N	\N
1110	Натяжение тросовой проводки управления регулируется:	\N	\N
1111	Загрузочные устройства основных систем управления	\N	\N
1112	Отсек ВСУ обогревается с целью:	\N	\N
1113	Слив воды из водяных баков производится:	\N	\N
1114	При отказе крана заправки в момент централизованной заправки самолёта топливом переполнение топливного бака предотвращается:	\N	\N
1115	На многодвигательных самолётах наибольшую надёжность подачи топлива к двигателям обеспечивает схема:	\N	\N
1116	Основным способом обеспечения требуемой высотности топливной системы является:	\N	\N
1117	Двигательные подкачивающие насосы предназначены для:	\N	\N
1118	Наибольшей опасностью от наличия в топливе воды является:	\N	\N
1119	Топливные баки, непосредственно из которых топливо подаётся к двигателям, называются:	\N	\N
1120	Отказ системы дренажа топливных баков во время централизованной заправки их топливным опасен:	\N	\N
1121	Для предотвращения пожара в неблагоприятно расположенном топливном баке (вблизи гермокабины) применяется:	\N	\N
1122	Воздух в систему кондиционирования для ее работы нагнетается:	\N	\N
1123	Охлаждение воздуха в системе кондиционирования происходит:	\N	\N
1124	В открытой атмосфере кислородное голодание начинается с высоты	\N	\N
1125	Температурный режим салонов и кабины экипажа обеспечивается регулированием:	\N	\N
1126	Чувствительным элементом самолётного сигнализатора пожара типа ДПС является:	\N	\N
1127	Для тушения пожара в отсеках двигателей и ВСУ используется:	\N	\N
1128	Для тушения пожара в багажных отсеках используется:	\N	\N
1129	Современным огнегасящим веществом, используемым в стационарной пожарной системе самолета, является:	\N	\N
1130	При посадке самолета с убранным шасси система пожаротушения включается:	\N	\N
1131	Из применяющихся на самолетах противообледенительных систем наиболее экономичной является:	\N	\N
1132	Металлизация частей самолета предназначена для:	\N	\N
1133	Системы управления рулями и элеронами на самолетах с большой продолжительностью полета оборудуются:	\N	\N
1134	При вращений штурвала влево какой из элеронов отклонится в верх:	\N	\N
1135	В световом сигнализаторе положения шасси зеленый цвет означает:	\N	\N
1136	Одним из преимуществ уборки шасси вперед является:	\N	\N
1137	Какие потребители гидроэнергии одновременно подключены к нескольким контурам питания:	\N	\N
1138	Последствием кавитации жидкости в гидросистеме является:	\N	\N
1139	На современных транспортных самолетах целесообразно применение тормозов:	\N	\N
1140	Каково назначение газа в жидкостно-газовом амортизаторе шасси:	\N	\N
1141	Каково назначение жидкости в жидкостно- газовом амортизаторе шасси:	\N	\N
1142	Шимми-это самовозбуждающиеся колебания:	\N	\N
1143	На современных транспортных самолетах применяются амортизаторы шасси:	\N	\N
1144	В гидросистеме торможения колес для автоматического отключения поврежденного участка устанавливается:	\N	\N
1145	Во время стоянки самолета, когда основные насосы, стоящие на двигателях выключены, стояночное торможение обеспечивается гидроэнергией:	\N	\N
1146	Силовым кессоном крыла называется:	\N	\N
1147	В систему защиты лобовых стекол фонаря кабины экипажа от обледенения входит:	\N	\N
1148	Явление выделения из жидкости парогазовых пузырьков при уменьшении внешнего давления называется:	\N	\N
1149	Укажите назначение ВНА:	\N	\N
1150	Назначение сигнализатора обледенения:	\N	\N
1151	Недостатки роторов дискового типа:	\N	\N
1152	Основные преимущества роторов барабанного типа:	\N	\N
1153	Назовите определение ступени осевого компрессора:	\N	\N
1154	Укажите, как изменяется площадь проточной части компрессора по направлению движения воздуха:	\N	\N
1155	Основные преимущества замка типа ласточкин хвост:	\N	\N
1156	Условия, способствующие обледенению входного устройства и лопаток ВНА:	\N	\N
1157	Укажите, на каком принципе основана работа лабиринтных уплотнений:	\N	\N
1158	Укажите, о чём свидетельствует уменьшение времени выбега ротора:	\N	\N
1159	Укажите, какие типы компрессоров получили самое широкое распространение в газотурбинных двигателях:	\N	\N
1160	Укажите назначение ротора компрессора:	\N	\N
1161	Основные недостатки роторов барабанного типа:	\N	\N
1162	Правило определения гироскопического момента:	\N	\N
1163	Назначение рабочих лопаток турбины:	\N	\N
1164	Назначение турбины газотурбинного двигателя:	\N	\N
1165	Назначение фиксаторов жаровых труб:	\N	\N
1166	Отличие корпуса от кожуха камеры сгорания (КС)	\N	\N
1167	Укажите причины коробления сопловых и рабочих лопаток турбины:	\N	\N
1168	Основные преимущества кольцевых камер сгорания:	\N	\N
1169	Основные недостатки кольцевых камер сгорания:	\N	\N
1170	Укажите количество и назначение первичного потока воздуха:	\N	\N
1171	Назначение дисков турбин газотурбинных двигателей:	\N	\N
1172	Назначение выходного устройства:	\N	\N
1173	Укажите, какие параметры дозвукового реактивного сопла изменяются при перемещении центрального тела:	\N	\N
1174	Независимое изменение критического и выходного сечений в сопле Ловаля обеспечивается:	\N	\N
1175	При включении форсажной камеры площадь выходного сечения реактивного сопла (РС):	\N	\N
1176	Назначение камеры сгорания:	\N	\N
1177	Укажите количество и назначение вторичного потока воздуха в камере сгорания:	\N	\N
1178	Необходимость разрезов в местах стыковки отдельных секций жаровой трубы камеры сгорания:	\N	\N
1179	Цель покрытия стенок жаровых труб зелёной эмалью:	\N	\N
1180	Назначение турбины в одновальном турбовинтовом двигателе:	\N	\N
1181	Клаcсификация турбин по направлению движения потока:	\N	\N
1182	Назначение соплового аппарата турбины:	\N	\N
1183	Укажите центр тяжести (ЦТ) неуравновешенного неподвижного диска:	\N	\N
1184	Укажите способы достижения статической балансировки диска:	\N	\N
1185	Явление резонанса ротора возникает:	\N	\N
1186	Радиально-упорный подшипник воспринимает нагрузки:	\N	\N
1187	Назначение предохранительного (перепускного) клапана в маслофильтре:	\N	\N
1188	Необходимость сообщения воздушно-масляных полостей двигателя с атмосферой:	\N	\N
1189	Циркуляционный расход масла выбирается из следующих условий:	\N	\N
1190	Рекомендуемая температура масла на входе в двигатель:	\N	\N
1191	Необходимость применения в турбовинтовом двигателе масла повышенной вязкости:	\N	\N
1192	Укажите контур циркуляционной замкнутой системы:	\N	\N
1193	Сорта масел, применяемые в дозвуковых турбореактивных двигателях;	\N	\N
1194	Необходимость применения синтетических масел на отдельных газотурбинных двигателях:	\N	\N
1195	Число опор ротора газотурбинного двигателя зависит:	\N	\N
1196	Силовой системой двигателя называют:	\N	\N
1197	Основные преимущества охлаждаемых рабочих лопаток турбины:	\N	\N
1198	Наиболее простой и широко применяемый способ охлаждения рабочих лопаток турбины	\N	\N
1199	Отрицательная тяга реверсивным устройством создаётся:	\N	\N
1200	Основной тип топливной рабочей форсунки в газотурбинных двигателях	\N	\N
1201	Регулирование форсунок осуществляется:	\N	\N
1202	Назначение заливочного клапана роторно-вращательного топливного насоса	\N	\N
1203	Основные недостатки аксиально-поршневых топливных насосов:	\N	\N
1204	Пульсация подачи топлива в аксиально-поршневом насосе снижается:	\N	\N
1205	Назначение системы автоматического регулирования в газотурбинном двигателе:	\N	\N
1206	Назначение чувствительного элемента в системе автоматического регулирования:	\N	\N
1207	Приёмистостью двигателя называется:	\N	\N
1208	Центробежный измеритель регулятора частоты вращения:	\N	\N
1209	Какой режим работы вторичного радиолокатора применяется, если бортовой ответчик не работает в режиме RBS?	\N	\N
1210	Какие правила или порядок устанавливают ФП ИВП РФ 128?	\N	\N
1211	Что означает термин диспетчерское обслуживание воздушных судов?	\N	\N
1212	Что означает термин диспетчерское разрешение экипажу воздушного судна?	\N	\N
1213	Что означает термин контролируемый аэродром?	\N	\N
1214	Что означает термин полетно-информационное обслуживание воздушного движения?	\N	\N
1215	Какая ширина воздушной трассы устанавливается в воздушном пространстве РФ?	\N	\N
1216	Какая ширина приграничной полосы вдоль государственной границы Российской Федерации?	\N	\N
1217	Какой интервал вертикального эшелонирования в воздушном пространстве RVSM РФ между ВС, выполняющими полет по ППП выше эшелона перехода?	\N	\N
1218	Какой вертикальный интервал должен быть между ВС, выполняющими полеты по ПВП и ППП в районе контролируемого аэродрома, ниже эшелона перехода?	\N	\N
1219	Какое минимальное расстояние или время полёта должно быть между ВС, следующими в попутном направлении на одном эшелоне по одной трассе?	\N	\N
1220	На каком расстоянии или времени полёта между ВС, следующими на одном эшелоне по пересекающимся маршрутам, разрешается пересечь маршрут другого ВС или эшелон, занятый другим ВС?	\N	\N
1221	На каком расстоянии или времени полёта между ВС в момент расхождения разрешается пересечь эшелон, занятый встречным ВС?	\N	\N
1222	На каком расстоянии между ВС в момент пересечения разрешается пересечь эшелон, занятый ВС, следующим в попутном направлении?	\N	\N
1223	Что является основанием для пересечения государственной сухопутной границы РФ при выполнении международного полета?	\N	\N
1224	Является ли нарушением порядка использования воздушного пространства РФ несоблюдение экипажем правил вертикального, продольного и бокового эшелонирования?	\N	\N
1225	Какие документы составляют Воздушное законодательство РФ?	\N	\N
1226	Перед какими ВС имеют приоритет ВС, выполняющие регулярные воздушные перевозки пассажиров и багажа, при использовании воздушного пространства РФ? (Ст. 13 п. 2 ВК РФ)	\N	\N
1227	ГА, осуществляющая перевозки пассажиров, багажа, грузов и почты, относится к коммерческой ГА или к авиации общего назначения? (Ст. 21 п. 2 и 3 ВК РФ)?	\N	\N
1228	Кто может входить в состав летного экипажа коммерческой гражданской авиации (ГА) РФ? (Ст. 56 п. 4 ВК РФ)?	\N	\N
1229	Какие меры принуждения имеет право применять КВС в отношении пассажиров и других лиц на борту ВС? (Ст. 58 1 (2) )ВК РФ)?	\N	\N
1230	Действия экипажа ВС, терпящего бедствие? (Ст. 57 ВК РФ)?	\N	\N
1231	Действия КВС, принявшего сигнал бедствия от морского, речного, ВС или, обнаружившего ВС, людей, терпящих бедствие? (Ст. 60 ВК РФ)?	\N	\N
1232	Какие документы должно иметь на борту каждое гражданское воздушное судно? (Ст. 67 п. 1 ВК РФ)	\N	\N
1233	На каком основании допускается отступление от плана полета воздушного судна? (Ст. 70 п. 2 ВК РФ)?	\N	\N
1234	Какое ВС признается терпящим бедствие? (Ст. 86 п. 1 ВК РФ)	\N	\N
1235	Какое ВС признается потерпевшим бедствие?(Ст.86 п. 2 ВК РФ)?	\N	\N
1236	Кого в первую очередь обязан оповестить КВС или другой член экипажа ВС, потерпевшего бедствие? (Ст. 93 п. 1 ВК РФ)?	\N	\N
1237	Каковы цели расследования авиационного происшествия или инцидента? (Ст. 95 п. 2 ВК РФ)?	\N	\N
1238	Какие сведения об АП или инциденте должны сохранить члены экипажа ВС, потерпевшего бедствие, до прибытия комиссии по расследованию? (Ст. 97 п. 1 ВК РФ)?	\N	\N
1239	Каков размер обязательной суммы страхования жизни и здоровья членов экипажа ВС при исполнении ими служебных обязанностей? (Ст. 132 п. 1 ВК РФ)?	\N	\N
1240	На какие виды подразделяются полеты ВС по метеорологическим условиям их выполнения?	\N	\N
1241	В радиусе какого максимального расстояния от КТА устанавливается безопасная высота полёта в районе аэродрома?	\N	\N
1242	С каким расчётом определяется безопасная высота полета в районе аэродрома?	\N	\N
1243	Какой интервал должен быть между высотой перехода и эшелоном перехода?	\N	\N
1244	Какое ВС имеет преимущество в занятии высоты (эшелона) полета, когда несколько ВС запрашивают одну и ту же высоту (эшелон) полета?	\N	\N
1245	Действия командиров ВС в случае непреднамеренного сближения на встречных курсах на одной высоте, если изменить высоту полета невозможно	\N	\N
1246	Действия КВС, решившего самостоятельно изменить высоту (эшелон) в целях обеспечения безопасности полета	\N	\N
1247	Какое ВС должно уступить дорогу при движении двух ВС, выполняющих руление по рабочей площади аэродрома или РД на сходящихся курсах?	\N	\N
1248	Что должны иметь на борту ВС экипажи, выполняющие полеты в воздушном пространстве приграничной полосы Российской Федерации?	\N	\N
1249	Действия КВС в случае вынужденного отклонения от воздушной трассы, которое может привести к нарушению Государственной границы РФ	\N	\N
1250	Какие правила устанавливают ФАП 128?	\N	\N
1251	Если законы и правила государства, в воздушном пространстве которого выполняется полёт, отличаются от требований ФАП 128, то какие законы и правила применяются в этом случае?	\N	\N
1252	Какие органы должен информировать КВС в случае совершения акта незаконного вмешательства в деятельность ГА?	\N	\N
1253	Когда запрещается начинать полёт при выполнении его в условиях обледенения?	\N	\N
1254	На каком удалении от берега при полёте над водным пространством ВС должно быть оборудовано спасательными плотами?	\N	\N
1255	Как производится подготовка ВС к полёту в случаях, когда на аэродроме техническое обслуживание ВС не обеспечивается?	\N	\N
1256	По каким признакам состояния любого члена экипажа КВС не начинает и не продолжает полет далее ближайшего подходящего для безопасной посадки аэродрома?	\N	\N
1257	Размещение членов летного экипажа, исполняющих свои функции в кабине экипажа	\N	\N
1258	На каких этапах полёта запрещается членам лётного экипажа осуществлять действия и вести переговоры, не связанные с управлением ВС?	\N	\N
1259	Какое давление устанавливается на шкалах высотомеров и с чем сравниваются показания высотомеров перед взлетом с контролируемого аэродрома	\N	\N
1260	Ниже какой высоты запрещается выполнять полет по воздушной трассе по ППП?	\N	\N
1261	Чем определяется момент принятия решения КВС о начале полета?	\N	\N
1262	В каких случаях экипажу ВС запрещается начинать или продолжать руление?	\N	\N
1263	При какой метеорологической видимости не допускается выполнение взлета в сильном дожде?	\N	\N
1264	Какие условия принятия решения на выполнение повторного взлета, если прекращение взлета не связано с отказом или неисправностью ВС?	\N	\N
1265	До какой высоты производится набор высоты с курсом взлета?	\N	\N
1266	Какие ограничения по вертикальной скорости набора высоты при подходе к заданному эшелону во избежание срабатывания TCAS?	\N	\N
1267	Действия лётного экипажа в случае непреднамеренных отклонений ВС от текущего плана полета	\N	\N
1268	Какое условие должно быть соблюдено экипажем в случае изменения плана полета для следования на другой аэродром по другому маршруту?	\N	\N
1269	О чём экипаж обязан информировать орган ОВД при входе в район ОВД, где находится рубеж ухода на запасной аэродром?	\N	\N
1270	В какой момент прекращается начатое органом ОВД векторение при заходе на посадку по приборам?	\N	\N
1271	Когда обеспечивается внеочередной заход на посадку ВС?	\N	\N
1272	В отсутствие какой информации не разрешается заход на посадку по приборам и посадка по категории II и IIIА?	\N	\N
1273	При каких условиях запрещается выполнение посадки в сильном дожде?	\N	\N
1274	В каком случае продолжение захода на посадку ниже DA/H или MDA/H является нарушением эксплуатационного минимума для посадки?	\N	\N
1275	Когда выполняется прерванный заход на посадку (уход на второй круг), если не получено разрешение на посадку?	\N	\N
1276	Какие полёты относятся к полётам в особых условиях?	\N	\N
1277	В каких аварийных ситуациях экипаж передает сигналы бедствия?	\N	\N
1278	Какие атмосферные условия относятся к неблагоприятным для выполнения полетов?	\N	\N
1279	Какие метеорологические явления и условия относятся к опасным для полета?	\N	\N
1280	Какие метеорологические условия должны быть на запасном аэродроме для взлета?	\N	\N
1281	При каких метеоусловиях на запасном аэродроме для точного захода на посадку разрешается полет при погоде на аэродроме назначения ниже минимума ко времени прибытия?	\N	\N
1282	Какой остаток топлива должен быть после прибытия на аэродром назначения при использовании в качестве запасного аэродрома второй непересекающейся ВПП аэродрома назначения?	\N	\N
1283	Какое количество топлива должно быть после прибытия на аэродром назначения при выполнении полета с выбранным запасным аэродромом с рубежа ухода?	\N	\N
1284	Какое количество топлива должно быть после прибытия на аэродром назначения при выполнении полета без запасного аэродрома?	\N	\N
1285	При каких условиях допускается эксплуатация ВС в случае выхода из строя нескольких указанных в MEL компонентов оборудования?	\N	\N
1286	Когда экипаж выключает бортовые самописцы в случае авиационного происшествия или инцидента?	\N	\N
1287	Допустимые перерывы в управлении ВС при взлете и посадке для КВС или второго пилота	\N	\N
1288	Допустимые перерывы в исполнении КВС обязанностей сменного пилота на крейсерском этапе полета	\N	\N
1289	Какая периодичность проверок техники пилотирования и умения действовать в аварийной обстановке установлена для членов экипажей ВС?	\N	\N
1290	Когда дверь кабины летного экипажа должна находиться в закрытом и запертом положении?	\N	\N
1292	Разрешается ли заправка ВС горючими и смазочными материалами, не имеющими паспортов качества?	\N	\N
1293	Сколько трапов должно быть у самолёта при заправке, дозаправке, сливе топлива из воздушного судна с пассажирами на его борту, а также при их посадке или высадке?	\N	\N
1294	Какой порядок проведения предполетного медосмотра экипажа при выполнении международных полетов?	\N	\N
1295	Что является основанием для вылета ВС в аэропорт, который временно прекратил прием и выпуск ВС?	\N	\N
1296	Кто принимает решение о посадке ВС в аэропорту при возникновении обстоятельств, делающих невозможным прием, выпуск ВС?	\N	\N
1297	Кто организует предотвращение попыток незаконного вмешательства в деятельность ГА и пресечение несанкционированного проникновения на ВС в иностранном аэропорту?	\N	\N
1298	Когда включается и выключается система светосигнального оборудования аэродрома (СТО)?	\N	\N
1299	Какие минимальные временные интервалы установлены между взлётами, взлетом и посадкой ВС с одной или параллельных ВПП, расстояние между осями которых менее 1000 м?	\N	\N
1300	Укажите физические свойства металлов.	\N	\N
1301	Чем обусловлена высокая электропроводимость проводниковых материалов?	\N	\N
1302	Укажите процентное содержание углерода в чугуне.	\N	\N
1303	К каким свойствам относится коррозионная стойкость металлов?	\N	\N
1304	На какой установке определяется ударная вязкость металлов?	\N	\N
1305	Укажите группу хромоникелевых нержавеющих марок сталей	\N	\N
1306	Какая марка латуни содержит 28% Zn?	\N	\N
1307	Какой способ нагружения является наиболее &ldquo;жестким "?	\N	\N
1308	Укажите символ обозначения предела прочности материала.	\N	\N
1309	Укажите группу марок жаропрочных и жаростойких сталей.	\N	\N
1310	Каким символом обозначается число твердости по методу Роквелла, если вдавливается шарик?	\N	\N
1311	Какой процесс химико-термической обработки позволяет получить наиболее твердую поверхность?	\N	\N
1312	Из группы легированных сталей марок: 25 ХГСА, 30ХГСА, 30 ХГСН2 изготавливают:	\N	\N
1313	Укажите группу марок высоколегированных сталей.	\N	\N
1314	Укажите группу марок легированных сталей, используемых для изготовления пружин, рессор, стопорных колец	\N	\N
1315	Укажите группу марок инструментальных углеродистых сталей.	\N	\N
1316	С какой целью производится цементация малоуглеродистых сталей?	\N	\N
1317	Укажите группу марок углеродистых инструментальных сталей с пониженным содержанием серы и фосфора:	\N	\N
1318	Укажите цель плакирования дюралюминия:	\N	\N
1319	Укажите какие виды термообработки относятся к окончательным?	\N	\N
1320	Укажите группу низколегированных сталей-качественные.	\N	\N
1321	Укажите группу марок нержавеющих специальных сплавов.	\N	\N
1322	Каким символом обозначается число твердости по методу Виккерса?	\N	\N
1323	Укажите символ, обозначающий пластичность (относительное удлинение) материала:	\N	\N
1324	С какой целью производится закалка стали?	\N	\N
1325	Укажите группу марок легированных сталей с минимальным содержанием серы и фосфора.	\N	\N
1326	Каким символом обозначается число твердости по методу Бринелля?	\N	\N
1327	Каким символом обозначается число твердости по методу Бринелля?	\N	\N
1328	Чем принципиально отличается режим полного отжига от режима нормализации?	\N	\N
1329	Укажите группу марок легированных сталей высокого качества.	\N	\N
1330	Укажите технологические свойства металлов.	\N	\N
1331	Каким символом обозначается число твердости по Роквелу?	\N	\N
1332	В какой среде осуществляется охлаждение углеродистой стали при закалке на структуру тростит закалки?	\N	\N
1333	Какие свойства металлов относятся к механическим?	\N	\N
1334	Какая структура обеспечивает наибольшую твердость?	\N	\N
1335	В какой среде осуществляется охлаждение углеродистой стали при закалке на структуру мартенсит закалки?	\N	\N
1336	Какой показатель механических свойств определяют на твердомере Бриннеля?	\N	\N
1337	В каких единицах измеряется относительное удлинение материала?	\N	\N
1338	Укажите группу марок низколегированных сталей-высококачественные.	\N	\N
1339	На каком приборе определяют число твердости?	\N	\N
1340	Из группы марок легированных сталей ШХ9, ШХ15 изготавливают.	\N	\N
1341	Укажите цель испытания металла на растяжение.	\N	\N
1342	Укажите группу углеродистых инструментальных сталей с повышенным содержанием углерода.	\N	\N
1343	В каких единицах измеряется предел прочности металла?	\N	\N
1344	Укажите группу марок высокопрочных чугунов?	\N	\N
1345	Расшифруйте группу углеродистых инструментальных сталей: Сталь У7, Сталь У8, Сталь У10	\N	\N
1346	Укажите группу двухкарбидных твердых сплавов.	\N	\N
1347	Укажите группу марок легированных сталей, используемых для изготовления подшипников качения.	\N	\N
1395	Получение лицензии необходимо на осуществление:	\N	\N
1348	В чем заключается сущность термической обработки, называемой улучшение?	\N	\N
1349	При нарушении анодного покрытия интенсивно коррозировать в первую очередь будет:	\N	\N
1350	Какие пластмассы имеют слоистый наполнитель?	\N	\N
1351	Какие материалы называют фрикционными?	\N	\N
1352	Каким слоем 4-х слойного покрытия является грунт?	\N	\N
1353	Какие пластмассы не имеют наполнителя?	\N	\N
1354	Какой наполнитель имеет гетинакс?	\N	\N
1355	При нарушении катодного покрытия интенсивно коррозировать в первую очередь будет:	\N	\N
1356	При отказе горелки аэростат классической формы буде снижаться со скоростью:	\N	\N
1357	При отказе дежурной горелки на ряде горелок в качестве замены ей можно использовать:	\N	\N
1358	При блокировании обоих огневых клапанов в открытом состоянии нужно:	\N	\N
1359	В случае возгорания травы при горячем наполнении первое действие, которое должен совершить пилот:	\N	\N
1360	В случае, если оболочка повисла на проводах, пилот может эвакуироваться из корзины следующим способом:	\N	\N
1361	В случае посадки с вертикальной скоростью около7 м/с и невозможностью ее уменьшить необходимо:	\N	\N
1362	В случае приземления на воду гондола аэростата с заправленным баллонами:	\N	\N
1363	В случае вынужденной посадки на воду, если ветер дует в сторону берега:	\N	\N
1364	При вынужденной посадке на воду нужно расконтрить карабины, крепящие оболочку к гондоле, почему?	\N	\N
1365	В случае вынужденной посадки аэростата на лес каким способом можно спуститься и спустить пассажиров с верхушек деревьев на землю:	\N	\N
1366	Какую команду пилот должен дать пассажирам перед вынужденной посадкой в лес:	\N	\N
1367	при посадке с большой горизонтальной скоростью нужно:	\N	\N
1368	В случае резкой потери нагрузки необходимо:	\N	\N
1369	Какие признаки скорого образования ложки существуют:	\N	\N
1370	Что нужно делать в случае образования ложки:	\N	\N
1371	Скорость приземного ветра имеет суточный ход. Когда достигается минимум скорости ветра?	\N	\N
1372	При планировании вечернего полета необходимо учитывать, что:	\N	\N
1373	При планировании утреннего полета в летнее время период нахождения в воздухе может безопасно находиться в интервале:	\N	\N
1374	При планировании вечернего полета в летнее время период нахождения в воздухе лучше планировать в интервале:	\N	\N
1375	При сильном ветре на площадке, прикрытой от ветра деревьями или другим препятствием, сразу за прикрытием образуется:	\N	\N
1376	В Северном полушарии с высотой направление ветра в нормальных метеоусловиях:	\N	\N
1377	Температура, при которой содержащаяся в воздухе вода начинает переходить из газообразного состояния в жидкое, называется:	\N	\N
1378	Туман по причинам образования классифицируется на :	\N	\N
1379	Если в прогнозе погоды на утренние часы графики температур и точки росы пересекаются, то можно:	\N	\N
1380	Кучевые облака формируются:	\N	\N
1381	Кучевые облака могут достигать высоты:	\N	\N
1382	Перистые облака говорят о:	\N	\N
1383	Что такое инверсионный слой:	\N	\N
1384	Для границ инверсионных слоев характерно:	\N	\N
1385	Как называется ветер суточного цикла в прибрежной зоне морей и озер?	\N	\N
1386	В утреннем летнем полете, через какое время после восхода солнца обычно можно ожидать начала термической активности:	\N	\N
1387	Что такое сдвиг ветра?	\N	\N
1388	Магнитное склонение:	\N	\N
1389	Угол между географическим и магнитным меридианами в точке земной поверхности, это	\N	\N
1390	В плоских прямоугольных координатах сетки UTM первая координата означает расстояние от:	\N	\N
1391	Для определения направления движения аэростата с использованием компаса нужно ориентировать осевую линую компаса:	\N	\N
1392	В случае потери ориентировки, найти свое местоположение на карте с использованием магнитного компаса, карты и линейки можно:	\N	\N
1393	При постоянной горизонтальной скорости ветра 6 узлов, аэростат пролетит за 20 минут:	\N	\N
1394	Рассчитать скорость аэростата при наличии карты, компаса и часов с секундной стрелкой можно:	\N	\N
1484	—	\N	\N
1396	Выполнение полетов на свободном аэростате в личных целях обладает приоритетом на использование воздушного пространства:	\N	\N
1397	Авиация подразделяется на:	\N	\N
1398	Авиация общего назначения - это:	\N	\N
1399	Легкое воздушное судно - это:	\N	\N
1400	Сверхлегкое воздушное судно - это	\N	\N
1401	На гражданское воздушное судно, зарегистрированное в государственном реестре гражданских воздушных судов, в обязательном порядке наносятся:	\N	\N
1402	На должности специалистов авиационного персонала не принимаются лица:	\N	\N
1403	Для выполнения полета воздушного судна должны быть оформлены как минимум следующие страховые полисы:	\N	\N
1404	Вертикальные границы элементов структуры воздушного пространства (диспетчерские зоны, диспетчерские районы, зоны ограничения полетов, опасные зоны, запретные зоны, кроме заповедников) указываются:	\N	\N
1405	Согласно Федеральным авиационным правилам Подготовка и выполнение полетов запрещается выполнять или предпринимать попытки выполнять обязанности командира воздушного судна:	\N	\N
1406	Что означает аббревиатура MSL?	\N	\N
1407	Что означает аббревиатура AGL?	\N	\N
1408	Что такое QNH?	\N	\N
1409	Что такое QFE?	\N	\N
1410	Что такое QNE?	\N	\N
1411	Наиболее удобный и используемый чаще всего в воздухоплавательных соревнованиях масштаб карты:	\N	\N
1412	В первой координате плоских прямоугольных координат четвертая цифра слева при шестизначном формате показывает:	\N	\N
1413	Вертикальные линии координатной сетки на картах 1942 года, выпущенной в Советском Союзе, направлены:	\N	\N
1414	Какова будет погрешность (выраженная в метра прилета аэростата с расстояния 10 000 м в точку при ошибке в направлении движения на 1 градус?	\N	\N
1415	Названия, границы, допустимые высоты и иные параметры элементов структуры воздушного пространства утверждаются:	\N	\N
1416	Обозначение GND обозначает:	\N	\N
1417	Обозначение UNL обозначает:	\N	\N
1418	Каждый аэродром имеет о себе информацию, публикуемую в официальном сборнике, которая в том числе содержит:	\N	\N
1419	NOTAM - это:	\N	\N
1420	NOTAM какой серии информирует пилотов о временных ограничениях в воздушном пространстве РФ:	\N	\N
1421	Принцип работы барометрического высотомера основан на измерении:	\N	\N
1422	На каждые 10 м высоты давление стандартной атмосферы изменяется на:	\N	\N
1423	Авиационный диапазон радиочастот - это:	\N	\N
1424	Для обеспечения хорошего приема сигнала длина антенны должна быть кратна:	\N	\N
1425	Для теплового аэростата объемом 2000-3000 м3 нормальным считается расход газа:	\N	\N
1426	К чему приводит повышенная продуваемость ткани оболочки?	\N	\N
1427	Контроль воздухопроницаемости ткани оболочки производится:	\N	\N
1428	Бесшумная горелка применяется:	\N	\N
1429	Газовый баллон заполняется жидким газом не полностью, в нем остается газовая подушка, которая примерно составляет в процентах от полного объема:	\N	\N
1430	Проверка технического состояния баллонов, используемых в аэростатах, имеющих сертификат типа в России должны проводиться:	\N	\N
1431	Максимальное рабочее давление в газовых баллонах свободных аэростатов:	\N	\N
1432	Испытания газового баллона на прочность проходят при давлении:	\N	\N
1433	Предохранительный клапан на баллоне должен сработать при достижении давления внутри баллона:	\N	\N
1434	Для контроля заправки газовых баллонов аэростата предусмотрен:	\N	\N
1435	Газовый баллон считается заправленным, когда:	\N	\N
1436	Для смазки соединения рукава горелки и баллона лучше использовать смазку на основе:	\N	\N
1437	При проверке работоспособности топливной системы перед полетом необходимо:	\N	\N
1438	При течи газа из соединения рукава горелки и баллона необходимо:	\N	\N
1439	Открывать вентиль газового баллона нужно:	\N	\N
1440	В газовых баллонах должен быть установлен индикатор окончания топлива, он показывает остаток топлива, когда топлива в баллоне:	\N	\N
1441	Максимальная вертикальная (динамическая) составляющая ветра для пилота свободного аэростата составляет:	\N	\N
1525	За горной вершиной/хребтом образуется:	\N	\N
1442	Диапазон рабочих температур свободного аэростата в общем случае:	\N	\N
1443	Максимальные допустимые вертикальные скорости перемещения для свободных аэростатов классической формы:	\N	\N
1444	Максимальная допустимая рабочая температура воздуха внутри оболочки для материалов оболочек на основе полиамида (капрона)	\N	\N
1445	Минимальная посадочная масса для свободного аэростат примерно равна:	\N	\N
1446	Рассчитать разрешенную массу полезной загрузки аэростата для данных погодных условий можно:	\N	\N
1447	При какой планируемой высоте полета разрешенная масса полезной загрузки больше?	\N	\N
1448	Зимой расход топлива на аэростате в сравнении с летним периодом при прочих равных условиях:	\N	\N
1449	Зимой разрешенная масса полезной нагрузки аэростата в сравнении с летним периодом при прочих равных условиях:	\N	\N
1450	В случае попадания в сдвиг ветра более устойчиво себя будет вести аэростат:	\N	\N
1451	В радиосигналах авиационного диапазона используется:	\N	\N
1452	Время торможения для аэростата объемом оболочки 4000 куб.м. в сравнении с аэростатом объемом оболочки 2200 куб.м. с одинаковой скорости спуска:	\N	\N
1453	Как меняется усилие на фале управления парашютным клапаном с увеличением загрузки гондолы аэростата?	\N	\N
1454	Расстояние от точки наполнения аэростата до ближайшего препятствия по направлению ветра примерно рассчитывается исходя из формулы, где h - высота препятствия, V - скорость ветра в м/с:	\N	\N
1455	При скорости ветра на посадке около 30 км/ч можно ожидать волочение аэростата по земле после касания земли с полностью открытым клапаном:	\N	\N
1456	При увеличении скорости ветра усилие на фале управления парашютным клапаном при приземлении:	\N	\N
1457	При какой скорости ветра уже целесообразно искать стартовую площадку с прикрытием от ветра?	\N	\N
1458	Наиболее опасные для аэростатов облака:	\N	\N
1459	После восхода солнца раньше всего можно ожидать начала турбулентности над:	\N	\N
1460	Динамическая турбулентность образуется:	\N	\N
1461	Динамическая турбулентность чаще всего характерна для:	\N	\N
1462	Туманы по синоптическим условиям образования делятся на:	\N	\N
1463	Для получения метеорологической информации пилот может использовать:	\N	\N
1464	При составлении плана полета географические координаты указываются в формате:	\N	\N
1465	ФПЛ (FPL) - это:	\N	\N
1466	В поле тип воздушного судна ФПЛ свободный аэростат обозначается как:	\N	\N
1470	Чтобы описать район полетов свободного аэростата согласно Табеля сообщений о движении воздушных судов в Российской Федерации 2013 используется признак:	\N	\N
1471	ФПЛ для полета в воздушном пространстве класса С пилотом свободного аэростата должен быть подан согласно Табелю сообщений о движении воздушного судна 2013 не позднее, чем:	\N	\N
1472	ФПЛ (уведомление для полета в воздушном пространстве класса G пилотом свободного аэростат должен быть подан согласно Табелю сообщений о движении воздушного судна 2013 не позднее, чем:	\N	\N
1473	В случае, если пилот сообщил органу УВД о начале выполнения полета согласно плана, он должен:	\N	\N
1474	ФПЛ для полета в воздушном пространства класса С может быть подан по следующим каналам связи:	\N	\N
1475	Почему у свободного аэростата отсутствует приемник воздушного давления для указателя скорости?	\N	\N
1476	Полет аэростата основан на:	\N	\N
1477	В коде METAR гроза с дождем обозначается как:	\N	\N
1478	В коде METAR отсутствие изменений погоды в течение ближайших двух часов обозначается как:	\N	\N
1479	В коде METAR видимость более 10 км, отсутствие облачности ниже 1500 м и кучево-дождевой облачности обозначается как:	\N	\N
1480	Буквы R и A согласно Федеральным авиационным правилам Порядок ведения радиосвязи читаются как:	\N	\N
1481	Фраза РАЗРЕШАЮ согласно Федеральным авиационным правилам Порядок ведения радиосвязи звучит как:	\N	\N
1482	Команды снижения (набора высоты) согласно Федеральным авиационным правилам Порядок ведения радиосвязи звучат как:	\N	\N
1483	Ограничение по скорости приземного ветра для свободного аэростата составляет:	\N	\N
1485	В воздушном пространстве класса G наличие разрешения на использование воздушного пространства:	\N	\N
1486	Класс С устанавливается:	\N	\N
1487	Класс G устанавливается:	\N	\N
1488	Границы классов A, C и G устанавливаются:	\N	\N
1489	Диспетчерская зона устанавливается:	\N	\N
1490	Диспетчерский район устанавливается от уровня:	\N	\N
1491	Ширина местной воздушной линии не может быть больше:	\N	\N
1492	Местная воздушная линия при обслуживании воздушного движения на ней классифицируется как:	\N	\N
1493	Разрешительный порядок использования воздушного пространства установлен:	\N	\N
1494	Для каких целей подается уведомление в классе G?	\N	\N
1495	Если в ходе полета, проходящем в воздушном пространстве класса G, необходимо пересечь класс С, предоставление плана полета:	\N	\N
1496	Кроме разрешения на использование воздушного пространства подъемы привязных аэростатов над населенными пунктами выполняются при наличии разрешения:	\N	\N
1497	На свободном аэростате, выполняющем полеты днем по ПВП на барометрических высотах менее 3000 м на борту должны находиться в соответствии с Федеральными правилами Подготовка и выполнение полетов в Российской Федерации при отсутствии утвержденного MEL:	\N	\N
1498	При выполнении полета в целях АОН с составом экипажа воздушного судна из одного пилота:	\N	\N
1499	По решению владельца или эксплуататанта воздушного судна АОН:	\N	\N
1500	Владелец легкого (сверхлегкого воздушного судна АОН обеспечивает:	\N	\N
1501	При взлете с неконтролируемого аэродрома на высотомере устанавливается давление:	\N	\N
1502	Перевод высотомера с QNH на QNE производится:	\N	\N
1503	Вне населенных пунктов и мест скопления людей при проведении массовых мероприятий запрещено выполнять полеты ближе, чем:	\N	\N
1504	Полет по ПВП на истинных высотах 300 м и выше, но ниже облаков выполняется:	\N	\N
1505	Желая выполнять полеты на воздушном судне, подъемная сила которого создается теплым воздухом, гражданин должен получить свидетельство пилота:	\N	\N
1506	Обладатель свидетельства пилота свободного аэростата может выполнять свои функции, если у него есть в наличии:	\N	\N
1507	Обладатель свидетельства пилота свободного аэростата должен быть старше:	\N	\N
1508	Минимальный учебный налет кандидата на получение свидетельства пилота свободного аэростата должен составлять:	\N	\N
1509	Выберите ошибку, грозящую наиболее серьезными последствиями в полете:	\N	\N
1510	Выберите ошибку, грозящую наиболее серьезными последствиями при дальнейшем наполнении:	\N	\N
1511	Выберите ошибку, грозящую наиболее серьезными последствиями:	\N	\N
1512	Выберите ошибку, грозящую наиболее серьезными последствиями при наполнении:	\N	\N
1513	После подъема аэростата Вы обнаружили разрыв ткани оболочки выше экватора размером около 30 см. Ваши действия:	\N	\N
1514	Метеоминимум пилота свободного аэростата составляет:	\N	\N
1515	Расстояние до линий электропередач от места наполнения аэростата по направлению ветра должно быть не менее:	\N	\N
1516	При планировании дальности полета пилот свободного аэростата учитывает при расчетах:	\N	\N
1517	В случае, если траектории двух аэростатов пересекаются, то какой аэростат должен уступить дорогу?	\N	\N
1518	В случае совместного использования воздушного пространства аэростатами и моторными воздушными судами, кто должен уступать дорогу?	\N	\N
1519	При массовых полетах аэростатов в случае, если пилот не уверен в том, что его траектория свободна, он не должен сообщать своему аэростату вертикальную скорость более:	\N	\N
1520	В случае массовых стартов аэростатов использование отцепки при взлете:	\N	\N
1521	Где рекомендуется располагаться пилоту в корзине аэростата при полетах с другими лицами на борту:	\N	\N
1522	При инструктаже лиц, находящихся на борту аэростата, пилот рекомендует им перед приземлением занять следующее положение:	\N	\N
1523	Пилот может управлять аэростатом:	\N	\N
1524	При пролете на аэростате над горной вершины высотой 1 км. со скоростью ветра 50 км/ч каким будет минимальный безопасный вертикальный интервал между горой и аэростатом?	\N	\N
1526	В какое время с зимнего режима полетов на летний (т.е исключать дневные полет:	\N	\N
1527	В весенний и осенний периоды сухой травы перед горячим наполнением рекомендуется:	\N	\N
1528	В случае прохождения восходящего термического потока:	\N	\N
1529	Что может случиться с аэростатом при резкой потере нагрузки:	\N	\N
1530	В воздушном пространстве класса С разрешаются:	\N	\N
1531	Владелец легкого или сверхлегкого воздушного суда обеспечивает хранение следующих данных:	\N	\N
1532	Может ли обладатель свидетельства пилота свободного аэростата - владелец ЕЭВС свободного аэростат выполнять оперативное и периодическое техническое обслуживание своего воздушного судна?	\N	\N
1533	В общем случае требования Федеральных авиационных правил Положение о порядке допуска к эксплуатации единичных экземпляров воздушных судов авиации общего назначения применимы к свободным аэростатам:	\N	\N
1534	В общем случае требования Федеральных авиационных правил Положение о порядке допуска к эксплуатации единичных экземпляров воздушных судов авиации общего назначения применимы к: свободным аэростатам:	\N	\N
1535	Для единичного экземпляра воздушного судна сертификат летной годности выдается на:	\N	\N
1536	Плановый инспекционный контроль летной годности единичного экземпляра ВС проводится уполномоченным органом в области гражданской авиации:	\N	\N
1537	На единичном экземпляре аэростатического воздушного судна должна быть установлена:	\N	\N
1538	Огнестойкая табличка на единичном экземпляре аэростатического воздушного судна должна содержать следующую информацию:	\N	\N
1539	Проверка ткани оболочки производится:	\N	\N
1540	При наличии в оболочке ткани различных цветов проверка прочности производится:	\N	\N
1541	Для проверки ткани на прочность необходимо:	\N	\N
1542	Для гарантированного сохранения летной годности ткань оболочки должна иметь прочность на разрыв (для полосы ткани в 25 м более:	\N	\N
1543	Повреждения оболочки не допускаются выше:	\N	\N
1544	Проверка технического состояния баллона на прочность проводится:	\N	\N
1545	Проверка технического состояния баллона на герметичность проводится:	\N	\N
1546	Могут ли свободные аэростаты, имеющие сертификат типа в России, комплектоваться компонентами других свободных аэростатов, также имеющих сертификат типа в России:	\N	\N
1547	Какие элементы оболочки воспринимают нагрузку от веса загруженной гондолы?	\N	\N
1548	Горизонтальные силовые ленты оболочки служат главным образом для:	\N	\N
1549	Выберите верное утверждение.	\N	\N
1550	При сборке аэростата для работы на привязи карабин привязного фала крепится к аэростату:	\N	\N
1551	При сборке аэростата для работы на привязи свободный конец привязного фала крепится на земле к:	\N	\N
1552	Какие требования предъявляются к привязному фалу:	\N	\N
1553	Устройство, срабатывающее в оболочке при определенной температуре и извещающее пилота о достижении максимально допустимого значения падающим в гондолу вымпелом, называется:	\N	\N
1554	Выберите, что не используется для измерения температуры воздуха в оболочке аэростата в полете:	\N	\N
1555	Почему гондолы, рассчитанные на большое количество пассажиров, делят на отсеки?	\N	\N
1556	Какой материал является самым ходовым для изготовления обшивки гондолы?	\N	\N
1557	Манометр горелки определяет:	\N	\N
1558	Почему не допускается работа горелкой при частично открытом огневом клапане?	\N	\N
1559	Чем принципиально отличается однофазная схема горелки от двухфазной?	\N	\N
1560	В однофазной схеме по сравнению с двухфазной:	\N	\N
1561	В двухфазной схеме по сравнению с однофазной:	\N	\N
1562	Почему газовый баллон, от которого питается дежурная горелка в двухфазной системе, нельзя надувать азотом?	\N	\N
1564	Будет ли течь газ из баллона при открытом вентиле при не присоединённом рукаве горелки:	\N	\N
1565	В штуцере газового баллона установлен:	\N	\N
1566	На оболочки аэростатов ставится:	\N	\N
1567	Для навигационных целей пилотами аэростатов используются приемники GPS/ГЛОНАС. Погрешность измерения высоты составляет:	\N	\N
1568	Для навигационных целей пилотами аэростатов используются приемники GPS/ГЛОНАС. Погрешность измерения плоскостных координат у современных приемников составляет:	\N	\N
1569	В общем случае приемник GPS/ГЛОНАС показывает высоту:	\N	\N
1570	При полете на аэростате объемом оболочки 4000 куб.м. в сравнении с аэростатом объемом оболочки 2200 куб.м. время отклика аэростата на действия пилота горелкой или парашютным клапаном:	\N	\N
1571	Для чего на аэростатах объемом оболочки от 4000 куб.м. ставят поворотные клапана для того:	\N	\N
1572	С увеличением температуры окружающего воздуха подъемная сила аэростата при неизменных остальных параметрах:	\N	\N
1573	С увеличением высоты полета подъемная сила аэростата при неизменных остальных параметрах:	\N	\N
1574	С увеличением влажности подъемная сила аэростата при неизменных остальных параметрах:	\N	\N
1575	С увеличением температуры воздуха внутри оболочки аэростата подъемная сила аэростата при неизменных остальных параметрах:	\N	\N
1576	Как зависит потребная температура внутри оболочки от изменения удельной подъемной силы (загрузки аэростата) в зависимости от изменения высоты полета?	\N	\N
1577	В стандартных условиях температура изменяется при изменении высоты на 1 км на:	\N	\N
1578	Внутреннее давление в оболочке по высоте оболочке:	\N	\N
1579	С увеличением загрузки гондолы аэростата внутреннее давление:	\N	\N
1580	Сколько и каких сил действует на аэростат в горизонтальном полете?	\N	\N
1581	Сколько и каких сил действует на аэростат в равномерном подъеме или спуске?	\N	\N
1582	При попадании в сдвиг ветра или в турбулентный поток на аэростат начинают действовать соответственно горизонтальные или вертикальные силы, зависящие от аэродинамических коэффициентов. В каком случае эти коэффициенты наибольшие?	\N	\N
1583	При работе аэростата в привязном режиме на 1 фале, сколько и каких сил действует на аэростат?	\N	\N
1584	При подъемах на привязи необходимо создавать большую подъемную силу, чем при горизонтальном полете. Зависит ли значение этой разницы от угла отклонения привязного фала относительно земли:	\N	\N
1585	С увеличением скорости ветра при работе в привязном режиме нужно уменьшать высоту привязных подъемов, потому что:	\N	\N
1586	Ложная (динамическая) подъемная сила возникает:	\N	\N
1587	С увеличением разницы в скоростях ветра у земли и на высоте 20-30 м эффект ложной подъемной силы:	\N	\N
1588	Тепло, создаваемое горелкой аэростата, в основном уходит на:	\N	\N
1589	С увеличением подъемной силы (загрузки аэростата) расход топлива:	\N	\N
1590	С увеличением температуры окружающего воздуха расход топлива:	\N	\N
1591	При одной и той же суммарной массе конструкции (включая аэростат, пилота, топливо и т.п.) на какой оболочке расход газа будет меньше?	\N	\N
1592	Для аэростата с объемом оболочки 2550 куб.м., температуре наружного воздуха 15°С и загрузке около 550 кг (т.е. примерно пилот+2) расход газа в минуту примерно составляет:	\N	\N
1593	При одинаковых температурах ночью и утром (после восхода солнца) при прочих равных условиях расход газа больше:	\N	\N
1594	Максимальная температура внутри оболочки достигается (через некоторое время после включения горелки, после перемешивания воздух:	\N	\N
1595	Максимальная температура в оболочке достигается на высоте примерно 0.7 от полной высоты оболочки. Она превышает аэростатическую температуру по оболочке на:	\N	\N
1596	Температура на поверхности ткани оболочки:	\N	\N
1597	Каким газом Вы будете поддавливать баллон, от которого питается дежурная горелка двухфазной схемы?	\N	\N
1598	Какой газ имеет наибольшую удельную подъемную силу?	\N	\N
1599	Какой газ взрывоопасен?	\N	\N
1600	Какой газ находится в оболочке теплового аэростата во время полета:	\N	\N
1601	Какие методы искусственного повышения давления в газовых баллонах могут применяться:	\N	\N
1602	Какой газ вы предпочтете для искусственного повышения давления в двухфазном баллоне:	\N	\N
1603	Какой из газов взрывоопасный:	\N	\N
1604	В каком из баллонов с искусственно поднятым давлением оно упадет быстрее с выработкой топлива в баллоне:	\N	\N
1605	Что является максимальным взлётным весом планера?	\N	\N
1606	Какие меры надо принять в том случае, если вес пилота планера меньше минимально допустимого?	\N	\N
1607	С учетом каких факторов определяется объем заливаемого в планер водного балласта?	\N	\N
1608	В наборе высоты произошла отцепка планера от самолёта буксировщика, для безопасной посадки необходимо:	\N	\N
1609	Как влияет слив водного балласта на смещение центра тяжести планера?	\N	\N
1610	Какие требования предъявляются к буксировочному фалу, используемому для подъема планеров?	\N	\N
1611	У самолёта-буксировщика отказал двигатель на разбеге (самолёт и планер находятся ещё на земле). Какие действия должен предпринять планерист?	\N	\N
1612	При угрозе лобового столкновения с препятствием на пробеге планеристу следует принять следующие меры:	\N	\N
1613	Какие действия надо предпринять при отказе указателя скорости на планере?	\N	\N
1614	При потере из поля зрения самолёта во время аэробуксировки (например, при попадании в облако), пилоту планера следует:	\N	\N
1615	Скорость максимального качества (наивыгоднейшая) для планера это:	\N	\N
1616	Экономическая скорость планера это:	\N	\N
1617	Какая цель преследуется при выпуске закрылков у планера, стоящего в спирали?	\N	\N
1618	На что влияет выпуск интерцепторов?	\N	\N
1619	Набор высоты в восходящем потоке планером достигается за счет:	\N	\N
1620	В какой момент планер относительно воздушного потока не снижается?	\N	\N
1621	Каким образом пилот управляет скоростью планера?	\N	\N
1622	В каких средних пределах находится аэродинамическое качество современных спортивных планеров?	\N	\N
1623	При попадании в спутную струю самолёта-буксировщика планеристу следует:	\N	\N
1624	Полеты на планерах, оснащенных кислородным оборудованием, на высотах свыше 4 тысяч метров разрешены в том случае если:	\N	\N
1625	Хорошая парящая погода устанавливается	\N	\N
1626	Признаками парящей погоды являются	\N	\N
1627	Какими факторами обусловлено появление восходящих потоков на равнине?	\N	\N
1628	Пилот какого типа планера может не бояться наступления обледенения?	\N	\N
1	Как изменится ЦТ воздушного судна после посадки пассажира весом 84 кг., если до посадки пассажира вертолёт весил 626 кг и момент силы относительно точки измерения равен 15743,5 кгм? Расстояние пассажира от точки измерения 2,1 метра.	\N	\N
3	Аэродинамическое качество планера равно 23. На сколько снизится воздушное судно, пролетев 15 км?	Для решения данной задачи, считаем, что воздушное судно снижается с наивыгоднейшим углом атаки, при котором достижим минимальный угол планирования и максимальная дальность планирования относительно земли.\r\n\r\nУгол планирования зависит только от аэродинамического качества: tg Θ = 1 / K\r\nВысота полёта H = Lпл * tg Θ, где Lпл - дальность планирования относительно земли, а Θ - угол планирования.\r\n\r\nСоставим равенство: 1 / K = H / Lпл\r\n\r\nВ нашем случае неизвестным является высота HΔ, на которую снизится воздушное судно, пролетев 15 км:\r\n\r\nHΔ = Lпл/ K\r\n\r\nПодставим значения: HΔ = 15 / 23 ≈ 0.652 км\r\n\r\nДля ответа переведём высоту в футы: HΔ = 0.652 / 0.3048 * 1000 ≈ 2 139 футов, где 0.3048 - коэффициент пересчёта из футов в метры\r\n\r\nНаиболее близкое значение в третьем варианте ответа: 2 100 футов.	\N
\.


--
-- Data for Name: rosaviatest_type_certificates_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rosaviatest_type_certificates_category (type_sertificates_id, category_id, "position") FROM stdin;
1	1	10
1	2	20
1	3	30
1	4	40
1	5	50
1	6	60
1	7	70
1	8	80
1	9	90
1	10	100
1	11	110
1	12	120
1	13	130
1	14	140
1	15	150
1	16	160
1	17	170
1	18	180
1	19	190
1	20	200
1	21	210
1	22	220
2	2	10
2	1	20
2	3	30
2	4	40
2	5	50
2	6	60
2	8	70
2	9	80
2	23	90
2	10	100
2	11	110
2	7	120
2	12	140
2	13	150
2	14	160
2	15	170
2	16	180
2	17	190
2	19	200
2	20	210
2	21	220
2	22	230
3	1	10
3	2	20
3	3	30
3	4	40
3	5	50
3	6	60
3	7	70
3	8	80
3	9	90
3	10	100
3	11	110
3	12	120
3	13	130
3	14	140
3	15	150
3	16	160
3	17	170
3	18	180
3	19	190
3	20	200
3	21	210
3	22	220
4	2	10
4	1	20
4	3	30
4	4	40
4	5	50
4	6	60
4	8	70
4	9	80
4	23	90
4	10	100
4	11	110
4	7	120
4	24	130
4	12	140
4	13	150
4	14	160
4	15	170
4	16	180
4	17	190
4	19	200
4	20	210
4	21	220
4	22	230
5	2	10
5	1	20
5	3	30
5	4	40
5	5	50
5	6	60
5	8	70
5	9	80
5	10	90
5	11	100
5	12	110
5	7	120
5	13	130
5	15	140
5	16	150
5	14	160
5	18	170
5	19	180
5	20	190
5	21	200
5	22	210
5	17	220
6	1	10
6	2	20
6	3	30
6	4	40
6	5	50
6	6	60
6	8	70
6	9	80
6	10	90
6	11	100
6	12	110
6	7	120
6	13	130
6	15	140
6	16	150
6	14	160
6	18	170
6	19	180
6	20	190
6	21	200
6	22	210
6	17	220
7	2	10
7	1	20
7	3	30
7	4	40
7	5	50
7	6	60
7	8	70
7	9	80
7	23	90
7	10	100
7	11	110
7	12	120
7	7	130
7	13	140
7	15	150
7	16	160
7	14	170
7	19	180
7	18	190
7	20	200
7	21	210
7	22	220
7	17	230
8	1	10
8	2	20
8	3	30
8	5	40
8	4	50
8	8	60
8	6	70
8	9	80
8	10	90
8	11	100
8	12	110
8	13	120
8	14	130
8	15	140
8	16	150
8	17	160
8	18	170
8	19	180
8	7	190
8	20	200
8	21	210
8	22	220
9	2	10
9	3	20
9	5	30
9	4	40
9	9	50
9	10	60
9	12	70
9	14	80
9	15	90
9	16	100
9	8	110
9	19	120
9	20	130
9	22	140
9	25	150
9	1	160
9	17	170
9	26	180
9	27	190
10	1	10
10	2	20
10	3	30
10	4	40
10	5	50
10	6	60
10	7	70
10	8	80
10	9	90
10	10	100
10	24	110
10	12	120
10	13	130
10	14	140
10	17	160
10	19	170
10	20	180
10	15	150
11	2	10
11	3	20
11	4	30
11	5	40
11	8	50
11	1	60
11	6	70
11	9	80
11	11	90
11	12	100
11	10	110
11	13	120
11	15	130
11	16	140
11	14	150
11	19	160
11	24	170
11	21	180
11	22	190
11	20	200
11	17	210
12	4	10
12	2	20
12	12	30
12	15	40
12	16	50
12	14	60
12	9	70
12	19	80
12	3	90
12	10	100
12	22	110
13	4	10
13	18	20
13	7	30
13	28	50
13	15	60
13	14	70
13	9	80
13	19	90
14	2	10
14	4	20
14	5	30
14	15	40
14	16	50
14	14	60
14	9	70
15	2	10
15	4	20
15	15	30
15	14	40
15	9	50
16	4	10
16	15	20
16	9	40
17	1	10
17	15	20
17	8	30
17	14	40
17	17	50
17	9	60
17	18	70
17	7	80
17	30	90
17	31	100
17	4	110
17	28	120
17	32	130
18	2	10
18	3	20
18	33	30
18	10	40
18	14	50
18	19	60
18	20	70
2	18	130
16	14	30
\.


--
-- Data for Name: stories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stories (id, image, video, text_button, hyperlink, time_show, "position", color_button, logo_story, text_color) FROM stdin;
1	stories/traktor/traktor.jpg	stories/traktor/traktor.mp4	Трактор	https://yandex.ru	57	1	FFFFFF	stories/traktor/traktor_logo.jpg	000000
2	stories/droni/droni.jpg	stories/droni/droni.mp4	Дроны	https://yandex.ru	49	2	FFFFFF	stories/droni/droni_logo.gif	000000
\.


--
-- Data for Name: type_certificates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_certificates (id, title, image) FROM stdin;
1	Частный пилот (самолет)	
2	Частный пилот (вертолет)	
3	Коммерческий пилот (самолет)	
4	Коммерческий пилот (вертолет)	
5	Пилот многочленного экипажа	
6	Линейный пилот (самолет)	
7	Линейный пилот (вертолет)	
8	Пилот планера	
9	Пилот свободного аэростата	
10	Пилот сверхлегкого воздушного судна	
11	Штурман	
12	Бортрадист	
13	Бортинженер (бортмеханик)	
14	Лётчик-наблюдатель	
15	Бортпроводник	
16	Бортоператор	
17	Специалист по техническому обслуживанию воздушных судов	
18	Сотрудник по обеспечению полетов	
19	Пилот-инструктор	
20	Подготовка по прочим вопросам	
21	Диспетчер УВД (АДО)	
22	Диспетчер УВД (ДОП)	
23	Диспетчер УВД (РДО)	
\.


--
-- Data for Name: type_correct_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_correct_answers (id, title) FROM stdin;
1	Подтверждена
2	Неоднозначна
3	Не подтверждена
4	Имеются расхождения
5	В процессе подтверждения
\.


--
-- Data for Name: video; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video (id, title, file_name, url) FROM stdin;
0	Выполнение учебных полётов на самолёте CESSNA 172S	video_for_students.mp4	video_for_students/video_for_students.mp4
\.


--
-- Name: mini_stories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mini_stories_id_seq', 3, true);


--
-- Name: preflight_inspection_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preflight_inspection_categories_id_seq', 1, false);


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profiles_id_seq', 3, true);


--
-- Name: rosaviatest_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rosaviatest_answers_id_seq', 9575, true);


--
-- Name: rosaviatest_question_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rosaviatest_question_category_id_seq', 33, true);


--
-- Name: type_certificates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.type_certificates_id_seq', 23, true);


--
-- Name: hand_book_main_categories hand_book_main_categories_mainCategoryId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hand_book_main_categories
    ADD CONSTRAINT "hand_book_main_categories_mainCategoryId" PRIMARY KEY (main_category_id);


--
-- Name: preflight_inspection_categories preflight_inspection_categories_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preflight_inspection_categories
    ADD CONSTRAINT preflight_inspection_categories_id PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: rosaviatest_answers rosaviatest_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosaviatest_answers
    ADD CONSTRAINT rosaviatest_answers_pkey PRIMARY KEY (id);


--
-- Name: rosaviatest_category rosaviatest_question_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosaviatest_category
    ADD CONSTRAINT rosaviatest_question_category_pkey PRIMARY KEY (id);


--
-- Name: rosaviatest_questions rosaviatest_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rosaviatest_questions
    ADD CONSTRAINT rosaviatest_questions_pkey PRIMARY KEY (id);


--
-- Name: stories stories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stories
    ADD CONSTRAINT stories_pkey PRIMARY KEY (id);


--
-- Name: type_certificates type_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_certificates
    ADD CONSTRAINT type_certificates_pkey PRIMARY KEY (id);


--
-- Name: video video_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_id PRIMARY KEY (id);


--
-- Name: hand_book_sub_categories_mainCategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "hand_book_sub_categories_mainCategoryId" ON public.preflight_inspection_categories USING btree (main_category_id);


--
-- Name: normal_categories_main_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX normal_categories_main_category_id ON public.normal_categories USING btree (main_category_id);


--
-- Name: normal_check_list_normal_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX normal_check_list_normal_category_id ON public.normal_check_list USING btree (normal_category_id);


--
-- Name: preflight_inspetion_check_list_preflihgtInspectionCategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "preflight_inspetion_check_list_preflihgtInspectionCategoryId" ON public.preflight_inspection_check_list USING btree (preflight_inspection_category_id);


--
-- Name: question_type_certificates fk_question_type_certificates_question; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT fk_question_type_certificates_question FOREIGN KEY (question_id) REFERENCES public.rosaviatest_questions(id) ON DELETE CASCADE;


--
-- Name: question_type_certificates fk_question_type_certificates_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT fk_question_type_certificates_type FOREIGN KEY (type_certificate_id) REFERENCES public.type_certificates(id) ON DELETE CASCADE;


--
-- Name: preflight_inspection_categories hand_book_sub_categories_mainCategoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preflight_inspection_categories
    ADD CONSTRAINT "hand_book_sub_categories_mainCategoryId_fkey" FOREIGN KEY (main_category_id) REFERENCES public.hand_book_main_categories(main_category_id);


--
-- Name: preflight_inspection_check_list preflight_inspetion_check_lis_preflihgtInspectionCategoryI_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preflight_inspection_check_list
    ADD CONSTRAINT "preflight_inspetion_check_lis_preflihgtInspectionCategoryI_fkey" FOREIGN KEY (preflight_inspection_category_id) REFERENCES public.preflight_inspection_categories(id);


--
-- Name: question_type_certificates question_type_certificates_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT question_type_certificates_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.rosaviatest_category(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict LevZripLeAjYINmbPRgtUNJMyuxiUzXCdeAf57POi4ufKuGBtZbftt3no4hVW30

