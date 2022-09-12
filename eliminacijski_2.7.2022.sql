/*Koriste�i tabele Person.Address, Sales.SalesOrderDetail i Sales.SalesOrderHeader kreirati upit koji �e dati
 sumu naru�enih koli�ina po gradu i godini isporuke koje su izvr�ene poslije 2012. godine, a gdje je suma ve�a od 200. 
 Rezultat poredati po sumi naru�enih koli�ina na silazni na�in.

 Izlaz:
-------- ----------------- -----------------------
Grad	 Godina isporuke   Suma naru�enih koli�ina
-------- ----------------- -----------------------
Toronto	 2013			   5719
London	 2013			   3572
Paris	 2013			   2788
Toronto	 2014	           2319

 */
 
 USE AdventureWorks2017
 GO

 SELECT * FROM Person.Address
 SELECT * FROM Sales.SalesOrderDetail
 SELECT * FROM Sales.SalesOrderHeader

 SELECT PA.City, YEAR(SOH.ShipDate) AS Godina, SUM(SOD.OrderQty) AS Suma
 FROM Person.Address AS PA INNER JOIN 
      Sales.SalesOrderHeader AS SOH ON PA.AddressID = SOH.ShipToAddressID INNER JOIN
	  Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE YEAR(SOH.ShipDate) > 2012
GROUP BY PA.City, YEAR(SOH.ShipDate)
HAVING SUM(SOD.OrderQty) > 2000
ORDER BY SUM(SOD.OrderQty) DESC