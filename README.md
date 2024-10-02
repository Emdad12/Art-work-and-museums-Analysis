# Artworks and Museums Analysis

## Overview
This repository contains SQL-based analysis performed on a dataset of museums, artists, and paintings. The analysis includes identifying popular artists, museum statistics, painting styles, and pricing trends.

## Datasets
- **museum**: Contains details about various museums, including their name, location, and country.
- **artist**: Includes information about artists, such as their full name, nationality, and painting style.
- **works**: Contains data about individual paintings, including the artist, painting style, museum location, and sale price.
- **product_size**: Information about the canvas size of the artworks, including dimensions and pricing.
- **museum_hours**: Hours of operation for various museums.
- **subject**:Information about the painting subject
- **canvas_size**:Contains canvas width,height,label
- **image_link**:Includes information painting image

## Key Analyses

### 1. **Most Popular Artists**
- Identified the top 5 most popular artists based on the number of paintings.

### 2. **Most Popular Museums**
- Found the top museums based on the number of paintings they house.

### 3. **Canvas Size and Painting Pricing**
- Analyzed the most and least expensive paintings and the canvas sizes associated with them.

### 4. **Museum with No Paintings**
- Found museums that don’t currently house any paintings.

### 5. **Artists with Paintings in Multiple Countries**
- Identified artists whose works are displayed in museums across multiple countries.

## SQL Queries
The SQL queries used in the analysis can be found in the [SQL Queries](SQL Queries) folder.

### Example Queries:
- **1. Fetch all the paintings which are not displayed on any museums?**:
  ```sql
  SELECT artist.full_name, COUNT(*) AS num_paintings
  FROM works
  JOIN artist ON works.artist_id = artist.artist_id
  GROUP BY artist.full_name
  ORDER BY num_paintings DESC
  LIMIT 5;
  ```
 Output:There are 5587 painting which are not displayed any museums 
- **2. Are there museums without any paintings?**:
  ```sql
  SELECT m.name, m.city
  FROM museum m
  WHERE NOT EXISTS (SELECT 1 FROM works w WHERE w.museum_id = m.museum_id);
  ```
 Output: Yes,there are 16 musuems without painting  
- **3. How many paintings have an asking price of more than their regular price?**  
```sql
SELECT COUNT(*) AS No_of_painting
FROM works w
JOIN product_size ps
ON w.work_id= ps.work_id
WHERE ps.sale_price > ps.regular_price;
```
Output:There are no painting have an asking price of more than their regular price 
- **4. Identify the paintings whose asking price is less than 50% of its regular price** 
```sql
SELECT * 
FROM works w
JOIN product_size ps
ON w.work_id = ps.work_id
WHERE ps.sale_price < 0.5*ps.regular_price ;
```
Output:
| work_id | name                                             | artist_id | style          | museum_id | work_id | size_id | sale_price | regular_price |
|---------|--------------------------------------------------|-----------|----------------|-----------|---------|---------|------------|---------------|
| 31780   | Portrait of Madame Labille-Guyard and Her Pupils | 621       | Neo-Classicism | 35        | 31780   | 30      | 10         | 95            |
| 31780   | Portrait of Madame Labille-Guyard and Her Pupils | 621       | Neo-Classicism | 35        | 31780   | 36      | 10         | 125           |
| 31780   | Portrait of Madame Labille-Guyard and Her Pupils | 621       | Neo-Classicism | 35        | 31780   | 30      | 10         | 95            |
| 31780   | Portrait of Madame Labille-Guyard and Her Pupils | 621       | Neo-Classicism | 35        | 31780   | 36      | 10         | 125           |

- **5. Which canva size costs the most?** 
```sql
SELECT cs.label AS canva,ps.sale_price
FROM (SELECT * ,
RANK() OVER( ORDER BY sale_price DESC) AS ranks
 FROM product_size ) AS ps
JOIN canvas_size AS cs
ON cs.size_id=ps.size_id
WHERE ps.ranks=1;
```
- **6. Delete duplicate records from works**
```sql
 WITH rankworks AS (
 SELECT work_id,
 ROW_NUMBER() OVER(PARTITION BY work_id ORDER BY work_id) AS rn
 FROM works)
 DELETE w
 FROM works w
 JOIN rankworks rw
 ON w.work_id=rw.work_id
 WHERE rw.rn>1;
```
- **7. Identify the museums with invalid city information in the given dataset**  
```sql
SELECT *
 FROM museum
 WHERE city IS NULL OR 
 city='' OR 
 city REGEXP '^[0-9]+$';
```
Output:
| museum_id | name                             | address               | city  | state           | postal | country | phone            | url                                                           |
|-----------|----------------------------------|-----------------------|-------|-----------------|--------|---------|------------------|---------------------------------------------------------------|
| 34        | The State Hermitage Museum       | Palace Square         | 2     | Sankt-Peterburg | 190000 | Russia  | 7 812 710-90-79  | https://www.hermitagemuseum.org/wps/portal/hermitage/         |
| 36        | Museum Folkwang                  | Museumsplatz 1        | 45128 | Essen           |        | Germany | 49 201 8845000   | https://www.museum-folkwang.de/en                             |
| 37        | Museum of Grenoble               | 5 Pl. de Lavalette    | 38000 | Grenoble        |        | France  | 33 4 76 63 44 44 | https://www.museedegrenoble.fr/1986-the-museum-in-english.htm |
| 38        | MusÃ©e des Beaux-Arts de Quimper | 40 Pl. Saint-Corentin | 29000 | Quimper         |        | France  | 33 2 98 95 45 20 | https://www.mbaq.fr/en/home-3.html                            |
| 40        | MusÃ©e du Louvre                 | Rue de Rivoli         | 75001 | Paris           |        | France  | 33 1 40 20 50 50 | https://www.louvre.fr/en                                      |
- **8. Fetch the top 10 most famous painting subject.**
```sql
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
```
Output:
| subject             | ranks | subject_count |
|---------------------|-------|---------------|
| Portraits           | 1     | 677           |
| Landscape Art       | 2     | 396           |
| Abstract/Modern Art | 3     | 338           |
| Marine Art/Maritime | 4     | 257           |
| Rivers/Lakes        | 5     | 249           |
| Nude                | 6     | 240           |
| Flowers             | 7     | 220           |
| Still-Life          | 8     | 212           |
| Horses              | 9     | 188           |
| Seascapes           | 10    | 167           |

