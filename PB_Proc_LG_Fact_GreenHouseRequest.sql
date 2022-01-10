Create Procedure [dbo].[PB_Proc_LG_Fact_GreenHouseRequest]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'LG_Fact_GreenHouseRequestCaptured','LG_Fact_GreenHouseRequestCaptured Start','Life Green'

	Truncate table dbo.LG_Fact_GreenHouseRequestCaptured

	
	Insert into LG_Fact_GreenHouseRequestCaptured(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,RepeatCount,
[Client Name],[Site Address],[Approx Date Req],[Request type],[Full Name],[Role],[Delivery Team],[No of plants?],
[Total Returns],[Plant type],[If other plant],[Plant Size],[Quantity],[Additional comment],[What needs Replaci],
[Quantity (bags)],[MR Additional comment],[Description],[Ornament Quantity],[Image],[Comment],[Returning items],
[Return Plant type],[Return Plant Size],[Return Quantity])
	select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,RepeatCount,
[Client Name],[Site Address],[Approx Date Req],[Request type],[Full Name],[Role],[Delivery Team],[No of plants?],
[Total Returns],[Plant type],[If other plant],[Plant Size],[Quantity],[Additional comment],[What needs Replaci],
[Quantity (bags)],[MR Additional comment],[Description],[Ornament Quantity],[Image],[Comment],[Returning items],
[Return Plant type],[Return Plant Size],[Return Quantity]
	 from [PB_VW_LG_Fact_GreenHouseRequestCaptured]

	Select @Desc = 'LG_Fact_GreenHouseRequestCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.LG_Fact_GreenHouseRequestCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'LG_Fact_GreenHouseRequestCaptured',@Desc,'Life Green'
---------------------------------------------------------------------------------------------------
Exec dbo.PB_Log_Insert 'LG_Fact_GreenHouseRequestFeedback','LG_Fact_GreenHouseRequestFeedback Start','Life Green'

	Truncate table dbo.LG_Fact_GreenHouseRequestFeedback

	
	Insert into LG_Fact_GreenHouseRequestFeedback(EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
RepeatCount,[Select the Process], [Changes to Request], [Would you like:],[Add More],[Add Plant type],[Add Plant Size],
[Add Quantity],[Less Add More],[Less Plant Type], [Less Plant Size],[Less Quantity],[Collection Assign],
[Estimated Pickup],[Date and Time],[Is the collection],[Items accounted],[What is missing],[Full Name],
[Signature],[No of Return Plant],[Ret Add More], [Ret Plant Type],[Ret Plant Size],[Ret Quantity],
[Date and Time Return], [Missing item],[Mis Add More], [Mis Plant Type], [Mis Plant Size],[Mis Quantity])
	select EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
RepeatCount,[Select the Process], [Changes to Request], [Would you like:],[Add More],[Add Plant type],[Add Plant Size],
[Add Quantity],[Less Add More],[Less Plant Type], [Less Plant Size],[Less Quantity],[Collection Assign],
[Estimated Pickup],[Date and Time],[Is the collection],[Items accounted],[What is missing],[Full Name],
[Signature],[No of Return Plant],[Ret Add More], [Ret Plant Type],[Ret Plant Size],[Ret Quantity],
[Date and Time Return], [Missing item],[Mis Add More], [Mis Plant Type], [Mis Plant Size],[Mis Quantity]
	 from [PB_VW_LG_Fact_GreenHouseRequestFeedback]

	Select @Desc = 'LG_Fact_GreenHouseRequestFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.LG_Fact_GreenHouseRequestFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'LG_Fact_GreenHouseRequestFeedback',@Desc,'Life Green'

	Set NoCount OFF;
END
