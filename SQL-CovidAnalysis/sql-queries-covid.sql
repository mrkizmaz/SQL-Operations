
SELECT name FROM sqlite_master WHERE type = 'table'; -- tablolar
/*
Database icerisinde iki farklı tablo bulunmaktadır;
- CovidDeaths
- CovidVaccinations
*/

-- CovidDeaths TABLOSUNU INCELEME ISLEMLERI --

SELECT * FROM CovidDeaths LIMIT 5; -- ön izlenim
SELECT COUNT(*) FROM CovidDeaths; -- 85171 satır

PRAGMA table_info('CovidDeaths'); -- tablo veri tipi bilgisi

SELECT sql 
FROM sqlite_master
WHERE name = 'CovidDeaths'; -- tablo bilgisi (güzel sorgu :))

ALTER TABLE CovidDeaths RENAME COLUMN field1 TO id; -- columns ismini degistirme
ALTER TABLE CovidDeaths DROP COLUMN field1; -- column silme islemi olmuyor!! (böyle bisey yok)

SELECT DISTINCT continent FROM CovidDeaths 
WHERE continent NOT NULL; -- 6 kıta

SELECT DISTINCT iso_code FROM CovidDeaths; -- 219 essiz satır

SELECT DISTINCT location FROM CovidDeaths; -- 219 location(ülke)

-- Ilk Vakaların Incelenmesi Islemleri --
 
SELECT date, new_cases, location FROM CovidDeaths
WHERE new_cases > 0
GROUP BY location
ORDER BY date, new_cases ASC; -- ülkelere göre ilk vaka ne zaman oldu?

-- ilk vaka nerede ve ne zaman oldu? (23 ocak 2020'de 3 farklı ülkede ilk vakalar meydana gelmis)
SELECT date, new_cases, location, continent FROM CovidDeaths
WHERE new_cases > 0
ORDER BY date, new_cases ASC LIMIT 100;

-- kıtalara göre ilk vakalar ne zaman ve nerede oldu? (output yanlıs gibi!)
SELECT date, new_cases, location, continent FROM CovidDeaths
WHERE new_cases > 0
GROUP BY continent
ORDER BY date, location;

-- ne zaman ve nerede en cok yeni vaka bildirildi? (30 nisan 2021 india'da olmus: 401993 vaka)
SELECT date, max(new_cases) AS encokVaka, location FROM
(SELECT date, new_cases, location FROM CovidDeaths
WHERE new_cases > 0 AND location 
NOT IN ('World', 'Asia', 'Europe', 'North America', 'South America', 'European Union', 'Oceania', 'Africa')
ORDER BY date ASC);

SELECT date, new_cases, location FROM CovidDeaths
WHERE new_cases > 0 AND location = 'Turkey'
GROUP BY location
ORDER BY date; -- Türkiye'de ilk vaka ne zaman oldu? (11 Mart 2020'de 1 vaka)

-- Türkiye'de en cok ne zaman vaka bildirildi? (16 nisan 2021'de 63082 vaka bildirilmis)
SELECT date, new_cases, location FROM CovidDeaths
WHERE new_cases > 0 AND location IN ('Turkey')
ORDER BY new_cases DESC LIMIT 1;

SELECT date, new_cases, location FROM CovidDeaths
WHERE location = 'United States' AND new_cases > 0
GROUP BY location
ORDER BY date ASC; -- Amerika'da ilk vaka ne zaman oldu? (24 Ocak 2020'de 1 vaka)

SELECT date, total_cases_per_million, location FROM CovidDeaths
WHERE total_cases_per_million > 0
ORDER BY total_cases_per_million; -- ülkelere göre toplam vaka (milyon basına)

-- Ilk Ölümlerin Incelenmesi --

SELECT date, new_deaths, location FROM CovidDeaths
WHERE new_deaths > 0.0
GROUP BY location
ORDER BY new_deaths; -- ülkelere göre ilk ölümler ne zaman oldu?

-- ilk ölüm ne zaman ve nerede oldu? (23 ocak 2020 China, 1 ölüm bildirmis ama toplam ölüm 18!)
SELECT date, new_deaths, total_deaths, location FROM CovidDeaths
WHERE new_deaths > 0 AND location 
NOT IN ('World', 'Asia', 'Europe', 'North America', 'South America', 'European Union', 'Oceania', 'Africa')
ORDER BY date LIMIT 1;

