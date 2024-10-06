--
-- VERSIÓN DE POSTGRESQL
--
SELECT version();

-- USUARIO
SELECT current_user, session_user;


--
-- TABLA CLIENTES
--
CREATE TABLE IF NOT EXISTS customers(
customer_id VARCHAR(64) NOT NULL,
customer_unique_id VARCHAR(64) NOT NULL,
customer_zip_code_prefix INTEGER,
customer_city VARCHAR(128),
customer_state VARCHAR(32)
-- PRIMARY KEY(customer_id)
);

-- Copia de fichero
-- psql postgresql://brazil_owner:dlESWvUg1LJ8@ep-little-boat-a5v1s5o2.us-east-2.aws.neon.tech/brazil?sslmode=require
-- \copy customers FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_customers_dataset.csv' DELIMITER ',' CSV HEADER

-- Aï¿½adimos PK para probar que estï¿½ OK
ALTER TABLE customers ADD PRIMARY KEY (customer_id);

-- Cambiamos el tipo int4 que configura por defecto al importar
ALTER TABLE customers ALTER COLUMN customer_zip_code_prefix TYPE varchar(6);


--
-- TABLA PEDIDOS
--
CREATE TABLE IF NOT EXISTS orders(
	order_id VARCHAR(64) PRIMARY KEY, 
	customer_id VARCHAR(64) NOT NULL,
	order_status VARCHAR(16),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP,	
	CONSTRAINT fk_orders_customer
      FOREIGN KEY(customer_id) 
        REFERENCES customers(customer_id)
);

-- IMPORTAR DATOS ORDERS
--  \copy orders FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_orders_dataset.csv' DELIMITER ',' CSV HEADER


--
-- TABLA PRODUCTOS
--
CREATE TABLE IF NOT EXISTS products(
	product_id VARCHAR(64) PRIMARY KEY, 
	product_category_name VARCHAR(64),
	product_name_lenght INTEGER,
	product_description_lenght INTEGER,
	product_photos_qty INTEGER,
	product_weight_g INTEGER,
	product_length_cm INTEGER,
	product_height_cm INTEGER,
	product_width_cm INTEGER
);

-- IMPORTAR DATOS products
--  \copy products FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_products_dataset.csv' DELIMITER ',' CSV HEADER

select * from products 
where product_category_name is null;


--
-- TABLA PAGOS
--
CREATE TABLE IF NOT EXISTS payments(
	order_id VARCHAR(64) NOT NULL, 
	payment_sequential INTEGER NOT NULL,
	payment_type VARCHAR(64) NOT NULL,
	payment_installments INTEGER NOT NULL,
	payment_value NUMERIC(10, 3) NOT null,
	CONSTRAINT pk_payments PRIMARY KEY(order_id, payment_sequential)
);


-- IMPORTAR DATOS payments
--  \copy payments FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER

-- Creamos la FK con orders
ALTER TABLE payments 
ADD CONSTRAINT fk_payments_orders 
FOREIGN KEY (order_id) 
REFERENCES orders (order_id);


--
-- TABLA LOCALIZACIONES
--
CREATE TABLE IF NOT EXISTS geolocation(
	geolocation_zip_code_prefix VARCHAR(6) NOT NULL,
	geolocation_lat NUMERIC(18, 15) NOT NULL, 
	geolocation_lng NUMERIC(18, 15) NOT null,
	geolocation_city VARCHAR(64) NOT NULL,
	geolocation_state VARCHAR(4) NOT NULL
);

-- importar datos geolocation
-- \copy geolocation FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_geolocation_dataset.csv' DELIMITER ',' CSV HEADER

-- le aï¿½adimos pk
ALTER TABLE geolocation ADD geolocation_id serial NOT NULL;
ALTER TABLE geolocation ADD CONSTRAINT geolocation_pk PRIMARY KEY (geolocation_id);


--
-- TABLA VENDEDORES
--
CREATE TABLE IF NOT EXISTS sellers(
	seller_id VARCHAR(64) PRIMARY KEY,
	seller_zip_code_prefix  VARCHAR(6) NOT NULL, 
	seller_city VARCHAR(64) NOT NULL,
	seller_state VARCHAR(4) NOT NULL
);

-- importar datos: 
-- \copy sellers FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER

