

CREATE Procedure [dbo].[PB_Proc_JDF_DetailInformation]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_DetailInformation','JDF_DetailInformation Start','JDF'

	Truncate table dbo.JDF_DetailInformation

	Insert Into dbo.JDF_DetailInformation(EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,PostDate,
EstablishmentGroupName ,SalesPerson,BDO,[Establishment Name],[Name],[Surname] ,[Cell] ,[Email] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Quote Price],
[Deposit Amount (This must be the amount)] ,[Estimated Equipment Delivery Date],[Follow Up Date],Model,Comments,
[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
Stage_TotalDays,Flag,Date,Conversation) 
	Select EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,PostDate,
EstablishmentGroupName ,SalesPerson,BDO,[Establishment Name],[Name],Surname ,[Cell] ,[Email] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Quote Price],
[Deposit Amount (This must be the amount)] ,[Estimated Equipment Delivery Date],[Follow Up Date],Model,Comments,
[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
Stage_TotalDays,Flag,Date,Conversation From dbo.JDF_BI_Vw_Detail_Information


	Select @Desc = 'JDF_DetailInformation Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_DetailInformation(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_DetailInformation',@Desc,'JDF'

	Set NoCount OFF;
END

