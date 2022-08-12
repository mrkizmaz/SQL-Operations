		-- ### ORTA SEVIYE POSTRESQL SORGULARI ### --
/*
https://www.mockaroo.com/ sitesinden 'person' tablosu olusturuldu
ve test database'e aktarıldı.
*/

SELECT * FROM information_schema.columns; -- database hakkında tüm bilgileri verir
SELECT * FROM information_schema.columns WHERE table_name = 'person'; -- person tablosundaki tüm bilgiler

SELECT * FROM person LIMIT 5; -- tablo ön görünümü

-- ////// VIEW \\\\\\ 
-- Kullanımı; (uzun sorguları kısayol haline getirir ve kolay calıstırılır)
-- NOT: view, bir tablo degildir!
CREATE [OR REPLACE] VIEW view_name AS queries; -- 1
CREATE OR REPLACE VIEW view_name AS queries
WITH CHECK OPTION; -- 2 (checkli)
SELECT * FROM view_name; -- view'i calıstırma

DROP VIEW [IF EXISTS] view_name [CASCADE | RESTRICT]; -- view silme 

-- örnek 1: uzun sorguyu kısa haline getirme
CREATE OR REPLACE VIEW view_email AS
SELECT * FROM person WHERE email IS NULL LIMIT 5;
SELECT * FROM view_email;
DROP VIEW view_email;

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

-- örnek 3: cözüm 1; person tablosuna uuid column ekleme ve her bir veriye uuid tanımlama
-- UUID'yi anlama
CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- database'e uuid extension yükleme
SELECT uuid_generate_v4(); -- evrensel id tanımlar

ALTER TABLE person ADD COLUMN uid UUID DEFAULT uuid_generate_v4(); -- kısayol; her bir veriye uuid tanımlar
ALTER TABLE person DROP COLUMN uid;

/*
örnek 3: cözüm 2; 
person tablosundan ilk 10 veriyi yeni bir tablo ile alıp,
id columnun ismini ve tipini degistirdikten sonra her veriye procedure ile uuid tanımlama
-- NOT: var olan tabloya sonradan yeni column eklendikten sonra, procedure ile yeni eklenen columna islem yapılamıyor! (denendi olmadı)
*/

CREATE VIEW person_ozellikleri AS 
SELECT * FROM information_schema.columns WHERE table_name = 'person'; -- tablo bilgilerini view ile uzun sorguyu kısa hale getirme 
SELECT * FROM person_ozellikleri; -- id columnda not null özelligi var! (kaldırılmalı)

CREATE TABLE person10 AS
SELECT * FROM person ORDER BY id ASC LIMIT 10; -- yeni tablo olusturarak ana tablonun yapısı bozulmaz (gecici tablo da olusturulabilir!)
 -- constaint özellikleri yok!
DROP TABLE person10; -- tabloyu silmek icin
SELECT * FROM person10;

CREATE OR REPLACE PROCEDURE column_sifirla()
LANGUAGE plpgsql AS $$
DECLARE
	sayac INTEGER:= 1;
	dongu_limit INTEGER;
BEGIN
	dongu_limit:= (SELECT MAX(id) FROM person10);
	WHILE sayac <= dongu_limit 
		LOOP
			UPDATE person10 SET id = NULL WHERE id = sayac;
			sayac:= sayac + 1;
		END LOOP;
	RAISE NOTICE 'Tüm islemler basarıyla tamamlandı';
END $$; -- tüm idleri null yapma islevi

CALL column_sifirla();

SELECT * FROM person10; -- person10 tablosunun son görünümünü inceleme

ALTER TABLE person10 RENAME COLUMN id TO uid; -- id columnun ismini degistirme
ALTER TABLE person10 ALTER COLUMN uid TYPE VARCHAR USING uid::VARCHAR; 
ALTER TABLE person10 ALTER COLUMN uid TYPE UUID USING uid::UUID;-- uid columnun tipini degistirme
-- NOT: bigint veritipi dogrudan uuid'ye cevrilemedi, önce varchar sonra uuid'ye cevrilerek yapılması gerek!
SELECT * FROM person10; -- veritipi kontrol

