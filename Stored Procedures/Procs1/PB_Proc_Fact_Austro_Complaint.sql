

CREATE Procedure [dbo].[PB_Proc_Fact_Austro_Complaint]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Austro_Complaints','Fact_Austro_Complaints Start','Austro'

	Truncate table dbo.Fact_Austro_Complaints

	
	Insert into Fact_Austro_Complaints(EstablishmentName,CapturedDate,ReferenceNo,UserName,ContactName,Status,[Issue Title],[Issue Description],[Customer],[Full name:],
[Mobile:],[Email:],[Topic],[If other],[Is this a critical],ResponseDate,[Are you satisfied ],[Issue Resolution],[Type of fix],
[Have you contacted],[Was the outcome],[What outcome],[Time taken on fix ])
	select EstablishmentName,CapturedDate,ReferenceNo,UserName,ContactName,Status,[Issue Title],[Issue Description],[Customer],[Full name:],
[Mobile:],[Email:],[Topic],[If other],[Is this a critical],ResponseDate,[Are you satisfied ],[Issue Resolution],[Type of fix],
[Have you contacted],[Was the outcome],[What outcome],[Time taken on fix ]
	 from [PB_VW_Fact_Austro_Complaints]

	Select @Desc = 'Fact_Austro_Complaints Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Austro_Complaints(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Austro_Complaints',@Desc,'Austro'

	Set NoCount OFF;
END
