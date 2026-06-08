
--Q1 - what is the total revenue by product category, ranked by revenue?
select 
c.category_name,
round(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_revenue
from order_details od
join products p on od.product_id = p.product_id
join categories c on p.category_id = c.category_id 
group by c.category_name
order by total_revenue desc;

--Q2 - which country generates the most orders and revenue?
select 
o.ship_country,
count(distinct o.order_id) as total_orders,
round(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_revenue
from orders o
join order_details od on o.order_id = od.order_id  
group by o.ship_country
order by total_revenue desc;

--Q3 - Who are the top 10 customers by lifetime revenue?
select
c.customer_id,
c.company_name,
c.country,
round(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as lifetime_revenue
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
group by c.customer_id, c.company_name, c.country
order by lifetime_revenue desc
limit 10;

-- Q4 - Are the top customers ordering more or less over time (YoY)?
with top_customers as (
select
c.customer_id
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
group by c.customer_id
order by SUM(od.unit_price * od.quantity * (1 - od.discount)) desc
limit 10
),
yearly_revenue as (
select 
c.customer_id,
c.company_name,
extract(year from o.order_date) as order_year, 
round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
where c.customer_id in (select customer_id from top_customers)
group by c.customer_id, c.company_name, order_year
)
select
customer_id,
company_name,
order_year,
revenue,
lag(revenue) over (partition by customer_id order by order_year) as previous_year_revenue,
round(revenue - lag(revenue) over (partition by customer_id order by order_year), 1) as yoy_change
from yearly_revenue
order by customer_id, order_year;

-- Q5 - Which products have obsesrved a decrease in sales compared to the previous year?
with yearly_product_sales as (
select
p.product_id,
p.product_name,
extract(year from o.order_date) as order_year,
round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as revenue
from products p
join order_details od on p.product_id = od.product_id
join orders o on od.order_id = o.order_id
group by p.product_id, p.product_name, order_year
),
with_lag as (
select
product_id,
product_name,
order_year,
revenue, 
lag(revenue) over (partition by product_id order by order_year) as prev_year_revenue
from yearly_product_sales
)
select
product_id,
product_name,
order_year,
revenue,
prev_year_revenue,
round(revenue - prev_year_revenue, 2) as yoy_change
from with_lag
where prev_year_revenue is not null
and revenue > prev_year_revenue
order by yoy_change asc;

--Q6 - What is the average freight cost per shipping country?
select 
ship_country,
count(order_id) as total_orders,
round(avg(freight)::numeric, 2) as avg_freight,
round(sum(freight)::numeric, 2) as total_freight
from orders
group by ship_country
order by avg_freight desc;

--Q7 - Which employee handles the highest-value orders?
select
e.employee_id,
e.first_name || '' || e.last_name as employee_name,
e.title,
count(distinct o.order_id) as orders_handled,
round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as total_order_value
from employees e 
join orders o on e.employee_id = o.employee_id 
join order_details od on o.order_id = od.order_id 
group by e.employee_id, e.first_name, e.last_name, e.title
order by total_order_value desc;