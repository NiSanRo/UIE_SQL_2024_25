--
-- VERSI�N DE POSTGRESQL
--
SELECT version();

-- USUARIO
SELECT current_user, session_user;

--
-- CREACIÓN DE USUARIOS DE CONSULTA
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
-- Tambi�n a los permisos. Por eso hay que revocarlos

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

-- Creaci�n de rol para permisos.
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
-- En postgresql cuando se crea un ROL, autom�ticamente se crea un usuario con el mismo nombre. 
-- CREATE USER es un alias de CREATE ROL y tambi�n se crea el ROL asociado.
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

-- Vemos que no tiene permisos para uie_alumno, pero comprobamos que est� asociado al rol que permite consultar
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





