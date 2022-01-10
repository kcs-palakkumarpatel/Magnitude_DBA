
Create Procedure [dbo].[PB_Proc_Fact_DFC_SM_Feedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_DFC_SM_Feedback','Fact_DFC_SM_Feedback Start','DFC'

	Truncate table dbo.Fact_DFC_SM_Feedback

	Insert Into dbo.Fact_DFC_SM_Feedback(
ReferenceNo,
SeenclientAnswerMasterid,

[Customer Target],
[Target Achieved YTD],
[Month to Date Invoiced],
[Current Order Intake Value for the month (Of new order received)],
[Is there RISK in achieving the monthly Targets],
[Any other Comments],
[Status on ALL Opportunities listed for this Customer that you Qualified],
[Name & Surname],
[Job Title],
[Mobile Number],
[Email Address]) 
	Select 
ReferenceNo,
SeenclientAnswerMasterid,

[Customer Target],
[Target Achieved YTD],
[Month to Date Invoiced],
[Current Order Intake Value for the month (Of new order received)],
[Is there RISK in achieving the monthly Targets],
[Any other Comments],
[Status on ALL Opportunities listed for this Customer that you Qualified],
[Name & Surname],
[Job Title],
[Mobile Number],
[Email Address] From dbo.PB_VW_Fact_DFC_SM_Feedback


	Select @Desc = 'Fact_DFC_SM_Feedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_DFC_SM_Feedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_DFC_SM_Feedback',@Desc,'DFC'

	Set NoCount OFF;
END