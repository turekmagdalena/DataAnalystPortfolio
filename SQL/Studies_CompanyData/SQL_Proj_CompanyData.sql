/***** Clear project ******/

DROP TABLE EmployeeBase
DROP TABLE Managers
DROP TABLE Departments
DROP TABLE Locations
DROP TABLE EmployeesData


/***** Create tables *****/

CREATE TABLE Departments
(
	DepartmentID int primary key identity (1,1),
	DepartmentName varchar(20),
	InternalNumber char(4) check (InternalNumber LIKE '[0-9][0-9][0-9][0-9]'),
	ExternalNumber char(9) check (ExternalNumber LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	HoD nvarchar(30) default 'TBD'
)

CREATE TABLE Locations
(
	LocationID int not null primary key identity (1,1),
	Country varchar(30),
	City varchar(30),
	LocationCode varchar(3) not null unique,
	Staff int default 100
)

CREATE TABLE Managers
(
	ManagerID int not null primary key identity (1,1),
	FirstName varchar(20),
	LastName varchar(20),
	EmailAddress varchar(30) check (EmailAddress LIKE '%@company.com'),
	DepartmentID int not null foreign key references Departments(DepartmentID)
)

CREATE TABLE EmployeesData
(
	EmployeeID int not null primary key identity (1,1),
	FirstName varchar(20) not null,
	LastName varchar(20) not null,
	SSN varchar(20) unique,
	PrivateMail varchar(30) check (PrivateMail LIKE '%@%.%')
)

CREATE TABLE EmployeeBase
(
	EmployeeID int not null foreign key references EmployeesData(EmployeeID) unique,
	WorkMail varchar(30) check (WorkMail LIKE '%@company.com'),
	DepartmentID int not null foreign key references Departments(DepartmentID),
	LocationID int not null foreign key references Locations(LocationID),
	ManagerID int not null foreign key references Managers(ManagerID),
	LastUpdate datetime
)

/***** Fill the tables *****/

INSERT INTO Departments VALUES ('IT', '1234', '456789010', DEFAULT)
INSERT INTO Departments VALUES ('Sales', '5670', '456789011', 'John Lennon')
INSERT INTO Departments VALUES ('Marketing', '9876', '456789012', 'John Cash')
SELECT * FROM Departments

INSERT INTO Locations VALUES ('Uruguay', 'Montevideo', 'MVD', 1200)
INSERT INTO Locations VALUES ('Poland', 'Krakow', 'KRK', DEFAULT)
SELECT * FROM Locations

INSERT INTO Managers VALUES ('Juan', 'Pravia', 'juan.pravia@company.com', 2)
INSERT INTO Managers VALUES ('Anna', 'Potocka', 'anna.potocka1@company.com', 1)
INSERT INTO Managers VALUES ('Justyna', 'Mucharska', 'justyna.mucharska@company.com', 1)
SELECT * FROM Managers

INSERT INTO EmployeesData VALUES ('Jan', 'Kowalski', '99100212539', 'jankowalski@gmail.com')
INSERT INTO EmployeesData VALUES ('Michael', 'Mambepe', '90100212539', 'mambepe@gmail.com')
INSERT INTO EmployeesData VALUES ('Eliza', 'Orzeszkowa', '80100212539', 'orzeszek@buziaczek.pl')
SELECT * FROM EmployeesData

INSERT INTO EmployeeBase VALUES (1, 'jank@company.com', 2, 2, 2, GETDATE())
INSERT INTO EmployeeBase VALUES (2, 'mambepe@company.com', 1, 2, 1, GETDATE())
INSERT INTO EmployeeBase VALUES (3, 'orzeszkowa@company.com', 2, 2, 1, GETDATE())
SELECT * FROM EmployeeBase

/*** Display data ***/

SELECT m.ManagerID, m.FirstName, m.LastName, m.EmailAddress, d.DepartmentName
FROM Managers AS m
LEFT JOIN Departments as d
ON m.DepartmentID = d.DepartmentID

SELECT ed.EmployeeID, eb.WorkMail, d.DepartmentName, l.LocationCode, m.FirstName + ' ' + m.LastName AS 'Manager'
FROM EmployeeBase AS eb
LEFT JOIN EmployeesData as ed
ON eb.EmployeeID = ed.EmployeeID
LEFT JOIN Departments as d
ON eb.DepartmentID = d.DepartmentID
LEFT JOIN Locations as l
ON eb.LocationID = l.LocationID
LEFT JOIN Managers as m
ON eb.ManagerID = m.ManagerID