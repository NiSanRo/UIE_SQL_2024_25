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
-- 1. Consultando los datos
-- 

-- Devuelve todas las filas y todas las columnas
SELECT *
FROM  geolocation g;

-- Devuelve todas las filas, pero sólo un subconjunto de las columnass
SELECT geolocation_city, geolocation_state, geolocation_zip_code_prefix 
FROM geolocation g;

-- Alias de columnas
SELECT geolocation_city AS Ciudad, geolocation_state AS Provincia, geolocation_zip_code_prefix AS CodPostal  
FROM geolocation g;

-- Order by
SELECT    geolocation_city AS Ciudad, geolocation_state AS Provincia, geolocation_zip_code_prefix AS CodPostal   
FROM   geolocation g 
ORDER BY  Ciudad ASC, codpostal DESC;

-- DISTINCT
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia, geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC;

--
-- 2. Filtrando los datos
-- 

-- WHERE
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
WHERE geolocation_city='abreu e lima'
ORDER BY Ciudad ASC, codpostal DESC;


-- Operadores lógicos (AND y OR)
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
WHERE geolocation_city='abreu e lima' AND geolocation_zip_code_prefix='53560'
ORDER BY Ciudad ASC, codpostal DESC;

-- Condiciones anidadas
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
WHERE (geolocation_city='sao paulo' AND geolocation_state='04843')
OR (geolocation_zip_code_prefix='55890' OR geolocation_zip_code_prefix='04843')
ORDER BY Ciudad ASC, codpostal DESC;

-- LIMIT
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC
LIMIT 3;

-- FETCH
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC
FETCH FIRST 3 ROWS ONLY;

SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC
FETCH FIRST 5 ROWS ONLY;

[ OFFSET row_to_skip { ROW | ROWS } ]
FETCH { FIRST | NEXT } [ row_count ] { ROW | ROWS } ONLY

SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC
OFFSET 2 ROWS 
FETCH FIRST 3 ROW ONLY; 

SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
ORDER BY Ciudad ASC, codpostal DESC
FETCH NEXT 5 ROWS ONLY;

-- IN
SELECT DISTINCT geolocation_city AS Ciudad, geolocation_state AS Provincia,
geolocation_zip_code_prefix AS CodPostal 
FROM geolocation g 
WHERE geolocation_city IN ('acarau','acegua')
ORDER BY Ciudad ASC, codpostal DESC;

-- BETWEEN

SELECT product_id AS Producto,price AS Precio,shipping_limit_date  AS Fecha_Limite
FROM order_items
WHERE price BETWEEN 200 AND 219.99
ORDER BY Precio DESC, Producto ASC;

SELECT product_id AS Producto,price AS Precio,shipping_limit_date  AS Fecha_Limite
FROM order_items
WHERE shipping_limit_date BETWEEN '2017-06-01 14:00:00' AND '2017-06-01 23:59:59'
ORDER BY Precio DESC, Producto ASC;

-- LIKE
SELECT product_id AS Producto,price AS Precio,shipping_limit_date  AS Fecha_Limite
FROM order_items
WHERE shipping_limit_date BETWEEN '2017-06-01 14:00:00' AND '2017-06-01 23:59:59'
AND (product_id LIKE '%3118%' OR product_id LIKE '%70a4')
ORDER BY Precio DESC, Producto ASC;

SELECT product_id AS Producto,price AS Precio,shipping_limit_date  AS Fecha_Limite
FROM order_items
WHERE shipping_limit_date BETWEEN '2017-06-01 14:00:00' AND '2017-06-01 23:59:59'
AND (product_id LIKE '%3118?' OR product_id LIKE '%70a4')
ORDER BY Precio DESC, Producto ASC;

-- IS NULL, IS NOT NULL

SELECT * FROM information_schema.COLUMNS
WHERE table_schema='public' AND is_nullable='YES'

SELECT order_id AS Pedido,order_status  AS Estado,
order_purchase_timestamp AS Fecha_Pedido,
order_approved_at AS Fecha_Aprobacion
FROM orders 
WHERE order_approved_at  IS NULL
ORDER BY Fecha_Pedido DESC;

