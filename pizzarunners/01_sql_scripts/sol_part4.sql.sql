                               --Pricing and Ratings--

alter database "Pizza Runner" set search_path='pizza_runner';							   
select * from customer_orders
order by customer_id,order_id;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;
select * from week_period

							   
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no
--charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with pizza_count as 
(select p1.pizza_id,count(p1.pizza_id) as numofpizza
from customer_orders p1 join
runner_orders r1 on p1.order_id=r1.order_id where r1.cancellation is null
group by p1.pizza_id),
final_price as (
select p3.pizza_id,p2.pizza_name,
case when p2.pizza_name='Meatlovers' then p3.numofpizza*12 else p3.numofpizza*10 end as pizza_price
from pizza_count p3 join pizza_names p2 on p3.pizza_id=p2.pizza_id)
select sum(pizza_price) as total_money_wo_any_charge
from final_price
--Pizza Runner has made $138 so far if there are no delivery fees






--The Pizza Runner team now wants to add an additional ratings system that allows
--customers to rate their runner, how would you design an additional table for this
--new dataset - generate a schema for this new table and insert your own data for ratings
--for each successful customer order between 1 to 5.
create table runner_feedback
(order_id   int   primary key,
runner_rating   int check(runner_rating between 1 and 5))
drop table runner_feedback
insert into runner_feedback
values(1,4),(2,5),(3,2),(4,4),(5,3),(7,5),(8,4),(10,5),(11,3),(12,1)
select * from runner_feedback





--Using your newly generated table - can you join all of the information together to form a table 
--which has the following information for successful deliveries?
--customer_id,order_id,runner_id,rating,order_time,pickup_time,Time between order and pickup
--Delivery duration,Average speed,Total number of pizzas
with cf as (
select cus.*,fdbk.runner_rating from customer_orders cus
join runner_feedback fdbk on cus.order_id=fdbk.order_id),
rf as(
select run.*,fdbk.runner_rating from runner_orders run
join runner_feedback fdbk on run.order_id=fdbk.order_id)
select cf.customer_id,cf.order_id,rf.runner_id,cf.runner_rating,
cf.order_time,rf.pickup_time,rf.pickup_time-cf.order_time as time_diff,
rf."duration(min)",
case when "duration(min)">0 then round(("distance(km)")/("duration(min)"),2) else '0' end as avg_speed,
count(cf.order_id) as numpizza
from cf join rf on cf.order_id=rf.order_id
group by cf.customer_id,cf.order_id,rf.runner_id,cf.runner_rating,
cf.order_time,rf.pickup_time,rf.pickup_time-cf.order_time,
rf."duration(min)",round(("distance(km)")/("duration(min)"),2),
cf.order_id
order by cf.customer_id
--yes we can join all these data together












--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for
--extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner 
--have left over after these deliveries?
with del_price as (
select cus.order_id,cus.pizza_id,
case when cus.pizza_id=1 then 12 else 10 end as price_per_pizza,
run."distance(km)"*0.30 as delivery_price
from customer_orders cus join runner_orders run on cus.order_id=run.order_id
where run.cancellation is null)
select sum(price_per_pizza-delivery_price) as money_after_del_cost
from del_price
--$73.380 money is left with Pizza Runner after these deliveries







