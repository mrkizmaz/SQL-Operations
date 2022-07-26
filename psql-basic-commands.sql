-- ### Temel Seviye PostgreSQL Sorguları ### --

-- website: https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/

SELECT * FROM customer LIMIT 5;
-- column birlestirme islemleri
SELECT first_name || ' ' || last_name, email FROM customer LIMIT 5;
SELECT CONCAT(first_name, last_name) FROM customer LIMIT 5; -- bosluksuz birlestirme
SELECT CONCAT_WS(' ', customer_id, first_name, last_name) AS id_fullname, email FROM customer LIMIT 5;

-- order by
SELECT customer_id, first_name, last_name FROM customer ORDER BY first_name, customer_id ASC LIMIT 5;
SELECT first_name, LENGTH(first_name) AS len FROM customer ORDER BY len DESC LIMIT 10;

-- distinct
SELECT DISTINCT store_id FROM customer;
SELECT COUNT(store_id) FROM customer;

-- where
SELECT * FROM customer WHERE first_name = 'Jamie';
SELECT * FROM customer WHERE first_name = 'Jamie' AND last_name = 'Rice';

SELECT * FROM customer WHERE last_name = 'Rodriguez' OR first_name = 'Adam';

SELECT * FROM customer WHERE first_name IN ('Ann', 'Anne', 'Annie');
SELECT * FROM customer WHERE first_name LIKE 'Ann%';

SELECT first_name, LENGTH(first_name) AS name_length FROM customer 
WHERE first_name LIKE 'A%' AND LENGTH(first_name) BETWEEN 4 AND 6
ORDER BY name_length;

SELECT * FROM customer WHERE first_name LIKE 'Bra%' AND last_name <> 'Motley';

-- IN
SELECT * FROM rental LIMIT 5;
SELECT * FROM rental WHERE customer_id IN (1, 2)
ORDER BY return_date;
SELECT * FROM rental WHERE customer_id NOT IN (1, 2) LIMIT 10;

SELECT * FROM rental WHERE CAST (return_date AS DATE) = '2005-05-27'
ORDER BY customer_id;

-- IN with subquery
SELECT * FROM customer
WHERE customer_id IN (
SELECT customer_id FROM rental WHERE CAST (return_date AS DATE) = '2005-05-27')
ORDER BY customer_id LIMIT 10;

-- between
SELECT * FROM payment LIMIT 5;
SELECT customer_id, payment_id, amount FROM payment WHERE amount BETWEEN 8 AND 9;
SELECT customer_id, payment_id, amount FROM payment WHERE amount NOT BETWEEN 8 AND 9;

SELECT customer_id, payment_id, amount, payment_date FROM payment 
WHERE payment_date BETWEEN '2007-02-07' AND '2007-02-15';

-- like
SELECT * FROM customer WHERE first_name LIKE 'Jen%';
SELECT * FROM customer WHERE first_name LIKE '%er%' ORDER BY first_name;
SELECT * FROM customer WHERE first_name LIKE '_her%' ORDER BY first_name;
SELECT * FROM customer WHERE first_name ILIKE 'BaR%'; -- ilike -> harf boyutunu önemsemez

-- joins
SELECT * FROM customer LIMIT 5; 
SELECT * FROM payment LIMIT 5;
SELECT * FROM employee LIMIT 5;
SELECT * FROM staff LIMIT 5;

SELECT c.customer_id, CONCAT_WS(' ', c.first_name, last_name), p.amount, p.payment_date FROM customer AS c
INNER JOIN payment AS p ON c.customer_id = p.customer_id
ORDER BY c.customer_id, p.payment_date DESC;

SELECT c.customer_id, CONCAT_WS(' ', c.first_name, last_name) AS full_name, p.amount, p.payment_date FROM customer AS c
INNER JOIN payment AS p ON c.customer_id = p.customer_id
ORDER BY c.customer_id, p.payment_date DESC;

SELECT c.customer_id, CONCAT_WS(' ', c.first_name, last_name) AS full_name, p.amount, p.payment_date FROM customer AS c
INNER JOIN payment AS p ON c.customer_id = p.customer_id
WHERE c.customer_id = 2;

SELECT c.customer_id, CONCAT_WS(' ', c.first_name, last_name) AS full_name, p.amount, p.payment_date FROM customer AS c
INNER JOIN payment AS p USING(customer_id)
ORDER BY c.customer_id, p.payment_date DESC;

