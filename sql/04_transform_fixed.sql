-- ========================================
-- TRANSFORM: staging_retail → modelo estrella (corregido)
-- ========================================

-- 1. Desactivar constraints y limpiar tablas
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE FactSales;
TRUNCATE TABLE DimCustomers;
TRUNCATE TABLE DimProducts;
TRUNCATE TABLE DimTime;
SET FOREIGN_KEY_CHECKS=1;

-- 2. Poblar DimCustomers
INSERT IGNORE INTO DimCustomers (CustomerID, FullName, Email, Region, CreatedAt)
SELECT DISTINCT
    CAST(CustomerID AS UNSIGNED),
    CONCAT('Customer_', CustomerID),
    CONCAT('customer', CustomerID, '@mail.com'),
    Country,
    CURDATE()
FROM staging_retail
WHERE CustomerID IS NOT NULL AND CustomerID <> '';

-- 3. Poblar DimProducts
-- ⚠️ ProductID y SKU ahora son VARCHAR porque StockCode tiene letras
INSERT IGNORE INTO DimProducts (ProductID, SKU, ProductName, Category, UnitPrice)
SELECT DISTINCT
    StockCode,
    StockCode,
    Description,
    'General',
    UnitPrice
FROM staging_retail
WHERE StockCode IS NOT NULL AND StockCode <> '';

-- 4. Poblar DimTime
INSERT IGNORE INTO DimTime (TimeKey, Year, Month, Day, MonthName)
SELECT DISTINCT
    DATE(InvoiceDate) AS TimeKey,
    YEAR(InvoiceDate),
    MONTH(InvoiceDate),
    DAY(InvoiceDate),
    MONTHNAME(InvoiceDate)
FROM staging_retail
WHERE InvoiceDate IS NOT NULL;

-- 5. Poblar FactSales
INSERT IGNORE INTO FactSales (TimeKey, CustomerID, ProductID, Quantity, UnitPrice, DiscountPct)
SELECT
    DATE(InvoiceDate) AS TimeKey,
    CAST(CustomerID AS UNSIGNED),
    StockCode,
    Quantity,
    UnitPrice,
    0
FROM staging_retail
WHERE CustomerID IS NOT NULL
  AND StockCode IS NOT NULL
  AND InvoiceDate IS NOT NULL;
