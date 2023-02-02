
-- Let's first identify for customerID 1060 the first invoice line of the first invoice
select  I.CustomerID, I.InvoiceID,Il.InvoiceLineID, Il.Quantity, Il.UnitPrice
from	Sales.Invoices as I,
		Sales.InvoiceLines as Il
where	I.InvoiceID = Il.InvoiceID
		and I.CustomerID = 1060
order by I.InvoiceID, Il.InvoiceLineID

-- this gives us the appropriate InvoiceLineID 225394 where to modify the UnitPrice from 240 to 260 as requested
-- CustomerID	| InvoiceID	| InvoiceLineID	| Quantity	| UnitPrice
-- 1060		| 69627		| 225394	| 2		| 240.00

update Sales.InvoiceLines
set UnitPrice = 260 where InvoiceLineID = 225394

-- rerunning the First query gives us the expected Result Set