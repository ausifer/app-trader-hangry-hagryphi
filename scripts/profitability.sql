WITH apple AS (
	SELECT * FROM app_store_apps
	where rating >= 4
	AND price > 0
	),
google AS (
	SELECT * FROM play_store_apps
	WHERE rating >= 4
	AND price != '0'
	),
target AS (SELECT   
	name,
	lifetime_earning,
	total_marketing_cost,
	SUM(purchase_cost) OVER(PARTITION BY name) AS total_purchase_cost,
	total_cost,
	net_profit
FROM
(SELECT
	DISTINCT name,
	rating,
	store,
	cost, 	
	ROUND(rating / .5,3) + 1 
 		AS expected_lifespan_in_years,
	12 * 2500 * (ROUND(rating / .5,3) + 1) 
 		AS lifetime_earning, 
	CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000
		END 
 		AS purchase_cost,
	500 * 12 * (ROUND(rating / .5,3) + 1)
 		AS total_marketing_cost,
	(CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000 									--`` purchase_cost +
		END) 
 	+ 																		--        +
 	(500 * 12 * (ROUND(rating / .5,3) + 1)) 								-- total_marketing_cost
 		AS total_cost,
 	(12 * 2500 * (ROUND(rating / .5,3) + 1)) 								--`` lifetime_earning 
 	- 																		--        -
 	(
		(CASE WHEN cost <= 1 THEN 10000
		WHEN cost > 1 THEN cost * 10000 									-- (purchase_cost +
		END) 
 	+ 																		--        +
 	(500 * 12 * (ROUND(rating / .5,3) + 1))
	)  																		-- total_marketing_cost)
 		AS net_profit
FROM
(
	SELECT TRIM(name) AS name,
		rating,
		'Apple' AS store,
		price AS cost
	FROM apple
		WHERE name IN (SELECT name FROM google)
	UNION ALL
	SELECT TRIM(name) AS name,
		rating,
		'Google' AS store,
		NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric AS cost
	FROM google
		WHERE name IN (SELECT name FROM apple)
		ORDER BY name
) AS combo
ORDER BY net_profit DESC) as subquery
ORDER BY net_profit DESC)
SELECT DISTINCT name,
		SUM(net_profit) AS net_profit
FROM target
GROUP BY name
ORDER BY net_profit DESC;



