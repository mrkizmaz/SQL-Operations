-- ### Orta Seviye PostgreSQL Sorguları ### -- 

-- tablo ön görünümleri
-- SELECT * FROM personn LIMIT 5;
-- SELECT * FROM personn LIMIT 5;


-- SELECT * FROM personn WHERE car_id NOTNULL;

-- SELECT * FROM carr WHERE make = 'Maserati' LIMIT 1;

-- SELECT * FROM personn LIMIT 10;

-- UPDATE personn SET car_id = (SELECT id FROM carr WHERE make = 'Maserati' LIMIT 1) WHERE first_name = 'Leonerd';
-- SELECT * FROM personn WHERE first_name = 'Leonerd';

-- UPDATE personn SET car_id = 47 WHERE first_name = 'Skipper';

-- SELECT p.first_name, p.last_name, p.email,c.make FROM personn AS p INNER JOIN carr AS c ON p.car_id = c.id WHERE email NOTNULL;

-- SELECT * FROM personn WHERE LENGTH(first_name) = (SELECT MAX(LENGTH(first_name)) FROM personn);

-- SELECT country_of_birth, COUNT(*) FROM personn GROUP BY country_of_birth ORDER BY COUNT(*) DESC LIMIT 1;

-- SELECT * FROM personn WHERE country_of_birth = 'China' AND car_id NOTNULL;

-- SELECT ASCII(LEFT(first_name, 1)), first_name FROM personn LIMIT 10;

-- SELECT * FROM personn WHERE car_id NOTNULL;

-- view olusturma
-- CREATE OR REPLACE VIEW view1 AS
-- SELECT * FROM personn WHERE car_id IS NOT NULL;
-- SELECT * FROM view1;

-- CREATE OR REPLACE VIEW check_wiew AS
-- SELECT * FROM personn WHERE LENGTH(personn.first_name::text) > 6
-- WITH CHECK OPTION;

-- check_view kontrol
-- INSERT INTO check_wiew (id, first_name, last_name, email, gender, date_of_birth, country_of_birth) VALUES
-- (108, 'Deneme123', 'Denemelast', 'denemeâgmail.com', 'Male', DATE '2000-02-02', 'Turkey');


-- degisken tanımlama islemleri
-- örnek 1
-- DO $$
-- DECLARE 
--     x INTEGER:= 22;
--     y INTEGER:= 11;
--     toplam INTEGER;
-- BEGIN
-- RAISE NOTICE 'X: %', x;
-- RAISE NOTICE 'Y: %', y;
-- RAISE NOTICE 'Toplam: %', (x+y);
-- END $$;

-- örnek 2
-- DO $$
-- DECLARE
--     name VARCHAR(50):= 'Ersel';
--     last_name VARCHAR(50):= 'Kızmaz';
--     age INTEGER;
-- BEGIN
-- age:= (SELECT EXTRACT(YEAR FROM AGE(NOW(), '1997-05-09')));
-- RAISE NOTICE '% % % yasındadır.', name, last_name, age;
-- END $$;

-- örnek 3: tablo ile
-- CREATE OR REPLACE VIEW variable_view AS
-- DO $$
-- DECLARE
--     kar_sayisi INTEGER;
--     name VARCHAR(50);
-- BEGIN
--     kar_sayisi:= (SELECT MAX(LENGTH(first_name)) FROM personn);
--     name:= (SELECT first_name FROM personn WHERE LENGTH(first_name) = (SELECT MAX(LENGTH(first_name)) FROM personn) LIMIT 1);
--     RAISE NOTICE 'En uzun karaktere sahip olan isim: %', name;
-- END $$;

-- karar yapıları
-- DO $$
-- DECLARE
--     sinav1 INTEGER:= 50;
--     sinav2 INTEGER:= 60;
--     sinav3 INTEGER:= 70;
--     ortalama NUMERIC;
-- BEGIN
--     ortalama := (sinav1 + sinav2 + sinav3) / 3;
--     RAISE NOTICE 'Sınavların ortalaması: %', ortalama;
--     if ortalama >= 65 THEN
--     RAISE NOTICE 'Tebrikler dersi geçtiniz.';
--     else 
--     RAISE NOTICE 'Bu notlar ile dersten kaldınız.';
--     end if;
-- END $$;

-- tablolar ile karar yapısı
-- DO $$
-- DECLARE
--     adet INTEGER;
--     ulke VARCHAR;
-- BEGIN
--     adet := (SELECT COUNT(*) FROM personn GROUP BY country_of_birth ORDER BY COUNT(*) DESC LIMIT 1);
--     ulke := (SELECT country_of_birth FROM personn GROUP BY country_of_birth HAVING COUNT(*) = (
--             SELECT COUNT(*) FROM personn GROUP BY country_of_birth ORDER BY COUNT(*) DESC LIMIT 1));
--     RAISE NOTICE 'En fazla doğunulan ülke: %, adedi: % ', ulke, adet;
-- END $$;
-- ee karar yapıları nerde? gjhjsjd neyse sonra bak!

