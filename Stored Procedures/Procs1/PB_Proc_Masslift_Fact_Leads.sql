
CREATE Procedure [dbo].[PB_Proc_Masslift_Fact_Leads]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)

	Exec dbo.PB_Log_Insert 'Masslift_Fact_LeadStatus','Masslift_Fact_LeadStatus Start','Masslift'

	/*Truncate table dbo.Masslift_Fact_LeadStatus

	
	Insert into Masslift_Fact_LeadStatus(ReferenceNo,Statustime,StatusName,StatusSort)
	select ReferenceNo,Statustime,StatusName,StatusSort
	 from [PB_VW_Masslift_Fact_LeadsStatus]

	Select @Desc = 'Masslift_Fact_LeadsStatus Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_LeadsStatus(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_LeadsStatus',@Desc,'Masslift'

	Exec dbo.PB_Log_Insert 'Masslift_Fact_Leads','Masslift_Fact_Leads Start','Masslift' */

	Truncate table dbo.Masslift_Fact_Leads

	
	Insert into Masslift_Fact_Leads(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Customer Name],
[Customer Email],
[Customer Contact N],
[Lead Description],
[Company Name ],
[Lead Source],
[Area: ],
[Oppourtunity],
[Reference Number],FirstResponseDate,LeadRecievedUser,[Is this a new or a],ResponseDate,
 CustomerName,CustomerSurname,
 CustomerCompany,
 CustomerEmail,CustomerMobile,
[Contact Customer],
[Meeting Set Up],
[General Comments ],
[If yes, please add])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Customer Name],
[Customer Email],
[Customer Contact N],
[Lead Description],
[Company Name ],
[Lead Source],
[Area: ],
[Oppourtunity],
[Reference Number],FirstResponseDate,LeadRecievedUser,[Is this a new or a],ResponseDate,
 CustomerName,CustomerSurname,
 CustomerCompany,
 CustomerEmail,CustomerMobile,
[Contact Customer],
[Meeting Set Up],
[General Comments ],
[If yes, please add]
	 from [PB_VW_Masslift_Fact_Leads]

	Select @Desc = 'Masslift_Fact_Leads Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Leads(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Leads',@Desc,'Masslift'

	Set NoCount OFF;
END
