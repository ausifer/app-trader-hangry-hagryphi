WITH apps_apple AS (
SELECT * FROM app_store_apps
where rating >= 4
AND price > 0
),
play_google AS (
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
  
CASE WHEN cost <=1 THEN 10000
	WHEN cost > 1 THEN cost*10000
END AS purchase_price,

--earnings = 5000 * lifespan(yr) * 12 to convert to months
5000 * ((rating*2) + 1) * 12 AS earnings_per_mo,

/*assuming 1 marketing cost given we are looking at data for apps common to both app_store_apps and play_store_apps*/
1000* ((rating*2) + 1 ) *12 as mktg_per_mo,

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

--net_profit = earnings - total_cost over lifetime
(5000 * (rating*2) + 1 * 12) - CASE WHEN cost <=1 THEN 10000
	WHEN cost > 1 THEN (cost*10000) + 1000* ((rating*2) + 1 ) *12 * (rating*2) + 1 
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
ORDER BY lifespan DESC) as test;


