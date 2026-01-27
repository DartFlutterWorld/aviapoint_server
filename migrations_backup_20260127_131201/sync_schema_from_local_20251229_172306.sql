-- Миграция структуры БД с локальной на продакшн
-- Создано автоматически
-- ВНИМАНИЕ: Эта миграция изменяет только структуру, НЕ переносит данные

BEGIN;

--
-- PostgreSQL database dump
--

\restrict vnMBDtQRgWtn57M4DuScedVVhu8C3SrhAQuILfJktLlaxKlnC0hqidbymp1YQ2z

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: deactivate_expired_subscriptions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.deactivate_expired_subscriptions() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE subscriptions
    SET is_active = false
    WHERE is_active = true 
      AND end_date < CURRENT_TIMESTAMP;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$;
--
-- Name: update_subscriptions_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_subscriptions_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: airport_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airport_feedback (
    id integer NOT NULL,
    airport_code character varying(10) NOT NULL,
    email character varying(255),
    comment text,
    photos jsonb,
    created_at timestamp without time zone DEFAULT now(),
    status character varying(20) DEFAULT 'pending'::character varying
);
--
-- Name: airport_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.airport_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: airport_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.airport_feedback_id_seq OWNED BY public.airport_feedback.id;
--
-- Name: airport_ownership_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airport_ownership_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    airport_id integer NOT NULL,
    email character varying(255) NOT NULL,
    documents jsonb DEFAULT '[]'::jsonb,
    status character varying(20) DEFAULT 'pending'::character varying,
    admin_notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    reviewed_at timestamp without time zone,
    reviewed_by integer,
    phone character varying(20),
    phone_from_request character varying(20),
    full_name character varying(255),
    comment text,
    airport_code character varying(10)
);
--
-- Name: TABLE airport_ownership_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.airport_ownership_requests IS 'Заявки пользователей на владение аэродромами';
--
-- Name: COLUMN airport_ownership_requests.documents; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.documents IS 'Массив URL документов, подтверждающих право собственности';
--
-- Name: COLUMN airport_ownership_requests.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.status IS 'Статус заявки: pending (на рассмотрении), approved (одобрена), rejected (отклонена)';
--
-- Name: COLUMN airport_ownership_requests.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.phone IS 'Телефон пользователя из профиля';
--
-- Name: COLUMN airport_ownership_requests.phone_from_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.phone_from_request IS 'Телефон из формы заявки';
--
-- Name: COLUMN airport_ownership_requests.full_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.full_name IS 'ФИО пользователя из формы заявки';
--
-- Name: COLUMN airport_ownership_requests.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.comment IS 'Комментарий пользователя';
--
-- Name: COLUMN airport_ownership_requests.airport_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_ownership_requests.airport_code IS 'Код ICAO аэропорта';
--
-- Name: airport_ownership_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.airport_ownership_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: airport_ownership_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.airport_ownership_requests_id_seq OWNED BY public.airport_ownership_requests.id;
--
-- Name: airport_visitor_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airport_visitor_photos (
    id integer NOT NULL,
    airport_code character varying(10) NOT NULL,
    airport_id integer,
    photo_url text NOT NULL,
    user_id integer NOT NULL,
    user_phone character varying(20) NOT NULL,
    label text,
    uploaded_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--
-- Name: TABLE airport_visitor_photos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.airport_visitor_photos IS 'Фотографии аэропортов, добавленные посетителями';
--
-- Name: COLUMN airport_visitor_photos.airport_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.airport_code IS 'ICAO код аэропорта';
--
-- Name: COLUMN airport_visitor_photos.airport_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.airport_id IS 'ID аэропорта (для связи с таблицей airports)';
--
-- Name: COLUMN airport_visitor_photos.photo_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.photo_url IS 'URL фотографии относительно public/';
--
-- Name: COLUMN airport_visitor_photos.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.user_id IS 'ID пользователя, загрузившего фотографию';
--
-- Name: COLUMN airport_visitor_photos.user_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.user_phone IS 'Телефон пользователя, загрузившего фотографию';
--
-- Name: COLUMN airport_visitor_photos.label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.label IS 'Подпись к фотографии (опционально)';
--
-- Name: COLUMN airport_visitor_photos.uploaded_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airport_visitor_photos.uploaded_at IS 'Дата и время загрузки фотографии';
--
-- Name: airport_visitor_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.airport_visitor_photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: airport_visitor_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.airport_visitor_photos_id_seq OWNED BY public.airport_visitor_photos.id;
--
-- Name: airports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airports (
    id integer NOT NULL,
    is_active boolean DEFAULT true,
    type character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    name_eng character varying(255),
    city character varying(255),
    ident character varying(10) NOT NULL,
    ident_ru character varying(10),
    country_code character varying(20),
    country character varying(100),
    country_eng character varying(100),
    region character varying(255),
    region_eng character varying(255),
    coordinates_text character varying(100),
    longitude_deg numeric(10,7) NOT NULL,
    latitude_deg numeric(10,7) NOT NULL,
    elevation_ft integer,
    ownership character varying(100),
    is_international boolean DEFAULT false,
    email character varying(255),
    website character varying(255),
    notes text,
    runway_name character varying(255),
    runway_length integer,
    runway_width integer,
    runway_surface character varying(100),
    runway_magnetic_course character varying(50),
    runway_lighting character varying(50),
    services jsonb DEFAULT '{}'::jsonb,
    owner_id integer,
    is_verified boolean DEFAULT false,
    source character varying(50) DEFAULT 'aopa'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    visitor_photos jsonb DEFAULT '[]'::jsonb,
    photos jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT airports_latitude_deg_check CHECK (((latitude_deg >= ('-90'::integer)::numeric) AND (latitude_deg <= (90)::numeric))),
    CONSTRAINT airports_longitude_deg_check CHECK (((longitude_deg >= ('-180'::integer)::numeric) AND (longitude_deg <= (180)::numeric)))
);
--
-- Name: TABLE airports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.airports IS 'База данных аэропортов на основе данных АОПА-Россия';
--
-- Name: COLUMN airports.ident; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airports.ident IS 'Код аэродрома из АОПА (например, HEE1)';
--
-- Name: COLUMN airports.ident_ru; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airports.ident_ru IS 'Русский код аэродрома (например, ХЕЕ1)';
--
-- Name: COLUMN airports.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airports.source IS 'Источник данных (aopa, manual, etc.)';
--
-- Name: COLUMN airports.visitor_photos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airports.visitor_photos IS 'Массив URL фотографий, добавленных посетителями аэропорта';
--
-- Name: COLUMN airports.photos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.airports.photos IS 'Массив URL фотографий аэродрома';
--
-- Name: airports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.airports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: airports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.airports_id_seq OWNED BY public.airports.id;
--
-- Name: airspeeds_for_emergency_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.airspeeds_for_emergency_operations (
    id integer NOT NULL,
    title text,
    name text NOT NULL,
    doing text NOT NULL
);
--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id integer NOT NULL,
    flight_id integer NOT NULL,
    passenger_id integer NOT NULL,
    seats_count integer NOT NULL,
    total_price integer NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT bookings_seats_count_check CHECK ((seats_count > 0)),
    CONSTRAINT bookings_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT bookings_total_price_check CHECK (((total_price)::numeric >= (0)::numeric))
);
--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;
--
-- Name: category_news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_news (
    id integer NOT NULL,
    title text NOT NULL
);
--
-- Name: emergency_categories; Type: TABLE; Schema: public; Owner: -
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
--
-- Name: feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedback (
    id integer NOT NULL,
    source_page character varying(100) NOT NULL,
    airport_code character varying(10),
    flight_id integer,
    email character varying(255),
    comment text NOT NULL,
    photos jsonb DEFAULT '[]'::jsonb,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);
