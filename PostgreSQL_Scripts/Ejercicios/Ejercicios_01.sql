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


-- 
-- Pregunta 02: Listado de nombres de actores que se repiten más de una vez
--

-- 
-- Pregunta 03: Listado de actores (nombre y apellido) que se repiten ordenados decrecientemente por número de repeticiones  
--


-- 
-- Pregunta 04: Listado de los 5 nombres de actor que se repiten más veces
-- En caso de que haya nombres con el mismo número de repeticiones, se ordenan alfabéticamente
--


-- 
-- Pregunta 05: Listado de los nombres de actor en los puestos 6 al 8 de los más repetidos
-- En caso de que haya nombres con el mismo número de repeticiones, se ordenan alfabéticamente
--


-- 
-- Pregunta 06: Listado de actores con 'rr' en cualquier posición de su apellido (last_name)
--


-- 
-- Pregunta 07: Listado de actores  con nombre igual 'Minnie' y apellido igual a 'Kilmer'
--


-- 
-- Pregunta 08: Listado de actores con 'or' como antepenúltima y penúltima letra respectivamente de su apellido
--



-- 
-- Pregunta 09: Listado de actores con 'or' como antepenúltima y penúltima letra respectivamente de su apellido 
-- y cuyo nombre incluya la letra r ó R
--


-- 
-- Pregunta 10: Listado de actores ordenados por nombre y apellido con la letra n en cualquier posición de su nombre 
-- y cuyo apellido empiece por T
-- Haga las soluciones utilizando WHERE, CTE y SET 
--



-- 
-- Pregunta 11: Listado de actores (nombre y apellido) ordenados por nombre y apellido con la letra 'n' en cualquier posición de su nombre 
-- y cuyo apellido no contenga la letra 't' 
-- Haga las soluciones utilizando WHERE y SET
-- Compara los resultados (número de líneas devuelto por cada consulta). ¿Por qué en un caso som 72 y en otro 71? 



-- 
-- Pregunta 12: Listado de actores (identificador, nombre y apellido) que se llaman Penelope, Gene, Cameron o Angela.
-- Mostrar el resultado por orden alfabéticamente descendente de nombre.
--




--
-- Pregunta 13: Listado de actores (identificador, nombre y apellido) que tienen la primera letra de su nombre entre la C y G
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 



--
-- Pregunta 14: Listado de actores nombre y apellido que tienen la primera letra de su nombre entre la C y I y que además tienen 
-- en su apellido una letra S al principio o una en E en la penúltima letra de su apellido
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 



-- Usando INTERSECT


--
-- Pregunta 15: Usando la cláusula EXCEPT de las operaciones SET, obtener el listado de actores (nombre y apellido) 
-- que tienen la primera letra de su nombre entre la C y I y que no tienen en su apellido una letra S al principio,
-- ni una letra E en la penúltima letra de su apellido
-- Mostrar el resultado por orden alfabéticamente ascendente de nombre.
-- Ayuda: para obtener la primera letra del nombre usad: left(first_name,1)
-- 



