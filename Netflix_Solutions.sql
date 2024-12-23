-- Netflix Project

DROP table if exists Netflix;

CREATE TABLE Netflix (
    show_id VARCHAR(7),
    show_type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(210),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(150),
    descriptions VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
	COUNT(*) total_rows 
FROM netflix;

SELECT DISTINCT show_type FROM netflix;

-- 15 Business Problems with Solutions:

-- 1. Count the number of Movies vs TV Shows

SELECT 
	show_type , count(*) "Number of Movies vs TV Shows" 
FROM netflix
GROUP BY show_type;

-- 2. Find the most common rating for movies and TV shows

SELECT 
	show_type,
	rating,
	rating_count,
	ranking
FROM (
	SELECT
		show_type,
		rating, count(*) "rating_count",
		RANK() OVER(PARTITION BY show_type ORDER BY count(*) DESC) as RANKING
	FROM netflix
	GROUP BY show_type, rating) as temp_table
WHERE 
	ranking=1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
	*
FROM 
	netflix
WHERE
	show_type = 'Movie' AND release_year =2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country, 
	COUNT(show_id) as "total_content"
FROM netflix
GROUP BY new_country
ORDER BY "total_content" DESC
LIMIT 5;

/* 
	IF YOUR COLUMNS DON'T HAVE MULTIPLE COUNTRY IN ONE CELL

		SELECT 
			country , COUNT(show_id) as "Netflix_content_count"
		FROM
			netflix
		GROUP BY country
		ORDER BY "Netflix_content_count" DESC
		LIMIT 5;
*/

-- 5. Identify the longest movie

SELECT *
FROM netflix
ORDER BY CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) DESC
LIMIT 1;

-- OR -- 

SELECT *,CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) int_duration 
FROM netflix
WHERE 
	show_type='Movie'
ORDER BY int_duration DESC
LIMIT 1;

/*
IF YOUR VALUES ARE OF INTEGER TYPE
	SELECT *
	FROM netflix
	WHERE
		show_type='Movie' AND duration=(SELECT MAX(duration) from netflix)
	ORDER BY duration DESC
	LIMIT 1;
*/

-- 6. Find content added in the last 5 years

SELECT *
	FROM netflix
WHERE CAST(date_added AS DATE)>= CURRENT_DATE - INTERVAL '5 years';

-- OR

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director ILike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE
	show_type = 'TV Show' AND
	CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) > 5
ORDER BY CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) DESC;

-- OR --

SELECT *
FROM netflix
WHERE
	show_type = 'TV Show' AND
	SPLIT_PART(duration, ' ',1)::NUMERIC>5
ORDER BY duration DESC;

-- 9. Count the number of content items in each genre

SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre, count(show_type) as "Content_Pieces"
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','))
ORDER BY count(show_type) DESC;

/* 10.Find each year and the average numbers of content release in India on netflix
return top 5 year with highest avg content release!*/

WITH date_format_table AS
	(
	SELECT CAST(date_added AS DATE) "DATE",*
	FROM netflix
	)
Select EXTRACT(YEAR FROM "DATE") AS "Year", COUNT(*), ROUND(COUNT(*)::numeric/(SELECT count(*) FROM netflix WHERE country ILIKE '%India%')*100 ,0) as avg_release_per_year
FROM date_format_table
WHERE country ILIKE '%India%'
GROUP BY 1;
;

--OR --

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')),
	COUNT(*), 
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')*100 ,0) as avg_release_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1;

-- 11. List all movies that are documentaries

SELECT *
FROM netflix 
WHERE 
	show_type= 'Movie' AND
	listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director

SELECT *
FROM netflix 
WHERE 
	director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix 
WHERE 
	casts ILIKE '%Salman Khan%' AND
	release_year>= EXTRACT(YEAR FROM CURRENT_DATE)-10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT UNNEST(STRING_TO_ARRAY(casts,',')) as "indian_actor", count(*) as "total_movies"
FROM netflix
WHERE 
	country ILIKE '%India%' AND
	show_type='Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* 15. Categorize the content based on the presence of the keywords 'kill' or 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/


WITH new_table AS(
	SELECT 
		CASE
		WHEN descriptions ILIKE '% kill%' OR descriptions ILIKE '% violen%' THEN 'Bad Content'
		ELSE 'Good Content'
		END as "Content_Categorization",
		title,
		show_id,
		descriptions
	FROM netflix
	ORDER BY "Content_Categorization" ASC)
SELECT "Content_Categorization", count(*) as "Count"
FROM new_table
GROUP BY "Content_Categorization";

-- OR --

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN descriptions ILIKE '% kill%' OR descriptions ILIKE '% violen%' THEN 'Bad Contet'
            ELSE 'Good Content'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
