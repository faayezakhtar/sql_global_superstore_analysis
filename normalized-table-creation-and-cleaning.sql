use practiceDB;
select * from Superstore
where segment = 'Corporate';

select OrderPriority from Superstore;

select distinct(Market) from Superstore;

select distinct(Region) from Superstore;

select * from customers;
select * from products;
select * from sales;
select * from employees;
desc Superstore;

-- Creating customer table
create table Customer (
	CustomerID varchar(100) primary key,
    CustomerName varchar(50),
    Segment varchar(100)
);

insert into Customer (CustomerID, CustomerName, Segment)
select distinct CustomerID, CustomerName, Segment
from Superstore;

select * from Customer;

-- Creating product table
create table Product (
	ProductID varchar(100),
    ProductName varchar(150),
    Category varchar(50),
    SubCategory varchar(50)
);


-- identifying duplicates to deal with error: Error Code: 1062. Duplicate entry 'TEC-CO-10003342' for key 'product.PRIMARY'
select productID, count(*)
from Superstore
group by productID
having count(*)>1;

select productID, productName, Category, subCategory, count(1) from
(select distinct productID, productName, Category, subCategory
from Superstore) p
group by productID, productName, Category, subCategory
having count(1) > 1
order by productID;

select * from Product;
insert into Product (ProductID, ProductName, Category, SubCategory)
select distinct productID, productName, Category, subCategory
from Superstore;

select p2.productID, p2.productName, p2.Category, p2.SubCategory
from Product p3 inner join
(select p1.productID, p1.productName, p1.Category, p1.SubCategory
from Product p1 inner join
(select productID, count(1)
from Product
group by productID
having count(1) > 1) p
on p.productID = p1.productID
order by p.productID) p2
on p2.productID = p3.productID
where (p2.Category != p3.Category or p2.SubCategory != p3.SubCategory);

select p.productID, p.productName, p.Category, p.SubCategory, p_one.row_num
from Product p inner join
(select productID, productName, Category, SubCategory, 	   
row_number() over (partition by productID order by productID asc) as row_num
from Product) p_one 
on (p.productID = p_one.productID and
	p.productName = p_one.productName and
    p.Category = p_one.Category and
    p.SubCategory = p_one.SubCategory)
where p_one.row_num > 1;

delete p
from Product p inner join
(select productID, productName, Category, SubCategory, 	   
row_number() over (partition by productID order by productID asc) as row_num
from Product) p_one 
on (p.productID = p_one.productID and
	p.productName = p_one.productName and
    p.Category = p_one.Category and
    p.SubCategory = p_one.SubCategory)
where p_one.row_num > 1;

create table Superstore_backup like Superstore;
insert into Superstore_backup select * from Superstore;

delete s
from Superstore s inner join Product p
on p.productID = s.productID
where (p.productName != s.productName or
    p.Category != s.Category or
    p.SubCategory != s.SubCategory);
    
commit;

select * from product;

create table duplicate_Product like Product;

insert into duplicate_Product
select p1.productID, p1.productName, null, null
from Product p1 inner join
(select productID, count(1)
from Product
group by productID
having count(1) > 1) p
on p.productID = p1.productID
order by p.productID;

select * from duplicate_Product;

-- Error Code: 1327. Undeclared variable: duplicate_Product
-- Error Code: 1222. The used SELECT statements have a different number of columns
-- Error Code: 1062. Duplicate entry 'TEC-CO-10003342' for key 'product.PRIMARY'

select distinct productID, productName, Category, subCategory
from Superstore
where ProductID = 'TEC-CO-10003342';

update Superstore
set ProductName = 'Canon Fax Machine, High-Speed' where productID = 'TEC-CO-10003342';

-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.

	-- creating temporary table to clean data
	create temporary table TpProduct as
	select distinct productID, productName, Category, subCategory
	from Superstore
	order by productID;

    insert into Product (ProductID, ProductName, Category, SubCategory)
    select ProductID, ProductName, Category, SubCategory
    from TpProduct;

insert into Product (ProductID, ProductName, Category, SubCategory)
select distinct ProductID, ProductName, Category, SubCategory
from Superstore;

-- Creating orders table
create table Orders (
	OrderID varchar(150),
	CustomerID varchar(100),
    ProductID varchar(100),
    OrderDate varchar(50),
    ShipDate varchar(50),
    ShipMode varchar(100),
    Sales double default null,
	Quantity int default null,
	Discount double default null,
	Profit double default null,
	ShippingCost double default null,
	OrderPriority text,
    LocationID int
);

insert into Orders (OrderID, CustomerID, ProductID, OrderDate, ShipDate, ShipMode, Sales, Quantity, Discount, Profit, ShippingCost, OrderPriority, LocationID)
select OrderID, CustomerID, ProductID, OrderDate, ShipDate, ShipMode, Sales, Quantity, Discount, Profit, ShippingCost, OrderPriority, LocationID
from Superstore;

truncate table Orders;


-- Error Code: 1062. Duplicate entry 'IN-2011-10286' for key 'orders.PRIMARY'
-- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`practicedb`.`orders`, CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer` (`CustomerID`))

select distinct OrderID, count(1)
from Superstore
group by OrderID
having count(1)>1;

-- creating Location table
create table Location (
	LocationID int,
	Country varchar(100),
	State varchar(100),
    City varchar(100),
    Region varchar(50),
    PostalCode varchar(50)
);

select Country, State, City, Region, PostalCode,
1000 + row_number() over (partition by null) as LocationID
from
(select distinct Country, State, City, Region, PostalCode
from Superstore) s;

insert into Location (LocationID, Country, State, City, Region, PostalCode)
select 1000 + row_number() over (partition by null) as LocationID, 
Country, State, City, Region, PostalCode
from
(select distinct Country, State, City, Region, PostalCode
from Superstore) s;

alter table Superstore
add column LocationID int null;

update Superstore s
inner join Location l on 
(s.Country = l.Country and 
s.State = l.State and
s.City = l.City and
s.Region = l.Region and
s.PostalCode = l.PostalCode)
set s.LocationID = l.LocationID;

-- Error Code: 2013. Lost connection to MySQL server during query
-- Error Code: 1205. Lock wait timeout exceeded; try restarting transaction
use practiceDB;
alter table Location
add primary key (LocationID);

select * from superstore where locationID = 1001;
select * from location where locationID = 1001;
select * from orders;
select * from location;
select * from customer;
select * from product;
    