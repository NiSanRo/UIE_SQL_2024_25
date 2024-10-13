--
-- VERSIÓN DE POSTGRESQL
--
SELECT version();

-- USUARIO
SELECT current_user, session_user;

-- Creación de un nuevo esquema
CREATE SCHEMA alquila_dvd;

-- Creamos un grupo para gestionar permisos
CREATE ROLE uie_permisos WITH NOLOGIN PASSWORD '#uie_consultas1';

-- Creamos un usuario/rol con permiso de login
CREATE ROLE uie_alumno LOGIN PASSWORD 'uie_20241002';
-- En postgresql cuando se crea un ROL, automáticamente se crea un usuario con el mismo nombre. 
-- CREATE USER es un alias de CREATE ROL y también se crea el ROL asociado.

-- Asociar un usuario a un grupo
GRANT uie_permisos TO uie_alumno;
--
-- Permisos a nivel de Grupo. Los usuarios adscritos los heredan
--
-- Permisos para utilizar un esquema
GRANT USAGE ON SCHEMA alquila_dvd TO uie_permisos ;
-- Permisos para leer una tabla existente
GRANT SELECT ON TABLE actor TO uie_permisos;
-- Todos los permisos, sobre todas las tablas de un esquema
GRANT ALL PRIVILEGES
ON ALL TABLES 
IN SCHEMA alquila_dvd 
TO uie_permisos;
-- Consulta de permisos sobre tablas
SELECT *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_permisos';

SELECT DISTINCT table_catalog,table_schema 
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_permisos';

-- Consulta de permisos sobre el esquema
SELECT n.nspname AS esquema, r.rolname AS rol_usuario,
    has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS crear,
    has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS usar
FROM pg_namespace n
JOIN  pg_roles r ON r.rolname = '<<usuario>>'
WHERE  n.nspname = 'alquila_dvd';

-- Le vamos a dar permisos para crear sus propios objetos, pero no para 
-- manipular los existentes
GRANT CREATE ON SCHEMA alquila_dvd TO alquila_dvd;
-- Permisos para leer cualquier tabla que sea creada a posteriori

ALTER DEFAULT PRIVILEGES IN SCHEMA alquila_dvd GRANT ALL PRIVILEGES  ON TABLES TO uie_permisos;
ALTER DEFAULT PRIVILEGES IN SCHEMA alquila_dvd REVOKE ALL ON TABLES FROM uie_permisos;

-- Consulta de permisos por defecto para un ROLE
SELECT 
  b.nspname,         -- 	esquema
  a.defaclobjtype,   -- tipo de objeto
  a.defaclacl        -- privilegios concedidos
FROM pg_catalog.pg_default_acl a 
JOIN pg_catalog.pg_namespace b ON a.defaclnamespace=b.oid
WHERE array_to_string(a.defaclacl, ' + ') LIKE 'uie_permisos%';

-- Se elimina la adscripción del usuario al grupo
REVOKE uie_permisos FROM uie_alumno;

-- Revocar todos los privilegios sobre tablas en el esquema alquila_dvd
REVOKE ALL PRIVILEGES ON
ALL TABLES
IN SCHEMA alquila_dvd
FROM uie_permisos;
-- Revocar todos los privilegios  en el esquema alquila_dvd
REVOKE ALL 
ON SCHEMA alquila_dvd
FROM uie_permisos;
-- REVOCACIÓN DE PERMISOS POR DEFECTO
ALTER DEFAULT PRIVILEGES 
IN SCHEMA alquila_dvd 
REVOKE ALL  
ON TABLES 
FROM uie_permisos;
-- Borrado del GRUPO
DROP ROLE uie_permisos;

-- UIE_CONSULTAS

--
-- CREACIÓN DE GRUPO
--
CREATE ROLE uie_consultas WITH PASSWORD '#uie_consultas1';
-- Comprobamos los usuarios y roles existentes
select * from pg_user;
SELECT * FROM pg_roles;
select * from pg_authid;
-- Permisos para el rol
select *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_consultas';

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
IN SCHEMA public
FROM uie_consultas;

-- Verificar si existen usuarios que hereden (sin ser el admin) y revocar permiso
SELECT u.usename,r.rolname
FROM pg_user u
JOIN pg_auth_members m ON u.usesysid = m.member
JOIN pg_roles r ON r.oid = m.roleid
where r.rolname='uie_consultas';

-- Le quitamos la adscripción al grupo
REVOKE uie_consultas FROM uie_alumno;

-- Ahora se puede borrar el rol. Ojo, es posible que haya otros usuarios con este rol y tengamos que REVOCAR
DROP ROLE uie_consultas;

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

-- Vemos que no tiene permisos para uie_alumno, pero comprobamos que est� asociado al rol que permite consultar
SELECT u.usename,r.rolname
FROM pg_user u
JOIN pg_auth_members m ON u.usesysid = m.member
JOIN pg_roles r ON r.oid = m.roleid
where r.rolname='uie_consultas';


-- Limpiamos todos los usuarios creados para la demo
DROP ROLE uie_consultas;

REVOKE ALL PRIVILEGES ON
SCHEMA "public"
FROM uie_consultas;

DROP ROLE uie_consultas;

