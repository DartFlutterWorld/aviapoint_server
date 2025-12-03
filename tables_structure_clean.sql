-- PostgreSQL database dump
-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14
-- Name: payments; Type: TABLE; Schema: public; Owner: -

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
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    payment_id character varying(255) NOT NULL,
    subscription_type_id integer NOT NULL,
    period_days integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount integer NOT NULL
);
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);
-- Name: idx_payments_created_at; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_payments_created_at ON public.payments USING btree (created_at);
-- Name: idx_payments_period_days; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_payments_period_days ON public.payments USING btree (period_days);
-- Name: idx_payments_status; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_payments_status ON public.payments USING btree (status);
-- Name: idx_payments_subscription_type; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_payments_subscription_type ON public.payments USING btree (subscription_type);
-- Name: idx_payments_user_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_payments_user_id ON public.payments USING btree (user_id);
-- Name: idx_subscriptions_end_date; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_subscriptions_end_date ON public.subscriptions USING btree (end_date);
-- Name: idx_subscriptions_is_active; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_subscriptions_is_active ON public.subscriptions USING btree (is_active);
-- Name: idx_subscriptions_payment_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_subscriptions_payment_id ON public.subscriptions USING btree (payment_id);
-- Name: idx_subscriptions_user_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_subscriptions_user_id ON public.subscriptions USING btree (user_id);
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
-- Name: subscriptions subscriptions_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;
-- Name: subscriptions subscriptions_subscription_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscription_type_id_fkey FOREIGN KEY (subscription_type_id) REFERENCES public.subscription_types(id);
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
-- PostgreSQL database dump complete
