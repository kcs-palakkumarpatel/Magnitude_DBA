CREATE Procedure [dbo].[PB_Proc_Fact_CSC_Complaint_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_CSC_Complaint_Captured','Fact_CSC_Complaint_Captured Start','Car Service City'

	Truncate table dbo.Fact_CSC_Complaint_Captured
	
	Insert into Fact_CSC_Complaint_Captured(EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,QuestionId,Question,UserId,UserName,FirstActionDate,FirstResponseDate,ResolvedDate,Longitude,Latitude,QPI,StatusTime,StatusName)
select 
	EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,SeenClientAnswerChildId,
IsPositive,Status,PI,Answer,QuestionId,Question,UserId,UserName,FirstActionDate,FirstResponseDate,ResolvedDate,Longitude,Latitude,QPI,StatusTime,StatusName
  from PB_VW_Fact_CSC_Complaint_Captured

	Select @Desc = 'Fact_CSC_Complaint_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_CSC_Complaint_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_CSC_Complaint_Captured',@Desc,'Car Service City'

	Set NoCount OFF;
END

