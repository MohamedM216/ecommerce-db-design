CREATE DATABASE ecommerce_db;
GO

USE ecommerce_db;
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
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CategoryParent FOREIGN KEY (parent_category_id) REFERENCES Category(category_id) ON DELETE SET NULL
);
GO

CREATE TABLE Product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    base_price DECIMAL(10, 2) NOT NULL,
    category_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ProductCategory FOREIGN KEY (category_id) REFERENCES Category(category_id)
);
GO

CREATE TABLE ProductVariant (
    variant_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    SKU NVARCHAR(50) UNIQUE NOT NULL,
    color NVARCHAR(50),
    size NVARCHAR(50),
    price_adjustment DECIMAL(10, 2) DEFAULT 0.00,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_VariantProduct FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
);
GO

CREATE TABLE Warehouse (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    location NVARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity_available INT NOT NULL DEFAULT 0,
    backorder_allowed BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_InventoryVariant FOREIGN KEY (variant_id) REFERENCES ProductVariant(variant_id) ON DELETE CASCADE,
    CONSTRAINT FK_InventoryWarehouse FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id) ON DELETE CASCADE,
    CONSTRAINT UQ_VariantWarehouse UNIQUE (variant_id, warehouse_id)
);
GO

CREATE TABLE [Order] (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    total_amount DECIMAL(12, 2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_OrderUser FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

CREATE TABLE OrderItem (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_OrderItemOrder FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItemVariant FOREIGN KEY (variant_id) REFERENCES ProductVariant(variant_id)
);
GO

CREATE TABLE [Transaction] (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    gateway_transaction_id NVARCHAR(100),
    status NVARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method NVARCHAR(50) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_PaymentOrder FOREIGN KEY (order_id) REFERENCES [Order](order_id),
    CONSTRAINT FK_PaymentTransaction FOREIGN KEY (transaction_id) REFERENCES [Transaction](transaction_id)
);
GO

CREATE TABLE ShippingProvider (
    provider_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    contact_info NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Shipping (
    shipping_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    provider_id INT NOT NULL,
    tracking_number NVARCHAR(100),
    estimated_delivery DATE,
    status NVARCHAR(20) DEFAULT 'processing' CHECK (status IN ('processing', 'shipped', 'in_transit', 'delivered')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ShippingOrder FOREIGN KEY (order_id) REFERENCES [Order](order_id),
    CONSTRAINT FK_ShippingProvider FOREIGN KEY (provider_id) REFERENCES ShippingProvider(provider_id)
);
GO

CREATE TABLE Coupon (
    coupon_id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) UNIQUE NOT NULL,
    discount_type NVARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    value DECIMAL(10, 2) NOT NULL,
    expiry_date DATE NOT NULL,
    max_uses INT NULL,
    current_uses INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Review (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    date DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ReviewUser FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_ReviewProduct FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE,
    CONSTRAINT UQ_UserProductReview UNIQUE (user_id, product_id)
);
GO
