-- EXPERIMENT 2: Relational schema and integrity constraints
CREATE DATABASE IF NOT EXISTS ECommerceSchemaLab;
USE ECommerceSchemaLab;

DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Seller;
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE Seller (
    SellerID INT PRIMARY KEY,
    SellerName VARCHAR(100) NOT NULL
);

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(120) NOT NULL,
    SellerID INT,
    CategoryID INT,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID) ON DELETE SET NULL,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID) ON DELETE SET NULL
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

CREATE TABLE OrderItem (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

INSERT INTO Customer VALUES
(1,'Aarav Sharma','aarav@example.com'),
(2,'Diya Verma','diya@example.com');
INSERT INTO Seller VALUES (1,'Lucknow Tech Store'),(2,'India Books');
INSERT INTO Category VALUES (1,'Electronics'),(2,'Books');
INSERT INTO Product VALUES
(101,'Wireless Mouse',1,1,699.00),
(102,'DBMS Textbook',2,2,599.00),
(103,'USB Keyboard',1,1,999.00);
INSERT INTO Orders VALUES (1001,1,'2026-01-15'),(1002,2,'2026-01-16');
INSERT INTO OrderItem VALUES (1001,101,2),(1001,102,1),(1002,103,1);

SELECT * FROM Customer;
SELECT * FROM Product;
SELECT o.OrderID, c.FullName, p.ProductName, oi.Quantity
FROM Orders o
JOIN Customer c ON c.CustomerID = o.CustomerID
JOIN OrderItem oi ON oi.OrderID = o.OrderID
JOIN Product p ON p.ProductID = oi.ProductID;

-- Integrity test (run separately): this should fail because CustomerID 999 does not exist.
-- INSERT INTO Orders VALUES (1003,999,'2026-01-17');

-- Demonstrate ON DELETE SET NULL: Product seller references become NULL.
-- DELETE FROM Seller WHERE SellerID = 2;
-- SELECT ProductID, ProductName, SellerID FROM Product WHERE ProductID = 102;

-- Demonstrate ON DELETE CASCADE: deleting a customer removes their orders and order items.
-- Run only if you want to observe the cascade:
-- DELETE FROM Customer WHERE CustomerID = 1;