CREATE OR REPLACE PROCEDURE uuid_tanimlama()
LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	UPDATE person10 SET uid = uuid_generate_v4() WHERE uid IS NULL;
	RAISE NOTICE 'Tüm islemler basarıyla tamamlandı.';	
END $$;

CALL uuid_tanimlama(); -- procedure cagırma
DROP PROCEDURE uuid_tanimlama();

SELECT * FROM person10; -- person10 tablosunun son hali

-- örnek 3: cözüm 3; cok kısa yol
UPDATE person10 SET uid = uuid_generate_v4() WHERE uid IS NULL; -- procedure kullanılmadan da yapılabilir! (sonradan kesfedildi :)

SELECT pg_sleep(5); -- uyuma zamanı saniye cinsinden
SELECT * FROM person LIMIT 5;

-- ////// FONKSIYONLAR \\\\\\
-- Kullanımı;
-- Procedure'dan farkı dıs dünyaya deger vermesi
CREATE FUNCTION func_name(parameters)
RETURNS data_type -- dıs dünyaya gönderilen degerin tipi
LANGUAGE plpgsql AS $$
DECLARE
	variable
BEGIN
	islemler
	RETURN variable
END $$; -- temel kullanım
SELECT func_name(parameters); -- fonksiyonnu calıstırır
SELECT column_names, func_name(parameters) FROM tablename; -- tablolarda kullanımında sonucu ek columnda verir

-- Tablo sonuclu fonksiyon kullanımı;
CREATE FUNCTION func_name(prmt)
RETURN table (new_table_columns_with_datatypes)
LANGUAGE plpgsql AS $$
DECLARE
BEGIN
	RETURN QUERY
		queries
END $$;
SELECT * FROM func_name(prmt);

-- örnek 1: iki sayının toplamı (parametreli)
CREATE FUNCTION toplam(s1 INT, s2 INT)
RETURNS INT
LANGUAGE plpgsql AS $$
DECLARE
	sonuc INT;
BEGIN
	sonuc:= s1 + s2;
	RETURN sonuc;
END $$;

SELECT toplam(14, 8); -- fonksiyonun calıstırılması

-- örnek 2 (tablo ile): person tablosunun emailin maximum uzunlugundan her bir emailin uzunlugunu cıkararak yeni columna ekleme! (parametreli)
-- sacma örnek gibi, önemli olan mantıgını kavramak!
CREATE OR REPLACE FUNCTION email_max_length()
RETURNS INTEGER
LANGUAGE "plpgsql" AS
$$
DECLARE
	max_uzunluk INTEGER;
BEGIN
	max_uzunluk:= (SELECT MAX(LENGTH(email)) FROM person);
	RETURN max_uzunluk;
END
$$;
DROP FUNCTION email_max_length(character varying); -- function drop etme

SELECT id, first_name, email, email_max_length() - LENGTH(email) AS "maxlen-len" FROM person LIMIT 10;

-- örnek 3 (tablo ile): person tablosundan fonksiyon yardımıyla bir parametre girilerek yeni bir tablo yaratma
CREATE OR REPLACE FUNCTION prmtre_ile_tablo(chr VARCHAR)
RETURNS TABLE (
	yeni_id BIGINT,
	yeni_firstname VARCHAR,
	yeni_email VARCHAR) -- column veri tipleri ilgili tablo ile aynı olmalı!
LANGUAGE "plpgsql" AS
$$
DECLARE
BEGIN
	RETURN QUERY
		SELECT id, first_name, email FROM person
		WHERE first_name LIKE chr;
END
$$;
DROP FUNCTION prmtre_ile_tablo(character varying);

