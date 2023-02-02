-- CTE: Common Table Expression
-- let's first group all orderline per orderID to compute the total for each order
-- regardless of the customer
with
individualOrderTotal as (
select Ol.OrderID as OrderID, sum(Ol.Quantity * Ol.UnitPrice) as orderTotal
from Sales.OrderLines  as Ol
group by Ol.OrderID
),
-- CTE: Common Table Expression 
-- we do the same for the invoiceline and group it per invoiceID and compute the total
individualInvoiceTotal as (
select Il.InvoiceID as InvoiceID, sum(Il.Quantity * Il.UnitPrice) as invoiceTotal
from Sales.InvoiceLines  as Il
group by Il.InvoiceID
) 
-- Now we can form the query Result set
select	O.CustomerID, 
		C.CustomerName ,
		COUNT(O.OrderID) as TotalNBOrders ,
		COUNT(I.OrderID) as TotalNBInvoices,
		SUM(orderTotal) as OrdersTotalValue,
		SUM(invoiceTotal) as InvoicesTotalValue,
		ABS(SUM(orderTotal) - SUM(invoiceTotal)) as AbsoluteValueDifference
		
from	Sales.Orders as O,
		individualOrderTotal as Ol,		-- CTE reused
		Sales.Invoices as I,
		individualInvoiceTotal as Il,	-- CTE reused
		Sales.Customers as C
where	O.CustomerID = C.CustomerID
		-- only order transformed into invoice are considered by this filter
		and O.OrderID = I.OrderID
		and O.OrderID = Ol.OrderID
		and I.InvoiceID = Il.InvoiceID

group by O.CustomerID, C.CustomerName
order by AbsoluteValueDifference desc, TotalNBOrders, C.CustomerName