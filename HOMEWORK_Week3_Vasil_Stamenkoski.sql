--Workshop 1  subqueries

--all accounts that are not open from user with NationalIdNumber 7137597 . 
--For those accounts additionally show how many accounts in total has the owner (customer) of the account
SELECT a.CustomerId, COUNT(a.AccountNumber) TotalAccountNumbers
FROM dbo.Account a
WHERE a.EmployeeId NOT IN (SELECT e.ID FROM dbo.Employee e WHERE e.NationalIDNumber=7137597)
GROUP BY a.CustomerId



--Workshop - 2 - joins
 
SELECT 
	ad.*
FROM
	dbo.AccountDetails AS ad
	LEFT JOIN dbo.Employee AS e ON e.ID = ad.EmployeeId
WHERE 
	ad.AccountId = 1 
	ORDER BY EmployeeId



---WORKSHOP 3

SELECT COUNT(*) 
FROM dbo.Account as a
WHERE 
	EmployeeId IN (SELECT ID
				  FROM	dbo.Employee
				  WHERE Gender = 'M') 
				  AND
	CustomerId IN (SELECT ID
				  FROM dbo.Customer 
				  WHERE Gender = 'F' )



--WORKSHOP 4
--Prepare query with 2 most often used locations for transactions for the male customers and for the female customers.
;WITH MyCte AS
(SELECT c.Gender,l.[Name],COUNT(*) as NumberOfTransaction,
	ROW_NUMBER() OVER (PARTITION BY c.Gender ORDER BY c.Gender,COUNT(*) DESC) AS rn
FROM dbo.AccountDetails AS ad
	inner join dbo.Account AS a ON ad.AccountId=a.Id
	inner join dbo.Customer AS c ON c.ID=a.CustomerId
	inner join dbo.[Location] AS l ON l.Id=ad.LocationId
	GROUP BY c.Gender,l.[Name],YEAR(ad.TransactionDate) 
)

SELECT GENDER,[Name], NumberOfTransaction
FROM MyCte WHERE rn<=2