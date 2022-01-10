

CREATE Procedure [dbo].[PB_Proc_Fact_Stefnutti_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Stefnutti_Captured','Fact_Stefnutti_Captured','Stefnutti Stocks'

	Truncate table dbo.Fact_Stefnutti_Captured

	
	Insert into Fact_Stefnutti_Captured(EstablishmentName,CapturedDate,ReferenceNo,
	SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
	Answer,QuestionId, Question ,UserName,FirstActionDate,FirstResponseDate
	,ResolvedDate,Longitude,Lattitude,AutoResolved)
	select EstablishmentName,CapturedDate,ReferenceNo,
	SeenClientAnswerMasterId,SeenClientAnswerChildId,IsPositive,Status,PI,
	Answer,QuestionId, Question ,UserName,FirstActionDate,FirstResponseDate
	,ResolvedDate,Longitude,Lattitude,AutoResolved
	 from [PB_View_Fact_Stefnutti_Captured]

	Select @Desc = 'Fact_Stefnutti_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Stefnutti_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Stefnutti_Captured',@Desc,'Austro'

	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Stefnutti','Dim_UpdateDateTime_Stefnutti Start','Stefnutti Stocks'


	Truncate table dbo.[Dim_UpdateDateTime_Stefnutti]

	Insert Into dbo.[Dim_UpdateDateTime_Stefnutti]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_Stefnutti Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Stefnutti',@Desc,'Stefnutti Stocks'
	Set NoCount OFF;
END
