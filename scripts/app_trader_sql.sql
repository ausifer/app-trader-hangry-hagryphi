WITH apple AS (SELECT * FROM app_store_apps),
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
	CAST(
		REPLACE(REPLACE(price, '$', ''),' ','') -- Trying to figure out how to get this stuff converted to same data type
		AS int),
-- 	CAST(install_count AS int),
	'Play Store' AS "store"
FROM play_store_apps;

SELECT DISTINCT price
FROM app_store_apps
ORDER BY price DESC;

SELECT DISTINCT price
FROM play_store_apps
ORDER BY price DESC;