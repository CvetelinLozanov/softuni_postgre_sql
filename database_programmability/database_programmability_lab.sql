-- 01 Count employees by Town

CREATE OR REPLACE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT AS
$$	
	DECLARE
		emp_count INT;
	BEGIN
		SELECT
			COUNT(*) INTO emp_count
		FROM
			employees AS e
		JOIN
			addresses AS a
		USING
			(address_id)
		JOIN
			towns AS t
		USING
			(town_id)
		WHERE t."name" = town_name;

		RETURN emp_count;
	END;
$$
LANGUAGE plpgsql;

SELECT fn_count_employees_by_town('Sofia');


-- 02 Employees Promotion

CREATE OR REPLACE PROCEDURE sp_increase_salaries(department_name VARCHAR(40))
	AS
$$
	BEGIN
		UPDATE
			employees
		SET
			salary = salary * 1.05
		WHERE
			department_id = (SELECT department_id FROM departments WHERE "name" = department_name);
	END;
$$
LANGUAGE plpgsql;

CALL sp_increase_salaries('Finance');

SELECT
	*
FROM
	employees
WHERE
	department_id = (SELECT department_id FROM departments WHERE "name" = 'Finance')
ORDER BY
	first_name, salary;

-- 03 Employees promotion id
	
CREATE OR REPLACE PROCEDURE sp_increase_salary_by_id("id" INT)
AS
$$
	BEGIN
		IF (SELECT salary FROM employees WHERE employee_id = id) IS NULL THEN
			RETURN;
		END IF;	

		UPDATE 
			employees
		SET
			salary = salary * 1.05
		WHERE
			employee_id = "id";
		COMMIT;
	END;
$$
LANGUAGE plpgsql;

CALL sp_increase_salary_by_id(17);

SELECT
	*
FROM
	employees
WHERE
	employee_id = 17;

-- 04 Triggered

CREATE TABLE deleted_employees(
		employee_id SERIAL PRIMARY KEY,
		first_name VARCHAR(20),
		last_name VARCHAR(20),
		middle_name VARCHAR(20),
		job_title VARCHAR(50),
		department_id INT,
		salary NUMERIC(19,4)
	);

CREATE OR REPLACE FUNCTION backup_fired_employees()
RETURNS TRIGGER
AS
$$
	BEGIN
		INSERT INTO deleted_employees(
			employee_id,
			first_name,
			last_name,
			middle_name,
			job_title,
			department_id,
			salary
		)
		VALUES
			(
				old.employee_id,
				old.first_name,
				old.last_name,
				old.middle_name,
				old.job_title,
				old.department_id,
				old.salary
			);
		RETURN new;
	END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER backup_employees
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE PROCEDURE backup_fired_employees();

DELETE FROM employees WHERE employee_id = 1;
SELECT * FROM deleted_employees;

-- Additional
CREATE OR REPLACE FUNCTION delete_last_items_log()
RETURNS TRIGGER
$$
	BEGIN
		WHILE (SELECT COUNT(*) FROM items_log) > 10 LOOP
			DELETE FROM items_log WHERE "id" = (SELECT MIN("id") FROM items_log)
		END LOOP;
		RETURN new;
	END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER delete_last_items_trigger
AFTER INSERT ON items_log
FOR EACH STATEMENT
EXECUTE PROCEDURE delete_last_items_log();
