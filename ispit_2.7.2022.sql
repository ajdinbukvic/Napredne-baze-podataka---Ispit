--1.a) Kreirati bazu pod vlastitim brojem indeksa.

CREATE DATABASE _177
GO

USE _177
GO

--1.b) Kreiranje tabela.

/*Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera

II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera


III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla*/

----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE produkt
(
	produktID int CONSTRAINT PK_Produkt PRIMARY KEY,
	jed_cijena money,
	kateg_naziv nvarchar(15),
	mj_jedinica nvarchar(20),
	dobavljac_naziv nvarchar(40),
	dobavljac_post_br nvarchar(10)
)

CREATE TABLE narudzba
(
	narudzbaID int CONSTRAINT PK_Narudzba PRIMARY KEY,
	dtm_narudzbe date,
	dtm_isporuke date,
	grad_isporuke nvarchar(15),
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)

CREATE TABLE narudzba_produkt
(
	narudzbaID int NOT NULL CONSTRAINT FK_Narudzba_Produkt_Narudzba FOREIGN KEY REFERENCES narudzba(narudzbaID),
	produktID int NOT NULL CONSTRAINT FK_Narudzba_Produkt_Produkt FOREIGN KEY REFERENCES produkt(produktID),
	CONSTRAINT PK_Narudzba_Produkt PRIMARY KEY(narudzbaID,produktID),
	uk_cijena money
)

GO
/*2. Import podataka

a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br

b) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv

c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- produkt jedinične cijene i količine
   uz uslov da je odobren popust 5% na produkt.
   */
INSERT INTO produkt
SELECT P.ProductID, P.UnitPrice, C.CategoryName, P.QuantityPerUnit, S.CompanyName, S.PostalCode
FROM NORTHWND.dbo.Categories AS C INNER JOIN 
     NORTHWND.dbo.Products AS P ON C.CategoryID = P.CategoryID INNER JOIN
	 NORTHWND.dbo.Suppliers AS S ON P.SupplierID = S.SupplierID

SELECT * FROM produkt

INSERT INTO narudzba
SELECT O.OrderID, O.OrderDate, O.ShippedDate, O.ShipCity, C.CustomerID, C.CompanyName, S.CompanyName
FROM NORTHWND.dbo.Customers AS C INNER JOIN
     NORTHWND.dbo.Orders AS O ON C.CustomerID = O.CustomerID INNER JOIN
	 NORTHWND.dbo.Shippers AS S ON O.ShipVia = S.ShipperID

SELECT * FROM narudzba

INSERT INTO narudzba_produkt
SELECT OrderID, ProductID, (UnitPrice*Quantity)
FROM NORTHWND.dbo.[Order Details]
WHERE Discount = 0.05

SELECT * FROM narudzba_produkt

----------------------------------------------------------------------------------------------------------------------------

/*3. a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view-uk-cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
      Obavezno pregledati sadržaj pogleda.

b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u kojima su feninzi veći od 49. 
   U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena biti zaokružena na veću vrijednost. 
   Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
*/
----------------------------------------------------------------------------------------------------------------------------
GO
CREATE VIEW view_uk_cijena
AS
SELECT N.narudzbaID, N.klijentID, FLOOR(NP.uk_cijena) AS uk_cijena_cijeli_dio, (uk_cijena - FLOOR(NP.uk_cijena)) * 100 AS uk_cijena_feninzi
FROM narudzba AS N INNER JOIN narudzba_produkt AS NP ON N.narudzbaID = NP.narudzbaID
GO

SELECT * FROM view_uk_cijena

SELECT *, uk_cijena_cijeli_dio + 1 AS uk_cijena_nova
INTO nova_uk_cijena
FROM view_uk_cijena
WHERE uk_cijena_feninzi > 49

SELECT * FROM nova_uk_cijena
/*4. Koristeći tabelu uk_cijena_nova kreiranu u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
   (možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
	narudzbaID - 10730
	klijentID  - ERNSH
*/
GO
CREATE OR ALTER PROCEDURE usp_zad4
@narudzbaID int = NULL,
@klijentID nvarchar(5) = NULL
AS
BEGIN
	SELECT * 
	FROM nova_uk_cijena
	WHERE narudzbaID = @narudzbaID OR klijentID = @klijentID
END
GO

EXEC usp_zad4 @narudzbaID = 10730
EXEC usp_zad4 @klijentID = 'ERNSH'
----------------------------------------------------------------------------------------------------------------------------
/*
5. Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj dobavljača počinje cifrom. 
   Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. Nakon kreiranja pokrenuti proceduru.

*/
GO
CREATE PROCEDURE usp_zad5
AS
BEGIN
	SELECT dobavljac_post_br, COUNT(*) AS Ukupno
	FROM produkt
	WHERE dobavljac_post_br LIKE '[0-9]%'
	GROUP BY dobavljac_post_br
