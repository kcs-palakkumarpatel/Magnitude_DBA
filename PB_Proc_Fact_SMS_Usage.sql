CREATE Procedure [dbo].[PB_Proc_Fact_SMS_Usage]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_SMS_Usage','Fact_SMS_Usage Start','SMS Usage'

	Truncate table dbo.Fact_SMS_Usage

	
	Insert into Fact_SMS_Usage(Id,MobileNo,SMStext,SentDate,refid,GroupName,EstablishmentGroupName,EstablishmentName)
	select Id,MobileNo,SMStext,SentDate,refid,GroupName,EstablishmentGroupName,EstablishmentName
	 from [PB_VW_Fact_SMS_Usage]

	Select @Desc = 'Fact_SMS_Usage Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_SMS_Usage(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_SMS_Usage',@Desc,'SMS Usage'

	Set NoCount OFF;
END
