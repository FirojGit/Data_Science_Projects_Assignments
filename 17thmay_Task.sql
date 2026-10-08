#The customers table contains columns: customer_id, customer_name, age, and 
#region. Write a query to categorize customers into age groups: 
#• "Teen" if age < 18 
#• "Young Adult" if age between 18 and 35 
#• "Adult" if age between 36 and 60 
#• "Senior" if age > 60.

CREATE DATABASE DB2;

CREATE TABLE customers(customer_id INT AUTO_INCREMENT PRIMARY KEY,
customer_name VARCHAR(20), age INT, region VARCHAR(20),
no_of_orders INT, Order_amount INT);

INSERT INTO customers (customer_name , age, region, no_of_orders, Order_amount) VALUES 
('Alisha', 30, 'india', 23, 12000), ('Anand', 25, 'USA', 10, 15000), ('Bobu',28, 'Westasia', 8, 11000), 
('george',28, 'africa', 6, 8000), ('rober',29, 'Westafrica', 25, 30000);

DROP TABLE customers;

SELECT * FROM customers ;

SELECT customer_id, customer_name, age, region,
CASE
   WHEN age<18 THEN "Teen"
   WHEN age BETWEEN 18 and 35 THEN "Young Adult"
   WHEN age BETWEEN 36 and 60 THEN "Adult" 
   WHEN age >60 THEN "Senior"
END AS Age_group 
FROM customers;

 #In the employees table, classify employees into salary bands using a CASE statement: 
#• "Low" for salaries < 30000 
#• "Medium" for salaries between 30000 and 70000 
#• "High" for salaries > 70000.

SELECT EmpName, Salory, 
CASE 
  WHEN Salory < 11000 THEN "LOW"
  WHEN Salory BETWEEN 12000 and 20000 THEN "Medium"
  WHEN Salory > 20000 THEN "High"
END AS salary_bands 
FROM Employees;

# In the students table, write a query to assign a RANK to each student within their class 
# based on their total_score, with the highest score ranked first. 
CREATE TABLE students (stdnt_name VARCHAR(20), age INT, total_score INT);

INSERT INTO students (stdnt_name , age, total_score) VALUES 
('Aleena', 13, 94), ('Anandaa', 15, 90), ('Babu',16, 90), 
('Geogeorge',17, 98), ('robert', 14, 82);

DROP TABLE students;

SELECT * FROM students ;

SELECT stdnt_name , total_score, 
RANK() OVER (ORDER BY total_score DESC) AS Student_rank
FROM students;


# Using the departments table, calculate the average salary for each department and 
# find the difference between each employee’s salary and the department average. 
SELECT EmpName, Department, Salory, 
AVG(Salory) OVER (PARTITION BY Department) AS avg_salory, 
Salory-avg(Salory) OVER (PARTITION BY Department) AS Salory_diff 
FROM Employees;

# Write a query to count the number of orders where the order_amount exceeds the 
# average order_amount across all orders. 
SELECT COUNT(no_of_orders) AS orders_exceed_avg
FROM customers 
WHERE order_amount > (SELECT AVG(order_amount) FROM customers);

# In the sales table, calculate the percentage contribution of each sale_amount to the 
# total sales for its product_id.
SELECT customer_id, Order_amount, 
ROUND((Order_amount * 100.0 / SUM(Order_amount) OVER (ORDER BY customer_id)) , 2) 
AS Percent_contribution
FROM customers;

#  Using the students table, write a query to find students whose scores are above the class average. 
SELECT stdnt_name
FROM students 
WHERE total_score > (SELECT AVG(total_score) FROM students);

# In the employees table, identify employees who earn more than the average salary in their department. 
SELECT EmpName, Salory,
CASE
WHEN Salory > AVG(Salory) OVER (PARTITION BY Department) THEN 'Above Avg' ELSE 'Below Avg'
END AS Avg_Salory
FROM Employees;

# Using the products table, write a query to replace all NULL values in the price column 
# with the average price of all products.
SET sql_safe_updates =0;
UPDATE products 
SET price = (SELECT AVG(price) FROM products)
WHERE price IS NULL;

# Using the sales table, calculate the cumulative sales for each product_id and classify 
# the sales performance into categories: 
#• "Underperforming" if cumulative sales < 5000 
#• "Meeting Expectations" if cumulative sales between 5000 and 10000 
#• "Exceeding Expectations" if cumulative sales > 10000.
SELECT customer_name, Order_amount,
CASE
WHEN SUM(Order_amount) OVER (PARTITION BY customer_id)<5000 THEN 'Underperforming'
WHEN SUM(Order_amount) OVER (PARTITION BY customer_id) BETWEEN 5000 and 10000 THEN 'Meeting Expectations'
WHEN SUM(Order_amount) OVER (PARTITION BY customer_id) > 10000 THEN 'Exceed Expectation'
END AS Sales_performance
FROM customers;
















