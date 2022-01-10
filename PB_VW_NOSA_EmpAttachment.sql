CREATE VIEW PB_VW_NOSA_EmpAttachment AS

SELECT w.Id,
       w.QuestionTitle,
       IIF(x.Data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS Detail 
	   FROM 
(SELECT DISTINCT AM.Id,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2011
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (12540,12541,12542)
)w CROSS APPLY (select Data from dbo.Split(W.Detail,',') ) x

UNION ALL

SELECT w.Id,
       w.QuestionTitle,
       IIF(x.Data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS Detail 
	   FROM 
(SELECT DISTINCT AM.Id,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2653
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (18482,18483,18484)
)w CROSS APPLY (select Data from dbo.Split(W.Detail,',') ) x

