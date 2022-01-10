
--alter table Masslift_Fact_Pipeline add [Industry] varchar(200) null

CREATE Procedure [dbo].[PB_Proc_Masslift_Fact_Pipeline]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Pipeline','Masslift_Fact_Pipeline Start','Masslift'

	Truncate table dbo.Masslift_Fact_Pipeline

	
	Insert into Masslift_Fact_Pipeline(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,UserId,UserName,
Longitude,Latitude,CustomerEmail,
CustomerCompany,CustomerMobile,
CustomerName,[Are you logging an opportunity?],
[Company name:],[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
[Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],
ResponseDate,
ResponseReferenceNo,
ResponsePI,
[Are you speaking to the same person?],
 [Who are you speaking to?],
[Status:],
[Describe the follow up:],
 [Reason for lost sale:],
[Please state other:],
 [Who are the competitors?],
 [What was the competitors price (ZAR)?],
 [Type of contract:],
 [Has the client financed?],
 [Who has the client financed with?],
 [Size of client:],
 [Has this prospect become hot?],
 [Value of deal (ZAR)],
DummyRow,
Sort,[Industry])
	select  EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,UserId,UserName,
Longitude,Latitude,CustomerEmail,
CustomerCompany,CustomerMobile,
CustomerName,[Are you logging an opportunity?],
[Company name:],[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
[Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],
ResponseDate,
ResponseReferenceNo,
ResponsePI,
[Are you speaking to the same person?],
 [Who are you speaking to?],
[Status:],
[Describe the follow up:],
 [Reason for lost sale:],
[Please state other:],
 [Who are the competitors?],
 [What was the competitors price (ZAR)?],
 [Type of contract:],
 [Has the client financed?],
 [Who has the client financed with?],
 [Size of client:],
 [Has this prospect become hot?],
 [Value of deal (ZAR)],
DummyRow,
Sort,[Industry]
	 from [PB_VW_Masslift_Fact_Pipeline]

	Select @Desc = 'Masslift_Fact_Pipeline Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Pipeline(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Pipeline',@Desc,'Masslift'

	Set NoCount OFF;
END
