CREATE VIEW PB_VW_NOSA_DrivingAttachment AS 

SELECT w.Id,
       w.QuestionTitle,
       IIF(x.Data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS Detail 
	   FROM 
(SELECT DISTINCT AM.Id,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2527
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (17463,17596,17597)
)w CROSS APPLY (select Data from dbo.Split(W.Detail,',') ) x

UNION ALL

SELECT w.Id,
       w.QuestionTitle,
       IIF(x.Data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS Detail 
	   FROM 
(SELECT DISTINCT AM.Id,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2605
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (17943,17944,17945)
)w CROSS APPLY (select Data from dbo.Split(W.Detail,',') ) x

