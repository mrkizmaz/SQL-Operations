
-- ERSEL KIZMAZ - ersel.kizmaz@gmail.com

--				////////// Microsoft SQL Queries \\\\\\\\\\

/* 
SORU 1: HR isimli database yaratma ve 'HR.xlsx' dosyasý icerisindeki tablolarý sql sorgularý ile olusturma 
*/

CREATE DATABASE HR;
USE HR;

-- position tablosunu olusturma
CREATE TABLE POSITION (
	ID SMALLINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	POSITION NVARCHAR(40) NOT NULL
	);

-- department tablosunu olusturma
CREATE TABLE DEPARTMENT (
	ID SMALLINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	DEPARTMENT NVARCHAR(40) NOT NULL
	);

-- person tablosunu olusturma
CREATE TABLE PERSON (
	ID INT IDENTITY(1, 1) NOT NULL,
	CODE INT NOT NULL,
	TCNUMBER CHAR(11) NOT NULL,
	NAME_ NVARCHAR(40) NOT NULL,
	SURNAME NVARCHAR(40) NOT NULL,
	GENDER CHAR(1),
	BIRTHDATE DATE NOT NULL,
	INDATE DATE NOT NULL,
	OUTDATE DATE,
	DEPARTMENTID SMALLINT NOT NULL,
	POSITIONID SMALLINT NOT NULL,
	PARENTPOSITIONID SMALLINT NOT NULL,
	MANAGERID SMALLINT,
	TELNR VARCHAR(30) NOT NULL,
	SALARY SMALLMONEY NOT NULL,

	CONSTRAINT pk_person PRIMARY KEY (ID),
	CONSTRAINT fk_person_position
		FOREIGN KEY (POSITIONID)
			REFERENCES POSITION (ID),
	CONSTRAINT fk_person_department
		FOREIGN KEY (DEPARTMENTID)
			REFERENCES DEPARTMENT (ID),
	);

/* 
SORU 2: Excel dosyasýndaki kayýtlý verileri kopyala-yapýstýr yöntemi ile veritabanýna ekleme 
*/

-- veriler kopyala-yapýstýr yöntemi ile eklendikten sonra konrol islemleri,
SELECT * FROM POSITION;
SELECT * FROM DEPARTMENT;
SELECT TOP 10 * FROM PERSON; -- ilk 10 veriyi inceleme

SELECT COUNT(*) FROM PERSON; -- toplam 1780 veri
SELECT * FROM PERSON WHERE ID = 22; -- excel dosyasýndaki veri ile uyusuyor

/*
SORU 3: Þirketimizde halen çalýþmaya devam eden çalýþanlarýn listesini getiren sorguyu yazýnýz.
		NOT: Ýþten çýkýþ tarihi boþ olanlar çalýþmaya devam eden çalýþanlardýr.
*/

SELECT * FROM PERSON WHERE OUTDATE IS NULL;

/* 
SORU 4: Þirketimizde departman bazlý halen çalýþmaya devam eden KADIN ve ERKEK sayýlarýný getiren sorguyu yazýnýz. 
*/

SELECT d.DEPARTMENT,
	CASE 
		WHEN  p.GENDER = 'E' THEN 'Erkek'
		WHEN  p.GENDER = 'K' THEN 'Kadýn'
	END GENDER, 
	COUNT(p.DEPARTMENTID) AS PERSONCOUNT
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
WHERE p.OUTDATE IS NULL
GROUP BY p.GENDER, d.DEPARTMENT
ORDER BY 1, 2;

/*
SORU 5: Þirketimizde departman bazlý halen çalýþmaya devam eden 
KADIN ve ERKEK sayýlarýný ayrý columnlar halinde getiren sorguyu yazýnýz.
*/

SELECT d.DEPARTMENT,
	(SELECT COUNT(*) FROM PERSON AS p 
	 WHERE p.DEPARTMENTID = d.ID AND p.GENDER = 'E' AND p.OUTDATE IS NULL) AS MALE_PERSONCOUNT,
	(SELECT COUNT(*) FROM PERSON AS p 
	 WHERE p.DEPARTMENTID = d.ID AND p.GENDER = 'K' AND p.OUTDATE IS NULL) AS FEMALE_PERSONCOUNT
FROM DEPARTMENT AS d
ORDER BY d.DEPARTMENT;

/*
SORU 6: Þirketimizin Planlama departmanýna yeni bir þef atamasý yapýldý ve maaþýný belirlemek istiyoruz.
Planlama departmaný için minimum,maximum ve ortalama þef maaþýný getiren sorguyu yazýnýz.
NOT: Ýþten çýkmýþ olan personel maaþlarý da dahildir.
*/

