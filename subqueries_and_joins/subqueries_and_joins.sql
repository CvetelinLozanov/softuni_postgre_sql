-- 01 Town Adresses
SELECT
	t.town_id,
	t.name,
	a.address_text
FROM towns AS t
JOIN addresses AS a
	USING(town_id)
WHERE
	t.name IN (
		'Sofia',
		'San Francisco',
		'Carnation'
	)
ORDER BY t.town_id, a.address_text;

-- 02 Managers
SELECT
	e.employee_id,
	CONCAT(e.first_name, ' ', e.last_name) AS full_name,
	d.department_id,
	d.name
FROM 
	employees AS e
JOIN
	departments AS d
ON
	e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT (5);

-- 03 Employee's project
SELECT
	e.employee_id,
	CONCAT(e.first_name, ' ', e.last_name) AS full_name,
	p.project_id,
	p.name
FROM
	employees AS e
JOIN
	employees_projects AS ep
		ON e.employee_id = ep.employee_id
JOIN projects AS p
	ON p.project_id = ep.project_id
WHERE 
	p.project_id = 1

-- 04 Higher Salary
SELECT
	COUNT(*)
FROM 
	employees AS e
WHERE e.salary > (
	SELECT
		AVG(salary)
	FROM employees
);
