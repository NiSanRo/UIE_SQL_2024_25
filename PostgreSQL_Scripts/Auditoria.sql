--
-- VERSI�N DE POSTGRESQL
--
SELECT version();

-- USUARIO
SELECT current_user, session_user;

-- Campos de tabla
select table_schema,table_name,column_name,data_type,character_maximum_length 
from information_schema.columns
where table_name ='pg_stat_activity';

-- Usuarios de la base de datos
select * 
from pg_catalog.pg_user;

-- Usuarios actualmente conectados
select distinct usename,usesysid,pid,client_addr,application_name,backend_start,state
from pg_stat_activity
order by usename,client_addr,backend_start;

--
-- Para realizar el tracking de conexiones
-- 
drop MATERIALIZED VIEW tracking_activity;
CREATE MATERIALIZED VIEW tracking_activity AS
SELECT pid, usename, client_addr, application_name,backend_start
FROM pg_stat_activity;

-- Se crea la tabla de tracking
drop table tracking_login;
CREATE TABLE tracking_login (
    pid INTEGER primary KEY,
    user_name TEXT,
    client_addr TEXT,
    application_name TEXT,
    backend_start TIMESTAMP
);

-- Se crea una función para realizar la inserción en la tabla de tracking
drop FUNCTION track_new_activity ;
CREATE FUNCTION track_new_activity() RETURNS void AS $$
DECLARE
    last_pid BIGINT;
    new_rows RECORD;
BEGIN
    -- Get the last recorded PID
    SELECT pid INTO last_pid FROM tracking_login ORDER BY id DESC LIMIT 1;

    -- Query pg_stat_activity for new entries
    FOR new_rows IN SELECT pid, usename, client_addr, application_name,backend_start FROM pg_stat_activity WHERE pid > last_pid LOOP
        INSERT INTO tracking_login (pid,user_name, client_addr, application_name,backend_start)
        VALUES (new_rows.pid,new_rows.usename, new_rows.client_addr, new_rows.application_name,new_rows.backend_start);
    END LOOP;
END;
$$ LANGUAGE plpgsql;





