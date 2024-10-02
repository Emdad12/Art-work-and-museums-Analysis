# Art work and museums Analysis
## Overview
This repository contains SQL-based analysis performed on a dataset of museums, artists, and paintings. The analysis includes identifying popular artists, museum statistics, painting styles, and pricing trends.
# Artworks and Museums Analysis

## Overview
This repository contains SQL-based analysis performed on a dataset of museums, artists, and paintings. The analysis includes identifying popular artists, museum statistics, painting styles, and pricing trends.

## Datasets
- **museum**: Contains details about various museums, including their name, location, and country.
- **artist**: Includes information about artists, such as their full name, nationality, and painting style.
- **works**: Contains data about individual paintings, including the artist, painting style, museum location, and sale price.
- **product_size**: Information about the canvas size of the artworks, including dimensions and pricing.
- **museum_hours**: Hours of operation for various museums.

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
- **1.Fetch all the paintings which are not displayed on any museums?**:
  ```sql
  SELECT artist.full_name, COUNT(*) AS num_paintings
  FROM works
  JOIN artist ON works.artist_id = artist.artist_id
  GROUP BY artist.full_name
  ORDER BY num_paintings DESC
  LIMIT 5;
  ```
 Output:There are 5789 painting  
- **2.Are there museums without any paintings?**:
  ```sql
  SELECT m.name, m.city
  FROM museum m
  WHERE NOT EXISTS (SELECT 1 FROM works w WHERE w.museum_id = m.museum_id);
  ```
 Output: Yes,there are 16 musuems without painting  
-**3.How many paintings have an asking price of more than their regular price?**  
```sql
SELECT COUNT(*) AS No_of_painting
FROM works w
JOIN product_size ps
ON w.work_id= ps.work_id
WHERE ps.sale_price > ps.regular_price;
```
Output:There are no painting  
-**4.Identify the paintings whose asking price is less than 50% of its regular price  
```sql
SELECT * 
FROM works w
JOIN product_size ps
ON w.work_id = ps.work_id
WHERE ps.sale_price < 0.5*ps.regular_price ;
```
Output:  
-**5. Which canva size costs the most?  
```sql
SELECT cs.label AS canva,ps.sale_price
FROM (SELECT * ,
RANK() OVER( ORDER BY sale_price DESC) AS ranks
 FROM product_size ) AS ps
JOIN canvas_size AS cs
ON cs.size_id=ps.size_id
WHERE ps.ranks=1;
```
-**6.Delete duplicate records from work, product_size, subject and image_link tables**
```sql





-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
-****
































## Tools Used
- MySQL Workbench
- GitHub for version control
- SQL for database querying and analysis

## How to Use
Clone the repository and use the SQL queries in any MySQL-compatible database system. You can adjust the queries to explore the data further or apply them to similar datasets.

## Future Work
- Incorporating machine learning for price prediction based on painting attributes.
- Further analysis of painting styles across different time periods.














