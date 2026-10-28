-- EXPERIMENT: SQL VIEWS AND RECURSIVE CTE

-- 1. DEPARTMENT SALARY SUMMARY VIEW
CREATE OR REPLACE VIEW DepartmentSalarySummary AS
SELECT
    d.DeptID,
    d.DeptName,
    COUNT(e.EmpID) AS TotalEmployees,
    AVG(e.Salary) AS AverageSalary,
    MIN(e.Salary) AS MinimumSalary,
    MAX(e.Salary) AS MaximumSalary,
    SUM(e.Salary) AS TotalSalary
FROM Department d
LEFT JOIN Employee e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName;

-- DISPLAY DEPARTMENT SALARY SUMMARY
SELECT * FROM DepartmentSalarySummary;

-- 2. EMPLOYEE HIERARCHY VIEW
CREATE OR REPLACE VIEW EmployeeHierarchy AS
SELECT
    e.EmpID,
    e.EmpName AS EmployeeName,
    e.ManagerID,
    m.EmpName AS ManagerName,
    e.DeptID,
    e.Salary
FROM Employee e
LEFT JOIN Employee m ON e.ManagerID = m.EmpID;

-- DISPLAY EMPLOYEE HIERARCHY
SELECT * FROM EmployeeHierarchy
ORDER BY ManagerID, EmpID;

-- 3. TEST UPDATABILITY OF VIEWS

-- A. SIMPLE VIEW
CREATE OR REPLACE VIEW EmployeeBasicView AS
SELECT EmpID, EmpName, DeptID, Salary
FROM Employee;

-- DISPLAY SIMPLE VIEW
SELECT * FROM EmployeeBasicView;

-- UPDATE THROUGH SIMPLE VIEW
UPDATE EmployeeBasicView
SET Salary = Salary + 1000
WHERE EmpID = 9;

-- VERIFY THE UPDATE
SELECT EmpID, EmpName, Salary
FROM Employee
WHERE EmpID = 9;

-- B. TEST UPDATABILITY OF AGGREGATE VIEW
-- Aggregate views containing GROUP BY and aggregate functions
-- are generally not directly updatable.
SELECT * FROM DepartmentSalarySummary;

-- C. TEST UPDATABILITY OF JOIN VIEW
-- This view uses a join and is not reliably updatable.
SELECT * FROM EmployeeHierarchy;

-- 4. RECURSIVE CTE TO DISPLAY REPORTING CHAINS
WITH RECURSIVE ReportingChain AS (
    -- Anchor: employees who have no manager
    SELECT
        EmpID,
        EmpName,
        ManagerID,
        0 AS ReportingLevel,
        CAST(EmpName AS CHAR(1000)) AS ReportingPath
    FROM Employee
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive member: employees reporting to the previous level
    SELECT
        e.EmpID,
        e.EmpName,
        e.ManagerID,
        rc.ReportingLevel + 1,
        CAST(
            CONCAT(rc.ReportingPath, ' -> ', e.EmpName)
            AS CHAR(1000)
        ) AS ReportingPath
    FROM Employee e
    JOIN ReportingChain rc ON e.ManagerID = rc.EmpID
)
SELECT
    EmpID,
    EmpName,
    ManagerID,
    ReportingLevel,
    ReportingPath
FROM ReportingChain
ORDER BY ReportingPath;

-- 5. DISPLAY REPORTING CHAIN FOR EACH EMPLOYEE
WITH RECURSIVE ReportingChain AS (
    SELECT
        EmpID,
        EmpName,
        ManagerID,
        0 AS ReportingLevel,
        CAST(EmpName AS CHAR(1000)) AS ReportingPath
    FROM Employee
    WHERE ManagerID IS NULL

    UNION ALL

    SELECT
        e.EmpID,
        e.EmpName,
        e.ManagerID,
        rc.ReportingLevel + 1,
        CAST(
            CONCAT(rc.ReportingPath, ' -> ', e.EmpName)
            AS CHAR(1000)
        )
    FROM Employee e
    JOIN ReportingChain rc ON e.ManagerID = rc.EmpID
)
SELECT
    EmpName,
    ReportingLevel,
    ReportingPath
FROM ReportingChain
ORDER BY EmpID;

-- 6. VERIFY ALL VIEWS
SHOW FULL TABLES WHERE Table_type = 'VIEW';