--
-- Name: TABLE feedback; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.feedback IS 'Таблица для обратной связи от пользователей';
--
-- Name: COLUMN feedback.source_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feedback.source_page IS 'Страница, с которой была отправлена форма обратной связи';
--
-- Name: COLUMN feedback.airport_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feedback.airport_code IS 'Код аэропорта (если обратная связь связана с аэропортом)';
--
-- Name: COLUMN feedback.flight_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feedback.flight_id IS 'ID полета (если обратная связь связана с полетом)';
--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;
--
-- Name: flight_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flight_photos (
    id integer NOT NULL,
    flight_id integer NOT NULL,
    photo_url character varying(500) NOT NULL,
    uploaded_by integer NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
--
-- Name: flight_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flight_photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: flight_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flight_photos_id_seq OWNED BY public.flight_photos.id;
--
-- Name: flight_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flight_questions (
    id integer NOT NULL,
    flight_id integer NOT NULL,
    author_id integer,
    question_text text NOT NULL,
    answer_text text,
    answered_by_id integer,
    answered_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);
--
-- Name: flight_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flight_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: flight_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flight_questions_id_seq OWNED BY public.flight_questions.id;
--
-- Name: flight_waypoints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flight_waypoints (
    id integer NOT NULL,
    flight_id integer NOT NULL,
    airport_code character varying(255) NOT NULL,
    sequence_order integer NOT NULL,
    arrival_time timestamp without time zone,
    departure_time timestamp without time zone,
    comment text,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT flight_waypoints_sequence_order_check CHECK ((sequence_order > 0))
);
--
-- Name: TABLE flight_waypoints; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.flight_waypoints IS 'Точки маршрута полета, включая первую и последнюю';
--
-- Name: COLUMN flight_waypoints.flight_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.flight_id IS 'ID полета';
--
-- Name: COLUMN flight_waypoints.airport_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.airport_code IS 'Код аэропорта (ICAO)';
--
-- Name: COLUMN flight_waypoints.sequence_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.sequence_order IS 'Порядок точки в маршруте (1, 2, 3...)';
--
-- Name: COLUMN flight_waypoints.arrival_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.arrival_time IS 'Время прибытия в эту точку';
--
-- Name: COLUMN flight_waypoints.departure_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.departure_time IS 'Время отправления из этой точки';
--
-- Name: COLUMN flight_waypoints.comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.flight_waypoints.comment IS 'Комментарий к точке маршрута';
--
-- Name: flight_waypoints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flight_waypoints_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: flight_waypoints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flight_waypoints_id_seq OWNED BY public.flight_waypoints.id;
--
-- Name: flights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flights (
    id integer NOT NULL,
    pilot_id integer NOT NULL,
    departure_date timestamp without time zone NOT NULL,
    available_seats integer NOT NULL,
    price_per_seat integer NOT NULL,
    aircraft_type character varying(100),
    description text,
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT flights_available_seats_check CHECK ((available_seats > 0)),
    CONSTRAINT flights_price_per_seat_check CHECK (((price_per_seat)::numeric >= (0)::numeric)),
    CONSTRAINT flights_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);
--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flights_id_seq OWNED BY public.flights.id;
--
-- Name: hand_book_main_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hand_book_main_categories (
    main_category_id integer DEFAULT 1 NOT NULL,
    title text NOT NULL,
    sub_title text NOT NULL,
    picture text NOT NULL
);
--
-- Name: stories; Type: TABLE; Schema: public; Owner: -
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
    text_color text NOT NULL,
    title text
);
--
-- Name: mini_stories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mini_stories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: mini_stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mini_stories_id_seq OWNED BY public.stories.id;
--
-- Name: news; Type: TABLE; Schema: public; Owner: -
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
--
-- Name: normal_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normal_categories (
    id integer NOT NULL,
    title text NOT NULL,
    main_category_id integer NOT NULL,
    title_eng text NOT NULL,
    picture text NOT NULL,
    sub_title text NOT NULL
);
--
-- Name: normal_check_list; Type: TABLE; Schema: public; Owner: -
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
--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    amount numeric(10,2) NOT NULL,
    currency character varying(10) DEFAULT 'RUB'::character varying NOT NULL,
    description text NOT NULL,
    payment_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    user_id integer NOT NULL,
    subscription_type character varying(50) NOT NULL,
    period_days integer NOT NULL
);
--
-- Name: preflight_inspection_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preflight_inspection_categories (
    id integer NOT NULL,
    title text NOT NULL,
    main_category_id integer NOT NULL,
    title_eng text NOT NULL,
    picture text NOT NULL,
    sub_title text NOT NULL
);
--
-- Name: preflight_inspection_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preflight_inspection_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: preflight_inspection_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preflight_inspection_categories_id_seq OWNED BY public.preflight_inspection_categories.id;
--
-- Name: preflight_inspection_check_list; Type: TABLE; Schema: public; Owner: -
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
--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    first_name text,
    phone text NOT NULL,
    last_name text,
    email text,
    id integer NOT NULL,
    avatar_url character varying(255),
    owned_airports jsonb DEFAULT '[]'::jsonb,
    telegram character varying(255),
    max character varying(255)
);
--
-- Name: COLUMN profiles.owned_airports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.owned_airports IS 'Массив ID аэропортов, которыми владеет пользователь';
--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;
--
-- Name: question_type_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_type_certificates (
    question_id integer NOT NULL,
    type_certificate_id integer NOT NULL,
    category_id integer
);
--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    booking_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    reviewed_id integer NOT NULL,
    rating integer,
    comment text,
    created_at timestamp without time zone DEFAULT now(),
    reply_to_review_id integer,
    CONSTRAINT reviews_rating_check CHECK (((rating IS NULL) OR ((rating >= 1) AND (rating <= 5))))
);
--
-- Name: COLUMN reviews.reply_to_review_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.reply_to_review_id IS 'ID отзыва, на который дан ответ (для двусторонних отзывов)';
--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;
--
-- Name: rosaviatest_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rosaviatest_answers (
    question_id integer NOT NULL,
    answer_text text NOT NULL,
    is_correct boolean NOT NULL,
    is_official boolean NOT NULL,
    "position" integer NOT NULL,
    id integer NOT NULL
);
--
-- Name: rosaviatest_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rosaviatest_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: rosaviatest_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rosaviatest_answers_id_seq OWNED BY public.rosaviatest_answers.id;
--
-- Name: rosaviatest_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rosaviatest_category (
    id integer NOT NULL,
    title text NOT NULL,
    image text NOT NULL
);
--
-- Name: rosaviatest_question_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rosaviatest_question_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: rosaviatest_question_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rosaviatest_question_category_id_seq OWNED BY public.rosaviatest_category.id;
--
-- Name: rosaviatest_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rosaviatest_questions (
    id integer NOT NULL,
    title text NOT NULL,
    explanation text,
    correct_answer integer
);
--
-- Name: rosaviatest_type_certificates_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rosaviatest_type_certificates_category (
    type_sertificates_id integer NOT NULL,
    category_id integer NOT NULL,
    "position" integer NOT NULL
);
--
-- Name: subscription_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_types (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    period_days integer NOT NULL,
    price integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    description text DEFAULT ''::text NOT NULL
);
--
-- Name: subscription_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscription_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: subscription_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscription_types_id_seq OWNED BY public.subscription_types.id;
--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    payment_id character varying(255),
    subscription_type_id integer NOT NULL,
    period_days integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount integer NOT NULL
);
--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;
--
-- Name: type_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_certificates (
    id integer NOT NULL,
    title text NOT NULL,
    image text NOT NULL
);
--
-- Name: type_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.type_certificates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--
-- Name: type_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.type_certificates_id_seq OWNED BY public.type_certificates.id;
--
-- Name: type_correct_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.type_correct_answers (
    id integer NOT NULL,
    title text NOT NULL
);
--
-- Name: video; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video (
    id integer NOT NULL,
    title text NOT NULL,
    file_name text NOT NULL,
    url text NOT NULL
);
--
-- Name: airport_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_feedback ALTER COLUMN id SET DEFAULT nextval('public.airport_feedback_id_seq'::regclass);
--
-- Name: airport_ownership_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_ownership_requests ALTER COLUMN id SET DEFAULT nextval('public.airport_ownership_requests_id_seq'::regclass);
--
-- Name: airport_visitor_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_visitor_photos ALTER COLUMN id SET DEFAULT nextval('public.airport_visitor_photos_id_seq'::regclass);
--
-- Name: airports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports ALTER COLUMN id SET DEFAULT nextval('public.airports_id_seq'::regclass);
--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);
--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);
--
-- Name: flight_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_photos ALTER COLUMN id SET DEFAULT nextval('public.flight_photos_id_seq'::regclass);
--
-- Name: flight_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_questions ALTER COLUMN id SET DEFAULT nextval('public.flight_questions_id_seq'::regclass);
--
-- Name: flight_waypoints id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_waypoints ALTER COLUMN id SET DEFAULT nextval('public.flight_waypoints_id_seq'::regclass);
--
-- Name: flights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights ALTER COLUMN id SET DEFAULT nextval('public.flights_id_seq'::regclass);
--
-- Name: preflight_inspection_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preflight_inspection_categories ALTER COLUMN id SET DEFAULT nextval('public.preflight_inspection_categories_id_seq'::regclass);
--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);
--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);
--
-- Name: rosaviatest_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rosaviatest_answers ALTER COLUMN id SET DEFAULT nextval('public.rosaviatest_answers_id_seq'::regclass);
--
-- Name: rosaviatest_category id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rosaviatest_category ALTER COLUMN id SET DEFAULT nextval('public.rosaviatest_question_category_id_seq'::regclass);
--
-- Name: stories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stories ALTER COLUMN id SET DEFAULT nextval('public.mini_stories_id_seq'::regclass);
--
-- Name: subscription_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_types ALTER COLUMN id SET DEFAULT nextval('public.subscription_types_id_seq'::regclass);
--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);
--
-- Name: type_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_certificates ALTER COLUMN id SET DEFAULT nextval('public.type_certificates_id_seq'::regclass);
--
-- Name: airport_feedback airport_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_feedback
    ADD CONSTRAINT airport_feedback_pkey PRIMARY KEY (id);
