



CREATE View [dbo].[BI_Vw_FinancedBy]
As

Select SeenClientAnswerMasterId,EstablishmentGroupId,
Split.a.value('.','varchar(100)') as [Financed By]
From (
	Select SA.SeenClientAnswerMasterId,EstablishmentGroupId,
	CAST ('<M>' + REPLACE(Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail
	From SeenClientQuestions Q
	INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  And IsNull(SAM.IsDeleted,0) = 0
	Inner Join dbo.SeenClientAnswers as SA on SA.SeenClientAnswerMasterId = SAM.Id and SA.QuestionId = Q.Id And IsNull(SA.IsDeleted,0) = 0  
	Inner Join dbo.AppUser U on SAM.AppUserId = U.Id And U.IsDeleted = 0
	Inner Join dbo.Establishment E on E.Id = SAM.EstablishmentId 
	And E.EstablishmentGroupId =963
	Where Convert(Date,SAM.CreatedOn) < GetDate()
	And IsNull(Q.IsDeleted,0) = 0
	And SA.QuestionId =14770
	And U.Id Not In (363,54)
) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a) 


