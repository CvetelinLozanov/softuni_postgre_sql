-- 01 Departments info

SELECT
	department_id,
	COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 02 Despartments info (by salary)

SELECT
	department_id,
	COUNT(salary) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 03 Sum salaries per department

SELECT
	department_id,
	SUM(salary) AS total_salaries
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 04 Maximum salary per department
SELECT
	department_id,
	MAX(salary)
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 05 Minimum salary per department

SELECT
	department_id,
	MIN(salary)
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 06 Average salary per department
SELECT
	department_id,
	AVG(salary)
FROM employees
GROUP BY department_id
ORDER BY department_id
;

-- 07 Filter total salaries
SELECT
	department_id,
	SUM(salary)
FROM
	employees
GROUP BY department_id
HAVING SUM(salary) < 4200
ORDER BY department_id;

-- 08 Department names

SELECT
	"id",
	first_name,
	last_name,
	ROUND(salary, 2),
	department_id,
	CASE department_id
		WHEN 1 THEN 'Management'
		WHEN 2 THEN 'Kitchen Staff'
		WHEN 3 THEN 'Service Staff'
		ELSE 'Other'
	END
FROM
	employees
;

