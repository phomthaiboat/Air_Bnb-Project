-- Filter column where last_review or date >2018
-- table listings
delete from listings
where last_review < '2019-01-01';
-- table reviews
delete from reviews
where date < '2019-01-01';

-- drop all blank row column in Listings table
alter table listings 
drop column neighbourhood_group, license;
-- drop all blank row column in neighbour_hoods table
alter table neighbourhoods
drop column neighbourhood_group

-- check table listings
select *
from listings
order by last_review 
-- check table reviews
select *
from reviews
order by date
--check table neighbourhoods
select *
from neighbourhoods





-- Data Manipulation
-- 1.Check Duplicate

-- Table listing
select id,row_num
from
(
select id, row_number() over(partition by id order by id) as row_num
from listings
) as T1
where row_num > 1;
-- No Duplicate

-- 2.Filled Missing value in last_Review
select *
from listings
order by id desc;

select listing_id, date
from
(
select listing_id,date, row_number() over(partition by listing_id order by date desc) as last_review
from reviews) as T1
where last_review = 1;
;

-- extract last review date from listing.date table
with cte as
(
select listing_id, date
from
(
select listing_id,date, row_number() over(partition by listing_id order by date desc) as last_review
from reviews) as T1
where last_review = 1
) 
select *
from cte
order by listing_id;


-- Check value in table reviews.date that can fill in listings.last_review's missing value
with cte as
(
select listing_id, date
from
(
select listing_id,date, row_number() over(partition by listing_id order by date desc) as last_review
from reviews) as T1
where last_review = 1
)
select t1.id, t2.date, t1.last_review
from cte as t2 right join listings as t1
on  t2.listing_id = t1.id
where t2.date is null;
;
-- There is no value in table review.date that can fill in listings.last_review


select *
from reviews
where date is null;

select *
from listings;

-- Question

--Descriptive Analysis
--Count distribution of room type
select room_type, count(room_type) as Room_Type_Frequency
from listings
group by room_type;
--Count the number of active listings per neighborhood.
select neighbourhood, count(neighbourhood)
from listings
where availability_365 > 0
group by neighbourhood
order by 2 desc;

-- Price_Insight
select top 5 neighbourhood, minimum_nights, avg(Price) as average_Price
from listings
group by neighbourhood, minimum_nights
order by 3 desc;

-- Review and demand analysis
-- Total Review per listing
select listing_id, count(date) as total_Review
from reviews 
group by listing_id
order by 2 desc; 
-- Average reviews per month
select month(date) as Monthly_review, count(date) as average_review_per_month
from reviews
group by month(date)
order by 2 desc

--Identify which neighborhoods generate the most guest activity
select neighbourhood, count(last_review) as review_activity
from listings 
group by neighbourhood
order by 2 desc


--Host Analysis
--Find the hosts with the most listings
select host_id, count(id) as count_of_listing
from listings 
group by host_id
order by 2 desc

--Check whether hosts with multiple listings charge higher or lower average prices.
select host_id, count(id) as count_of_listing, Price, (select avg(Price) from listings where price is not null) as Average_Price_Overall -- Should use median
from listings 
where price is not null 
group by host_id, Price
having count(id) > 1
order by 2 desc;


select *
from Listings