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
-- INTERSECT
-- EXCEPT

--
-- 5. Common Table Expression (CTE)
-- 

-- CTE
-- CTE Recursivo

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
select oid, typname as TIPO
from pg_type;
-- CREATE TABLE
-- CREATE TABLE AS
-- ALTER TABLE
-- DROP y TRUNCATE TABLE