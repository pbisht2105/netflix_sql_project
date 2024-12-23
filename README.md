# Netflix Movies and TV Shows Data Analysis Using SQL
![Netflix Logo](https://github.com/pbisht2105/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	show_type,
	count(*) "Number of Movies vs TV Shows" 
FROM netflix
GROUP BY show_type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
    show_type,
    rating,
    rating_count,
    ranking
FROM (
    SELECT
        show_type,
        rating, 
        COUNT(*) AS "rating_count",
        RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY show_type, rating
) AS temp_table
WHERE 
    ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT 
    *
FROM 
    netflix
WHERE
    show_type = 'Movie' 
    AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, 
    COUNT(show_id) AS "total_content"
FROM netflix
GROUP BY new_country
ORDER BY "total_content" DESC
LIMIT 5;

-- OR --

SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, 
    COUNT(show_id) AS "total_content"
FROM netflix
GROUP BY new_country
ORDER BY "total_content" DESC
LIMIT 5;
```
```sql
-- IF YOUR COLUMNS DON'T HAVE MULTIPLE COUNTRY IN ONE CELL

SELECT 
    country, 
    COUNT(show_id) AS "Netflix_content_count"
FROM
    netflix
GROUP BY country
ORDER BY "Netflix_content_count" DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT *
FROM netflix
ORDER BY CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) DESC
LIMIT 1;

-- OR --

SELECT *, CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) AS int_duration 
FROM netflix
WHERE 
    show_type = 'Movie'
ORDER BY int_duration DESC
LIMIT 1;
```
```sql
-- IF YOUR VALUES ARE OF INTEGER TYPE
SELECT *
FROM netflix
WHERE
    show_type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE CAST(date_added AS DATE) >= CURRENT_DATE - INTERVAL '5 years';

-- OR --

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE
    show_type = 'TV Show' 
    AND CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) > 5
ORDER BY CAST(LEFT(duration, POSITION(' ' IN duration) - 1) AS INTEGER) DESC;

-- OR --

SELECT *
FROM netflix
WHERE
    show_type = 'TV Show' 
    AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5
ORDER BY duration DESC;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
    COUNT(show_type) AS "Content_Pieces"
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','))
ORDER BY COUNT(show_type) DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*), 
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%') * 100, 0) AS avg_release_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY year;

-- OR --

WITH date_format_table AS
	(
	SELECT CAST(date_added AS DATE) "DATE",*
	FROM netflix
	)
Select EXTRACT(YEAR FROM "DATE") AS "Year", COUNT(*), ROUND(COUNT(*)::numeric/(SELECT count(*) FROM netflix WHERE country ILIKE '%India%')*100 ,0) as avg_release_per_year
FROM date_format_table
WHERE country ILIKE '%India%'
GROUP BY 1;

```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix 
WHERE 
    show_type = 'Movie' 
    AND listed_in ILIKE '%documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix 
WHERE 
    director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix 
WHERE 
    casts ILIKE '%Salman Khan%' 
    AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS "indian_actor", 
    COUNT(*) AS "total_movies"
FROM netflix
WHERE 
    country ILIKE '%India%' 
    AND show_type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH new_table AS (
	SELECT 
		CASE
    		WHEN descriptions ILIKE '% kill%' OR descriptions ILIKE '% violen%' THEN 'Bad Content'
    		ELSE 'Good Content'
		END as "Content_Categorization",
		title,
		show_id,
		descriptions
	FROM netflix
	ORDER BY "Content_Categorization" ASC
)
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
            WHEN descriptions ILIKE '% kill%' OR descriptions ILIKE '% violen%' THEN 'Bad Content'
            ELSE 'Good Content'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset includes a wide variety of movies and TV shows with different ratings and genres.
- **Common Ratings:** Analyzing the most frequent ratings helps us understand the intended audience for the content.
- **Geographical Insights:** The top countries and the average number of content releases from India provide a clearer picture of regional content distribution.
- **Content Categorization:** Organizing the content using specific keywords gives us a better understanding of the types of content available on Netflix.


This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Author

This project was created and maintained by [Pankaj Singh Bisht](https://github.com/pbisht2105).

You can contact me at: [pbisht2105@gmail.com](mailto:pbisht2105@gmail.com).
