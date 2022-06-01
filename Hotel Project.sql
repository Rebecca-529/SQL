--Merging the tables for different years into on table
WITH Hotels as (
Select * from dbo.T2018
UNION
Select * from dbo.T2019
UNION
Select * from dbo.T2020)

--Is our hotel revenue growing?
Select 
arrival_date_year, 
hotel,
round(sum((stays_in_week_nights + stays_in_weekend_nights)* adr),2) as Revenue from Hotels
group by arrival_date_year, hotel


--Join in market_segment and meal_cost information
Select * from hotels
left join.dbo.market_segment
on hotels.market_segment = market_segment.market_segment
left join dbo.meal_cost 
on meal_cost.meal = hotels.meal