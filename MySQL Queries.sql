select * from walmart;

select count(*) from walmart;

select payment_method, count(*)
 from walmart
 group by payment_method;
 
 select count(distinct branch) from walmart;
 
 select max(quantity) from walmart;
 
 -- Business Problems
 -- Ques 1. Find different payment methods, number of transactions and number of quantity sold.
 select payment_method,
 count(*) as no_payments,
 sum(quantity) as no_quantity_sold
 from walmart
 group by payment_method;
 
 -- Ques 2. Identify the highest-rated category in each branch. Display the branch, category and avg rating.
select * from (
SELECT 
    branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) as rnk
FROM walmart
GROUP BY branch, category
) as top_categories
where rnk = 1;

-- Ques 3. Identify the busiest day for each branch based on the umber of transactions.  
select * from walmart;
select * from (
 select branch,
	dayname(date) as day_name,
    count(*) as no_tansactions,
    rank() over(partition by branch order by count(*) DESC) as rnk
from walmart
group by 1, 2
) as busiest_day
where rnk = 1;

-- Ques 4. Calculate the total quantity of items sold per payment method. List the total quantity and payment methods. 
select payment_method,
count(quantity) as total_quantity,
sum(quantity) as no_of_quantity
from walmart
group by 1
order by no_of_quantity DESC;

-- Ques 5. Determine average, minimum and maximum rating of category of each city. List the city, average_rating, min_rating and max_rating.
select city,
	category,
    avg(rating) as avg_rating,
    min(rating) as min_rating,
    max(rating) as max_rating
from walmart
group by 1, 2
order by city ASC;

-- Ques 6. Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin) . List category and total_profit, orderder from highest to lowest profit. 
select category, 
	sum(total) as total_revenue,
    sum(total * profit_margin) as total_profit
from walmart
group by category
order by total_profit DESC;

-- Ques 8. Determine the most common payment method for each branch. Display branch and the preferred method.
with cte as (
select branch,
	payment_method,
    count(*) as total_transaction,
    rank() over(partition by branch order by count(*) DESC) as rnk
from walmart
group by 1, 2)
select * from cte
where rnk = 1;

-- Ques 8. Categorize sales into 3 groups as Morning, Afternoon and Evening. Find each of the shifts and no of invoices
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
 
 