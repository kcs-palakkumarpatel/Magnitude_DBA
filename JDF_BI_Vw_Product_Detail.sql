


CREATE View [dbo].[JDF_BI_Vw_Product_Detail]
As

With CTE As
(

Select SeenClientAnswerMasterId,--EstablishmentGroupId,
Split.a.value('.','varchar(100)') as Product
From (
	Select SA.SeenClientAnswerMasterId,--E.EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId In (963,2661) And E.IsDeleted = 0
	Inner Join dbo.JDF_BI_Vw_FinancedBy  F on F.SeenClientAnswerMasterId = SAM.Id and F.[Financed By] ='John Deere Finance'
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And Q.id=5496
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

Union All

Select SeenClientAnswerMasterId,--EstablishmentGroupId,
Split.a.value('.','varchar(100)') as Product
From (
	Select SA.SeenClientAnswerMasterId,--EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId in (2315,2667,2729,2727,2731,2733) And E.IsDeleted = 0
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And Q.IsRequiredInBI=1
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 

) 

Select SeenClientAnswerMasterId,--EstablishmentGroupId,
(Case When Product = '' then 'Undefined' Else IsNull(Product,'Undefined') End) as Product 
From CTE

Union all

select Id,/*EstablishmentGroupId,*/'Undefined' from JDF_BI_Vw_FACT_Magnitude --where IsLikelihood = 0 and 
Where Id not in (select SeenClientAnswerMasterId From CTE)


/*
--Select Count(1) from BI_Vw_Product_Detail


Select Distinct Questiontitle
From SeenClientQuestions Q
INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId And E.EstablishmentGroupId In (2315)
Inner Join dbo.EstablishmentGroup EG on E.EstablishmentGroupId = EG.Id And E.IsDeleted = 0
Inner Join dbo.[group] G on G.Id = EG.GroupId And EG.IsDeleted = 0
Inner Join dbo.AppUser U on U.Id = SAM.AppUserId And U.IsDeleted = 0
Where Q.IsDeleted = 0


*/





