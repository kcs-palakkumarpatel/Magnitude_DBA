

CREATE Procedure [dbo].[PB_Proc_Fact_Reef_Feedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Reef_Feedback','Fact_Reef_Feedback Start','Reef Catering'

	Truncate table dbo.Fact_Reef_Feedback
	
	Insert into Fact_Reef_Feedback(EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,
Status,PI,Answer,QuestionId,Question,UserName)
select EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,
Status,PI,Answer,QuestionId,Question,UserName from PB_VW_Fact_Reef_Feedback

	Select @Desc = 'Fact_Reef_Feedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Reef_Feedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Reef_Feedback',@Desc,'Reef Catering'

	Set NoCount OFF;
END
