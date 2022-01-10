

Create Procedure [dbo].[PB_Proc_Masslift_Fact_CourtseyCall]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_CourtseyCall','Masslift_Fact_CourtseyCall Start','Masslift'

	Truncate table dbo.Masslift_Fact_CourtseyCall

	
	Insert into Masslift_Fact_CourtseyCall(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,[Company name:],[Reason for visit:],[Any issues with this client?],
[If yes, please describe what the issue(s):],[How is your current relationship with this client?],
[What transpired in the meeting?],[Wh have you spoken with?],
ResponseDate, CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Are you happy with the service of the salesman?],[Why not?],[Are we on the same page?],[Please correct us:],[Comments:])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,[Company name:],[Reason for visit:],[Any issues with this client?],
[If yes, please describe what the issue(s):],[How is your current relationship with this client?],
[What transpired in the meeting?],[Wh have you spoken with?],
ResponseDate, CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Are you happy with the service of the salesman?],[Why not?],[Are we on the same page?],[Please correct us:],[Comments:]
	 from [PB_VW_Masslift_Fact_CourtseyCall]

	Select @Desc = 'Masslift_Fact_CourtseyCall Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_CourtseyCall(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_CourtseyCall',@Desc,'Masslift'

	Set NoCount OFF;
END

