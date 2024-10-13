SELECT version();

-- Comprobar usuario y esquema
SELECT current_user AS mi_login, CURRENT_SCHEMA AS mi_esquema;
-- En adelante cuando veas <<mi_login>> pon el valor que te devuelve la anterior consulta

-- Esquemas a los que puedes acceder (debe aparecer alquila_dvd)
SELECT unnest(current_schemas(true));

-- Comprobar los permisos de acceso al esquema (si no aparece alquila_dvd en la respuesta a la consulta anterior)
SELECT has_schema_privilege('<<mi_login>>', 'alquila_dvd', 'USAGE');
-- Se puede comprobar también los permisos de CREATE objetos en el esquema. Hace falta para crear tablas
SELECT has_schema_privilege('<<mi_login>>', 'alquila_dvd', 'CREATE');
SELECT has_table_privilege('<<mi_login>>', 'alquila_dvd.actor', 'SELECT');
SELECT has_table_privilege('<<mi_login>>', 'alquila_dvd.actor', 'SELECT');

-- Otra forma de ver los permisos del usuario sobre tablas
SELECT *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = '<<mi_login>>';

-- Cómo ver los permisos de usuario sobre el esquema
SELECT n.nspname AS esquema, r.rolname AS rol_usuario,
    has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS crear,
    has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS usar
FROM pg_namespace n
JOIN  pg_roles r ON r.rolname = '<<mi_login>>'
WHERE  n.nspname = 'alquila_dvd';

-- Path (es el orden de búsqueda de los objetos en una consulta)
SHOW search_path;

-- Si no aparece el primero alquila_dvd ejecuta
SET search_path =alquila_dvd, "$user", public;

-- Comprueba de nuevo el esquema que se está utilizando. Ahora debería ser alquila_dvd
SELECT current_user AS mi_login, CURRENT_SCHEMA AS mi_esquema;
--
-- Alguna información para entender el entorno de trabajo
--

-- A. Tablas en el esquema
SELECT table_name 
FROM information_schema.TABLES
WHERE table_catalog='brazil' AND table_schema='alquila_dvd'
ORDER BY table_name;

-- B. Columnas  de una tabla y tipo de datos asociado. 
-- El ejemplo es para la tabla actor que es la que vamos a utilizar en estos ejercicios
SELECT table_name,column_name,data_type,ordinal_position 
FROM information_schema.columns
WHERE table_catalog='brazil' AND table_schema='alquila_dvd'
AND table_name ='actor';

--
-- 10. Gestionando las tablas
--

-- Consulta de propietario de tablas
SELECT n.nspname AS esquema, c.relname AS tabla, r.rolname AS propietario
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.oid = c.relowner
WHERE c.relkind = 'r'  -- se filtran las tablas normales
ORDER BY esquema, tabla;

-- CREATE TABLE
CREATE TABLE IF NOT EXISTS alquila_dvd.mi_film (
	film_id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	title varchar(255) NOT NULL,
	description text NULL,
	release_year alquila_dvd."year" NULL,
	language_id int2 NOT NULL,
	rental_duration int2 DEFAULT 3 NOT NULL,
	rental_rate numeric(4, 2) DEFAULT 4.99 NOT NULL,
	length int2 NULL,
	replacement_cost numeric(5, 2) DEFAULT 19.99 NOT NULL,
	rating alquila_dvd."mpaa_rating" DEFAULT 'G'::mpaa_rating NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	special_features _text NULL,
	fulltext tsvector NOT NULL,
	CONSTRAINT mi_tabla_film_pk PRIMARY KEY (film_id)
);

CREATE TABLE IF NOT EXISTS alquila_dvd.mi_film_actor (
	actor_id int4 NOT NULL,
	film_id int4 NOT NULL,
	last_update timestamp DEFAULT now() NOT NULL,
	CONSTRAINT mi_film_actor_pkey PRIMARY KEY (actor_id, film_id)
);
-- CREATE TABLE AS
CREATE TABLE alquila_dvd.mi_actor AS
	SELECT *
	FROM actor;

-- ALTER TABLE
-- Creamos la PK para mi_actor
ALTER TABLE alquila_dvd.mi_actor ADD CONSTRAINT mi_actor_pk UNIQUE (actor_id);
-- Creamos las FK para mi_film_actor que relaciona mi_actor y mi_film
ALTER TABLE alquila_dvd.mi_film_actor ADD CONSTRAINT mi_film_actor_actor_id_fk FOREIGN KEY (actor_id) REFERENCES alquila_dvd.mi_actor(actor_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE alquila_dvd.mi_film_actor ADD CONSTRAINT mi_film_actor_film_id_fk FOREIGN KEY (film_id) REFERENCES alquila_dvd.mi_film(film_id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- DROP TABLE
DROP TABLE IF EXISTS alquila_dvd.mi_film_actor;
DROP TABLE IF EXISTS alquila_dvd.mi_film CASCADE;
DROP TABLE IF EXISTS alquila_dvd.mi_actor CASCADE;

--
-- 11. Modificando los datos
--


-- INSERT
-- INSERT INTO.. (SELECT…)
-- UPDATE
-- UPDATE JOIN
-- DELETE
-- DELETE JOIN
-- UPSERT
-- MERGE




