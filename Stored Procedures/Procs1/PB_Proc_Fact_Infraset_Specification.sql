


CREATE Procedure [dbo].[PB_Proc_Fact_Infraset_Specification]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Infraset_Specification','Fact_Infraset_Specification Start','Infraset'

	Truncate table dbo.Fact_Infraset_Specification
	
	Insert into Fact_Infraset_Specification(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Project Name],[Databuild Referenc],
[Product Type],[Product Discussed],[Product Color],[Quantity],[Project Value],[Contractor Name],[Project Start Date],[Product Specified ],[Meeting Notes])
select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Project Name],[Databuild Referenc],
[Product Type],[Product Discussed],[Product Color],[Quantity],[Project Value],[Contractor Name],[Project Start Date],[Product Specified ],[Meeting Notes]
from PB_VW_Fact_Infraset_Specification
	Select @Desc = 'Fact_Infraset_Specification Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Infraset_Specification(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Infraset_Specification',@Desc,'Infraset'

	Set NoCount OFF;
END
