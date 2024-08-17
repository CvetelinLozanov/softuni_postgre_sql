-- 01 Database Design

CREATE TABLE countries(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE customers(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	first_name VARCHAR(25) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	gender CHAR(1) CHECK(gender IN ('M', 'F')),
	age INT NOT NULL CHECK(age > 0),
	phone_number CHAR(10) NOT NULL,
	country_id INT NOT NULL,

	CONSTRAINT fk_customers_countries
		FOREIGN KEY (country_id)
			REFERENCES countries("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE products(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(25) NOT NULL,
	description VARCHAR(250),
	recipe TEXT,
	price NUMERIC(10, 2) NOT NULL CHECK (price > 0)
);

CREATE TABLE feedbacks(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	description VARCHAR(255),
	rate NUMERIC(4, 2) CHECK(rate BETWEEN 0 AND 10),
	product_id INT NOT NULL,
	customer_id INT NOT NULL,

	CONSTRAINT fk_feedbacks_products
		FOREIGN KEY (product_id)
			REFERENCES products("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_feedbacks_customers
		FOREIGN KEY (customer_id)
			REFERENCES customers("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE distributors(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(25) UNIQUE NOT NULL,
	address VARCHAR(30) NOT NULL,
	summary VARCHAR(200) NOT NULL,
	country_id INT NOT NULL,

	CONSTRAINT fk_distributors_countries
		FOREIGN KEY (country_id)
			REFERENCES countries("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE ingredients(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(30) NOT NULL,
	description VARCHAR(200),
	country_id INT NOT NULL,
	distributor_id INT NOT NULL,

	CONSTRAINT fk_ingredients_countries
		FOREIGN KEY (country_id)
			REFERENCES countries("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_ingredients_distributors
		FOREIGN KEY (distributor_id)
			REFERENCES distributors("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

CREATE TABLE products_ingredients(
	product_id INT NOT NULL,
	ingredient_id INT NOT NULL,

	CONSTRAINT fk_products_ingredients_products
		FOREIGN KEY(product_id)
			REFERENCES products("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE,

	CONSTRAINT fk_products_ingredients_ingredients
		FOREIGN KEY (ingredient_id)
			REFERENCES ingredients("id")
				ON DELETE CASCADE
				ON UPDATE CASCADE
);

-- 02 Insert
CREATE TABLE gift_recipients(
	"id" INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	"name" VARCHAR(100) NOT NULL,
	country_id INT NOT NULL,
	gift_sent BOOLEAN DEFAULT FALSE
);

INSERT INTO gift_recipients(
	"name",
	country_id,
	gift_sent
)
	SELECT
		CONCAT(first_name,  ' ', last_name) AS name,
		country_id AS country_id,
		CASE
			WHEN country_id IN (7, 8, 14, 17, 26) THEN TRUE
			ELSE FALSE 
		END AS gift_send
	FROM customers;

-- 03 Update
UPDATE products
SET price = price * 1.10
WHERE "id" IN (
		SELECT
			product_id
		FROM
			feedbacks
		WHERE
			rate > 8);

-- 04 Delete
DELETE
FROM
	distributors
WHERE
	"name" LIKE 'L%';

-- 05 Products
SELECT
	"name",
	recipe,
	price
FROM
	products
WHERE
	price BETWEEN 10 AND 20
ORDER BY
	price DESC;

-- 06 Negative feedback
SELECT
	f.product_id,
	f.rate,
	f.description,
	f.customer_id,
	c.age,
	c.gender
FROM
	customers AS c
JOIN
	feedbacks AS f
ON
	c.id = f.customer_id
WHERE
	f.rate < 5
AND
	c.gender = 'F'
AND
	c.age > 30
ORDER BY
	f.product_id DESC;

-- 07 High Average Price and multiple feedbacks
SELECT
	p.name,
	ROUND(AVG(p.price), 2) AS average_price,
	COUNT(f.id) AS total_feedbacks
FROM
	feedbacks AS f
JOIN
	products AS p
ON
	p.id = f.product_id
WHERE
	p.price > 15
GROUP BY
	p.name
HAVING
	COUNT(f.id) > 1
ORDER BY
	total_feedbacks, average_price DESC;

-- 08 Specific ingredients
SELECT
	i.name,
	p.name,
	d.name
FROM
	ingredients AS i
JOIN
	products_ingredients AS pi
ON
	i.id = pi.ingredient_id
JOIN
	products AS p
ON
	pi.product_id = p.id
JOIN
	distributors AS d
ON
	i.distributor_id = d.id
WHERE
	d.country_id = 16
AND
	i.name ILIKE '%Mustard%'
ORDER BY
	p.name;

-- 09 Middle Range Distributors

SELECT
	d.name AS distributor_name,
	i.name AS ingredient_name,
	p.name AS product_name,
	AVG(f.rate) AS average_rate
FROM
	distributors AS d
JOIN
	ingredients AS i
ON
	d.id = i.distributor_id
JOIN
	products_ingredients AS pi
ON
	pi.ingredient_id = i.id
JOIN
	products AS p
ON
	p.id = pi.product_id
JOIN
	feedbacks AS f
ON
	f.product_id = p.id
GROUP BY
	d.name,
	i.name,
	p.name
HAVING
	AVG(f.rate) BETWEEN 5 AND 8
ORDER BY
	d.name, i.name, p.name;

-- 10 Customer Feedback

CREATE OR REPLACE FUNCTION fn_feedbacks_for_product(product_name VARCHAR(25))
RETURNS TABLE(
	customer_id INT,
	customer_name VARCHAR(75),
	feedback_description VARCHAR(255),
	feedback_rate NUMERIC(4, 2)
)
AS
$$
BEGIN
	RETURN QUERY
		SELECT
			c.id,
			c.first_name,
			f.description,
			f.rate
		FROM
			products AS p
		JOIN
			feedbacks AS f
		ON
			p.id = f.product_id
		JOIN
			customers AS c
		ON
			f.customer_id = c.id
		WHERE p.name = product_name
		ORDER BY
			c.id;		
END;
$$
LANGUAGE plpgsql;

SELECT * FROM fn_feedbacks_for_product('ALCOHOL');

-- 11 Customer's Country

CREATE OR REPLACE PROCEDURE sp_customer_country_name(IN customer_full_name VARCHAR(50), OUT country_name VARCHAR(50))
AS
$$
BEGIN
	SELECT
		co.name INTO country_name
	FROM
		customers AS cu
	JOIN
		countries AS co
	ON
		cu.country_id = co.id
	WHERE CONCAT(cu.first_name, ' ', cu.last_name) = customer_full_name;
END;
$$
LANGUAGE plpgsql;

CALL sp_customer_country_name('Rachel Bishop', '')



