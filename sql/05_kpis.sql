-- ========================================
-- KPIs y vistas de análisis
-- ========================================

-- 1. Ventas mensuales (evolución en el tiempo)
SELECT
    YEAR(TimeKey) AS Year,
    MONTH(TimeKey) AS Month,
    SUM(Quantity * UnitPrice * (1 - DiscountPct/100)) AS Revenue,
    COUNT(DISTINCT CustomerID) AS Active_Customers
FROM FactSales
GROUP BY YEAR(TimeKey), MONTH(TimeKey)
ORDER BY Year, Month;

-- 2. Top 10 productos por ingresos
SELECT
    p.ProductName,
    SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimProducts p ON f.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC
LIMIT 10;

-- 3. Top 10 clientes por compras
SELECT
    c.CustomerID,
    c.Region,
    SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Region
ORDER BY Revenue DESC
LIMIT 10;

-- 4. Ventas por país
SELECT
    c.Region AS Country,
    SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY Revenue DESC;

-- 5. Métricas rápidas (totales)
SELECT
    COUNT(DISTINCT c.CustomerID) AS Total_Customers,
    COUNT(DISTINCT p.ProductID) AS Total_Products,
    SUM(f.Quantity) AS Units_Sold,
    SUM(f.Quantity * f.UnitPrice) AS Total_Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
JOIN DimProducts p ON f.ProductID = p.ProductID;
