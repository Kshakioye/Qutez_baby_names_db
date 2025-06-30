-- EXPLORING DATA 
--Question 1: What is the total period of time the data was collected?
SELECT MIN(names.year), MAX(names.year)
FROM names;

--Answer: The entire data was collected within the period of year 1980 and 2009
--		  approximately 30 years.

--Question 2: How many baby names are in the DB?
SELECT COUNT(Distinct name) FROM names;
--Answer: There are a total of 22,240 baby names in the DB

--Question 3: How many male names are in the DB?
SELECT COUNT(Distinct name) 
FROM names WHERE gender 
IN ('M');
--Answer: There are a total of 9730 male names in the DB

--Question 4: How many female names are in the DB?
SELECT COUNT(Distinct name) 
FROM names WHERE gender 
IN ('F');
--Answer: There are a total of 14,474 female names in the DB

-- Question 5: What is the total number of birth recorded?
SELECT SUM(births) 
FROM names;
--Answer: A total of 98,730,863 births were recorded in the DB

-- Question 6: How many female and Male birth is recorded?
SELECT gender, SUM(births)
FROM names
GROUP BY gender;
--Answer: There were 45,856,778 female births and 52,874,085 male births recorded.

--Question 7: How many Unique Regions are recorded in the DB?
SELECT COUNT(distinct region)
FROM regions;
--Answer: Seven(7) regions are recorded in the DB

--Question 8: How many unique states are recorded in the DB?
SELECT COUNT(distinct state)
FROM regions;
--Answer: 51 unique states are recorded in the DB 

-- Question 9: How many states are in each region?
SELECT  Distinct region, COUNT(state)
FROM regions
GROUP BY region
ORDER BY COUNT(state) DESC;
-- Run query to view result table





------ KEY QUESTIONS-------

-- Question 1: What are the most popular male names in the first decade.
SELECT name AS baby_names, SUM (births) AS no_of_babies
FROM names
WHERE year BETWEEN 1980 AND 1989 AND gender = 'M'
GROUP BY baby_names
ORDER BY no_of_babies DESC
LIMIT 5; 

-- Answer: Run the query to see the result table.
-- Inference: In the first decade,male children were name popular religious names such as XXX..,

-- Question 2: What are the most popular female names in the first decade.
SELECT name AS baby_names, SUM (births) AS no_of_babies
FROM names
WHERE year BETWEEN 1980 AND 1989 AND gender = 'F'
GROUP BY baby_names
ORDER BY no_of_babies DESC
LIMIT 5; 

-- Answer: Run the query to see the result table.
-- Inference: In the first decade, female children were name popular conventional names such as XXX..,

-- Question 3: What are the most popular male names in the last decade.
SELECT name AS baby_names, SUM (births) AS no_of_babies
FROM names
WHERE year BETWEEN 1999 AND 2009 AND gender = 'M'
GROUP BY baby_names
ORDER BY no_of_babies DESC
LIMIT 5; 
-- Answer: Run the query to see the result table.

-- Question 4: What are the most popular female names in the last decade.
SELECT name AS baby_names, SUM (births) AS no_of_babies
FROM names
WHERE year BETWEEN 1999 AND 2009 AND gender = 'F'
GROUP BY baby_names
ORDER BY no_of_babies DESC
LIMIT 5; 

-- Question 5: what are the single most common names in each region 
WITH ranked_names AS (
    SELECT 
    names.name AS baby_name,
    regions.region,
    SUM(names.births) AS total_births,
    ROW_NUMBER() OVER (PARTITION BY regions.region ORDER BY SUM(names.births) DESC) AS rn
FROM names
JOIN regions ON names.state = regions.state
WHERE regions.region IN ('Mountain', 'Pacific', 'Mid_Atlantic', 'South', 'North', 'Midwest', 'New_England')
GROUP BY names.name, regions.region
)
SELECT baby_name, region, total_births
FROM ranked_names
WHERE rn = 1
ORDER BY total_births DESC;

-- Question 6: Which names overlap across gender (unisex names) and which are the top 5?
SELECT DISTINCT a.name
FROM names a
JOIN names b
  ON a.name = b.name
WHERE a.gender = 'M'
  AND b.gender = 'F';

SELECT name, SUM(births) AS total_births, year
FROM names
WHERE gender IN ('M', 'F')
  AND name IN (
    SELECT DISTINCT a.name
    FROM names a
    JOIN names b ON a.name = b.name
    WHERE a.gender = 'M' AND b.gender = 'F'
  )
GROUP BY name, year
ORDER BY total_births DESC
LIMIT 20;
-- Answer: Run query to view result table

-- Question 7: Which names have dropped in popularity over the years?

-- (selecting the baby names from the first 15 years)
WITH early_pop AS (
  SELECT name, SUM(births) AS early_births
  FROM names
  WHERE year BETWEEN 1980 AND 1994
  GROUP BY name
),
--(selecting the baby names from the last 15 years)
late_pop AS (
  SELECT name, SUM(births) AS late_births
  FROM names
  WHERE year BETWEEN 1995 AND 2009
  GROUP BY name
),
-- Comparing the list and extracting those that were unused over the years
pop_change AS (
  SELECT 
    e.name,
    e.early_births,
    COALESCE(l.late_births, 0) AS late_births,
    e.early_births - COALESCE(l.late_births, 0) AS drop_in_births
  FROM early_pop e
  LEFT JOIN late_pop l ON e.name = l.name
)
-- selecting the names that drop in number of births as calculated from pop_change table
SELECT pop_change.name, early_births, late_births, drop_in_births
FROM pop_change
WHERE drop_in_births > 0 AND name IN ('Michael', 'Emma')
ORDER BY drop_in_births DESC;

SELECT
  name,
  CASE 
    WHEN year BETWEEN 1980 AND 1994 THEN 'Early'
    WHEN year BETWEEN 1995 AND 2009 THEN 'Late'
  END AS period,
  SUM(births) AS total_births
FROM names
WHERE name = 'Emma' AND year BETWEEN 1980 AND 2009
GROUP BY name, period;



-- QUESTION 8: What are the top 5 new names introduced in the most recent year that weren’t in use the previous year?
SELECT DISTINCT name, year
FROM names
WHERE year IN '2009';


JOIN names ON names.name = pop_change.name 