-- en cok ölüm nerede ve ne zaman bildirilmis? (14 ocak mexico'da bildirilmis!)
SELECT date, max(new_deaths) AS encokDeath, location FROM
(SELECT date, new_deaths, location FROM CovidDeaths
WHERE new_deaths > 0.0 AND location NOT IN
('World', 'Asia', 'Europe', 'North America', 'South America', 'European Union', 'Oceania', 'Africa')
ORDER BY new_deaths DESC);

-- kıtalara göre ilk ölümler nerede ve ne zaman oldu? (ülkeleri dogru vermiyor gibi!!)
SELECT date, new_deaths, total_deaths, location, continent FROM CovidDeaths
WHERE new_deaths > 0.0
GROUP BY continent
ORDER BY date;

SELECT date, new_deaths, location FROM CovidDeaths
WHERE location = 'Turkey' AND new_deaths > 0.0
ORDER BY date
LIMIT 1; -- TR'de ilk ölüm ne zaman oldu? (17 Mart 2020)

-- TR'de en cok ölüm ne zaman bildirildi? (26 nisan 2020, 99 ölüm!!)
SELECT date, max(new_deaths) FROM
(SELECT date, new_deaths, location FROM CovidDeaths
WHERE new_deaths > 0.0 AND location = 'Turkey'
ORDER BY new_deaths DESC);

/* 
ÖNEMLI: verisetindeki bazı degiskenlerin veri tipi, sayısal olması gerekirken text olarak girilmis.
Daha sonra hallet !! ciddi bir sorun !!
*/

SELECT date, new_deaths, location FROM CovidDeaths
WHERE location LIKE '%states%' AND new_deaths > 0.1
ORDER BY date
LIMIT 1; -- Amerika'da ilk ölüm ne zaman oldu? (29 Şubat 2020)

SELECT
(SELECT COUNT(*) FROM 
(SELECT total_cases_per_million, location FROM CovidDeaths
GROUP BY location)) - 
(SELECT COUNT(*) FROM
(SELECT total_cases_per_million, location FROM CovidDeaths
WHERE total_cases_per_million NOT NULL
GROUP BY location)) AS null_notNoll; -- toplam null sayısı: 21 (bunu neden yaptım?)


SELECT MAX(total_cases), aged_65_older, location FROM CovidDeaths
WHERE aged_65_older NOTNULL
GROUP BY location
ORDER BY total_cases DESC LIMIT 100; -- bölgelere göre 65 yas üstü toplam vaka sayıları

SELECT MAX(total_cases_per_million), continent FROM CovidDeaths
WHERE total_cases_per_million NOTNULL
GROUP BY continent; -- milyon basına toplam vaka sayıları

SELECT MAX(weekly_hosp_admissions_per_million), location FROM CovidDeaths 
WHERE weekly_hosp_admissions_per_million NOTNULL
GROUP BY location; -- haftalık hastaneye yatırılan vaka sayıları bölgelere göre

SELECT MAX(weekly_hosp_admissions_per_million), location FROM CovidDeaths 
WHERE weekly_hosp_admissions_per_million NOTNULL; -- en cok hasta yatıran bölge

-- test sayılarının incelenmesi
SELECT date, new_tests, total_tests, location FROM CovidDeaths; 

SELECT MAX(total_tests) AS totalTest, location FROM CovidDeaths 
WHERE total_tests NOTNULL
GROUP BY location
ORDER BY totalTest DESC; -- bölgelere göre toplam test sayısı


SELECT date, new_cases, total_cases, location FROM CovidDeaths
WHERE location LIKE '%states%'; -- vaka sayılarının incelenmesi

SELECT date, new_deaths, total_deaths, location FROM CovidDeaths
WHERE location LIKE '%states%'; -- ölüm sayılarının incelenmesi

SELECT date, new_deaths, total_deaths, (new_deaths / total_deaths) AS oranDeath, location
FROM CovidDeaths
WHERE location LIKE '%states%'; -- ölüm oranlarının incelenmesi








