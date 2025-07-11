                               'Pizza-Metrics'


alter database "Pizza Runner" set search_path='pizza_runner';							   
select * from customer_orders
order by customer_id;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

--how many pizzas were ordered?
select count(pizza_id) as total_pizzas from customer_orders
--total pizzas=14


--how many unique customer orders were made?
select count(distinct order_id) as total_orders from customer_orders
--10 unique customer orders



--how many successful orders were delivered by each runner?
select runner_id,count(order_id) as orders_delivered
from runner_orders 
where cancellation is null
group by runner_id
--total pizzas delivered=8,4 orders by runner1,3 orders by runner 2 and 1 order by runner3



--how many of each type of pizza were delivered?
select cus.pizza_id,count(cus.order_id)as delivered_pizzas
from customer_orders cus join runner_orders run on cus.order_id=run.order_id
where cancellation is null
group by pizza_id
--9 pizzas with pizza_id 1,3 with pizza_id 2



--how many Vegetarian and Meatlovers were ordered by each customer?
with pizza_data as
(select order_id,customer_id,
sum(case when pizza_id=1 then 1 else 0 end) as Meatlover_pizza,
sum(case when pizza_id=2 then 1 else 0 end) as Vegetarian_pizza
from customer_orders  
group by customer_id,pizza_id,order_id
order by customer_id)
select customer_id,sum(Meatlover_pizza) as Meatlover_pizza,sum(Vegetarian_pizza) as Vegetarian_pizza
from pizza_data join runner_orders on pizza_data.order_id=runner_orders.order_id
where cancellation is null
group by customer_id





--What was the maximum number of pizzas delivered in a single order?
select cus.order_id,count(cus.pizza_id) as pizzas_per_order
from customer_orders cus join runner_orders run on cus.order_id=run.order_id
where cancellation is null
group by cus.order_id
order by count(cus.pizza_id) desc
limit 1
--max 3 pizzas were ordered in a single order 





--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with final_changes as (
select customer_id,order_id,
sum(case when exclusions is null and extras is null then 1 else '0' end )as no_changes,
sum(case when exclusions is not null or extras is not null then 1 else '0' end) as leas1_changes
from customer_orders
where order_id in (select order_id
from runner_orders 
where cancellation is null)
group by customer_id,order_id,exclusions,extras)
select customer_id,sum(no_changes)as no_changes,sum(leas1_changes)as leas1_changes
from final_changes
group by customer_id
order by customer_id





--How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) as pizza_both_changes
from customer_orders
where exclusions is not null and extras is not null and order_id in (select order_id
from runner_orders 
where cancellation is null)
--only one 





--What was the total volume of pizzas ordered for each hour of the day?
with hours as (
select *,extract(hour from order_time) as order_hour from customer_orders)
select order_hour,count(pizza_id) as vol_per_hr
from hours
group by order_hour
order by order_hour




--What was the volume of orders for each day of the week?
with week as (
select *,to_char(order_time,'day') as order_day_name,extract(DOW from order_time)as order_day from customer_orders)
select order_day,order_day_name,count(distinct order_id) as vol_per_day
from week
group by order_day,order_day_name
order by order_day
