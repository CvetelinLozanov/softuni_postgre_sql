-- 01 Find book titles
SELECT
	title
FROM 
	books
WHERE
	LEFT(title, 3) = 'The'
;

-- 02 Replace titles
SELECT
	REPLACE(title, 'The', '***')
FROM
	books
WHERE
	title LIKE 'The%'
;

-- 03 Triangles on bookshelves
SELECT
	id,
	(side * height) / 2 as area
FROM
	triangles
;

-- 04 Format costs
SELECT
	title,
	ROUND("cost", 3) as modified_price
FROM
	books
;

-- 05 Year of birth
SELECT
	first_name,
	last_name,
	date_part('year', born) as "year"
FROM
	authors
;

-- 06 Format date of birth
SELECT
	last_name as "Last Name",
	TO_CHAR(born, 'DD (Dy) Mon YYYY')
FROM
	authors
;

-- 07 Harry Potter Books
SELECT
	title
FROM
	books
WHERE
	title LIKE 'Harry Potter%'
;
