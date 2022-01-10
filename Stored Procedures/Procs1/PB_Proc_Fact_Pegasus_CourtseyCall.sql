
CREATE Procedure [dbo].[PB_Proc_Fact_Pegasus_CourtseyCall]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_CourtseyCall','Fact_Pegasus_CourtseyCall Start','Pegasus'

	Truncate table dbo.Fact_Pegasus_CourtseyCall
	
	Insert into Fact_Pegasus_CourtseyCall([EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId, UserName,CustomerCompany,CustomerEmail,
CustomerMobile,CustomerName,Longitude,Latitude,[Company],[Time taken],[Opportunities ],[If yes, please out],
[Value of additiona],[General notes])
select 
[EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId, UserName,CustomerCompany,CustomerEmail,
CustomerMobile,CustomerName,Longitude,Latitude,[Company],[Time taken],[Opportunities ],[If yes, please out],
[Value of additiona],[General notes]
	
  from PB_VW_Fact_Pegasus_CourtseyCall

	Select @Desc = 'Fact_Pegasus_CourtseyCall Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Pegasus_CourtseyCall(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_CourtseyCall',@Desc,'Pegasus'


	Set NoCount OFF;
END
