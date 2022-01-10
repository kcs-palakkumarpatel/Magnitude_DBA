
CREATE Procedure [dbo].[PB_Proc_Masslift_Fact_OpportunitySummary]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_OpportunitySummary','Masslift_Fact_OpportunitySummary Start','Masslift'

	Truncate table dbo.Masslift_Fact_OpportunitySummary

	
	Insert into Masslift_Fact_OpportunitySummary(Activity,EstablishmentName,CapturedDate,ReferenceNo,Status,Longitude,Latitude,UserId,UserName,Customer,[Name],
[Surname],[Mobile],[Email ],[Is Opportunity],[Value of Opportunity],[What is Opportunity],Total,IsDelegate,LeadCapturedDate,LeadReferenceNo,
[Customer Name],
[Customer Email],
[Customer Contact N],
[Lead Description],
[Company Name ],
[Lead Source],
[Area: ],
[Oppourtunity],
[Reference Number],
LeadRecievedUser,
LeadResponseDate,
[Contact Customer],
[Meeting Set Up],
[General Comments ],
[If yes, please add],
SeenClientAnswerMasterId
	)
	select Activity,EstablishmentName,CapturedDate,ReferenceNo,Status,Longitude,Latitude,UserId,UserName,Customer,[Name],
[Surname],[Mobile],[Email ],[Is Opportunity],[Value of Opportunity],[What is Opportunity],Total,IsDelegate,LeadCapturedDate,LeadReferenceNo,
[Customer Name],
[Customer Email],
[Customer Contact N],
[Lead Description],
[Company Name ],
[Lead Source],
[Area: ],
[Oppourtunity],
[Reference Number],LeadRecievedUser,
LeadResponseDate,
[Contact Customer],
[Meeting Set Up],
[General Comments ],
[If yes, please add],
SeenClientAnswerMasterId
	 from [PB_VW_Masslift_Fact_OpportunitySummary]

	Select @Desc = 'Masslift_Fact_OpportunitySummary Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_OpportunitySummary(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_OpportunitySummary',@Desc,'Masslift'

	Set NoCount OFF;
END
