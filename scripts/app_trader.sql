select * from app_store_apps
limit 10
--7197

/*with app as (SELECT * FROM app_store_apps),
play AS (SELECT * FROM play_store_apps)
;

WITH app AS (SELECT * FROM app_store_apps),
play AS (SELECT * FROM play_store_apps);*/

select min (price) from app_store_apps
--0.00

select name, max (price) from app_store_apps
-299.99

select round(avg (price),2) from app_store_apps
--1.73

select min (content_rating) from app_store_apps
--12+

select max (content_rating) from app_store_apps
9+

select distinct (primary_genre) from app_store_apps
--23

select * from play_store_apps
--10840

select min (rating) from play_store_apps
---1.0
select max(rating) from play_store_apps
--5

select min (rating) from app_store_apps
---0.0
select max(rating) from app_store_apps
--5.0

select distinct name from play_store_apps
--9659

/*ASSUMPTIONS PSEUDO CODE
2a	CASE WHEN price Between (0, 1) THEN purchase_price  = 10000
		 WHEN price > 1 THEN purchase_price = price*10000

2b	earnings = 5000 	

2c	market_cost = 1000						
	if app is in appstore and app is in playstore then market cost is 1000						
	if app is in playstore and  not in app store then market cost is 1000						
	if app is in appstore and not in playstore then market cost is 1000		
	
2d	case when rating 0 then lifespan = 1			
	when rating = 1.0 then lifespan = 3			
	when rating = 2.0 then lifespan = 5			
	when rating = 3.0 then lifespan = 7			
	when rating  = 4 THEN lifespan = 9			
	when rating  = 5 THEN lifespan = 11			
	else lifespan = 0.5*rating			

e	select app from … INTERSECT			
	app is in playstore and app is in appstore		
	
	total cost = purchase_price + marketing
	
	earnings = 5000 * lifespan
	
	net_profit = earnings - expenses
*/

SELECT -- UNION ALL .This subquery helps to combine tables App / Play stores,  INTO A SINGLESET, including duplicates. 18037 rows
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
FROM play_store_apps



SELECT -- UNION. This subquery helps to select related information from two tables App / Play stores, WITHOUT DUPLICATES, only distinct values are selected. 16954 rows
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
UNION
SELECT 
	name,
	category,
	rating,
	size,
	content_rating,
	nullif(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric as cost,
-- 	CAST(install_count AS int),
	'Play Store' AS "store"
FROM play_store_apps


--2a. Query calculates purchase price from app_store_apps based on the assumptions
	select Name, price,
	CASE WHEN price <=1 THEN 10000
		WHEN price > 1 THEN price*10000
	END AS purchase_price
	from app_store_apps
	
--2b. 

if app is in appstore and app is in playstore then market cost is 1000						
	if app is in playstore and  not in app store then market cost is 1000						
	if app is in appstore and not in playstore then market cost is 1000	

--2e Query calculates rating from app_store_apps based on the assumptions

select Name, price, rating,
case when rating = 0 then 1			
	when rating = 1.0 then 3			
	when rating = 2.0 then 5			
	when rating = 3.0 then 7			
	when rating  = 4 THEN 9			
	when rating  = 5 THEN 11			
	else (rating*2) + 1			
END AS lifespan
from app_store_apps

SELECT--This subquery helps to findrow/app names that are common to both App / Play stores --881
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
WHERE name in (select name from play_store_apps)
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
FROM play_store_apps
WHERE name in (select name from app_store_apps)




--Common Table Expression

WITH apps_apple AS (
SELECT * FROM app_store_apps
where rating >= 4
AND price > 0
),
play_google AS (
SELECT * FROM play_store_apps
WHERE rating >= 4
AND price <> '0'
)
SELECT *
FROM
(SELECT
name,
rating,
store,
cost,
  
CASE WHEN cost <=1 THEN 10000
	WHEN cost > 1 THEN cost*10000
END AS purchase_price,

--earnings = 5000 * lifespan(yr) * 12 to convert to months
5000 * ((rating*2) + 1) * 12 AS earnings_per_mo,

/*assuming 1 marketing cost given we are looking at data for apps common to both app_store_apps and play_store_apps*/
1000* ((rating*2) + 1 ) *12  as mktg_per_mo,

CASE WHEN rating = 0 then 1			
	WHEN rating = 1.0 then 3			
	WHEN rating = 2.0 then 5			
	WHEN rating = 3.0 then 7			
	WHEN rating  = 4 THEN 9			
	WHEN rating  = 5 THEN 11			
	ELSE (rating*2) + 1			
END AS lifespan,

-- total cost = purchase_price + (marketing * lifespan)
CASE WHEN cost <=1 THEN 10000
	WHEN cost > 1 THEN (cost*10000) + 1000* ((rating*2) + 1 ) *12 * (rating*2) + 1 
 END AS total_cost,

--net_profit = earnings - total_cost
(5000 * ((rating*2) + 1) * 12 ) - (CASE WHEN cost <=1 THEN 10000
	WHEN cost > 1 THEN cost*10000) 
+ (1000* ((rating*2) + 1) * 12)* ((rating*2) + 1 ) 
	END AS net_profit


FROM
(
SELECT name,
rating,
'Apple' AS store,
price AS cost
FROM apps_apple

WHERE name IN (SELECT name FROM play_google) UNION ALL
SELECT  name,
rating,
'Google' AS store,
NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric AS cost
FROM play_google
WHERE name IN (SELECT name FROM app_store_apps)
ORDER BY name
) AS combo
ORDER BY lifespan DESC) as test

;




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
	distinct name,
	rating,
	store,
	cost,
 	

	ROUND(rating / .5,3) + 1 AS expected_lifespan_in_years,
	rating * 2 + 1 * 12 * 5000 AS earnings_per_mo,
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
		END)) AS net_profit,
   avg(rating) over () as PartitionTest
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
		WHERE name IN (SELECT name FROM app_store_apps)
		ORDER BY name
) AS combo
ORDER BY name, expected_lifespan_in_years DESC) as test





SELECT DISTINCT TRIM(name) AS name,
        rating,
        store,
        cost,
        INITCAP(
			CASE WHEN category ILIKE '%Game%' THEN 'Games'
				WHEN category ILIKE '%Health%' THEN 'Health & Fitness'
				WHEN category ILIKE '%Food%' THEN 'Food & Drink'
			WHEN category ILIKE '%Lifestyle%' THEN 'Lifestyle'
			WHEN category ILIKE '%Education%' THEN 'Education'
			WHEN category ILIKE '%Family%' THEN 'Family'
			WHEN category ILIKE '%Book%' THEN 'Lifestyle'
			WHEN category ILIKE '%Medical%' THEN 'Medical'
			WHEN category ILIKE '%Family%' THEN 'Family'
						ELSE category END
		) AS category,
        expected_lifespan_in_years,

