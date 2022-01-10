

CREATE Procedure [dbo].[PB_Proc_Fact_Beekman_Help]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman_Help','Fact_Beekman_Help Start','Beekman New'

	Truncate table dbo.Fact_Beekman_Help

	
	Insert into Fact_Beekman_Help(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved,[Name],[Cell] ,[Unit No.],[Category],[Comments])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved,[Name],[Cell] ,[Unit No.],[Category],[Comments]
	 from [PB_VW_Fact_Beekman_Help]

	Select @Desc = 'Fact_Beekman_Help Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman_Help(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman_Help',@Desc,'Beekman New'

	Set NoCount OFF;
END
