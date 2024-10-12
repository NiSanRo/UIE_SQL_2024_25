-- 
-- Ejercicios a realizar sobre tablas del esquema alquila_dvd
--
SELECT version();

-- Comprobar usuario y esquema
SELECT current_user AS mi_login, CURRENT_SCHEMA AS mi_esquema;
-- En adelante cuando veas <<mi_login>> pon el valor que te devuelve la anterior consulta

-- Esquemas a los que puedes acceder (debe aparecer alquila_dvd)
SELECT unnest(current_schemas(true));

-- Comprobar los permisos de acceso al esquema (si no aparece alquila_dvd en la respuesta a la consulta anterior)
SELECT has_schema_privilege('<<mi_login>>', 'alquila_dvd', 'USAGE');
SELECT has_table_privilege('<<mi_login>>', 'alquila_dvd.actor', 'SELECT');

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
-- Pregunta 01: Listado de todos los actores (tabla alquila_dvd.actor) con nombre igual a 'Kenneth'
-- 
SELECT * 
FROM alquila_dvd.actor 
WHERE first_name ='Kenneth';
-- 
-- Pregunta 02: Listado de nombres de actores que se repiten más de una vez
--
SELECT first_name,count(1) AS registros
FROM alquila_dvd.actor
GROUP BY first_name 
HAVING count(1)>1;

-- 
-- Pregunta 03: Listado de actores (nombre y apellido) que se repiten ordenados decrecientemente por número de repeticiones  
--
SELECT first_name AS nombre, last_name AS apellido ,count(1) AS registros
FROM alquila_dvd.actor
GROUP BY first_name,last_name
HAVING count(1)>1
ORDER BY registros DESC; 
-- 
-- Pregunta 04: Listado de los 5 nombres de actor que se repiten más veces
-- En caso de que haya nombres con el mismo número de repeticiones, se ordenan alfabéticamente
--
SELECT first_name,count(1) AS registros
FROM alquila_dvd.actor
GROUP BY first_name 
ORDER BY registros DESC, first_name ASC
LIMIT 5;

SELECT first_name,count(1) AS registros
FROM alquila_dvd.actor
GROUP BY first_name 
ORDER BY registros DESC, first_name ASC
FETCH FIRST 5 ROW ONLY;
-- 
-- Pregunta 05: Listado de los nombres de actor en los puestos 6 al 8 de los más repetidos
-- En caso de que haya nombres con el mismo número de repeticiones, se ordenan alfabéticamente
--
SELECT first_name,count(1) AS registros
FROM alquila_dvd.actor
GROUP BY first_name 
ORDER BY registros DESC, first_name ASC
OFFSET 5 ROWS
FETCH FIRST 3 ROW ONLY;
-- 
-- Pregunta 06: Listado de actores con 'rr' en cualquier posición de su apellido (last_name)
--
SELECT *
FROM actor a 
WHERE last_name LIKE '%rr%'
OR last_name LIKE '%Rr%'
OR last_name LIKE '%rR%';

SELECT *
FROM actor a 
WHERE UPPER(last_name) LIKE '%RR%';

-- 
-- Pregunta 07: Listado de actores  con nombre igual 'Minnie' y apellido igual a 'Kilmer'
--
SELECT * 
FROM actor a 
WHERE first_name='Minnie' AND last_name ='Kilmer'
-- 
-- Pregunta 08: Listado de actores con 'or' como antepenúltima y penúltima letra respectivamente de su apellido
--
SELECT *
FROM actor a 
WHERE UPPER(last_name) LIKE '%OR_';
-- 
-- Pregunta 09: Listado de actores con 'or' como antepenúltima y penúltima letra respectivamente de su apellido 
-- y cuyo nombre incluya la letra r ó R
--
SELECT *
FROM actor a 
WHERE UPPER(last_name) LIKE '%OR_' 
AND (first_name LIKE '%R%' OR first_name LIKE '%r%');

SELECT *
FROM actor a 
WHERE UPPER(last_name) LIKE '%OR_' 
AND UPPER(first_name) LIKE '%R%';
-- 
-- Pregunta 10: Listado de actores ordenados por nombre y apellido con la letra n en cualquier posición de su nombre 
-- y cuyo apellido empiece por T 
--
SELECT first_name AS nombre,last_name AS apellido 
FROM actor 
WHERE (first_name LIKE '%n%' OR first_name LIKE '%N%')
AND (last_name LIKE 'T%')
ORDER BY nombre,apellido;

