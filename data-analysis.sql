-- Let us approach analyzing the data with a question. Assume the superstore wanted to expand to a new location. There are a few ways to go 
-- about this:
-- 		- Identify the most popular customer segement, find a location with a large population of that customer segment, and expand to that 
-- 		location to capture market share.
-- 		- Identify location with the highest number of sales. Identify a market in this location that observes lower sales. Since the superstore's
-- 		brand image and reputation have already been established in this location, it can be safe to assume - for the purpose of this project - 
-- 		that lower sales might be observed due to shortage of goods or high supply costs. Hence, this market would also be a good candidate for
-- 		expansion. 

-- The following analysis will focus on the second option. 

-- What country has had the highest sales? 
select l.country, sum(o.Sales) 
from location l inner join orders o on l.locationID = o.locationID
group by l.country
order by sum(o.sales) desc;

-- Top 5: 
	-- United States
	-- Australia
	-- France
	-- China
	-- Germany
    
--      In that country, which state has had the highest sales?
select s.state, sum(s.sales) 
from
(select l.country, l.state, o.sales 
from location l inner join orders o on l.locationID = o.locationID
where l.country = "United States") s
group by s.state
order by sum(s.sales) desc;

-- Top 5: 
	-- California
	-- New York
	-- Texas
	-- Washington
	-- Pennsylvania

-- 		In that state, which city had the highest amount of sales?
select s.city, sum(s.sales) 
from 
(select l.country, l.state, l.city, o.sales
from location l inner join orders o on l.locationID = o.locationID
where l.state = 'California') s
group by s.city
order by sum(sales) desc;

-- Top 5: 
	-- LA
	-- San Francisco
	-- San Diego
	-- Fresno
	-- Anaheim
    

-- Of the countries recorded above, have these countries gotten the highest number of orders as well? 
select l.country, count(o.orderID) 
from location l inner join orders o on l.locationID = o.locationID
group by l.country
order by count(o.orderID) desc;

-- Top 5: 
	-- United States
	-- France
	-- Australia
	-- Mexico
	-- Germany
-- China ranks at 6th, instead of 4th
-- As seen above, the top 3 are the same but China has been moved from 4th to 6th. This may suggest that Chinese consumers might be 
-- purchasing a higher quantity of goods with every order, hence having higher sales with lesser number of orders. This is cross-checked
-- using the query below:

select l.country, sum(o.quantity) 
from location l inner join orders o on l.locationID = o.locationID
group by l.country
order by sum(o.quantity) desc;

-- Top 6:
	-- United States
    -- France
    -- Australia
    -- Mexico
    -- Germany
    -- China
-- As seen by China's rank above, the output debunks the theory that Chinese consumers may order in bulk. Instead, it suggests that sales might be higher due to 
-- higher prices seen in the Chinese market. Howvever, as price is not recorded in the data, this would be hard to verify.

-- The analysis has proven that the United States is the biggest consumer of goods from the Superstore. Therefore, for business expansion, the US market would be 
-- the easiest to penetrate due to factors such as reputation, brand image, and consumer awareness. Now, we need to decide on a city (new market) to open a new branch. Ideally, 
-- this should be in California to leverage brand image and consumer awareness, and hence reduce barriers to entry. Additionally, as mentioned earlier, it should be 
-- a city with lower sales since this would suggest a shortage of goods (demand > supply). The following query identifies plausible locations:

select s.city, sum(s.sales) 
from 
(select l.country, l.state, l.city, o.sales
from location l inner join orders o on l.locationID = o.locationID
where l.state = 'California') s
group by s.city
order by sum(sales) asc
limit 50;

-- Let's say we decide to open a branch in Stockton (from above output). Before opening a branch, we need to consider what products to introduce in the store first
-- i.e the product portfolio. By introducing products in an order that aligns with consumer demand, we would be able to attract a large fraction of the market share.
-- Eventually, we can introduce the less popular products to offer diversity. Answering the questions below would help address this step
-- (we need to keep in mind that we are opening a store in Stockton, hence the questions below need to answered with respect to Stockton). 
-- As an insurance measure, we could also introduce surveys into the market to understand consumer preferences. 

