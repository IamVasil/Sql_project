-----HOMEWORK 4---(1) VASIL STAMENKOSKI 
--Create scalar function that will return the total available amount (MKD) for input @NationalNumber. Available amount should be calculated as allowed owerdraft + current balance
--E.g. my current balance is + 10.000 and I have  40.000 allowed overdraft, which means that my total available amount is 50.000


CREATE OR ALTER FUNCTION dbo.fn_TotalAvailableAmount (@NationalNumber NVARCHAR(15))
RETURNS DECIMAL(18,2)
AS
BEGIN

	DECLARE @Result DECIMAL(18,2)
	SELECT @Result = a.CurrentBalance + a.AllowedOverdraft 
	FROM dbo.Customer AS c
	INNER JOIN dbo.Account AS a ON c.ID = a.CustomerID
	INNER JOIN dbo.Currency AS cu ON cu.ID = a.CurrencyID
	WHERE cu.ShortName = 'MKD' AND @NationalNumber = c.NationalIDNumber

RETURN @Result

END

-----HOMEWORK 4---(2) VASIL STAMENKOSKI
--Create table valued function that for input parameter @NationalIDNumber  will return resultset with CurrencyName and current balance
GO
CREATE or ALTER FUNCTION [dbo].[fn_TotalAvailableAmount_Table](@NationalIDNumber nvarchar(15))
RETURNS @ResultSet TABLE (CurencyName NVARCHAR(20),CurentBalance DECIMAL(18,2))
AS
BEGIN
	
	INSERT INTO @ResultSet (CurencyName,CurentBalance)
	SELECT c.ShortName,SUM(ad.Amount) AS CurrentBalance 
	FROM dbo.Account AS a 
	INNER JOIN dbo.Currency AS c ON c.id=a.CurrencyId
	INNER JOIN dbo.Customer AS cu ON a.CustomerId=cu.id
	INNER JOIN dbo.AccountDetails AS ad ON ad.accountID=a.id
	WHERE cu.NationalIDNumber=@NationalIDNumber
	GROUP BY c.ShortName		
	RETURN
END



-----HOMEWORK 4---(3) VASIL STAMENKOSKI
--Prepare stored procedure that for LocationId and CurrencyID on input, will return:
--Biggest 2 transactions for that location and currency (CustomerName, TransactionAmount)
--Additionally if the location on input belongs to the "Pelagoniski region" then the procedure will additionally return the Purpose code and Purpose description information for the 2 biggest transactions
CREATE or ALTER PROCEDURE dbo.sp_BiggestTwoTransactions
(
	@LocationId int,
	@CurrencyId int
)
AS
BEGIN

	DECLARE @Region NVARCHAR(20)
	SELECT  @Region=ci.Region
	FROM dbo.[Location] AS l 
	INNER JOIN dbo.City AS ci ON ci.ID=l.CityId
	WHERE @LocationId=l.Id

;WITH CTE AS
	(
		SELECT c.FirstName + ' ' + c.LastName AS CustomerName,ad.Amount,
		ROW_NUMBER() OVER(PARTITION BY l.Id, cu.Id ORDER BY ad.Amount DESC) AS RN
		FROM dbo.Customer AS c
		INNER JOIN dbo.Account AS a ON a.CustomerId = c.Id
		INNER JOIN dbo.AccountDetails AS ad ON ad.AccountId = a.Id
		INNER JOIN dbo.Currency AS cu ON cu.Id = a.CurrencyId
		INNER JOIN dbo.[Location] AS l ON l.Id = ad.LocationId
		WHERE @LocationId = l.Id AND @CurrencyId = cu.id
	)

	SELECT * 
	FROM CTE
	WHERE RN IN (1,2)

END

EXEC dbo.sp_BiggestTwoTransactions
		@LocationId=74 ,
		@CurrencyId=1



