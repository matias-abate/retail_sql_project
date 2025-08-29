#!/bin/bash
# Script para exportar KPIs desde db_project_excel a CSVs

OUTDIR=~/Documents/retail_sql_project/analysis
mkdir -p $OUTDIR

echo "Exportando KPIs a $OUTDIR ..."

# 1. Ventas mensuales
docker exec -i retail_mysql mysql -uroot -p12345 --batch --skip-column-names -e "
USE db_project_excel;
SELECT YEAR(TimeKey) AS Year, MONTH(TimeKey) AS Month,
       SUM(Quantity * UnitPrice * (1 - DiscountPct/100)) AS Revenue,
       COUNT(DISTINCT CustomerID) AS Active_Customers
FROM FactSales
GROUP BY YEAR(TimeKey), MONTH(TimeKey)
ORDER BY Year, Month;
" > $OUTDIR/ventas_mensuales.csv

# 2. Top productos
docker exec -i retail_mysql mysql -uroot -p12345 --batch --skip-column-names -e "
USE db_project_excel;
SELECT p.ProductName, SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimProducts p ON f.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC
LIMIT 10;
" > $OUTDIR/top_productos.csv

# 3. Top clientes
docker exec -i retail_mysql mysql -uroot -p12345 --batch --skip-column-names -e "
USE db_project_excel;
SELECT c.CustomerID, c.Region, SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Region
ORDER BY Revenue DESC
LIMIT 10;
" > $OUTDIR/top_clientes.csv

# 4. Ventas por país
docker exec -i retail_mysql mysql -uroot -p12345 --batch --skip-column-names -e "
USE db_project_excel;
SELECT c.Region AS Country, SUM(f.Quantity * f.UnitPrice) AS Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY Revenue DESC;
" > $OUTDIR/ventas_por_pais.csv

# 5. Totales generales
docker exec -i retail_mysql mysql -uroot -p12345 --batch --skip-column-names -e "
USE db_project_excel;
SELECT COUNT(DISTINCT c.CustomerID) AS Total_Customers,
       COUNT(DISTINCT p.ProductID) AS Total_Products,
       SUM(f.Quantity) AS Units_Sold,
       SUM(f.Quantity * f.UnitPrice) AS Total_Revenue
FROM FactSales f
JOIN DimCustomers c ON f.CustomerID = c.CustomerID
JOIN DimProducts p ON f.ProductID = p.ProductID;
" > $OUTDIR/totales_generales.csv

echo "✅ Exportación completa. Archivos en $OUTDIR"