SELECT order_id AS Pedido,order_status AS Estado,
order_purchase_timestamp AS Fecha_Pedido,
order_approved_at AS Fecha_Aprobacion
FROM orders 
WHERE order_approved_at IS NOT NULL
AND order_approved_at BETWEEN  '2018-09-03 00:00:00' 
AND  '2018-09-03 23:59:59'
ORDER BY Fecha_Pedido DESC;

-- 
-- 3. Agrupando los datos
-- 

-- GROUP BY
SELECT order_status AS Estado
FROM orders 
WHERE 
order_approved_at BETWEEN  '2017-01-01 00:00:00' 
AND  '2024-09-30 23:59:59'
GROUP BY Estado
ORDER BY Estado DESC;

SELECT order_status AS Estado, count(1) AS Registros
FROM orders 
WHERE 
order_approved_at BETWEEN  '2017-01-01 00:00:00' 
AND  '2024-09-30 23:59:59'
GROUP BY Estado
ORDER BY Estado DESC;

SELECT product_category_name AS Categoria,
product_photos_qty AS Num_Fotos,
product_width_cm AS Largo_Nombre,
COUNT(1) AS Registros
FROM products p
GROUP BY Categoria,Num_Fotos,Largo_Nombre
ORDER BY Categoria ASC,Num_Fotos ASC;

-- HAVING
SELECT order_status AS Estado, count(1) AS Registros
FROM orders 
WHERE order_approved_at 
BETWEEN  '2017-01-01 00:00:00'  AND  '2024-09-30 23:59:59'
GROUP BY Estado
HAVING count(1) BETWEEN 200 AND 299
ORDER BY Estado DESC;

-- GROUPING SETS
SELECT GROUPING(product_category_name) AS Grouping_Categoria,
GROUPING(product_photos_qty) AS Grouping_Num_Fotos,
product_category_name AS Categoria,
product_photos_qty AS Num_Fotos,
COUNT(1) AS Registros
FROM products p
GROUP BY 
		GROUPING SETS (  (Categoria,Num_Fotos),(Categoria),(Num_Fotos),()  )
ORDER BY Categoria ASC,Num_Fotos ASC;

-- CUBE 
SELECT product_category_name AS Categoria,
product_photos_qty AS Num_Fotos,
COUNT(1) AS Registros
FROM products p
GROUP BY 
		CUBE (Categoria,Num_Fotos)
ORDER BY Categoria ASC,Num_Fotos ASC;  
   
-- ROLL UP
SELECT product_category_name AS Categoria,
product_photos_qty AS Num_Fotos,
COUNT(1) AS Registros
FROM products p
GROUP BY 
		CUBE (Categoria,Num_Fotos)
ORDER BY Categoria ASC,Num_Fotos ASC;  

--
-- 4. Operaciones SET
-- 

-- UNION
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_approved_at 
BETWEEN  '2017-09-01 00:00:00'  AND  '2017-09-30 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
UNION
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_status='shipped' 
AND order_approved_at 
BETWEEN  '2017-08-01 00:00:00'  AND  '2017-08-31 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
ORDER BY Estado_Pedido DESC,Fecha_Aprobacion ASC;

-- INTERSECT
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_approved_at 
BETWEEN  '2017-08-15 00:00:00'  AND  '2017-09-30 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
INTERSECT 
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_status='shipped' 
AND order_approved_at 
BETWEEN  '2017-08-01 00:00:00'  AND  '2017-08-31 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
ORDER BY Estado_Pedido DESC,Fecha_Aprobacion ASC;

-- EXCEPT
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_status='shipped' 
AND order_approved_at 
BETWEEN  '2017-08-01 00:00:00'  AND  '2017-08-31 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
EXCEPT
SELECT order_status as Estado_Pedido,
TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
count(1) AS Registros
FROM orders 
WHERE order_approved_at 
BETWEEN  '2017-08-15 00:00:00'  AND  '2017-09-30 23:59:59'
GROUP BY Estado_Pedido,Fecha_Aprobacion
ORDER BY Estado_Pedido DESC,Fecha_Aprobacion ASC;

