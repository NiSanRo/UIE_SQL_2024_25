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

-- INNER JOIN
-- LEFT JOIN
-- RIGHT JOIN
-- SELF-JOIN
-- FULL OUTER JOIN



--
-- 7. SUBQUERY
-- 

-- Subquery
-- Correlated Subquery
-- ANY Operator
-- ALL Operator
-- EXISTS Operator

--
-- 8. Expresiones condicionales y Operadores
--

-- CASE … WHEN… ELSE.. END
-- COALESCE
-- NULLIF
-- CAST

--
-- 9. Funciones de Ventana
--

-- OVER 
-- PARTITION

--
-- 10. Modificando los datos
--

-- INSERT
-- INSERT INTO.. (SELECT…)
-- UPDATE
-- UPDATE JOIN
-- DELETE
-- DELETE JOIN
-- UPSERT
-- MERGE

--
-- 11. Gestionando las tablas
--

-- Tipos de datos
-- CREATE TABLE


-- CREATE TABLE AS

-- ALTER TABLE


-- DROP y TRUNCATE TABLE
TRUNCATE [ TABLE ] [ ONLY ] name [ * ] [, ... ]
    [ RESTART IDENTITY | CONTINUE IDENTITY ] [ CASCADE | RESTRICT ]

