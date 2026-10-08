CREATE DATABASE Emplys;

USE emplys;
CREATE TABLE Employees (EmpName VARCHAR(20), 
EmpID INT AUTO_INCREMENT PRIMARY KEY, 
Department VARCHAR(30), 
Salory INT, 
Hire_date date);

INSERT INTO Employees (EmpName, Department, Salory, Hire_date) VALUES
('Alice','Sales', 10000, '2003-05-12'),
('BOb', 'Marketing', 14000, '2025-06-20'),
('John', 'IT', 20000, '2000-03-10'),
('Robert', 'HR', 25000, '2000-04-23'),
('Ram', 'HR', 22000, '2002-04-23'),
('Ramesh', 'IT', 21000, '2002-08-03');
# Retrieve all records from a table named Employees. 

DROP TABLE Employees;

UPDATE Employees SET manager = 'Kunal'   WHERE EmpName = 'Alice';
UPDATE Employees SET manager = 'Kishore' WHERE EmpName = 'Bob';
UPDATE Employees SET manager = 'Vaibhav' WHERE EmpName = 'John';
UPDATE Employees SET manager = 'Ram'     WHERE EmpName = 'Robert';

SET sql_safe_updates= 0;
UPDATE Employees 
SET Department= 'IT' where EmpName='BOb';

SET sql_safe_updates= 0;
DELETE FROM Employees where EmpName IS NULL OR manager IS NULL;

# Retrieve all records from a table named Employees. 
SELECT * FROM Employees;
SHOW TABLE Employees;

# Get the distinct departments from the Employees table. 
SELECT COUNT(distinct Department) FROM Employees;

# Count the total number of employees in the Employees table.
SELECT COUNT(EmpName) FROM Employees;

# Retrieve all employees whose salary is greater than 50,000.
SELECT EmpName FROM Employees where Salory>15000;

# List names of employees whose name starts with 'A'. 
SELECT * FROM Employees where EmpName LIKE 'A%';

# Fetch the top 5 highest-paid employees. 

# Retrieve employees who do not have a manager (i.e., NULL in manager_id).
SELECT * FROM Employees where manager = NULL;

# Show all columns from Employees where hire_date is in 2000. 
SELECT * FROM Employees where Hire_date LIKE '2000%';

#Fetch records where department_id is either 10, 20, or 30. 
SELECT * FROM Employees where EmpID LIKE '1' OR EmpID LIKE '2' OR EmpID LIKE '3';

# Get the total salary paid to all employees. 
SELECT SUM(Salory) FROM Employees;

# Fetch employee names along with their department names (use Employees and Departments tables). 
SELECT EmpName, Department FROM Employees;

#  List all employees and their manager names. 
SELECT EmpName ,manager FROM Employees;

# Show employees who work in the same department as 'John'. 
SELECT EmpName FROM Employees where Department IN 
(SELECT Department FROM Employees where EmpName='John');

#  Get a list of employees and their project names using a many-to-many relationship (via EmployeeProjects table). 
CREATE TABLE Employeeproject ( 
EmpID INT AUTO_INCREMENT PRIMARY KEY, 
projects VARCHAR(30));

INSERT INTO Employeeproject (projects) VALUES
('Ford'),
('TATA'),
('Volkswagen'),
('cariad'); 

SELECT * FROM Employeeproject;

SELECT Em.EmpName, Ep.projects FROM Employees Em LEFT JOIN Employeeproject Ep ON Em.EmpID=Ep.EmpID
UNION
SELECT Em.EmpName, Ep.projects FROM Employees Em RIGHT JOIN Employeeproject Ep ON Em.EmpID=Ep.EmpID
WHERE Ep.projects IS NULL

# Write a query to display employees with no assigned project.--> 85th line