--
-- Name: airport_ownership_requests airport_ownership_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_ownership_requests
    ADD CONSTRAINT airport_ownership_requests_pkey PRIMARY KEY (id);
--
-- Name: airport_visitor_photos airport_visitor_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_visitor_photos
    ADD CONSTRAINT airport_visitor_photos_pkey PRIMARY KEY (id);
--
-- Name: airports airports_ident_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports
    ADD CONSTRAINT airports_ident_key UNIQUE (ident);
--
-- Name: airports airports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (id);
--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);
--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);
--
-- Name: flight_photos flight_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_photos
    ADD CONSTRAINT flight_photos_pkey PRIMARY KEY (id);
--
-- Name: flight_questions flight_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_questions
    ADD CONSTRAINT flight_questions_pkey PRIMARY KEY (id);
--
-- Name: flight_waypoints flight_waypoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_waypoints
    ADD CONSTRAINT flight_waypoints_pkey PRIMARY KEY (id);
--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);
--
-- Name: hand_book_main_categories hand_book_main_categories_mainCategoryId; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hand_book_main_categories
    ADD CONSTRAINT "hand_book_main_categories_mainCategoryId" PRIMARY KEY (main_category_id);
--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
--
-- Name: preflight_inspection_categories preflight_inspection_categories_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preflight_inspection_categories
    ADD CONSTRAINT preflight_inspection_categories_id PRIMARY KEY (id);
