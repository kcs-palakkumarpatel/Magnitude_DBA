
CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_OnLineSupportCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnLineSupportCaptured','Avocet_Fact_OnLineSupportCaptured Start','Avocet'

	Truncate table dbo.Avocet_Fact_OnLineSupportCaptured

	
	Insert into Avocet_Fact_OnLineSupportCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,RepeatCount,UserName,Technician,
[Email],[Mobile],[Company],Latitude,Longitude,ResolvedDate,ResponseDate,ResponseReferenceNo,
[Response User],SeenClientAnswerMasterId,[Issue],[Remote Support App],[Which Application],
[Your Application I],[Your Application P],[Supporting Image |],ResponseLatitude,ResponseLongitude)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,RepeatCount,UserName,Technician,
[Email],[Mobile],[Company],Latitude,Longitude,ResolvedDate,ResponseDate,ResponseReferenceNo,
[Response User],SeenClientAnswerMasterId,[Issue],[Remote Support App],[Which Application],
[Your Application I],[Your Application P],[Supporting Image |],ResponseLatitude,ResponseLongitude
	 from [PB_VW_Avocet_Fact_OnLineSupportCaptured]

	Select @Desc = 'Avocet_Fact_OnLineSupportCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_OnLineSupportCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnLineSupportCaptured',@Desc,'Avocet'

	Set NoCount OFF;
END
