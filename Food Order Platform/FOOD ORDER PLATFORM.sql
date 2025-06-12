-- create database

DROP DATABASE IF EXISTS FoodOrderPlatform;
GO

CREATE DATABASE FoodOrderPlatform;
GO

USE FoodOrderPlatform;
GO

-- create table(12)

DROP TABLE IF EXISTS Customer;
GO

CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(15) UNIQUE
);

DROP TABLE IF EXISTS CustomerAddress;
GO

CREATE TABLE CustomerAddress (
    AddressId INT PRIMARY KEY IDENTITY(1,1),
    AddressLine NVARCHAR(255) NOT NULL,
    City NVARCHAR(100),
    State NVARCHAR(100),
    ZipCode NVARCHAR(10)
);

DROP TABLE IF EXISTS CustomerAddressMapping;
GO

CREATE TABLE CustomerAddressMapping (
    CustomerId INT CONSTRAINT FK_CustomerAddressMapping_Customer FOREIGN KEY REFERENCES Customer(CustomerId),
    AddressId INT CONSTRAINT FK_CustomerAddressMapping_CustomerAddress FOREIGN KEY REFERENCES CustomerAddress(AddressId),
    PRIMARY KEY (CustomerId, AddressId)
);

DROP TABLE IF EXISTS Restaurant;
GO

CREATE TABLE Restaurant (
    RestaurantId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    Phone NVARCHAR(15) NOT NULL
);

DROP TABLE IF EXISTS Category;
GO

CREATE TABLE Category (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS Food;
GO

CREATE TABLE Food (
    FoodId INT PRIMARY KEY IDENTITY(1,1),
    FoodName NVARCHAR(100) NOT NULL,
    CategoryId INT CONSTRAINT FK_Food_Category FOREIGN KEY REFERENCES Category(CategoryId),
    CONSTRAINT UQ_Food UNIQUE (FoodName, CategoryId)
);

DROP TABLE IF EXISTS MenuItem;
GO

CREATE TABLE MenuItem (
    MenuItemId INT PRIMARY KEY IDENTITY(1,1),
    RestaurantId INT CONSTRAINT FK_MenuItem_Restaurant FOREIGN KEY REFERENCES Restaurant(RestaurantId),
    FoodId INT CONSTRAINT FK_MenuItem_Food FOREIGN KEY REFERENCES Food(FoodId),
    Price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT UQ_MenuItem UNIQUE (RestaurantId, FoodId)
);

DROP TABLE IF EXISTS Orders;
GO

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    CustomerId INT CONSTRAINT FK_Orders_Customer FOREIGN KEY REFERENCES Customer(CustomerId),
    RestaurantId INT CONSTRAINT FK_Orders_Restaurant FOREIGN KEY REFERENCES Restaurant(RestaurantId),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2)
);

DROP TABLE IF EXISTS OrderItem;
GO

CREATE TABLE OrderItem (
    OrderItemId INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT CONSTRAINT FK_OrderItem_Orders FOREIGN KEY REFERENCES Orders(OrderId),
    MenuItemId INT CONSTRAINT FK_OrderItem_MenuItem FOREIGN KEY REFERENCES MenuItem(MenuItemId),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    SubTotal AS (Quantity * (SELECT Price FROM MenuItem WHERE MenuItem.MenuItemId = OrderItem.MenuItemId)) PERSISTED
);

DROP TABLE IF EXISTS PaymentMethod;
GO

CREATE TABLE PaymentMethod (
    PaymentMethodId INT PRIMARY KEY IDENTITY(1,1),
    MethodName NVARCHAR(50) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS Payment;
GO

CREATE TABLE Payment (
    PaymentId INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT UNIQUE FOREIGN KEY REFERENCES Orders(OrderId),
    PaymentMethodId INT CONSTRAINT FK_Payment_PaymentMethod FOREIGN KEY REFERENCES PaymentMethod(PaymentMethodId),
    PaymentDate DATETIME DEFAULT GETDATE(),
    AmountPaid DECIMAL(10,2) NOT NULL
);

DROP TABLE IF EXISTS Delivery;
GO

CREATE TABLE Delivery (
    DeliveryId INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT CONSTRAINT FK_Delivery_Orders UNIQUE FOREIGN KEY REFERENCES Orders(OrderId),
    AddressId INT CONSTRAINT FK_Delivery_CustomerAddress FOREIGN KEY REFERENCES CustomerAddress(AddressId),
    DeliveryStatus NVARCHAR(50) NOT NULL CHECK (DeliveryStatus IN ('Pending', 'In Transit', 'Delivered', 'Cancelled')),
    EstimatedDeliveryTime DATETIME,
    DeliveredOn DATETIME
);
