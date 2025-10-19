USE northwind_project;

SHOW TABLES;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM shippers;
SELECT COUNT(*) FROM suppliers;
-- Q1 What is the average number of orders per customer? Are there high-value repeat customers?
-- Average number of orders per customer
SELECT 
    ROUND(COUNT(DISTINCT OrderID) / COUNT(DISTINCT CustomerID), 2) AS AvgOrdersPerCustomer
FROM orders;
-- Identify high-value repeat customers
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSpend
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
HAVING TotalOrders > 3 AND TotalSpend > 5000
ORDER BY TotalSpend DESC;

-- Q2 How do customer order patterns vary by city or country?

SELECT 
    c.Country,
    c.City,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(AVG(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS AvgOrderValue
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Country, c.City
ORDER BY TotalSales DESC;
-- Q3 Can we cluster customers based on total spend, order count, and preferred categories?
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSpend,
    cat.CategoryName AS PreferredCategory
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN products p ON od.ProductID = p.ProductID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY c.CustomerID, c.CompanyName, cat.CategoryName
ORDER BY TotalSpend DESC;
-- Q4 Which product categories or products contribute most to order revenue?
-- Revenue by Product Category
SELECT 
    cat.CategoryName,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS CategoryRevenue
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY CategoryRevenue DESC;

-- Revenue by Individual Product
SELECT 
    p.ProductName,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS ProductRevenue
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY ProductRevenue DESC
LIMIT 10;
-- Q4.5 Are there any correlations between orders and customer location or product category?
SELECT 
    c.Country,
    cat.CategoryName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalRevenue
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN products p ON od.ProductID = p.ProductID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY c.Country, cat.CategoryName
ORDER BY TotalRevenue DESC;
-- Q5 How frequently do different customer segments place orders?
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS OrderFrequency,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSpend,
    CASE 
        WHEN COUNT(DISTINCT o.OrderID) >= 10 THEN 'Frequent Buyer'
        WHEN COUNT(DISTINCT o.OrderID) BETWEEN 5 AND 9 THEN 'Regular Buyer'
        ELSE 'Occasional Buyer'
    END AS CustomerSegment
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpend DESC;
-- Q6 What is the geographic and title-wise distribution of employees?
SELECT 
    Country,
    Title,
    COUNT(*) AS EmployeeCount
FROM employees
GROUP BY Country, Title
ORDER BY Country, EmployeeCount DESC;
-- Q7 What trends can we observe in hire dates across employee titles?
SELECT 
	Title, Hire_Year,
    COUNT(*) AS EmployeesHired
FROM employees
GROUP BY Title, Hire_Year
ORDER BY Hire_Year, Title;
-- Q8 What patterns exist in employee title and courtesy title distributions?
SELECT 
    TitleOfCourtesy,
    Title,
    COUNT(*) AS CountOfEmployees
FROM employees
GROUP BY TitleOfCourtesy, Title
ORDER BY TitleOfCourtesy, CountOfEmployees DESC;

-- Q9 Are there correlations between product pricing, stock levels, and sales performance?
SELECT 
    p.ProductName,
    p.UnitPrice,
    p.UnitsInStock,
    p.UnitsOnOrder,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSales
FROM products p
JOIN orderdetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName, p.UnitPrice, p.UnitsInStock, p.UnitsOnOrder
ORDER BY TotalSales DESC;

-- Q10 How does product demand change over months or seasons?
SELECT 
    OrderYear,
    OrderMonth,
    ROUND(SUM(od.Quantity), 2) AS TotalUnitsSold
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
GROUP BY OrderYear, OrderMonth
ORDER BY OrderYear, OrderMonth;

-- Q11 Can we identify anomalies in product sales or revenue performance?
SELECT 
    p.ProductName,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalRevenue,
    ROUND(AVG(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS AvgRevenuePerOrder
FROM orderdetails od
JOIN products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
HAVING TotalRevenue < 1000 OR TotalRevenue > 50000
ORDER BY TotalRevenue DESC;

-- Q12 Are there any regional trends in supplier distribution and pricing?
SELECT 
    Country,
    ROUND(AVG(p.UnitPrice), 2) AS AvgProductPrice,
    COUNT(DISTINCT s.SupplierID) AS SupplierCount
FROM suppliers s
JOIN products p ON s.SupplierID = p.SupplierID
GROUP BY Country
ORDER BY AvgProductPrice DESC;

-- Q13 How are suppliers distributed across different product categories?
SELECT 
    cat.CategoryName,
    COUNT(DISTINCT s.SupplierID) AS SupplierCount
FROM suppliers s
JOIN products p ON s.SupplierID = p.SupplierID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY SupplierCount DESC;

-- Q14 How do supplier pricing and categories relate across different regions?
SELECT 
    s.Country,
    cat.CategoryName,
    ROUND(AVG(p.UnitPrice), 2) AS AvgPrice
FROM suppliers s
JOIN products p ON s.SupplierID = p.SupplierID
JOIN categories cat ON p.CategoryID = cat.CategoryID
GROUP BY s.Country, cat.CategoryName
ORDER BY s.Country, AvgPrice DESC;



