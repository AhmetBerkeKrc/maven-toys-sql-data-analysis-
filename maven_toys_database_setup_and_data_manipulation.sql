---- DATABASE SETUP ----
CREATE SCHEMA maven_toys;

SET search_path = maven_toys;

-- calendar.csv

DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar (
	date VARCHAR(10)
);

SELECT * FROM calendar
LIMIT 50;

-- data_dict.csv

DROP TABLE IF EXISTS data_dict;

CREATE TABLE data_dict (
	tbl VARCHAR(9),
	field VARCHAR(16),
	description TEXT
);

SELECT * FROM data_dict
LIMIT 50;

-- inventory.csv

DROP TABLE IF EXISTS inventory;

CREATE TABLE inventory (
	store_id INTEGER REFERENCES stores(store_id),
	product_id INTEGER REFERENCES product(product_id),
	stock_on_hand INTEGER
);

SELECT * FROM inventory
LIMIT 50;

-- products.csv

DROP TABLE IF EXISTS product;

CREATE TABLE product (
	product_id INTEGER PRIMARY KEY,
	product_name VARCHAR(21),
	product_category VARCHAR(17),
	product_cost TEXT,
	product_price TEXT
);

SELECT * FROM product
LIMIT 50;

-- sales.csv

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
	sales_id INTEGER PRIMARY KEY,
	date VARCHAR(10),
	store_id INTEGER REFERENCES stores(store_id),
	product_id INTEGER,
	units INTEGER
);

SELECT * FROM sales
LIMIT 50;

-- stores.csv

DROP TABLE IF EXISTS stores;

CREATE TABLE stores (
	store_id INTEGER PRIMARY KEY,
	store_name VARCHAR(29),
	store_city VARCHAR(16),
	store_location VARCHAR(11),
	store_open_date DATE
);

SELECT * FROM stores
LIMIT 50;





---- DATA MANIPULATION ----

-- calendar table
SELECT * FROM calendar; 

BEGIN; -- Reformating the dates for Postgresql

ALTER TABLE  calendar
ALTER COLUMN date TYPE DATE 
USING CAST(
	SPLIT_PART(date, '/', 3) || '-' ||
	LPAD(SPLIT_PART(date, '/', 1), 2, '0') || '-' ||
	LPAD(SPLIT_PART(date, '/', 2), 2, '0') AS DATE
	);

ROLLBACK;
COMMIT;

--********************************

-- inventory table

SELECT * FROM inventory; -- inventory table looks fine

--********************************

-- product table

SELECT * FROM product;


BEGIN; -- Removing $ sign from product_cost and product_price.

UPDATE product
	SET product_cost = TRIM(REPLACE(product_cost, '$', '')),
		product_price = TRIM(REPLACE(product_price, '$', ''));


ALTER TABLE product
ALTER COLUMN product_cost TYPE FLOAT USING product_cost::FLOAT; 

ALTER TABLE product
ALTER COLUMN product_price TYPE FLOAT USING product_price::FLOAT;

ROLLBACK;
COMMIT;
--********************************

-- sales table

SELECT * FROM sales; 


BEGIN; -- changing the data type of date column

ALTER TABLE sales
ALTER COLUMN date TYPE DATE
USING (
	date::DATE
);

ROLLBACK;
COMMIT;


--********************************

-- stores table

SELECT * FROM stores; -- stores table looks fine