SELECT CONCAT_WS(' ', c.first_name, c.last_name) AS customer_fullname,
       CONCAT_WS(' ', s.first_name, s.last_name) AS staff_fullname,
       p.amount, p.payment_date FROM customer AS c
   INNER JOIN payment AS p USING(customer_id)
   INNER JOIN staff AS s USING(staff_id)
ORDER BY p.amount DESC, p.payment_date ASC;

-- group by
SELECT ROUND(AVG(amount), 2) AS ortalama, 
       SUM(amount) AS toplam, 
       COUNT(*) AS sayi, customer_id 
FROM payment GROUP BY customer_id 
ORDER BY COUNT(*) DESC;

SELECT CONCAT_WS(' ', c.first_name, c.last_name) AS full_name, SUM(p.amount) AS amount FROM customer AS c 
INNER JOIN payment AS p USING(customer_id)
GROUP BY full_name
ORDER BY amount DESC;

SELECT staff_id, COUNT(staff_id) FROM payment GROUP BY staff_id;

SELECT customer_id, staff_id, SUM(amount) FROM payment 
GROUP BY staff_id, customer_id ORDER BY customer_id;

SELECT DATE(payment_date), SUM(amount) AS amount FROM payment GROUP BY DATE(payment_date) ORDER BY amount DESC;

-- having
SELECT customer_id, SUM(amount) FROM payment
GROUP BY customer_id HAVING SUM(amount) > 200;

SELECT store_id, COUNT(customer_id) FROM customer
GROUP BY store_id HAVING COUNT(customer_id) > 300;

SELECT active, COUNT(*) FROM customer GROUP BY active HAVING COUNT(*) > 15;

-- grouping sets
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    brand VARCHAR NOT NULL,
    segment VARCHAR NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (brand, segment)
);

INSERT INTO sales (brand, segment, quantity)
VALUES
    ('ABC', 'Premium', 100),
    ('ABC', 'Basic', 200),
    ('XYZ', 'Premium', 100),
    ('XYZ', 'Basic', 300);
    
SELECT * FROM sales;
SELECT brand, segment, SUM(quantity) FROM sales GROUP BY brand, segment; -- coklu veride anlasılır
SELECT brand, SUM(quantity) FROM sales GROUP BY brand;
SELECT segment, SUM(quantity) FROM sales GROUP BY segment;
SELECT SUM(quantity) FROM sales;

SELECT brand, segment, SUM(quantity) FROM sales GROUP BY brand, segment
UNION ALL
SELECT brand, NULL, SUM(quantity) FROM sales GROUP BY brand
UNION ALL 
SELECT NULL, segment, SUM(quantity) FROM sales GROUP BY segment
UNION ALL
SELECT NULL, NULL, SUM(quantity) FROM sales; -- bu uzun bir yöntem ve perfomansı düsürür

SELECT brand, segment, SUM(quantity) FROM sales
GROUP BY
GROUPING SETS (
    (brand, segment),
    (brand),
    (segment),
    ()  ); -- bu sekilde yapılırsa okunusu kolay ve performansı yüksek olur
    
SELECT GROUPING(brand) AS group_brand,
       GROUPING(segment) AS group_segment, brand, segment, SUM(quantity)
FROM sales
GROUP BY GROUPING SETS (
    (brand),
    (segment),
    ()  )
ORDER BY brand, segment;

SELECT
	GROUPING(brand) grouping_brand,
	GROUPING(segment) grouping_segment,
	brand,
	segment,
	SUM (quantity)
FROM
	sales
GROUP BY
	GROUPING SETS (
		(brand),
		(segment),
		()
	)
HAVING GROUPING(brand) = 0	
ORDER BY
	brand,
	segment;
    
-- rollup (toplamını da tabloda gösterir)
SELECT brand, segment, SUM(quantity) FROM sales
GROUP BY
    ROLLUP (brand, segment)
ORDER BY brand, segment;

SELECT segment, SUM(quantity) FROM sales
GROUP BY
    ROLLUP (segment)
ORDER BY segment;

SELECT brand, segment, SUM(quantity) FROM sales
GROUP BY
    segment,
    ROLLUP (brand)
ORDER BY segment, brand;

SELECT 
    EXTRACT(YEAR FROM rental_date) AS y,
    EXTRACT(MONTH FROM rental_date) AS m,
    EXTRACT(DAY FROM rental_date) AS d,
    COUNT(rental_id) AS sayi
