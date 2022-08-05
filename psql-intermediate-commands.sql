		-- ### ORTA SEVIYE POSTRESQL SORGULARI ### --
/*
https://www.mockaroo.com/ sitesinden person tablosu olusturuldu
ve test database'e aktarıldı.
*/

SELECT * FROM information_schema.columns; -- database hakkında tüm bilgileri verir
SELECT * FROM information_schema.columns WHERE table_name = 'person'; -- person tablosundaki tüm bilgiler

SELECT * FROM person LIMIT 5; -- tablo ön görünümü

-- ////// VIEW \\\\\\ 
-- Kullanımı; (uzun sorguları kısayol haline getirir ve kolay calıstırılır)
CREATE [OR REPLACE] VIEW view_name AS queries; -- 1
CREATE OR REPLACE VIEW view_name AS queries
WITH CHECK OPTION; -- 2 (checkli)
SELECT * FROM view_name; -- view'i calıstırma

DROP VIEW [IF EXISTS] view_name [CASCADE | RESTRICT]; -- view silme 

-- örnek 1: uzun sorguyu kısa haline getirme
CREATE OR REPLACE VIEW view_email AS
SELECT * FROM person WHERE email IS NULL LIMIT 5;
SELECT * FROM view_email;

-- örnek 2: checkli view olusturma
CREATE VIEW check_view AS
SELECT * FROM person WHERE LENGTH(person.first_name::text) > 6
WITH CHECK OPTION;

INSERT INTO check_view (id, first_name, last_name, email, gender, dob, cob)
VALUES (1002, 'Ersel', 'Kızmaz', 'ersel@gmail.com', 'Male', '2000-02-02', 'Canada'); -- hata verir (check!)

-- ////// DEGISKEN TANIMLAMA ISLEMLERI \\\\\\ 
-- Kullanımı;
DO $$
DECLARE
	degisken degisken_tipi:= deger; -- degisken burada tanımlanır
BEGIN
	degisken:= deger; -- degiskenin degeri burada da verilir
RAISE NOTICE 'degisken: %', degisken; -- degiskeni yazdırma islemi
END $$;

-- örnek 1: degiskenleri yazdırma
DO $$
DECLARE
	x INTEGER:= 22;
	y INTEGER:= 10;
	toplam INTEGER:= (x+y);
BEGIN
RAISE NOTICE 'X: %', x;
RAISE NOTICE 'Y: %', y;
RAISE NOTICE 'Toplam = %', toplam;
END $$;

-- örnek 2: degiskeni sorgu ile atama
DO $$
DECLARE
	first_name VARCHAR:= 'Ersel';
	last_name VARCHAR:= 'Kizmaz';
	age INTERVAL:= (SELECT AGE(NOW()::DATE, DATE '1997-05-09'));
BEGIN
RAISE NOTICE 'I am % % and my age is %.', first_name, last_name, age;
END $$;

-- örnek 3 (tablo ile): person tablosunda first_name columnda en uzun karaktere sahip olanı yazdırma	
DO $$
DECLARE
	krkter_sayisi INTEGER;
	name VARCHAR;
BEGIN
	krkter_sayisi:= (SELECT MAX(LENGTH(first_name)) FROM person);
	name:= (SELECT first_name FROM person WHERE LENGTH(first_name) = (
					SELECT MAX(LENGTH(first_name)) FROM person ));
RAISE NOTICE
	'En uzun karaktere sahip olan isim: %, karakter sayisi: %', 
	name, krkter_sayisi;
END $$;

-- ////// KARAR YAPILARI (IF) \\\\\\ 
-- Kullanımı;
DO $$
DECLARE -- bu bölümde degiskenler de tanıtılabilir
	IF conditions THEN
		statements;
	ELSE
		alternative_condition;
	END IF;
BEGIN
	-- bu bölümde de if kalıpları kullanılır
END $$

-- örnek 1: sınav ortalamasının hesaplanması
DO $$
DECLARE
	sinav1 INTEGER:= 50;
	sinav2 INTEGER:= 80;
	sinav3 INTEGER:= 100;
	ortalama NUMERIC; -- ortalama float olabilir!
BEGIN
	ortalama:= ROUND((sinav1 + sinav2 + sinav3)::NUMERIC / 3, 2);
	IF ortalama <= 30 THEN
		RAISE NOTICE 'Ortalamanız: %. Bu dersten kaldınız!', ortalama;
	ELSEIF ortalama > 30 AND ortalama <= 65 THEN
		RAISE NOTICE 'Ortalamanız: %. Bu dersten sartlı gectiniz!', ortalama;
	ELSE
		RAISE NOTICE 'Ortalamanız: %. Bu dersi basarıyla gectiniz, tebrikler!', ortalama;
	END IF;
