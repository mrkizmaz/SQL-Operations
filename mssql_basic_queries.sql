
-- ERSEL KIZMAZ - ersel.kizmaz@gmail.com

--				////////// Microsoft SQL Queries \\\\\\\\\\

/* 
SORU 1: HR isimli database yaratma ve 'HR.xlsx' dosyas� icerisindeki tablolar� sql sorgular� ile olusturma 
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
SORU 2: Excel dosyas�ndaki kay�tl� verileri kopyala-yap�st�r y�ntemi ile veritaban�na ekleme 
*/

-- veriler kopyala-yap�st�r y�ntemi ile eklendikten sonra konrol islemleri,
SELECT * FROM POSITION;
SELECT * FROM DEPARTMENT;
SELECT TOP 10 * FROM PERSON; -- ilk 10 veriyi inceleme

SELECT COUNT(*) FROM PERSON; -- toplam 1780 veri
SELECT * FROM PERSON WHERE ID = 22; -- excel dosyas�ndaki veri ile uyusuyor

/*
SORU 3: �irketimizde halen �al��maya devam eden �al��anlar�n listesini getiren sorguyu yaz�n�z.
		NOT: ��ten ��k�� tarihi bo� olanlar �al��maya devam eden �al��anlard�r.
*/

SELECT * FROM PERSON WHERE OUTDATE IS NULL;

/* 
SORU 4: �irketimizde departman bazl� halen �al��maya devam eden KADIN ve ERKEK say�lar�n� getiren sorguyu yaz�n�z. 
*/

SELECT d.DEPARTMENT,
	CASE 
		WHEN  p.GENDER = 'E' THEN 'Erkek'
		WHEN  p.GENDER = 'K' THEN 'Kad�n'
	END GENDER, 
	COUNT(p.DEPARTMENTID) AS PERSONCOUNT
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
WHERE p.OUTDATE IS NULL
GROUP BY p.GENDER, d.DEPARTMENT
ORDER BY 1, 2;

/*
SORU 5: �irketimizde departman bazl� halen �al��maya devam eden 
KADIN ve ERKEK say�lar�n� ayr� columnlar halinde getiren sorguyu yaz�n�z.
*/

SELECT d.DEPARTMENT,
	(SELECT COUNT(*) FROM PERSON AS p 
	 WHERE p.DEPARTMENTID = d.ID AND p.GENDER = 'E' AND p.OUTDATE IS NULL) AS MALE_PERSONCOUNT,
	(SELECT COUNT(*) FROM PERSON AS p 
	 WHERE p.DEPARTMENTID = d.ID AND p.GENDER = 'K' AND p.OUTDATE IS NULL) AS FEMALE_PERSONCOUNT
FROM DEPARTMENT AS d
ORDER BY d.DEPARTMENT;

/*
SORU 6: �irketimizin Planlama departman�na yeni bir �ef atamas� yap�ld� ve maa��n� belirlemek istiyoruz.
Planlama departman� i�in minimum,maximum ve ortalama �ef maa��n� getiren sorguyu yaz�n�z.
NOT: ��ten ��km�� olan personel maa�lar� da dahildir.
*/

SELECT po.POSITION, 
	MIN(p.SALARY) AS MIN_SALARY, 
	MAX(p.SALARY) AS MAX_SALARY,
	AVG(p.SALARY) AS AVG_SALARY
FROM POSITION AS po
INNER JOIN PERSON AS p ON p.POSITIONID = po.ID
WHERE po.POSITION = 'PLANLAMA �EF�'
GROUP BY po.POSITION;

/*
SORU 7: Her bir pozisyonda mevcut halde �al��anlar olarak 
ka� ki�i ve ortalama maa�lar�n�n ne kadar oldu�unu listelettirmek istiyoruz. 
Bu sonucu getiren sorguyu yaz�n�z.
*/

SELECT po.POSITION, COUNT(po.ID) AS PERSONCOUNT, AVG(p.SALARY) AS AVG_SALARY
FROM POSITION AS po
INNER JOIN PERSON AS p ON p.POSITIONID = po.ID
WHERE p.OUTDATE IS NULL
GROUP BY po.POSITION
ORDER BY po.POSITION ASC;

/*
SORU 8: Y�llara g�re i�e al�nan personel say�s�n�
kad�n ve erkek baz�nda listelettiren sorguyu yaz�n�z.
*/

SELECT YEAR(INDATE) AS YEAR_,
	(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'E' AND YEAR(PERSON.INDATE) = YEAR(p.INDATE)) AS MALE_PERSON,
	(SELECT COUNT(*) FROM PERSON WHERE GENDER = 'K' AND YEAR(PERSON.INDATE) = YEAR(p.INDATE)) AS FEMALE_PERSON
FROM PERSON AS p
GROUP BY YEAR(INDATE)
ORDER BY 1;

/*
SORU 9: Her bir personelimizin ne kadar zamand�r 
�al��t��� bilgisini ay olarak getiren sorguyu yaz�n�z.
*/

-- sorgunun yaz�ld�g� tarihe g�re islem yap�ld�! (2022-09-05)
SELECT
	CONCAT(NAME_, ' ', SURNAME) AS PERSON,
	INDATE, OUTDATE,
	DATEDIFF(MONTH, INDATE, GETDATE()) AS WORKINGTIME
FROM PERSON; -- concat fonksiyonu string birlestirme icin kullan�ld�

/*
SORU 10: �irketimiz 5. y�l�nda �st�nde herkesin isminin ve soyisminin ba� harflerinin 
bulundu�u bir ajanda bast�r�p �al��anlar�na hediye edecektir. Bunun i�in hangi harf 
kombinasyonundan en az ne kadar say�da bast�r�laca�� sorusunun cevab�n� getiren sorguyu yaz�n�z.
NOT: �ki isimli olanlar�n birinci isminin ba� harfi kullan�lacakt�r.
*/

SELECT tmp.SHORTNAME, COUNT(*) AS PERSONCOUNT 
FROM (
	SELECT CONCAT(LEFT(NAME_, 1), '.', LEFT(SURNAME, 1), '.') AS SHORTNAME
	FROM PERSON) AS tmp
GROUP BY tmp.SHORTNAME
ORDER BY 2 DESC;

/*
SORU 11: Maa� ortalamas� 5.500 TL�den fazla olan departmanlar� listeleyecek sorguyu yaz�n�z.
*/

SELECT d.DEPARTMENT, AVG(p.SALARY) AS AVG_SALARY
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
GROUP BY d.DEPARTMENT
HAVING AVG(p.SALARY) > 5500
ORDER BY d.DEPARTMENT;

/*
SORU 12: Departmanlar�n ortalama k�demini ay olarak hesaplayacak sorguyu yaz�n�z.
*/
-- sorgunun yaz�ld�g� tarihe g�re islem yap�ld�! (2022-09-05)
SELECT d.DEPARTMENT, AVG(DATEDIFF(MONTH, p.INDATE, GETDATE())) AS AVG_WORKINGTIME
FROM DEPARTMENT AS d
INNER JOIN PERSON AS p ON p.DEPARTMENTID = d.ID
GROUP BY d.DEPARTMENT;

/*
SORU 13: Her personelin ad�n�, pozisyonunu ba�l� oldu�u 
birim y�neticisinin ad�n� ve pozisyonunu getiren sorguyu yaz�n�z.
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