FROM rental
GROUP BY 
    ROLLUP (y, m, d)
ORDER BY y;

-- cube
SELECT brand, segment, SUM(quantity) FROM sales
GROUP BY
    CUBE (brand, segment)
ORDER BY brand, segment;

SELECT brand, segment, SUM(quantity) FROM sales
GROUP BY
    brand,
    CUBE (segment)
ORDER BY brand, segment;

-- subquery
SELECT * FROM film LIMIT 5;
SELECT * FROM inventory LIMIT 5;
SELECT * FROM rental LIMIT 5;

SELECT AVG(rental_rate) FROM film;
SELECT film_id, title, rental_rate FROM film WHERE rental_rate > 2.98;

SELECT film_id, title, rental_rate FROM film 
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);

SELECT i.film_id, r.return_date FROM rental AS r
INNER JOIN inventory AS i USING(inventory_id)
WHERE return_date BETWEEN '2005-05-29' AND '2005-05-30';

SELECT film_id, title FROM film 
WHERE film_id IN (
    SELECT i.film_id FROM rental
    INNER JOIN inventory AS i USING(inventory_id)
    WHERE return_date BETWEEN '2005-05-29' AND '2005-05-30');
    
SELECT first_name, last_name FROM customer
WHERE EXISTS (
    SELECT 1 FROM payment WHERE payment.customer_id = customer.customer_id);

-- any
SELECT * FROM film LIMIT 5;
SELECT * FROM film_category LIMIT 5;

SELECT MAX(length) FROM film 
INNER JOIN film_category USING(film_id)
GROUP BY category_id;

SELECT title FROM film
WHERE length >= ANY (
    SELECT MAX(length) FROM film 
    INNER JOIN film_category USING(film_id)
    GROUP BY category_id);

-- any vs. in
SELECT fc.category_id, f.title FROM film AS f
INNER JOIN film_category AS fc USING(film_id)
WHERE category_id = ANY(
    SELECT category_id FROM category
    WHERE name = 'Action' OR name = 'Drama');
    
SELECT fc.category_id, f.title FROM film AS f
INNER JOIN film_category AS fc USING(film_id)
WHERE category_id IN(
    SELECT category_id FROM category
    WHERE name = 'Action' OR name = 'Drama');

-- all
SELECT * FROM film LIMIT 5;
SELECT rating, COUNT(*), ROUND(AVG(length), 2) AS avg_length FROM film
GROUP BY rating
ORDER BY avg_length DESC;

SELECT film_id, title, length FROM film
WHERE length > ALL (
    SELECT ROUND(AVG(length), 2) FROM film
    GROUP BY rating)
ORDER BY length;

-- cte (common table expressions)
/* 
WITH cte_name (column_list) AS (
    CTE_query_definition 
)
statement;
*/

WITH cte_film AS (
    SELECT film_id, title,
    (CASE
         WHEN length < 30 THEN 'short'
         WHEN length >= 30 AND length < 90 THEN 'medium'
         ELSE 'long'
     END) length
    FROM film)
SELECT film_id, title, length FROM cte_film
WHERE length = 'medium'
ORDER BY title; -- view ile de yapılabilir!

-- insert
CREATE TABLE links (
    id SERIAL PRIMARY KEY,
    url VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    last_update DATE
);
INSERT INTO links (url, name, last_update)
VALUES ('https://www.postgresqltutorial.com','PostgreSQL Tutorial', NULL),
       ('http://www.oreilly.com','O''Reilly Media', NULL),
       ('https://www.google.com','Google','2013-06-01');

INSERT INTO links (url, name)
VALUES('http://www.postgresql.org','PostgreSQL') 
RETURNING id;

INSERT INTO links(url,name, description)
VALUES
    ('https://duckduckgo.com/','DuckDuckGo','Privacy & Simplified Search Engine'),
    ('https://swisscows.com/','Swisscows','Privacy safe WEB-search')
RETURNING *;

-- update
SELECT * FROM links;
UPDATE links SET description = 'This tutorial about PostgreSQL for developers'
WHERE id = 1
RETURNING *;

SELECT * FROM links;
UPDATE links SET description = 'This link for searching about anything',
                 last_update = NOW()::DATE
WHERE id = 3
RETURNING *;

-- delete
SELECT * FROM links;
DELETE FROM links WHERE id = 2
RETURNING *;

DELETE FROM links WHERE id IN (4, 5)
RETURNING *;

