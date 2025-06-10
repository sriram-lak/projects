-- Advanced Query Practice Questions

USE FoodOrderPlatform;
GO

-- 1, List all users who have placed at least one bill, showing their userId, userName, and total amount spent (sum of billPrice).

SELECT U.userId,U.userName,SUM(B.billPrice) AS Total_Amount_Spent
FROM Users U
JOIN Bills B ON B.userId = U.userId
GROUP BY U.userName,U.userId;

-- 2, Find the top 3 shops with the highest total sales amount, showing shopId, shopName, and total sales.

SELECT TOP 3 S.shopId,S.shopName,ISNULL(SUM(OD.quantity * SFM.foodPrice),0) AS TotalSales
FROM Shops S
JOIN ShopFoodMenu SFM ON S.shopId = SFM.shopId
JOIN OrderDetail OD ON OD.shopMenuId = SFM.shopMenuId
JOIN Bills B ON B.billId = OD.billId
GROUP BY S.shopId,S.shopName
ORDER BY TotalSales DESC;

-- 3, For each shop, list the food items they sell along with their prices, sorted by shopId and then by foodName.

SELECT S.shopId, S.shopName, F.foodName, SFM.foodPrice
FROM Shops S
JOIN ShopFoodMenu SFM ON SFM.shopId = S.shopId
JOIN Foods F ON F.foodId = SFM.foodId
ORDER BY S.shopId,F.foodName;

-- 4, Find the food item(s) that are sold by the most number of shops.

SELECT F.foodName, COUNT(foodName) AS NumberOfShopsSold
FROM Foods F
JOIN ShopFoodMenu SFM ON F.foodId = SFM.foodId
JOIN Shops S ON SFM.shopId = S.shopId
GROUP BY F.foodName
ORDER BY NumberOfShopsSold DESC;

-- 5, Find the average quantity ordered per food item across all bills.

SELECT F.foodName,ISNULL(AVG(OD.quantity),0) AS AverageQuantity
FROM Foods F
JOIN ShopFoodMenu SFM ON F.foodId = SFM.foodId
JOIN OrderDetail OD ON OD.shopMenuId = SFM.shopMenuId
GROUP BY F.foodName
ORDER BY AverageQuantity DESC;

-- 6, List the bills where the total price (billPrice) does not match the sum of productPrice * quantity from the OrderDetail table.

SELECT B.billId
FROM Bills B
WHERE B.billPrice != ISNULL((SELECT SUM(quantity * productPrice) FROM OrderDetail OD WHERE B.billId = OD.billId),0);

-- 7, Find the users who have ordered food from more than 3 different shops.

SELECT U.userName
FROM Users U
JOIN Bills B ON B.userId = U.userId
JOIN OrderDetail OD ON OD.billId = B.billId
JOIN ShopFoodMenu SFM ON SFM.shopMenuId = OD.shopMenuId
GROUP BY U.userName
HAVING COUNT(DISTINCT SFM.shopId) > 3;

-- 8, Show the top 5 most ordered food items (by total quantity) along with their foodName and total quantity ordered. (10-06-2025)

SELECT TOP 5 F.foodName,ISNULL(SUM(OD.quantity),0) AS TotalQuantityOrdered
FROM Foods F
JOIN ShopFoodMenu SFM ON SFM.foodId = F.foodId
JOIN OrderDetail OD ON OD.shopMenuId = SFM.shopMenuId
GROUP BY F.foodName
ORDER BY TotalQuantityOrdered DESC;

-- 9, For each bill, list the detailed order including billId, userName, shopName, foodName, quantity, and productPrice.

SELECT B.billId,U.userName,S.shopName,F.foodName,OD.quantity,OD.productPrice
FROM Users U
JOIN Bills B ON B.userId = U.userId
JOIN OrderDetail OD ON OD.billId = B.billId
JOIN ShopFoodMenu SFM ON SFM.shopMenuId = OD.shopMenuId
JOIN Foods F ON F.foodId = SFM.foodId
JOIN Shops S ON S.shopId = SFM.shopId;

-- 10, Find the shops that have not sold any food in any bill yet.

SELECT S.shopName
FROM Shops S
LEFT JOIN ShopFoodMenu SFM ON SFM.shopId = S.shopId
LEFT JOIN OrderDetail OD ON OD.shopMenuId = SFM.shopMenuId
WHERE OD.orderDetailId IS NULL;

-- 11, only show shops where none of their food was ever sold

SELECT S.shopId
FROM Shops S
WHERE S.shopId NOT IN
(SELECT DISTINCT SFM.shopId
FROM ShopFoodMenu SFM
JOIN OrderDetail OD ON OD.shopMenuId = SFM.shopMenuId);

-- 12, Find users who have spent more than the average total spending across all users.

WITH UserSpentAmount AS(
SELECT B.userId,SUM(b.billPrice) AS TotalSpent
FROM Bills B
GROUP BY B.userId)
SELECT U.userId,U.userName, USA.TotalSpent
FROM UserSpentAmount USA
JOIN Users U ON U.userId = USA.userId
WHERE USA.TotalSpent > (SELECT AVG(TotalSpent) FROM UserSpentAmount);


SELECT * FROM Foods
SELECT * FROM Shops
SELECT * FROM ShopFoodMenu
SELECT * FROM Users
SELECT * FROM Bills
SELECT * FROM OrderDetail