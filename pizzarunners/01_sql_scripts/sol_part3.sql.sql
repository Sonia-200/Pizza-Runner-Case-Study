                           --Ingredient Optimisation--

alter database "Pizza Runner" set search_path='pizza_runner';							   
select * from customer_orders
order by customer_id,order_id;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;





--What are the standard ingredients for each pizza?
select piz.pizza_id,top.topping_name
from pizza_recipes piz join pizza_toppings top
on piz.toppings=top.topping_id
order by piz.pizza_id






--What was the most commonly added extra?
select count(cus.extras),top.topping_name
from customer_orders cus
join pizza_toppings top on cus.extras=cast(top.topping_id as varchar)
group by top.topping_name
--Bacon is the most commonly added extra





--What was the most common exclusion?
select count(cus.exclusions),top.topping_name
from customer_orders cus
join pizza_toppings top on cus.exclusions=cast(top.topping_id as varchar)
group by top.topping_name
--Cheese is the most common exclusion







--Generate an order item for each record in the customers_orders table 
--in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
select c2.order_id, c2.customer_id,p1.pizza_name||
case when c2.exclusions is not null then '-Exclude'|| 
string_agg(distinct top1.topping_name,','order by top1.topping_name) 
else '' end|| case when c2.extras is not null then
'-Extras'||string_agg(distinct top2.topping_name,','order by top2.topping_name) else '' end as prod_desc
from pizza_names p1 right join customer_orders c2 on p1.pizza_id=c2.pizza_id
left join
lateral unnest(string_to_array(coalesce(c2.exclusions,''),',')) as excl_id on excl_id <>''
left join 
pizza_toppings top1 on top1.topping_id::varchar=excl_id
left join
lateral unnest(string_to_array(coalesce(c2.extras,''),',')) as extra_id on extra_id<>''
left join
pizza_toppings top2 on top2.topping_id::varchar=extra_id
group by c2.order_id,c2.customer_id,p1.pizza_name,c2.exclusions,c2.extras
order by c2.customer_id,c2.order_id