DELETE FROM links; -- tüm tabloyu siler (tehlikeli!)

-- upsert
CREATE TABLE customers (
	customer_id serial PRIMARY KEY,
	name VARCHAR UNIQUE,
	email VARCHAR NOT NULL,
	active bool NOT NULL DEFAULT TRUE
);
INSERT INTO 
    customers (name, email)
VALUES 
    ('IBM', 'contact@ibm.com'),
    ('Microsoft', 'contact@microsoft.com'),
    ('Intel', 'contact@intel.com');
SELECT * FROM customers;

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT ON CONSTRAINT customers_name_key
DO NOTHING; -- 'Microsoft' ismi var ise islem yapmaz (do nothing)

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT (name) DO NOTHING; -- bu da islem yapmaz

INSERT INTO customers (name, email)
VALUES ('Microsoft', 'hotline@microsoft.com')
ON CONFLICT (name)
DO
    UPDATE SET email = EXCLUDED.email || '; ' || customers.email
RETURNING *;

-- transaction
-- ACID (atomic, consistent, isolated, durable)

CREATE TABLE accounts (
    id INT GENERATED BY DEFAULT AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    balance DEC(15,2) NOT NULL,
    PRIMARY KEY(id)
);
INSERT INTO accounts (name, balance)
VALUES ('Bob', 10000);

BEGIN TRANSACTION; -- or begin work or begin
INSERT INTO accounts (name, balance)
VALUES ('Alice', 10000); -- yeni sorguda eklendigi görülmez! commit eklenmeli!
COMMIT; -- or commit transaction or commit work

BEGIN;
UPDATE accounts 
SET balance = balance - 1000
WHERE id = 1;
UPDATE accounts
SET balance = balance + 1000
WHERE id = 2; 
SELECT id, name, balance
FROM accounts;
COMMIT;

INSERT INTO accounts(name, balance)
VALUES('Jack', 0);

BEGIN;
UPDATE accounts 
SET balance = balance - 1500
WHERE id = 1;
UPDATE accounts
SET balance = balance + 1500
WHERE id = 3; 
ROLLBACK; -- islemi geri alır

-- import ve export islemleri
COPY sample_table_name FROM 'path' DELIMETER ',' CSV HEADER; -- import
COPY TO tablename 'path/filename.csv' DELIMETER ',' CSV HEADER; -- export
\copy (SELECT * FROM tablename) to 'path/filename.csv' WITH csv -- in terminal to export

-- metinsel fonksiyonlar
SELECT ASCII ('e');
SELECT CONCAT('ersel ', 'kizmaz');
SELECT CONCAT_WS('*', 'ersel', 'kizmaz');

SELECT LEFT('Merhaba DÜnya', 4);
SELECT LENGTH('ersel kizmaz');

SELECT * FROM musteri;
SELECT id, REPLACE(ad, 'e', 'a') FROM musteri;
SELECT REVERSE(ad) FROM musteri;
SELECT SUBSTRING('ersel kizmaz', 2, 4);
SELECT LOWER(ad), UPPER(soyad) FROM musteri;

-- matematiksel fonksiyonlar
SELECT abs(-22);
SELECT CEIL(4.89);
SELECT FLOOR(5.67);
SELECT pi();
SELECT POWER(2, 4);
SELECT RANDOM();
SELECT ROUND(22.3142, 2);
SELECT SIGN(-11);
SELECT SQRT(625);
SELECT LOG(50);

		-- ## PSQL Table Commands ## -- 

/* Overview of PostgreSQL Data Types */
/*
boolean; true: 1, yes, y, t
		false: 0, no, n, f
character; varchar(n), char(n), text
numeric; integer  --> smallint, integer, serial = auto_increment
         floating --> float(n), real, numeric(p, s)
temporal data types;
    date, time, timestamp, timestamptz, interval
uuid, array, json, hstore

special data types; box, line, point, lseg, polygon, inet, macaddr
*/

-- create table (genel tablo olusturma)
CREATE TABLE account (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_on TIMESTAMP NOT NULL,
    last_login TIMESTAMP
);

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE account_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    grant_date TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (role_id)
        REFERENCES roles (role_id),
    FOREIGN KEY (user_id)
        REFERENCES account (user_id)
);

-- DROP TABLE account;
-- DROP TABLE roles;
-- DROP TABLE account_roles;

