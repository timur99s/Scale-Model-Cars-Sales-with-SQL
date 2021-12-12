SELECT 'Customers' AS table_name,
	13 AS number_of_attribute,
	COUNT(*) AS number_of_row
FROM Customers

UNION ALL

SELECT 'Products' AS table_name, 
	9 AS number_of_attribute, 
	COUNT(*) AS number_of_row
FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
	4 AS number_of_attribute, 
	COUNT(*) AS number_of_row
FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
	7 AS number_of_attribute, 
	COUNT(*) AS number_of_row
FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
	5 AS number_of_attribute, 
	COUNT(*) AS number_of_row
FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name,
	4 AS number_of_attribute,
	COUNT(*) AS number_of_row
FROM payments

UNION ALL

SELECT 'Employees' AS table_name,
	8 AS number_of_atributes,
	COUNT(*) AS number_of_row
FROM employees

UNION ALL

SELECT 'Offices' AS table_name,
	9 AS number_of_attributes,
	COUNT(*) AS number_of_row
FROM Offices;

/* Calculating low stock */

SELECT productCode, ROUND(SUM(quantityOrdered)*1.0 / (SELECT quantityInStock 

FROM products WHERE orderdetails.productCode = products.productCode), 2) 
			AS low_stock
			FROM orderdetails GROUP BY productCode 
			ORDER BY low_stock LIMIT 10; /* Keeping only top 10 low_stock products */						      
						      
/* Calculating Product Performance */
SELECT productCode, SUM(quantityOrdered*priceEach) 
					AS product_perf FROM orderdetails GROUP BY productCode 
					ORDER BY product_perf DESC LIMIT 10;

/* Selecting products for restoring only */

WITH

low_stock_table AS (
SELECT productCode, ROUND(SUM(quantityOrdered) * 1.0/(SELECT quantityInStock
                                           FROM products WHERE orderdetails.productCode = products.productCode), 2) 
						AS low_stock
  FROM orderdetails
 GROUP BY productCode
 ORDER BY low_stock
 LIMIT 10
)

SELECT productCode, 
       SUM(quantityOrdered * priceEach) AS product_perf
  FROM orderdetails WHERE productCode IN (SELECT productCode
					FROM low_stock_table) GROUP BY productCode 
						ORDER BY product_perf DESC LIMIT 10;


/* Identifying what customers provide the most revenue */ 
						
SELECT orders.customerNumber, SUM(quantityOrdered*(priceEach - buyPrice)) AS revenue 
							FROM products JOIN orderdetails 
							 ON products.productCode = orderdetails.productCode
							JOIN orders ON orders.orderNumber = orderdetails.orderNumber
							 GROUP BY orders.customerNumber;

WITH
					
/* Top 5 most engaged customers */
revenue_by_customer AS (
SELECT orders.customerNumber, SUM(quantityOrdered*(priceEach - buyPrice)) AS revenue 
							FROM products JOIN orderdetails 
							 ON products.productCode = orderdetails.productCode
							JOIN orders ON orders.orderNumber = orderdetails.orderNumber
							 GROUP BY orders.customerNumber
							)
					
SELECT contactLastName, contactFirstName, city, country, rv.revenue
						FROM customers
						 JOIN revenue_by_customer rv
							ON rv.customerNumber = customers.customerNumber
						ORDER BY rv.revenue DESC LIMIT 5;

WITH

/* Top 5 least engaged customers */

revenue_by_customer AS (
SELECT orders.customerNumber, SUM(quantityOrdered*(priceEach - buyPrice)) AS revenue 
							FROM products JOIN orderdetails 
							 ON products.productCode = orderdetails.productCode
							JOIN orders ON orders.orderNumber = orderdetails.orderNumber
							 GROUP BY orders.customerNumber
							)

SELECT contactLastName, contactFirstName, city, country, rv.revenue
						FROM customers
						 JOIN revenue_by_customer rv
							ON rv.customerNumber = customers.customerNumber
						ORDER BY rv.revenue LIMIT 5;

WITH

/* Customer Lifetime Value (LTV) */

revenue_by_customer AS (
SELECT orders.customerNumber, SUM(quantityOrdered*(priceEach - buyPrice)) AS revenue 
							FROM products JOIN orderdetails 
							 ON products.productCode = orderdetails.productCode
							JOIN orders ON orders.orderNumber = orderdetails.orderNumber
							 GROUP BY orders.customerNumber
							)

SELECT AVG(rv.revenue) AS lifetime_val
			FROM revenue_by_customer rv;







