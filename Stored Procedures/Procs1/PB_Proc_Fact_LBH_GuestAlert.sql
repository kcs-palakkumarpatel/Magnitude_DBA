


CREATE Procedure [dbo].[PB_Proc_Fact_LBH_GuestAlert]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_GuestAlert','Fact_LBH_GuestAlert Start','LBH Reputation Management'

	Truncate table dbo.Fact_LBH_GuestAlert

	
	Insert into Fact_LBH_GuestAlert(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,[Room Number ],
[Experience ],ResolvedDate,SeenClientAnswerMasterId)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,[Room Number ],
[Experience ],ResolvedDate,SeenClientAnswerMasterId
	from PB_VW_Fact_LBH_GuestAlert

	Select @Desc = 'Fact_LBH_GuestAlert Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_GuestAlert(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_GuestAlert',@Desc,'LBH Reputation Management'

	Set NoCount OFF;
END
