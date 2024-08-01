-- 01 COUNT of records

SELECT
	COUNT(*)
FROM
	wizard_deposits;

-- 02 Total deposit amount

SELECT
	SUM(deposit_amount) AS total_amount
FROM
	wizard_deposits;

-- 03 AVG Magic wand size

SELECT
	ROUND(AVG(magic_wand_size), 3) AS average_magic_wand_size
FROM wizard_deposits;

-- 04 Min deposit charge

SELECT
	MIN(deposit_charge) AS minimum_deposit_charge
FROM wizard_deposits;

-- 05 MAX age

SELECT
	MAX(age)
FROM wizard_deposits;

-- 06 GROUP BY deposit interest
SELECT
	deposit_group,
	SUM(deposit_interest)
FROM wizard_deposits
GROUP BY deposit_group
ORDER BY SUM(deposit_interest) DESC
LIMIT 5;

-- 07 LIMIT the Magic Wand Creator
SELECT
	magic_wand_creator,
	MIN(magic_wand_size) AS minimum_wand_size
FROM wizard_deposits
GROUP BY magic_wand_creator
ORDER BY minimum_wand_size
LIMIT 5;

-- 08 Bank Profability
SELECT
	deposit_group,
	is_deposit_expired,
	TRUNC(AVG(deposit_interest))
FROM wizard_deposits
WHERE deposit_start_date > '1985-01-01'
GROUP BY deposit_group, is_deposit_expired
ORDER BY deposit_group DESC, is_deposit_expired;

-- 09 Notes with Dumbledore
SELECT
	last_name,
	COUNT(notes)
FROM wizard_deposits
WHERE notes LIKE '%Dumbledore%'
GROUP BY last_name
;

-- 10 Wizard view
CREATE OR REPLACE VIEW view_wizard_deposits_with_expiration_date_before_1983_08_17 
	AS 
SELECT
	CONCAT_WS(' ', first_name, last_name) AS wizard_name,
	deposit_start_date AS start_date,
	deposit_expiration_date AS expiration_date,
	deposit_amount AS amount
FROM wizard_deposits
WHERE deposit_expiration_date <= '1983-08-17'
GROUP BY wizard_name, deposit_start_date, deposit_expiration_date, deposit_amount
ORDER BY deposit_expiration_date;

-- 11 Filter Max Deposit

SELECT
	magic_wand_creator,
	MAX(deposit_amount) as max_deposit_amount
FROM wizard_deposits
GROUP BY magic_wand_creator
HAVING MAX(deposit_amount) < 20000 OR MAX(deposit_amount) > 40000
ORDER BY max_deposit_amount DESC
LIMIT 3;

-- 12 Age group

SELECT
	CASE
		WHEN age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
		ELSE '[61+]'
	END AS age_group,
	COUNT(age)
FROM wizard_deposits
GROUP BY age_group
ORDER BY age_group;

-- 13 SUM the employees

SELECT
	COUNT(CASE department_id WHEN 1 THEN 1 ELSE NULL END) AS "Engineering",
	COUNT(CASE department_id WHEN 2 THEN 1 ELSE NULL END) AS "Tool Design",
	COUNT(CASE department_id WHEN 3 THEN 1 ELSE NULL END) AS "Sales",
	COUNT(CASE department_id WHEN 4 THEN 1 ELSE NULL END) AS "Marketing",
	COUNT(CASE department_id WHEN 5 THEN 1 ELSE NULL END) AS "Purchasing",
	COUNT(CASE department_id WHEN 6 THEN 1 ELSE NULL END) AS "Research and Development",
	COUNT(CASE department_id WHEN 7 THEN 1 ELSE NULL END) AS "Production"
FROM employees;

-- 14 Update employees data
UPDATE employees
	SET salary = 
		CASE
			WHEN hire_date < '2015-01-16' THEN salary + 2500
			WHEN hire_date < '2020-03-04' THEN salary + 1500
			ELSE salary
		END,
		job_title =
		CASE
			WHEN hire_date < '2015-01-16' THEN CONCAT('Senior ', job_title)
			WHEN hire_date < '2020-03-04' THEN CONCAT('Mid-', job_title)
			ELSE job_title
		END
		;

-- 15 Categorizes Salary

SELECT
	job_title,
	CASE
		WHEN AVG(salary) > 45800 THEN 'Good'
		WHEN AVG(salary) BETWEEN 27500 AND 45800 THEN 'Medium'
		WHEN AVG(salary) < 27500 THEN 'Need Improvement'
	END AS category
FROM employees
GROUP BY job_title
ORDER BY category, job_title;

-- 16 Where project status
SELECT
	project_name,
	CASE
		WHEN start_date IS NULL AND end_date IS NULL THEN 'Ready for development'
		WHEN start_date IS NOT NULL AND end_date IS NULL THEN 'In Progress'
		ELSE 'Done'
	END AS project_status
FROM projects
WHERE project_name LIKE '%Mountain%';

-- 17 HAVING Salary level

SELECT
	department_id,
	COUNT(*) AS num_employees,
	CASE
		WHEN AVG(salary) > 50000 THEN 'Above average'
		WHEN AVG(salary) <= 50000 THEN 'Below average'
	END
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 30000
ORDER BY department_id;

-- 18 Nested CASE conditions
CREATE OR REPLACE VIEW view_performance_rating 
	AS 
SELECT
	first_name,
	last_name,
	job_title,
	salary,
	department_id,
	CASE
		WHEN salary >= 25000 AND job_title LIKE 'Senior%' THEN 'High-performing Senior'
		WHEN salary >= 25000 AND job_title NOT LIKE 'Senior%' THEN 'High-performing Employee'
		ELSE 'Average-performing'
	END AS performance_raiting
FROM employees;

CREATE OR REPLACE VIEW view_performance_rating 
	AS 
SELECT
	first_name,
	last_name,
	job_title,
	salary,
	department_id,
	CASE
		WHEN salary >= 25000 THEN
			CASE
				WHEN job_title LIKE 'Senior%' THEN 'High-performing Senior'
				ELSE 'High-performing Employee'				
			END
		ELSE 'Average-performing'
	END AS performance_raiting
FROM employees;

-- 19 Foreign Key

CREATE TABLE employees_projects(
	id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees(id),
	project_id INT REFERENCES projects(id)
)

-- 20 Join tables
SELECT
	*
FROM departments d
JOIN employees e
	ON d.id = e.department_id;
