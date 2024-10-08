--
-- 1. Consultando los datos
-- 

-- SELECT
-- Alias de columnas
-- ORDER BY
-- DISTINCT

--
-- 2. Filtrando los datos
-- 

-- WHERE
-- Operadores lógicos (AND y OR)
-- LIMIT
-- FETCH
-- IN
-- BETWEEN
-- LIKE
-- IS NULL, IS NOT NULL

-- 
-- 3. Agrupando los datos
-- 

-- GROUP BY
-- HAVING
-- GROUPING SETS
-- CUBE
-- ROLL UP

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