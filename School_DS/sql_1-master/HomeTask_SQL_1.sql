--1. Выберите заказчиков из Германии, Франции и Мадрида, выведите их название, страну и адрес.
select 
	CustomerName
	, Country
	, PostalCode || ', ' || City || ', ' || Address as FullAddress
from 
	Customers
where
	Country in ('Germany', 'France') or City = 'Madrid'

--2. Выберите топ 3 страны по количеству заказчиков, выведите их названия и количество записей.
SELECT 
	country
    , count(*) as CustomersCount 
FROM 
	customers
group by 
	country
order by 
	2 desc
limit 3

--3. Выберите перевозчика, который отправил 10-й по времени заказ, выведите его название, и дату отправления.
select 
	s.ShipperName
    , b.orderdate 
from 
	(
    	SELECT *
		FROM Orders
		order by 
			orderdate
			, orderid
		limit 10
    ) b
	join shippers s on b.shipperid = s.shipperid
order by 
	b.orderid desc
limit 1

--4. Выберите самый дорогой заказ, выведите список товаров с их ценами.
select
	ProductName
    , Price
from 
	orderdetails od
    join (
          SELECT 
              orderid
              , sum(quantity*price) as fullPrice 
          FROM 
              OrderDetails od 
              join products p on p.productid = od.productid
         group by orderid
         order by 
              sum(quantity*price) desc
          limit 1
        ) ap on ap.orderid = od.orderid
        join products p on p.productid = od.productid

--5. Какой товар больше всего заказывали по количеству единиц товара, выведите его название и количество единиц в каждом из заказов.
select 
	p.productname
    , od.orderid
    , od.quantity
from 
	orderdetails od 
   	join products p on p.productid = od.productid 
where
od.productid = 
	(
      SELECT productid FROM OrderDetails
      group by productid
      order by sum(quantity) desc
      limit 1
    )

--6. Выведите топ 5 поставщиков по количеству заказов, выведите их названия, страну, контактное лицо и телефон.
SELECT distinct 
    s.SupplierName
    , s.Country
	, s.ContactName
    , s.Phone
FROM 
	orderdetails od
    join products p on p.productid = od.productid
    join suppliers s on s.SupplierID = p.SupplierID
group by
	p.SupplierID
    , s.SupplierName
    , s.Country
	, s.ContactName
    , s.Phone
order by 
	count(orderid) desc
limit 5


--7. Какую категорию товаров заказывали больше всего по стоимости в Бразилии, выведите страну, название категории и сумму.
-- наверное это имелось в виду, так как сказано по стоимости, а не по стоимости заказа
SELECT 
	c.Country
    , ca.CategoryName
    , sum(od.Quantity) as QuantitySumm
FROM 
	customers c
    join orders o on o.CustomerID = c.CustomerID and c.Country = 'Brazil'
    join orderdetails od on od.OrderID = o.OrderID
    join products p on p.ProductID = od.ProductID
    join Categories ca on ca.CategoryID = p.CategoryID
group by 
	p.categoryid
    , p.productid
    , p.price
    , c.Country
    , ca.CategoryName
order by 
	sum(od.quantity) desc
limit 1

--8. Какая разница в стоимости между самым дорогим и самым дешевым заказом из США.
select 
	FullPriceMax - FullPriceMin as DeltaMaxMin
from 
	(
        SELECT 
            sum(quantity*price) as FullPriceMax
        FROM 
          OrderDetails od 
          join products p on p.productid = od.productid
        group by orderid
        order by 
          sum(quantity*price) desc
        limit 1
	),
    (
		SELECT 
            orderid,
            sum(quantity*price) as FullPriceMin
        FROM 
          OrderDetails od 
          join products p on p.productid = od.productid
        group by orderid
        order by 
          sum(quantity*price)
        limit 1
    ) min on 1=1

--9. Выведите количество заказов у каждого их трех самых молодых сотрудников, а также имя и фамилию во второй колонке.
SELECT 
	count(e.EmployeeID) as QuantityOrders
    , FirstName || ' ' || LastName as Name
FROM 
	Orders o
    join Employees e on e.EmployeeID = o.EmployeeID
group by
	e.EmployeeID
    , FirstName
    , LastName
    , e.BirthDate
order by 
	e.BirthDate desc
limit 3

--10. Сколько банок крабового мяса всего было заказано.
select 
	sum(Quantity) as BostonCrabMeat_Quantity
from 
	OrderDetails od
    join products p on p.ProductID = od.ProductID and productName = 'Boston Crab Meat'