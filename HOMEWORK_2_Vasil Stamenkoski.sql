
--HOMEWORK 2 VASIL STAMENKOSKI
--List all customers in the database having any transactions in Cities different then the Cities where they belong to.
SELECT * FROM dbo.Customer
SELECt * FROM dbo.Account
SELECT * FROM dbo.AccountDetails
SELECT * FROM dbo.[Location]
SELECT DISTINCT c.FirstName+ '  ' +c.LastName AS FirstLastName,c.CityID AS CustomerCity,l.CityID AS LocationCity
FROM dbo.Customer as C
INNER JOIN dbo.Account a ON c.Id = a.CustomerId
INNER JOIN dbo.AccountDetails ad ON a.Id = ad.AccountId
INNER JOIN dbo.Location l ON l.Id = ad.LocationId
WHERE c.CityID <> l.CityID
--Pre-requisite is to update customer and Location table records with City information
SELECT * FROM dbo.Customer
SELECT * FROM dbo.Employee

SELECT DISTINCT c.FirstName,e.LastName
FROM dbo.Customer C 
CROSS JOIN dbo.Account A 
CROSS JOIN dbo.Employee E
--Create query that will contain All possible combinations between Customer First Names and Employee last names. 
--Put the resultset in new table called MyNames. Table should have only 1 column – MyFullName
--Prepare query that will read the data stored in MyNames table and provide 2 columns as resultset – FirstName and LastName
CREATE TABLE #MyNames
(
	MyFullName NVARCHAR (20) null
)

INSERT INTO #MyNames (MyFullName)
SELECT DISTINCT c.FirstName+ ' ' + e.LastName
FROM dbo.Customer C 
CROSS JOIN dbo.Account A 
CROSS JOIN dbo.Employee E

SELECT * FROM #MyNames

Select 
*,
LEFT(MyFullName, CHARINDEX(' ', MyFullName ) - 1) as FirstName,
SUBSTRING(MyFullName,CHARINDEX(' ', MyFullName) + 1,LEN(MyFullName) - CHARINDEX(' ', MyFullName)) as LastName
FROM #MyNames


--Calculate the total Outflow amount for all ATM’s in Resen and Kumanovo performed by customers born after 1905.12.01 
SELECT  c.FirstName + ' ' +c.LastName AS FisrtLastName, SUM(ad.Amount) TotalAmountOutflow
FROM dbo.Customer C
INNER JOIN dbo.Account A ON c.ID=a.CustomerId
INNER JOIN dbo.AccountDetails ad ON ad.AccountID = a.ID
INNER JOIN dbo.Location L ON ad.LocationID =l.ID
WHERE c.DateofBirth > '1905-12-01' AND (l.Name like '%Resen%' OR L.Name LIKE '%Kumanovo%') AND ad.Amount < 0
GROUP BY c.FirstName + ' '+c.LastName

--Steps:
--Define scalar variable @DateOfBirth and assign a specific date – 1905.12.01
DECLARE @DateofBirth date = '1905-12-01'
SELECT c.ID,c.FirstName,c.LastName,c.DateofBirth
FROM dbo.Customer C
WHERE c.DateofBirth > @DateofBirth
--Find all Customers born after that date
SELECT c.ID,c.FirstName,c.LastName
FROM dbo.Customer C
WHERE c.DateofBirth >@DateofBirth

SELECT* FROM dbo.Customer

--Store the CustomerID data in temp table (#Customers)
CREATE TABLE #Customer
(
	ID int ,
	FirstName nvarchar(15),
	LastName nvarchar(15),
)
--Define Table variable @Locations
DECLARE @Locations TABLE
(
	LocationId INT
)
--Table variable should contain ids for all ATM’s in Resen and Kumanovo
INSERT INTO @Locations (LocationId)
SELECT l.Id
FROM dbo.Location as L
WHERE l.Name LIKE '%Resen%' OR l.Name LIKE '%Kumanovo%'

--Calculate the total Outflow amount for all locations in Locations variable and customers  stored in #Customer table
SELECT SUM(ad.Amount)
FROM dbo.Customer AS c
JOIN dbo.Account AS a ON c.Id=a.CustomerId
JOIN dbo.AccountDetails AS ad ON ad.AccountId=a.Id
JOIN [Location] AS L ON L.LocationTypeId =ad.LocationId
WHERE ad.Amount<0 AND c.DateOfBirth>@DateOfBirth