-- case kullanımı
-- SELECT first_name, gender,
-- CASE
--     WHEN LENGTH(first_name) >= 7
--     THEN 'Geçti'
--     WHEN LENGTH(first_name) >= 5 AND LENGTH(first_name) < 7
--     THEN 'Orta'
--     ELSE 'Kaldı'
-- END durum
-- FROM personn LIMIT 50;

-- while kullanımı
-- DO $$
-- DECLARE
--     sayac INTEGER := 1;
--     toplam INTEGER := 0;
-- BEGIN 
--     while sayac <= 10 loop
--     RAISE NOTICE 'Sayac durumu: %', sayac;
--     toplam := toplam + sayac;
--     sayac := sayac + 1;
--     end loop;
--     RAISE NOTICE 'Sayacların toplamı: %', toplam;
-- END $$

-- loop kullanımı (while ile aynı denilebilir.)
-- DO $$
-- DECLARE
--     sayac INTEGER := 1;
--     toplam INTEGER := 0;
-- BEGIN
--     loop
--         exit when sayac = 10;
--         RAISE NOTICE 'Merhaba Ersel Kızmaz';
--         toplam := toplam + sayac;
--         sayac := sayac + 1;
--     end loop;
--     RAISE NOTICE 'Ardışık sayıların toplamı: %', toplam;
-- END $$;

-- procedures (fonksiyonlara benziyor!)
-- CREATE OR REPLACE PROCEDURE deneme()
-- LANGUAGE plpgsql AS $$
-- BEGIN
--     RAISE NOTICE 'PostgreSQL ögrenmeye devam ediyorum.';
-- END $$;
-- proceduru cagırmak icin; CALL (procedur_name)
-- CALL deneme();

-- parametreli procedure kullanımı
-- CREATE PROCEDURE person_procedure(a INT, b VARCHAR, c VARCHAR, d VARCHAR, e DATE, f VARCHAR)
-- LANGUAGE plpgsql AS $$
-- BEGIN
-- INSERT INTO person (id, first_name, last_name, gender, date_of_birth, email) VALUES
-- (a, b, c, d, e, f);
-- END $$;
-- CALL person_procedure(3, 'Ersel', 'Kızmaz', 'Male', '1997-05-09', 'ersel@gmail.com');

-- SELECT * FROM person;


-- UUID'yi anlama
-- SELECT pg_typeof(uuid_generate_v1()::text);
-- SELECT uuid_generate_v4(), uuid_generate_v4()::varchar;

-- ALTER TABLE person ALTER COLUMN id TYPE UUID; column data type degistirme (calısmadı!)
-- UPDATE person SET uuid = uuid_generate_v4() WHERE id = 2;

-- procedure ile uuid tanımlama
DROP PROCEDURE uuid_tanimlama(table_name VARCHAR);
CREATE OR REPLACE PROCEDURE uuid_tanimlama()
LANGUAGE plpgsql AS $$
DECLARE
    sayac INTEGER := 1;
    id_degeri INTEGER;
    dongu_limit INTEGER;
BEGIN 
    dongu_limit := (SELECT MAX(id) FROM car);
    while sayac <= dongu_limit loop
        id_degeri := (SELECT id FROM car WHERE id = sayac);
        if id_degeri NOTNULL THEN
            UPDATE car SET uuid_tanimlama = uuid_generate_v4() WHERE id = id_degeri;
        end if;
        sayac := sayac + 1;
    end loop;
END $$

CALL uuid_tanimlama();

-- yeni column ekleme
SELECT * FROM car;
SELECT * FROM person;
ALTER TABLE person ADD COLUMN car_id2 UUID;
-- column data type degistirme
ALTER TABLE person ALTER COLUMN car_id TYPE UUID;
-- unique ekleme
ALTER TABLE person ADD CONSTRAINT unique_car2 UNIQUE (car_id2);
ALTER TABLE car ADD CONSTRAINT unique_car1 UNIQUE (uuid_tanimlama);
UPDATE person SET car_id = (SELECT uuid_tanimlama FROM car WHERE make = 'Mercedes-Benz' LIMIT 1) WHERE uuid = '09ba09f9-bc12-41ef-afaa-eae9d0185771';

-- alter table ile foreign key ekleme
ALTER TABLE person ADD CONSTRAINT const_fk
FOREIGN KEY (car_id2) REFERENCES car(uuid_tanimlama) ON DELETE CASCADE;

UPDATE person SET car_id2 = (SELECT uuid_tanimlama FROM car WHERE uuid_tanimlama = 'b3f59917-093f-45eb-aa11-9e53d502fdec') WHERE id = 2;
SELECT * FROM person WHERE id = 3;
SELECT * FROM person;
-- id'ye sahip olan her şeyi siler
DELETE FROM car WHERE uuid_tanimlama = 'b3f59917-093f-45eb-aa11-9e53d502fdec';


CREATE DATABASE EnglishWords OWNER ersel;
