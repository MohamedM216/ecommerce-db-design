Here is an initial db schema:

| Entity | Attributes |
| :------------------ | :----------- |
| User | **user_id**, name, email, password, role (customer/seller/admin), phone |
| Product | **product_id**, name, description, base_price, category_id (FK) |
| ProductVariant | **variant_id**, product_id (FK), SKU, color, size, price_adjustment |
| Inventory	| **inventory_id**, variant_id (FK), warehouse_id (FK), quantity_available, backorder_allowed |
| Category | **category_id**, name, parent_category_id (for subcategories) |
| Order | **order_id**, user_id (FK), order_date, status, total_amount |
| OrderItem	| **order_item_id**, order_id (FK), variant_id (FK), quantity, price_at_purchase |
| Payment | **payment_id**, order_id (FK), amount, payment_method, status, transaction_id (FK) |
| Shipping | **shipping_id**, order_id (FK), provider_id (FK), tracking_number, estimated_delivery |
| ShippingProvider | **provider_id**, name (e.g., FedEx), contact_info |
| Coupon | **coupon_id**, code, discount_type (percentage/fixed), value, expiry_date |
| Warehouse | **warehouse_id**, name, location |
| Review | **review_id**, user_id (FK), product_id (FK), rating, comment, date |
| Transaction | **transaction_id**, gateway_transaction_id, status |
