select * from Customers
select * from shippers
select * from categories


select FirstName,LastName,HireDate from employees
where Title = 'Sales Representative' and Country Like 'USA'


select * from employees
select * from orders where EmployeeID = 5

select SupplierID,ContactName,ContactTitle  from suppliers
where ContactTitle  != 'Marketing Manager'

--------------------------------------------------------------------
select ProductId,ProductName from Products
where ProductName Like '%queso%'
--------------------------------------------------------------------------
select OrderID,CustomerID,ShipCountry from orders
where ShipCountry in ('France','Belgium')
-------------------------------------------------------------------------------
select FirstName,LastName,BirthDate from employees
order by BirthDate ASC
-----------------------------------------------------------------------------------
select FirstName,LastName,convert(date,BirthDate) from employees
order by BirthDate ASC
------------------------------------------------------------------------------
select UnitPrice , Quantity ,(Quantity*UnitPrice) as TotalPrice from OrderDetails 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select count(*) from Customers
---------------------------------------------------------------------------------------------------
select min(convert(date,orderdate)) from orders
------------------------------------------------------------------------------------------
select count(ContactTitle),contactTitle from customers
group by contactTitle
order by count(*) DESC
------------------------------------------------------------------------------------
select orderId,OrderDate,CompanyName from orders
inner join shippers 
on shippers.shipperId = orders.ShipVia
where OrderID  < 10300
--------------------------------------------------------------------------------
select categoryName , count(*) as Number_of_prodcucts from products 
inner join Categories 
on Products.CategoryId = Categories.CategoryId
group by categoryName
order by count(*) Desc
-----------------------------------------------------------------------------------
select count(*) as Number_of_customers,City,Country from Customers 
group by Country,City
order by count(*) DESC
----------------------------------------------------------------------------------------
select ProductId,ProductName,UnitsInStock,
       UnitsOnOrder,ReorderLevel,
	   Discontinued 
From products
where UnitsInStock + UnitsOnOrder < = ReorderLevel and Discontinued = 0
---------------------------------------------------------------------------------------
--To make Null values at the bottom and the values at the top
select CustomerId,CompanyName,Region,
       CASE 
	   WHEN region is null then 1
	   else 0
	   end as X
From   Customers
order by X,CustomerId
---------------------------------------------------------------------------
select top(3) ShipCountry,Avg(freight) from orders
where Year(orderDate) = 2015 
group by ShipCountry
order by Avg(freight) DESC
-------------------------------------------------------------------------------------
select top(3) ShipCountry,Avg(freight) from orders
where convert(date,orderDate) between '2015-01-01' and '2015-12-31'
group by ShipCountry
order by Avg(freight) DESC

select top(3) ShipCountry,Avg(freight) from orders
where orderDate between '2015-01-01' and '2015-12-31'
group by ShipCountry
order by Avg(freight) DESC
-------------------------------------------------------------------------------------------------
select * from orders order by OrderDate


select top(3) ShipCountry,Avg(freight) from orders
where convert(date,orderDate) between '2015-01-01' and '2015-12-31'
group by ShipCountry
order by Avg(freight) DESC
--------------------------------------------------------------------------------------------

select * from orders
select max(OrderDate) from Orders
select DATEADD(YEAR,-1,max(OrderDate)) from Orders
select DATEADD(MONTH,-12,max(OrderDate)) from Orders
Select Dateadd(yy, -1, (Select Max(OrderDate) from Orders)) 

------------------------------------------------------------------------------

select concat(FirstName,' ',LastName) as FullName,
       Orders.OrderID,Products.ProductName,OrderDetails.Quantity
from Employees inner join Orders
on Orders.EmployeeID = Employees.EmployeeID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID
inner join Products
on Products.ProductID = OrderDetails.ProductID
--------------------------------------------------------------------------
select CustomerID,ContactName from Customers
where CustomerID not in (select Orders.CustomerID from Orders) 

select CustomerID from Customers
except 
select CustomerId from Orders

-------------------------------------------------------------
select Customers.CustomerID,Orders.CustomerID
from Customers left outer join Orders
on Customers.CustomerID = Orders.CustomerID
where Orders.CustomerID is Null
-------------------------------------------------------------------------------------
select Customers.CustomerID,Orders.CustomerID 
from Customers
left outer join Orders
on Customers.CustomerID = Orders.CustomerID  and Orders.EmployeeID = 4 
Where  
    Orders.CustomerID is null 
  


select Customers.CustomerID from Customers where CustomerID not in 
                                           (select CustomerID from Orders where EmployeeID=4)

---------------------------------------------------------------------------------------------------
select * from Customers
select * from Orders


