
CREATE Procedure [dbo].[PB_Proc_Fact_Pegasus_Pipeline]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_Pipeline','Fact_Pegasus_Pipeline Start','Pegasus'

	Truncate table dbo.Fact_Pegasus_Pipeline
	
	Insert into Fact_Pegasus_Pipeline([EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId,UserName,Longitude,Latitude,[Is this a:],
[Company name:],[Quote number:],[Value of quote (ZAR):],[cap_comments],[Full name:],[Mobile number:],[Email:],[Type of account:],[CustomerName],[CustomerMobile],
[CustomerEmail],[ResponseDate],[Refno],[response_pi],[Status:],[Reason for lost sale:],[Who did we loose the sale to?],
[Percentage price difference on lost deal? (%)],[General comments:],[What was the full value of the purchase order (ZAR):],[sortorder])
select 
	[EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],UserId,UserName,Longitude,Latitude,[Is this a:],
[Company name:],[Quote number:],[Value of quote (ZAR):],[cap_comments],[Full name:],[Mobile number:],[Email:],[Type of account:],[CustomerName],[CustomerMobile],
[CustomerEmail],[ResponseDate],[Refno],[response_pi],[Status:],[Reason for lost sale:],[Who did we loose the sale to?],
[Percentage price difference on lost deal? (%)],[General comments:],[What was the full value of the purchase order (ZAR):],[sortorder]
  from PB_VW_Fact_PegasusPipeline

	Select @Desc = 'Fact_Pegasus_Pipeline Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Pegasus_Pipeline(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_Pipeline',@Desc,'Pegasus'


	Set NoCount OFF;
END
