# DBMS Lab Experiments

This repository contains the 10 practical experiments listed in the uploaded *Database Management Systems* curriculum.

## Requirements
- MySQL 8.0 or later (recommended for CTEs and window/recursive-query features)
- MySQL Workbench or a configured MySQL extension in VS Code
- Git and GitHub (optional, for version control)

## Folder structure
Each lab folder contains:
- `experiment1.sql` — SQL script for the experiment
- `output.png` — placeholder image; replace it with your own screenshot after executing the SQL in MySQL
- `README.md` — aim, requirements, procedure, and result notes

## Experiments
1. E-commerce ER model and entity/relationship specification
2. Convert the e-commerce model to relational tables and demonstrate integrity constraints
3. Employee–Department–Project schema, sample data, and SQL query demonstrations
4. Joins, subqueries, set-operation simulations, and EXPLAIN
5. Views, view updatability, and recursive employee hierarchy
6. Stored procedure, validation triggers, and audit logging
7. Functional dependencies and normalization from UNF through 3NF/BCNF
8. Banking transactions, savepoints, rollback, and isolation-level demonstration
9. Railway booking dataset with at least 5,000 rows and index benchmarking
10. Dataset with at least 10,000 rows, slow-query examples, EXPLAIN, and optimization

## How to run
1. Open a lab's `experiment1.sql` in MySQL Workbench.
2. Read the script before executing it. Scripts may create/drop experiment-specific databases or tables.
3. Execute the script in sections when it contains intentional error demonstrations, transactions, or stored-program definitions.
4. Review result grids and EXPLAIN output.
5. Capture your actual MySQL output and replace that lab's `output.png`.

> The included `output.png` files are clearly labelled placeholders, not screenshots of executed MySQL results. You must replace them with real screenshots from your environment before submitting.

## Notes
- Scripts are written for MySQL 8.0+.
- Some experiments intentionally demonstrate invalid operations or transaction behavior. Run them section by section and read the comments.
- The exact execution time and EXPLAIN plan depend on your MySQL version, data, and machine.
