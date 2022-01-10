
CREATE view JD_BI_Vw_FACT_Magnitude as
With CTE As
(

SELECT FACT.Id,
(Case When FACT.[Company Id] = 27 And ET.IsNorth = 0 then -1001 Else FACT.[Company Id] End) as [Company Id],
FACT.EstablishmentId,FACT.[EstablishmentGroupId],
AppUserId as [Sales Person Id],
IsNull(ET.TownId,-100) as TownId,
IsPositive as [Result],IsResolved as [Status],SenderCellNo as [Sender MobileNo],
Convert(Datetime,FACT.[Post Date]) as [Date],
FACT.Latitude as Latitude, 
FACT.Longitude as Longitude,
LH.Detail as Likelihood,Client.Detail as ClientName,SPName,ET.[Town Name] as TName,0 as IsLikelihood
FROM (
	SELECT SAM.Id,EstablishmentId,
	E.Establishmentgroupid as [EstablishmentGroupId],AppUserId,
	G.Id as [Company Id],G.GroupName as [Company Name],
	IsPositive,IsResolved,SenderCellNo,Convert(Date,Dateadd(mi,SAM.TimeOffSet,SAM.CreatedOn)) as [Post Date],
	Latitude,Longitude,[U].[Name] as SPName,
	--IsNull(Upper(Q.[Name]),'UNDEFINED') as Product,
	IsNull(UPPER(LTRIM(RTRIM(Replace(Replace(Replace(EstablishmentName,'FIRST CONTACT',''),'DELIVERY',''),'SALES CALL','')))),'UNDEFINED') as [TOWN Name]
	FROM dbo.SeenClientAnswerMaster AS SAM 
	Left Outer Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.IsDeleted = 0
	Left Outer Join dbo.EstablishmentGroup EG on EG.Id = E.Establishmentgroupid And EG.IsDeleted = 0
	Left Outer Join dbo.[group] G on G.Id = EG.Groupid And G.IsDeleted = 0
	Left Outer Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Where G.Id In (27,353)  --AFGRI & JOHN DEERE
	And EG.Id in (961,963,965,2661,2663,2665) 
	And U.Id Not In (363,54)
	AND SAM.IsDeleted = 0 
) FACT
Left Outer Join [dbo].[Establishment_Town] ET on ET.[Town Name] = FACT.[Town Name] --3199
Left Outer Join (
	SELECT Distinct SA.SeenClientAnswerMasterId,EG.Id as EstablishmentGroup_Id,U.Id as SalesPerson_Id,
	EstablishmentId,G.Id as [Company Id],SA.Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId In (963,2661)
	Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
	Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
	Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
	Where Q.IsDeleted = 0
	and Q.Id in( 5495,18546)
	And U.Id Not In (363,54)
) Lh on Fact.Id =  Lh.SeenClientAnswerMasterId
And Fact.EstablishmentGroupId = Lh.EstablishmentGroup_Id
And Fact.EstablishmentId = Lh.EstablishmentId
And Fact.AppUserId = Lh.SalesPerson_Id
And FACT.[Company Id] = Lh.[Company Id]

Left Outer Join (
	SELECT Distinct SA.SeenClientAnswerMasterId,EG.Id as EstablishmentGroup_Id,U.Id as SalesPerson_Id,
	EstablishmentId,G.Id as [Company Id],(select top 1 D.Detail from SeenClientAnswers D where D.SeenClientAnswerMasterId=SAM.id and Q.id=D.QuestionId) as Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId In (965,2665)
	Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
	Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
	Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
	Where Q.IsDeleted = 0
	And Q.Id in(5503,18564)
	And U.Id Not In (363,54)
) Client on Fact.Id =  Client.SeenClientAnswerMasterId
And Fact.EstablishmentGroupId = Client.EstablishmentGroup_Id
And Fact.EstablishmentId = Client.EstablishmentId
And Fact.AppUserId = Client.SalesPerson_Id
And FACT.[Company Id] = Client.[Company Id]

) 

Select * From CTE Where [Date] < GetDate() 
Union All
Select Row_Number() OVer (Order By (Select 1)) * -1 as Id,[Company Id],EstablishmentId,-100 as [EstablishmentGroupId],[Sales Person Id],TownId,[Result],[Status],[Sender MobileNo],
[Date],Latitude,Longitude,Likelihood,ClientName,SPName,TName,1 as IsLikelihood
From CTE 
Where Likelihood Between 4 And 5