--
-- 5. Common Table Expression (CTE)
-- 

-- CTE
WITH pedidos_shipped AS (
	SELECT order_status as Estado_Pedido,	TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
	count(1) AS Registros
	FROM orders 
	WHERE order_status='shipped' 
	AND order_approved_at 	BETWEEN  '2017-08-01 00:00:00'  AND  '2017-08-31 23:59:59'
	GROUP BY Estado_Pedido,Fecha_Aprobacion
),
pedidos_todos AS(
	SELECT order_status as Estado_Pedido,	TO_CHAR(order_approved_at, 'dd/mm/yyyy') AS Fecha_Aprobacion,
	count(1) AS Registros
	FROM orders 
	WHERE order_approved_at 	BETWEEN  '2017-08-15 00:00:00'  AND  '2017-09-30 23:59:59'
	GROUP BY Estado_Pedido,Fecha_Aprobacion
)
SELECT Estado_Pedido, Fecha_Aprobacion,Registros
FROM pedidos_shipped
EXCEPT
SELECT Estado_Pedido, Fecha_Aprobacion,Registros
FROM pedidos_todos
ORDER BY Estado_Pedido DESC,Fecha_Aprobacion ASC;

-- CTE Recursivo

-- En la tabla customers tenemos una jerarquía con CUSTOMER_ID
SELECT customer_unique_id,count(1) AS Registros
FROM customers
GROUP BY customer_unique_id
HAVING count(1)>=4; 

WITH RECURSIVE customer_parent  AS (
	SELECT customer_id,customer_unique_id
	FROM customers
    WHERE customer_unique_id IN 
    	('63cfc61cee11cbe306bff5857d00bfe4','b2bd387fdc3cf05931f0f897d607dc88','a239b8e2fbce33780f1f1912e2ee5275','56c8638e7c058b98aae6d74d2dd6ea23')
	UNION 
	SELECT c.customer_id,c.customer_unique_id
	FROM customers c
	INNER JOIN customer_parent p ON p.customer_unique_id=c.customer_unique_id AND p.customer_unique_id<>c.customer_id
)
SELECT * FROM customer_parent
ORDER BY customer_unique_id ASC;

--
--  6. Combinando Tablas
-- 

-- LISTADO DE TABLAS y CAMPOS PK (sólo muestra los datos para aquellas tablas en las que se es propietario)
SELECT n.nspname AS esquema, r.rolname AS propietario_tabla, c.relname AS tabla,
   	 p.conname AS nombre_pk, a.attname AS nombre_columna
FROM pg_constraint p
JOIN pg_attribute a ON a.attnum = ANY(p.conkey) AND a.attrelid = p.conrelid
JOIN pg_class c ON c.oid = p.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.oid = c.relowner
WHERE  n.nspname::text = 'alquila_dvd'  -- Hay que hacer un CAST para poder comparar
AND p.contype = 'p'; -- Para PK

-- LISTADO DE RELACIONES
SELECT n.nspname AS esquema_fk, c.relname AS tabla_fk, fk.conname AS nombre_fk,a.attname AS columna_fk,
    n2.nspname AS esquema_pk, c2.relname AS tabla_pk, pk.conname AS nombre_pk, a2.attname AS columna_pk
FROM pg_constraint fk
JOIN pg_attribute a ON a.attnum = ANY(fk.conkey) AND a.attrelid = fk.conrelid
JOIN pg_class c ON c.oid = fk.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_constraint pk ON pk.conrelid = fk.confrelid AND pk.contype = 'p'  -- Primary key constraint
JOIN pg_attribute a2 ON a2.attnum = ANY(pk.conkey) AND a2.attrelid = pk.conrelid
JOIN pg_class c2 ON c2.oid = pk.conrelid
JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
WHERE  fk.contype = 'f'  -- 'f' es para clave FK
    AND n.nspname::text = 'alquila_dvd'  -- Hay que hacer un CAST para poder comparar
