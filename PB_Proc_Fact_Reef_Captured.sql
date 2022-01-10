

CREATE Procedure [dbo].[PB_Proc_Fact_Reef_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Reef_Captured','Fact_Reef_Captured Start','Reef Catering'

	Truncate table dbo.Fact_Reef_Captured
	
	Insert into Fact_Reef_Captured(EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,RatingSort,QuestionId,Question,userName,FirstActionDate,FirstResponseDate,ResolvedDate,Longitude,Latitude,AutoResolved)
select 
	EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,RatingSort,QuestionId,Question,userName,FirstActionDate,FirstResponseDate,ResolvedDate,Longitude,Latitude,AutoResolved
  from PB_VW_Fact_Reef_Captured

	Select @Desc = 'Fact_Reef_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Reef_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Reef_Captured',@Desc,'Reef Catering'

	Truncate table dbo.Dim_UpdateDateTimeReef

	Insert Into dbo.Dim_UpdateDateTimeReef
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeReef Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeReef',@Desc,'Reef Catering'


	Set NoCount OFF;
END
