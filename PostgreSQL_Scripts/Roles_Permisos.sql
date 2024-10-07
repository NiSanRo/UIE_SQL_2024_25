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
-- Consulta de permisos
SELECT *
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_permisos';

SELECT DISTINCT table_catalog,table_schema 
FROM INFORMATION_SCHEMA.ROLE_TABLE_GRANTS
WHERE GRANTEE = 'uie_permisos';

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





