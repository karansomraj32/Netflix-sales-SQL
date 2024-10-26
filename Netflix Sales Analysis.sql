-- Netflix Project --
CREATE TABLE netflix
(
show_id	VARCHAR(6),
type VARCHAR (10),	
title VARCHAR(150),	
director VARCHAR(208),	
casts VARCHAR (1000),	
country	VARCHAR (150),
date_added	VARCHAR (50),
release_year INT,
rating	VARCHAR (10),
duration	VARCHAR (15),
listed_in	VARCHAR (100),
description  VARCHAR (250)
);

SELECT * 
FROM netflix ;

select count(*)
from netflix ;

-- problems--

--1. Count the numbers of movies vs tv shows--

SELECT type , 
       count(*)as total_content
from netflix 
group by type

--2. Find he most common ratings for movies and tv shows--

select
     type,
	 rating
FROM 
(
select 
     type,
     rating,
   COUNT(*),
    RANK() OVER(PARTITION BY type ORDER BY COUNT(*) desc) as ranking
from netflix
group by 1,2
) as t1
where ranking = 1

--3. List all movies released in a specific year (e.g. 2000)

-- filter 2020
-- movies

select * from netflix
where 
    type = 'Movie' 
	and 
	release_year=2020

--4. Find the top 5 countries with the most contents on Netflix--

select 
UNNEST(STRING_TO_ARRAY(country,','))as new_country,
COUNT(show_id)as total_content
from netflix
group by 1
order by 2 desc
limit 5

--5. Indentify the longest movie--

SELECT * FROM netflix
WHERE
     type = 'Movie'
     AND
	 duration = (SELECT MAX (duration)FROM netflix)

--6. Find content added in the last 5 years --

SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE-INTERVAL '5 years'

--7. Find all the movies/tv shows by director 'Rajiv Chilaka'--

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

--8. List all tv shows with more than 5 seasons --

SELECT *
FROM netflix
WHERE type = 'TV Show'
      AND
      SPLIT_PART(duration, ' ',1)::numeric >5 

--9. Count the number of content items in each genre --

SELECT 
    UNNEST(STRING_TO_ARRAY( listed_in,',' ))as genre,
	COUNT(show_id)as total_content
FROM netflix
group by 1

--10. Find each year and the average numbers of content release by India on netflix.Return top 5 year with highest avg content release --

total content 333/972

SELECT
     EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD , YYYY'))AS year,
	 COUNT (*)AS yearly_content,
	 ROUND (
	 COUNT (*):: numeric/(SELECT COUNT (*)FROM netflix WHERE country = 'India'):: numeric* 100 , 2)AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

--11. List all movies that are documentaries--

SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--12. Find all content without a director --

SELECT *
FROM netflix
WHERE director IS NULL

--13. Find in how many movies 'Salman Khan'appeared in last 10 years -- 

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
      AND
	  release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Find the top 10 actors who have appeared in the hightest number of movies produced in India--

SELECT
UNNEST(STRING_TO_ARRAY(casts,','))as actors,
COUNT (*)AS total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15. Categorize the content based on the presence of the keyword 'kill' and 'violence' in the description field.Label content containing these keywords as 'Bad'and all other content as 'Good'. Count how many items fall into each category.--

WITH new_table AS 
(
SELECT *,
CASE
   WHEN description ILIKE '%kill%' OR
        description ILIKE 'violence' THEN 'Bad_content'
		ELSE 'Good_content'
	END AS category
FROM netflix
)
SELECT 
     category,
	 COUNT (*)AS total_content
FROM new_table
GROUP BY 1
