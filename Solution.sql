-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),	
	title VARCHAR(150),
	director VARCHAR(210),
	castS VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

COPY netflix 
FROM 'E:\New\netflix_titles.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM netflix;

SELECT
	COUNT(*) AS counter
FROM netflix;

--1. COUNT the no of movies vs tv shows
SELECT 
	type,
	COUNT(*) AS table_content
FROM netflix
GROUP BY type;

-- 2.Find the most common rating for movies and tv shows
SELECT 
	type,
	rating
FROM 
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1, 2
) as t1
WHERE 
	ranking = 1;

-- ORDER BY 1, 3 DESC;

-- 3. List all the movies in specific year

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;

-- 4. Find the top 5 countries with most content
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_countries,
	COUNT(show_id) as contents
FROM netflix
GROUP BY country
ORDER BY 2 DESC
LIMIT 5;

-- 5. Find the movies with highest duration
-- SELECT * FROM netflix
-- WHERE CAST(SUBSTRING_INDEX(duration, ' ', 1) AS INTEGER) = (
--     SELECT MAX(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS INTEGER))
--     FROM netflix
--     WHERE duration LIKE '%min'
-- );
    

SELECT *
FROM netflix
WHERE CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) = (
    SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER))
    FROM netflix
    WHERE duration LIKE '%min'
);


-- 6. Find contents added in last 5 years
SELECT 
	*
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years';

SELECT CURRENT_DATE - INTERVAL '5 years'

-- 7. find all the movies directed by 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE 
	director LIKE '%Rajiv Chilaka%'

-- 8. List all the series more than 5 seasons
SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1) ::numeric > 5  
	-- same as -> CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER))

-- 9. count the no of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) AS shows	
FROM netflix
GROUP BY 1
order by 2 desc;


-- 10. find each year avg contents released by india on netflix return best 5

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS release_year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric * 100
	, 2) AS avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1;

-- 11. list all the documentaries

SELECT 
	* 
FROM netflix
WHERE 
	listed_in LIKE '%Documentaries%'
	-- or WE CAN USE -> ILIKE where case sensitivity removes

-- 12. how many movies salman khan appeared in last 10 years
SELECT * FROM netflix
WHERE 
	castS ILIKE '%salman khan%'
	AND 
	-- TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '10 years'
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10


-- SELECT CURRENT_DATE - INTERVAL '10 Years'

-- 13. Find top 10 actors appeared in highset movies produced in india
SELECT 
	UNNEST(STRING_TO_ARRAY(castS, ',')) as actors,
	COUNT(*) AS total_content
FROM netflix
WHERE 
	country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 14. mark description where 'kill' or 'violence' used mark them as bad-content and else good
WITH new_table
AS
(
SELECT 
	*,
	CASE
		WHEN
			description ILIKE '%KILL%'
		OR
			description ILIKE '%Violence%'
				THEN 'bad_content'
			ELSE 'good_content'
		END category
FROM netflix
)	SELECT 
		category,
		COUNT(*) AS total_content
	FROM new_table
	GROUP BY 1;
	