ORDER BY esquema_fk, tabla_fk,nombre_fk, columna_fk;

-- INNER JOIN
-- Devuelve los registros coincidentes (se comprueba el ON) entre ambas tablas
-- Listado de películas que tenemos en el inventario en las que participa Cuba Olivier
SELECT a.first_name AS nombre, a.last_name AS apellido, f.title AS pelicula
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id =a.actor_id 
INNER JOIN film f ON f.film_id =fa.film_id 
WHERE UPPER(a.first_name) ='CUBA' AND UPPER(last_name)='OLIVIER' ;

-- Usando cláusula USING
SELECT a.first_name AS nombre, a.last_name AS apellido, f.title AS pelicula
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id =a.actor_id 
INNER JOIN film f USING(film_id) 
WHERE UPPER(a.first_name) ='CUBA' AND UPPER(last_name)='OLIVIER' ;



-- LEFT JOIN
-- Devuelve todos los registros de la primera tabla (izquierda) que tengan o no valore coincidentes en la segunda (derecha)
SELECT a.first_name AS nombre, a.last_name AS apellido, f.title AS pelicula
FROM actor a 
LEFT JOIN film_actor fa ON fa.actor_id =a.actor_id 
LEFT JOIN film f ON f.film_id =fa.film_id 
WHERE UPPER(a.first_name) ='CUBA' OR UPPER(a.first_name) IN ('ANTONIO' ,'LUIS','MALENA')
ORDER BY nombre DESC;

-- Listar aquellos actores para los que no tenemos ninguna película en el inventario
SELECT a.actor_id,a.first_name AS nombre, a.last_name AS apellido, fa.actor_id 
FROM actor a 	
LEFT JOIN film_actor fa ON fa.actor_id =a.actor_id 
WHERE fa.actor_id IS NULL; 

-- RIGHT JOIN
-- Devuelve el listado de actores en las películas 'AIRBAG' ,'BUTCH PANTHER','AFRICAN EGG'
SELECT  f.title AS pelicula,a.first_name AS nombre_actor, a.last_name AS apellido_actor
FROM actor a 
RIGHT JOIN film_actor fa ON fa.actor_id =a.actor_id 
RIGHT JOIN film f ON f.film_id =fa.film_id 
WHERE UPPER(f.title) IN ('AIRBAG' ,'BUTCH PANTHER','AFRICAN EGG')
ORDER BY pelicula DESC,nombre_actor ASC, apellido_actor ASC;

-- Devuelve el listado de películas para el que no se tiene información del reparto
SELECT  f.title AS pelicula,fa.actor_id 
FROM film_actor fa  
RIGHT JOIN film f ON f.film_id =fa.film_id 
WHERE fa.actor_id IS NULL 
ORDER BY pelicula DESC;

-- FULL OUTER JOIN
-- Devuelve el listado de actores y películas para los que, o bien no hay ninguna película en la que participe, 
-- o no tenga reparto asociado.
SELECT  f.title AS pelicula,a.first_name AS nombre_actor, a.last_name AS apellido_actor
FROM actor a 
FULL OUTER JOIN film_actor fa ON fa.actor_id =a.actor_id 
FULL OUTER JOIN film f ON f.film_id =fa.film_id 
WHERE fa.actor_id IS NULL OR fa.film_id IS NULL
ORDER BY pelicula DESC,nombre_actor ASC, apellido_actor ASC;

-- CROSS JOIN
-- Combinar todos los valores de actores y películas.
SELECT  a.*,f.*
FROM actor a 
CROSS JOIN film f  
ORDER BY a.actor_id,a.last_name;

-- SELF-JOIN
-- Devolver el listado de películas (títulos y duración) con idéntica duración.
-- Mostrar los resultados ordenados de menor a mayor duración.
SELECT f.title AS titulo_1, f2.title AS titulo_2,  f.length AS duracion 
FROM film f
INNER JOIN film f2 ON f.film_id <> f2.film_id 
AND f.length = f2.length
ORDER BY duracion,titulo_1,titulo_2;