-- Vamos a configurar una FK
ALTER TABLE sellers ADD geolocation_id integer NULL;

update sellers 
set geolocation_id=sub.geolocation_id
from (
	select g.geolocation_id,s.seller_id,count(1)
	from sellers s
	inner join geolocation g on g.geolocation_zip_code_prefix =s.seller_zip_code_prefix
	group by g.geolocation_id,s.seller_id
) sub
where sellers.seller_id=sub.seller_id;

-- Creamos la FK con geolocation
ALTER TABLE sellers 
ADD CONSTRAINT fk_sellers_geolocation 
FOREIGN KEY (geolocation_id) 
REFERENCES geolocation(geolocation_id);

-- Borramos las columnas que rompen las formas normales
ALTER TABLE sellers DROP COLUMN seller_zip_code_prefix;
ALTER TABLE sellers DROP COLUMN seller_city;
ALTER TABLE sellers DROP COLUMN seller_state;

-- Algunos sellers (7) no estï¿½n mapeados con geolocation
select * 
from sellers
where geolocation_id is null;

-- Tambiï¿½n tenemos que corregir customers para hacerla cumplir con la forma normal
-- Vamos a configurar una FK
ALTER TABLE customers ADD geolocation_id integer NULL;

update customers 
set geolocation_id=sub.geolocation_id
from (
	select g.geolocation_id,s.customer_id,count(1)
	from customers s
	inner join geolocation g on g.geolocation_zip_code_prefix=lpad(s.customer_zip_code_prefix,5,'0')
	group by g.geolocation_id,s.customer_id
) sub
where customers.customer_id=sub.customer_id;

-- Hay 278 clientes que no mapean con cï¿½digos de geolocalizaciï¿½n
select customer_zip_code_prefix,customer_city,customer_state,geolocation_id  
from customers
where geolocation_id is null;

-- Creamos la FK con geolocation
ALTER TABLE customers 
ADD CONSTRAINT fk_customers_geolocation 
FOREIGN KEY (geolocation_id) 
REFERENCES geolocation(geolocation_id);


--
-- TABLA LÍNEAS DE PEDIDO
--
CREATE TABLE IF NOT EXISTS order_items(
	order_id VARCHAR(64) NOT NULL, 
	order_item_id INTEGER NOT NULL,
	product_id VARCHAR(64) NOT NULL,
	seller_id VARCHAR(64) NOT NULL,
	shipping_limit_date TIMESTAMP NOT NULL, 
	price NUMERIC(10,2) NOT NULL,
	freight_value NUMERIC(10,2) NOT NULL,
	CONSTRAINT pk_order_items PRIMARY KEY(order_id, order_item_id),
	CONSTRAINT fk_orders_items_orders
      FOREIGN KEY(order_id) 
        REFERENCES orders (order_id),
    CONSTRAINT fk_orders_items_products
      FOREIGN KEY(product_id) 
        REFERENCES products(product_id),
    CONSTRAINT fk_orders_items_sellers
      FOREIGN KEY(seller_id) 
        REFERENCES sellers(seller_id)
);

--
-- TABLA REVISIONES DE PEDIDOS
--

CREATE TABLE IF NOT EXISTS order_reviews(
	review_id VARCHAR(64) NOT NULL,
	order_id VARCHAR(64) NOT NULL, 
    review_score INTEGER,
	review_comment_title VARCHAR(1024),
	review_comment_message VARCHAR(4096),
	review_creation_date DATE  NOT NULL, 
	review_answer_timestamp TIMESTAMP NOT NULL, 
	CONSTRAINT fk_order_reviews_orders
      FOREIGN KEY(order_id) 
        REFERENCES orders (order_id)
);

-- Se cargan datos
-- \copy order_reviews FROM 'C:\TRABAJO\PLEXUS\DataLab\Datasets_testing\archive\olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER

ALTER TABLE order_reviews ADD PRIMARY KEY (review_id,order_id);

-- Hay repetidos en review_id
select review_id,count(1)
from order_reviews
group by review_id
having count(1)>1;

-- Identificamos con consulta CTE las lï¿½neas duplicadas
select * from (
	SELECT review_id,review_creation_date,ROW_NUMBER() OVER( PARTITION BY review_id ORDER BY  review_creation_date DESC ) AS row_num
	FROM order_reviews 
) filas 
where filas.row_num>1;

