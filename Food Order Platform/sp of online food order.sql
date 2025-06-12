-- Store Procedure of Customer table

CREATE PROCEDURE InsertCustomer
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15)
AS
BEGIN
    IF LTRIM(RTRIM(@Name)) = ''
    BEGIN
        RAISERROR('Customer name cannot be empty', 16, 1);
        RETURN;
    END
	
    IF EXISTS (SELECT 1 FROM Customer WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already exists', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Customer WHERE Phone = @Phone)
    BEGIN
        RAISERROR('Phone number already exists', 16, 1);
        RETURN;
    END

    INSERT INTO Customer (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);
END;
GO

-- Store Procedure of CustomerAddress table

CREATE PROCEDURE InsertCustomerAddress
    @AddressLine NVARCHAR(255),
    @City NVARCHAR(100) = NULL,
    @State NVARCHAR(100) = NULL,
    @ZipCode NVARCHAR(10) = NULL
AS
BEGIN
    IF LTRIM(RTRIM(@AddressLine)) = ''
    BEGIN
        RAISERROR('Address line cannot be empty', 16, 1);
        RETURN;
    END

    INSERT INTO CustomerAddress (AddressLine, City, State, ZipCode)
    VALUES (@AddressLine, @City, @State, @ZipCode);
END;
GO
 
-- Store Procedure of CustomerAddressMapping table

CREATE PROCEDURE InsertCustomerAddressMapping
    @CustomerId INT,
    @AddressId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerId = @CustomerId)
    BEGIN
        RAISERROR('Invalid CustomerId. Customer does not exist', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM CustomerAddress WHERE AddressId = @AddressId)
    BEGIN
        RAISERROR('Invalid AddressId. Address does not exist', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM CustomerAddressMapping 
        WHERE CustomerId = @CustomerId AND AddressId = @AddressId
    )
    BEGIN
        RAISERROR('This mapping already exists', 16, 1);
        RETURN;
    END

    INSERT INTO CustomerAddressMapping (CustomerId, AddressId)
    VALUES (@CustomerId, @AddressId);
END;
GO

-- Store Procedure of Restaurant table

CREATE PROCEDURE InsertRestaurant
    @Name NVARCHAR(100),
    @Address NVARCHAR(255),
    @Phone NVARCHAR(15)
