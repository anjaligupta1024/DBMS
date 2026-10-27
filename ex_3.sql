CREATE DATABASE IF NOT EXISTS CompanyDB;
USE CompanyDB;

DROP TABLE IF EXISTS Employee_Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL,
    Location VARCHAR(50)
);

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    Salary DECIMAL(10,2),
    DeptID INT,
    HireDate DATE,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Project (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    Budget DECIMAL(12,2),
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Employee_Project (
    EmpID INT,
    ProjectID INT,
    HoursWorked INT,
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

INSERT INTO Department VALUES
(1, 'IT', 'Delhi'),
(2, 'HR', 'Mumbai'),
(3, 'Finance', 'Bengaluru'),
(4, 'Marketing', 'Pune'),
(5, 'Research', 'Hyderabad');

INSERT INTO Employee VALUES
(101, 'Aarav Sharma', 'Male', 60000, 1, '2022-01-15'),
(102, 'Priya Verma', 'Female', 55000, 2, '2021-03-20'),
(103, 'Rahul Singh', 'Male', 75000, 1, '2020-06-10'),
(104, 'Ananya Gupta', 'Female', 65000, 3, '2022-08-12'),
(105, 'Rohan Mehta', 'Male', 45000, 4, '2023-02-18'),
(106, 'Sneha Kapoor', 'Female', 70000, 5, '2021-11-25'),
(107, 'Arjun Patel', 'Male', 50000, 1, '2023-04-05'),
(108, 'Neha Joshi', 'Female', 48000, 2, '2022-07-14'),
(109, 'Vikram Rao', 'Male', 80000, 3, '2019-09-30'),
(110, 'Pooja Mishra', 'Female', 52000, 4, '2023-01-11'),
(111, 'Karan Malhotra', 'Male', 90000, 1, '2018-05-22'),
(112, 'Isha Agarwal', 'Female', 62000, 5, '2022-10-19'),
(113, 'Aditya Kumar', 'Male', 58000, 2, '2021-12-01'),
(114, 'Meera Nair', 'Female', 67000, 3, '2020-02-17'),
(115, 'Sahil Khanna', 'Male', 42000, 4, '2023-06-09'),
(116, 'Kavya Reddy', 'Female', 72000, 5, '2021-04-27'),
(117, 'Aman Yadav', 'Male', 53000, 1, '2022-09-08'),
(118, 'Riya Das', 'Female', 49000, 2, '2023-03-16'),
(119, 'Manish Jain', 'Male', 85000, 3, '2019-07-21'),
(120, 'Simran Kaur', 'Female', 56000, 4, '2022-05-13'),
(121, 'Devansh Sinha', 'Male', 61000, 5, '2020-11-06'),
(122, 'Tanya Bose', 'Female', 68000, 1, '2021-08-29'),
(123, 'Nikhil Shah', 'Male', 47000, 2, '2023-07-02'),
(124, 'Aditi Chawla', 'Female', 74000, 3, '2020-10-15'),
(125, 'Yash Thakur', 'Male', 51000, 4, '2022-12-20'),
(126, 'Diya Menon', 'Female', 79000, 5, '2019-04-14'),
(127, 'Harsh Bansal', 'Male', 64000, 1, '2021-06-23'),
(128, 'Nisha Sethi', 'Female', 57000, 2, '2022-02-08'),
(129, 'Varun Pillai', 'Male', 88000, 3, '2018-12-11'),
(130, 'Sakshi Roy', 'Female', 46000, 4, '2023-08-04');

INSERT INTO Project VALUES
(201, 'Website Development', 500000, 1),
(202, 'Mobile Application', 750000, 1),
(203, 'Employee Recruitment', 200000, 2),
(204, 'Payroll Automation', 300000, 3),
(205, 'Digital Marketing', 400000, 4),
(206, 'AI Research', 900000, 5),
(207, 'Cloud Migration', 650000, 1),
(208, 'Financial Analysis', 350000, 3);

INSERT INTO Employee_Project VALUES
(101, 201, 120),
(101, 207, 40),
(102, 203, 100),
(103, 201, 150),
(103, 202, 60),
(104, 204, 100),
(105, 205, 80),
(106, 206, 140),
(107, 202, 110),
(108, 203, 90),
(109, 204, 160),
(110, 205, 100),
(111, 207, 130),
(112, 206, 120),
(113, 203, 70),
(114, 208, 140),
(115, 205, 60),
(116, 206, 150),
(117, 201, 90),
(118, 203, 110),
(119, 208, 170),
(120, 205, 100),
(121, 206, 80),
(122, 202, 130),
(123, 203, 75),
(124, 204, 125),
(125, 205, 90),
(126, 206, 160),
(127, 207, 100),
(128, 203, 85),
(129, 208, 150),
(130, 205, 70);

SELECT *
FROM Employee
WHERE Salary > 60000;

SELECT EmpName, Salary
FROM Employee;

SELECT
    COUNT(*) AS TotalEmployees,
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AverageSalary,
    MAX(Salary) AS HighestSalary,
    MIN(Salary) AS LowestSalary
FROM Employee;

SELECT
    d.DeptName,
    COUNT(e.EmpID) AS TotalEmployees,
    AVG(e.Salary) AS AverageSalary
FROM Department d
JOIN Employee e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName;

SELECT
    d.DeptName,
    AVG(e.Salary) AS AverageSalary
FROM Department d
JOIN Employee e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
HAVING AVG(e.Salary) > 60000;

SELECT
    EmpName,
    Salary,
    CASE
        WHEN Salary >= 80000 THEN 'High Salary'
        WHEN Salary >= 60000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS SalaryCategory
FROM Employee;

SELECT EmpName, Salary
FROM Employee
ORDER BY Salary DESC;

SELECT
    e.EmpName,
    d.DeptName,
    p.ProjectName,
    ep.HoursWorked
FROM Employee e
JOIN Department d ON e.DeptID = d.DeptID
JOIN Employee_Project ep ON e.EmpID = ep.EmpID
JOIN Project p ON ep.ProjectID = p.ProjectID
ORDER BY e.EmpName;

SELECT
    d.DeptName,
    COUNT(p.ProjectID) AS TotalProjects
FROM Department d
LEFT JOIN Project p ON d.DeptID = p.DeptID
GROUP BY d.DeptID, d.DeptName
ORDER BY TotalProjects DESC;

SELECT COUNT(*) AS TotalEmployees FROM Employee;

SELECT COUNT(*) AS TotalDepartments FROM Department;

SELECT COUNT(*) AS TotalProjects FROM Project;

SELECT COUNT(*) AS TotalAssignments FROM Employee_Project;