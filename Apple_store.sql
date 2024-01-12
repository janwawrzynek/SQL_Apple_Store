--SQLITE code
-- AppleStore file contains the table values
-- appleappleStore_description files contain the descriptions
-- for the apps. These will be joined when needed.

CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * from appleStore_description2

UNION ALL 

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4



-- find the number of unique applications in both tablesAppleStoreAppleStore

SELECT COUNT(DISTINCT id) as uniqueAppIDs
FROM AppleStore
-- 7198
SELECT COUNT(DISTINCT id) as uniqueAppIDs
FROM appleStore_description_combined

-- 7197

-- check for any missing values in the key fields
SELECT COUNT(*) as MissingValues
FROM AppleStore
WHERE track_name is null or user_rating is null or prime_genre is NULL

SELECT COUNT(*) as MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL

--find out the number of apps per genre

SELECT prime_genre, count(*) as NumApps
FROM AppleStore
group BY prime_genre
order by numApps DESC

--Get an overview of the apps' ratingsAppleStore

SELECT min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore
-- average rating of 3.53

-- Determine the distribution of App prices
select
	(Price / 2)*2 as PriceBinStart,
    ((price / 2)*2) +2 as PriceBinEnd,
    COUNT(*) as NumApps
FROM AppleStore
group by PriceBinStart
order by PriceBinStart
-- most apps have a price between 0-2 dollars.

-- see whether paid apps have higher ratings than free apps

SELECT CASE
		when price > 0 THEN 'Paid'
        else 'Free'
        end as App_Type,
        avg(user_rating) as Avg_Rating
        
From AppleStore
Group By App_Type
-- free apps have an average rating of 3.38
-- Paid apps have an average rating of 3.72

-- check if apps with more supported languages have higher ratings
SELECT CASE
	WHEN lang_num < 10 THEN '<10 languages'
    when lang_num BETWEEN 10 and 30 then '10-30 languages'
    else '>30 languages'
  end as language_bucket,
  avg(user_rating) as Avg_Rating
 FROM AppleStore
group by language_bucket
order by Avg_Rating DESC
-- <10 languages avg rating = 3.37
-- 10-30 languages avg rating= 4.13
-- >30 languages avg rating = 3.78
-- this suggests that apps which focus on a range of
-- the right languages have better ratings
--Find which genres have low ratings
SELECT prime_genre,
avg(user_rating) as Avg_Rating
from AppleStore
Group by prime_genre
ORDER by Avg_Rating ASC
limit 10
-- lowest ratings are
-- catalogs 2.1
-- finance 2.43
-- book 2.43
-- These low scores mean there may be potential for a new app
-- to break into these markets

-- see if theres a correlation between the length of the
-- description and the user rating

SELECT CASE
		when length(b.app_desc) < 500 then 'Short'
    	when length(b.app_desc) between 500 and 1000 then 'Medium'
    	else 'long'
	end as description_length_bucket,
    avg(a.user_rating) as average_rating

    
from
	AppleStore as a

JOIN
	appleStore_description_combined as b

on
	a.id =  b.id
GROUP by description_length_bucket
order by average_rating DESC

-- can see that longer description have on average better ratings
-- long = 3.86
-- medium = 3.23
-- short = 2.53

-- find the top rated apps for each category
SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
     SELECT
     prime_genre,
     track_name,
     user_rating,
     RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC,
                 rating_count_tot desc) as rank
  
  
FROM AppleStore
     ) as a
WHERE
a.rank = 1


-- there are apps in each category with a perfect 5/5 rating

       
       
       
