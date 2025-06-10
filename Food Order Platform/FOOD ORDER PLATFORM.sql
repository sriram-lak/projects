-- create database

DROP DATABASE IF EXISTS FoodOrderPlatform;
GO

CREATE DATABASE FoodOrderPlatform;
GO

USE FoodOrderPlatform;
GO

-- create table(6)

DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users(
userId INT IDENTITY(1,1) PRIMARY KEY,
userName NVARCHAR(50) NOT NULL);
GO

DROP TABLE IF EXISTS Foods;
GO

CREATE TABLE Foods(
foodId INT IDENTITY(101,1) PRIMARY KEY,
foodName NVARCHAR(100) NOT NULL);
GO

DROP TABLE IF EXISTS Shops;
GO

CREATE TABLE Shops(
shopId INT IDENTITY(1001,1) PRIMARY KEY,
shopName NVARCHAR(100) NOT NULL,
shopLocation NVARCHAR(100) NOT NULL);
GO

DROP TABLE IF EXISTS Bills;
GO

CREATE TABLE Bills(
billId INT IDENTITY(101,1) PRIMARY KEY,
userId INT CONSTRAINT FK_Bills_Users FOREIGN KEY REFERENCES Users(userId),
billPrice MONEY DEFAULT 0);
GO

DROP TABLE IF EXISTS ShopFoodMenu;
GO

CREATE TABLE ShopFoodMenu(
shopMenuId INT IDENTITY(1,1) PRIMARY KEY,
shopId INT CONSTRAINT FK_ShopFoodMenu_Shops FOREIGN KEY REFERENCES Shops(shopId),
foodId INT CONSTRAINT FK_ShopFoodMenu_Foods FOREIGN KEY REFERENCES Foods(foodId),
foodPrice MONEY DEFAULT 0,
CONSTRAINT UQ_shopId_foodId UNIQUE (shopId,foodId));
GO

DROP TABLE IF EXISTS OrderDetail;
GO

CREATE TABLE OrderDetail(
orderDetailId INT IDENTITY(1001,1) PRIMARY KEY,
billId INT CONSTRAINT FK_OrderDetail_Bills foreign key references Bills(billId),
shopMenuId INT CONSTRAINT FK_OrderDetail_ShopFoodMenu foreign key references ShopFoodMenu(shopMenuId),
quantity INT NOT NULL DEFAULT 1,
productPrice MONEY DEFAULT 0);
GO

-- insert data in Users table

INSERT INTO Users (userName) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');
GO

-- insert data in Foods table
INSERT INTO Foods (foodName) VALUES
('Burger'),
('Pizza'),
('Pasta'),
('Salad'),
('Sushi');
GO

-- insert data in Shops table
INSERT INTO Shops (shopName, shopLocation) VALUES
('Tasty Bites', 'Downtown'),
('Food Corner', 'Uptown'),
('Snack Shack', 'Midtown');
GO

-- insert data in ShopFoodMenu table

-- Tasty Bites menu
INSERT INTO ShopFoodMenu (shopId, foodId, foodPrice) VALUES
(1001, 101, 5.99),   -- Burger
(1001, 102, 7.99),   -- Pizza
(1001, 103, 6.50);   -- Pasta

-- Food Corner menu
INSERT INTO ShopFoodMenu (shopId, foodId, foodPrice) VALUES
(1002, 102, 8.50),   -- Pizza
(1002, 104, 4.99),   -- Salad
(1002, 105, 12.99);  -- Sushi

-- Snack Shack menu
INSERT INTO ShopFoodMenu (shopId, foodId, foodPrice) VALUES
(1003, 101, 6.25),   -- Burger
(1003, 104, 5.50),   -- Salad
(1003, 105, 13.25);  -- Sushi
GO

-- insert data in Bills table
INSERT INTO Bills (userId, billPrice) VALUES
(1, 20.97),  -- Alice
(2, 21.99),  -- Bob
(1, 18.49),  -- Alice second bill
(3, 13.75);  -- Charlie
GO

-- insert data in OrderDetail table

-- Bill 1 by Alice
INSERT INTO OrderDetail (billId, shopMenuId, quantity, productPrice) VALUES
(101, 1, 2, 5.99),   -- 2 Burgers from Tasty Bites
(101, 2, 1, 7.99);   -- 1 Pizza from Tasty Bites

-- Bill 2 by Bob
INSERT INTO OrderDetail (billId, shopMenuId, quantity, productPrice) VALUES
(102, 5, 1, 8.50),   -- 1 Pizza from Food Corner
(102, 6, 2, 4.99);   -- 2 Salads from Food Corner

-- Bill 3 by Alice (second bill)
INSERT INTO OrderDetail (billId, shopMenuId, quantity, productPrice) VALUES
(103, 3, 1, 6.50),   -- 1 Pasta from Tasty Bites
(103, 8, 2, 5.50);   -- 2 Salads from Snack Shack

-- Bill 4 by Charlie
INSERT INTO OrderDetail (billId, shopMenuId, quantity, productPrice) VALUES
(104, 9, 1, 13.25);  -- 1 Sushi from Snack Shack
GO