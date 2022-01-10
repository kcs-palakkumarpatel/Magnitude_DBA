
Create Procedure [dbo].[PB_Proc_Masslift_Fact_ContractExpiry]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ContractExpiry','Masslift_Fact_ContractExpiry Start','Masslift'

	Truncate table dbo.Masslift_Fact_ContractExpiry

	
	Insert into Masslift_Fact_ContractExpiry(EstablishmentName,CapturedDate,ReferenceNo,
Status,
UserName,Longitude,Latitude,
[Salesmen:],
[Contact manager:],
[Location:],
[Customer name:],
[Contract type:],
[Forklift Model:],
[Serial Number:],
[Unit location:],
[Agree:],
[Current Hours:],
[Post contract:],
[Starting Date:],
[RV due:],
--[Masslift Term:],
[Term:],
[Current GP%:],
[Finance :],
[Maintenance:],
[Line total:],
[Condition Report Complete],
[Ownership:],
[Finance:],
[Finance comp:],
[Residual %:],
[Residual (ZAR):],
[Bank residual:],
[Retention %:],
[Retention:],
[Settlement from bank:],
[Finance/bank settlement:],
[Billing comment:],
[Sales comment:],
[6 Month Expiry Date:],
[3 Month Expiry Date:],
[1 Month Expiry Date:],
[Contract Expiry Date:])
	select 
EstablishmentName,CapturedDate,ReferenceNo,
Status,
UserName,Longitude,Latitude,
[Salesmen:],
[Contact manager:],
[Location:],
[Customer name:],
[Contract type:],
[Forklift Model:],
[Serial Number:],
[Unit location:],
[Agree:],
[Current Hours:],
[Post contract:],
[Starting Date:],
[RV due:],
--[Masslift Term:],
[Term:],
[Current GP%:],
[Finance :],
[Maintenance:],
[Line total:],
[Condition Report Complete],
[Ownership:],
[Finance:],
[Finance comp:],
[Residual %:],
[Residual (ZAR):],
[Bank residual:],
[Retention %:],
[Retention:],
[Settlement from bank:],
[Finance/bank settlement:],
[Billing comment:],
[Sales comment:],
[6 Month Expiry Date:],
[3 Month Expiry Date:],
[1 Month Expiry Date:],
[Contract Expiry Date:]
	 from [PB_VW_Masslift_Fact_ContractExpiry]

	Select @Desc = 'Masslift_Fact_ContractExpiry Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_ContractExpiry(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ContractExpiry',@Desc,'Masslift'

	Set NoCount OFF;
END

