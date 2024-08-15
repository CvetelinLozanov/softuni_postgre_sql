-- 01 Data Definition Language (DDL)
CREATE TABLE owners(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50) NOT NULL,
	phone_number VARCHAR(50) NOT NULL,
	address VARCHAR(50)
);

CREATE TABLE animal_types(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	animal_type VARCHAR(30) NOT NULL
);

CREATE TABLE cages(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	animal_type_id INT NOT NULL,
	CONSTRAINT fk_cages_animal_types
		FOREIGN KEY (animal_type_id)
			REFERENCES animal_types("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE animals(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(30) NOT NULL,
	birthdate DATE NOT NULL,
	owner_id INT,
	animal_type_id INT NOT NULL,

	CONSTRAINT fk_animals_owners
		FOREIGN KEY (owner_id)
			REFERENCES owners("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_animals_animal_types
		FOREIGN KEY (animal_type_id)
			REFERENCES animal_types("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE volunteers_departments(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	department_name VARCHAR(30) NOT NULL
);

CREATE TABLE volunteers(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50) NOT NULL,
	phone_number VARCHAR(15) NOT NULL,
	address VARCHAR(50),
	animal_id INT,
	department_id INT NOT NULL,

	CONSTRAINT fk_volunteers_animals
		FOREIGN KEY (animal_id)
			REFERENCES animals("id")
			ON DELETE CASCADE
			ON UPDATE CASCADE,

	CONSTRAINT fk_volunteers_volunteers_departments
		FOREIGN KEY (department_id)
			REFERENCES volunteers_departments("id")
			ON DELETE CASCADE
			ON UPDATE CASCADE
);

CREATE TABLE animals_cages(
	cage_id INT NOT NULL,
	animal_id INT NOT NULL,
	--PRIMARY KEY(cage_id, animal_id),

	CONSTRAINT fk_animals_cages_animals
		FOREIGN KEY (animal_id)
			REFERENCES animals("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_animals_cages_cages
		FOREIGN KEY (cage_id)
			REFERENCES cages("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

-- 02 INSERT
INSERT INTO volunteers(
	name,
	phone_number,
	address,
	animal_id,
	department_id
)
VALUES
	('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
	('Dimitur Stoev', '0877564223', NULL, 42, 4),
	('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
	('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
	('Boryana Mileva', '0888112233', NULL, 31, 5);

INSERT INTO animals
	(
		name,
		birthdate,
		owner_id,
		animal_type_id
	)
	VALUES
		('Giraffe', '2018-09-21', 21, 1),
		('Harpy Eagle', '2015-04-17', 15, 3),
		('Hamadryas Baboon', '2017-11-02', NULL, 1),
		('Tuatara', '2021-06-30', 2, 4);

-- 03 UPDATE
UPDATE
	animals
SET
	owner_id = 
	(SELECT
		"id"
	FROM
		owners
	WHERE 
		name = 'Kaloqn Stoqnov'
	)
WHERE 
	owner_id IS NULL;

-- 04 Delete
DELETE
FROM volunteers_departments
WHERE department_name = 'Education program assistant';

-- 05 Volunteers
SELECT
	name,
	phone_number,
	address,
	animal_id,
	department_id
FROM
	volunteers
ORDER BY
	name, animal_id, department_id DESC;

-- 06 Animals Data

SELECT
	a.name,
	at.animal_type,
	TO_CHAR(a.birthdate, 'DD.MM.YYYY')
FROM
	animals AS a
JOIN
	animal_types AS at
ON
	a.animal_type_id = at.id
ORDER BY
	a.name;

-- 07 Owners and their animals
SELECT
	o.name,
	COUNT(a.*) AS count_of_animals
FROM
	owners AS o
JOIN
	animals AS a
ON	
	o.id = a.owner_id
GROUP BY
	o.name
ORDER BY 
	count_of_animals DESC,
	o.name
LIMIT (5);

-- 08 owners, animals and cages
SELECT
	CONCAT(o.name, ' - ', a.name) AS "owners - animals",
	o.phone_number,
	ac.cage_id
FROM
	owners AS o
JOIN
	animals AS a
ON
	a.owner_id = o.id
JOIN
	animal_types AS at
ON
	a.animal_type_id = at.id
JOIN
	animals_cages AS ac
ON
	a.id = ac.animal_id
WHERE
	at.animal_type = 'Mammals'
ORDER BY
	o.name, a.name DESC;

-- 09 Volunteers in Sofia
SELECT
	v."name" AS volunteers,
	v.phone_number,
	TRIM(RIGHT(v.address, -POSITION(',' IN v.address)))
FROM
	volunteers AS v
JOIN
	volunteers_departments AS vd
ON
	vd.id = v.department_id
WHERE
	LEFT(TRIM(address), 5) LIKE 'Sofia%'
AND
	vd.department_name = 'Education program assistant'
ORDER BY
	name;

-- 10 Animals for adoption
SELECT
	a.name AS animal,
	date_part('year', a.birthdate) AS birth_year,
	at.animal_type
FROM
	animals AS a
JOIN
	animal_types AS at
ON a.animal_type_id = at.id
WHERE
	a.owner_id IS NULL
AND
	at.animal_type <> 'Birds'
AND
	a.birthdate > '01/01/2022'::DATE  - interval '5' year
ORDER BY a.name;

-- 11
CREATE OR REPLACE FUNCTION fn_get_volunteers_count_from_department(searched_volunteers_department VARCHAR(30))
RETURNS INT
AS
$$
DECLARE
	volunteers_count INT;
BEGIN
	SELECT	
		COUNT(*) INTO volunteers_count
	FROM 
		volunteers AS v
	JOIN
		volunteers_departments AS vd
	ON
		v.department_id = vd.id
	WHERE vd.department_name = searched_volunteers_department;
	RETURN volunteers_count;
END;
$$
LANGUAGE plpgsql;

-- 12 Animals whit Owner or Not

CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(IN animal_name VARCHAR(30),OUT owner_name VARCHAR(50))
AS
$$
BEGIN
	SELECT
		o.name INTO owner_name
	FROM
		owners AS o
	RIGHT JOIN
		animals AS a
	ON
		a.owner_id = o.id
	WHERE a.name = animal_name;

	IF owner_name IS NULL THEN
		owner_name := 'For adoption';
	END IF;
END;
$$
LANGUAGE plpgsql;

CALL sp_animals_with_owners_or_not('Hippo','')