AS
BEGIN
    IF LTRIM(RTRIM(@Name)) = ''
    BEGIN
        RAISERROR('Restaurant name cannot be empty', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Restaurant WHERE Phone = @Phone)
    BEGIN
        RAISERROR('Phone number already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Restaurant (Name, Address, Phone)
    VALUES (@Name, @Address, @Phone);
END;
GO

-- Store Procedure of Category table

CREATE PROCEDURE InsertCategory
    @CategoryName NVARCHAR(50)
AS
BEGIN
    IF LTRIM(RTRIM(@CategoryName)) = ''
    BEGIN
        RAISERROR('Category name cannot be empty', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Category WHERE CategoryName = @CategoryName)
    BEGIN
        RAISERROR('Category name already exists', 16, 1);
        RETURN;
    END

    INSERT INTO Category (CategoryName)
    VALUES (@CategoryName);
END;
GO

-- Store Procedure of Food table

CREATE PROCEDURE InsertFood
    @FoodName NVARCHAR(100),
    @CategoryId INT
AS
BEGIN
    IF LTRIM(RTRIM(@FoodName)) = ''
    BEGIN
        RAISERROR('Food name cannot be empty', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Category WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Food
        WHERE FoodName = @FoodName AND CategoryId = @CategoryId
    )
    BEGIN
        RAISERROR('This food item already exists in the given category', 16, 1);
        RETURN;
    END

    INSERT INTO Food (FoodName, CategoryId)
    VALUES (@FoodName, @CategoryId);
END;
GO

-- Store Procedure of MenuItem table

CREATE PROCEDURE InsertMenuItem
    @RestaurantId INT,
    @FoodId INT,
    @Price DECIMAL(10, 2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Restaurant WHERE RestaurantId = @RestaurantId)
    BEGIN
        RAISERROR('Invalid RestaurantId. Restaurant does not exist', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Food WHERE FoodId = @FoodId)
    BEGIN
        RAISERROR('Invalid FoodId. Food does not exist', 16, 1);
        RETURN;
    END

    IF @Price <= 0
    BEGIN
        RAISERROR('Price must be greater than 0', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM MenuItem
        WHERE RestaurantId = @RestaurantId AND FoodId = @FoodId
    )
    BEGIN
        RAISERROR('This food item already exists for the restaurant', 16, 1);
        RETURN;
    END

    INSERT INTO MenuItem (RestaurantId, FoodId, Price)
    VALUES (@RestaurantId, @FoodId, @Price);
END;
GO

-- Store Procedure of Orders table

CREATE PROCEDURE InsertOrder
    @CustomerId INT,
    @RestaurantId INT,
    @TotalAmount DECIMAL(10, 2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerId = @CustomerId)
    BEGIN
        RAISERROR('Invalid CustomerId. Customer does not exist', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Restaurant WHERE RestaurantId = @RestaurantId)
    BEGIN
        RAISERROR('Invalid RestaurantId. Restaurant does not exist', 16, 1);
        RETURN;
    END

    IF @TotalAmount <= 0
    BEGIN
        RAISERROR('Total amount must be greater than 0', 16, 1);
        RETURN;
    END

    INSERT INTO Orders (CustomerId, RestaurantId, TotalAmount)
    VALUES (@CustomerId, @RestaurantId, @TotalAmount);
END;
GO

-- Store Procedure of OrderItem table

CREATE PROCEDURE InsertOrderDetail
    @OrderId INT,
    @MenuItemId INT,
    @Quantity INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('Invalid OrderId. Order does not exist', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MenuItem WHERE MenuItemId = @MenuItemId)
    BEGIN
        RAISERROR('Invalid MenuItemId. Menu item does not exist', 16, 1);
        RETURN;
    END

    IF @Quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than 0', 16, 1);
        RETURN;
    END

    DECLARE @OrderRestaurantId INT;
    SELECT @OrderRestaurantId = RestaurantId FROM Orders WHERE OrderId = @OrderId;

    DECLARE @MenuRestaurantId INT, @ItemPrice DECIMAL(10,2);
    SELECT 
        @MenuRestaurantId = RestaurantId,
        @ItemPrice = Price
    FROM MenuItem
    WHERE MenuItemId = @MenuItemId;

    IF @OrderRestaurantId != @MenuRestaurantId
    BEGIN
        RAISERROR('This menu item does not belong to the restaurant selected in the order', 16, 1);
        RETURN;
    END

    INSERT INTO OrderItem (OrderId, MenuItemId, Quantity)
    VALUES (@OrderId, @MenuItemId, @Quantity);

    UPDATE Orders
    SET TotalAmount = TotalAmount + (@Quantity * @ItemPrice)
    WHERE OrderId = @OrderId;
END;
GO

-- Store Procedure of PaymentMethod table

CREATE PROCEDURE InsertPaymentMethod
    @MethodName NVARCHAR(50)
AS
BEGIN
    IF LTRIM(RTRIM(@MethodName)) = ''
    BEGIN
        RAISERROR('Payment method name cannot be empty', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM PaymentMethod WHERE MethodName = @MethodName)
    BEGIN
        RAISERROR('This payment method already exists', 16, 1);
        RETURN;
    END

    INSERT INTO PaymentMethod (MethodName)
    VALUES (@MethodName);
END;
GO

-- Store Procedure of Payment table

CREATE PROCEDURE InsertPayment
    @OrderId INT,
    @PaymentMethodId INT,
    @AmountPaid DECIMAL(10, 2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('Invalid OrderId. Order does not exist', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Payment WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('Payment for this order already exists', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM PaymentMethod WHERE PaymentMethodId = @PaymentMethodId)
    BEGIN
        RAISERROR('Invalid PaymentMethodId. Payment method does not exist', 16, 1);
        RETURN;
    END

    IF @AmountPaid <= 0
    BEGIN
        RAISERROR('AmountPaid must be greater than 0', 16, 1);
        RETURN;
    END

    DECLARE @OrderAmount DECIMAL(10,2);
    SELECT @OrderAmount = TotalAmount FROM Orders WHERE OrderId = @OrderId;

    IF @AmountPaid < @OrderAmount
    BEGIN
        RAISERROR('AmountPaid is less than the total order amount', 16, 1);
        RETURN;
    END

    INSERT INTO Payment (OrderId, PaymentMethodId, AmountPaid)
    VALUES (@OrderId, @PaymentMethodId, @AmountPaid);
END;
GO

-- Store Procedure of Delivery table

CREATE PROCEDURE InsertDelivery
    @OrderId INT,
    @AddressId INT,
    @DeliveryStatus NVARCHAR(50),
    @EstimatedDeliveryTime DATETIME = NULL,
    @DeliveredOn DATETIME = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('Invalid OrderId. Order does not exist', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Delivery WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('Delivery already exists for this order', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM CustomerAddress WHERE AddressId = @AddressId)
    BEGIN
        RAISERROR('Invalid AddressId. Address does not exist', 16, 1);
        RETURN;
    END

    IF @DeliveryStatus NOT IN ('Pending', 'In Transit', 'Delivered', 'Cancelled')
    BEGIN
        RAISERROR('Invalid DeliveryStatus. Must be one of: Pending, In Transit, Delivered, Cancelled', 16, 1);
        RETURN;
    END

    INSERT INTO Delivery (OrderId, AddressId, DeliveryStatus, EstimatedDeliveryTime, DeliveredOn)
    VALUES (@OrderId, @AddressId, @DeliveryStatus, @EstimatedDeliveryTime, @DeliveredOn);
END;
GO
