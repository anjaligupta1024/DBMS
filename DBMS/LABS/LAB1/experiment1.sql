-- EXPERIMENT 1: E-commerce ER model specification
-- This script creates a relational prototype for the ER model.
-- ER design notes (also documented in README.md):
-- Customer 1:M Order; Order 1:M OrderItem; Product 1:M OrderItem;
-- Seller 1:M Product; Category 1:M Product; Order 1:M Payment (model choice);
-- Order 1:0..1 Delivery; Customer 1:M Address.
-- OrderItem is a weak/dependent entity identified by (OrderID, ProductID).
-- Product specialization example: PhysicalProduct and DigitalProduct are subtypes.
-- Multi-valued Customer phone numbers are normalized into CustomerPhone.

CREATE DATABASE IF NOT EXISTS ECommerceLab;
USE ECommerceLab;

CREATE TABLE IF NOT EXISTS Customer (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS CustomerPhone (
    CustomerID INT NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (CustomerID, PhoneNumber),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Address (
    AddressID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AddressLine VARCHAR(200) NOT NULL,
    City VARCHAR(80) NOT NULL,
    StateName VARCHAR(80) NOT NULL,
    PostalCode VARCHAR(12) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Seller (
    SellerID INT PRIMARY KEY,
    SellerName VARCHAR(120) NOT NULL,
    Email VARCHAR(150) UNIQUE
);

CREATE TABLE IF NOT EXISTS Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Product (
    ProductID INT PRIMARY KEY,
    SellerID INT NOT NULL,
    CategoryID INT NOT NULL,
    ProductName VARCHAR(150) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    ProductType ENUM('PHYSICAL','DIGITAL') NOT NULL,
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE IF NOT EXISTS PhysicalProduct (
    ProductID INT PRIMARY KEY,
    WeightKg DECIMAL(8,3) NOT NULL CHECK (WeightKg >= 0),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DigitalProduct (
    ProductID INT PRIMARY KEY,
    DownloadURL VARCHAR(500) NOT NULL,
    LicenseKeyRequired BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    OrderStatus ENUM('PLACED','PAID','SHIPPED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'PLACED',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE IF NOT EXISTS OrderItem (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE IF NOT EXISTS Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    PaymentMethod ENUM('UPI','CARD','NETBANKING','COD') NOT NULL,
    PaymentStatus ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    AddressID INT NOT NULL,
    TrackingNumber VARCHAR(80) UNIQUE,
    DeliveryStatus ENUM('PENDING','IN_TRANSIT','DELIVERED','RETURNED') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

SHOW TABLES;
