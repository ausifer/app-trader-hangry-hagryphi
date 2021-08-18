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
/*
2a	CASE WHEN price Between (0, 1) THEN purchase_price  = 10000
WHEN price > 1 THEN purchase_price = price*10000

2b	earnings = 5000 	

2c	market_cost = 1000						
	if app is in appstore and app is in playstore then market cost is 1000						
	if app is in playstore and  not in app store then market cost is 1000						
	if app is in appstore and not in playstore then market cost is 1000		
	
	d	case when rating 0 then lifespan = 1			
	when rating = 1.0 then lifespan = 3			
	when rating = 2.0 then lifespan = 5			
	when rating = 3.0 then lifespan = 7			
	when rating  = 4 THEN lifespan = 9			
	when rating  = 5 THEN lifespan = 11			
	else lifespan = 0.5*rating			


e	select app from …			
	app is in playstore and app is in appstore			
*/