SELECT first_name AS nombre,last_name AS apellido 
FROM actor 
WHERE UPPER(first_name) LIKE '%N%'  AND UPPER(last_name) LIKE 'T%'
ORDER BY nombre,apellido;

-- Usando claúsula SET
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE UPPER(first_name) LIKE '%N%' 
INTERSECT 
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE UPPER(last_name) LIKE 'T%' 
ORDER BY nombre,apellido;

-- Usando Common Table Expression (CTE)
WITH cumplen_nombre AS (
	SELECT first_name AS nombre,last_name AS apellido 
	FROM actor a 
	WHERE UPPER(first_name) LIKE '%N%'
),
cumplen_apellido AS(
	SELECT first_name AS nombre,last_name AS apellido 
	FROM actor a 
	WHERE UPPER(last_name) LIKE 'T%'
)
SELECT nombre,apellido
FROM cumplen_nombre
INTERSECT 
SELECT nombre,apellido
FROM cumplen_apellido
ORDER BY nombre,apellido;

-- 
-- Pregunta 11: Listado de actores (nombre y apellido) ordenados por nombre y apellido con la letra 'n' en cualquier posición de su nombre 
-- y cuyo apellido no contenga la letra 't' 
--
SELECT first_name AS nombre,last_name AS apellido 
FROM actor 
WHERE UPPER(first_name) LIKE '%N%'
AND UPPER(last_name) NOT LIKE 'T%' 
ORDER BY nombre,apellido;

-- Usando claúsula SET
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE UPPER(first_name) LIKE '%N%' 
EXCEPT 
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE UPPER(last_name) LIKE 'T%' 
ORDER BY nombre,apellido;

-- El resultado no es el mismo porque SUSAN DAVIS (como se vío en la pregunta 02) está repetida. 
-- La consulta con el WHERE devuelve TODAS las coincidencias
-- La consulta EXCEPT devuelve TODAS las coincidencias SIN REPETICIONES
-- Para que devuelvan lo mismo se pone DISTINCT en la consulta con WHERE
SELECT DISTINCT first_name AS nombre,last_name AS apellido 
FROM actor 
WHERE UPPER(first_name) LIKE '%N%'
AND UPPER(last_name) NOT LIKE 'T%' 
ORDER BY nombre,apellido;

-- 
-- Pregunta 12: Listado de actores identificador, nombre y apellido que se llaman Penelope, Gene, Cameron o Angela.
-- Mostrar el resultado por orden alfabéticamente descendente de nombre.
--
SELECT actor_id,first_name AS nombre,last_name AS apellido
FROM actor
WHERE upper(first_name) IN ('PENELOPE','GENE','CAMERON','ANGELA')
ORDER BY nombre DESC;

--
-- Pregunta 13: Listado de actores identificador, nombre y apellido que tienen la primera letra de su nombre entre la C y G
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 
SELECT actor_id,first_name AS nombre,last_name AS apellido
FROM actor
WHERE upper(left(first_name,1)) BETWEEN 'C' AND 'G'
ORDER BY nombre ASC;
--
-- Pregunta 14: Listado de actores nombre y apellido que tienen la primera letra de su nombre entre la C y I y que además tienen 
-- en su apellido una letra S al principio o una en E en la penúltima letra de su apellido
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 
SELECT DISTINCT first_name AS nombre,last_name AS apellido
FROM actor
WHERE upper(left(first_name,1)) BETWEEN 'C' AND 'I'
AND (upper(last_name) LIKE 'S%' OR upper(last_name) LIKE '%E_')
ORDER BY nombre ASC;

-- Usando INTERSECT
SELECT first_name AS nombre,last_name AS apellido
FROM actor
WHERE upper(left(first_name,1)) BETWEEN 'C' AND 'I'
INTERSECT 
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE upper(last_name) LIKE 'S%' OR upper(last_name) LIKE '%E_'
ORDER BY nombre ASC;

--
-- Pregunta 15: Usando la cláusula EXCEPT de las operaciones SET, obtener el listado de actores (nombre y apellido) 
-- que tienen la primera letra de su nombre entre la C y I y que no tienen en su apellido una letra S al principio,
-- ni una letra E en la penúltima letra de su apellido
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 
SELECT first_name AS nombre,last_name AS apellido
FROM actor
WHERE upper(left(first_name,1)) BETWEEN 'C' AND 'I'
EXCEPT 
SELECT first_name AS nombre,last_name AS apellido 
FROM actor a 
WHERE upper(last_name) LIKE 'S%' OR upper(last_name) LIKE '%E_'
ORDER BY nombre ASC;
