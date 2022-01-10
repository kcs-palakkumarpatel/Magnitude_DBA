


CREATE Procedure [dbo].[PB_Proc_Fact_Stefnutti_Feedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Stefnutti_Feedback','Fact_Stefnutti_Feedback Start','Stefnutti Stocks'

	Truncate table dbo.Fact_Stefnutti_Feedback

	
	Insert into Fact_Stefnutti_Feedback(EstablishmentName,ResponseDate,ReferenceNo,
	SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,Answer,QuestionId,Question ,UserName)
	select EstablishmentName,ResponseDate,ReferenceNo,
	SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,Answer,QuestionId,Question ,UserName
	 from [PB_View_Fact_Stefnutti_Feedback]

	Select @Desc = 'Fact_Stefnutti_Feedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Stefnutti_Feedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Stefnutti_Feedback',@Desc,'Stefnutti Stocks'

	Set NoCount OFF;
END
