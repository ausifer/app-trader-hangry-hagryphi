/*with apple as (
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
	price as cost,
	primary_genre AS "category",
	rating * 2 + 1 * 12 * 5000 AS Earnings,
	ROUND(rating / .5,1) + 1 AS expected_lifespan_in_years,
	CASE WHEN price <= 1 
		THEN 10000 + (((rating * 2) + 1) * 12 * 1000)
	WHEN price > 1 
		THEN price * 10000 + (((rating * 2) + 1) * 12 * 1000)
	END AS total_cost
from apple
where name in (select name from google)
	union all
select 	name, 
 	rating, 
	'Google' as store,
	nullif(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric as cost,
	category,
	rating * 2 + 1 * 12 * 5000 AS Earnings,
	ROUND(rating / .5,1) + 1 AS expected_lifespan_in_years,
		CASE WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric <= 1 
			THEN 10000 + (((rating * 2) + 1) * 12 * 1000)
		WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric > 1 
			THEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric * 10000 + (((rating * 2) + 1) * 12 * 1000)
		END AS total_cost
from google
where name in (select name from apple)
	order by name, rating desc
	;*/
	


WITH apple AS (
	SELECT * FROM app_store_apps
	where rating >= 4
	AND price > 0
	),
google AS (
	SELECT * FROM play_store_apps
	WHERE rating >= 4
	AND price != '0'
	)
SELECT *
FROM
(SELECT
	name,
	rating,
	store,
	cost,
 	
	ROUND(rating / .5,3) + 1 AS expected_lifespan_in_years,
	rating * 2 + 1 * 12 * 5000 AS lifetime_earnings,
	CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000
		END AS purchase_cost,
	CASE WHEN cost <= 1 THEN 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		WHEN cost > 1 THEN cost * 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		END AS total_marketing_cost,
	(CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000
		END) +
 	(CASE WHEN cost <= 1 THEN 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		WHEN cost > 1 THEN cost * 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		END) AS total_cost,
 	((rating * 2 + 1 * 12 * 5000)*(ROUND(rating / .5,3) + 1)) -
 	((CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000
		END) +
 	(CASE WHEN cost <= 1 THEN 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		WHEN cost > 1 THEN cost * 10000 + (ROUND(rating / .5,1) + 1 * 12 * 1000)
		END)) AS net_profit
FROM
(
	SELECT name,
		rating,
		'Apple' AS store,
		price AS cost
		FROM apple
		WHERE name IN (SELECT name FROM google)
		UNION ALL
	SELECT 	name,
		rating,
		'Google' AS store,
		NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric AS cost
		FROM google
		WHERE name IN (SELECT name FROM play_store_apps)
		ORDER BY name
) AS combo
ORDER BY net_profit DESC) as test;