--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
--
-- Name: rosaviatest_answers rosaviatest_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rosaviatest_answers
    ADD CONSTRAINT rosaviatest_answers_pkey PRIMARY KEY (id);
--
-- Name: rosaviatest_category rosaviatest_question_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rosaviatest_category
    ADD CONSTRAINT rosaviatest_question_category_pkey PRIMARY KEY (id);
--
-- Name: rosaviatest_questions rosaviatest_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rosaviatest_questions
    ADD CONSTRAINT rosaviatest_questions_pkey PRIMARY KEY (id);
--
-- Name: stories stories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stories
    ADD CONSTRAINT stories_pkey PRIMARY KEY (id);
--
-- Name: subscription_types subscription_types_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_types
    ADD CONSTRAINT subscription_types_code_key UNIQUE (code);
--
-- Name: subscription_types subscription_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_types
    ADD CONSTRAINT subscription_types_pkey PRIMARY KEY (id);
--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);
--
-- Name: type_certificates type_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.type_certificates
    ADD CONSTRAINT type_certificates_pkey PRIMARY KEY (id);
--
-- Name: airport_visitor_photos uq_airport_visitor_photos_airport_code_url; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_visitor_photos
    ADD CONSTRAINT uq_airport_visitor_photos_airport_code_url UNIQUE NULLS NOT DISTINCT (airport_code, photo_url);