-- select into (bir başka tablodan column alarak yeni tablo olusturur)
SELECT * FROM film LIMIT 5;
SELECT film_id, title, length
INTO TABLE film_r FROM film
WHERE rating = 'R' AND rental_duration = 5 
ORDER BY title;
SELECT * FROM film_r;

SELECT film_id, title, length
INTO TEMP TABLE short_film FROM film
WHERE length < 60 ORDER BY title;
SELECT * FROM short_film; -- temp (gecici yeni tablo olusturur)

-- create table ... as (iki farklı tabloyu birlestirerek yeni tablo olusturur)
CREATE TABLE action_film AS 
SELECT film_id, title, release_year, length, rating FROM film
INNER JOIN film_category USING(film_id)
WHERE category_id = 1;
SELECT * FROM action_film;

CREATE TABLE IF NOT EXISTS film_rating (rating, film_count) AS
SELECT rating, COUNT(film_id) FROM film
GROUP BY rating;
SELECT * FROM film_rating;

-- serial example
CREATE TABLE fruits (
	id SERIAL PRIMARY KEY, 
	name VARCHAR NOT NULL );
INSERT INTO fruits (name) VALUES ('Orange');

INSERT INTO fruits (id, name) VALUES (DEFAULT, 'Apple');
-- satır sayısını bulma
SELECT currval(pg_get_serial_sequence('fruits', 'id'));
INSERT INTO fruits (name) VALUES ('Banana')
RETURNING id;
SELECT * FROM fruits;

-- sequences (diziler)
CREATE SEQUENCE mysequence
INCREMENT 5
START 100;
SELECT nextval('mysequence');

CREATE SEQUENCE three
INCREMENT -1
MINVALUE 1
MAXVALUE 3
START 3
CYCLE;
SELECT nextval('three');

CREATE TABLE order_details (
	order_id SERIAL,
	item_id INT NOT NULL,
	item_text VARCHAR NOT NULL,
	price DEC(10, 2) NOT NULL,
	PRIMARY KEY (order_id, item_id));
	
CREATE SEQUENCE order_item_id
START 10
INCREMENT 10
MINVALUE 10
OWNED BY order_details.item_id;

INSERT INTO order_details (order_id, item_id, item_text, price)
VALUES (100, nextval('order_item_id'), 'DVD Player', 100),
       (100, nextval('order_item_id'), 'Android TV', 550),
       (100, nextval('order_item_id'), 'Speaker', 250);
SELECT * FROM order_details;

-- var olan sequence'ları yazdırma
SELECT relname sequence_name FROM pg_class WHERE relkind = 'S';

DROP SEQUENCE IF EXISTS three CASCADE; 
DROP TABLE order_details; -- iliskili sequnce'ları da siler

-- identify column
CREATE TABLE color (
    color_id INT GENERATED ALWAYS AS IDENTITY,
    color_name VARCHAR NOT NULL );
	
INSERT INTO color(color_name) VALUES ('Red');
INSERT INTO color (color_id, color_name) VALUES (2, 'Green'); -- hata verir!

INSERT INTO color (color_id, color_name)
OVERRIDING SYSTEM VALUE 
VALUES(2, 'Green'); -- üstteki hatayı gidermek için

-- 2. yol
DROP TABLE color;
CREATE TABLE color (
    color_id INT GENERATED BY DEFAULT AS IDENTITY,
    color_name VARCHAR NOT NULL );

INSERT INTO color (color_name) VALUES ('White');
INSERT INTO color (color_id, color_name) VALUES (2, 'Yellow');

DROP TABLE color;
CREATE TABLE color (
    color_id INT GENERATED BY DEFAULT AS IDENTITY 
    (START WITH 10 INCREMENT BY 10),
    color_name VARCHAR NOT NULL ); 

INSERT INTO color (color_name) 
VALUES ('Orange'),
	   ('Banana'),
	   ('Purple');
SELECT * FROM color;

-- var olan tabloya identify özelligi ekleme
CREATE TABLE shape (
    shape_id INT NOT NULL,
    shape_name VARCHAR NOT NULL );
	
ALTER TABLE shape 
ALTER COLUMN shape_id ADD GENERATED ALWAYS AS IDENTITY;
-- identify'ı güncelleme
ALTER TABLE shape
ALTER COLUMN shape_id SET GENERATED BY DEFAULT;

ALTER TABLE shape
ALTER COLUMN shape_id
DROP IDENTITY IF EXISTS;

-- https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-alter-table/