select customers.CustomerID,CompanyName,Orders.OrderID,
       sum(Quantity * UnitPrice) as TotalAmount from Customers
inner join Orders
on Orders.CustomerID = customers.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID
where Year(OrderDate) = 2016
group by customers.CustomerID,CompanyName,Orders.OrderID
having sum(Quantity * UnitPrice)>= 10000

-----------------------------------------------------------------------------------------------------------
select customers.CustomerID,CompanyName,
       sum(Quantity * UnitPrice) as TotalAmount from Customers
inner join Orders
on Orders.CustomerID = customers.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID
where Year(OrderDate) = 2016
group by customers.CustomerID,CompanyName
having sum(Quantity * UnitPrice)>= 15000
order by TotalAmount desc
---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
select Quantity * UnitPrice as TotalAmountWithoutDiscount,
       Quantity * UnitPrice * (1-Discount) as TotalAmountWithDiscount
from OrderDetails

-------------------------------------------------------------------------------------------------
select customers.CustomerID,CompanyName,
       sum(Quantity * UnitPrice) as TotalAmountWithoutDiscount,
       sum(Quantity * UnitPrice * (1-Discount)) as TotalAmountWithDiscount from Customers
inner join Orders
on Orders.CustomerID = customers.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID
where Year(OrderDate) = 2016
group by customers.CustomerID,CompanyName
having sum(Quantity * UnitPrice * (1-Discount)) >= 10000
order by TotalAmountWithDiscount desc
--------------------------------------------------------------------------------
Select Employeeid, Orderid, Orderdate
From Orders
Where Eomonth(Orderdate) = Convert(Date, Orderdate)
Order By Employeeid, Orderid

------------------------------------------------------------------------------------
select top(10)orders.OrderID,count(OrderDetails.OrderID) from orders
inner join OrderDetails
on OrderDetails.OrderID=Orders.OrderID
group by orders.OrderID
order by count(OrderDetails.OrderID) desc
-------------------------------------------------------------------------------------------
select top(17)OrderID from orders
order by NEWID()

Select  Top 2 Percent Orderid
From Orders
Order By Newid()
--------------------------------------------------------------------------------------
select distinct OrderID
from
    (select OrderID,
        count(ProductID) over(partition by orderid, quantity) as nl
    from OrderDetails
    where Quantity >= 60) As T
where nl > 1
order by OrderID
------------------------------------------------------------------------------------
With DE_Orders(OrderID) As
    (select distinct OrderID
    from
        (select OrderID,
            count(ProductID) over(partition by orderid, quantity) as nl
        from OrderDetails
        where Quantity >= 60) As T
    where nl > 1)
	select OrderID, ProductID, UnitPrice, QUantity, Discount
from OrderDetails
where OrderID in (select OrderID from DE_Orders)
------------------------------------------------------------
Select  
    OrderDetails.OrderID 
    ,ProductID 
    ,UnitPrice 
    ,Quantity 
    ,Discount 
From OrderDetails  
    Join ( 
        Select  
            DISTINCT OrderID  
        From OrderDetails 
        Where Quantity >= 60 
        Group By OrderID, Quantity 
        Having Count(*) > 1 
    )  PotentialProblemOrders 
        on PotentialProblemOrders.OrderID = OrderDetails.OrderID 
Order by OrderID, ProductID
-----------------------------------------------------------------------------
select OrderID, OrderDate, RequiredDate, ShippedDate
from Orders
where ShippedDate >= RequiredDate
-----------------------------------------------------------------------------
select Employees.EmployeeID,FirstName,LastName,
       count(Orders.OrderID) as totalOrderswithLate 
from Employees
inner join Orders
ON Orders.EmployeeID = Employees.EmployeeID
where ShippedDate >= RequiredDate
group by Employees.EmployeeID,FirstName,LastName
order by Employees.EmployeeID asc
-----------------------------------------------------------------------------------------------

WITH Allorders as (
select Employees.EmployeeID,count(*) as totalorder from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
group by Employees.EmployeeID
), totalLate as (
select Employees.EmployeeID,count(*) as totalOrderWithLate from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
where ShippedDate >= RequiredDate
group by Employees.EmployeeID)

select Employees.EmployeeID,FirstName,LastName,totalorder,totalOrderWithLate from Allorders inner join totalLate
on totalLate.EmployeeID = Allorders.EmployeeID
inner join Employees
on Employees.EmployeeID = Allorders.EmployeeID
---------------------------------------------------------------------------------------
WITH Allorders as (
select Employees.EmployeeID,count(*) as totalorder from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
group by Employees.EmployeeID
), totalLate as (
select Employees.EmployeeID,count(*) as totalOrderWithLate from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
where ShippedDate >= RequiredDate
group by Employees.EmployeeID)

