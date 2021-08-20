/* WITH apple AS (SELECT * FROM app_store_apps),
droid AS (SELECT * FROM play_store_apps)
SELECT * FROM apple
SELECT * FROM 
ORDER BY name;

SELECT -- This subquery helps to put most columns together from App / Play stores. 
	name,
	primary_genre AS "category",
	rating,
	size_bytes AS "size",
	content_rating,
	price,
-- 	CAST(price AS int),
-- 	0 AS install_count,
	'App Store' AS "store"
FROM app_store_apps
UNION ALL
SELECT 
	name,
	category,
	rating,
	size,
	content_rating,
	nullif(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric as cost,
-- 	CAST(install_count AS int),
	'Play Store' AS "store"
FROM play_store_apps; */


-- EVERYTHING ABOVE THIS POINT IS AUSTIN'S QUERY - BUT WE'RE USING HOLLAND'S BASIC STRUCTURE BECAUSE HE FIGURED THINGS OUT QUICKER AND BETTER

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
SELECT *   -- THIS NEEDS TO BE A CTE AS WELL AND WE NEED TO GET RID OF CATEGORIES BESIDES GAMES
FROM
(SELECT
	name,
	rating,
	store,
	cost,
	category, 	
	ROUND(rating / .5,3) + 1 AS expected_lifespan_in_years,
	rating * 2 + 1 * 12 * 5000 AS earnings_per_mo, --THIS IS STILL WRONG FOR MINE, SO THE OTHER CALCULATIONS BELOW ARE WRONG, TOO
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
		price AS cost,
		primary_genre AS "category"
		FROM apple
		WHERE name IN (SELECT name FROM google)

		UNION ALL
	SELECT 	name,
		rating,
		'Google' AS store,
		NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric AS cost,
		category
	FROM google
		WHERE name IN (SELECT name FROM play_store_apps)
		ORDER BY name
) AS combo
ORDER BY net_profit DESC) as test
;

