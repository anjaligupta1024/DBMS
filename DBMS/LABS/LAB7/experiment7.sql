-- EXPERIMENT: NORMALIZATION FROM UNF TO BCNF

-- STEP 1: CREATE DENORMALIZED SALES TABLE

DROP TABLE IF EXISTS Sales_UNF;

CREATE TABLE Sales_UNF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    ProductID INT,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    SalespersonID INT,
    SalespersonName VARCHAR(100),
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_UNF VALUES
(101,'2026-01-10',1,'Aarav Sharma','Lucknow',201,'Laptop',55000,1,501,'Rahul Verma'),
(101,'2026-01-10',1,'Aarav Sharma','Lucknow',202,'Mouse',800,2,501,'Rahul Verma'),
(102,'2026-01-11',2,'Diya Verma','Kanpur',201,'Laptop',55000,1,502,'Priya Singh'),
(102,'2026-01-11',2,'Diya Verma','Kanpur',203,'Keyboard',1500,1,502,'Priya Singh'),
(103,'2026-01-12',3,'Kabir Singh','Delhi',204,'Monitor',12000,2,501,'Rahul Verma'),
(104,'2026-01-13',1,'Aarav Sharma','Lucknow',203,'Keyboard',1500,1,503,'Amit Kumar'),
(105,'2026-01-14',4,'Ananya Gupta','Noida',205,'Printer',9000,1,502,'Priya Singh'),
(105,'2026-01-14',4,'Ananya Gupta','Noida',202,'Mouse',800,3,502,'Priya Singh');

SELECT * FROM Sales_UNF;

-- STEP 2: FUNCTIONAL DEPENDENCIES

-- OrderID determines order-level information:
-- OrderID -> OrderDate, CustomerID, SalespersonID

-- CustomerID determines customer details:
-- CustomerID -> CustomerName, CustomerCity

-- ProductID determines product details:
-- ProductID -> ProductName, UnitPrice

-- SalespersonID determines salesperson details:
-- SalespersonID -> SalespersonName

-- Composite key:
-- (OrderID, ProductID) -> Quantity

-- STEP 3: 1NF
-- All attributes contain atomic values.
-- Each row represents one product in one order.

DROP TABLE IF EXISTS Sales_1NF;

CREATE TABLE Sales_1NF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    ProductID INT,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    SalespersonID INT,
    SalespersonName VARCHAR(100),
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF
SELECT * FROM Sales_UNF;

SELECT * FROM Sales_1NF;

-- STEP 4: 2NF
-- Remove partial dependencies on parts of the composite key.

DROP TABLE IF EXISTS OrderDetails_2NF;
DROP TABLE IF EXISTS OrderItems_2NF;

CREATE TABLE OrderDetails_2NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    SalespersonID INT,
    SalespersonName VARCHAR(100)
);

INSERT INTO OrderDetails_2NF
SELECT DISTINCT
    OrderID, OrderDate, CustomerID,
    CustomerName, CustomerCity,
    SalespersonID, SalespersonName
FROM Sales_1NF;

CREATE TABLE OrderItems_2NF (
    OrderID INT,
    ProductID INT,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO OrderItems_2NF
SELECT OrderID, ProductID, ProductName, UnitPrice, Quantity
FROM Sales_1NF;

SELECT * FROM OrderDetails_2NF;
SELECT * FROM OrderItems_2NF;

-- STEP 5: 3NF
-- Remove transitive dependencies.

DROP TABLE IF EXISTS OrderItems_3NF;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Products_3NF;
DROP TABLE IF EXISTS Customers_3NF;
DROP TABLE IF EXISTS Salespersons_3NF;

CREATE TABLE Customers_3NF (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100)
);

INSERT INTO Customers_3NF
SELECT DISTINCT CustomerID, CustomerName, CustomerCity
FROM Sales_1NF;

CREATE TABLE Salespersons_3NF (
    SalespersonID INT PRIMARY KEY,
    SalespersonName VARCHAR(100)
);

INSERT INTO Salespersons_3NF
SELECT DISTINCT SalespersonID, SalespersonName
FROM Sales_1NF;

CREATE TABLE Orders_3NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    SalespersonID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers_3NF(CustomerID),
    FOREIGN KEY (SalespersonID) REFERENCES Salespersons_3NF(SalespersonID)
);

INSERT INTO Orders_3NF
SELECT DISTINCT OrderID, OrderDate, CustomerID, SalespersonID
FROM Sales_1NF;

