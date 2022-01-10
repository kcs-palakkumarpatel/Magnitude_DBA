CREATE Procedure [dbo].[PB_Proc_Fact_Beekman_PostStaySurvey]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman_PostStaySurvey','Fact_Beekman_PostStaySurvey Start','Beekman New'

	Truncate table dbo.Fact_Beekman_PostStaySurvey

	
	Insert into Fact_Beekman_PostStaySurvey(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved,
[Overall],[Staff],[Do you want to men],[Facilities],[Areas],[We would like to h],[Cleanliness],[Comfort],[Contact],[Please comment on],[Full Name])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved,
[Overall],[Staff],[Do you want to men],[Facilities],[Areas],[We would like to h],[Cleanliness],[Comfort],[Contact],[Please comment on],[Full Name]
	 from [PB_VW_Fact_Beekman_PostStaySurvey]

	Select @Desc = 'Fact_Beekman_PostStaySurvey Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman_PostStaySurvey(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman_PostStaySurvey',@Desc,'Beekman New'

	Set NoCount OFF;
END
