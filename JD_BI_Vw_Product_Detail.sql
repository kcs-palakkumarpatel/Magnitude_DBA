



CREATE View [dbo].[JD_BI_Vw_Product_Detail]
As

With CTE As

(

Select SeenClientAnswerMasterId,EstablishmentGroupId,
Split.a.value('.','varchar(100)') as Product 
From (
	Select SA.SeenClientAnswerMasterId,EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId 
	And E.EstablishmentGroupId In (961,2663)
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And Q.IsRequiredInBI=1
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

Union All

Select SeenClientAnswerMasterId,EstablishmentGroupId,
Split.a.value('.','varchar(100)') as Product
From (
	Select SA.SeenClientAnswerMasterId,EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId 
	And E.EstablishmentGroupId In (963,2661)
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And Q.IsRequiredInBI=1 
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

Union All

Select SeenClientAnswerMasterId,EstablishmentGroupId,
Split.a.value('.','varchar(100)') as Product
From (
	Select SA.SeenClientAnswerMasterId,EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId 
	And E.EstablishmentGroupId In (965,2665)
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And Q.IsRequiredInBI=1 
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

) 

Select SeenClientAnswerMasterId,EstablishmentGroupId,
(Case When Product = '' then 'Undefined' Else IsNull(Product,'Undefined') End) as Product 
From CTE

Union all

select Id,EstablishmentGroupId,'Undefined' from JD_BI_Vw_FACT_Magnitude where Id not in (select SeenClientAnswerMasterId From CTE)

--Select Count(1) from BI_Vw_Product_Detail

/*
Select E.EstablishmentGroupId,Q.*
From SeenClientQuestions Q
INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId In (965,1819)
Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
Where Q.IsDeleted = 0


*/



