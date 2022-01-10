
CREATE Procedure [dbo].[PB_Proc_Fact_CSC_Feedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_CSC_Feedback','Fact_CSC_Feedback Start','Car Service City'

	Truncate table dbo.Fact_CSC_Feedback
	
	Insert into Fact_CSC_Feedback(EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,QuestionId,Question,UserName,ResolvedDate,Longitude,Latitude)
select 
	EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,QuestionId,Question,UserName,ResolvedDate,Longitude,Latitude
  from PB_VW_Fact_CSC_Feedback

	Select @Desc = 'Fact_CSC_Feedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_CSC_Feedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_CSC_Feedback',@Desc,'Car Service City'

	Set NoCount OFF;
END
