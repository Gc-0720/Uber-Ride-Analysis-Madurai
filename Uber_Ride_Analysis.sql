CREATE DATABASE madurai_uber_analysis;
USE madurai_uber_analysis;

SELECT DATABASE();

CREATE TABLE Locations (
    LocationID INT PRIMARY KEY,
    AreaName VARCHAR(80),
    City VARCHAR(40),
    Zone VARCHAR(20)
);

CREATE TABLE Riders (
    RiderID INT PRIMARY KEY,
    RiderName VARCHAR(80),
    SignupDate DATE,
    Age INT,
    Gender VARCHAR(30),
    HomeLocationID INT,
    RiderSegment VARCHAR(20),
    FOREIGN KEY (HomeLocationID) REFERENCES Locations(LocationID)
);

CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    DriverName VARCHAR(80),
    JoinDate DATE,
    VehicleType VARCHAR(20),
    DriverRating DECIMAL(2,1),
    HomeLocationID INT,
    DriverStatus VARCHAR(20),
    FOREIGN KEY (HomeLocationID) REFERENCES Locations(LocationID)
);

CREATE TABLE Rides (
    RideID INT PRIMARY KEY,
    BookingDateTime DATETIME,
    PickupDateTime DATETIME,
    DropDateTime DATETIME,
    RiderID INT,
    DriverID INT,
    PickupLocationID INT,
    DropLocationID INT,
    VehicleType VARCHAR(20),
    RideStatus VARCHAR(30),
    DistanceKM DECIMAL(7,2),
    FareAmount DECIMAL(10,2),
    SurgeMultiplier DECIMAL(3,2),
    PaymentMethod VARCHAR(30),
    Rating VARCHAR(10) NULL,
    CancelledBy VARCHAR(20) NULL,
    CancellationReason VARCHAR(80) NULL,

    FOREIGN KEY (RiderID) REFERENCES Riders(RiderID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID),
    FOREIGN KEY (PickupLocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (DropLocationID) REFERENCES Locations(LocationID)
);

CREATE TABLE Vehicle_Summary (
    VehicleType VARCHAR(20),
    Total_Rides INT,
    Completed_Rides INT,
    Cancelled_Rides INT,
    Total_Revenue DECIMAL(12,2),
    Average_Distance DECIMAL(7,2),
    Average_Rating DECIMAL(3,2)
);

INSERT INTO Vehicle_Summary (
    VehicleType,
    Total_Rides,
    Completed_Rides,
    Cancelled_Rides,
    Total_Revenue,
    Average_Distance,
    Average_Rating
)
SELECT
    VehicleType,
    COUNT(*),
    SUM(RideStatus = 'Completed'),
    SUM(RideStatus LIKE 'Cancelled%'),
    SUM(CASE
        WHEN RideStatus = 'Completed'
        THEN FareAmount ELSE 0
    END),
    ROUND(AVG(DistanceKM), 2),
    ROUND(AVG(Rating), 2)
FROM Rides
GROUP BY VehicleType;

/* VERIFY ROW COUNTS */

SELECT COUNT(*) AS total_locations FROM Locations;
SELECT COUNT(*) AS total_riders FROM Riders;
SELECT COUNT(*) AS total_drivers FROM Drivers;
SELECT COUNT(*) AS total_rides FROM Rides;

/* TABLE STRUCTURE AND SAMPLE */

SHOW TABLES;

DESCRIBE Rides;
DESCRIBE Riders;
DESCRIBE Locations;
DESCRIBE Drivers;

SELECT * FROM Rides LIMIT 10;
SELECT * FROM Riders LIMIT 10;
SELECT * FROM Drivers LIMIT 10;
SELECT * FROM Locations LIMIT 10;

/* " SHOW TABLES Lists tables. DESCRIBE shows column names and data types. SELECT * Display rows.Limit 10 restricts the outputto ten rows." */

/* DISTINCT, ORDER BY AND LIMIT */

SELECT DISTINCT RideStatus FROM Rides;
SELECT DISTINCT VehicleType FROM Rides;
SELECT DISTINCT PaymentMethod FROM Rides;

SELECT RideID, FareAmount
FROM Rides
ORDER BY FareAmount DESC LIMIT 10;

/* ("DISTINCT removes repeated values in the result.ORDER BY sorts rows; DESC mean descending and ASC means ascending.LIMIT returns only the requested number of rows.") */

/* ALIASES */

SELECT 
COUNT(*) AS TotalBookings,
SUM(CASE WHEN RideStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedRides 
FROM Rides;

/* ("AS gives a readable temporary name to a result column. It does not rename the stored table column.") */

/* FILTER ROWS WITH WHERE AND OPERATORS */
/* COMPARISION AND LOGICAL OPERATORS */

SELECT * FROM RIDES
WHERE RideStatus = 'Completed';

SELECT * FROM RIDES
WHERE FareAmount >= 200;

SELECT * FROM RIDES
WHERE VehicleType = 'Mini' and RideStatus = 'Completed';

SELECT * FROM RIDES
WHERE PaymentMethod = 'UPI' OR PaymentMethod = 'Card';

SELECT * FROM RIDES
WHERE NOT RideStatus = 'Completed';

/* ("OPERATORS: =,<>,!=,>,<,>=,<=. AND means both the conditions must be true; OR means either can be true;NOT reverses a condition.") */

/* IN,BETWEEN,LIKE, and NULL */

SELECT * FROM Rides
WHERE VehicleType IN ('Mini','Sedan');

SELECT * FROM Rides
WHERE FareAmount BETWEEN 100 AND 300;

SELECT * FROM Riders
WHERE RiderName LIKE 'Rider_00%';

SELECT * FROM Rides
WHERE Rating IS NULL;

SELECT * FROM Rides
WHERE Rating IS NOT NULL;

/* ("IN checks a list of values. BETWEEN includes both endpoints. LIKE uses % for any-length text and _ for one character.
NULL means missing/unknown, so use IS NULL or IS NOT NULL, not = NULL.") */

/* MORE USEFUL FILTERING */

SELECT * FROM RIDES
WHERE DATE(BookingDateTime) = '2024-06-15';

SELECT * FROM RIDES
WHERE HOUR(BookingDateTime) BETWEEN 7 AND 10;

/* ("DATE() extracts the date part from a DATETIME. HOUR() extracts the hour from a time/datetime.") */

/* AGGREGATE FUNCTIONS,GROUP BY and HAVING */

/* CORE AGGREGATE FUNCTIONS */

SELECT 
COUNT(*) AS TotalBookings,
SUM(FareAmount) as SumOfAllFareValues,
AVG(FareAmount) as AverageFareValue,
MIN(FareAmount) as MinimumFare,
MAX(FareAmount) as MaxmumFare
FROM Rides;

SELECT 
COUNT(*) AS CompletedRides,
SUM(FareAmount) AS CompletedRideRevenue,
ROUND(AVG(FareAmount),2) AS AverageCompletedFare
FROM Rides WHERE RideStatus = 'Completed';

/* ("COUNT counts rows/values. SUM adds numbers. AVG calculates average. MIN and MAX find the smallest and largest
values. Revenue analysis should filter to Completed rides.") */

/* GROUP BY */

SELECT RideStatus, COUNT(*) AS RideCount
FROM RIDES 
GROUP BY RideStatus;

SELECT VehicleType,
COUNT(*) AS CompletedRides,
ROUND(SUM(FareAmount),2) as Revenue
FROM Rides
WHERE RideStatus = 'Completed'
GROUP BY VehicleType
ORDER BY Revenue DESC;

/* ("GROUP BY creates one group for each category and calculates aggregates per group.") */

/* HAVING */

SELECT PaymentMethod, COUNT(*) AS CompletedRideCount
FROM Rides
WHERE RideStatus = 'Completed'
GROUP BY PaymentMethod
HAVING COUNT(*) >= 100
ORDER BY CompletedRideCount DESC;

/* ("WHERE filters individual rows before grouping. HAVING filters groups after GROUP BY. Use HAVING for conditions
involving aggregate results.") */

/* STRING FUNCTIONS */

/* CASE,JOINING and LENGTH */

SELECT UPPER(RiderName) as UpperName,
       LOWER(RiderName) as LowerName
FROM Riders
LIMIT 5;

/* ("UPPER converts to uppercase; LOWER converts to lowercase; CONCAT joins strings. LENGTH returns bytes;
CHAR_LENGTH returns characters.") */

/* EXTRACT,TRIM and REPLACE */

SELECT SUBSTRING(RiderName, 1, 5) as FirstFive
FROM Riders
LIMIT 5;

SELECT LEFT(RiderName,5), RIGHT(RiderName,4)
FROM Riders
LIMIT 5;

SELECT TRIM(' Madurai ') AS CleanText;

SELECT REPLACE('Madurai Uber Ride', 'Uber', 'Ride')
as UpdatedText;

/* ("SUBSTRING(text,start,length) extracts part of text. LEFT and RIGHT extract from either end. TRIM removes
leading/trailing spaces. REPLACE swaps matching text.") *?

/* SEARCH and POSITION FUNCTIONS */

SELECT RiderName
FROM Riders
WHERE INSTR(RiderName, '001') > 0;

SELECT LOCATE('Rider', Ridername) as TextPosition
FROM Riders 
LIMIT 5;

SELECT REVERSE('Madurai') as ReversedText;

/* ("INSTR and LOCATE return the position of a substring (0 if not found). REVERSE reverses text. These are useful for text
checks, though generated names are already standardised.") */

/* NUMERIC FUNCTIONS */

/* ROUNDING and ABSOLUTE VALUES */

SELECT FareAmount,
ROUND(FareAmount, 0) AS RoundFare,
CEIL(FareAmount) AS RoundedUp,
FLOOR(FareAmount) AS RoundedDwon,
ABS(FareAmount) AS AbsoluteFare
FROM RIDES
LIMIT 10;

/* ("ROUND rounds to decimal places. CEIL rounds upward to the next integer. FLOOR rounds downward. ABS returns a
non-negative magnitude.") */

/* MOD, POWER, SQRT, SIGN */

SELECT MOD(17,5) AS Remainder;
SELECT POWER(3,2) AS ThreeSquared;
SELECT SQRT(144) AS SquareRoot;
SELECT SIGN(-25) AS NumberSign;

/* ("MOD returns a remainder. POWER raises a number to a power. SQRT returns square root. SIGN returns -1, 0 or 1.") */

/* FARE PER KILOMETRE */

SELECT RideID, DistanceKM, FareAmount,
ROUND(FareAmount / NULLIF(DistanceKM, 0), 2) AS FarePerKM
FROM Rides 
WHERE RideStatus = 'Completed'
LIMIT 20;

/* ("NULLIF(DistanceKM,0) returns NULL if distance is zero, preventing division-by-zero errors. FarePerKM is a derived
metric, not a new stored column.") */

/* DATE TIME FUNCTIONS */

/* EXTRACT DATE/TIME PARTS */

SELECT BookingDateTime,
DATE(BookingDateTime) AS BookingDate,
TIME(BookingDateTime) AS BookingTime,
YEAR(BookingDateTime) AS BookingYear,
MONTH(BookingDateTime) AS MonthName,
DAY(BookingDateTime) AS DayNumber,
DAYNAME(BookingDateTime) AS WeekdayName,
HOUR(BookingDateTime) AS BookingHour
FROM Rides
LIMIT 10;

/* FORMAT and WEEKDAY NUMBER */

SELECT DATE_FORMAT(BookingDateTime, '%d-%b-%Y %h:%i %p') AS FormattedBooking
FROM Rides
LIMIT 10; 

SELECT DAYOFWEEK(BookingDateTime) AS WeekdayNumber,
WEEKDAY(BookingDateTime) AS MondayZeroWeekday
FROM Rides
LIMIT 10;

/* ("DATE_FORMAT changes display format. DAYOFWEEK returns 1=Sunday through 7=Saturday. WEEKDAY returns
0=Monday through 6=Sunday.") */

/* DURATION and DATE ARITHMETIC */

SELECT RideID,
TIMESTAMPDIFF(MINUTE, PickupDateTime, DropDateTime) AS TripMinutes
FROM Rides
WHERE RideStatus = 'Completed'
LIMIT 20;

SELECT DATE_ADD(BookingDateTime, INTERVAL 7 DAY) AS OneWeekLater,
DATE_SUB(BookingDateTime, INTERVAL 1 MONTH) AS OneMonthEarlier
FROM Rides
LIMIT 5;

/* ("TIMESTAMPDIFF(unit,start,end) calculates the difference. DATE_ADD and DATE_SUB add/subtract an interval.") */

/* MONTHLY TREND */

SELECT DATE_FORMAT(BookingDateTime, '%Y-%m') AS RideMonth,
COUNT(*) AS TotalBookings,
SUM(CASE WHEN RideStatus = 'Completed' THEN FareAmount ELSE 0 END) AS Revenue
FROM Rides
GROUP BY DATE_FORMAT(BookingDateTime, '%Y-%m')
ORDER BY RideMonth;

/* NULL HANDLING and CONDITIONAL FUNCTIONS */

/* IFNULL and COALESCE */

SELECT RideID,
IFNULL(Rating, 0) AS RatingZero,
COALESCE(CancellationReason, CancelledBy, 'Not Applicable') AS Reasonable1
FROM Rides
LIMIT 20;

/* ("IFNULL(value,replacement) replaces NULL with one alternative. COALESCE returns the first non-NULL value from a
list.") */

/* IF and CASE */

SELECT RideID,
IF(RideStatus = 'Completed', ' Successful', 'Not Completed') AS RideCategory
FROM Rides
LIMIT 20;

SELECT RideID, FareAmount,
CASE
WHEN FareAmount >= 500 THEN 'High Fare'
WHEN FareAmount >= 200 THEN 'Medium Fare'
ELSE 'Low Fare'
END AS FareBand
FROM Rides
WHERE RideStatus = 'Completed'
LIMIT 20;

/* ("IF checks one condition. CASE supports multiple conditions and is usually clearer for business classifications.") */

/* CONDITIONAL AGGREGATE */

SELECT
COUNT(*) AS AllBookings,
SUM(CASE WHEN RideStatus = 'Completed' THEN 1 ELSE 0 END) AS COMPLETED,
SUM(CASE WHEN RideStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS Cancelled,
ROUND(100 * SUM(CASE WHEN RideStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END)
/ COUNT(*) , 2) AS Cnacellationprevent
FROM Rides;

/* ("This is a common analytics pattern: conditional counts are created with SUM(CASE WHEN ... THEN 1 ELSE 0 END).") */

/* JOINS */

/* INNER JOIN - MATCHING ROWS ONLY */

SELECT r.RideID, ri.RiderName, d.Drivername,
r.VehicleType, r.RideStatus, r.FareAmount
FROM Rides r 
INNER JOIN Riders ri ON r.RiderID = ri.RiderID
INNER JOIN Drivers d ON r.DriverID = d.DriverID
LIMIT 20;

/* LEFT JOIN - KEEP EVERY RIDE ROW */

SELECT r.RideID, ri.RiderName
FROM Rides r 
LEFT JOIN Riders ri ON R.RiderID = ri.RiderID
LIMIT 20;

/* ("INNER JOIN returns matching records. LEFT JOIN keeps all rows from the left table and adds NULL when no match
exists.") */

/* JOIN LOCATIONS TWICE */

SELECT R.RideID,
pickup.AreaName AS PickupArea,
dropoff.AreaName AS DropArea,
r.DistanceKM, r.Fareamount
FROM Rides r
JOIN Locations pickup
ON r.PickupLocationsID = pickup.LocationID
JOIN Locations dropoff
ON r.DropLocationID = dropoff.LocationID
LIMIT 20;

/* ("The Locations table is joined twice because each ride has two location roles. Aliases pickup and dropoff distinguish
those roles.") */

/* RIGHT JOIN and CROSS JOIN */

SELECT l.AreaName, r.RideID
FROM Rides r
RIGHT JOIN Locations l
  ON r.PickupLocationID = l.LocationID;
  
SELECT v.VehicleType, p.PaymentMethod
FROM (SELECT DISTINCT VehicleType FROM Rides) v 
CROSS JOIN (SELECT DISTINCT PaymentMethod FROM Rides) p;

/* ("RIGHT JOIN keeps every row from the right table. CROSS JOIN produces every possible pair; use it only when that is
intended. MySQL does not support FULL OUTER JOIN directly; combine LEFT and RIGHT joins with UNION if
required.") */

/* SUBQUERIES, EXISTS AND SET OPERATORS */

/* SCALAR SUBQUERY */

SELECT RideID, FareAmount
FROM Rides
WHERE RideStatus = 'Completed'
AND FareAmount > (
SELECT AVG(FareAmount)
FROM Rides
WHERE RideStatus = 'Completed'
);

/* ("The inner query calculates average completed fare. The outer query finds completed rides above that average.") */

/* IN AND CORRELATED SUBQUERY */

SELECT RiderID, RiderName
FROM Riders
WHERE RiderID IN(
SELECT RiderID
FROM Rides 
WHERE RideStatus = 'Completed'
);

SELECT ri.RiderID, ri.RiderName
FROM Riders ri
WHERE (
SELECT COUNT(*) 
FROM Rides r
WHERE r.RideID = ri.RiderID
AND r.RideStatus = 'Completed'
) > 1;

/* ("IN checks membership in a returned list. A correlated subquery refers to the current row of the outer query; here it
counts each rider's completed rides.') */

/* EXISTS and NOT EXISTS */

SELECT ri.RiderID, ri.RiderName
FROM Rides ri
WHERE EXISTS (
SELECT 1 FROM Rides r
WHERE r.RideID = ri.RiderID
);

SELECT ri.RiderID, ri.RiderName
FROM Riders ri
WHERE NOT EXISTS (
    SELECT 1 FROM Rides r
    WHERE r.RiderID = ri.RiderID
);

/* ("EXISTS is true if the subquery returns at least one row. NOT EXISTS finds riders with no ride records. SELECT 1 is
conventional; the value itself is not important.") */

/* UNION and UNION ALL */

SELECT RiderID as PersonID FROM Riders WHERE Gender = 'Female'
UNION
SELECT DriverID as PersonID FROM Drivers WHERE DriverStatus = 'Active';

SELECT RiderID AS PersonID FROM Riders WHERE Gender = 'Female'
UNION ALL 
SELECT DriverID AS PersonID FROM Drivers WHERE DriverStatus = 'Active';

/* ("UNION combines compatible result sets and removes duplicates. UNION ALL keeps duplicates and is usually faster.
The selected columns must have compatible types and counts.") */

/* CTE and RECURSIVE CTE */

/* BASIC CTE */

WITH MonthlyRides AS (
SELECT DATE_FORMAT(BookingDateTime, '%Y-%m') AS RideMonth,
COUNT(*) AS RideCount
FROM Rides
GROUP BY DATE_FORMAT(BookingDateTime,'%Y-%m')
)
SELECT * 
FROM MonthlyRides
ORDER BY RideMonth;

/* MULTIPLE CTE'S */

WITH Completed AS (
    SELECT * FROM Rides WHERE RideStatus='Completed'
),
VehicleSummary AS (
    SELECT VehicleType, COUNT(*) AS RideCount,
           ROUND(SUM(FareAmount),2) AS Revenue
    FROM Completed
    GROUP BY VehicleType
)
SELECT *
FROM VehicleSummary
ORDER BY Revenue DESC;

/* RECURSIVE CTE - GENERATE NUMBERS 1 TO 12 */

WITH RECURSIVE MonthNumbers AS (
SELECT 1 AS MonthNo 
UNION ALL 
SELECT MonthNo + 1
FROM MonthNumbers 
WHERE MonthNo < 12
)
SELECT MonthNo FROM MonthNumbers;

/* ("The anchor query starts with 1. The recursive part adds 1 repeatedly until MonthNo reaches 12. This example teaches
recursion; it does not modify project data.") */

/* WINDOW FUNCTION */

/* ROW_NUMBER, RANK and DENSE_RANK */

SELECT DriverID, DriverName, DriverRating,
ROW_NUMBER() OVER (ORDER BY DriverRating DESC) AS RowNum,
RANK() OVER (ORDER BY DriverRating DESC) AS RatingRank,
DENSE_RANK() OVER(ORDER BY DriverRating DESC) AS DenseRatingRank
FROM Drivers;

/* ("ROW_NUMBER assigns a unique sequence. RANK gives tied rows the same rank and leaves gaps. DENSE_RANK
gives tied rows the same rank without gaps.") */

/* PARTITION BY */

SELECT VehicleType, RideID, FareAmount,
RANK() OVER (
PARTITION BY VehicleType
ORDER BY FareAmount DESC
) AS FareRankWithinVehicle
FROM Rides
WHERE RideStatus = 'Completed';

/* ("PARTITION BY restarts the ranking for each vehicle type.") */

/* RUNNING TOTAL and LAG/LEAD */

WITH DailyRevenue AS (
SELECT DATE(BookingDateTime) AS RideDate,
SUM(FareAmount) AS Revenue
FROM Rides 
WHERE RideStatus = 'Completed'
GROUP BY DATE(BookingDateTime)
)
SELECT RideDate, Revenue, 
SUM(REVENUE) OVER (ORDER BY RideDate) AS RunningRevenue,
LAG(Revenue) OVER (ORDER BY RideDate) AS PreviousDayRevenue,
LEAD(Revenue) OVER (ORDER BY RideDate) AS NextDayRevenue
FROM DailyRevenue
ORDER BY RideDate;

/* ("SUM() OVER creates a running total. LAG reads a previous row and LEAD reads a next row in the defined order.") */

/* VIEWS */

/* COMPLETED-RIDES VIEW */

CREATE OR REPLACE VIEW vw_completed_rides AS 
SELECT RideID, BookingDateTime, RiderID, DriverID,
VehicleType, DistanceKM, PaymentMethod, Rating
FROM Rides
WHERE RideStatus = 'Completed';

SELECT * FROM vw_completed_rides LIMIT 20;

/* VIEW WITH JOINED NAMES */

CREATE OR REPLACE VIEW vw_ride_details AS 
SELECT r.RideID, r.BookingDateTime,
ri.Ridername, d.DriverName,
p.AreaName AS PickupArea,
q.AreaName AS DropArea,
r.VehicleType, r.RideStatus, r.DistanceKM, r.FareAmount
FROM Rides r 
JOIN Riders ri ON r.RiderID = ri.RiderID
JOIN Drivers d ON r.DriverID = d.DriverID
JOIN Locations p ON r.PickupLocationID = p.LocationID
JOIN Locations q ON r.DropLocationID = q.LocationId;

SELECT * FROM vw_ride_details LIMIT 20;

/* ("A view normally stores the query, not a separate copy of its result. The underlying tables remain the source of the data.") */

/* MANAGE A VIEW */

SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
SHOW CREATE VIEW vw_completed_rides;
SHOW CREATE VIEW vw_ride_details;

/* STORED PROCEDURES */

/* PROCEDURE WITH INPUT PARAMETER */

DELIMITER //

CREATE PROCEDURE GetRiderRides(IN p_RiderID INT)
BEGIN 
SELECT RideID, BookingDateTime, RideStatus, FareAmount
FROM Rides
WHERE RiderID = p_RiderID
ORDER BY BookingDateTime;
END //

DELIMITER ;

CALL GetRiderRides(1);

/* ("IN means the caller supplies a value. DELIMITER temporarily changes the statement terminator so the semicolons
inside BEGIN...END do not end the CREATE PROCEDURE early.") */

/* PROCEDURE WITH AGGREGATE RESULT */

DELIMITER //
CREATE PROCEDURE GetMonthlyRevenue(IN p_Month INT)
BEGIN
SELECT MONTHNAME(BookingDateTime) AS MonthName,
COUNT(*) AS CompletedRides,
ROUND(SUM(FareAmount), 2) AS Revenue 
FROM Rides 
WHERE RideStatus = 'Completed'
AND MONTH(BookingDateTime) = p_Month
GROUP BY MONTHNAME(BookingDateTime);
END //

DELIMITER ; 

CALL GetMonthlyRevenue(6) ;

/* INSPECT and REMOVE PROCEDURES */

SHOW PROCEDURE STATUS
WHERE Db = 'madurai_uber_analysis';

DROP PROCEDURE IF EXISTS GetRiderRides;

/* STORED FUNCTIONS */

/* FARE CATEGORY FUNCTION */

DELIMITER //

CREATE FUNCTION FareCategory(p_Fare DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
RETURN CASE
WHEN p_Fare >= 500 THEN 'HIGH'
WHEN p_Fare >=200 THEN 'MEDIUM'
ELSE 'LOW'
END;
END // 

DELIMITER ;

SELECT RideID, FareAmount, FareCategory(FareAmount) AS FareBand
FROM Rides
WHERE RideStatus = 'Completed'
LIMIT 20;

/* ("RETURNS defines the output data type. DETERMINISTIC says the same input gives the same output. The function
returns one category for each fare.") */

/* FUNCTIONS TO CALCULATE TRIP MINUTES */

DELIMITER //

CREATE FUNCTION TripMinutes(p_Pickup DATETIME, p_Drop DATETIME)
RETURNS INT 
DETERMINISTIC 
BEGIN
RETURN TIMESTAMPDIFF(MINUTE, p_Pickup, p_Drop);
END //

DELIMITER ;

SELECT RideID,
TripMinutes(PickupDateTime, DropDateTime) AS TripDurationMinutes 
FROM Rides
WHERE RideStatus = 'Completed'
LIMIT 20;

/*  INSPECT and REMOVE */

SHOW FUNCTION STATUS
WHERE Db = 'madurai_uber_analysis';

DROP FUNCTION IF EXISTS FareCategory;

/* TRIGGERS AND AUDIT TABLE */

/* CREATE AN AUDIT TABLE */

CREATE TABLE RideAudit (
AuditID INT AUTO_INCREMENT PRIMARY KEY,
RideID INT,
ActionName VARCHAR(20),
ActionTime DATETIME
);

/* CREATE AN AFTER UPDATE TRIGGER */

DELIMITER //

CREATE TRIGGER trg_ride_after_update 
AFTER UPDATE ON Rides 
FOR EACH ROW
BEGIN 
INSERT INTO RideAudit (RideID, ActionName, ActionTime)
VALUES (NEW.RideID, 'UPDATED', NOW());
END//

DELIMITER ;

/* ("AFTER UPDATE runs after an existing Rides row is updated. OLD refers to the previous values and NEW refers to the
new values. This trigger records the ride ID and time.") */

/* TEST SAFELY */

UPDATE Rides 
SET FareAmount = FareAmount
WHERE RideID = 1;

SELECT * FROM RideAudit
ORDER BY AuditID DESC
LIMIT 10;

/* ("The test update should create an audit row even though the fare value is unchanged. In a production system, audit
exactly which fields changed and control who can update records.") */

/* INSPECT and REMOVE TRIGGER */

SHOW TRIGGERS;
DROP TRIGGER IF EXISTS trg_ride_after_update;

/* INDEXES and EXPLAIN */

/* CREATE USEFUL INDEXES */

CREATE INDEX idx_rides_booking_datetime
ON Rides(BookingDateTime);

CREATE INDEX idx_rides_status
ON Rides(RideStatus);

CREATE INDEX idx_rides_rider
ON Rides(RiderID);

CREATE INDEX idx_rides_driver
ON Rides(DriverID);

/* COMPOSITE INDEX EXAMPLE */

CREATE INDEX idx_rides_rider_status
ON Rides(RiderID, RideStatus);

SHOW INDEX FROM Rides;

/* ("A composite index is built from more than one column. Column order matters: an index on (RiderID, RideStatus) is most
useful when a query filters by RiderID, or by RiderID and RideStatus together.") */

/* TRANSACTIONS and DATA SAFETY */

/* COMMIT */

START TRANSACTION;

UPDATE Drivers
SET DriverStatus = 'Inactive'
WHERE DriverID = 1;

SELECT DriverID, DriverStatus
FROM Drivers 
WHERE DriverID = 1;

COMMIT;

/* ROLLBACK TEST */

START TRANSACTION;

UPDATE Drivers
SET DriverStatus = 'Inactive'
WHERE DriverID = 2;

SELECT DriverID, DriverStatus
FROM Drivers
WHERE DriverID = 2;

ROLLBACK;

SELECT DriverID, DriverStatus
FROM Drivers 
WHERE DriverID = 2;

/* ("ROLLBACK cancels uncommitted changes. Run the SELECT after ROLLBACK to confirm the original value is restored.
Avoid testing updates on important real data.") */

/* SAVEPOINT */

START TRANSACTION;

UPDATE Drivers
SET DriverStatus = 'Inactive'
WHERE DriverID = 3;

SAVEPOINT after_first_change;

UPDATE Drivers
SET DriverStatus = 'Inactive'
WHERE DriverID = 4;

ROLLBACK TO SAVEPOINT after_first_change;
ROLLBACK;

/* ("SAVEPOINT marks a point inside a transaction. ROLLBACK TO SAVEPOINT undoes changes made after that point
while keeping earlier uncommitted changes.") */

/* DATA QUALITY CHECKS */

/* DUPLCATE PRIMARY ID'S */

SELECT RideID, COUNT(*) AS DuplicateCount
FROM Rides
GROUP BY RideID
HAVING COUNT(*) > 1;

SELECT RiderID, COUNT(*) AS DuplicateCount
FROM Riders
GROUP BY RiderID 
HAVING COUNT(*) > 1;

/* ("Primary keys should prevent duplicates. These checks are still useful when validating raw files before import.") */

/* MISSING VALUES */

SELECT 
SUM(BookingDateTime IS NULL) AS MissingBookingTime,
SUM(RiderID IS NULL) AS MissingRideID,
SUM(DriverID IS NULL) AS MissingDriverID,
SUM(Rating IS NULL) AS MissingRating
FROM Rides;	

/* ("In MySQL, TRUE is treated as 1 and FALSE as 0 in numeric expressions, so SUM(condition) counts rows where the
condition is true.") */

/* INVALID RANGES AND DURATION */

SELECT * 
FROM Rides
WHERE DistanceKM < 0
OR FareAmount < 0
OR SurgeMultiplier <= 0;

SELECT * 
FROM Rides
WHERE DropDateTime < PickupDateTime;

SELECT *
FROM Rides
WHERE RideStatus = 'Completed'
AND (DistanceKM IS NULL OR FareAmount IS NULL);

/* FOREIGN KEY INTEGRITY CHECK */

SELECT r.RideID
FROM Rides r 
LEFT JOIN Riders ri ON r.RiderID = ri.RiderID
WHERE ri.RiderID IS NULL;

SELECT r.RideID
FROM Rides r
LEFT JOIN Drivers d ON r.DriverID=d.DriverID
WHERE d.DriverID IS NULL;

/* ("These queries search for ride rows whose rider or driver ID does not match a parent record. With correctly enforced
foreign keys, these should return no rows.") */

/* FINAL BUSINESS ANALYSIS QUERIES */

/* OVERALL KPI SUMMARY */

SELECT 
COUNT(*) AS TotalBookings,
SUM(RideStatus = 'Completed') AS CompletedRides,
SUM(RideStatus LIKE 'Cancelled%') AS CancelledRides,
ROUND(100 * SUM(RideStatus LIKE 'Cancelled%') / COUNT(*), 2)
AS CancellationPercent,
ROUND(SUM(CASE WHEN RideStatus = 'Completed' THEN FareAmount ELSE 0 END), 2)
AS CompletedRevenue,
ROUND(AVG(CASE WHEN RideStatus = 'Completed' THEN FareAmount END),2)
AS AverageCompletedFare
FROM Rides;

/* PEAK HOUR */

SELECT HOUR(BookingDateTime) AS BookingHour,
COUNT(*) AS TotalBookings
FROM Rides
GROUP BY HOUR(BookingDateTime)
ORDER BY TotalBookings DESC;

/* POPULAR PICKUP AREAS */

SELECT l.AreaName AS PickupArea,
COUNT(*) AS PickupCount
FROM Rides r 
JOIN Locations l ON r.PickupLocationID = l.LocationID
GROUP BY l.AreaName
ORDER BY PickupCount DESC
LIMIT 10;

/* POPULAR DROP AREAS */

SELECT l.AreaName AS DropArea,
COUNT(*) AS DropCount
FROM Rides r 
JOIN Locations l ON r.DropLocationID = l.LocationID
GROUP BY l.AreaName
ORDER BY DropCount DESC
LIMIT 10;

/* VEHICLE PERFORMANCE */

SELECT VehicleType,
COUNT(*) AS CompletedRides,
ROUND(SUM(FareAmount),2) AS Revenue,
ROUND(AVG(DistanceKM),2) AS AverageDistanceKM,
ROUND(AVG(FareAmount),2) AS AverageFare
FROM Rides
WHERE RideStatus = 'Completed'
GROUP BY VehicleType
ORDER BY Revenue DESC;

/* PAYMENT METHOD ANALYSIS */

SELECT PaymentMethod,
COUNT(*) AS CompletedRides,
ROUND(SUM(FareAmount),2) AS Revenue
FROM Rides 
WHERE RideStatus = 'Completed'
GROUP BY PaymentMethod
ORDER BY CompletedRides DESC;

/* CANCELLATION REASONS */

SELECT CancellationReason,
COUNT(*) AS CancellationCount
FROM Rides
WHERE RideStatus LIKE 'Cancelled%'
GROUP BY CancellationReason
ORDER BY CancellationCount DESC;

/* TOP DRIVERS BY COMPLETED RIDES */

SELECT d.DriverID, d.DriverName,
COUNT(*) AS CompletedRides,
ROUND(AVG(r.Rating),2) AS AverageRideRating,
ROUND(SUM(r.FareAmount),2) AS Revenue
FROM Rides r 
JOIN Drivers d ON r.DriverID = d.DriverID
WHERE r.RideStatus = 'Completed'
GROUP BY d.DriverID, d.DriverName
ORDER BY CompletedRides DESC
LIMIT 10;

/* REPEAT RIDERS */

SELECT ri.RiderID, ri.RiderName,
COUNT(*) AS CompletedRideCount,
ROUND(SUM(r.FareAmount),2) AS TotalSpend
FROM Rides r 
JOIN Riders ri ON r.RiderID = ri.RiderID
WHERE r.RideStatus = 'Completed'
GROUP BY ri.RiderID, ri.Ridername
HAVING COUNT(*) > 1
ORDER BY CompletedRideCount DESC
LIMIT 20;

/* WEEKDAY DEMAND */

SELECT DAYNAME(BookingDateTime)  AS WeekdayName,
COUNT(*) AS TotalBookings
FROM Rides 
GROUP BY DAYOFWEEK(BookingDateTime), DAYNAME(BookingDateTime)
ORDER BY DAYOFWEEK(BookingDateTime);