-- Sin repetidos
SELECT f.title AS titulo_1, f2.title AS titulo_2,  f.length AS duracion 
FROM film f
INNER JOIN film f2 ON f.film_id < f2.film_id 
AND f.length = f2.length
ORDER BY duracion,titulo_1,titulo_2;

-- NATURAL JOIN
-- Comprobación de tipos de columnas para columnas con nombre coincidente
WITH columnas AS (
	SELECT table_name AS tabla,column_name AS columna,data_type AS tipo_dato 
	FROM information_schema.COLUMNS
	WHERE table_catalog='brazil' AND table_schema='alquila_dvd'
)
SELECT c1.tabla AS tabla_1,c2.tabla AS tabla_2,c1.columna AS columna_1,c2.columna AS columna_2,
c1.tipo_dato AS tipo_dato_1, c2.tipo_dato AS tipo_dato_2
FROM columnas c1
INNER JOIN columnas c2 ON c1.tabla<>c2.tabla AND c1.columna=c2.columna
WHERE c1.columna ='address_id' OR c1.columna ='actor_id' 
ORDER BY columna_1;

-- Comparación de columnas para dos tablas
WITH columnas AS (
	SELECT table_name AS tabla,column_name AS columna,data_type AS tipo_dato 
	FROM information_schema.COLUMNS
	WHERE table_catalog='brazil' AND table_schema='alquila_dvd'
)
SELECT c1.tabla AS tabla_1,c2.tabla AS tabla_2,c1.columna AS columna_1,c2.columna AS columna_2,
c1.tipo_dato AS tipo_dato_1, c2.tipo_dato AS tipo_dato_2
FROM columnas c1
INNER JOIN columnas c2 ON c1.tabla<>c2.tabla AND c1.columna=c2.columna
WHERE c1.tabla ='customer' AND c2.tabla ='staff' 
ORDER BY columna_1;

-- No cruza porque los tipos de datos son diferentes
SELECT a.first_name AS nombre_actor, a.last_name AS apellido_actor 
FROM actor a 
NATURAL JOIN film_actor fa;

-- Existe cruce
SELECT c.first_name AS nombre_cliente,c.last_name AS apellido_cliente,
s.first_name AS nombre_empleado, s.last_name AS apellido_empleado
FROM customer c
NATURAL JOIN staff s;

-- JOIN CON USING
SELECT a.first_name AS nombre_actor, a.last_name AS apellido_actor, fa.film_id 
FROM actor a 
JOIN film_actor fa USING (actor_id);

-- Usando NATURAL no devuelve nada por que los tipos de datos son diferentes
SELECT a.first_name AS nombre_actor, a.last_name AS apellido_actor, fa.film_id 
FROM actor a 
NATURAL JOIN film_actor fa;

-- ANTI - JOIN
-- Listar aquellos actores para los que no tenemos ninguna película en el inventario 
-- y las películas para que no tenemos ningún actor del reparto
SELECT  f.title AS pelicula,a.first_name AS nombre_actor, a.last_name AS apellido_actor
FROM actor a 
FULL OUTER JOIN film_actor fa ON fa.actor_id =a.actor_id 
FULL OUTER JOIN film f ON f.film_id =fa.film_id 
WHERE fa.actor_id IS NULL OR fa.film_id IS NULL
ORDER BY pelicula DESC,nombre_actor ASC, apellido_actor ASC;

-- ANTI SEMI JOIN
-- Listar aquellos actores para los que no tenemos ninguna película en el inventario
SELECT a.actor_id,a.first_name AS nombre, a.last_name AS apellido, fa.actor_id 
FROM actor a 	
LEFT JOIN film_actor fa ON fa.actor_id =a.actor_id 
WHERE fa.actor_id IS NULL; 

--
-- 7. SUBQUERY
-- 

-- Subquery
-- Listado de películas en las que en el reparto interviene algún actor con nombre que empieza por HUM
SELECT f.title AS pelicula,a.first_name  AS nombre,a.last_name AS Apellido
FROM actor a 
INNER JOIN film_actor fa ON a.actor_id =fa.actor_id 
INNER JOIN film f ON fa.film_id =f.film_id 
WHERE a.actor_id IN (
	SELECT actor_id 
	FROM actor a 
	WHERE UPPER(a.first_name) LIKE 'HUM%'
)
ORDER BY pelicula;

