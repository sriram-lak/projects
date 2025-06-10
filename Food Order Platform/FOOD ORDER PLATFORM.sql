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
shopId INT CONSTRAINT FK_Bills_Shops FOREIGN KEY REFERENCES Shops(shopId),
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

-- Store Procedure of User table

CREATE PROCEDURE InsertUser
    @userName NVARCHAR(50)
AS
BEGIN
    IF LTRIM(RTRIM(@userName)) = ''
    BEGIN
        RAISERROR('User name cannot be empty',16,1); 
        RETURN;
    END

    INSERT INTO Users (userName)
    VALUES (@userName)
END;
GO

-- Store Procedure of Foods table

CREATE PROCEDURE InsertFood
    @foodName NVARCHAR(100)
AS
BEGIN
    IF LTRIM(RTRIM(@foodName)) = ''
    BEGIN
        RAISERROR('Food name cannot be empty',16,1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Foods WHERE foodName = @foodName)
    BEGIN
        RAISERROR('This food item already exists',16,1);
        RETURN;
    END

    INSERT INTO Foods (foodName)
    VALUES (@foodName);
END;
GO

-- Store Procedure of Shops table

CREATE PROCEDURE InsertShop
    @shopName NVARCHAR(100),
    @shopLocation NVARCHAR(100)
AS
BEGIN
    IF LTRIM(RTRIM(@shopName)) = ''
    BEGIN
        RAISERROR('Shop name cannot be empty',16,1);
        RETURN;
    END

    IF LTRIM(RTRIM(@shopLocation)) = ''
    BEGIN
        RAISERROR('Shop location cannot be empty',16,1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Shops
        WHERE shopName = @shopName AND shopLocation = @shopLocation
    )
    BEGIN
        RAISERROR('This shop already exists at the same location',16,1);
        RETURN;
    END

    INSERT INTO Shops (shopName, shopLocation)
    VALUES (@shopName, @shopLocation);
END;
GO

-- Store Procedure of ShopFoodMenu table

CREATE PROCEDURE InsertShopFoodMenu
    @shopId INT,
    @foodId INT,
    @foodPrice MONEY
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Shops WHERE shopId = @shopId)
    BEGIN
        RAISERROR('Invalid shopId. Shop does not exist',16,1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Foods WHERE foodId = @foodId)
    BEGIN
        RAISERROR('Invalid foodId. Food does not exist',16,1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ShopFoodMenu WHERE shopId = @shopId AND foodId = @foodId)
    BEGIN
        RAISERROR('This food item already exists in the shops menu',16,1);
        RETURN;
    END

    IF @foodPrice <= 0
    BEGIN
        RAISERROR('Food price must be greater than 0',16,1);
        RETURN;
    END

    INSERT INTO ShopFoodMenu (shopId, foodId, foodPrice)
    VALUES (@shopId, @foodId, @foodPrice);
END;
GO

-- Store Procedure of Bills table

CREATE PROCEDURE InsertBill
    @userId INT,
    @shopId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE userId = @userId)
    BEGIN
        RAISERROR('Invalid userId. User does not exist',16,1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Shops WHERE shopId = @shopId)
    BEGIN
        RAISERROR('Invalid shopId. Shop does not exist',16,1);
        RETURN;
    END

    INSERT INTO Bills (userId, shopId)
    VALUES (@userId, @shopId);
END;
GO

-- Store Procedure of OrderDetail table

CREATE PROCEDURE InsertOrderDetail
    @billId INT,
    @shopMenuId INT,
    @quantity INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Bills WHERE billId = @billId)
    BEGIN
        RAISERROR('Invalid billId. Bill does not exist',16,1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM ShopFoodMenu WHERE shopMenuId = @shopMenuId)
    BEGIN
        RAISERROR('Invalid shopMenuId. Menu item does not exist',16,1);
        RETURN;
    END

    IF @quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than 0',16,1);
        RETURN;
    END

    DECLARE @billShopId INT;
    SELECT @billShopId = shopId FROM Bills WHERE billId = @billId;

    DECLARE @menuShopId INT, @foodPrice MONEY;
    SELECT @menuShopId = shopId, @foodPrice = foodPrice
    FROM ShopFoodMenu
    WHERE shopMenuId = @shopMenuId;

    IF @billShopId != @menuShopId
    BEGIN
        RAISERROR('This menu item does not belong to the shop selected in the bill',16,1);
        RETURN;
    END

    INSERT INTO OrderDetail (billId, shopMenuId, quantity, productPrice)
    VALUES (@billId, @shopMenuId, @quantity, @foodPrice);

    UPDATE Bills
    SET billPrice = billPrice + (@quantity * @foodPrice)
    WHERE billId = @billId;
END;
GO

-- Insert data in Users table

EXEC InsertUser 'Sriram'
EXEC InsertUser 'Raman'
EXEC InsertUser 'Ravi'
EXEC InsertUser 'Suresh'

-- Insert data in Foods table

EXEC InsertFood 'Veg Biryani';
EXEC InsertFood 'Chicken Roll';
EXEC InsertFood 'Paneer Butter Masala';
EXEC InsertFood 'Egg Fried Rice';
EXEC InsertFood 'Mutton Curry';

-- Insert data in Shops table

EXEC InsertShop 'Food Point', 'Anna Nagar';
EXEC InsertShop 'Spice Hub', 'T. Nagar';
EXEC InsertShop 'Hot Plate', 'Velachery';

-- Insert data in ShopFoodMenu table

-- Food Point
EXEC InsertShopFoodMenu @shopId = 1001, @foodId = 101, @foodPrice = 120.00; -- Veg Biryani
EXEC InsertShopFoodMenu @shopId = 1001, @foodId = 102, @foodPrice = 150.00; -- Chicken Roll

-- Spice Hub
EXEC InsertShopFoodMenu @shopId = 1002, @foodId = 103, @foodPrice = 180.00; -- Paneer Butter Masala
EXEC InsertShopFoodMenu @shopId = 1002, @foodId = 104, @foodPrice = 110.00; -- Egg Fried Rice

-- Hot Plate
EXEC InsertShopFoodMenu @shopId = 1003, @foodId = 105, @foodPrice = 220.00; -- Mutton Curry

-- Insert data in Bills table

EXEC InsertBill @userId = 1, @shopId = 1001;  -- billId should be 101

-- Insert data in OrderDetail  table

-- Sriram orders 2 Veg Biryani (shopMenuId = 1), 1 Chicken Roll (shopMenuId = 2)
EXEC InsertOrderDetail @billId = 101, @shopMenuId = 1, @quantity = 2; -- 2 x 120 = 240
EXEC InsertOrderDetail @billId = 101, @shopMenuId = 2, @quantity = 1; -- 1 x 150 = 150

-- Total billPrice will now be updated to 390