-----HOMEWORK 4---(4) VASIL STAMENKOSKI
--Create procedure that will list all transactions for specific customer in and specific date interval
--Input: CustomerId, ValidFrom, ValidTo
--Output: CustomerFullName, LocationName,Amount,Currency
--Extend the procedure to add input parameter @EmployeeId for the employee that generates the report for the list of transactions.
--For auditing purposes for each execution of the report (procedure) we want to track which Employee executed the query and the input parameters he used during the execution. 
CREATE or ALTER PROCEDURE dbo.sp_TotalTransactions
(
	@CustomerId int,
	@ValidFrom date,
	@ValidTo date
)
AS
BEGIN

	SELECT c.FirstName + ' '+ c.LastName AS CustomerName, l.[Name] AS LocationName, ad.Amount, cu.ShortName AS CurrencyShortName
	FROM dbo.Customer AS c
	INNER JOIN dbo.Account AS a ON a.CustomerId = c.Id
	INNER JOIN dbo.AccountDetails AS ad ON ad.AccountId = a.Id
	INNER JOIN dbo.Currency AS cu ON cu.Id = a.CurrencyId
	INNER JOIN dbo.[Location] AS l ON l.Id = ad.LocationId
	WHERE c.Id=@CustomerId AND ad.TransactionDate >= @ValidFrom AND ad.TransactionDate <= @ValidTo
END

EXEC dbo.sp_TotalTransactions
	@CustomerId=1,
	@ValidFrom='2022-01-01',
	@ValidTo='2022-12-31'

--Prepare table for logging this executions
  CREATE TABLE dbo.CustomerReports
(
	EmployeeName NVARCHAR(50),
	CustomerId INT,
	ValidFrom DATE,
	ValidTo DATE
)

 CREATE or ALTER PROCEDURE dbo.sp_TotalTransactions2
(
	@CustomerId INT,
	@ValidFrom DATE,
	@ValidTo DATE,
	@EmployeeId INT
)
 AS
 BEGIN

	SELECT c.FirstName + ' ' + c.LastName AS CustomerName, l.[Name] AS LocationName, ad.Amount, cu.ShortName AS CurrencyShortName
	FROM dbo.Customer AS c
	INNER JOIN dbo.Account AS a ON a.CustomerId = c.Id
	INNER JOIN dbo.AccountDetails AS ad ON ad.AccountId = a.Id
	INNER JOIN dbo.Currency AS cu ON cu.Id = a.CurrencyId
	INNER JOIN dbo.[Location] AS l ON l.Id = ad.LocationId
	WHERE c.Id = @CustomerId AND ad.TransactionDate >= @ValidFrom AND ad.TransactionDate <= @ValidTo

	INSERT INTO dbo.CustomerReports(EmployeeName, CustomerId, ValidFrom, ValidTo)
	SELECT
	e.FirstName + ' ' + e.LastName, @CustomerId, @ValidFrom, @ValidTo
	FROM dbo.Employee AS e
	WHERE e.Id = @EmployeeId

	SELECT * FROM dbo.CustomerReports
END


EXEC dbo.sp_TotalTransactions2
	@CustomerId=1,
	@ValidFrom='2022-01-01',
	@ValidTo='2022-12-31',
	@EmployeeId=5
--Prepare new procedure for reading the logged data
--Input: ValidFrom, ValidTo
--Output: Employee Name, CustomerName, executions count
CREATE or ALTER PROCEDURE dbo.sp_ReadingLogs
(
@ValidFrom1 date,
@ValidTo1 date
)
AS
BEGIN


	SELECT cr.EmployeeName, c.FirstName + ' ' + c.LastName AS CustomerName, COUNT(*) AS ExecutionsCount
	FROM dbo.CustomerReports AS cr
	INNER JOIN dbo.Customer AS c ON c.Id = cr.CustomerId
	WHERE cr.ValidFrom=@ValidFrom1 AND cr.ValidTo = @ValidTo1
	GROUP BY cr.EmployeeName, c.FirstName + ' ' + c.LastName

END

EXEC dbo.sp_ReadingLogs
	@ValidFrom1='2022-01-01',
	@ValidTo1='2022-12-31'



