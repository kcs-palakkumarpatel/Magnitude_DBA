

CREATE View [dbo].[BI_Vw_Detail_Information]
As

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,
--(Case When CompanyId = 27 And ET.IsNorth = 0 then -1001 Else CompanyId End) as CompanyId,
(Case When CompanyId = 27 And ET.IsNorth = 1 then 'AFGRI NORTH' Else 
(Case When CompanyId = 27 And ET.IsNorth = 0 then 'AFGRI SOUTH' Else
[CompanyName] End)END) as [CompanyName],
EstablishmentGroupName,SalesPerson,CreatedOn,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[Kommentaar],[Products],[Indien Ander, spesifiseer asseblief],
[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],[Model No.],[Model number],[Wat gelewer is?]

From (

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
[CompanyName],EstablishmentGroupName,SalesPerson,CreatedOn,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[Kommentaar],
[Products],[Indien Ander, spesifiseer asseblief],
NULL as [(1 = Swak ; 5 = Uitstekend)],
NULL as [As ander, besryf asseblief],
NULL as [Comments (No Confidential Information)],
NULL as [Enige mededingende kwotasies?],
NULL as [Preferred financial solution?],
NULL as [Prys],
NULL as [Total Quote Amount],
NULL as [Wat was die uiteinde van u besoek?],
NULL as [Watter produkte was bespreek?],
NULL as [Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
NULL as [Model No.],
NULL as [Model number],
NULL as [Wat gelewer is?]
From (
	SELECT SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail, G.Id as CompanyId,
	G.GroupName as [CompanyName],EG.Id as EstablishmentGroup_Id,
	Replace(Replace(Replace(EG.EstablishmentGroupName,'01',''),'02',''),'03','') as EstablishmentGroupName,
	IsNull(U.Name,'UNDEFINED') as SalesPerson,SAM.CreatedOn,Upper(IsNull(EstablishmentName,'UNDEFINED')) as [Establishment Name]
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId =961
	Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
	Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
	Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
	Where U.Id Not In (363,54)
) S
Pivot (
	Max(Detail)
	For  QuestionTitle In ([Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[Kommentaar],[Products],[Indien Ander, spesifiseer asseblief])
) P

UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
[CompanyName],EstablishmentGroupName,SalesPerson,CreatedOn,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],NULL as [Kommentaar],
NULL as [Products],NULL as [Indien Ander, spesifiseer asseblief],
[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],
[Comments (No Confidential Information)],
[Enige mededingende kwotasies?],
[Preferred financial solution?],
[Prys],
[Total Quote Amount],
[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],
NULL as [Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
NULL as [Model No.],
NULL as [Model number],
NULL as [Wat gelewer is?]
From (
	SELECT SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id as CompanyId,
	G.GroupName as [CompanyName],EG.Id as EstablishmentGroup_Id,
	Replace(Replace(Replace(EG.EstablishmentGroupName,'01',''),'02',''),'03','') as EstablishmentGroupName,
	IsNull(U.Name,'UNDEFINED') as SalesPerson,SAM.CreatedOn,Upper(IsNull(EstablishmentName,'UNDEFINED')) as [Establishment Name]
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId  =963
	Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
	Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
	Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
	Where Q.IsDeleted = 0
	And U.Id Not In (363,54)
) S
Pivot (
	Max(Detail)
	For  QuestionTitle In (
		[Naam],
		[Van],
		[Selfoon Nommer],
		[E-Pos Adres],
		[Maatskappy Naam],
		[Watter produkte was bespreek?], 
		[(1 = Swak ; 5 = Uitstekend)],
		[As ander, besryf asseblief],
		[Comments (No Confidential Information)],
		[Enige mededingende kwotasies?],
		[Preferred financial solution?],
		[Prys],
		[Total Quote Amount],
		[Wat was die uiteinde van u besoek?]
	)
) P

Union All

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
[CompanyName],EstablishmentGroupName,SalesPerson,CreatedOn,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[Kommentaar],
NULL as [Products],NULL as [Indien Ander, spesifiseer asseblief],
NULL as [(1 = Swak ; 5 = Uitstekend)],
NULL as [As ander, besryf asseblief],
NULL as [Comments (No Confidential Information)],
NULL as [Enige mededingende kwotasies?],
NULL as [Preferred financial solution?],
NULL as [Prys],
NULL as [Total Quote Amount],
NULL as [Wat was die uiteinde van u besoek?],
NULL as [Watter produkte was bespreek?],
[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
[Model No.],
[Model number],
[Wat gelewer is?]
From (
	SELECT SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id as CompanyId,
	G.GroupName as [CompanyName],EG.Id as EstablishmentGroup_Id,
	Replace(Replace(Replace(EG.EstablishmentGroupName,'01',''),'02',''),'03','') as EstablishmentGroupName,
	IsNull(U.Name,'UNDEFINED') as SalesPerson,SAM.CreatedOn,Upper(IsNull(EstablishmentName,'UNDEFINED')) as [Establishment Name]
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId  =965
	Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
	Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
	Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
	Where Q.IsDeleted = 0
	And U.Id Not In (363,54)
) S
Pivot (
	Max(Detail)
	For  QuestionTitle In (
		[Naam],
		[Van],
		[Selfoon Nommer],
		[E-Pos Adres],
		[Maatskappy Naam],
		[Kommentaar],
		[Is daar enige onopgeloste probleme? Indien ja, verduidelik asseblief],
		[Model No.],
		[Model number],
		[Wat gelewer is?]
	)
) P

) Z
Left Outer Join [dbo].[Establishment_Town]  ET on ET.[Town Name] = LTrim(SubString(ltrim(Z.[Establishment Name]),(Len(ltrim(Z.[Establishment Name])) - Len(ltrim(ET.[Town Name]))+1),Len(ltrim(ET.[Town Name]))))