--SUBQUERY CORRELADA
-- Listar las películas que tienen más duración que el promedio para su clasificación
SELECT title AS pelicula, length AS duracion, rating AS clasificacion
FROM film f
WHERE length > (
    SELECT AVG(length)
    FROM film
    WHERE rating = f.rating
);

-- ANY Operator
SELECT customer_id,count(1) AS coincidencias 
FROM rental  
WHERE inventory_id = ANY(
	SELECT   r.inventory_id  
	FROM customer c 
	INNER JOIN rental r ON c.customer_id =r.customer_id 
	WHERE upper(c.first_name)='BRIAN' AND upper(c.last_name)='WYMAN'
)
GROUP BY customer_id 
ORDER BY coincidencias DESC;

WITH  cluster_brian_wyman AS (
	SELECT customer_id 
	FROM rental  
	WHERE inventory_id = ANY(
		SELECT   r.inventory_id  
		FROM customer c 
		INNER JOIN rental r ON c.customer_id =r.customer_id 
		WHERE upper(c.first_name)='BRIAN' AND upper(c.last_name)='WYMAN'
	)
)
SELECT c.first_name AS nombre,c.last_name AS apellido,count(1) AS coincidencias
FROM customer c
INNER JOIN cluster_brian_wyman cb ON c.customer_id=cb.customer_id
WHERE UPPER(c.first_name)<>'BRIAN' OR upper(c.last_name)<>'WYMAN'
GROUP BY nombre,apellido
ORDER BY coincidencias DESC;

-- ALL Operator
-- igual que el ANY

-- EXISTS Operator
-- Comprobar que clientes han realizado al menos un pago con un importe superior a 7
SELECT customer_id,first_name AS nombre,  last_name AS apellido
FROM customer c 
WHERE 
  EXISTS (
    SELECT 1 
    FROM payment p 
    WHERE p.customer_id = c.customer_id 
      AND amount > 7
  ) 
ORDER BY customer_id ;

SELECT count(1) 
FROM payment p 
WHERE customer_id =1 
AND amount >7;

-- Clientes que nunca han hecho un pago por encima de 7
SELECT customer_id,first_name AS nombre,  last_name AS apellido
FROM customer c 
WHERE 
  NOT EXISTS (
    SELECT 1 
    FROM payment p 
    WHERE p.customer_id = c.customer_id 
      AND amount > 7
  ) 
ORDER BY customer_id ;

SELECT count(1) 
FROM payment p 
WHERE customer_id =38 
AND amount >7;

--
-- 8. Expresiones condicionales y Operadores
--

-- CASE … WHEN… ELSE.. END

-- Moda en el número de alquileres
WITH alquileres AS (
	SELECT c.customer_id,count(1) AS alquileres 
	FROM customer c 
	INNER JOIN rental r ON c.customer_id =r.customer_id
	GROUP BY c.customer_id 
)
SELECT MODE() WITHIN GROUP (ORDER BY alquileres)
FROM alquileres;

-- Tipología
WITH alquileres AS (
	SELECT c.customer_id,count(1) AS alquileres 
	FROM customer c 
	INNER JOIN rental r ON c.customer_id =r.customer_id
	GROUP BY c.customer_id 
)
SELECT c.first_name AS nombre, c.last_name AS apellido,a.alquileres,
CASE 
	WHEN a.alquileres < 22 THEN 'OCASIONALES' 
	WHEN a.alquileres>=22 AND a.alquileres <31 THEN 'RECURRENTES'  
	ELSE 'VIP'
END AS Tipo_Cliente
FROM customer c 
INNER JOIN alquileres a ON c.customer_id =a.customer_id
ORDER BY alquileres DESC, nombre ASC, apellido ASC;

-- COALESCE

