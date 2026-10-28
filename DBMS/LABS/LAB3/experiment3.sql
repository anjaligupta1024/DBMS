-- EXPERIMENT 3: Employee-Department-Project schema
CREATE DATABASE IF NOT EXISTS CompanyLab;
USE CompanyLab;

DROP TABLE IF EXISTS Employee_Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL UNIQUE,
    Location VARCHAR(50)
);

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100) NOT NULL,
    DeptID INT NOT NULL,
    ManagerID INT NULL,
    Salary DECIMAL(10,2) NOT NULL CHECK (Salary >= 0),
    HireDate DATE NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (ManagerID) REFERENCES Employee(EmpID) ON DELETE SET NULL
);

CREATE TABLE Project (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    Budget DECIMAL(12,2) NOT NULL CHECK (Budget >= 0)
);

CREATE TABLE Employee_Project (
    EmpID INT NOT NULL,
    ProjectID INT NOT NULL,
    HoursPerWeek INT NOT NULL DEFAULT 0 CHECK (HoursPerWeek BETWEEN 0 AND 80),
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID) ON DELETE CASCADE,
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID) ON DELETE CASCADE
);

INSERT INTO Department VALUES
(1,'Engineering','Lucknow'),(2,'Human Resources','Kanpur'),
(3,'Finance','Noida'),(4,'Marketing','Delhi'),(5,'Operations','Agra');

INSERT INTO Employee (EmpID,EmpName,DeptID,ManagerID,Salary,HireDate) VALUES
(1,'Aarav Sharma',1,NULL,95000,'2021-02-10'),
(2,'Diya Verma',2,NULL,72000,'2021-04-12'),
(3,'Kabir Singh',3,NULL,88000,'2020-06-01'),
(4,'Ananya Gupta',4,NULL,81000,'2022-01-15'),
(5,'Ishaan Patel',5,NULL,76000,'2022-03-20'),
(6,'Meera Joshi',1,1,65000,'2022-05-11'),
(7,'Rohan Yadav',1,1,61000,'2023-01-09'),
(8,'Sana Khan',1,1,68000,'2022-09-17'),
(9,'Vivaan Das',1,6,54000,'2023-07-03'),
(10,'Aditi Rao',1,6,57000,'2024-02-14'),
(11,'Arjun Mehta',2,2,52000,'2023-03-01'),
(12,'Myra Jain',2,2,56000,'2022-12-05'),
(13,'Reyansh Roy',2,11,48000,'2024-01-08'),
(14,'Kiara Mishra',2,11,51000,'2023-08-22'),
(15,'Advik Sinha',2,12,49000,'2024-04-10'),
(16,'Pari Kapoor',3,3,64000,'2022-07-19'),
(17,'Atharv Malhotra',3,3,59000,'2023-05-27'),
(18,'Ira Chawla',3,16,55000,'2024-06-12'),
(19,'Krish Bansal',3,16,53000,'2023-11-16'),
(20,'Navya Saxena',3,17,58000,'2022-10-30'),
(21,'Dhruv Arora',4,4,62000,'2022-02-07'),
(22,'Anvi Tiwari',4,4,60000,'2023-04-18'),
(23,'Yuvaan Gill',4,21,50000,'2024-03-21'),
(24,'Aarohi Dubey',4,21,52000,'2023-09-13'),
(25,'Sai Khanna',4,22,49000,'2024-05-06'),
(26,'Shanaya Bose',5,5,61000,'2022-06-23'),
(27,'Rudra Nair',5,5,57000,'2023-02-28'),
(28,'Aanya Menon',5,26,53000,'2024-07-01'),
(29,'Vihaan Reddy',5,26,55000,'2023-10-11'),
(30,'Prisha Ghosh',5,27,51000,'2024-08-15');

INSERT INTO Project VALUES
(1,'Inventory System',250000),(2,'Mobile App',400000),
(3,'Payroll Upgrade',180000),(4,'Customer Portal',320000),
(5,'Data Warehouse',500000),(6,'Security Audit',150000),
(7,'Marketing Analytics',220000),(8,'Cloud Migration',600000);

INSERT INTO Employee_Project VALUES
(1,2,8),(6,2,12),(7,8,10),(8,5,8),(9,1,10),(10,8,8),
(2,3,8),(11,3,12),(12,4,6),(13,3,8),(14,6,4),(15,4,8),
(3,5,10),(16,5,12),(17,1,8),(18,5,10),(19,6,6),(20,1,8),
(4,4,8),(21,7,10),(22,7,8),(23,4,8),(24,7,6),(25,2,4),
(5,1,8),(26,8,10),(27,1,8),(28,8,8),(29,6,6),(30,1,8);

-- Selection
SELECT * FROM Employee WHERE Salary > 60000;

-- Projection
SELECT EmpName, Salary FROM Employee;

-- Aggregate functions
SELECT COUNT(*) AS TotalEmployees, AVG(Salary) AS AverageSalary,
       MIN(Salary) AS MinimumSalary, MAX(Salary) AS MaximumSalary
FROM Employee;

-- GROUP BY
SELECT d.DeptName, COUNT(*) AS EmployeeCount, AVG(e.Salary) AS AvgSalary
FROM Employee e JOIN Department d ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName;

-- HAVING
SELECT d.DeptName, AVG(e.Salary) AS AvgSalary
FROM Employee e JOIN Department d ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
HAVING AVG(e.Salary) > 60000;

-- CASE expression
SELECT EmpName, Salary,
       CASE WHEN Salary >= 80000 THEN 'High'
            WHEN Salary >= 60000 THEN 'Medium'
            ELSE 'Entry' END AS SalaryBand
FROM Employee;

-- ORDER BY
SELECT EmpName, Salary FROM Employee ORDER BY Salary DESC, EmpName ASC;

-- Multi-table join and project assignment summary
SELECT e.EmpName, d.DeptName, p.ProjectName, ep.HoursPerWeek
FROM Employee e
JOIN Department d ON d.DeptID = e.DeptID
JOIN Employee_Project ep ON ep.EmpID = e.EmpID
JOIN Project p ON p.ProjectID = ep.ProjectID
ORDER BY d.DeptName, e.EmpName;
