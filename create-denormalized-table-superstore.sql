use practiceDB;
CREATE TABLE Superstore (
    RowID int,
    OrderID varchar(50),
    OrderDate varchar(50),
    ShipDate varchar(50),
    ShipMode varchar(100),
    CustomerID varchar(100),
    CustomerName varchar(50),
    Segment varchar(100),
    Country varchar(100),
    City varchar(100),
    State varchar(100),
    PostalCode varchar(50),
    Market varchar(100),
    Region varchar(50),
    ProductID varchar(100),
    Category varchar(50),
    SubCategory varchar(50),
    ProductName varchar(150),
	Sales double default null,
	Quantity int default null,
	Discount double default null,
	Profit double default null,
	ShippingCost double default null,
	OrderPriority text
);
-- RowID can be dropped

-- Customers
CustomerName
CustomerID
Segment

-- Products
ProductID
ProductName
Category
SubCategory

-- Orders
CustomerID -- to join with customers
ProductID -- to join with products
OrderID -- primary key
OrderDate
ShipDate
ShipMode
Sales -- this value is probably earnings from the sale of that product
Quantity
Discount
Profit
ShippingCost
OrderPriority

-- Location
OrderID -- foreign key
City
State
Country
Market
Region -- (one of either region or market can be dropped - ideally market)
PostalCode


