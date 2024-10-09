-- SQL Retail Sales Analysis - P1

-- CREATE TABLE --

CREATE TABLE retail_sales (
	transaction_id INT,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(50),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

SELECT *
FROM retail_sales;

SELECT count(*)
FROM retail_sales;

SELECT count(DISTINCT customer_id)
FROM retail_sales;


-- DATA CLEANING --

SELECT *
FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
	transaction_id IS NULL 
	OR sale_date IS NULL 
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;


-- DATA EXPLORATION --

-- How many sales we have?

SELECT count(*) 
FROM retail_sales;


-- How many unique customers we have ?

SELECT count(DISTINCT customer_id)
FROM retail_sales;


-- How many categories we have?

SELECT DISTINCT category 
FROM retail_sales;


-- Data Analysis & Business Key Problems & Answers
-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and 
--     the quantity sold is more than 3 in the month of Nov-2022.

SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND quantity > 3
	AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- OR --

SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND quantity > 3
	AND EXTRACT(MONTH FROM sale_date) = 11
	AND EXTRACT(YEAR FROM sale_date) = 2022;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
	category,
	COUNT(*) AS total_orders,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT 
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- OR --

SELECT 
	category,
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM retail_sales
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by  
--     each gender in each category.

SELECT 
	category, 
	gender,
	COUNT(transaction_id) AS total_transactions
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 2;


-- Q.7 Write a SQL query to calculate the average sale for each month. 
--     Find out best selling month in each year.

WITH average_sale_pr_month AS (
SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	ROUND(AVG(total_sale)::numeric, 2) AS avg_sale,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS ranking
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)

SELECT 
	year,
	month,
	avg_sale
FROM average_sale_pr_month
WHERE ranking = 1;

-- OR --

SELECT 
	year,
	month,
	avg_sale
FROM (SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	ROUND(AVG(total_sale)::numeric, 2) AS avg_sale,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS ranking
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 3 DESC) AS t1
WHERE ranking = 1;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales .

SELECT 
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY 1


-- Q.10 Write a SQL query to create each shift and number of orders. 
--      (Example Morning <=12, Afternoon Between 12 & 16, Evening > 16)	

WITH shift_table AS (
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) > 16 THEN 'Evening'
		ELSE 'Afternoon'
		END AS shift
FROM retail_sales)

SELECT 
	shift,
	COUNT(transaction_id) AS total_orders
FROM shift_table
GROUP BY 1
ORDER BY 2 DESC


-- End of project



