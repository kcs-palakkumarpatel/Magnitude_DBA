

CREATE Procedure [dbo].[PB_Proc_Afgri_DetailInformation]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_DetailInformation','Afgri_DetailInformation Start','Afgri'

	Truncate table dbo.Afgri_DetailInformation

	Insert Into dbo.Afgri_DetailInformation(EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,
EstablishmentGroupName ,SalesPerson,CreatedOn,[Establishment Name],[Naam],[Van] ,[Selfoon Nommer] ,[E-Pos Adres] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
[Model No.],[Model number],[Wat gelewer is?]) 
	Select EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,
EstablishmentGroupName ,SalesPerson,CreatedOn,[Establishment Name],[Naam],[Van] ,[Selfoon Nommer] ,[E-Pos Adres] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
[Model No.],[Model number],[Wat gelewer is?] From dbo.BI_Vw_Detail_Information


	Select @Desc = 'Afgri_DetailInformation Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_DetailInformation(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_DetailInformation',@Desc,'Afgri'

	Set NoCount OFF;
END

