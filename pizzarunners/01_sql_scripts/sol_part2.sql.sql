                             --Runner and Customer Experience--
alter database "Pizza Runner" set search_path='pizza_runner';							   
select * from customer_orders
order by customer_id;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;



							 
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
create table week_period 
(id  int,
weeknum  varchar,
week  date)
insert into week_period
values(1,'week1','2021-01-01'),
      (2,'week2','2021-01-08'),
	  (3,'week3','2021-01-15'),
	  (4,'week4','2021-01-22')
select * from week_period
with runner_final as (select *,row_number() over() as week_id from runners)
select week_period.weeknum,week_period.week as week_date,
count(runner_final.runner_id)
from week_period join runner_final on week_period.week<=runner_final.registration_date
and week_period.week+interval '7day'>runner_final.registration_date
group by week_period.weeknum,week_period.week
order by weeknum
	  




--What was the average time in minutes it took for each 
--runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, extract(minutes from avg(runner_orders.pickup_time-customer_orders.order_time)) as avg_pickup_time
from runner_orders join customer_orders 
on runner_orders.order_id=customer_orders.order_id
where pickup_time is not null
group by runner_id
order by runner_id






--Is there any relationship between the number of pizzas and how long the order takes to prepare?
select c1.order_id,count(c1.pizza_id) as numofpizza,c1.order_time,r1.pickup_time,
extract( minutes from (pickup_time-order_time)) as time_diff
from customer_orders c1 join runner_orders r1 on c1.order_id=r1.order_id
where r1.cancellation is null
group by c1.order_id,c1.order_time,r1.pickup_time
order by order_id
--generally more the number of pizzas more is the
--time taken to prepare the order although there are some anomalies






--What was the average distance travelled for each customer?
select c2.customer_id,round(avg(r2."distance(km)")) as avg_dis_for_deliveries
from customer_orders c2 join runner_orders r2
on c2.order_id=r2.order_id
group by customer_id
order by customer_id




--What was the difference between the longest and shortest delivery times for all orders?
with delivery_table as (select c2.customer_id,round(avg(r2."distance(km)")) as avg_time_for_deliveries
from customer_orders c2 join runner_orders r2
on c2.order_id=r2.order_id
group by customer_id
order by customer_id)
select max(avg_time_for_deliveries)-min(avg_time_for_deliveries) as diff_del
from delivery_table
-- the difference between the longest and shortest delivery times for all orders is 15 mins.







  

--What was the average speed for each runner for each delivery and do 
--you notice any trend for these values?
with runner_speed as (
select runner_id,order_id,
round(("distance(km)"/"duration(min)"),2) as speed
from runner_orders
group by runner_id,order_id,"distance(km)","duration(min)"
having "distance(km)" is not null 
order by runner_id,order_id)
--runner with id 2 had the most speed






--What is the successful delivery percentage for each runner?
with del_final as(
select runner_id,count(order_id) as deliveries_done
from runner_orders
where cancellation is null
group by runner_id),
total_final as(
select d1.runner_id,d1.deliveries_done,count(r3.order_id)as tot_del
from runner_orders r3 join del_final d1 on r3.runner_id=d1.runner_id
group by d1.runner_id,d1.deliveries_done)
select runner_id,deliveries_done,tot_del,round((deliveries_done::numeric/tot_del)*100)||'%' as success_del_rate
from total_final