-----------------------------------------------------------------------------------------------------------------------
-- CONSULTAS DE CATÁLOGO DE DATOS
-----------------------------------------------------------------------------------------------------------------------

-- Claves primarias, columnas y propietario de  tabla
SELECT n.nspname AS esquema, r.rolname AS propietario_tabla, c.relname AS tabla,
   	 p.conname AS nombre_pk, a.attname AS nombre_columna
FROM pg_constraint p
JOIN pg_attribute a ON a.attnum = ANY(p.conkey) AND a.attrelid = p.conrelid
JOIN pg_class c ON c.oid = p.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.oid = c.relowner
WHERE p.contype = 'p'; -- Para PK

-- Claves foráneas (FK), tabla y columnas
SELECT n.nspname AS esquema, r.rolname AS propietario_tabla, c.relname AS tabla,
   	 p.conname AS nombre_pk, a.attname AS nombre_columna
FROM pg_constraint p
JOIN pg_attribute a ON a.attnum = ANY(p.conkey) AND a.attrelid = p.conrelid
JOIN pg_class c ON c.oid = p.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.oid = c.relowner
WHERE p.contype = 'f'; -- Para FK

-- Relaciones entre tablas
SELECT n.nspname AS schema_name, c.relname AS table_name,
    fk.conname AS foreign_key_name, a.attname AS foreign_key_column,
    n2.nspname AS referenced_schema_name, c2.relname AS referenced_table_name,
    pk.conname AS primary_key_name, a2.attname AS primary_key_column
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
ORDER BY schema_name, table_name, foreign_key_name, foreign_key_column;


-- Cambios en el modelo para poder trabajar con comodidad
DROP VIEW alquila_dvd.actor_info;
DROP VIEW alquila_dvd.film_list;
DROP VIEW alquila_dvd.nicer_but_slower_film_list;

-- Ponemos como identidad el valor de actor_id
ALTER TABLE alquila_dvd.actor ALTER actor_id DROP DEFAULT;
ALTER TABLE alquila_dvd.actor ALTER COLUMN actor_id  SET DATA TYPE int; 
ALTER TABLE alquila_dvd.actor ALTER COLUMN actor_id DROP DEFAULT;
ALTER TABLE alquila_dvd.actor ALTER COLUMN actor_id ADD GENERATED ALWAYS AS IDENTITY (RESTART 500);
-- Ponemos como identidad el valor de film_id
ALTER TABLE alquila_dvd.film ALTER film_id DROP DEFAULT;
ALTER TABLE alquila_dvd.film ALTER COLUMN film_id  SET DATA TYPE int; 
ALTER TABLE alquila_dvd.film ALTER COLUMN film_id ADD GENERATED ALWAYS AS IDENTITY (RESTART 1500);
-- Ponemos como identidad el valor de film_id
ALTER TABLE alquila_dvd.language ALTER language_id DROP DEFAULT;
ALTER TABLE alquila_dvd.language ALTER COLUMN language_id  SET DATA TYPE int; 
ALTER TABLE alquila_dvd.language ALTER COLUMN language_id ADD GENERATED ALWAYS AS IDENTITY (RESTART 100);
-- Ponemos como char(1)
INSERT INTO alquila_dvd.LANGUAGE (name, last_update)  VALUES( 'Spanish', now());
-- Cambiar tipo de columna de integer a boolean
ALTER TABLE alquila_dvd.customer ALTER COLUMN active DROP DEFAULT;
ALTER TABLE  alquila_dvd.customer ALTER active TYPE bool USING CASE WHEN active=0 THEN FALSE ELSE TRUE END;
ALTER TABLE  alquila_dvd.customer ALTER COLUMN active SET DEFAULT FALSE;
-- Añadir fila a tabla staff para el NATURAL JOIN
INSERT INTO alquila_dvd.staff (first_name,last_name,address_id,email,store_id,username,"password",last_update)
	VALUES ('Linda','Williams',7,'linda.williams@sakilacustomer.org',1,'Linda','8cb2237d0679ca88db6464eac60da96345513964','2013-05-26 14:49:45.738');
-- Añadimos filas a customer
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(2, 'Pepe', 'Perez', 'no_tiene@sindominio.com', 501, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(1, 'Pepito', 'Perez', 'no_tiene@sindominio.com', 502, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(1, 'Juan', 'García', 'no_tiene@sindominio.com', 405, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(2, 'Juanito', 'Sin miedo', 'no_tiene@sindominio.com', 302, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(2, 'Antonio', 'Romero', 'no_tiene@sindominio.com', 303, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(2, 'Pepa', 'Romero', 'no_tiene@sindominio.com', 305, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(1, 'Juana', 'Romero', 'no_tiene@sindominio.com', 406, true);
INSERT INTO alquila_dvd.customer(store_id, first_name, last_name, email, address_id , active)
VALUES(1, 'Juanita', 'Banana', 'no_tiene@sindominio.com', 504, true);
-- Para ejemplo de nullif
UPDATE alquila_dvd.customer
SET create_date='2024-10-13', last_update=now(), active=FALSE WHERE customer_id=605;
UPDATE alquila_dvd.customer
SET create_date='2024-10-13', last_update=now(), activebool=TRUE WHERE customer_id=605;
COMMIT;

