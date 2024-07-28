-- 01 River Info
CREATE VIEW view_river_info AS
	SELECT 
		CONCAT_WS(' ',
			'The river',
			river_name,
			'flows into the',
			outflow,
			'and is',
			"length",
			'kilometers long.') as "River Information"
	FROM
		rivers
	ORDER BY
		river_name;

-- 02 Concatenate geography data
CREATE VIEW view_continents_countries_currencies_details AS  
SELECT
	CONCAT_WS(': ', TRIM(con.continent_name), con.continent_code) AS continent_details,
	CONCAT_WS(' - ', cou.country_name, cou.capital, cou.area_in_sq_km, 'km2') AS country_information,
	CONCAT(cur.description, ' (', cur.currency_code, ')') AS currencies
FROM
	continents con
JOIN
	countries cou
	ON 
	cou.continent_code = con.continent_code
JOIN
	currencies cur
	ON
	cou.currency_code = cur.currency_code
ORDER BY
	country_information, currencies
;

-- 03 Capital Code
ALTER TABLE 
	countries
ADD COLUMN 
	capital_code CHAR(2);

UPDATE
	countries
SET
	capital_code = SUBSTRING(capital, 1, 2)
RETURNING *;

-- 04 (Descr)iption
SELECT
	SUBSTRING(description, 5)
FROM
	currencies
;

--05 substring river length
SELECT
	SUBSTRING("River Information" FROM '([0-9]{1,4})') AS river_length
FROM
	view_river_info;
	
-- 06 Replace A
SELECT
	REPLACE(mountain_range, 'a', '@') as replace_a,
	REPLACE(mountain_range, 'A', '$') as replace_A
FROM
	mountains
;

-- 07 Translate
SELECT
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou')
FROM
	countries
;

-- 08 Leading
SELECT
	continent_name,
	TRIM(continent_name) as "trim"
FROM 
	continents
;

-- 09 Trailing
SELECT
	continent_name,
	TRIM(TRAILING FROM continent_name) as "trim"
FROM 
	continents
;

-- 10 Ltrim & Rtrim
SELECT
	LTRIM(peak_name, 'M') AS left_trim,
	RTRIM(peak_name, 'm') AS right_trim
FROM
	peaks
;
-- 11 Character length and bits
SELECT
	CONCAT_WS(' ', m.mountain_range, p.peak_name) AS mountain_information,
	LENGTH(CONCAT_WS(' ', m.mountain_range, p.peak_name)),
	BIT_LENGTH(CONCAT_WS(' ', m.mountain_range, p.peak_name))
FROM
	mountains m
JOIN
	peaks p
ON
	m.id = p.mountain_id;

-- 12 Length of a number
SELECT
	population,
	LENGTH(CAST(population AS TEXT))
FROM
	countries;

-- 13 Positive and Negative LEFT
SELECT
	peak_name,
	LEFT(peak_name, 4) AS positive_left,
	LEFT(peak_name, -4) AS negative_left
FROM
	peaks
;

-- 14 Positive and Negative RIGHT
SELECT
	peak_name,
	RIGHT(peak_name, 4) AS positive_left,
	RIGHT(peak_name, -4) AS negative_left
FROM
	peaks
;

-- 15 Update iso_code
UPDATE
	countries
SET
	iso_code = UPPER(SUBSTRING(country_name, 1,3))
WHERE
	iso_code IS NULL
;

-- 16 REVERSE country_code
UPDATE
	countries
SET
	country_code = LOWER(REVERSE(country_code))
;


-- 17 Elevation -->> Peak Name
SELECT
	CONCAT_WS(
		' ',
		elevation,
		REPEAT('-', 3)||REPEAT('>', 2),
		peak_name
	)
FROM
	peaks
WHERE
	elevation >= 4884
	
-- 18 Arithmetical Operators
CREATE TABLE bookings_calculation AS
SELECT
	booked_for,
	CAST(booked_for * 50 AS NUMERIC) AS multiplication,
	CAST(booked_for % 50 AS NUMERIC) AS modulo
FROM
	bookings
WHERE
	apartment_id = 93;

-- 19 ROUND vs TRUNC
SELECT
	latitude,
	ROUND(latitude, 2),
	TRUNC(latitude, 2)
FROM
	apartments;

-- 20 Absolute Value
SELECT
	longitude,
	ABS(longitude)
FROM
	apartments;

-- 21 Billing Day
ALTER TABLE bookings
ADD COLUMN billing_day TIMESTAMPTZ DEFAULT now()

SELECT
	TO_CHAR(billing_day, 'DD ''Day'' MM ''Month'' YYYY ''Year'' HH24:MI:SS')
FROM
	bookings;

-- 22 EXTRACT Booked At
SELECT
	EXTRACT(YEAR FROM booked_at),
	EXTRACT(MONTH FROM booked_at),
	EXTRACT(DAY FROM booked_at),
	EXTRACT(HOUR FROM booked_at AT TIME ZONE 'UTC') AS HOUR,
	EXTRACT(MINUTE FROM booked_at),
	CEILING(EXTRACT(SECOND FROM booked_at))
FROM
	bookings;

-- 23 Early birds
SELECT
	user_id,
	AGE(starts_at, booked_at) AS early_birds
FROM
	bookings
WHERE
	starts_at - booked_at >= '10_MONTHS';

-- 24 Match or Not
SELECT
	companion_full_name,
	email
FROM
	users
WHERE
	companion_full_name ILIKE '%and%'
AND
	email NOT LIKE '%@gmail';

-- 25 COUNT by initial
SELECT
	SUBSTRING(first_name, 1, 2) AS initials,
	COUNT(*) AS user_count
FROM
	users
GROUP BY initials
ORDER BY user_count DESC, initials;

-- 26 SUM
SELECT
	SUM(booked_for) AS total_value
FROM
	bookings
WHERE
	apartment_id = 90;

-- 27 Average Value
SELECT
	AVG(multiplication) AS avarage_value
FROM
	bookings_calculation;
