-- EXPERIMENT 6: Stored procedure and triggers
CREATE DATABASE IF NOT EXISTS HRProcedureLab;
USE HRProcedureLab;

DROP TRIGGER IF EXISTS trg_employee_salary_before_insert;
DROP TRIGGER IF EXISTS trg_employee_salary_before_update;
DROP TRIGGER IF EXISTS trg_employee_audit_after_update;
DROP PROCEDURE IF EXISTS transfer_employee;
DROP TABLE IF EXISTS EmployeeAudit;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100) NOT NULL,
    DeptID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE EmployeeAudit (
    AuditID BIGINT AUTO_INCREMENT PRIMARY KEY,
    EmpID INT NOT NULL,
    OldDeptID INT,
    NewDeptID INT,
    OldSalary DECIMAL(10,2),
    NewSalary DECIMAL(10,2),
    ChangedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Note VARCHAR(255)
);

INSERT INTO Department VALUES (1,'Engineering'),(2,'Finance'),(3,'Marketing');
INSERT INTO Employee VALUES
(1,'Aarav Sharma',1,75000),(2,'Diya Verma',2,68000),(3,'Kabir Singh',1,72000);

DELIMITER //
CREATE TRIGGER trg_employee_salary_before_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.Salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be negative';
    END IF;
END//

CREATE TRIGGER trg_employee_salary_before_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.Salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be negative';
    END IF;
END//

CREATE TRIGGER trg_employee_audit_after_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO EmployeeAudit
        (EmpID, OldDeptID, NewDeptID, OldSalary, NewSalary, Note)
    VALUES
        (OLD.EmpID, OLD.DeptID, NEW.DeptID, OLD.Salary, NEW.Salary,
         'Employee record updated');
END//

CREATE PROCEDURE transfer_employee(IN p_emp_id INT, IN p_new_dept_id INT)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO v_exists FROM Employee WHERE EmpID = p_emp_id;
    SELECT COUNT(*) INTO v_dept_exists FROM Department WHERE DeptID = p_new_dept_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;

    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Target department does not exist';
    END IF;

    START TRANSACTION;
    UPDATE Employee SET DeptID = p_new_dept_id WHERE EmpID = p_emp_id;
    COMMIT;
END//
DELIMITER ;

CALL transfer_employee(1,2);
SELECT * FROM Employee;
SELECT * FROM EmployeeAudit;

-- Edge-case tests (run separately; each should raise an error):
-- CALL transfer_employee(999,2); -- unknown employee
-- CALL transfer_employee(1,999); -- unknown department
-- UPDATE Employee SET Salary = -1 WHERE EmpID = 1; -- rejected by trigger
