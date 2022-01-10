

CREATE Procedure [dbo].[PB_Proc_JohnDeere_DetailInformation]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_DetailInformation','JohnDeere_DetailInformation Start','JohnDeere'

	Truncate table dbo.JohnDeere_DetailInformation

	Insert Into dbo.JohnDeere_DetailInformation(EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,
EstablishmentGroupName ,SalesPerson,CreatedOn,[Establishment Name],[Naam],[Van] ,[Selfoon Nommer] ,[E-Pos Adres] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
[Model No.],[Model number],[Wat gelewer is?]) 
	Select EstablishmentGroup_Id ,SeenClientAnswerMasterId ,CompanyName,
EstablishmentGroupName ,SalesPerson,CreatedOn,[Establishment Name],[Naam],[Van] ,[Selfoon Nommer] ,[E-Pos Adres] ,[(1 = Swak ; 5 = Uitstekend)] ,
[As ander, besryf asseblief] ,[Comments (No Confidential Information)] ,[Enige mededingende kwotasies?] ,[Preferred financial solution?] ,
[Prys] ,[Total Quote Amount] ,[Wat was die uiteinde van u besoek?] ,[Watter produkte was bespreek?] ,[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
[Model No.],[Model number],[Wat gelewer is?] From dbo.JD_BI_Vw_Detail_Information


	Select @Desc = 'JohnDeere_DetailInformation Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_DetailInformation(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_DetailInformation',@Desc,'JohnDeere'

	Set NoCount OFF;
END

