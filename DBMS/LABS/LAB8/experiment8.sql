-- EXPERIMENT 8: Banking transactions
CREATE DATABASE IF NOT EXISTS BankingTransactionLab;
USE BankingTransactionLab;

DROP TABLE IF EXISTS Account;
CREATE TABLE Account (
    AccountID INT PRIMARY KEY,
    HolderName VARCHAR(100) NOT NULL,
    Balance DECIMAL(12,2) NOT NULL CHECK (Balance >= 0)
) ENGINE=InnoDB;

INSERT INTO Account VALUES
(101,'Aarav Sharma',10000.00),
(102,'Diya Verma',7000.00),
(103,'Kabir Singh',5000.00);

SELECT * FROM Account;

-- Successful transfer: transfer 1,000 from account 101 to 102.
START TRANSACTION;
UPDATE Account SET Balance = Balance - 1000 WHERE AccountID = 101 AND Balance >= 1000;
UPDATE Account SET Balance = Balance + 1000 WHERE AccountID = 102;
COMMIT;
SELECT * FROM Account;

-- SAVEPOINT example: the first change is retained, the second is rolled back.
START TRANSACTION;
UPDATE Account SET Balance = Balance - 500 WHERE AccountID = 101 AND Balance >= 500;
SAVEPOINT after_debit;
UPDATE Account SET Balance = Balance + 500 WHERE AccountID = 999;
ROLLBACK TO SAVEPOINT after_debit;
-- Return the debit too, so balances remain unchanged for this demonstration.
ROLLBACK;
SELECT * FROM Account;

-- Full rollback example
START TRANSACTION;
UPDATE Account SET Balance = Balance - 200 WHERE AccountID = 103 AND Balance >= 200;
ROLLBACK;
SELECT * FROM Account;

-- Isolation-level setting for the current session:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation AS CurrentIsolationLevel;

-- Two-session concurrency demonstration (manual):
-- Session A:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT Balance FROM Account WHERE AccountID = 101;
-- Wait while Session B updates and commits the same row, then run SELECT again.
-- COMMIT;
--
-- Session B:
-- START TRANSACTION;
-- UPDATE Account SET Balance = Balance + 100 WHERE AccountID = 101;
-- COMMIT;
--
-- Repeat using REPEATABLE READ to observe the behavior difference.
-- Run sessions separately; a single script cannot pause reliably between sessions.
