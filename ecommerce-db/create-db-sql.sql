-- Create the database on SQL Server
CREATE DATABASE ECommerce5NF;
GO

USE ECommerce5NF;
GO

CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('customer', 'seller', 'admin')),
    phone NVARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES Category(category_id)
);
GO

CREATE TABLE Product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    base_price DECIMAL(10, 2) NOT NULL CHECK (base_price >= 0),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ProductCategory (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE
);
GO

CREATE TABLE ProductVariant (
    variant_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    SKU NVARCHAR(50) UNIQUE NOT NULL,
    price_adjustment DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);
GO

CREATE TABLE AttributeType (
    attribute_type NVARCHAR(50) PRIMARY KEY,
    description NVARCHAR(255)
);
GO

CREATE TABLE VariantAttribute (
    variant_id INT NOT NULL,
    attribute_type NVARCHAR(50) NOT NULL,
    value NVARCHAR(100) NOT NULL,
    PRIMARY KEY (variant_id, attribute_type),
    FOREIGN KEY (variant_id) REFERENCES ProductVariant(variant_id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_type) REFERENCES AttributeType(attribute_type)
);
GO

CREATE TABLE Warehouse (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    location NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE Inventory (
    variant_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity_available INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
    PRIMARY KEY (variant_id, warehouse_id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariant(variant_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id) ON DELETE CASCADE
);
GO

CREATE TABLE WarehousePolicy (
    warehouse_id INT NOT NULL,
    policy_type NVARCHAR(50) NOT NULL,
    value NVARCHAR(MAX) NOT NULL,
    PRIMARY KEY (warehouse_id, policy_type),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id) ON DELETE CASCADE
);
GO

CREATE TABLE [Order] (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

CREATE TABLE OrderTotal (
    order_id INT NOT NULL,
    calculation_method NVARCHAR(50) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (order_id, calculation_method),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE
);
GO

CREATE TABLE OrderItem (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES ProductVariant(variant_id)
);
GO

CREATE TABLE ItemPriceSnapshot (
    order_item_id INT NOT NULL,
    price_type NVARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_item_id, price_type),
    FOREIGN KEY (order_item_id) REFERENCES OrderItem(order_item_id) ON DELETE CASCADE
);
GO

CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    amount_requested DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES [Order](order_id)
);
GO

CREATE TABLE PaymentAttempt (
    attempt_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_id INT NOT NULL,
    method NVARCHAR(50) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    status NVARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id) ON DELETE CASCADE
);
GO

CREATE TABLE PaymentAllocation (
    payment_id INT NOT NULL,
    order_id INT NOT NULL,
    amount_applied DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (payment_id, order_id),
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id),
    FOREIGN KEY (order_id) REFERENCES [Order](order_id)
);
GO

CREATE TABLE ShippingProvider (
    provider_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    contact_info NVARCHAR(255)
);
GO

CREATE TABLE Shipping (
    shipping_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    provider_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES [Order](order_id),
    FOREIGN KEY (provider_id) REFERENCES ShippingProvider(provider_id)
);
GO

CREATE TABLE ShippingLeg (
    leg_id INT IDENTITY(1,1) PRIMARY KEY,
    shipping_id INT NOT NULL,
    tracking_number NVARCHAR(100) NOT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'processing',
    estimated_delivery DATE,
    actual_delivery DATE,
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id) ON DELETE CASCADE
);
GO

CREATE TABLE ShippingCostComponent (
    shipping_id INT NOT NULL,
    cost_type NVARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (shipping_id, cost_type),
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id) ON DELETE CASCADE
);
GO

CREATE TABLE Coupon (
    coupon_id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) UNIQUE NOT NULL,
    discount_type NVARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    value DECIMAL(10, 2) NOT NULL CHECK (value > 0),
    expiry_date DATE NOT NULL,
    is_active BIT DEFAULT 1
);
GO

CREATE TABLE Review (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    date DATETIME DEFAULT GETDATE(),
    content NVARCHAR(MAX),
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES [User](user_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE,
    CONSTRAINT UQ_UserProductReview UNIQUE (user_id, product_id)
);
GO

CREATE INDEX IX_ProductVariant_SKU ON ProductVariant(SKU);
CREATE INDEX IX_Order_UserID ON [Order](user_id);
CREATE INDEX IX_OrderItem_OrderID ON OrderItem(order_id);
CREATE INDEX IX_Inventory_VariantID ON Inventory(variant_id);
CREATE INDEX IX_Review_ProductID ON Review(product_id);
GO

PRINT 'E-commerce 5NF database schema created successfully';
GO