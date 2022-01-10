

CREATE Procedure [dbo].[PB_Proc_Fact_AustroOtherLeads]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroOtherLeads','Fact_AustroOtherLeads Start','Austro'

	--Truncate table dbo.Fact_AustroOtherLeads

	delete from Fact_AustroOtherLeads where Flag=0
	
	Insert into Fact_AustroOtherLeads(LeadReferenceno,LeadCapturedDate,Status ,[Name] ,[Plan of action],[Company],[Full Name],[Contact Number],[Contact Email] ,[Topic],
[Reference No],[Industry:],[Is this an opportu],[Type of lead:],SeenclientanswermasterId ,LeadResponseDate,[Meeting Set Up],
[If yes, date of me] ,[General Comments ],[Contacted Prospect],Flag)
	select LeadReferenceno,LeadCapturedDate,Status ,[Name] ,[Plan of action],[Company],[Full Name],[Contact Number],[Contact Email] ,[Topic],
[Reference No],[Industry:],[Is this an opportu],[Type of lead:],SeenclientanswermasterId ,LeadResponseDate,[Meeting Set Up],
[If yes, date of me] ,[General Comments ],[Contacted Prospect], 0 as Flag
	 from [PB_VW_Fact_AustroOtherLeads]

	Select @Desc = 'Fact_AustroOtherLeads Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroOtherLeads(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroOtherLeads',@Desc,'Austro'

	
	Set NoCount OFF;
END
