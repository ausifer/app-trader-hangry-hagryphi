-- This is a query to find all apps in both the App Store and Play Store with a rating >= 4 and price > 0, their category,
-- expected lifespan in years, lifetime earnings, lifetime cost, net profit and total net profit for both stores
--  CTE to select app store table
WITH apple AS ( 
    SELECT * 
    FROM app_store_apps
    WHERE rating >= 4
    AND price > 0),
-- CTE to select play store table
google AS (
    SELECT * 
    FROM play_store_apps
    WHERE rating >= 4
    AND price != '0'
    ),
-- subquery to determine columns and total net profit
target AS (SELECT DISTINCT TRIM(name) AS name,
        rating,
        store,
        cost,
        TRIM(INITCAP(
			CASE WHEN category ILIKE '%Game%' THEN 'Games'
				WHEN category ILIKE '%Health%' THEN 'Health & Fitness'
				WHEN category ILIKE '%Food%' THEN 'Food & Drink'
			ELSE category END 
		)) AS category,
        expected_lifespan_in_years,
        lifetime_earnings,
        lifetime_cost,
        net_profit,
SUM(net_profit) OVER(PARTITION BY name) AS total_net_profit
-- FROM clause to pick select columns from each table and UNION into one
FROM (SELECT DISTINCT name,
    rating,
    'Apple' AS store,
    price AS cost,
    TRIM(INITCAP(primary_genre)) AS "category",
    ((rating * 2) + 1) AS expected_lifespan_in_years,
    CAST((((rating * 2) + 1) * 12 * 2500) AS money) AS lifetime_earnings,
    CAST((CASE WHEN price <= 1 THEN 10000 + (((rating * 2) + 1) * 12 * 500)
        WHEN price > 1 THEN price * 10000 + (((rating * 2) + 1) * 12 * 500)
        END) AS MONEY) AS lifetime_cost,
    CAST((((rating * 2) + 1) * 12 * 2500) - (CASE WHEN price <= 1 THEN 10000 + (((rating * 2) + 1) * 12 * 500)
        WHEN price > 1 THEN price * 10000 + (((rating * 2) + 1) * 12 * 500)
        END) AS MONEY) AS net_profit
FROM apple
WHERE name IN (SELECT name FROM google)
UNION ALL
SELECT DISTINCT name,
    rating,
    'Google' AS store,
    NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric AS cost,
    category,
    ((rating * 2) + 1) + 1 AS expected_lifespan_in_years,
    CAST((((rating * 2) + 1) * 12 * 2500) AS MONEY) AS lifetime_earnings,
    CAST((CASE WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric <= 1 THEN 10000 + (((rating * 2) + 1) * 12 * 500)
        WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric > 1 THEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric * 10000 + (((rating * 2) + 1) * 12 * 500)
        END) AS MONEY)lifetime_cost,
    CAST((((rating * 2) + 1) * 12 * 2500) - (CASE WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric <= 1 THEN 10000 + (((rating * 2) + 1) * 12 * 500)
        WHEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric > 1 THEN NULLIF(regexp_replace(price, '[^0-9.]*','','g'), '')::numeric * 10000 + (((rating * 2) + 1) * 12 * 500)
        END) AS MONEY) AS net_profit
FROM google
WHERE name IN (SELECT name FROM apple)) AS sub
-- ORDER BY total net profit to show the most profitable first, then by name to group the names together.
ORDER BY total_net_profit DESC, TRIM(name))

-- Pulling the data all together by name
SELECT 
	DISTINCT name AS name,
	COUNT(DISTINCT category) 				AS category_count,
	CASE WHEN COUNT(store) >= 3 THEN 2
	WHEN COUNT(store) < 3 THEN COUNT(store) 
	END										AS store_count,
	AVG(rating) AS avg_rating,
	AVG(expected_lifespan_in_years) 		AS avg_lifespan,
    SUM(lifetime_earnings) 					AS combined_lifetime_earnings,
    SUM(lifetime_cost) 						AS combined_lifetime_cost,
    SUM(net_profit) 						AS total_net_profit
FROM target
GROUP BY name
ORDER BY total_net_profit DESC;


