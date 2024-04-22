CREATE DATABASE IF NOT EXISTS WalmartDataSales;

CREATE TABLE IF NOT EXISTS Sale(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2)
);


-- ------------------------------------------------------------------------------------
-- -------------feature engineering-------------

-- Data cleaning
SELECT *
FROM sales;

-- Add the time_of_day column ------> Data Engineering

select time,(case
  WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
  else "Evening" end) as time_of_day
  from sale;
  
  -- adding time_of_day column to table sale now.
  
  Alter Table sale add column time_of_day varchar(10);
  
  update sale 
  set time_of_day = (case
  WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
  else "Evening" end);
  
  
  -- ------------------------------------------------------------------------------------------------
  -- adding day name for the particular date in table.------------------------------------
  
  select date,
  dayname(date) from sale;
  
  Alter Table sale add column day_name varchar(10);
  update sale 
  set day_name = dayname(date);
 -- ----------------------------------------------------------------------- 

-- adding month name for the particular date in table------------

select date,
monthname(date) from sale;

Alter Table sale add column month_name varchar(10);
update sale
set month_name = monthname(date);

-- -----------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------

-- ------------------Generic Questions------------

-- Number of uniques cities----

select distinct(city) from sale;

-- Each branch in which city----

select distinct(branch) from sale;

select distinct(city),branch from sale;

-- ------------------------------------------------------------------------------------------
-- ---------------------------Product--------------------------------------------------------

--  How many unique product lines does the data have?


SELECT
	DISTINCT product_line
FROM sale;

-- ------------------------------------------------
-- What is the most common payment method?

select payment,count(payment) 
from sale
group by payment
order by payment desc limit 1;

-- ----------------------------------------------
-- What is the most selling product line?

select * from sale;

select product_line,count(product_line) as count
from sale
group by product_line
order by count(product_line) desc limit 1;

-- ----------------------------------------------
-- What is the total revenue by month?

SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sale
GROUP BY month_name 
ORDER BY total_revenue desc;

-- ------------------------------------------
-- What month had the largest COGS?

SELECT
	month_name AS month,
	SUM(cogs) AS cog
FROM sale
GROUP BY month_name
ORDER BY cog desc;

-- ----------------------------------------------
-- What product line had the largest revenue?

select product_line,
sum(total) as total_revenue
from sale
group by product_line
order by total_revenue desc limit 1;

-- ----------------------------------------------
-- What is the city with the largest revenue

SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sale
GROUP BY city, branch 
ORDER BY total_revenue DESC;

-- ---------------------------------------------
-- What product line had the largest VAT?

select * from sale;
SELECT
	product_line,
	avg(tax_pct) as avg_tax
FROM sale
GROUP BY product_line
ORDER BY avg_tax DESC;

-- ---------------------------------------------
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

WITH AvgSalesPerProductLine AS (SELECT
product_line,
AVG(quantity) AS avg_quantity 
FROM sale
GROUP BY product_line)

SELECT s.product_line, s.quantity,
CASE WHEN s.quantity > avg_sales.avg_quantity THEN 'Good' ELSE 'Bad'END AS remark
FROM sale s
JOIN AvgSalesPerProductLine avg_sales ON s.product_line = avg_sales.product_line;

-- -------------------------------------------------------------------------------------
-- Which branch sold more products than average product sold?

WITH AvgSalesPerBranch AS (SELECT branch, AVG(quantity) AS avg_quantity
FROM sale
GROUP BY branch)

SELECT branch,SUM(quantity) AS total_quantity_sold
FROM sale
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(avg_quantity) FROM AvgSalesPerBranch);

-- --------------------------------------------------------------------------------------
-- What is the most common product line by gender

SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sale
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- -----------------------------------------------------------------------
-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sale
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------

-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sale
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sale
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sale
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sale
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------



-- -------------------------- Customers -------------------------------

-- --------------------------------------------------------------------
-- How many unique customer types does the data have?

SELECT
	DISTINCT customer_type
FROM sale;

-- --------------------------------------------------------------------
-- How many unique payment methods does the data have?

SELECT
	DISTINCT payment
FROM sale;

-- --------------------------------------------------------------------
-- What is the most common customer type?

SELECT
	customer_type,
	count(*) as count
FROM sale
GROUP BY customer_type
ORDER BY count DESC;

-- --------------------------------------------------------------------
-- Which customer type buys the most?

SELECT
	customer_type,
    COUNT(*)
FROM sale
GROUP BY customer_type;

-- --------------------------------------------------------------------
-- What is the gender of most of the customers?

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sale
GROUP BY gender
ORDER BY gender_cnt DESC;

-- --------------------------------------------------------------------
-- What is the gender distribution per branch?

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sale
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- --------------------------------------------------------------------
-- Which time of the day do customers give most ratings?

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sale
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter

-- --------------------------------------------------------------------
-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sale
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- --------------------------------------------------------------------
-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sale
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

-- --------------------------------------------------------------------
-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sale
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- Revenue And Profit Calculations----------------------------------------------------------


-- Data given:

-- $ \text{Unite Price} = 45.79 $
-- $ \text{Quantity} = 7 $
-- $ COGS = 45.79 * 7 = 320.53 $

-- $ \text{VAT} = 5% * COGS\= 5% 320.53 = 16.0265 $
-- $ total = VAT + COGS\= 16.0265 + 320.53 = 
-- $ \text{Gross Margin Percentage} = \frac{\text{gross income}}{\text{total revenue}}\=\frac{16.0265}{336.5565} = 0.047619\\approx 4.7619% $


-- ------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------
























 










