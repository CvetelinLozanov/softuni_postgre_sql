-- 01 Booked for Nights
SELECT
	CONCAT(a.address, ' ', a.address_2) AS appartment_address,
	b.booked_for AS nights
FROM
	apartments AS a
JOIN
	bookings AS b
	ON 
	a.booking_id = b.booking_id
ORDER BY a.apartment_id;

-- 02 First 10 Apartments Booked At

SELECT
	a.name,
	a.country,
	b.booked_at::DATE
FROM
	apartments AS a
LEFT JOIN
	bookings AS b
	ON
	a.booking_id = b.booking_id
LIMIT(10);

-- 03 First 10 Customers with Bookings

SELECT
	b.booking_id,
	b.starts_at::date,
	b.apartment_id,
	CONCAT(c.first_name, ' ', last_name) as customer_name
FROM
	bookings AS b
RIGHT JOIN
	customers AS c
ON
	b.customer_id = c.customer_id
ORDER BY customer_name
LIMIT(10);

-- 04 Booking Information

SELECT
	b.booking_id,
	a.name AS aparment_owner,
	a.apartment_id,
	CONCAT(c.first_name, ' ', last_name) as customer_name
FROM
	bookings AS b
FULL JOIN
	apartments AS a
ON
	b.booking_id = a.booking_id
FULL JOIN
	customers AS c
ON
	c.customer_id = b.customer_id
ORDER BY b.booking_id, aparment_owner, customer_name;

-- 05 Multiplication of Information
SELECT
	b.booking_id,
	c.first_name
FROM
	bookings AS b
CROSS JOIN
	customers AS c

-- 06 Unassigned Apartments

SELECT
	b.booking_id,
	b.apartment_id,
	c.companion_full_name
FROM
	bookings AS b
JOIN
	customers AS c
USING
	(customer_id)
WHERE
	b.apartment_id IS NULL;

-- 07 Bookings Made By Lead

SELECT
	b.apartment_id,
	b.booked_for,
	c.first_name,
	c.country
FROM
	customers AS c
JOIN
	bookings AS b
ON
	c.customer_id = b.customer_id
WHERE
	c.job_type = 'Lead';

-- 08 Hanh's Books

SELECT
	COUNT(*)
FROM
	bookings AS b
JOIN
	customers AS c
USING
	(customer_id)
WHERE c.last_name = 'Hahn';

-- 09 Total Sum of Nights

SELECT
	a.name,
	SUM(b.booked_for)
FROM
	bookings AS b
JOIN
	apartments AS a
USING
	(apartment_id)
GROUP BY
	a.name
ORDER BY
	a.name;

-- 10 Popular Vacation Destination
SELECT
	a.country,
	COUNT(b.booking_id) AS booking_count
FROM bookings AS b
JOIN apartments AS a
	ON b.apartment_id = a.apartment_id
WHERE b.booked_at > '2021-05-18 07:52:09.904+03' AND  b.booked_at < '2021-09-17 19:48:02.147+03'
GROUP BY a.country
ORDER BY booking_count DESC;
	
