Create Procedure [dbo].[PB_Proc_RB_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'RB_Fact_Covid','RB_Fact_Covid Start','Royal Bafokeng'

	Truncate table dbo.RB_Fact_Covid

	
	Insert into RB_Fact_Covid(Activity,ResponseDate,ResponseReferenceNo,[Name],[Mobile],[Employee Number],[Contact With Covid],[Lesotho],
[Swaziland],[Mozambique],[Botswana],[Trvalled in overseas country],[Where],[Out of Rustenburg],
[if yes],[Fever],[Cough],[Sore Throat],[ Difficulty in Breathing],[Persistent headache],[Abnormal body and muscle pain],
[Diarrhea],[Blocked or running nose],[Anything else],Latitude,Longitude,PI)
	select Activity,ResponseDate,ResponseReferenceNo,[Name],[Mobile],[Employee Number],[Contact With Covid],[Lesotho],
[Swaziland],[Mozambique],[Botswana],[Trvalled in overseas country],[Where],[Out of Rustenburg],
[if yes],[Fever],[Cough],[Sore Throat],[ Difficulty in Breathing],[Persistent headache],[Abnormal body and muscle pain],
[Diarrhea],[Blocked or running nose],[Anything else],Latitude,Longitude,PI
	 from [PB_VW_RB_Fact_Covid]

	Select @Desc = 'RB_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.RB_Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'RB_Fact_Covid',@Desc,'Royal Bafokeng'

	Exec dbo.PB_Log_Insert 'RB_Fact_CovidCaptured','RB_Fact_CovidCaptured Start','Royal Bafokeng'

	Truncate table dbo.RB_Fact_CovidCaptured

	
	Insert into RB_Fact_CovidCaptured(CapturedDate,TotalSent)
	select CapturedDate,TotalSent
	 from [PB_VW_RB_Fact_CovidCaptured]

	Select @Desc = 'RB_Fact_CovidCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.RB_Fact_CovidCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'RB_Fact_CovidCaptured',@Desc,'Royal Bafokeng'

	Set NoCount OFF;
END
