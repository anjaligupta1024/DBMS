-- EXPERIMENT 10: Query optimization
CREATE DATABASE IF NOT EXISTS QueryOptimizationLab;
USE QueryOptimizationLab;

DROP TABLE IF EXISTS SalesData;
CREATE TABLE SalesData (
    SaleID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Region VARCHAR(30) NOT NULL,
    SaleDate DATE NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StatusName VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- Generate 10,000 rows with MySQL 8.0 recursive CTE.
SET SESSION cte_max_recursion_depth = 11000;
INSERT INTO SalesData
    (SaleID, CustomerID, ProductID, Region, SaleDate, Quantity, UnitPrice, StatusName)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10000
)
SELECT n,
       MOD(n * 37, 1200) + 1,
       MOD(n * 13, 250) + 1,
       ELT(MOD(n,4)+1,'North','South','East','West'),
       DATE_ADD('2024-01-01', INTERVAL MOD(n,730) DAY),
       MOD(n,10)+1,
       100 + MOD(n * 19, 5000) / 10,
       ELT(MOD(n,3)+1,'PAID','PENDING','REFUNDED')
FROM seq;

SELECT COUNT(*) AS TotalRows FROM SalesData;

-- Slow-query pattern 1: function applied to indexed candidate column
EXPLAIN SELECT * FROM SalesData WHERE YEAR(SaleDate) = 2025;
SELECT COUNT(*) FROM SalesData WHERE YEAR(SaleDate) = 2025;

-- Optimized range predicate
EXPLAIN SELECT * FROM SalesData
WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';
SELECT COUNT(*) FROM SalesData
WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';

-- Slow-query pattern 2: broad aggregation without a suitable index
EXPLAIN SELECT Region, SUM(Quantity * UnitPrice) AS Revenue
FROM SalesData GROUP BY Region;
SELECT Region, SUM(Quantity * UnitPrice) AS Revenue
FROM SalesData GROUP BY Region;

-- Slow-query pattern 3: filter by status and date
EXPLAIN SELECT SaleID, SaleDate, Region
FROM SalesData
WHERE StatusName = 'PAID' AND SaleDate >= '2025-01-01';
SELECT SaleID, SaleDate, Region
FROM SalesData
WHERE StatusName = 'PAID' AND SaleDate >= '2025-01-01';

-- Slow-query pattern 4: customer filter
EXPLAIN SELECT * FROM SalesData WHERE CustomerID = 500;
SELECT * FROM SalesData WHERE CustomerID = 500;

-- Slow-query pattern 5: product and region filter
EXPLAIN SELECT ProductID, COUNT(*) AS SaleCount
FROM SalesData
WHERE ProductID BETWEEN 20 AND 40 AND Region = 'West'
GROUP BY ProductID;
SELECT ProductID, COUNT(*) AS SaleCount
FROM SalesData
WHERE ProductID BETWEEN 20 AND 40 AND Region = 'West'
GROUP BY ProductID;

-- Add targeted indexes and re-run the same EXPLAIN/query pairs.
CREATE INDEX idx_sales_date ON SalesData(SaleDate);
CREATE INDEX idx_sales_status_date ON SalesData(StatusName, SaleDate);
CREATE INDEX idx_sales_customer ON SalesData(CustomerID);
CREATE INDEX idx_sales_region_product ON SalesData(Region, ProductID);

ANALYZE TABLE SalesData;

EXPLAIN SELECT * FROM SalesData
WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';

EXPLAIN SELECT SaleID, SaleDate, Region
FROM SalesData
WHERE StatusName = 'PAID' AND SaleDate >= '2025-01-01';

EXPLAIN SELECT * FROM SalesData WHERE CustomerID = 500;

EXPLAIN SELECT ProductID, COUNT(*) AS SaleCount
FROM SalesData
WHERE ProductID BETWEEN 20 AND 40 AND Region = 'West'
GROUP BY ProductID;

-- Record actual elapsed times from your MySQL client before/after indexing.
-- Do not assume a fixed speedup: results depend on hardware, caching, and optimizer choices.
