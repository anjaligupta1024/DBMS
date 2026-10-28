# LAB 6: Stored Procedure, Triggers, and Audit Logging

## Aim
Create transfer_employee(emp_id, new_dept_id) with validation and error handling, salary validation triggers, and audit logging.

## Software / Requirements
- MySQL 8.0 or later
- MySQL Workbench or VS Code with a configured MySQL connection

## Files
- `experiment1.sql` — SQL statements for this experiment
- `output.png` — placeholder to replace with an actual execution screenshot

## Procedure
1. Open `experiment1.sql` in MySQL Workbench.
2. Read the comments and identify sections that are intended to be run separately.
3. Execute the SQL statements in order. For stored procedures/triggers, execute the full delimiter block.
4. Inspect the result grids and, where applicable, the `EXPLAIN` output.
5. Capture the actual results from your MySQL client and replace `output.png`.

## Expected result
The script demonstrates the concepts described in the aim. Exact rows, execution plans, and timings depend on the database state, MySQL version, and machine.

## Important notes
- This repository is prepared from the practicals in the supplied DBMS curriculum.
- Some tests are intentionally commented out because they should produce errors or modify data. Uncomment and run them separately only when you understand the effect.
- For Experiments 4 and 5, the scripts use the `CompanyLab` database created by Experiment 3. Run Experiment 3 first, or execute the relevant schema/data setup before running them.
- For Experiments 9 and 10, MySQL 8.0+ is required for recursive CTE-based row generation.
- `output.png` is currently a labelled placeholder, not a genuine SQL execution screenshot.
