--Consulta de clientes
SELECT * 
FROM customers;

-- Consulta de clientes en la ciudad de SAO PAULO
select *
from customers
where customer_city='sao paulo';
	
-- Consulta de clientes de Sao Paulo con código postal 1154
select *
from customers
where customer_city='sao paulo' and customer_zip_code_prefix='1154';

