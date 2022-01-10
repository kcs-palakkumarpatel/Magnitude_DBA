CREATE Procedure [dbo].[PB_Proc_LG_Fact_SiteVisit1]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'LG_Fact_SiteVisit1','LG_Fact_SiteVisit1 Start','Life Green'

	Truncate table dbo.LG_Fact_SiteVisit1

	
	Insert into LG_Fact_SiteVisit1(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Company Name],[Site Address],
[Unit Count],[Contact Person],[Person Mobile],[Week Number],[Scheduled Week],[Scheduled Day],[VisitedDay],
[Visited Week],Longitude,Latitude,ResponseDate,ResponseRef,SeenClientAnswerMasterId, ResponseLongitude, ResponseLatitude,
[Any plant diseases],[Picture of Plant],[Describe Disease],[Replacing Plant],[Plant Description],[Location],
[Image of New plant],[Require Replace],[Replacement Type],[Type of plant],[Quantity],
[Size],[Picture of Replaced plant],[Client signature],[Client name])
	 
	 select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Company Name],[Site Address],
[Unit Count],[Contact Person],[Person Mobile],[Week Number],[Scheduled Week],[Scheduled Day],[VisitedDay],
[Visited Week],Longitude,Latitude,ResponseDate,ResponseRef,SeenClientAnswerMasterId, ResponseLongitude, ResponseLatitude,
[Any plant diseases],[Picture of Plant],[Describe Disease],[Replacing Plant],[Plant Description],[Location],
[Image of New plant],[Require Replace],[Replacement Type],[Type of plant],[Quantity],
[Size],[Picture of Replaced plant],[Client signature],[Client name]
	 from [PB_VW_LG_Fact_SiteVisit1]

	Select @Desc = 'LG_Fact_SiteVisit1 Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.LG_Fact_SiteVisit1(NoLock) 
	Exec dbo.PB_Log_Insert 'LG_Fact_SiteVisit1',@Desc,'Life Green'

	Set NoCount OFF;
END
