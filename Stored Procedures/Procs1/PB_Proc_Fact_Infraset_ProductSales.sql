
CREATE Procedure [dbo].[PB_Proc_Fact_Infraset_ProductSales]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Infraset_ProductSales','Fact_Infraset_ProductSales Start','Infraset'

	Truncate table dbo.Fact_Infraset_ProductSales
	
	Insert into Fact_Infraset_ProductSales(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Customer Type],[Project Name],[Product Type],
[Product List],[Color],[Project Value],[Meeting Outcome],[Delivery],[Manager Assistance],[Additional Comment],[Product Specified],[Meeting Purpose])
select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Customer Type],[Project Name],[Product Type],
[Product List],[Color],[Project Value],[Meeting Outcome],[Delivery],[Manager Assistance],[Additional Comment],[Product Specified],[Meeting Purpose]
  from PB_VW_Fact_Infraset_ProductSales

	Select @Desc = 'Fact_Infraset_ProductSales Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Infraset_ProductSales(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Infraset_ProductSales',@Desc,'Infraset'

	Set NoCount OFF;
END