CREATE TABLE Products_3NF (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2)
);

INSERT INTO Products_3NF
SELECT DISTINCT ProductID, ProductName, UnitPrice
FROM Sales_1NF;

CREATE TABLE OrderItems_3NF (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders_3NF(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products_3NF(ProductID)
);

INSERT INTO OrderItems_3NF
SELECT OrderID, ProductID, Quantity
FROM Sales_1NF;

SELECT * FROM Customers_3NF;
SELECT * FROM Salespersons_3NF;
SELECT * FROM Orders_3NF;
SELECT * FROM Products_3NF;
SELECT * FROM OrderItems_3NF;

-- STEP 6: RECONSTRUCT SALES USING A LOSSLESS JOIN

SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.CustomerName,
    c.CustomerCity,
    p.ProductID,
    p.ProductName,
    p.UnitPrice,
    oi.Quantity,
    s.SalespersonID,
    s.SalespersonName
FROM Orders_3NF o
JOIN Customers_3NF c
    ON o.CustomerID = c.CustomerID
JOIN Salespersons_3NF s
    ON o.SalespersonID = s.SalespersonID
JOIN OrderItems_3NF oi
    ON o.OrderID = oi.OrderID
JOIN Products_3NF p
    ON oi.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID;

-- STEP 7: VERIFY LOSSLESS JOIN
-- Compare original and reconstructed row counts.

SELECT COUNT(*) AS OriginalRows
FROM Sales_1NF;

SELECT COUNT(*) AS ReconstructedRows
FROM Orders_3NF o
JOIN Customers_3NF c
    ON o.CustomerID = c.CustomerID
JOIN Salespersons_3NF s
    ON o.SalespersonID = s.SalespersonID
JOIN OrderItems_3NF oi
    ON o.OrderID = oi.OrderID
JOIN Products_3NF p
    ON oi.ProductID = p.ProductID;

-- Check for missing rows in reconstructed data.

SELECT
    su.OrderID,
    su.ProductID
FROM Sales_1NF su
LEFT JOIN Orders_3NF o
    ON su.OrderID = o.OrderID
LEFT JOIN OrderItems_3NF oi
    ON su.OrderID = oi.OrderID
   AND su.ProductID = oi.ProductID
LEFT JOIN Customers_3NF c
    ON o.CustomerID = c.CustomerID
LEFT JOIN Salespersons_3NF s
    ON o.SalespersonID = s.SalespersonID
LEFT JOIN Products_3NF p
    ON oi.ProductID = p.ProductID
WHERE o.OrderID IS NULL
   OR oi.OrderID IS NULL
   OR c.CustomerID IS NULL
   OR s.SalespersonID IS NULL
   OR p.ProductID IS NULL;

-- STEP 8: VERIFY DEPENDENCY PRESERVATION
-- Check that each determinant is a primary key
-- or unique key in its corresponding table.

SHOW KEYS FROM Customers_3NF;
SHOW KEYS FROM Salespersons_3NF;
SHOW KEYS FROM Products_3NF;
SHOW KEYS FROM Orders_3NF;
SHOW KEYS FROM OrderItems_3NF;

-- Check for duplicate customer identifiers.

SELECT CustomerID, COUNT(*) AS Occurrences
FROM Customers_3NF
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Check for duplicate product identifiers.

SELECT ProductID, COUNT(*) AS Occurrences
FROM Products_3NF
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Check for duplicate salesperson identifiers.

SELECT SalespersonID, COUNT(*) AS Occurrences
FROM Salespersons_3NF
GROUP BY SalespersonID
HAVING COUNT(*) > 1;

-- STEP 9: BCNF VERIFICATION
-- For the stated functional dependencies, each determinant
-- in the 3NF decomposition is a candidate key of its relation.
-- Therefore, these relations also satisfy BCNF.

SELECT 'Customers_3NF' AS RelationName,
       COUNT(*) AS TotalRows
FROM Customers_3NF
UNION ALL
SELECT 'Salespersons_3NF', COUNT(*)
FROM Salespersons_3NF
UNION ALL
SELECT 'Orders_3NF', COUNT(*)
FROM Orders_3NF
UNION ALL
SELECT 'Products_3NF', COUNT(*)
FROM Products_3NF
UNION ALL
SELECT 'OrderItems_3NF', COUNT(*)
FROM OrderItems_3NF;