--
-- Name: flight_waypoints uq_flight_waypoints_sequence; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_waypoints
    ADD CONSTRAINT uq_flight_waypoints_sequence UNIQUE (flight_id, sequence_order);
--
-- Name: video video_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_id PRIMARY KEY (id);
--
-- Name: hand_book_sub_categories_mainCategoryId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "hand_book_sub_categories_mainCategoryId" ON public.preflight_inspection_categories USING btree (main_category_id);
--
-- Name: idx_airport_feedback_airport_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_feedback_airport_code ON public.airport_feedback USING btree (airport_code);
--
-- Name: idx_airport_feedback_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_feedback_created_at ON public.airport_feedback USING btree (created_at);
--
-- Name: idx_airport_feedback_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_feedback_status ON public.airport_feedback USING btree (status);
--
-- Name: idx_airport_ownership_requests_airport_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_ownership_requests_airport_code ON public.airport_ownership_requests USING btree (airport_code) WHERE (airport_code IS NOT NULL);
--
-- Name: idx_airport_ownership_requests_airport_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_ownership_requests_airport_id ON public.airport_ownership_requests USING btree (airport_id);
--
-- Name: idx_airport_ownership_requests_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_ownership_requests_created_at ON public.airport_ownership_requests USING btree (created_at);
--
-- Name: idx_airport_ownership_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_ownership_requests_status ON public.airport_ownership_requests USING btree (status);
--
-- Name: idx_airport_ownership_requests_user_airport; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_airport_ownership_requests_user_airport ON public.airport_ownership_requests USING btree (user_id, airport_id) WHERE ((status)::text = 'pending'::text);
--
-- Name: idx_airport_ownership_requests_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_ownership_requests_user_id ON public.airport_ownership_requests USING btree (user_id);
--
-- Name: idx_airport_visitor_photos_airport_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_visitor_photos_airport_code ON public.airport_visitor_photos USING btree (airport_code);
--
-- Name: idx_airport_visitor_photos_airport_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_visitor_photos_airport_id ON public.airport_visitor_photos USING btree (airport_id);
--
-- Name: idx_airport_visitor_photos_uploaded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_visitor_photos_uploaded_at ON public.airport_visitor_photos USING btree (uploaded_at DESC);
--
-- Name: idx_airport_visitor_photos_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airport_visitor_photos_user_id ON public.airport_visitor_photos USING btree (user_id);
--
-- Name: idx_airports_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_city ON public.airports USING btree (city) WHERE (city IS NOT NULL);
--
-- Name: idx_airports_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_country_code ON public.airports USING btree (country_code) WHERE (country_code IS NOT NULL);
--
-- Name: idx_airports_ident; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_ident ON public.airports USING btree (ident);
--
-- Name: idx_airports_ident_ru; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_ident_ru ON public.airports USING btree (ident_ru) WHERE (ident_ru IS NOT NULL);
--
-- Name: idx_airports_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_is_active ON public.airports USING btree (is_active);
--
-- Name: idx_airports_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_location ON public.airports USING gist (point((longitude_deg)::double precision, (latitude_deg)::double precision));
--
-- Name: idx_airports_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_name ON public.airports USING btree (name);
--
-- Name: idx_airports_photos; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_photos ON public.airports USING gin (photos) WHERE ((photos IS NOT NULL) AND (jsonb_array_length(photos) > 0));
--
-- Name: idx_airports_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_region ON public.airports USING btree (region) WHERE (region IS NOT NULL);
--
-- Name: idx_airports_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_airports_type ON public.airports USING btree (type);
--
-- Name: idx_bookings_flight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_flight_id ON public.bookings USING btree (flight_id);
--
-- Name: idx_bookings_passenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_passenger_id ON public.bookings USING btree (passenger_id);
--
-- Name: idx_bookings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_status ON public.bookings USING btree (status);
--
-- Name: idx_feedback_airport_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_airport_code ON public.feedback USING btree (airport_code) WHERE (airport_code IS NOT NULL);
--
-- Name: idx_feedback_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_created_at ON public.feedback USING btree (created_at);
--
-- Name: idx_feedback_flight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_flight_id ON public.feedback USING btree (flight_id) WHERE (flight_id IS NOT NULL);
--
-- Name: idx_feedback_source_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_source_page ON public.feedback USING btree (source_page);
--
-- Name: idx_feedback_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feedback_status ON public.feedback USING btree (status);
--
-- Name: idx_flight_photos_flight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_photos_flight_id ON public.flight_photos USING btree (flight_id);
--
-- Name: idx_flight_photos_uploaded_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_photos_uploaded_by ON public.flight_photos USING btree (uploaded_by);
--
-- Name: idx_flight_questions_answered_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_questions_answered_by_id ON public.flight_questions USING btree (answered_by_id);
--
-- Name: idx_flight_questions_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_questions_author_id ON public.flight_questions USING btree (author_id);
--
-- Name: idx_flight_questions_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_questions_created_at ON public.flight_questions USING btree (created_at);
--
-- Name: idx_flight_questions_flight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_questions_flight_id ON public.flight_questions USING btree (flight_id);
--
-- Name: idx_flight_waypoints_airport_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_waypoints_airport_code ON public.flight_waypoints USING btree (airport_code);
--
-- Name: idx_flight_waypoints_flight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_waypoints_flight_id ON public.flight_waypoints USING btree (flight_id);
--
-- Name: idx_flight_waypoints_sequence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flight_waypoints_sequence ON public.flight_waypoints USING btree (flight_id, sequence_order);
--
-- Name: idx_flights_departure_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flights_departure_date ON public.flights USING btree (departure_date);
--
-- Name: idx_flights_pilot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flights_pilot_id ON public.flights USING btree (pilot_id);
--
-- Name: idx_flights_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_flights_status ON public.flights USING btree (status);
--
-- Name: idx_payments_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_created_at ON public.payments USING btree (created_at);
--
-- Name: idx_payments_period_days; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_period_days ON public.payments USING btree (period_days);
--
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_status ON public.payments USING btree (status);
--
-- Name: idx_payments_subscription_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_subscription_type ON public.payments USING btree (subscription_type);
--
-- Name: idx_payments_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_user_id ON public.payments USING btree (user_id);
--
-- Name: idx_profiles_owned_airports; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_owned_airports ON public.profiles USING gin (owned_airports) WHERE ((owned_airports IS NOT NULL) AND (jsonb_array_length(owned_airports) > 0));
--
-- Name: idx_reviews_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_booking_id ON public.reviews USING btree (booking_id);
--
-- Name: idx_reviews_reply_to_review_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_reply_to_review_id ON public.reviews USING btree (reply_to_review_id) WHERE (reply_to_review_id IS NOT NULL);
--
-- Name: idx_reviews_reviewed_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_reviewed_id ON public.reviews USING btree (reviewed_id);
--
-- Name: idx_subscriptions_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_end_date ON public.subscriptions USING btree (end_date);
--
-- Name: idx_subscriptions_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_is_active ON public.subscriptions USING btree (is_active);
--
-- Name: idx_subscriptions_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_payment_id ON public.subscriptions USING btree (payment_id);
--
-- Name: idx_subscriptions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscriptions_user_id ON public.subscriptions USING btree (user_id);
--
-- Name: normal_categories_main_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX normal_categories_main_category_id ON public.normal_categories USING btree (main_category_id);
--
-- Name: normal_check_list_normal_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX normal_check_list_normal_category_id ON public.normal_check_list USING btree (normal_category_id);
--
-- Name: preflight_inspetion_check_list_preflihgtInspectionCategoryId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "preflight_inspetion_check_list_preflihgtInspectionCategoryId" ON public.preflight_inspection_check_list USING btree (preflight_inspection_category_id);
--
-- Name: airports update_airports_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_airports_updated_at BEFORE UPDATE ON public.airports FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
--
-- Name: bookings update_bookings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
--
-- Name: flight_questions update_flight_questions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_flight_questions_updated_at BEFORE UPDATE ON public.flight_questions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
--
-- Name: flights update_flights_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_flights_updated_at BEFORE UPDATE ON public.flights FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
--
-- Name: subscriptions update_subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_subscriptions_updated_at();
--
-- Name: airport_ownership_requests airport_ownership_requests_airport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_ownership_requests
    ADD CONSTRAINT airport_ownership_requests_airport_id_fkey FOREIGN KEY (airport_id) REFERENCES public.airports(id) ON DELETE CASCADE;