- **9. Identify the museums which are open on both Sunday and Monday.Display museum name, city.**
```sql
SELECT m.name ,m.city
FROM museum m
JOIN museum_hours mh
ON m.museum_id = mh.museum_id
WHERE mh.day ='Sunday' AND 
                       EXISTS (SELECT museum_id
                       FROM museum_hours mh2
                       WHERE mh.museum_id=mh2.museum_id
                       AND mh2.day='Monday');
```
Output:
| name                              | city         |
|-----------------------------------|--------------|
| The Museum of Modern Art          | New York     |
| Pushkin State Museum of Fine Arts | Moscow       |
| National Gallery of Victoria      | Melbourne    |
| The Metropolitan Museum of Art    | New York     |
| Museum of Grenoble                | 38000        |
| Nelson-Atkins Museum of Art       | Kansas City  |
| MusÃ©e du Louvre                  | 75001        |
| National Maritime Museum          | London       |
| Museum of Fine Arts Boston        | Boston       |
| Rijksmuseum                       | Amsterdam    |
| Israel Museum                     | Jerusalem    |
| National Gallery of Art           | Washington   |
| National Gallery                  | London       |
| Mauritshuis Museum                | Den Haag     |
| The Prado Museum                  | Madrid       |
| The Barnes Foundation             | Philadelphia |
| Van Gogh Museum                   | Amsterdam    |
| Los Angeles County Museum of Art  | Los Angeles  |
| Solomon R. Guggenheim Museum      | New York     |
| The Tate Gallery                  | London       |
| Museum of Fine Arts of Nancy      | Nancy        |
| Smithsonian American Art Museum   | Washington   |
| Philadelphia Museum of Art        | Philadelphia |
| The Art Institute of Chicago      | Chicago      |
| Army Museum                       | Paris        |
| National Gallery Prague           | NovÃ© MÄ›st  |
| Norton Simon Museum               | Pasadena     |
| Courtauld Gallery                 | Stran        |
- **10. How many museums are open every single day?**
```sql
SELECT COUNT(*) AS num_museums_open_every_day
FROM (
    SELECT mh.museum_id
    FROM museum_hours mh
    GROUP BY mh.museum_id
    HAVING COUNT(DISTINCT mh.day) = 7
) AS open_every_day;
```

- **11. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)**
```sql
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
```

- **12. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)**
```sql
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
```

- **13. Display the 3 least popular canva sizes**
```sql
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
```
- **14. Identify the artists whose paintings are displayed in multiple countries**
```sql
SELECT a.full_name AS artist_name,
       COUNT(DISTINCT m.country) AS country_count
FROM artist a
JOIN works w ON a.artist_id = w.artist_id
JOIN museum m ON w.museum_id = m.museum_id
GROUP BY a.artist_id, a.full_name
HAVING COUNT(DISTINCT m.country) > 1;
```

- **15. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum 
 city and canvas label**
```sql
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
```
- **16. Which country has the 5th highest no of paintings?**
```sql
SELECT *
FROM( SELECT m.country,COUNT(*) AS no_of_paintings,
     DENSE_RANK () OVER(ORDER BY COUNT(*) DESC) AS ranks
     FROM museum m
     JOIN works w
     ON m.museum_id=w.museum_id
     GROUP BY m.country)
     AS x
     WHERE x.ranks=5;
```

- **17. Which are the 3 most popular and 3 least popular painting styles?**
```sql
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
```

- **18. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality**
```sql
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
```
## Tools Used
- MySQL Workbench
- GitHub for version control
- SQL for database querying and analysis

## How to Use
Clone the repository and use the SQL queries in any MySQL-compatible database system. You can adjust the queries to explore the data further or apply them to similar datasets.

## Future Work
- Incorporating machine learning for price prediction based on painting attributes.
- Further analysis of painting styles across different time periods.














