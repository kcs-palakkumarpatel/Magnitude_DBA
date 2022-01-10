CREATE VIEW PB_VW_NOSA_CheckIn AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
	   CAST(AA.CapturedDate AS DATE) AS [Capture Date],
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.[Client name],
       AA.[Activity to be Completed],
       AA.[Depot/DC],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Happy with everything?],
       BB.[If no, why?],
       BB.[Number of Learners],
       BB.Comment 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,
[Client name],[Activity to be Completed],[Depot/DC]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=3697
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (49793,28850,28851,28849)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy	
)s
pivot(
Max(Answer)
For  Question In (
[Client name],[Activity to be Completed],[Depot/DC]
))p
)AA

LEFT JOIN

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Happy with everything?],[If no, why?],[Number of Learners],[Comment]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 296 and eg.id=3697 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (17266,17391,17392,17267)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Happy with everything?],[If no, why?],[Number of Learners],[Comment]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

