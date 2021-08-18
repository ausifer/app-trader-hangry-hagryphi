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
-- select count(apple.name)
-- 	from apple
	select name, rating, 'Apple' as store from apple
	union all
	select name, rating, 'Google' as store from google
	order by name
	;