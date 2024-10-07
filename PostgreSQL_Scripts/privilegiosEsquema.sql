-- Ver usuario conectado
SELECT current_user, session_user;

-- Para el otro esquema
-- Añadir nuevo esquema a la ruta
SHOW search_path;
SET search_path TO alquila_dvd, public, "$user";

-- Prueba de select
SELECT * FROM alquila_dvd.actor ;


-- Creación de objeto
CREATE TABLE public.tabla_prueba (            
                 user_id INT PRIMARY KEY,           
                 campo1 TEXT NULL,
                 campo2 TEXT NULL );

-- Consulta de privilegios por defecto
SELECT 
  nspname,         -- nombre de esquema
  defaclobjtype,   -- tipo de objeto
  defaclacl        -- privilegios por defecto
FROM pg_default_acl a JOIN pg_namespace b ON a.defaclnamespace=b.oid;




