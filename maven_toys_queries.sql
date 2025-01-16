---- QUERIES ----

-- Q1) Order the product table first by category name alphabetically and then by price in descending 
--     order to prioritize the most expensive items.

SELECT 
	*
FROM product
ORDER BY product_category, product_price DESC;

-- Q2) List each store's out-of-stock products with product names.
--     *RESTRICTION: Remove "Maven Toys" from each store name and 
--	    replace any Latin numerals with their corresponding Roman numerals.*

SELECT 
	CASE
		WHEN store_name LIKE '%1' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'1','I')
		WHEN store_name LIKE '%2' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'2','II')
		WHEN store_name LIKE '%3' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'3','III')
		WHEN store_name LIKE '%4' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'4','IV')
	END AS store_names,
	i.product_id,
	product_name
FROM stores AS s
JOIN inventory AS i
	ON s.store_id = i.store_id
JOIN product AS p
	ON i.product_id = p.product_id
WHERE stock_on_hand = 0
ORDER BY store_names, i.product_id;


-- Q3) List the top 3 stores that made the most sales among the stores that were opened 
--     between 2005-01-01 and 2010-01-01. Note: Use the same restriction on storenames 
--     as the one we used in the first question.

SELECT
	CASE
		WHEN store_name LIKE '%1' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'1','I')
		WHEN store_name LIKE '%2' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'2','II')
		WHEN store_name LIKE '%3' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'3','III')
		WHEN store_name LIKE '%4' THEN REPLACE(REPLACE(store_name, 'Maven Toys ', ''),'4','IV')
	END AS store_names,
	store_open_date,
	COUNT(sales_id)
FROM sales AS sa
JOIN stores AS st
	ON sa.store_id = st.store_id
WHERE store_open_date BETWEEN '2005-01-01' AND '2010-01-01'
GROUP BY store_names, store_open_date
ORDER BY COUNT(sales_id) DESC
LIMIT 3;

-- Q4) In which city, did the company make the most profit by "Sports & Outdoors" category?


SELECT 
	store_city AS city,
	SUM((product_price-product_cost)*units) AS  profit
FROM sales AS sa
JOIN stores AS st 
	ON sa.store_id = st.store_id
JOIN product AS p
	ON p.product_id = sa.product_id
WHERE product_category = 'Sports & Outdoors'
GROUP BY store_city
ORDER BY SUM((product_price-product_cost)*units) DESC
LIMIT 1;



-- Q5) Which product categories drive the biggest profits? Is this the same across store locations?

WITH sales_profit_data AS (
    SELECT 
        sales_id,
        date,
        store_location,
        s.product_id,
        product_category,
        units,
        product_cost,
        product_price,
        ROUND(((product_price - product_cost) * units)::NUMERIC, 2) AS profit
    FROM sales AS s
    LEFT JOIN product AS p
        ON s.product_id = p.product_id
    LEFT JOIN stores AS st
        ON s.store_id = st.store_id
)


SELECT -- Which category drive the biggest profit?
	product_category,
	SUM(profit) AS total_profit
FROM sales_profit_data
GROUP BY product_category
ORDER BY total_profit DESC;


SELECT -- Which category drive the biggest profit in which 'store location'?
    store_location,
    product_category,
    SUM(profit) AS total_profit
FROM sales_profit_data
GROUP BY store_location, product_category
ORDER BY store_location, total_profit DESC;


-- Q6) Can you find any seasonal trends or patterns in the sales data?

WITH CTE AS (
	SELECT 
		sales_id,
		date,
		EXTRACT(MONTH FROM date) AS month,
		EXTRACT(QUARTER FROM date) AS quarter,
		store_location,
		product_category,
		units,
		product_cost,
		product_price,
		ROUND(((product_price - product_cost) * units)::NUMERIC, 2) AS profit
	FROM sales AS s
	LEFT JOIN product AS p
		ON s.product_id = p.product_id
	LEFT JOIN stores AS st
		ON st.store_id = s.store_id
)

/* 
	We can observe the seaosanal trends in many aspects. I preferred to observe these ones:

	* A) Total number of units sold by category per quarter	
	* B) Total profit per quarter.
	* C) Total profit per month.
*/
-- A) Total number of units sold by category per quarter	

SELECT
	quarter,
	product_category,
	RANK() OVER(PARTITION BY quarter ORDER BY SUM(units) DESC) AS category_rank,
	SUM(units) AS total_category_sales
FROM CTE
GROUP BY quarter, product_category
ORDER BY quarter, total_category_sales DESC; 

/* 
	At the beginning and end of the year (Q1 and Q4), "Games" ranks as the most sold category after 
	"Art & Crafts" and "Toys" In the middle of the year (Q2 and Q3), however, "Sports & Outdoors" 
	becomes the most preferred category after "Art & Crafts" and "Toys". 	
*/

-- B) Total profit per quarter

SELECT
	quarter,
	SUM(profit) AS total_profit
FROM CTE
GROUP BY quarter
ORDER BY quarter;

/*
	The total profit in the third and last quarters of the year is noticeably lower compared to the 
	first and second quarters. Additionally, it is evident that the profit at the end of the year is 
	the lowest overall.
*/

-- C) Total profit per month
SELECT
	month,
	SUM(profit) AS total_profit
FROM CTE
GROUP BY month
ORDER BY month;

/*
	This query also highlights a noticable decline in profit during the last quarter of the year. 
	The final three months, which make up the fourth quarter, rank as the top three months with the 
	lowest profit compared to all other months.
*/


-- Q7) How much money is tied up in inventory at the toy stores? How long will it last?	

WITH inventory_status AS (
	SELECT
		store_id,
		i.product_id,
		SUM(stock_on_hand) AS total_stock,
		product_price,
		SUM(stock_on_hand)*product_price AS value_contribution
	FROM inventory AS i
	JOIN product AS p
		ON p.product_id = i.product_id
	GROUP BY i.store_id, i.product_id, product_price
	HAVING SUM(stock_on_hand) != 0
),
sale_rates AS (
    SELECT 
		store_id, 
		ROUND((SUM(units*product_price) / (SELECT MAX(date) - MIN(date) FROM sales))::NUMERIC,2) AS sale_rate
	FROM sales AS s
	JOIN product AS p
		ON s.product_id = p.product_id
	GROUP BY store_id
),
inventory_values AS (
	SELECT 
		store_id,
		SUM(value_contribution) AS inv_value
	FROM inventory_status 
	GROUP BY store_id
)

SELECT
	inv.store_id,
	ROUND((inv_value/sale_rate)::NUMERIC,0) AS day_take
FROM inventory_values AS inv
JOIN sale_rates AS sr
	ON inv.store_id = sr.store_id
ORDER BY store_id;

/*
 This query calculates the amount of money tied up in inventory and estimates how many days it 
 will last based on current sales rates. The approach involves three main steps:
 
 1. `inventory_status`: Determine the total stock and its value contribution for each product 
 	in each store. This includes only items with stock on hand (non-zero).
	 
 2. `sale_rates`: Calculate the average daily sales rate for each store by dividing total sales
 	revenue by the duration of recorded sales data.
	 
 3. `inventory_values`: Compute the total inventory value for each store. Finally, the main query 
 	calculates the number of days the inventory would last (`day_take`) for each store by dividing
	the inventory value by the daily sales rate.
*/