SELECT * FROM prmtre_ile_tablo('%er%'); -- ilgili column verilerinde 'er' olanları getiren function

-- ////// TRIGGERS \\\\\\
/* Bir tablodan herhangi bir degisiklik (insert, update, select, delete, etc) yapıldıktan sonra
bir baska tablonun veya aynı tablonun bu durumdan etkilenmesidir. */
-- Kullanımı;
-- önce fonksiyon islevi olusturulur;
CREATE [OR REPLACE] FUNCTION trig_name()
	RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
	variable_type -- kullanılmayadabilir (parametreli oldugunda kullanılır genelde)
BEGIN
	UPDATE foreign_table SET columnname = columnname + 1 -- farklı sorgularda yazılabilir
	RETURN NEW;
END $$;
-- sonra trigger;
CREATE TRIGGER testtrig
AFTER INSERT [SELECT, DELETE, etc.]-- hangi sorgu yapıldıgında?
ON target_table
FOR EACH ROW -- her bir satır icin
EXECUTE PROCEDURE trig_name();

-- person tablosuyla iliskili yeni bir tablo olusturularak triggerlar olusturma;
-- örnek 1: person tablosundaki veriler ve yeni eklenecek olan verilerin toplam sayısını gösteren trigger,
-- I. islem;
CREATE TABLE IF NOT EXISTS person_trigger_table (
	toplam_veri INTEGER );
INSERT INTO person_trigger_table (toplam_veri) VALUES ((SELECT COUNT(*) FROM person));
SELECT * FROM person_trigger_table;
-- II. islem;
CREATE OR REPLACE FUNCTION person_count_data()
	RETURNS TRIGGER
LANGUAGE "plpgsql" AS
$$
DECLARE
BEGIN
	UPDATE person_trigger_table SET toplam_veri = toplam_veri + 1;
	RETURN NEW;
END
$$;
-- III. islem;
CREATE TRIGGER test_person_trigger
AFTER INSERT
ON person
FOR EACH ROW
EXECUTE PROCEDURE person_count_data();
-- trigger kontrol;
INSERT INTO person (id, first_name, last_name, email, gender, dob, cob)
VALUES
	(1003, 'trigger', 'kontrol', 'trigger@gmail.com', 'Male', '2022-08-06', 'Denmark'); -- person tablosuna veri ekleme

INSERT INTO person (id, first_name, last_name, email, gender, dob, cob)
VALUES
	(1004, 'trigger2', 'kontrol2', 'trigger2@gmail.com', 'Male', '2022-08-06', 'Denmark'),
	(1005, 'trigger3', 'kontrol3', 'trigger3@gmail.com', 'Female', '2022-08-07', 'Canada'),
	(1006, 'trigger4', 'kontrol4', 'trigger4@gmail.com', 'Female', '2022-08-08', 'German'); -- coklu veri ekleme

SELECT * FROM person_trigger_table; -- toplam veri sayısını inceleme

-- örnek 2: person tablosunda 'first_name' columnda yer alan bütün veriler ve yeni eklenecek olan verilerin toplam karakter uzunlugunu triggerlama,
-- I. islem;
ALTER TABLE person_trigger_table ADD COLUMN fn_toplam_karakter BIGINT; -- trigger tabloya yeni column ekleme
UPDATE person_trigger_table 
SET fn_toplam_karakter = (
	SELECT SUM(LENGTH(first_name)) FROM person ); -- first_name columndaki verilerin toplam karakter sayısını yeni tabloya ekleme
SELECT * FROM person_trigger_table;
-- II. islem;
CREATE OR REPLACE FUNCTION personfn_char_length()
	RETURNS TRIGGER
LANGUAGE "plpgsql" AS
$$
DECLARE
	uzunluk INTEGER;
BEGIN
	uzunluk:= (SELECT LENGTH(first_name) FROM person ORDER BY id DESC LIMIT 1);
	UPDATE person_trigger_table SET fn_toplam_karakter = fn_toplam_karakter + uzunluk;
	RETURN NEW;
