-- EXPERIMENT 9: Railway booking data and indexes
CREATE DATABASE IF NOT EXISTS RailwayIndexLab;
USE RailwayIndexLab;

DROP TABLE IF EXISTS RailwayBooking;
CREATE TABLE RailwayBooking (
    BookingID INT PRIMARY KEY,
    PassengerName VARCHAR(100) NOT NULL,
    TrainNo INT NOT NULL,
    JourneyDate DATE NOT NULL,
    SourceStation VARCHAR(80) NOT NULL,
    DestinationStation VARCHAR(80) NOT NULL,
    SeatClass ENUM('SL','3A','2A','1A','CC') NOT NULL,
    Fare DECIMAL(10,2) NOT NULL,
    BookingStatus ENUM('CONFIRMED','WAITLIST','CANCELLED') NOT NULL
) ENGINE=InnoDB;

-- Generate 5,000 rows with a recursive CTE (MySQL 8.0+).
SET SESSION cte_max_recursion_depth = 6000;
INSERT INTO RailwayBooking
    (BookingID, PassengerName, TrainNo, JourneyDate, SourceStation,
     DestinationStation, SeatClass, Fare, BookingStatus)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 5000
)
SELECT n,
       CONCAT('Passenger_', n),
       12000 + MOD(n, 50),
       DATE_ADD('2026-01-01', INTERVAL MOD(n, 180) DAY),
       ELT(MOD(n,5)+1,'Lucknow','Delhi','Kanpur','Varanasi','Agra'),
       ELT(MOD(n+2,5)+1,'Delhi','Mumbai','Jaipur','Prayagraj','Bhopal'),
       ELT(MOD(n,5)+1,'SL','3A','2A','1A','CC'),
       250 + MOD(n * 17, 3000),
       ELT(MOD(n,3)+1,'CONFIRMED','WAITLIST','CANCELLED')
FROM seq;

SELECT COUNT(*) AS TotalBookings FROM RailwayBooking;

-- Before indexes: inspect the plan and time this query in your SQL client.
EXPLAIN SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12010 AND JourneyDate = '2026-02-10';

SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12010 AND JourneyDate = '2026-02-10';

CREATE INDEX idx_railway_train ON RailwayBooking(TrainNo);
CREATE INDEX idx_railway_train_date ON RailwayBooking(TrainNo, JourneyDate);

-- After indexes: compare key, rows, and access type in EXPLAIN.
EXPLAIN SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12010 AND JourneyDate = '2026-02-10';

SELECT BookingStatus, COUNT(*) AS Bookings
FROM RailwayBooking
GROUP BY BookingStatus;

-- Compare single-column and composite-index alternatives by dropping/recreating
-- indexes one at a time and running EXPLAIN. Avoid claiming a fixed speedup:
-- the actual plan and elapsed time depend on the MySQL optimizer and environment.
