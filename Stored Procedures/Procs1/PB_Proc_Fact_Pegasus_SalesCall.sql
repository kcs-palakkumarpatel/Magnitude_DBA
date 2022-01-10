CREATE Procedure [dbo].[PB_Proc_Fact_Pegasus_SalesCall]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_SalesCall','Fact_Pegasus_SalesCall Start','Pegasus'

	Truncate table dbo.Fact_Pegasus_SalesCall
	
	Insert into Fact_Pegasus_SalesCall([EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId, UserName,Longitude,Latitude, CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,[Company ],[Meeting Perception],[Time Taken],[Additional Gaps],[Value Of Deal],[Any referrals],
[Referrals],[Resistance],[Resistance Categor],[If other, please s],[Services ],[Met With],[Position Met with],
[Common interests ],AccountOpenDate,[Opening An Account])
select 
	[EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId, UserName,Longitude,Latitude, CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,[Company ],[Meeting Perception],[Time Taken],[Additional Gaps],[Value Of Deal],[Any referrals],
[Referrals],[Resistance],[Resistance Categor],[If other, please s],[Services ],[Met With],[Position Met with],
[Common interests ],AccountOpenDate,[Opening An Account]
  from PB_VW_Fact_Pegasus_SalesCall

	Select @Desc = 'Fact_Pegasus_SalesCall Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Pegasus_SalesCall(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_SalesCall',@Desc,'Pegasus'


	Set NoCount OFF;
END
