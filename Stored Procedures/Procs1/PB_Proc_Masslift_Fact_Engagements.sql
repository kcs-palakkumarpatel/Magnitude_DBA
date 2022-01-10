
Create Procedure [dbo].[PB_Proc_Masslift_Fact_Engagements]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Engagements','Masslift_Fact_Engagements Start','Masslift'

	Truncate table dbo.Masslift_Fact_Engagements

	
	Insert into Masslift_Fact_Engagements(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
Customer,
[Address],
[Agreed Next Steps],
[Area:],
[Client was interested in],
[Company],
[Email],
[Full Name],
[Is this a hot prospect?],
[If a hot prospect, why?],
[what is the current fleet],
[If other, please elaborate],
[If yes, what price point will get them over the link],
[The fit for Masslift],
[Mast:],
[How did you get on?],
[Perception of the meeting],
[Position of the person you met with],
[Today you met with],
[Mobile],
[Next target date],
[Have you spotted any potential opportunities?],
[Price (has this been discussed)],
[Price (Rands)],
[If yes, who must send quote?],
[Resistance],
[Send Quote],
[Specification of the equipment],
[Time Taken:],
[Type of quote],
[Unit:],
[Value of potential opportunity (ZAR)],
[If yes, what is the opportunity],
[What transpired in the meeting?],ResponseDate,
 CustomerName, CustomerSurname,
CustomeCompany,
CustomerEmail,CustomerMobile,
[Did we understand ],
[If no, why? ],
[Happy Service ])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
Customer,
[Address],
[Agreed Next Steps],
[Area:],
[Client was interested in],
[Company],
[Email],
[Full Name],
[Is this a hot prospect?],
[If a hot prospect, why?],
[what is the current fleet],
[If other, please elaborate],
[If yes, what price point will get them over the link],
[The fit for Masslift],
[Mast:],
[How did you get on?],
[Perception of the meeting],
[Position of the person you met with],
[Today you met with],
[Mobile],
[Next target date],
[Have you spotted any potential opportunities?],
[Price (has this been discussed)],
[Price (Rands)],
[If yes, who must send quote?],
[Resistance],
[Send Quote],
[Specification of the equipment],
[Time Taken:],
[Type of quote],
[Unit:],
[Value of potential opportunity (ZAR)],
[If yes, what is the opportunity],
[What transpired in the meeting?],ResponseDate,
 CustomerName, CustomerSurname,
CustomeCompany,
CustomerEmail,CustomerMobile,
[Did we understand ],
[If no, why? ],
[Happy Service ]

	 from [PB_VW_Masslift_Fact_Engagements]

	Select @Desc = 'Masslift_Fact_Engagements Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Engagements(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Engagements',@Desc,'Masslift'

	Set NoCount OFF;
END

