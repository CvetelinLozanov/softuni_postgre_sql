-- 01 select and display info
SELECT
	"id",
	concat(first_name, ' ', last_name) AS "Full Name",
	job_title as "Job Title"
FROM employees
;

-- 02 select employees by filtering and ordering
SELECT
	"id",
	concat(first_name, ' ', last_name) AS "Full Name",
	job_title,
	salary
FROM employees
WHERE salary > 1000
;

-- 03 select employees by multiple filters
SELECT
	*
FROM employees
WHERE salary >= 1000 AND department_id = 4

-- 04 Insert data into employees table
INSERT INTO employees(first_name, last_name, job_title, department_id, salary)
VALUES
	('Samantha', 'Young', 'Housekeeping', 4, 900),
	('Roger', 'Palmer', 'Waiter', 3, 928.33)
;

SELECT
	*
FROM employees
;

-- 05 Update employees salary
UPDATE employees
SET salary = salary + 100
WHERE job_title = 'Manager'
;

SELECT
	*
FROM employees
WHERE job_title = 'Manager'
;

-- 06 Delete from table
DELETE FROM employees
WHERE department_id IN (1, 2)
;

SELECT
	*
FROM employees
;

-- 07 Create view for top paid employee
CREATE VIEW top_paid_employee_view AS
SELECT
	*
FROM employees
ORDER BY salary DESC
LIMIT (1)
;

SELECT
	*
FROM top_paid_employee_view
;