END $$;

-- örnek 2 (tablo ile): daha sonra yap!

-- ////// CASE \\\\\\ 
-- Kullanımı; (select ile kullanılır, tabloya ek column da ekleyebilir)
SELECT 
CASE 
	WHEN condition1 THEN statment1;
	WHEN condition2 THEN statment2;
	ELSE statment3;
END case_name;

-- örnek 1: durum yazdırma
SELECT 
CASE 
	WHEN 5 > 3 THEN 'buyuk'
	WHEN 5 < 3 THEN 'kucuk'
END casedurum;

-- örnek 2 (tablo ile): person tablosunda belirli yasları ek columna yazdırma
SELECT first_name, gender, dob,
CASE
	WHEN dob <= DATE '2010-01-01' 
	THEN '10 yas altı'
	WHEN dob > DATE '2010-01-01' AND dob <= DATE '2015-01-01'
	THEN '10-15 yas arası'
	ELSE
		'15+ yas'
END belirli_yaslar
FROM person LIMIT 50;

-- ////// WHILE \\\\\\
-- Kullanımı;
DO $$
DECLARE
	i
BEGIN
	WHILE i <= border -- (border kosulu farketmez)
	LOOP
		statements
		i:= i + 1;
	END LOOP;
END $$;

-- örnek 1: 1-10 arası sayıların toplamı
DO $$
DECLARE
	sayac INTEGER:= 1;
	toplam INTEGER:= 0;
BEGIN
	WHILE sayac <= 10 LOOP
	RAISE NOTICE 'Sayac durumu: %', sayac;
	toplam:= toplam + sayac;
	sayac:= sayac + 1;
	END LOOP;
	RAISE NOTICE 'Sayıların toplamı: %', toplam;
END $$;

-- örnek 2: (tablo ile): tablo ile kullanımı nasıl olur? Daha sonra yap!

-- ////// LOOP \\\\\\
-- Kullanımı; (calısma mantıgı while ile aynı)
DO $$
DECLARE
	i
BEGIN
	LOOP
	EXIT WHEN i = border;
	i:= i + 1;
	END LOOP;
END $$;

-- örnek: bir metni 10 defa yazdırma
DO $$
DECLARE
	sayac INTEGER:= 1;
BEGIN
	LOOP
	EXIT WHEN sayac = 11; -- loop icinde her yerde kullanılabilir!
	RAISE NOTICE '%. sayac, Merhaba Ersel Kızmaz', sayac;
	sayac:= sayac + 1;
	END LOOP;
END $$;

-- ////// PROCEDURES \\\\\\
-- Kullanımı;
CREATE [OR REPLACE] PROCEDURE procedure_name(paramaters) -- parametresiz de olabilir!
LANGUAGE plpgsql AS $$
DECLARE
	statements
BEGIN
	statements
END $$;

CALL procedure_name(paramaters); -- procedure calıstırma
DROP PROCEDURE procedure_name(parameters); -- procedure kaldırma

-- örnek 1: parametresiz procedure kullanımı
CREATE OR REPLACE PROCEDURE parametresiz_pro()
LANGUAGE plpgsql AS $$
DECLARE -- kullanılmayadabilir
BEGIN
	RAISE NOTICE 'PostgreSQL ögrenmeye devam ediyorum.';
END $$;

CALL parametresiz_pro();
DROP PROCEDURE parametresiz_pro();

-- örnek 2 (tablo ile): person tablosuna parametreli procedure yardımıyla veri ekleme
CREATE PROCEDURE person_veri_ekle(
	a INT, b VARCHAR, c VARCHAR, d VARCHAR, e VARCHAR, f DATE, g VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
	INSERT INTO person (id, first_name, last_name, email, gender, dob, cob)
	VALUES (a, b, c, d, e, f, g);
	RAISE NOTICE 'Veriler basarıyla eklendi.';
END $$;

CALL person_veri_ekle(1002, 'Deneme', 'Verisi', 'deneme@gmail.com', 'Male', '2022-08-05', 'Canada');
SELECT * FROM person WHERE id = 1002; -- veri eklendi mi?
DROP PROCEDURE person_veri_ekle(a INT, b VARCHAR, c VARCHAR, d VARCHAR, e VARCHAR, f DATE, g VARCHAR); -- procedure kaldırma





