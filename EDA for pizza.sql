use pizza;

-- Lets take a look at the entire data
select * from pizza_sales;

-- Lets take a look at the sales of each pizza size and see which is the highest
select pizza_size, round(sum(total_price),2) as sales from pizza_sales
group by pizza_size 
order by sales asc;
-- it turns out L is the highest followed by M then Small (xl isnt ordered much and xxl is a bit of a niche as they arent ordered very often)

-- lets see which pizza generates the most sales
select pizza_name, round(sum(total_price),2) as sales from pizza_sales
group by pizza_name 
order by sales asc;
-- The thai chicken, barbecu chicken, california chicken

-- lets also check all categories sales (chiecken will probably be the highest)
select pizza_category, round(sum(total_price),2) as sales from pizza_sales
group by pizza_category 
order by sales asc;
-- to our surprise the classic category generates the highest sales then supreme and then chicken


-- Lets Check to see which pizza has the highest number of orders per order
select pizza_name, max(quantity) as q
 from pizza_sales
 group by pizza_name
 order by q desc;
 -- We see that the california chicken pizza was ordered  4 times before and it also had the second highest sales out of all pizzas which means it is one 
 -- of our best pizzas and it is a fan favourite (fan favourites are also barbcue chicken, spicy italian and big meat)

 -- Since we know classic pizzas are our highest sales generator, lets take a look at which size of classic profits us more
 select 
 pizza_category,pizza_size, round(sum(total_price),2) as total_sales 
 from pizza_sales
 group by pizza_category,pizza_size
 order by total_sales desc;
-- interesting Large size is our best by far but viggie is highest when it comes to L altough laking in all other sizes
-- Chicken is the second highest in large size but third in all sizes combined, and classic are the last in large sizes but really high in small as well 
-- which could indicate our customers usually get small classic pizzas to complement their original meal or get it as a quick snack



-- how about we test this hypothesis
SELECT 
    COUNT(DISTINCT order_id) AS total_orders, 
    SUM(CASE WHEN total_pizzas = 1 THEN 1 ELSE 0 END) AS single_item_orders,
    SUM(CASE WHEN total_pizzas > 1 THEN 1 ELSE 0 END) AS combo_orders
FROM (
    SELECT order_id, COUNT(*) AS total_pizzas
    FROM pizza_sales
    WHERE pizza_size = 'S' AND pizza_category = 'Classic'
    GROUP BY order_id
) subquery;
-- Wow our second assumption was true (small classic pizzas are mostly ordered as a seperate snack and not complmenting a full meal) 
-- as single item orders are ordered more than combo_orders (4684 > 616)
-- we have to say that this hypothsis could also be affected by 


-- Lets see the most frequently ordered pizzas with our classic small 
SELECT datepart(hour,order_time) AS hour_of_day, COUNT(*) AS order_count
FROM pizza_sales
WHERE pizza_size = 'S' AND pizza_category = 'Classic'
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_count DESC;
-- They are most frequently ordered at 12 and 13 (12pm and 1pm) at afternoon which indecates these orders were snacks,
-- but the 17 and 18 probably indicates that they are in meal times


SELECT 
	hour_of_day,
    COUNT(DISTINCT order_id) AS total_orders, 
    SUM(CASE WHEN total_pizzas = 1 THEN 1 ELSE 0 END) AS single_item_orders,
    SUM(CASE WHEN total_pizzas > 1 THEN 1 ELSE 0 END) AS combo_orders
FROM (
    SELECT order_id, COUNT(*) AS total_pizzas,datepart(hour,order_time) AS hour_of_day
    FROM pizza_sales
    WHERE pizza_size = 'S' AND pizza_category = 'Classic'
    GROUP BY order_id, datepart(hour,order_time)
) subquery
group by hour_of_day
ORDER BY hour_of_day;
-- as you can see throughout the entire day classic small pizza are ordered more as single item (snack)
-- espically late at 6 pm or 1 pm

-- Now that we know a lot about our data lets import it to power bi for more Insights and analysis
select * from pizza_sales;

-- We will leave out ingredients,pizza_name_id,pizza_id,total_price (since we can easily caluclate in power query in power bi)

Go

CREATE VIEW 
pizza_sales_PBI AS
SELECT order_id, order_date, order_time, quantity, unit_price,pizza_size,pizza_category,pizza_name
FROM pizza_sales;

Go