



CREATE Procedure [dbo].[PB_Proc_Fact_AustroDailyPlanCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanCaptured','Fact_AustroDailyPlanCaptured Start','Austro'

	Truncate table dbo.Fact_AustroDailyPlanCaptured

	
	Insert into Fact_AustroDailyPlanCaptured(EstablishmentName ,CapturedDate ,ReferenceNo,IsPositive ,Status,PI,UserId,UserName ,ResolvedDate,Longitude ,Latitude,RepeatCount,
[Name],[Mobile],[Email ],[Company ],[Client Company],[Name of person you],[Position],[Type of visit: ],[Type of industry:], [Company Spend ],
[Contingency Commen],[General Comment ],[Requires Help],[If yes, outline wh],[Region],[NonClient Company],[NonClient Comment],
[Client Time Planned],[Client Type of Task],[NonClient Time Planned],[Clients today],[NonClient Task Type],[Client Facing Time],
[Non-Client Time],[Client Other Task Type],[Non Client Other Task Type])
	select EstablishmentName ,CapturedDate ,ReferenceNo,IsPositive ,Status,PI,UserId,UserName ,ResolvedDate,Longitude ,Latitude,RepeatCount,
[Name],[Mobile],[Email ],[Company ],[Client Company],[Name of person you],[Position],[Type of visit: ],[Type of industry:], [Company Spend ],
[Contingency Commen],[General Comment ],[Requires Help],[If yes, outline wh],[Region],[NonClient Company],[NonClient Comment],
[Client Time Planned],[Client Type of Task],[NonClient Time Planned],[Clients today],[NonClient Task Type],[Client Facing Time],
[Non-Client Time],[Client Other Task Type],[Non Client Other Task Type]
	 from [PB_VW_Fact_AustroDailyPlanCaptured]

	Select @Desc = 'Fact_AustroDailyPlanCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroDailyPlanCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