-- Cálculo con valores NULOS, no los tiene en cuenta
WITH pagos AS (
	SELECT c.customer_id,sum(p.amount) AS total_compras 
	FROM customer c 
	LEFT JOIN rental r ON c.customer_id =r.customer_id
	LEFT JOIN payment p ON r.rental_id =p.rental_id 
	GROUP BY c.customer_id 
)
SELECT AVG(total_compras)
FROM pagos;

-- Cálculo con COALESCE para poner nulos a 0
WITH pagos AS (
	SELECT c.customer_id,sum(COALESCE(p.amount,0)) AS total_compras 
	FROM customer c 
	LEFT JOIN rental r ON c.customer_id =r.customer_id
	LEFT JOIN payment p ON r.rental_id =p.rental_id 
	GROUP BY c.customer_id 
)
SELECT AVG(total_compras)
FROM pagos;

-- NULLIF
-- Ratio de clientes con activebool TRUE frente a FALSE
SELECT SUM(CASE WHEN activebool= TRUE THEN 1 ELSE 0 END) AS verdadero,
SUM(CASE WHEN activebool= FALSE THEN 1 ELSE 0 END) AS falso,
SUM(CASE WHEN activebool= TRUE THEN 1 ELSE 0 END)/SUM(CASE WHEN activebool= FALSE THEN 1 ELSE 0 END) AS ratio
FROM customer; 

-- Con NULLIF para evitar division por 0
SELECT SUM(CASE WHEN activebool= TRUE THEN 1 ELSE 0 END) AS verdadero,
SUM(CASE WHEN activebool= FALSE THEN 1 ELSE 0 END) AS falso,
SUM(CASE WHEN activebool= TRUE THEN 1 ELSE 0 END)/NULLIF( SUM(CASE WHEN activebool= FALSE THEN 1 ELSE 0 END), 0) AS ratio
FROM customer; 

-- CAST
SELECT  category_id, CAST(category_id AS NUMERIC(10,2)) AS category_id_float
FROM category;

--
-- 9. Funciones de Ventana
--

-- OVER 
WITH compras AS (
	SELECT c.store_id,c.customer_id,
	sum(COALESCE(p.amount,0))  AS total_compras
	FROM customer c 
	LEFT JOIN rental r ON c.customer_id =r.customer_id
	LEFT JOIN payment p ON r.rental_id =p.rental_id
	GROUP BY c.store_id,c.customer_id
)
SELECT store_id,customer_id,total_compras,
RANK() OVER (ORDER BY total_compras DESC) AS ranking_ventas
FROM compras
ORDER BY ranking_ventas;

-- PARTITION
-- Ranking de clientes por total de compras y por tienda
WITH compras AS (
	SELECT c.store_id,c.customer_id,
	sum(COALESCE(p.amount,0))  AS total_compras
	FROM customer c 
	LEFT JOIN rental r ON c.customer_id =r.customer_id
	LEFT JOIN payment p ON r.rental_id =p.rental_id
	GROUP BY c.store_id,c.customer_id
)
SELECT store_id,customer_id,total_compras,
RANK() OVER (PARTITION BY store_id ORDER BY total_compras DESC) AS ranking_ventas
FROM compras;
ORDER BY ranking_ventas;

-- Rankint total y parcial, promedio parcial y máximo y mínimo parcial
WITH compras AS (
	SELECT c.store_id,c.customer_id,
	sum(COALESCE(p.amount,0))  AS total_compras
	FROM customer c 
	LEFT JOIN rental r ON c.customer_id =r.customer_id
	LEFT JOIN payment p ON r.rental_id =p.rental_id
	GROUP BY c.store_id,c.customer_id
)
SELECT store_id,customer_id,total_compras,
RANK() OVER (ORDER BY total_compras DESC) AS ranking_total,
RANK() OVER (PARTITION BY store_id ORDER BY total_compras DESC) AS ranking_tienda,
MAX(total_compras) OVER (PARTITION BY store_id) AS mayor_tienda,
AVG(total_compras) OVER (PARTITION BY store_id) AS media_tienda,
MIN(total_compras) OVER (PARTITION BY store_id) AS menor_tienda
FROM compras
ORDER BY ranking_total;
