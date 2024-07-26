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
