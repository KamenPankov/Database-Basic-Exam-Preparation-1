--Section 1. DDL (30 pts)
CREATE DATABASE Airport
USE Airport

CREATE TABLE Planes
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	Range INT NOT NULL
)

CREATE TABLE Flights
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	Address VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL,
)

CREATE TABLE LuggageTypes
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	Type VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES LuggageS(Id) NOT NULL,
	Price DECIMAL(15, 2) NOT NULL
)

--Section 2. DML (10 pts)
--2, Insert
INSERT INTO Planes(Name, Seats, Range)
VALUES ('Airbus 336', 112, 5132),
		('Airbus 330', 432, 5325),
		('Boeing 369', 231, 2355),
		('Stelt 297', 254, 2143),
		('Boeing 338', 165, 5111),
		('Airbus 558', 387, 1342),
		('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes (Type)
VALUES ('Crossbody Bag'),
		('School Backpack'),
		('Shoulder Bag')

--3. Update
UPDATE Tickets
SET Price += 0.13 * Price
WHERE FlightId = (SELECT Id FROM Flights WHERE Destination = 'Carlsbad')

--4. Delete
DELETE FROM Tickets
WHERE FlightId = (SELECT Id FROM Flights WHERE Destination = 'Ayn Halagim')

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

--Section 3. Querying (40 pts)
--5. The "Tr" Planes
SELECT
	*
FROM Planes
WHERE LOWER(Name) LIKE '%tr%'
ORDER BY Id,
		 Name,
		 Seats,
		 Range

--6. Flight Profits
SELECT
	FlightId,
	SUM(Price) AS [Price]
FROM Tickets
GROUP BY FlightId
ORDER BY [Price] DESC,
		 FlightId

--7. Passenger Trips
SELECT
	CONCAT(P.FirstName, ' ', P.LastName) AS [Full Name],
	F.Origin,
	F.Destination
FROM Passengers AS P
JOIN Tickets AS T ON P.Id = T.PassengerId
JOIN Flights AS F ON T.FlightId = F.Id
ORDER BY [Full Name],
		 F.Origin,
		 F.Destination

--8. Non Adventures People
SELECT
	P.FirstName,
	P.LastName,
	P.Age
FROM Passengers AS P
LEFT JOIN Tickets AS T ON P.Id = T.PassengerId
WHERE T.PassengerId IS NULL
ORDER BY P.Age DESC,
		 P.FirstName,
		 P.LastName

--9. Full Info
SELECT
	CONCAT(P.FirstName, ' ', P.LastName) AS [Full Name],
	PL.Name AS [Plane Name],
	CONCAT(F.Origin, ' - ', F.Destination) AS [Trip],
	LT.Type AS [Luggage Type]
FROM Passengers AS P
JOIN Tickets AS T ON P.Id = T.PassengerId
JOIN Flights AS F ON T.FlightId = F.Id
JOIN Planes AS PL ON F.PlaneId = PL.Id
JOIN Luggages AS L ON T.LuggageId = L.Id
JOIN LuggageTypes AS LT ON L.LuggageTypeId = LT.Id
ORDER BY [Full Name],
		 [Plane Name],
		 F.Origin,
		 F.Destination,
		 [Luggage Type]

--10. PSP
SELECT
	PL.Name,
	PL.Seats,
	COUNT(T.PassengerId) AS [Passengers Count]
FROM Planes AS PL
LEFT JOIN Flights AS F ON PL.Id = F.PlaneId
LEFT JOIN Tickets AS T ON F.Id = T.FlightId
GROUP BY PL.Name,
		 PL.Seats
ORDER BY [Passengers Count] DESC,
		 PL.Name,
		 PL.Seats


--Section 4. Programmability (20 pts)
--11. Vacation
GO
CREATE FUNCTION udf_CalculateTickets
(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(50)
AS
BEGIN
	IF (@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!'
	END

	DECLARE @getFlightId INT = (SELECT Id FROM Flights WHERE Origin = @origin
														AND Destination = @destination)

	IF (@getFlightId IS NULL)
	BEGIN
		RETURN 'Invalid flight!'
	END

	DECLARE @getPrice DECIMAL(15, 2) = (SELECT Price FROM Tickets WHERE FlightId = @getFlightId)
	DECLARE @totalPrice DECIMAL(15, 2) = @getPrice * @peopleCount 
	DECLARE @result VARCHAR(50) = CONCAT('Total price ', @totalPrice)

	RETURN @result
END

SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)

--12. Wrong Data
GO
CREATE PROCEDURE usp_CancelFlights
AS
UPDATE Flights
SET DepartureTime = NULL, 
	ArrivalTime = NULL
WHERE DepartureTime > ArrivalTime