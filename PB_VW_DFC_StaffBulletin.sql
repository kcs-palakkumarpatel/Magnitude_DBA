CREATE VIEW dbo.PB_VW_DFC_StaffBulletin AS 

SELECT AA.EstablishmentName,
       AA.[Capture Date],
       AA.ReferenceNo,
       AA.UserName,
       AA.[What would you like to communicate ?],
       AA.Message,
       IIF(AA.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.Attachments)) AS Attachments,
       BB.ResponseDate,
       BB.ResponseNo,
       BB.Responsename,
       BB.[Please provide us any comments you have on this bulletin] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,UserName,
[What would you like to communicate ?],[Message],[Attachments]
from (
SELECT
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 366 and eg.id=5989 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (49448,49449,49450)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
)s
pivot(
Max(Answer)
For  Question In (
[What would you like to communicate ?],[Message],[Attachments]
))p 
)AA

LEFT JOIN

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,Responsename,
[Please provide us any comments you have on this bulletin]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle as Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as Responsename
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 366 and eg.id=5989
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (35262)
left outer join dbo.[Appuser] u on u.id=am.AppUserId
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
LEFT JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id=am.SeenClientAnswerChildId
) s
pivot(
Max(Answer)
For  Question In (
[Please provide us any comments you have on this bulletin]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

