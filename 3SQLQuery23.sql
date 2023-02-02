
CREATE PROCEDURE ReportCustomerTurnover 
	-- Add the parameters for the stored procedure here
	@Choice int = 1, 
	@Year int = 2013
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT @Choice, @Year
	-- For Choice = 1, we report the Monthly Turnover for the selected year 
	-- if no second parameter for year, then default year = 2013
	IF @Choice = 1
	BEGIN
		-- Execute Monthly query: Pivoting Monthly InvoiceTotal
		select	CustomerName,
				coalesce([1], 0) as Jan,
				coalesce([2], 0) as Feb,
				coalesce([3], 0) as Mar,
				coalesce([4], 0) as Apr,
				coalesce([5], 0) as May,
				coalesce([6], 0) as Jun,
				coalesce([7], 0) as Jul,
				coalesce([8], 0) as Aug,
				coalesce([9], 0) as Sep,
				coalesce([10],0) as Oct,
				coalesce([11],0) as Nov,
				coalesce([12],0) as [Dec]

		from (
		select	Cu.CustomerName,
				MONTH(It.InvoiceDate) as InvoiceMonth, 
				sum(It.InvoiceTotal) as InvoiceTotal
		from	Sales.Customers as Cu
				left join (
					select I.CustomerID, I.InvoiceID, I.InvoiceDate, sum(Il.Quantity * Il.UnitPrice) as InvoiceTotal
					from	Sales.Invoices as I		
							join Sales.InvoiceLines as Il on I.InvoiceID = Il.InvoiceID	
					where	YEAR(I.InvoiceDate) = @Year
					group by I.CustomerID, I.InvoiceID, I.InvoiceDate
				) as It	on Cu.CustomerID = It.CustomerID
		group by Cu.CustomerName, MONTH(It.InvoiceDate)
		
		) as SourceTable
		Pivot (
			max(InvoiceTotal) for InvoiceMonth in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
		) as PivotTable 
		order by CustomerName

	END --IF @Choice = 1
	ELSE
	BEGIN
	-- For Choice = 1, we report the Monthly Turnover for the selected year 
	-- if no second parameter for year, then default year = 2013
	IF  @Choice = 2
	BEGIN
		-- Execute Quaterly query: Pivoting Quarterly InvoiceTotal
		select	CustomerName,
				coalesce([1],0) as Q1,
				coalesce([2],0) as Q2,
				coalesce([3],0) as Q3,
				coalesce([4],0) as Q4
		from (
		select	Cu.CustomerName,
				datepart(quarter, It.InvoiceDate) as InvoiceQuarter, 
				sum(It.InvoiceTotal) as InvoiceTotal
		from	Sales.Customers as Cu
				left join (
					select I.CustomerID, I.InvoiceID, I.InvoiceDate, sum(Il.Quantity * Il.UnitPrice) as InvoiceTotal
					from	Sales.Invoices as I		
							join Sales.InvoiceLines as Il on I.InvoiceID = Il.InvoiceID	
					where	YEAR(I.InvoiceDate) = 2015
					group by I.CustomerID, I.InvoiceID, I.InvoiceDate
				) as It	on Cu.CustomerID = It.CustomerID
		group by Cu.CustomerName, datepart(quarter, It.InvoiceDate)
		
		) as SourceTable
		Pivot (
			max(InvoiceTotal) for InvoiceQuarter in ([1],[2],[3],[4])
		) as PivotTable 
		order by CustomerName
	END --IF @Choice = 2
	ELSE
	BEGIN
	IF @Choice = 3
	BEGIN
		-- Execute Yearly Turnover By pivoting InvoiceTotal from 2013 to 2016
		-- second parameter not taken into account
		select	CustomerName,
				coalesce([2013],0) as [2013],
				coalesce([2014],0) as [2014],
				coalesce([2015],0) as [2015],
				coalesce([2016],0) as [2016]
		from (
		select	Cu.CustomerName as CustomerName,
				sum(Il.Quantity * Il.UnitPrice) as InvoiceTotal,
				YEAR(I.InvoiceDate) as InvoiceYear
		
		from	Sales.Customers as Cu,
				Sales.Invoices as I,
				Sales.InvoiceLines as Il
		where	Cu.CustomerID = I.CustomerID
				and I.InvoiceID = Il.InvoiceID
		group by Cu.CustomerName, YEAR(I.InvoiceDate)
		
		) as SourceTable
		Pivot (
			max(InvoiceTotal) for InvoiceYear in ([2013],[2014],[2015],[2016])
		) as PivotTable 
		order by CustomerName

	END -- IF @Choice = 3
	ELSE
	BEGIN
	PRINT 'Invalid Procedure Input Paremeter: Choice in [1..3], Year in [2013..2016]'
	END -- ELSE @Choice = 3
	END -- ELSE @Choice = 2
	END -- ELSE @Choice = 1
END
GO