-- Se ve que en la PK debe entrar order_id
select * from order_reviews 
where review_id='00130cbe1f9d422698c812ed8ded1919';

select review_id,order_id,count(1)
from order_reviews
group by review_id,order_id
having count(1)>1;

-- Para obtener diagrama con dbdiagram.io
-- pg_dump -h ep-little-boat-a5v1s5o2.us-east-2.aws.neon.tech -p 5432 -d brazil -U brazil_owner -s -F p -E UTF-8 -f brasil_ecomm_ddl_20241002.sql

-- Copia de Seguridad
-- pg_dump -h ep-little-boat-a5v1s5o2.us-east-2.aws.neon.tech -p 5432 -d brazil -U brazil_owner -f brazil_ecomm_20241002.sql

-- Restaurar
-- pg_restore -h ep-little-boat-a5v1s5o2.us-east-2.aws.neon.tech -p 5432 -d brazil_new -U brazil_new_owner -1 brazil_ecomm_20241001.sql


--
-- CREACIÃ“N DE USUARIOS DE CONSULTA
--

-- Comprobamos los usuarios y roles existentes

select * from pg_user;
select * from pg_roles;
select * from pg_authid;

select *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'brazil_owner';

-- Para borrar un role, hay que eliminar todas sus dependencias
-- Esto afecta a cualquier objeto de base de datos que sea de su propiedad
-- También a los permisos. Por eso hay que revocarlos

-- Revocar todos los privilegios en el esquema public
REVOKE ALL PRIVILEGES ON
SCHEMA public
FROM uie_consultas;

-- Revocar todos los privilegios sobre tablas en el esquema public
REVOKE ALL PRIVILEGES ON
ALL TABLES
IN SCHEMA "public"
FROM uie_consultas;

-- Verificar si existen usaurios que hereden (sin ser el admin) y revocar permiso
SELECT u.usename,r.rolname
FROM pg_user u
JOIN pg_auth_members m ON u.usesysid = m.member
JOIN pg_roles r ON r.oid = m.roleid
where r.rolname='uie_consultas';

REVOKE uie_consultas FROM uie_alumno;

-- Ahora se puede borrar el rol. Ojo, es posible que haya otros usuarios con este rol y tengamos que REVOCAR
DROP ROLE uie_consultas;

-- Creación de rol para permisos.
CREATE ROLE uie_consultas WITH PASSWORD '#uie_consultas1';
-- Consultamos los roles existentes para verificar que no se puede conectar a la base de datos 
select rolname,rolcanlogin 
from pg_roles
where rolname like 'uie_%';
-- Comprobamos que no tiene permisos
SELECT *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_consultas';
-- Le damos permisos de lectura sobre las tablas
GRANT SELECT
ON ALL TABLES 
IN SCHEMA "public" 
TO uie_consultas;

-- Intentamos conectar
-- No nos deja conectar 


SELECT current_user, session_user;

-- Creamos un usuario/rol con permiso de login
CREATE ROLE uie_alumno LOGIN PASSWORD 'uie_20241002';
-- En postgresql cuando se crea un ROL, automáticamente se crea un usuario con el mismo nombre. 
-- CREATE USER es un alias de CREATE ROL y también se crea el ROL asociado.
-- 
-- Si queremos dar permisos de LOGIN a un usuario que no lo tiene
-- ALTER ROLE uie_alumno WITH LOGIN;
-- Con este permiso se puede conectar, pero no puede realizar consultas
select * from pg_roles
where rolname='uie_alumno';

SELECT *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_alumno';

-- Ahora asociamos al usuario al ROL uie_consultas
GRANT uie_consultas TO uie_alumno;

-- Vemos que no tiene permisos para uie_alumno, pero comprobamos que está asociado al rol que permite consultar
SELECT u.usename,r.rolname
FROM pg_user u
JOIN pg_auth_members m ON u.usesysid = m.member
JOIN pg_roles r ON r.oid = m.roleid
where r.rolname='uie_consultas';


-- Limpiamos todos los usuarios creados para la demo
DROP ROLE uie_alumno;

REVOKE ALL PRIVILEGES ON
SCHEMA "public"
FROM uie_consultas;

DROP ROLE uie_consultas;





