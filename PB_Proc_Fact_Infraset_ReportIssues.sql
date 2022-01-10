CREATE Procedure [dbo].[PB_Proc_Fact_Infraset_ReportIssues]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Infraset_ReportIssues','Fact_Infraset_ReportIssues Start','Infraset'

	Truncate table dbo.Fact_Infraset_ReportIssues
	
	Insert into Fact_Infraset_ReportIssues(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],

[Industry],[Project Name],[Project Descriptio],[If Other, please e],[Please explain the],
[Please provide you],[Remedies/Solutions],[Evaluation],[Company Name],[Customer Name],[Nature of Complain])
select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Industry],[Project Name],[Project Descriptio],[If Other, please e],[Please explain the],
[Please provide you],[Remedies/Solutions],[Evaluation],[Company Name],[Customer Name],[Nature of Complain]
from PB_VW_Fact_Infraset_ReportIssues
	Select @Desc = 'Fact_Infraset_ReportIssues Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Infraset_ReportIssues(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Infraset_ReportIssues',@Desc,'Infraset'

	Set NoCount OFF;
END
