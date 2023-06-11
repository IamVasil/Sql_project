CREATE DATABASE SQLProject_VasilStamenkoski
GO

USE SQLProject_VasilStamenkoski
GO

--1. Seniority level

CREATE TABLE dbo.SeniorityLevel
(
	ID INT IDENTITY (1,1) NOT NULL,
	[Name] NVARCHAR (100) NOT NULL,
	CONSTRAINT PK_SeniorityLevel PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--2. Location  

CREATE TABLE dbo.[Location]
(
	ID INT IDENTITY (1,1) NOT NULL,
	CountryName NVARCHAR(100) NULL,
	Continent NVARCHAR(100) NULL,
	Region NVARCHAR(100) NULL,
	CONSTRAINT PK_Location PRIMARY KEY CLUSTERED (ID ASC)
)
GO


--3. Department 

CREATE TABLE dbo.Department
(
	ID INT IDENTITY (1,1) NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Department PRIMARY KEY CLUSTERED (ID ASC)
)
GO


--Employee   

CREATE TABLE dbo.Employee
(
	ID INT IDENTITY (1,1) NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	LocationID INT NOT NULL,
	SeniorityLevelID INT NOT NULL,
	DepartmentID INT NOT NULL,
	CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (ID ASC)
)
GO

-- Salary
CREATE TABLE dbo.Salary
(
	ID BIGINT IDENTITY (1,1) NOT NULL,
	EmployeeID INT NOT NULL,
	[Month] SMALLINT NOT NULL,
	[Year] SMALLINT NOT NULL,
	GrossAmount DECIMAL(18,2) NOT NULL,
	NetAmount DECIMAL(18,2) NOT NULL,
	RegularWorkAmount DECIMAL(18,2) NOT NULL,
	BonusAmount DECIMAL(18,2) NOT NULL,
	OvertimeAmount DECIMAL(18,2) NOT NULL,
	VacationDays SMALLINT NOT NULL,
	SickLeaveDays SMALLINT NOT NULL,
	CONSTRAINT PK_Salary PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--Foreign keys
ALTER TABLE dbo.Employee WITH CHECK 
ADD CONSTRAINT FK_Employee_SeniorityLevel FOREIGN KEY (SeniorityLevelID)
REFERENCES dbo.SeniorityLevel (ID)
GO
ALTER TABLE dbo.Employee CHECK CONSTRAINT FK_Employee_SeniorityLevel
GO

ALTER TABLE dbo.Employee WITH CHECK 
ADD CONSTRAINT FK_Employee_Location FOREIGN KEY (LocationID)
REFERENCES dbo.[Location] (ID)
GO
ALTER TABLE dbo.Employee CHECK CONSTRAINT FK_Employee_Location
GO

ALTER TABLE dbo.Employee WITH CHECK 
ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentID)
REFERENCES dbo.Department (ID)
GO
ALTER TABLE dbo.Employee CHECK CONSTRAINT FK_Employee_Department
GO

ALTER TABLE dbo.Salary WITH CHECK 
ADD CONSTRAINT FK_Salary_Employee FOREIGN KEY (EmployeeID)
REFERENCES dbo.Employee (ID)
GO
ALTER TABLE dbo.Salary CHECK CONSTRAINT FK_Salary_Employee 
GO


--Vnes na podatoci vo senioritylevel
INSERT INTO dbo.SeniorityLevel ([Name]) 
VALUES 
	('Junior'),
	('Intermediate'),
	('Senor'),
	('Lead'),
	('Project Manager'),
	('Division Manager'),
	('Office manager'),
	('CEO'),
	('CTO'),
	('CIO')
GO 

--vnes na podatoci vo lokacija
INSERT INTO dbo.[Location] (CountryName,Continent,Region)
SELECT CountryName,Continent,Region 
FROM [WideWorldImporters].[Application].Countries
GO

--vnes na podatoci vo department
INSERT INTO dbo.Department ([Name])
VALUES 
	('Personal Banking & Operations'),
	('Digital Banking Department'),
	('Retail Banking & Marketing Department'),
	('Wealth Management & Third Party Products'),
	('International Banking Division & DFB'),
	('Treasury'),
	('Information Technology'),
	('Corporate Communications'),
	('Support Services & Branch Expansion'),
	('Human Resources')
GO

--Vnes vo empolye
INSERT INTO dbo.Employee (FirstName,LastName,LocationId,SeniorityLevelId,DepartmentId)
SELECT SUBSTRING(FullName, 1, CHARINDEX(' ', FullName) - 1) AS Firstname,     
       SUBSTRING(FullName, CHARINDEX(' ', FullName) + 1,LEN(FullName) - CHARINDEX(' ', FullName)) AS Lastname,1,1,1
FROM [WideWorldImporters].[Application].People

;WITH CTE as
(SELECT *
,	NTILE(10) OVER (ORDER BY ID) AS MySeniorityLevel
,	NTILE(10) OVER (ORDER BY FirstName) AS MyDepartment
,	NTILE(190) OVER (ORDER BY LastName) AS MyLocation
FROM dbo.Employee AS e
)

UPDATE C SET
	LocationID = MyLocation,
	SeniorityLevelID = MySeniorityLevel,
	DepartmentID = MyDepartment
FROM Cte as C
GO

--SELECT * FROM dbo.Employee

--salary
DECLARE @EmployeeID TABLE (EmployeeID INT)
INSERT INTO @EmployeeID
SELECT ID FROM dbo.Employee

DECLARE @Month TABLE ([Month] INT)
INSERT INTO @Month
VALUES
		(1), 
		(2),
		(3),
		(4),
		(5),
		(6),
		(7),
		(8),
		(9),
		(10),
		(11),
		(12)

DECLARE @Year TABLE ([Year] INT)
INSERT INTO @Year
VALUES
	(2001), 
	(2002), 
	(2003), 
	(2004), 
	(2005), 
	(2006),
	(2007),
	(2008),
	(2009),
	(2010),
	(2011),
	(2012),
	(2013),
	(2014),
	(2015), 
	(2016), 
	(2017),
	(2018),
	(2019),
	(2020)

CREATE TABLE #Temptbl (EmployeeID INT, [Month] INT, [Year] INT)
INSERT INTO #Temptbl
	SELECT * 
	FROM @EmployeeID
	CROSS JOIN @Month
	CROSS JOIN @Year
--drop table #Temptbl
INSERT INTO dbo.Salary (EmployeeID, [Month], [Year], GrossAmount, NetAmount, RegularWorkAmount, BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
SELECT EmployeeID, [Month], [Year], 1, 1, 1, 0, 0, 0, 0 
FROM #Temptbl 
ORDER BY [Year], [Month], EmployeeID
GO

;WITH cte AS
(
	SELECT *, 
	30000 + ABS(CHECKSUM(NewID())) % 30000 as GrossA
	FROM dbo.Salary
)
UPDATE dbo.Salary SET GrossAmount = cte.GrossA
FROM
	cte
	INNER JOIN dbo.Salary AS s ON s.id = cte.ID
WHERE s.ID = cte.ID
GO
---	Net amount should be 90% of the gross amount
UPDATE dbo.Salary SET NetAmount = ROUND(CAST (GrossAmount *90/100 AS decimal (18,2)), 0)
GO
---	RegularWorkAmount sould be 80% of the total Net amount for all employees and months
UPDATE dbo.Salary SET RegularWorkAmount = ROUND(CAST (NetAmount *80/100 AS decimal (18,2)), 0)
GO
--Bonus amount should be the difference between the NetAmount and RegularWorkAmount for every Odd month (January,March,..)
UPDATE dbo.Salary SET BonusAmount = NetAmount-RegularWorkAmount
WHERE [Month] IN (1,3,5,7,9,11)
GO
--OvertimeAmount  should be the difference between the NetAmount and RegularWorkAmount for every Even month (February,April,…)
UPDATE dbo.Salary SET OvertimeAmount = NetAmount-RegularWorkAmount
WHERE [Month] IN (2,4,6,8,10,12)
GO
--All employees use 10 vacation days in July and 10 Vacation days in December
UPDATE dbo.Salary SET VacationDays = 10
WHERE [Month] IN (7,12)
GO
--Additionally random vacation days and sickLeaveDays should be generated with the following script:
UPDATE dbo.salary SET vacationDays = vacationDays + (EmployeeId % 2)
WHERE  (employeeId + MONTH+ year)%5 = 1
GO

UPDATE dbo.salary SET SickLeaveDays = EmployeeId%8, vacationDays = vacationDays + (EmployeeId % 3)
WHERE  (employeeId + MONTH+ year)%5 = 2
GO


--Proveka
/*SELECT * FROM dbo.Salary
WHERE NetAmount <> (RegularWorkAmount + BonusAmount + OvertimeAmount)
queryto vrajka 0 redovi
*/
--DROP DATABASE SQLProject_VasilStamenkoski

