--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 17.0

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
-- Name: customers; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.customers (
    customer_id character varying NOT NULL,
    customer_unique_id character varying(64) NOT NULL,
    customer_zip_code_prefix character varying(6),
    customer_city character varying(128),
    customer_state character varying(32),
    geolocation_id integer
);


ALTER TABLE public.customers OWNER TO brazil_owner;

--
-- Name: geolocation; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.geolocation (
    geolocation_zip_code_prefix character varying(6) NOT NULL,
    geolocation_lat numeric(18,15) NOT NULL,
    geolocation_lng numeric(18,15) NOT NULL,
    geolocation_city character varying(64) NOT NULL,
    geolocation_state character varying(4) NOT NULL,
    geolocation_id integer NOT NULL
);


ALTER TABLE public.geolocation OWNER TO brazil_owner;

--
-- Name: geolocation_geolocation_id_seq; Type: SEQUENCE; Schema: public; Owner: brazil_owner
--

CREATE SEQUENCE public.geolocation_geolocation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.geolocation_geolocation_id_seq OWNER TO brazil_owner;

--
-- Name: geolocation_geolocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: brazil_owner
--

ALTER SEQUENCE public.geolocation_geolocation_id_seq OWNED BY public.geolocation.geolocation_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.order_items (
    order_id character varying(64) NOT NULL,
    order_item_id integer NOT NULL,
    product_id character varying(64) NOT NULL,
    seller_id character varying(64) NOT NULL,
    shipping_limit_date timestamp without time zone NOT NULL,
    price numeric(10,2) NOT NULL,
    freight_value numeric(10,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO brazil_owner;

--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.order_reviews (
    review_id character varying(64) NOT NULL,
    order_id character varying(64) NOT NULL,
    review_score integer,
    review_comment_title character varying(1024),
    review_comment_message character varying(4096),
    review_creation_date date NOT NULL,
    review_answer_timestamp timestamp without time zone NOT NULL
);


ALTER TABLE public.order_reviews OWNER TO brazil_owner;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.orders (
    order_id character varying(64) NOT NULL,
    customer_id character varying(64) NOT NULL,
    order_status character varying(16),
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);


ALTER TABLE public.orders OWNER TO brazil_owner;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.payments (
    order_id character varying(64) NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type character varying(64) NOT NULL,
    payment_installments integer NOT NULL,
    payment_value numeric(10,3) NOT NULL
);


ALTER TABLE public.payments OWNER TO brazil_owner;

--
-- Name: products; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.products (
    product_id character varying(64) NOT NULL,
    product_category_name character varying(64),
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer
);


ALTER TABLE public.products OWNER TO brazil_owner;

--
-- Name: sellers; Type: TABLE; Schema: public; Owner: brazil_owner
--

CREATE TABLE public.sellers (
    seller_id character varying(64) NOT NULL,
    geolocation_id integer
);


ALTER TABLE public.sellers OWNER TO brazil_owner;

--
-- Name: geolocation geolocation_id; Type: DEFAULT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.geolocation ALTER COLUMN geolocation_id SET DEFAULT nextval('public.geolocation_geolocation_id_seq'::regclass);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: geolocation geolocation_pk; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.geolocation
    ADD CONSTRAINT geolocation_pk PRIMARY KEY (geolocation_id);


--
-- Name: order_reviews order_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT order_reviews_pkey PRIMARY KEY (review_id, order_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: order_items pk_order_items; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);


--
-- Name: payments pk_payments; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT pk_payments PRIMARY KEY (order_id, payment_sequential);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: customers fk_customers_geolocation; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_geolocation FOREIGN KEY (geolocation_id) REFERENCES public.geolocation(geolocation_id);


--
-- Name: order_reviews fk_order_reviews_orders; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT fk_order_reviews_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: orders fk_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: order_items fk_orders_items_orders; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_orders_items_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: order_items fk_orders_items_products; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_orders_items_products FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: order_items fk_orders_items_sellers; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_orders_items_sellers FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id);


--
-- Name: payments fk_payments_orders; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payments_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: sellers fk_sellers_geolocation; Type: FK CONSTRAINT; Schema: public; Owner: brazil_owner
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT fk_sellers_geolocation FOREIGN KEY (geolocation_id) REFERENCES public.geolocation(geolocation_id);


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--



