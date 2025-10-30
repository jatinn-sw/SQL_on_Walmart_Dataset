select * from walmart;
--

select count(*) from walmart;
--

select 
	payment_method,
    count(*)
from walmart
group by payment_method;


select 
	count(distinct branch)
from walmart;

select min(quantity) from walmart;


-- Problems:
-- Question 1: Find different payment methods, number of transactions and number of quantity sold.

select
	payment_method,
    count(*) as no_of_trans,
    sum(quantity) as quantity_sold
from walmart
group by payment_method;


-- Question 2: Identify the highest-rated caetgoryin each branch displaying the branch, the category and the average rating.

select *
from
(	select
		branch,
	    category,
	    avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating) desc) as rank
	from walmart
	group by branch, category
)
where rank = 1;


-- Question 3: Identify the busiest day for each branch based on the number of transactions.

select *
from
	(select
		branch,
		to_char(to_date(date, 'DD/MM/YY'), 'Day') as day_name,
		count(*) as no_of_transactions,
		rank() over(partition by branch order by count(*) desc) as rank
	from walmart
	group by branch, day_name
	)
where rank = 1;


-- Question 4: Calculate the total number of items sold per payment method. List payment method and total quantity.

select
	payment_method,
    sum(quantity) as quantity_sold
from walmart
group by payment_method;


-- Question 5: Determine the average, minimum and maximum rating of products for each city. List the city, average rating, minimum rating and maximum rating.

select
	city,
	category,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
from walmart
group by city, category;


-- Question 6: Calculate the total pofits for each category by considering total_profits as (unit_price * quantity * profit_margin).
--				List category and total_profit, ordered from highest to lowest profits.

select
	category,
	sum(total_price) as total_revenue,
	sum(total_price * profit_margin) as profit
from walmart
group by category;


-- Question 7: Determine the most common payment method for each branch. Display branch and preferred_payment_method

with cte
as
(select
	branch,
	payment_method,
	count(*) as total_trans,
	rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by branch, payment_method
)
select *
from cte
where rank = 1;


-- Question 8: Categorize sales into 3 groups - Morning, Afternoon and Evening. Find out each of the shifts and number of invoices.

select
	branch,
case 
		when extract (hour from(time::time)) < 12 then 'Morning'
		when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end day_time,
	count(*)
from walmart
group by branch, day_time
order by branch, count desc;


-- Question 9: Identify 5 branch with highest decrease ratio in revenue compared to last year (2023 and 2023, dataset is old)

select
	extract (year from to_date(date, 'DD/MM/YY')) as formatted_date
from walmart


-- 2022 sales
with revenue_2022
as
(
	select
		branch,
		sum(total_price) as revenue
	from walmart
	where extract (year from to_date(date, 'DD/MM/YY')) = 2022
	group by branch
), 

-- 2023 sales
revenue_2023
as
(
	select
		branch,
		sum(total_price) as revenue
	from walmart
	where extract (year from to_date(date, 'DD/MM/YY')) = 2023
	group by branch
)

select 
	ls.branch,
	ls.revenue as year_2022_revenue,
	cs.revenue as year_2023_revenue,
	round((ls.revenue - cs.revenue)::numeric / ls.revenue::numeric * 100, 2) as rev_decrease_ratio_in_percent
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by rev_decrease_ratio_in_percent desc
limit 5;


-- Question 10: Find top 10 cities that has generated the highest average total revenue per transaction. 
-- 				Also display the number of transactions and total revenue for that city.

select
	city,
	count(*) as total_transactions,
	sum(total_price) as total_revenue,
	round(sum(total_price)::numeric / count(*), 2) as avg_revenue_per_trans
from walmart
group by city
order by avg_revenue_per_trans desc
limit 10;


-- Question 11: Display total revenue and average rating for each month.

select
	to_char(to_date(date, 'DD/MM/YY'), 'YYYY-MM') as month,
	sum(total_price) as total_revenue,
	round(avg(rating)::numeric, 2) as avg_rating
from walmart
group by month
order by month

-- Question 12: List branches with profit margins below the overall average.

select 	
	branch,
	avg(profit_margin) as avg_profit_margin
from walmart
group by branch
having avg(profit_margin) < (select avg(profit_margin) from walmart)
order by avg_profit_margin;


-- Question 13: Find the hour that contributes most to sales revenue.

select
	extract (hour from time::time) as hour,
	sum(total_price) as total_revenue
from walmart
group by hour
order by total_revenue desc;