END
$$;
-- III. islem;
CREATE TRIGGER test_person_trigger2
AFTER INSERT
ON person
FOR EACH ROW
EXECUTE PROCEDURE personfn_char_length();
-- trigger kontrol;
INSERT INTO person (id, first_name, last_name, email, gender, dob, cob)
VALUES
	(1007, '10karakter', 'kontrol', 'karakter@gmail.com', 'Male', '2022-08-09', 'Finland'); -- yeni veri ekleme

SELECT * FROM person_trigger_table; -- toplam karakter sayısını inceleme

/*
???: peki ya person tablosundan veri silinirse triggerlar etkilenir mi? (denendi ve etkilenmedi!)
Bu sorunu düzeltmek icin yeni triggerlar olusturulması gerekir!
Yukarıdaki islemler ile aynı, sadece 
			+ --> - ve
			INSERT --> DELETE ile degistirilmesi gerekir. Uzun oldugu icin yapmadım :/
*/

-- örnek 3: person tablosundan silinen son veriyi trigger tablosuna kaydetme, 
-- NOT: herhangi rasgele bir veri silindiginde triggerlama olmadı! (parametreli trigger olmuyor, denendi!)
-- I. islem;
ALTER TABLE person_trigger_table ADD COLUMN silinen_son_veri TEXT; -- trigger tabloya yeni column ekleme
SELECT * FROM person_trigger_table;
-- II. islem;
CREATE OR REPLACE FUNCTION silinen_son_veri()
	RETURNS TRIGGER
LANGUAGE "plpgsql" AS
$$
DECLARE
	sil_id INTEGER;
	uzunluk INTEGER;
	veri TEXT;
BEGIN
	sil_id:= (SELECT id FROM person ORDER BY id DESC LIMIT 1);
	uzunluk:= (SELECT LENGTH(first_name) FROM person ORDER BY id DESC LIMIT 1);
	veri:= (SELECT CONCAT_WS(',', id, first_name, last_name, email, gender, dob, cob) FROM person WHERE id = sil_id);
	UPDATE person_trigger_table
		SET silinen_son_veri = veri,
			toplam_veri = toplam_veri - 1,
			fn_toplam_karakter = fn_toplam_karakter - uzunluk;
	RETURN NEW;
END
$$;
-- III. islem;
CREATE TRIGGER test_person_trigger3
AFTER DELETE
ON person
FOR EACH ROW
EXECUTE PROCEDURE silinen_son_veri();
-- trigger kontrol;
SELECT * FROM person_trigger_table; -- islemden önceki tablo durum kontrolü
DELETE FROM person WHERE id = 1007; -- son veriyi silme
SELECT * FROM person_trigger_table; -- islemden sonraki tablo durum kontrolü
/*
NOT: silinen son veriyi degil, son veriden bir öncekini ekliyor
bunun nedeni silme isleminin triggerdan önce calısması olabilir! 
Ama triggerlar sorunsuz calısıyor :)
*/

-- ////// INDEXES \\\\\\
-- Büyük veri boyutlarında sorgu performansını yüksek ve gpu yogunlugunu düsürmek icin kullanılır.
-- Index ile ilgili detaylı bilgi icin: https://www.farukerdem.com/postgresql-index/2021/02/26

/* 
////// EK BILGILER \\\\\\
# CSV dosyasını veri tabanına aktarma (import) islemi;
	1. CSV dosyasındaki verilerin column isimleri ile benzer sekilde yeni tablo olusturulur
	2. COPY table_name(column1, column2, ...) FROM 'dosya_yolu' DELIMETER ',' CSV HEADER;
   ya da COPY table_name FROM 'dosya_yolu' DELIMETER ',' CSV HEADER;

# Dısardan veri tabanı yüklemek icin;
	https://www.postgresqltutorial.com/postgresql-getting-started/load-postgresql-sample-database/
*/


