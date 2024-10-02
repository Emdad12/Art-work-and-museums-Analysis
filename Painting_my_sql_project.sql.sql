-- 1.Fetch all the paintings which are not displayed on any museums?
SELECT *
FROM works
WHERE museum_id IS NULL;
-- 2.Are there museums without any paintings?
SELECT *
FROM museum m
WHERE NOT EXISTS (SELECT 1 FROM works w WHERE w.museum_id = m.museum_id);

-- 3.How many paintings have an asking price of more than their regular price?

SELECT COUNT(*) AS No_of_painting
FROM works w
JOIN product_size ps
ON w.work_id= ps.work_id
WHERE ps.sale_price < ps.regular_price;

-- 4.Identify the paintings whose asking price is less than 50% of its regular price
SELECT * 
FROM works w
JOIN product_size ps
ON w.work_id = ps.work_id
WHERE ps.sale_price < 0.5*ps.regular_price ;

-- 5.Which canva size costs the most?
SELECT cs.label AS canva,ps.sale_price
FROM (SELECT * ,
RANK() OVER( ORDER BY sale_price DESC) AS ranks
 FROM product_size ) AS ps
JOIN canvas_size AS cs
ON cs.size_id=ps.size_id
WHERE ps.ranks=1;
-- alternative 1
SELECT cs.label,ps.sale_price
FROM canvas_size AS cs
JOIN product_size AS ps
ON cs.size_id=ps.size_id
WHERE ps.sale_price = (SELECT MAX(sale_price)
					   FROM product_size) ;
 -- 6.Delete duplicate records from works
 SET SQL_SAFE_UPDATES = 0;
 WITH rankworks AS (
 SELECT work_id,
 ROW_NUMBER() OVER(PARTITION BY work_id ORDER BY work_id) AS rn
 FROM works)
 DELETE w
 FROM works w
 JOIN rankworks rw
 ON w.work_id=rw.work_id
 WHERE rw.rn>1;
 SET SQL_SAFE_UPDATES = 1;
 
 -- 7.Identify the museums with invalid city information in the given dataset
 SELECT *
 FROM museum
 WHERE city IS NULL OR 
 city='' OR 
 city REGEXP '^[0-9]+$';
 
-- 8. Fetch the top 10 most famous painting subject
SELECT subject,ranks,subject_count
FROM (
    SELECT s.subject,
           COUNT(*) AS subject_count,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS ranks
    FROM subject AS s
    JOIN works AS w
    ON s.work_id = w.work_id
    GROUP BY s.subject) AS ranked_subjects
WHERE ranks BETWEEN 1 AND 10;
-- 
select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from works w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;

-- 9.Identify the museums which are open on both Sunday and Monday. Display museum name, city.
SELECT m.name ,m.city
FROM museum m
JOIN museum_hours mh
ON m.museum_id = mh.museum_id
WHERE mh.day ='Sunday' AND 
                       EXISTS (SELECT museum_id
                       FROM museum_hours mh2
                       WHERE mh.museum_id=mh2.museum_id
                       AND mh2.day='Monday');
-- 10.How many museums are open every single day?
SELECT COUNT(*) AS num_museums_open_every_day
FROM (
    SELECT mh.museum_id
    FROM museum_hours mh
    GROUP BY mh.museum_id
    HAVING COUNT(DISTINCT mh.day) = 7
) AS open_every_day;

-- 11.Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT m.name,m.city,m.country,x.no_of_painting
FROM( SELECT m.museum_id,COUNT(*) AS no_of_painting,
RANK() OVER(ORDER BY COUNT(*) DESC) AS ranks
FROM works w
JOIN museum m
ON w.museum_id=m.museum_id
GROUP BY museum_id)
AS x
JOIN museum m 
ON m.museum_id=x.museum_id
WHERE x.ranks <=5;
 
 -- 12.Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

 SELECT a.artist_id,a.full_name,a.nationality,a.style,x.no_of_paintings
 FROM ( SELECT w.artist_id,COUNT(*) AS no_of_paintings,
       RANK() OVER(ORDER BY COUNT(*) DESC) AS ranks
       FROM works w
       JOIN artist a
       ON w.artist_id=a.artist_id
       GROUP BY w.artist_id)
       AS x
 JOIN artist a
 ON x.artist_id=a.artist_id
 WHERE x.ranks <= 5;
 -- 13.Display the 3 least popular canva sizes
 SELECT cs.*,x.frequency
 FROM(SELECT ps.size_id,COUNT(*) AS frequency,
      RANK() OVER(ORDER BY COUNT(*)) AS ranks
      FROM product_size ps
      JOIN canvas_size cs
      ON ps.size_id=cs.size_id
      GROUP BY ps.size_id)
