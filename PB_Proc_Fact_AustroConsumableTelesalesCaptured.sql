CREATE Procedure [dbo].[PB_Proc_Fact_AustroConsumableTelesalesCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableTelesalesCaptured','Fact_AustroConsumableTelesalesCaptured Start','Austro'

	--Truncate table dbo.Fact_AustroConsumableTelesalesCaptured

	delete From Fact_AustroConsumableTelesalesCaptured where Flag=0
	
	Insert into Fact_AustroConsumableTelesalesCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude,RepeatCount,Customer,[Full Name],[Email ],[Mobile],[Company ],[Spoke With ],[Interest ],[Successful ],--[Send Quote],
[Call Summary ],[Type:],[Products: ],[Quantity:],[Comments ],Flag)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude,RepeatCount,Customer,[Full Name],[Email ],[Mobile],[Company ],[Spoke With ],[Interest ],[Successful ],--[Send Quote],
[Call Summary ],[Type:],[Products: ],[Quantity:],[Comments ], 0 as Flag
	 from [PB_VW_Fact_AustroConsumableTelesalesCaptured]

	Select @Desc = 'Fact_AustroConsumableTelesalesCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroConsumableTelesalesCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableTelesalesCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