END
GO

EXEC usp_zad5
----------------------------------------------------------------------------------------------------------------------------
/*
6. a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
      Obavezno napisati naredbu za pregled sadržaja pogleda.
   b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
   c) Iz pogleda kreiranog pod a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano 
      uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.

*/
GO
CREATE VIEW view_prebrojano
AS
SELECT klijent_naziv, COUNT(*) AS prebrojano
FROM narudzba
GROUP BY klijent_naziv
GO

SELECT * FROM view_prebrojano

SELECT MAX(prebrojano) AS [Maksimalna vrijednost] FROM view_prebrojano

SELECT *, (SELECT MAX(prebrojano) FROM view_prebrojano) - prebrojano AS Razlika
FROM view_prebrojano
WHERE prebrojano != (SELECT MAX(prebrojano) FROM view_prebrojano)
----------------------------------------------------------------------------------------------------------------------------
/*
7. a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
   b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira obrtanjem niza znakova koji se dobiju spajanjem zadnja četiri znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, lozinka se kreira obrtanjem slučajno generisanog niza znakova
      Nakon kreiranja pokrenuti proceduru.
      Obavezno provjeriti sadržaj tabele narudžba.
*/
ALTER TABLE produkt
ADD lozinka nvarchar(20)

GO
CREATE PROCEDURE usp_zad7b
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE produkt
			SET lozinka = REVERSE(CONCAT(RIGHT(mj_jedinica,4),dobavljac_post_br))
			WHERE ISNUMERIC(dobavljac_post_br) = 1

			UPDATE produkt
			SET lozinka = REVERSE(LEFT(NEWID(),20))
			WHERE ISNUMERIC(dobavljac_post_br) = 0
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END
GO

EXEC usp_zad7b

SELECT * FROM produkt

----------------------------------------------------------------------------------------------------------------------------
/*
8. a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
      Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice .
      Obavezno pregledati sadržaj pogleda.

   b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
 
*/
GO
CREATE VIEW view_zad8a
AS
SELECT P.produktID, P.dobavljac_naziv, N.grad_isporuke, DATEDIFF(day,N.dtm_narudzbe,N.dtm_isporuke) AS period_do_isporuke
FROM produkt AS P INNER JOIN narudzba_produkt AS NP ON P.produktID = NP.produktID
                  INNER JOIN narudzba AS N ON NP.narudzbaID = N.narudzbaID
WHERE DATEDIFF(day,N.dtm_narudzbe,N.dtm_isporuke) <= 28
GO

SELECT * FROM view_zad8a

SELECT *
INTO isporuka
FROM view_zad8a

SELECT * FROM isporuka
----------------------------------------------------------------------------------------------------------------------------
/*
9.  a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
    b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti od vrijednosti u koloni period_do_isporuke. Pokrenuti proceduru
    c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. Pregled treba da sadrži redni broj sedmice i ukupan broj zapisa po rednom broju.
*/
ALTER TABLE isporuka
ADD red_br_sedmice nvarchar(10)

GO
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE isporuka
		SET red_br_sedmice = 'prva'
		WHERE period_do_isporuke <= 7

		UPDATE isporuka
		SET red_br_sedmice = 'druga'
		WHERE period_do_isporuke BETWEEN 8 AND 14

		UPDATE isporuka
		SET red_br_sedmice = 'treca'
		WHERE period_do_isporuke BETWEEN 15 AND 21

		UPDATE isporuka
		SET red_br_sedmice = 'cetvrta'
		WHERE period_do_isporuke >= 22
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT ERROR_MESSAGE()
END CATCH
GO

CREATE VIEW view_zad9c
AS
SELECT red_br_sedmice, COUNT(*) AS Ukupno
FROM isporuka
GROUP BY red_br_sedmice
GO

SELECT * FROM view_zad9c
----------------------------------------------------------------------------------------------------------------------------
/*
10. a) Kreirati backup baze na default lokaciju.
    b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.

*/
BACKUP DATABASE _177
TO DISK = '_177.bak'
GO

CREATE PROCEDURE usp_zad10b
AS
BEGIN
	DROP VIEW view_prebrojano, view_uk_cijena, view_zad8a, view_zad9c
	DROP PROCEDURE usp_zad4, usp_zad5, usp_zad7b
END
GO

EXEC usp_zad10b
GO