--
-- Name: airport_ownership_requests airport_ownership_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_ownership_requests
    ADD CONSTRAINT airport_ownership_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: airport_ownership_requests airport_ownership_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_ownership_requests
    ADD CONSTRAINT airport_ownership_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: airports airports_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airports
    ADD CONSTRAINT airports_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: bookings bookings_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id) ON DELETE CASCADE;
--
-- Name: bookings bookings_passenger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_passenger_id_fkey FOREIGN KEY (passenger_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: feedback feedback_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id) ON DELETE SET NULL;
--
-- Name: airport_visitor_photos fk_airport_visitor_photos_airport; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_visitor_photos
    ADD CONSTRAINT fk_airport_visitor_photos_airport FOREIGN KEY (airport_id) REFERENCES public.airports(id) ON DELETE CASCADE;
--
-- Name: airport_visitor_photos fk_airport_visitor_photos_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.airport_visitor_photos
    ADD CONSTRAINT fk_airport_visitor_photos_user FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: question_type_certificates fk_question_type_certificates_question; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT fk_question_type_certificates_question FOREIGN KEY (question_id) REFERENCES public.rosaviatest_questions(id) ON DELETE CASCADE;
--
-- Name: question_type_certificates fk_question_type_certificates_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT fk_question_type_certificates_type FOREIGN KEY (type_certificate_id) REFERENCES public.type_certificates(id) ON DELETE CASCADE;
--
-- Name: flight_photos flight_photos_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_photos
    ADD CONSTRAINT flight_photos_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id) ON DELETE CASCADE;