SELECT po.POSITION, 
	MIN(p.SALARY) AS MIN_SALARY, 
	MAX(p.SALARY) AS MAX_SALARY,
	AVG(p.SALARY) AS AVG_SALARY
FROM POSITION AS po
INNER JOIN PERSON AS p ON p.POSITIONID = po.ID
WHERE po.POSITION = 'PLANLAMA ÞEFÝ'
GROUP BY po.POSITION;

/*
SORU 7: Her bir pozisyonda mevcut halde çalýþanlar olarak 
kaç kiþi ve ortalama maaþlarýnýn ne kadar olduðunu listelettirmek istiyoruz. 
Bu sonucu getiren sorguyu yazýnýz.
*/

SELECT po.POSITION, COUNT(po.ID) AS PERSONCOUNT, AVG(p.SALARY) AS AVG_SALARY
FROM POSITION AS po
INNER JOIN PERSON AS p ON p.POSITIONID = po.ID
WHERE p.OUTDATE IS NULL
GROUP BY po.POSITION
ORDER BY po.POSITION ASC;

/*
SORU 8: Yýllara göre iþe alýnan personel sayýsýný
kadýn ve erkek bazýnda listelettiren sorguyu yazýnýz.
*/

SELECT YEAR(INDATE) AS YEAR_,
	(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'E' AND YEAR(PERSON.INDATE) = YEAR(p.INDATE)) AS MALE_PERSON,
	(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'K' AND YEAR(PERSON.INDATE) = YEAR(p.INDATE)) AS FEMALE_PERSON
FROM PERSON AS p
GROUP BY YEAR(INDATE)
ORDER BY 1;

/*
SORU 9: Her bir personelimizin ne kadar zamandýr 
çalýþtýðý bilgisini ay olarak getiren sorguyu yazýnýz.
*/

-- sorgunun yazýldýgý tarihe göre islem yapýldý! (2022-09-05)
SELECT
	CONCAT(NAME_, ' ', SURNAME) AS PERSON,
	INDATE, OUTDATE,
	DATEDIFF(MONTH, INDATE, GETDATE()) AS WORKINGTIME
FROM PERSON; -- concat fonksiyonu string birlestirme icin kullanýldý

/*
SORU 10: Þirketimiz 5. yýlýnda üstünde herkesin isminin ve soyisminin baþ harflerinin 
bulunduðu bir ajanda bastýrýp çalýþanlarýna hediye edecektir. Bunun için hangi harf 
kombinasyonundan en az ne kadar sayýda bastýrýlacaðý sorusunun cevabýný getiren sorguyu yazýnýz.
NOT: Ýki isimli olanlarýn birinci isminin baþ harfi kullanýlacaktýr.
*/

SELECT tmp.SHORTNAME, COUNT(*) AS PERSONCOUNT 
FROM (
	SELECT CONCAT(LEFT(NAME_, 1), '.', LEFT(SURNAME, 1), '.') AS SHORTNAME
	FROM PERSON) AS tmp
GROUP BY tmp.SHORTNAME
ORDER BY 2 DESC;

/*
SORU 11: Maaþ ortalamasý 5.500 TL’den fazla olan departmanlarý listeleyecek sorguyu yazýnýz.
*/

SELECT d.DEPARTMENT, AVG(p.SALARY) AS AVG_SALARY
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
GROUP BY d.DEPARTMENT
HAVING AVG(p.SALARY) > 5500
ORDER BY d.DEPARTMENT;

/*
SORU 12: Departmanlarýn ortalama kýdemini ay olarak hesaplayacak sorguyu yazýnýz.
*/
-- sorgunun yazýldýgý tarihe göre islem yapýldý! (2022-09-05)
SELECT d.DEPARTMENT, AVG(DATEDIFF(MONTH, p.INDATE, GETDATE())) AS AVG_WORKINGTIME
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
GROUP BY d.DEPARTMENT;

/*
SORU 13: Her personelin adýný, pozisyonunu baðlý olduðu 
birim yöneticisinin adýný ve pozisyonunu getiren sorguyu yazýnýz.
*/

SELECT TOP 20
	CONCAT(p.NAME_, ' ', p.SURNAME) AS PERSON,
	po.POSITION,
	CONCAT(p1.NAME_, ' ', p1.SURNAME) AS MANAGER,
	po1.POSITION AS MANAGER_POSITION
FROM PERSON AS p
INNER JOIN PERSON AS p1 ON p1.ID = p.MANAGERID
INNER JOIN POSITION AS po ON po.ID = p.POSITIONID
INNER JOIN POSITION AS po1 ON po1.ID = p1.POSITIONID;