-----HOMEWORK 4---(5) VASIL STAMENKOSKI
--Create procedure that will list Avarage Salary for Customer from his last 3 Paychecks (purpose code 101) on his MKD account,
--Input: CustomerId, 
--Output: CustomerFullName,AverageSalaryFromLast3Months, AllowedOverdraft
--Note: insert new rows if you need more than 3 paychecks in account details
--Create New procedure that will fix the current Customer Allowed Overdraft If it is different than the calculated averageSalary * 2 from previous Procedure.
--Input: CustomerId
--Output – If the customer needed Allowed Overdraft update then update the AllowedOverdraft and return Customer Name and flag named NeedsFix with values true or false depending if the customer current Allowed Overdraft was different than the new calculated Value 
INSERT INTO dbo.AccountDetails(AccountId,LocationId,TransactionDate,Amount,PurposeCode)
Values (1,1,'2022-03-15',88000,101),
		(1,2,'2022-04-15',50000,101),
		(1,3,'2022-05-15',30000,101)

CREATE OR ALTER PROCEDURE dbo.sp_AvarageSalary
(	
	@CustomerID INT
)
AS
BEGIN

	SELECT c.FirstName + ' ' + c.LastName AS CustomerFullName, AVG(ad.Amount) AS AverageSalary,a.AllowedOverdraft
	FROM dbo.Customer AS c
	INNER JOIN dbo.Account a ON c.Id = a.CustomerId
	INNER JOIN dbo.AccountDetails AS ad ON a.Id = ad.AccountId
	INNER JOIN dbo.Currency cu ON cu.id = a.CurrencyId
	WHERE a.CustomerId = @CustomerID AND cu.ShortName = 'MKD' AND ad.PurposeCode = 101  AND ad.transactiondate >= DATEADD(MONTH,-3,GETDATE())
	GROUP BY  c.FirstName + ' ' + c.LastName, a.AllowedOverdraft

RETURN

END

EXEC dbo.sp_AvarageSalary @CustomerID = 4


GO

CREATE OR ALTER PROCEDURE dbo.sp_FixAllowedOverdraft
(	
	@CustomerID INT 
)
AS
BEGIN 

	DECLARE @Fix TABLE 
	(
		CustomerFullName NVARCHAR(101),
		AverageSalary DECIMAL(18,2),
		AllowedOverdraft DECIMAL(18,2)
	)

	INSERT INTO @Fix 
	EXEC dbo.sp_AvarageSalary @CustomerID = @CustomerID

	DECLARE @CustomerFullNameFix NVARCHAR (101)
	SELECT @CustomerFullNameFix = CustomerFullName FROM @Fix

	DECLARE @AverageSalaryFix DECIMAL (18,2)
	SELECT @AverageSalaryFix =AverageSalary FROM @Fix

	DECLARE @AllowedOverdraft DECIMAL (18,2)
	SELECT @AllowedOverdraft = AllowedOverdraft FROM @Fix

	DECLARE @AllowedOverdraftFix DECIMAL (18,2)
	SELECT @AllowedOverdraftFix = (2 * AverageSalary) FROM @Fix

	DECLARE @FlagsTrue NVARCHAR(20) = 'True'

	DECLARE @FlagsFalse NVARCHAR(20) = 'False'


	IF (@AllowedOverdraftFix<>@AllowedOverdraft )
		BEGIN
			PRINT @CustomerFullNameFix + ' ' + 'NeedFix=' + @FlagsTrue
			UPDATE a
			SET a.AllowedOverdraft =@AllowedOverdraftFix
			FROM dbo.Account AS a
			WHERE a.CustomerId = @CustomerID AND a.CurrencyId = (SELECT cu.ID FROM dbo.Currency AS cu WHERE cu.ShortName = 'MKD');

		END
	ELSE
		BEGIN
		SELECT @CustomerFullNameFix AS CustomerFullName, @FlagsFalse AS NeedFix
		END

END
GO

EXEC dbo.sp_FixAllowedOverdraft
	@CustomerID = 12
