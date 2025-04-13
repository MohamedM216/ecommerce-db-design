Here is an initial db schema:

| Entity | Attributes |
| :------------------ | :----------- |
| User | **user_id**, name, email, password, role (customer/seller/admin), phone |
| Product | **product_id**, name, description, base_price |
| ProductCategory | **product_id (FK)**, **category_id (FK)** |
| Category | **category_id**, name, parent_category_id (for subcategories) |
| ProductVariant | **variant_id**, product_id (FK), SKU, price_adjustment |
| VariantAttribute | **variant_id (FK)**, **attribute_type**, value |
| AttributeType | **attribute_type**, description |
| Inventory	| **variant_id (FK)**, **warehouse_id (FK)**, quantity_available |
| WarehousePolicy | **warehouse_id (FK)**, **policy_type**, value |
| Warehouse | **warehouse_id**, name, location |
| Order | **order_id**, user_id (FK), order_date, status |
| OrderTotal | **order_id (FK)**, calculation_method, amount |
| OrderItem	| **order_item_id**, order_id (FK), variant_id (FK), quantity |
| ItemPriceSnapshot | **order_item_id (FK)**, price_type, amount |
| Payment | **payment_id**, order_id (FK), amount_requested |
| PaymentAttempt | **attempt_id**, payment_id (FK), method, amount, status |
| PaymentAllocation | **payment_id (FK)**, **order_id (FK)**, amount_applied |
| Shipping | **shipping_id**, order_id (FK), provider_id (FK) |
| ShippingLeg | **leg_id**, shipping_id (FK), tracking_number |
| ShippingCostComponent | **shipping_id (FK)**, **cost_type**, amount |
| ShippingProvider | **provider_id**, name (e.g., FedEx), contact_info |
| Coupon | **coupon_id**, code, discount_type (percentage/fixed), value, expiry_date |
| Review | **review_id**, user_id (FK), product_id (FK), date, content, rate |
