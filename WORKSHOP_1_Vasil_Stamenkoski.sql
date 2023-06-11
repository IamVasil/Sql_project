
--Data types and data manipulation – Account tables-WORKSHOP_1
--Insert new Customer in the system
INSERT INTO dbo.Customer(FirstName,LastName,Gender,NationalIDNumber,DateOfBirth,isActive)
VALUES('Aleksandar', 'Aleksandrov', 'M','123456','1996-10-03',1)
SELECT * FROM dbo.Customer


--Insert new Employee in the system. Use your friend name
INSERT INTO dbo.Employee(FirstName, LastName,NationalIDNumber,DateOfBirth,Gender,HireDate)
VALUES('Andrijana', 'Videska', '654321','1993-04-16','F','2018-09-01')
SELECT * FROM dbo.Employee


--Insert 2 accounts for the new customer (EUR, USD)
INSERT INTO dbo.Account(AccountNumber,CustomerID,CurrencyID,AllowedOverdraft,CurrentBalance,EmployeeID)
VALUES(123456,301,5,50000.00,0.0,10)


INSERT INTO dbo.Account(AccountNumber,CustomerID,CurrencyID,AllowedOverdraft,CurrentBalance,EmployeeID)
VALUES(654321,301,6,100000.00,0.00,6)
SELECT * FROM dbo.Account


--Insert new location type in the database (Terminal)
INSERT INTO dbo.LocationType([Name],[Description])
VALUES('Terminal', 'Terminal')
SELECT * FROM dbo.LocationType


--Insert new location from type Terminal (e.g. Zara City mall post terminal)
INSERT INTO dbo.Location(LocationTypeId,Name)
VALUES(6,'Zara City mall post terminal')
SELECT * FROM dbo.[Location]


--Insert 1 transaction for each account we created in bullet 3 (income) –AccountDetails table
INSERT INTO dbo.AccountDetails(AccountID,LocationID,TransactionDate,Amount,PurpouseCode,PurpouseDescription)
VALUES(298,68,GETDATE(),'-1856.00',930,'isplata')
SELECT * FROM dbo.AccountDetails


--Insert 2 transactions for each account (outcome) as the transactions were performed from the Zara City Mall post terminal
INSERT INTO [dbo].[AccountDetails] (AccountId,LocationId,TransactionDate,Amount,PurpouseDescription)
VALUES(298,68,Getdate(),-200,'Isplata')


Insert Into [dbo].[AccountDetails] (AccountId,LocationId,TransactionDate,Amount,PurpouseDescription)
VALUES(280,30,Getdate(),-50,'Isplata')
Select * from [dbo].[AccountDetails]


--Change the Allowed overdraft on EUR account to be 10.000
UPDATE dbo.Account
SET AllowedOverdraft = '10.000'
WHERE ID = 301
SELECT * FROM dbo.Account

--WORKSHOP_2
--Add default constraint with value = 930 on PurposeCode column in AccountDetails table
ALTER TABLE dbo.AccountDetails
ADD CONSTRAINT DF_AccountDetails_PurpouseCode
DEFAULT(930) FOR PurpouseCode
GO

--Add Unique constraint on Name column in Location table
ALTER TABLE dbo.[Location]
ADD CONSTRAINT UC_Location_Name
UNIQUE(Name)
GO


--Add Check constraint on Account table to prevent inserting negative values in AllowedOverdraft column
ALTER TABLE dbo.Account
ADD CONSTRAINT CHK_Account_AllowedOverdraft
CHECK(AllowedOverdraft >=0)
GO


--WORKSHOP_3
--List all Customers with FirstName = ‘Aleksandra’
SELECT * FROM dbo.Customer
WHERE FirstName = 'Aleksandra'
GO


--List all Customers with FirstName = ‘Aleksandra’ and LastName starting with letter B
SELECT * FROM dbo.Customer
WHERE FirstName = 'Aleksandra' and LastName = 'B%'
GO


--Order the results by the LastName
SELECT * FROM dbo.Customer
WHERE LastName = ('')
ORDER BY LastName
GO


--Provide information about the total number of Customers with FirstName = ‘Aleksandra’ OR LastName starting with ‘B;
SELECT * FROM dbo.Customer
WHERE FirstName = 'Aleksandra' and LastName ='B%'
GO


--List all Customers that are born in February (any year)
SELECT * FROM dbo.Customer
WHERE MONTH(DateOfBirth) = 2
GO


--List all Customers that are born in February (any year) or their last name starts with B
SELECT * FROM dbo.Customer
WHERE MONTH(DateOfBirth) = 2 OR LastName = 'B%'
GO


--Provide total number of Female customers from Ohrid
SELECT * FROM dbo.Customer
WHERE Gender = 'F' and City = 'Ohrid'
GO


--Provide total number of customers born in Odd months in any year
SELECT * FROM dbo.Customer
WHERE MONTH(DateOfBirth)%2 <>0
GO


--WORKSHOP_4
--Calculate how many customers from each city are in the system
SELECT COUNT(*) as NumCustomer,City
FROM dbo.Customer
GROUP BY City


--Calculate how many male and female customers from each city are in the system
SELECT COUNT(*) as NumCustomer,Gender,City
FROM dbo.Customer
GROUP BY City,Gender
ORDER BY City


--List only cities having more then 25 Female customers. Provide City name and total number of Female customers
SELECT COUNT(*) as NumberFemale
FROM dbo.Customer
WHERE Gender = 'F'
GROUP BY c.City
HAVING COUNT(Gender)>25

