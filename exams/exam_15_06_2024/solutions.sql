-- 01 Table Design
CREATE TABLE accounts(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	username VARCHAR(30) NOT NULL UNIQUE,
	"password" VARCHAR(30) NOT NULL,
	email VARCHAR(50) NOT NULL,
	gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
	age INT NOT NULL,
	job_title VARCHAR(40) NOT NULL,
	ip VARCHAR(30) NOT NULL
);

CREATE TABLE addresses(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	street VARCHAR(30) NOT NULL,
	town VARCHAR(30) NOT NULL,
	country VARCHAR(30) NOT NULL,
	account_id INT NOT NULL,

	CONSTRAINT fk_addresses_account
		FOREIGN KEY (account_id)
			REFERENCES accounts("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE photos(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	description TEXT,
	capture_date TIMESTAMP NOT NULL,
	"views" INT NOT NULL DEFAULT 0 CHECK ("views" >= 0)
);

CREATE TABLE "comments"(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"content" VARCHAR(255) NOT NULL,
	published_on TIMESTAMP NOT NULL,
	photo_id INT NOT NULL,

	CONSTRAINT fk_comments_phots
		FOREIGN KEY (photo_id)
			REFERENCES photos("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE accounts_photos(
	account_id INT NOT NULL,
	photo_id INT NOT NULL,
	PRIMARY KEY(account_id, photo_id),

	CONSTRAINT fk_accounts_photos_accounts
		FOREIGN KEY (account_id)
			REFERENCES accounts("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_accounts_photos_photos
		FOREIGN KEY (photo_id)
			REFERENCES photos("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE				
);

CREATE TABLE likes(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	photo_id INT NOT NULL,
	account_id INT NOT NULL,

	CONSTRAINT fk_likes_photos
		FOREIGN KEY (photo_id)
			REFERENCES photos("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_likes_accounts
		FOREIGN KEY (account_id)
			REFERENCES accounts("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);


-- 02 Insert
INSERT INTO addresses(street, town, country, account_id)
	SELECT
		username,
		password,
		ip,
		age
	FROM
		accounts
	WHERE
		gender = 'F';

-- 03 Update
UPDATE addresses
SET
	country = 
		CASE
			WHEN country LIKE 'B%' THEN 'Blocked'
			WHEN country LIKE 'T%' THEN 'Test'
			WHEN country LIKE 'P%' THEN 'In Progress'
			ELSE
				country
		END;

-- 04 Delete
DELETE
FROM
	addresses
WHERE
	"id" % 2 = 0
AND
	street ILIKE '%r%';

-- 05 accounts
SELECT
	username,
	gender,
	age
FROM
	accounts
WHERE
	age >= 18
AND
	LENGTH("username") > 9
ORDER BY age DESC, username;

-- 06 Top 3 Most Commented Photos
SELECT
	p."id",
	p.capture_date,
	p.description,
	COUNT(c.id) AS comments_count
FROM
	photos AS p
JOIN
	"comments" AS c
ON
	c.photo_id = p.id
WHERE
	p.description IS NOT NULL
GROUP BY
	p."id",
	p.capture_date,
	p.description
ORDER BY
	comments_count DESC,
	p.id
LIMIT (3);


-- 07 Lucky accounts

SELECT
	CONCAT(a."id", ' ', a.username) AS id_username,
	a.email
FROM
	accounts AS a
JOIN
	accounts_photos AS ap
ON
	a.id = ap.account_id
WHERE
	a.id = ap.photo_id;

-- 08 Count Likes and Comments

SELECT
	p.id AS photo_id,
	COUNT(DISTINCT l.id) AS likes_count,
	COUNT(DISTINCT c.id) AS comments_count
FROM
	photos AS p
LEFT JOIN likes AS l
	ON p.id = l.photo_id
LEFT JOIN comments AS c
	ON c.photo_id = p.id
GROUP BY p.id
ORDER BY
	likes_count DESC, comments_count DESC, p.id;

-- 09 Photos Captured on the tenth day of the month

SELECT
	CONCAT(SUBSTRING(description, 1, 10), '...') AS summary,
	TO_CHAR(capture_date, 'DD.MM HH24:MI') AS "date"
FROM
	photos
WHERE
	date_part('day', capture_date) = 10
ORDER BY capture_date DESC;

-- 10 Get accounts photos count

CREATE OR REPLACE FUNCTION udf_accounts_photos_count(account_username VARCHAR(30))
RETURNS INT
AS
$$
DECLARE
	photos_count INT;
BEGIN
	SELECT
		COUNT(*) INTO photos_count
	FROM
		accounts AS a
	JOIN
		accounts_photos AS ap
	ON
		a.id = ap.account_id
	WHERE
		a.username = account_username;

	RETURN photos_count;
END;
$$
LANGUAGE plpgsql;

SELECT udf_accounts_photos_count('ssantryd') AS photos_count;


-- 11 Modify Accounts Job Title
CREATE OR REPLACE PROCEDURE udp_modify_account(address_street VARCHAR(30), address_town VARCHAR(30))
AS
$$
DECLARE
	fin_account_id INT;
BEGIN
	SELECT
		account_id INTO fin_account_id
	FROM
		addresses 
	WHERE
		street = address_street
	AND town = address_town;
	RAISE NOTICE 'dsadada %', fin_account_id;
	IF fin_account_id IS NOT NULL THEN
		UPDATE accounts
		SET job_title = CONCAT('(Remote) ', job_title)
		WHERE id = fin_account_id;
	END IF;	
END;
$$
LANGUAGE plpgsql;

CALL udp_modify_account('97 Valley Edge Parkway', 'Divinópolis');
SELECT a.username, a.gender, a.job_title FROM accounts AS a
WHERE a.job_title ILIKE '(Remote)%';