select Employees.EmployeeID,FirstName,LastName,totalorder,totalOrderWithLate from Allorders left join totalLate
on totalLate.EmployeeID = Allorders.EmployeeID
inner join Employees
on Employees.EmployeeID = Allorders.EmployeeID
-----------------------------------------------------------------------------------------------------------------------
WITH Allorders as (
select Employees.EmployeeID,count(*) as totalorder from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
group by Employees.EmployeeID
), totalLate as (
select Employees.EmployeeID,count(*) as totalOrderWithLate from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
where ShippedDate >= RequiredDate
group by Employees.EmployeeID)

select Employees.EmployeeID,FirstName,LastName,totalorder,isnull(totalOrderWithLate,0) from Allorders left join totalLate
on totalLate.EmployeeID = Allorders.EmployeeID
inner join Employees
on Employees.EmployeeID = Allorders.EmployeeID
order by totalorder Desc
-------------------------------------------------------------------------------------------------------
WITH Allorders as (
select Employees.EmployeeID,count(*) as totalorder from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
group by Employees.EmployeeID
), totalLate as (
select Employees.EmployeeID,count(*) as totalOrderWithLate from Employees
inner join Orders
on Orders.EmployeeID=Employees.EmployeeID
where ShippedDate >= RequiredDate
group by Employees.EmployeeID)

select *,(LateOrders*100.0/totalorder) AS PercentLateOrders 
,cast(round(LateOrders*100.0/totalorder,2) as numeric(10,2)),
convert(decimal(10,2), (LateOrders*100.0/totalorder) )
from
(select Employees.EmployeeID,LastName,totalorder,isnull(totalOrderWithLate,0) as LateOrders 
      
from Allorders left join totalLate
on totalLate.EmployeeID = Allorders.EmployeeID
inner join Employees
on Employees.EmployeeID = Allorders.EmployeeID) as newtab
order by totalorder Desc
----------------------------------------------------------------------------------------
select Customers.CustomerID,
       CompanyName,
	   count(Orders.OrderID) as TotalOrders,
	   sum(Quantity*UnitPrice) as TotalAmount,
	   DENSE_RANK() OVER(order by sum(Quantity*UnitPrice) DESC) as DR
	   from Orders
inner Join Customers
on Customers.CustomerID = Orders.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID
where year(orderDate) = 2016
group by Customers.CustomerID,CompanyName
order by Customers.CustomerID ASC
-------------------------------------------------------------------------------------
select Customers.customerId,
       CompanyName,count(*) as TotalOrders , 
	   sum(Quantity*UnitPrice) as TotalAmount,
	   case when sum(Quantity*UnitPrice) between 0 and 1000 then 'Low' 
	        when sum(Quantity*UnitPrice) between 1000 and 5000 then 'Medium'
			when sum(Quantity*UnitPrice) between 5000 and 10000 then 'High'
			else 'Very High'
			end as CustomerGroup

from Customers
inner join Orders
on Orders.CustomerID = Customers.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID and Year(OrderDate) = 2016 
--where Year(OrderDate) = 2016
group by Customers.CustomerID,CompanyName
order by TotalAmount DESC
------------------------------------------------------------------------------------------------------
Go
with XXX as (
select Customers.customerId,
       CompanyName,
	   count(*) as TotalOrders , 
	   sum(Quantity*UnitPrice) as TotalAmount,
	   case when sum(isnull(Quantity,0)*isnull(UnitPrice,0)) >= 0    and sum(isnull(Quantity,0)*isnull(UnitPrice,0)) < 1000 then 'Low' 
	        when sum(isnull(Quantity,0)*isnull(UnitPrice,0)) >= 1000 and sum(isnull(Quantity,0)*isnull(UnitPrice,0)) < 5000 then 'Medium'
			when sum(isnull(Quantity,0)*isnull(UnitPrice,0)) >= 5000 and sum(isnull(Quantity,0)*isnull(UnitPrice,0)) < 10000 then 'High'
			else 'Very High'
			end as CustomerGroup

from Customers
inner join Orders
on Orders.CustomerID = Customers.CustomerID
inner join OrderDetails
on OrderDetails.OrderID = Orders.OrderID and Year(OrderDate) = 2016 
--where Year(OrderDate) = 2016
group by Customers.CustomerID,CompanyName)

select count(CustomerID) as CountCustomerInEachOrder,CustomerGroup from XXX
group by CustomerGroup
order by CountCustomerInEachOrder DESC
------------------------------------------------------------------------------------------------------
With CustomerTotalOrder_2016(CustomerID, CompanyName, TotalOrderAmount) AS
    (Select Customers.CustomerID, Customers.CompanyName,
    TotalOrderAmount = SUM(Quantity * UnitPrice)
    From Customers
        join Orders
            on Orders.CustomerID = Customers.CustomerID
        join OrderDetails
            on Orders.OrderID = OrderDetails.OrderID
        Where  
            YEAR(Orders.OrderDate) = 2016
        group by Customers.CustomerID, Customers.CompanyName)