-- 		Identify the category for everything below and then dive into the sub-category
-- 		Which sub-category is the most profitable? (both this and below can be seen by country)
--      Which sub-category has seen the most sales?
--      Which sub-category has had the most quantity sold?
--      Is there a large difference between the highest sale sub-category and second highest sale sub-category?

select p2.category, 
sum(p2.profit) as profit_sum, 
sum(p2.sales) as sales_sum, 
sum(p2.quantity) as quantity_sum
from 
(select p.productID, s.state, s.city, s.sales, s.profit, s.quantity, p.productName, p.Category, p.subCategory 
from
(select o.productID, l.state, l.city, o.sales, o.profit, o.quantity
from location l inner join orders o on l.locationID = o.locationID
where l.city = 'Stockton') s
inner join product p on s.productID = s.productID) p2
group by p2.category
order by sum(p2.profit) desc;

-- From the output, it can be seen that "Office Supplies" is the most profitable category, along with the highest number of sales and the greatest quantity ordered.

-- The below query explore the same as the above, but for sub-category instead of category:

select p2.subCategory, 
sum(p2.profit) as profit_sum, 
sum(p2.sales) as sales_sum, 
sum(p2.quantity) as quantity_sum
from 
(select p.productID, s.state, s.city, s.sales, s.profit, s.quantity, p.productName, p.Category, p.subCategory 
from
(select o.productID, l.state, l.city, o.sales, o.profit, o.quantity
from location l inner join orders o on l.locationID = o.locationID
where l.city = 'Stockton') s
inner join product p on s.productID = s.productID) p2
group by p2.subCategory
order by sum(p2.profit) desc;

-- The output shows the order of popularity for each product sub-category. Hence, we learn the order in which products need to be introduced as well which products
-- to promote/advertise to attract consumers. An interesting observation is that there is no one product that is extremely popular. There is no major difference 
-- between the most profitable sub-category and the second most profitable sub-category. The same is true for total number of sales and quantity sold. 
 

-- Another important factor to consider could be demand patterns. Is the demand for different products the same throughout the year? This could provide insight into
-- inventory management as well an ensuring sales are profitable throughout the year. Demand patterns can be checked by observing the respective quantity of goods 
-- sold in each quarter (unfortunately, the data did not have enough observations for Stockton to reach a conclusion. Hence the below quuery carries demand trend
-- analysis for California):

-- The below query attemps to answer the demand trend question, however, it did not group by Product subcategory, so it just shows profit, sales, and quantity trend
-- by quarters. While this is still useful for general analysis (and hence left on this project report), it does not show answer the demand trend question. The query
-- for the specific demand trend question can be found below this query:

select quarter(q.date_orderDate) as quarter_of_year, 
sum(q.quantity) as sum_quantity, 
sum(q.sales) as sum_sales, 
sum(q.profit) as sum_profit
from
(select l.city, l.state, o.sales, o.profit, o.quantity, 
str_to_date(orderdate, '%d-%m-%Y') as date_orderDate
from orders o inner join location l
on o.locationID = l.locationID
where l.state = "California") q
where quarter(q.date_orderDate) is not null
group by quarter(q.date_orderDate)
order by quarter(q.date_orderDate);

-- Brainstorming how to create the demand trend table

	-- inner join product, location, order
	-- filter by location - state = California
	-- divide above output by quarter into 4 tables (filtering)
	-- group by sub-category in each table to show the sales, quantity, profit by sub-category for the respective quarter
	-- union the tables

select q1.subCategory, 
round(avg(q1.date_orderDate)) as quarterOfYear,
sum(q1.sales) as sumOfSales,
sum(q1.profit) as sumOfProfit,
sum(q1.quantity) as sumOfQuantity
from
(select l.locationID, 
quarter(o.orderDate) as date_orderDate, 
l.state, l.city, p.category, p.subCategory, o.sales, o.profit, o.quantity
from
orders o inner join location l
on o.locationID = l.locationID
inner join product p
on p.productID = o.productID
where l.state = "California" and 
quarter(o.orderDate) is not null and
quarter(o.orderDate) = 1) q1
group by q1.subCategory

