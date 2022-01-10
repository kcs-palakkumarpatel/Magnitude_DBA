

CREATE Procedure [dbo].[PB_Proc_Fact_AustroTelesalesCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroTelesalesCaptured','Fact_AustroTelesalesCaptured Start','Austro'

	Truncate table dbo.Fact_AustroTelesalesCaptured

	
	Insert into Fact_AustroTelesalesCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI ,UserId ,UserName ,ResolvedDate ,Longitude,Latitude ,Customer,
[Full Name] ,[Email ] ,[Mobile],[Company ],[Spoke With ],[Interest ] ,[Successful ],[Send Quote],[Call Summary ],[Type:],[Products: ],
[Quantity:],[Comments ] ,[Additional Opportu],[If yes, please exp],[Value of additiona])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI ,UserId ,UserName ,ResolvedDate ,Longitude,Latitude ,Customer,
[Full Name] ,[Email ] ,[Mobile],[Company ],[Spoke With ],[Interest ] ,[Successful ],[Send Quote],[Call Summary ],[Type:],[Products: ],
[Quantity:],[Comments ] ,[Additional Opportu],[If yes, please exp],[Value of additiona]
	 from [PB_VW_Fact_AustroTelesalesCaptured]

	Select @Desc = 'Fact_AustroTelesalesCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroTelesalesCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroTelesalesCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