select distinct
  CustomerGroup,
  count(CustomerGroup) over(partition by CustomerGroup) as TotalInGroup,
  (count(CustomerGroup) over(partition by CustomerGroup))*100.0/(select count(*)
from CustomerTotalOrder_2016) as PercentageInGroup
from
    (select
    case
      when 0 <= TotalOrderAmount AND TotalOrderAmount <= 1000 Then 'Low'
      when 1000 < TotalOrderAmount AND TotalOrderAmount <= 5000 Then 'Medium'
      when 5000 < TotalOrderAmount AND TotalOrderAmount <= 10000 Then 'High'
      when TotalOrderAmount > 10000  Then 'Very High'
    end as CustomerGroup
    from CustomerTotalOrder_2016) AS T
order by TotalInGroup desc
-----------------------------------------------------------------------------------------

With CustomerTotalOrder_2016(CustomerID, CompanyName, TotalOrderAmount) AS
    (Select Customers.CustomerID, Customers.CompanyName,
        TotalOrderAmount = SUM(Quantity * UnitPrice)
    From Customers
        join Orders
            on Orders.CustomerID = Customers.CustomerID
        join OrderDetails
            on Orders.OrderID = OrderDetails.OrderID
        Where  
            YEAR(Orders.OrderDate) = 2016
        group by Customers.CustomerID, Customers.CompanyName)
select CustomerID, CompanyName, TotalOrderAmount, CustomerGroupName
from CustomerTotalOrder_2016
    join CustomerGroupThresholds
        on (RangeBottom < TotalOrderAmount)
        and (RangeTop > TotalOrderAmount)
order by CustomerID
-----------------------------------------------------------------------------------------------
select Country from Suppliers 
except
select Country from Customers 
--Union »Ì— » ÊÌ‘Ì· «·„ ﬂ—— 
--union all »Ì÷Ì› «·« ‰Ì‰ ›Êﬁ »⁄÷ Ê»ÌﬂÊ‰ ›ÌÂ  ﬂ—«— ﬂ Ì— (gets only unique names from two tables)
--intersect 
--except

---------------------------------------------------------------------------------------------------------------
Go
with CountrySupplier as 
(
select distinct Country as Country_Spp from Suppliers
),countryCustomer as (
select distinct Country as Country_Cust  from Customers
)
select Country_Spp,Country_Cust from CountrySupplier
full outer join countryCustomer
on countryCustomer.Country_Cust = CountrySupplier.Country_Spp
------------------------------------------------------------------------------------------
Go
with CountrySupplier as 
(
select  Country as Country_Spp,count(*) as TotalSupplierInEachCountry from Suppliers group by Country
),countryCustomer as (
select  Country as Country_Cust,count(*) as TotalCustomerInEachCountry  from Customers group by Country
)
select coalesce(Country_Spp,Country_Cust) as Country , 
       isnull(TotalSupplierInEachCountry,0) , 
	   isnull(TotalCustomerInEachCountry,0)
From CountrySupplier
full outer join countryCustomer
on countryCustomer.Country_Cust = CountrySupplier.Country_Spp
----------------------------------------------------------------------------------------------------
GO
WITH cte as (
Select          
    ShipCountry 
    ,CustomerID 
    ,OrderID  
    ,convert(date, OrderDate) as DD,
	ROW_NUMBER() over(partition by ShipCountry order by ShipCountry,OrderID) as RN
From orders  
--Order by  ShipCountry,OrderID
)
select ShipCountry,CustomerID,OrderID,DD from cte
where RN = 1
order by ShipCountry,OrderID

-----------------------------------------------------
with cte as (
Select 
    InitialOrder.CustomerID 
    ,InitialOrderID = InitialOrder.OrderID 
    ,InitialOrderDate = InitialOrder.OrderDate 
    ,NextOrderID = NextOrder.OrderID 
    ,NextOrderDate = NextOrder.OrderDate ,
	ABS(DATEDIFF(day,NextOrder.OrderDate,InitialOrder.OrderDate)) as DaysBetween
from Orders InitialOrder 
    join Orders NextOrder 
        on InitialOrder.CustomerID = NextOrder.CustomerID 
where InitialOrder.OrderID < NextOrder.OrderID )
select * from cte where DaysBetween <= 5
Order by  
    cte.CustomerID



-------------------------------------------------------------------------------------------------------------------	-------------------------------------------------------------------------------------------------------------------


