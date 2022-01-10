

Create Procedure [dbo].[PB_Proc_Masslift_Fact_Discussions]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Discussions','Masslift_Fact_Discussions Start','Masslift'

	Truncate table dbo.Masslift_Fact_Discussions

	
	Insert into Masslift_Fact_Discussions(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Discussion Title:],
[Discussion Topic],
[Urgent],
[What is this discu],ResponseDate,
CustomerName,CustomerSurname,
CustomerCompany,
CustomerEmail, CustomerMobile,
[Necessary ],
[Discussion Outcome],Conversation,[CommentUser], [CommentDate])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Discussion Title:],
[Discussion Topic],
[Urgent],
[What is this discu],ResponseDate,
CustomerName,CustomerSurname,
CustomerCompany,
CustomerEmail, CustomerMobile,
[Necessary ],
[Discussion Outcome],Conversation,[CommentUser], [CommentDate]
	 from [PB_VW_Masslift_Fact_Discussions]

	Select @Desc = 'Masslift_Fact_Discussions Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Discussions(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Discussions',@Desc,'Masslift'

	Set NoCount OFF;
END