AS x
JOIN canvas_size cs
ON cs.size_id= x.size_id
WHERE x.ranks <=3;
-- 14.Identify the artists whose paintings are displayed in multiple countries
SELECT a.full_name AS artist_name,
       COUNT(DISTINCT m.country) AS country_count
FROM artist a
JOIN works w ON a.artist_id = w.artist_id
JOIN museum m ON w.museum_id = m.museum_id
GROUP BY a.artist_id, a.full_name
HAVING COUNT(DISTINCT m.country) > 1;
/* 15. Identify the artist and the museum where the most expensive and least expensive
painting is placed. Display the artist name, sale_price, painting name, museum
name, museum city and canvas label*/
 WITH cte AS (
    SELECT ps.work_id, ps.size_id, ps.sale_price,
           RANK() OVER (ORDER BY ps.sale_price DESC) AS rnk,
           RANK() OVER (ORDER BY ps.sale_price ASC) AS rnk_asc
    FROM product_size ps
)
SELECT w.name AS painting,cte.sale_price,a.full_name AS artist,m.name AS museum,m.city,cz.label AS canvas
FROM cte
JOIN works w 
ON w.work_id = cte.work_id
JOIN museum m 
ON m.museum_id = w.museum_id
JOIN artist a 
ON a.artist_id = w.artist_id
JOIN canvas_size cz 
ON cz.size_id = cte.size_id
WHERE cte.rnk = 1 OR cte.rnk_asc = 1;

-- 16. Which country has the 5th highest no of paintings?
SELECT *
FROM( SELECT m.country,COUNT(*) AS no_of_paintings,
     DENSE_RANK () OVER(ORDER BY COUNT(*) DESC) AS ranks
     FROM museum m
     JOIN works w
     ON m.museum_id=w.museum_id
     GROUP BY m.country)
     AS x
     WHERE x.ranks=5;
-- 17.Which are the 3 most popular and 3 least popular painting styles?
-- 3 Most popular styles
SELECT style, COUNT(*) AS frequency
FROM works
GROUP BY style
ORDER BY frequency DESC
LIMIT 3;
-- 3 Least popular styles
SELECT style, COUNT(*) AS frequency
FROM works
GROUP BY style
ORDER BY frequency ASC
LIMIT 3;
-- ALternative
SELECT *,'Most Popular' AS Popularity
FROM( SELECT style ,COUNT(*) AS total_paintings,
     DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS ranks
     FROM works
     GROUP BY style)
     AS x
where x.ranks<=3
UNION ALL
(SELECT *,'Least Popular' AS Popularity
FROM( SELECT style ,COUNT(*) AS total_paintings,
     DENSE_RANK() OVER(ORDER BY COUNT(*)) AS ranks
     FROM works
     GROUP BY style)
     AS x
where x.ranks<=3);

-- 18. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality
SELECT full_name,painting_count,nationality
FROM (SELECT a.full_name,a.nationality,COUNT(*) AS painting_count,
      RANK () OVER (ORDER BY COUNT(*) DESC) AS ranks
      FROM works w
      JOIN artist a
      ON w.artist_id = a.artist_id
      JOIN museum m
      ON m.museum_id = w.museum_id
      JOIN subject s
      ON s.work_id = w.work_id
      WHERE m.country <> 'USA'
      AND s.subject ='Portraits'
      GROUP BY a.full_name,a.nationality
      ) AS x
 WHERE x.ranks = 1;

      

      


      


                        







                           