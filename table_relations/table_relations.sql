-- 01 Mountains and Peaks
CREATE TABLE mountains(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50)
);

CREATE TABLE peaks(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50),
	mountain_id INT,
	CONSTRAINT fk_peaks_mountains
		FOREIGN KEY (mountain_id)
			REFERENCES peaks(id)
);

-- 02 Trip Organization
SELECT
	v.driver_id,
	v.vehicle_type,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM
	vehicles AS v
JOIN campers AS c
	ON c.id = v.driver_id;

-- 03 Softuni Hiking
SELECT
	r.start_point,
	r.end_point,
	r.leader_id,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM 
	routes AS r
JOIN campers AS c
	ON r.leader_id = c.id;

-- 04 Mountains and Peaks
CREATE TABLE mountains(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50)
);

CREATE TABLE peaks(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50),
	mountain_id INT,
	CONSTRAINT fk_mountain_id
		FOREIGN KEY (mountain_id)
			REFERENCES mountains(id)
				ON DELETE CASCADE
);

-- 05 Project management db
CREATE TABLE clients(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50)
);

CREATE TABLE employees(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	project_id INT
)

CREATE TABLE projects(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	client_id INT REFERENCES clients(id),
	project_lead_id INT REFERENCES employees(id)
);

ALTER TABLE employees
ADD CONSTRAINT fk_employee_projects
	FOREIGN KEY (project_id)
		REFERENCES projects(id);