--
-- Name: flight_photos flight_photos_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_photos
    ADD CONSTRAINT flight_photos_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: flight_questions flight_questions_answered_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_questions
    ADD CONSTRAINT flight_questions_answered_by_id_fkey FOREIGN KEY (answered_by_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: flight_questions flight_questions_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_questions
    ADD CONSTRAINT flight_questions_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: flight_questions flight_questions_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_questions
    ADD CONSTRAINT flight_questions_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id) ON DELETE CASCADE;
--
-- Name: flight_waypoints flight_waypoints_flight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flight_waypoints
    ADD CONSTRAINT flight_waypoints_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES public.flights(id) ON DELETE CASCADE;
--
-- Name: flights flights_pilot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pilot_id_fkey FOREIGN KEY (pilot_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: preflight_inspection_categories hand_book_sub_categories_mainCategoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preflight_inspection_categories
    ADD CONSTRAINT "hand_book_sub_categories_mainCategoryId_fkey" FOREIGN KEY (main_category_id) REFERENCES public.hand_book_main_categories(main_category_id);
--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: preflight_inspection_check_list preflight_inspetion_check_lis_preflihgtInspectionCategoryI_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preflight_inspection_check_list
    ADD CONSTRAINT "preflight_inspetion_check_lis_preflihgtInspectionCategoryI_fkey" FOREIGN KEY (preflight_inspection_category_id) REFERENCES public.preflight_inspection_categories(id);
--
-- Name: question_type_certificates question_type_certificates_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_type_certificates
    ADD CONSTRAINT question_type_certificates_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.rosaviatest_category(id) ON DELETE CASCADE;
--
-- Name: reviews reviews_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;
--
-- Name: reviews reviews_reply_to_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reply_to_review_id_fkey FOREIGN KEY (reply_to_review_id) REFERENCES public.reviews(id) ON DELETE CASCADE;
--
-- Name: reviews reviews_reviewed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reviewed_id_fkey FOREIGN KEY (reviewed_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: reviews reviews_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- Name: subscriptions subscriptions_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;
--
-- Name: subscriptions subscriptions_subscription_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscription_type_id_fkey FOREIGN KEY (subscription_type_id) REFERENCES public.subscription_types(id);
--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
--
-- PostgreSQL database dump complete
--

\unrestrict vnMBDtQRgWtn57M4DuScedVVhu8C3SrhAQuILfJktLlaxKlnC0hqidbymp1YQ2z

COMMIT;
