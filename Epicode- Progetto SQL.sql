-- Product Table
CREATE TABLE Product (
    Product_ID char(4) primary key,
    ProductName VARCHAR(255),
    Price int,
    Category_ID CHAR(4)
	);
    
    Insert into Product (Product_ID, ProductName, Price, Category_ID) 
    values 
('P001', 'Aimen', 10, 'C001')
, ('P002', 'Rotul', 15,  'C002')
, ('P003', 'Gensis', 5, 'C003')
, ('P004', 'Goom', 28, 'C004')
;

-- Verifica l'unicità della chiave primaria
SELECT COUNT(Product_ID) AS NumDuplicates
FROM Product
GROUP BY Product_ID
HAVING COUNT(Product_ID) > 1;

-- Region Table
create TABLE Region (
    Region_ID char(4) PRIMARY KEY,
    RegionName VARCHAR(100)
    );

insert into region (Region_ID, RegionName)
value
('R001', 'SouthEurope')
, ('R002', 'NorthEurope')
, ('R003', 'WestEurope')
;

-- Verifica l'unicità della chiave primaria
SELECT COUNT(Region_ID) AS NumDuplicates
FROM region
GROUP BY Region_ID
HAVING COUNT(Region_ID) > 1;

-- Sales Table
CREATE TABLE Sales (
    Sales_ID char(4) PRIMARY KEY,
    SalesDate DATE,
    Amount INT,
    Product_ID char (4),
    State_ID char (4)
  );

INSERT INTO Sales (Sales_ID, SalesDate, Amount, Product_ID, State_ID)
Values
('S001', '2023-07-17', 10, 'P002', 'ST01')
, ('S002', '2023-08-09', 5, 'P003', 'ST02')
, ('S003', '2023-08-22', 15, 'P001', 'ST03')
, ('S004', '2023-08-22', 7, 'P002', 'ST04' )
;

-- Verifica l'unicità della chiave primaria
SELECT COUNT(Sales_ID) AS NumDuplicates
FROM Sales
GROUP BY Sales_ID
HAVING COUNT(Sales_ID) > 1;

-- Category table
create table Category (
Category_ID char (4) primary key,
CategoryName varchar (255)
);

insert into category (Category_ID, CategoryName)
values
('C001', 'Books')
, ('C002', 'Videogames')
, ('C003', 'Accessories')
, ('C004', 'Food')
;

-- Verifica l'unicità della chiave primaria
SELECT COUNT(Category_ID) AS NumDuplicates
FROM Category
GROUP BY category_ID
HAVING COUNT(category_ID) > 1;

-- State table
create table State (
State_ID char(4),
StateName varchar(255),
Region_ID char (4)
);

insert into State (State_ID, StateName, Region_ID)
values
('ST01', 'italy', 'R001')
, ('ST02', 'France', 'R003')
, ('ST03', 'Germany', 'R002')
, ('ST04', 'Norway', 'R002')
;

-- Verifica l'unicità della chiave primaria
SELECT COUNT(State_ID) AS NumDuplicates
FROM State
GROUP BY State_ID
HAVING COUNT(State_ID) > 1;

/* 2)	Esporre l’elenco delle transazioni indicando nel result set:
 il codice documento, la data, il nome del prodotto, la categoria del prodotto, il nome dello stato, 
 il nome della regione di vendita e un campo booleano valorizzato in base alla condizione 
 che siano passati più di 180 giorni dalla data vendita o meno 
(>180 -> True, <= 180 -> False)
*/

Select Sales_ID, SalesDate, ProductName, Category, StateName, RegionName, 
case 
when datediff(now(),salesdate) > 180
then true
else false
end as DateTime

from Sales, product, category, State, region;



/*3) Esporre l’elenco dei prodotti che hanno venduto, in totale, 
una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito. 
(ogni valore della condizione deve risultare da una query e non deve essere inserito a mano). 
Nel result set devono comparire solo il codice prodotto e il totale venduto.
*/



SELECT p.product_ID, SUM(s.amount) AS total_sold
FROM product p
JOIN sales s ON p.product_ID = s.product_ID
WHERE s.salesdate BETWEEN CURDATE() - INTERVAL 1 YEAR AND CURDATE()
GROUP BY p.product_ID
HAVING total_sold > (SELECT AVG(sub.total_amount) 
                    FROM (SELECT p.product_ID, SUM(s.amount) AS total_amount
                          FROM product p
                          JOIN sales s ON p.product_ID = s.product_ID
                          WHERE s.salesdate BETWEEN CURDATE() - INTERVAL 1 YEAR AND CURDATE()
                          GROUP BY p.product_ID) sub);


-- 4) Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno. 

SELECT
    P.Product_ID,
    ProductName,
    YEAR(SalesDate) AS SalesYear,
    SUM(Amount * P.Price) AS TotalRevenue
FROM
    Product AS P
JOIN
    Sales AS S ON P.Product_ID = S.Product_ID
GROUP BY
    P.Product_ID, P.ProductName, SalesYear
ORDER BY
    P.Product_ID, SalesYear;

/*5) Esporre il fatturato totale per stato per anno. 
Ordina il risultato per data e per fatturato decrescente
*/


SELECT
    S.State_ID,
    YEAR(SalesDate) AS Anno,
    SUM(Amount * p.Price) AS FatturatoTotale
FROM
    Sales as S
JOIN
    Product as P ON S.Product_ID = P.Product_ID
GROUP BY
   S.State_ID, Anno
ORDER BY
    Anno ASC, FatturatoTotale DESC;


-- 6) qual è la categoria di articoli maggiormente richiesta dal mercato?

SELECT
    P.Category_ID,
    SUM(Amount) AS TotalQuantity
FROM
    Product AS P
JOIN
    Sales AS S ON P.Product_ID = S.Product_ID
GROUP BY
    P.Category_ID
ORDER BY
    TotalQuantity DESC
LIMIT 1;


-- 7) quali sono i prodotti invenduti?

SELECT
    Product.Product_ID, ProductName
FROM
    Product
LEFT JOIN
    Sales ON Product.Product_ID = Sales.Product_ID
WHERE
    Sales.Product_ID IS NULL;


/* 8)	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni utili 
(codice prodotto, nome prodotto, nome categoria)
*/

CREATE VIEW DenormalizedProductView AS
SELECT
    P.Product_ID,
    P.ProductName,
    C.CategoryName
FROM
    Product as P
JOIN
    Category C ON P.Category_ID = C.Category_ID;

-- 9)	Creare una vista per le informazioni geografiche

-- Creazione della vista geografica
CREATE VIEW GeographicInfoView AS
SELECT
    ST.State_ID,
    ST.StateName,
    ST.Region_ID,
    R.RegionName
FROM
    State ST
JOIN
    Region R ON ST.Region_ID = R.Region_ID;