union

select q2.subCategory, 
round(sum(q2.date_orderDate)/count(q2.date_orderDate)) as quarterOfYear,
sum(q2.sales) as sumOfSales,
sum(q2.profit) as sumOfProfit,
sum(q2.quantity) as sumOfQuantity
from
(select l.locationID, 
quarter(o.orderDate) as date_orderDate, 
l.state, l.city, p.category, p.subCategory, o.sales, o.profit, o.quantity
from
orders o inner join location l
on o.locationID = l.locationID
inner join product p
on p.productID = o.productID
where l.state = "California" and 
quarter(o.orderDate) is not null and
quarter(o.orderDate) = 2) q2
group by q2.subCategory

union

select q3.subCategory, 
round(sum(q3.date_orderDate)/count(q3.date_orderDate)) as quarterOfYear,
sum(q3.sales) as sumOfSales,
sum(q3.profit) as sumOfProfit,
sum(q3.quantity) as sumOfQuantity
from
(select l.locationID, 
quarter(o.orderDate) as date_orderDate, 
l.state, l.city, p.category, p.subCategory, o.sales, o.profit, o.quantity
from
orders o inner join location l
on o.locationID = l.locationID
inner join product p
on p.productID = o.productID
where l.state = "California" and 
quarter(o.orderDate) is not null and
quarter(o.orderDate) = 3) q3
group by q3.subCategory

union

select q4.subCategory, 
round(sum(q4.date_orderDate)/count(q4.date_orderDate)) as quarterOfYear,
sum(q4.sales) as sumOfSales,
sum(q4.profit) as sumOfProfit,
sum(q4.quantity) as sumOfQuantity
from
(select l.locationID, 
quarter(o.orderDate) as date_orderDate, 
l.state, l.city, p.category, p.subCategory, o.sales, o.profit, o.quantity
from
orders o inner join location l
on o.locationID = l.locationID
inner join product p
on p.productID = o.productID
where l.state = "California" and 
quarter(o.orderDate) is not null and
quarter(o.orderDate) = 4) q4
group by q4.subCategory;

-- From the output of the above query, the following observations are made:
-- 	   _ Chairs see a sharp decline in sales and profit from the 1st to the 2nd, 3rd, and 4th quarter
--     _ Envelopes see a sharp decline in sales and profit from the 1st to the 2nd, 3rd, and 4th quarter
--     _ Phones only observe sales and profits in 1st and 3rd quarter
--     _ Binders observe sales in all 4 quarters, with a sharp decline in the 2nd, 3rd, and 4th quarter
--     _ Bookcases and chairs observe loss in 2nd quarter
--     _ Copiers have the highest sales observed of any product, but this is only in the 2nd quarter. They have 0 sales in 1st, 2nd, and 3rd quarters. 


-- This concludes the analysis of the business expansion case. 


use practiceDB;
select * from customer;
select * from product;
select * from orders;
select * from location;
select * from superstore;

-- Errors encountered and resolved:

Errors:
Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'practicedb.l.LocationID' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
Error Code: 1140. In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'practicedb.l.Country'; this is incompatible with sql_mode=only_full_group_by
Error Code: 1060. Duplicate column name 'LocationID'
Error Code: 1054. Unknown column 'o.category' in 'field list'
Error Code: 1140. In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'p2.Category'; this is incompatible with sql_mode=only_full_group_by
Error Code: 1140. In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'q.date_orderDate'; this is incompatible with sql_mode=only_full_group_by
Error Code: 1060. Duplicate column name 'LocationID'
Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'q.city' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'q.city' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
Error Code: 1054. Unknown column 'q.date_orderDate' in 'having clause'
Error Code: 1054. Unknown column 'q.date_orderDate' in 'having clause'

        
        