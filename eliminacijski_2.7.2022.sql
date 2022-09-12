/*Koristeæi tabele Person.Address, Sales.SalesOrderDetail i Sales.SalesOrderHeader kreirati upit koji æe dati
 sumu naruèenih kolièina po gradu i godini isporuke koje su izvršene poslije 2012. godine, a gdje je suma veæa od 200. 
 Rezultat poredati po sumi naruèenih kolièina na silazni naèin.

 Izlaz:
-------- ----------------- -----------------------
Grad	 Godina isporuke   Suma naruèenih kolièina
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