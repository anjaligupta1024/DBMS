-- EXPERIMENT 4: Run after EXPERIMENT 3, or execute its schema/data section first.
USE CompanyLab;

-- INNER JOIN
SELECT e.EmpName, d.DeptName
FROM Employee e INNER JOIN Department d ON d.DeptID = e.DeptID;

-- LEFT JOIN: include employees even if they have no project assignment
SELECT e.EmpName, p.ProjectName
FROM Employee e
LEFT JOIN Employee_Project ep ON ep.EmpID = e.EmpID
LEFT JOIN Project p ON p.ProjectID = ep.ProjectID;

-- Self-join: employee and manager
SELECT e.EmpName AS Employee, m.EmpName AS Manager
FROM Employee e LEFT JOIN Employee m ON m.EmpID = e.ManagerID;

-- Three-way join
SELECT e.EmpName, d.DeptName, p.ProjectName
FROM Employee e
JOIN Department d ON d.DeptID = e.DeptID
JOIN Employee_Project ep ON ep.EmpID = e.EmpID
JOIN Project p ON p.ProjectID = ep.ProjectID;

-- Correlated subquery: employees paid above their own department average
SELECT e.EmpName, e.Salary, e.DeptID
FROM Employee e
WHERE e.Salary > (
    SELECT AVG(e2.Salary) FROM Employee e2 WHERE e2.DeptID = e.DeptID
);

-- EXISTS: employees assigned to at least one project
SELECT e.EmpName
FROM Employee e
WHERE EXISTS (SELECT 1 FROM Employee_Project ep WHERE ep.EmpID = e.EmpID);

-- NOT EXISTS: employees without project assignment
SELECT e.EmpName
FROM Employee e
WHERE NOT EXISTS (SELECT 1 FROM Employee_Project ep WHERE ep.EmpID = e.EmpID);

-- Simulated INTERSECT: departments with employees earning >= 60000
-- and departments located in Lucknow or Delhi
SELECT DeptID FROM Employee WHERE Salary >= 60000
AND DeptID IN (SELECT DeptID FROM Department WHERE Location IN ('Lucknow','Delhi'))
GROUP BY DeptID;

-- Simulated EXCEPT: all employees minus employees assigned to projects
SELECT e.EmpID, e.EmpName
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1 FROM Employee_Project ep WHERE ep.EmpID = e.EmpID
);

-- Compare plans for a filter before and after indexing
EXPLAIN SELECT EmpID, EmpName FROM Employee WHERE DeptID = 1;
CREATE INDEX idx_employee_dept_salary ON Employee(DeptID, Salary);
EXPLAIN SELECT EmpID, EmpName FROM Employee WHERE DeptID = 1 AND Salary > 60000;

-- Additional join plan
EXPLAIN
SELECT e.EmpName, d.DeptName
FROM Employee e JOIN Department d ON d.DeptID = e.DeptID
WHERE d.Location = 'Lucknow';
