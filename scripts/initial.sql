with apple as (
	select * from app_store_apps
	where rating >= 4
	and price > 0
	),
google as (
	select * from play_store_apps
	where rating >= 4
	and price != '0'
	)

select name, 
	rating, 
	'Apple' as store, 
	price as cost
from apple
	union all
select 	name, 
	rating, 
	'Google' as store,
	nullif(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric as cost
from google
	order by name
	;
	