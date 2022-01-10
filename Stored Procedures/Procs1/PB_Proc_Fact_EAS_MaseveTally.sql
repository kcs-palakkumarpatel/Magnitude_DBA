

Create Procedure [dbo].[PB_Proc_Fact_EAS_MaseveTally]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_EAS_MaseveTally','Fact_EAS_MaseveTally Start','EAS'

	Truncate table dbo.Fact_EAS_MaseveTally

	
	Insert into Fact_EAS_MaseveTally(EstablishmentName,CapturedDate,ReferenceNo,UserName,[Date],[WALL FILL (cbm)],
[LINED AREA (sqm)],[DRAIN (m)],[PEN-STOCK PIPE (m)],[PEN-STOCK LIFT(no)],[Any issues],[Provide Details],[Issue Category])
	select EstablishmentName,CapturedDate,ReferenceNo,UserName,[Date],[WALL FILL (cbm)],
[LINED AREA (sqm)],[DRAIN (m)],[PEN-STOCK PIPE (m)],[PEN-STOCK LIFT(no)],[Any issues],[Provide Details],[Issue Category]
	 from [PB_VW_Fact_EAS_MaseveTally]

	Select @Desc = 'Fact_EAS_MaseveTally Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_EAS_MaseveTally(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_EAS_MaseveTally',@Desc,'EAS'

	Exec dbo.PB_Log_Insert 'Fact_EAS_SPO','Fact_EAS_SPO Start','EAS'

	Truncate table dbo.Fact_EAS_SPO

	
	Insert into Fact_EAS_SPO(EstablishmentName,CapturedDate,ReferenceNo,UserName ,RepeatCount,FirstResponseDate,[Short Title],
[Project leader],[Deadline],[Description & goal],[Desired outcomes],[Overall purpose],[Revenue or Cost],
[Milestone Number],[Description],[Planned Start Date],[Plan Finish Date],ResponseDate,SeenclientAnswerMasterId,
RepeatCount_1,[OVERALL average],[Milestone #],[PROGRESS],[BENEFITS],[ISSUES to report],[Describe the issue],
[Issue Category],[Who can assist you])
	select EstablishmentName,CapturedDate,ReferenceNo,UserName ,RepeatCount,FirstResponseDate,[Short Title],
[Project leader],[Deadline],[Description & goal],[Desired outcomes],[Overall purpose],[Revenue or Cost],
[Milestone Number],[Description],[Planned Start Date],[Plan Finish Date],ResponseDate,SeenclientAnswerMasterId,
RepeatCount_1,[OVERALL average],[Milestone #],[PROGRESS],[BENEFITS],[ISSUES to report],[Describe the issue],
[Issue Category],[Who can assist you]
	 from [PB_VW_Fact_EAS_SPO]

	Select @Desc = 'Fact_EAS_SPO Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_EAS_SPO(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_EAS_SPO',@Desc,'EAS'

	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_EAS','Dim_UpdateDateTime_EAS Start','EAS'


	Truncate table dbo.[Dim_UpdateDateTime_EAS]

	Insert Into dbo.[Dim_UpdateDateTime_EAS]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_EAS Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_EAS',@Desc,'EAS'
	Set NoCount OFF;
END
