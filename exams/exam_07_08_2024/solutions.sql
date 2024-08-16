-- 01 Table Design

CREATE TABLE countries(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(40) NOT NULL UNIQUE,
	continent VARCHAR(40) NOT NULL,
	currency VARCHAR(5)
);

CREATE TABLE categories(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE actors(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birthdate DATE NOT NULL,
	height INT,
	awards INT NOT NULL DEFAULT 0 CHECK(awards >= 0),
	country_id INT NOT NULL,

	CONSTRAINT fk_actors_countries
		FOREIGN KEY (country_id)
			REFERENCES countries("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE productions_info(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	rating DECIMAL(4, 2) NOT NULL,
	duration INT NOT NULL CHECK(duration > 0),
	budget DECIMAL(10, 2),
	release_date DATE NOT NULL,
	has_subtitles BOOLEAN NOT NULL DEFAULT FALSE,
	synopsis TEXT
);

CREATE TABLE productions(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	title VARCHAR(70) NOT NULL UNIQUE,
	country_id INT NOT NULL,
	production_info_id INT NOT NULL UNIQUE,

	CONSTRAINT fk_productions_countries
		FOREIGN KEY (country_id)
			REFERENCES countries("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,
				
	CONSTRAINT fk_productions_productions_info
		FOREIGN KEY (production_info_id)
			REFERENCES productions_info("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE productions_actors(
	production_id INT NOT NULL,
	actor_id INT NOT NULL,
	PRIMARY KEY (production_id, actor_id),

	CONSTRAINT fk_productions_actors_production
		FOREIGN KEY(production_id)
			REFERENCES productions("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_productions_actors_actors
		FOREIGN KEY (actor_id)
			REFERENCES actors("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE categories_productions(
	category_id INT NOT NULL,
	production_id INT NOT NULL,
	PRIMARY KEY (category_id, production_id),

	CONSTRAINT fk_categories_productions_category
		FOREIGN KEY (category_id)
			REFERENCES categories("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_categories_productions_productions
		FOREIGN KEY (production_id)
			REFERENCES productions("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

-- 02 Insert
INSERT INTO actors
	(
		first_name,
		last_name,
		birthdate,
		height,
		awards,
		country_id
	)
	
		SELECT
			REVERSE(first_name),
			REVERSE(last_name),
			birthdate - interval '2' DAY,
			COALESCE(height, 0) + 10,
			country_id,
			(SELECT "id" FROM countries WHERE "name" = 'Armenia')
		FROM
			actors
		WHERE "id" BETWEEN 10 AND 20;

SELECT * FROM actors ORDER BY id DESC;

-- 03 Update
UPDATE productions_info
SET
	duration =
		CASE
			WHEN "id" < 15 THEN duration + 15
			WHEN "id" >= 20 THEN duration + 20
		ELSE
			duration
		END
WHERE synopsis IS NULL
;

-- 04 Delete
DELETE FROM countries
WHERE "id" NOT IN (
    SELECT DISTINCT country_id FROM actors
    UNION
    SELECT DISTINCT country_id FROM productions
);

-- 05 Countries
SELECT
	*
FROM
	countries
WHERE
	continent = 'South America'
AND
	(currency LIKE 'U%' OR currency LIKE 'P%')
ORDER BY
	currency DESC, "id";

-- 06 Productions by Release Year
SELECT
	p.id,
	p.title,
	pi.duration,
	ROUND(pi.budget, 1) AS budget,
	TO_CHAR(pi.release_date, 'MM-YY') AS release_date
FROM
	productions AS p
JOIN
	productions_info AS pi
ON
	p.production_info_id = pi.id
WHERE
	date_part('year', release_date) IN ('2023','2024')
AND
	budget > 1500000
ORDER BY
	budget, pi.duration DESC
LIMIT(3);

-- 07 Casting
SELECT
	CONCAT(a.first_name, ' ', a.last_name) AS full_name,
	CONCAT(LEFT(LOWER(a.first_name), 1), RIGHT(a.last_name, 2), LENGTH(a.last_name), '@sm-cast.com') AS email,
	a.awards
FROM 
	actors AS a
LEFT JOIN
	productions_actors AS pa
ON pa.actor_id = a.id
WHERE
	pa.production_id IS NULL
ORDER BY
	a.awards DESC, a."id";

-- 08 Nominees
SELECT
	c.name,
	COUNT(p.*) AS productions_count,
	COALESCE(AVG(pi.budget), 0) AS avg_budget
FROM
	countries AS c
JOIN
	productions AS p
ON
	p.country_id = c.id
JOIN
	productions_info AS pi
ON
	pi.id = p.production_info_id
GROUP BY
	c.name
ORDER BY
	productions_count DESC, c.name;


-- 09 Classify by Raiting

SELECT
	a.title,
	a.rating,
	a.subtitles,
	COUNT(a.actor_id) AS actors_count
FROM
	(
	SELECT
		p.title,
		CASE 
			WHEN pi.rating <= 3.50 THEN 'poor'
			WHEN pi.rating > 3.50 AND pi.rating <= 8 THEN 'good'
			ELSE
				'excellent'
		END AS rating, 
		CASE
			WHEN pi.has_subtitles = TRUE THEN 'Bulgarian'
			ELSE
				'N/A'
		END AS subtitles,
		pa.actor_id
	FROM
		productions_info AS pi
	JOIN
		productions AS p
	ON
		pi.id = p.production_info_id
	JOIN
		productions_actors AS pa
	ON
		pa.production_id = p.id) 
	AS a
GROUP BY 
	a.title,
	a.rating,
	a.subtitles
ORDER BY
	a.rating,
	actors_count DESC,
	a.title
;

-- 10 Productions Count by Category

CREATE OR REPLACE FUNCTION udf_category_productions_count(category_name VARCHAR(50))
RETURNS VARCHAR(50)
AS
$$
DECLARE
	total_count INT;
BEGIN
	SELECT
		COUNT(*) INTO total_count
	FROM
		categories AS c
	JOIN
		categories_productions AS cp
	ON
		c.id = cp.category_id
	WHERE
		c."name" = category_name;

	RETURN 'Found ' || total_count || ' productions.';
END;
$$
LANGUAGE plpgsql;

SELECT udf_category_productions_count('History') AS message_text;

-- 11 Awarded prodction

CREATE OR REPLACE PROCEDURE udp_awarded_production(production_title VARCHAR(70))
AS
$$
BEGIN
	UPDATE
	actors
	SET 
		awards = awards + 1
	WHERE
		id IN (
			SELECT
				pa.actor_id
			FROM
				productions AS p
			JOIN
				productions_actors AS pa
			ON
				pa.production_id = p.id
			WHERE
				p.title = production_title
		);
END;
$$
LANGUAGE plpgsql;

CALL udp_awarded_production('Tea For Two');
