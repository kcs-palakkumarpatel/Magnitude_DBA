




Create Procedure [dbo].[PB_Proc_Masslift_Fact_ColdCallPush]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ColdCallPush','Masslift_Fact_ColdCallPush Start','Masslift'

	Truncate table dbo.Masslift_Fact_ColdCallPush

	
	Insert into Masslift_Fact_ColdCallPush(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
Customer,
[Spoke With ],
[Customer Interest], 
[Interest ],
[Primary hook],
[Successful],
[Opposition ],
[Have you set up a ],
[If no, Why was the],ResponseDate,
CustomerName,CustomerSurname,
CustomerCompany,
CustomerEmail,CustomerMobile,
[Response Interest],
[Next Engagement ],
[Add Value])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
Customer,
[Spoke With ],
[Customer Interest], 
[Interest ],
[Primary hook],
[Successful],
[Opposition ],
[Have you set up a ],
[If no, Why was the],ResponseDate,
CustomerName,CustomerSurname,
CustomerCompany,
CustomerEmail,CustomerMobile,
[Response Interest],
[Next Engagement ],
[Add Value]

	 from [PB_VW_Masslift_Fact_ColdCallPush]

	Select @Desc = 'Masslift_Fact_ColdCallPush Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_ColdCallPush(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ColdCallPush',@Desc,'Masslift'

	Set NoCount OFF;
END

