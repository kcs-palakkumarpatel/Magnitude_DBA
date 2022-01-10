CREATE VIEW PB_VW_Jupidex_ServiceRepair AS

SELECT AA.EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.Company,
       AA.[Serial number],
       AA.Hours,
       AA.Model,
       AA.[Work to be done],
       AA.[Parts used],
       AA.[Are there any issues this month?],
       AA.[If Yes, What is the issue?],
       IIF(AA.[Attachment of issue]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Attachment of issue])) AS [Attachment of issue],
       AA.[General comment],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       IIF(BB.[Do you approve?] IS NULL,'Waiting for Approval',BB.[Do you approve?]) AS [Do you approve?],
       BB.[Why don't you approve?],
       IIF(BB.Signature='' OR BB.Signature IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Signature)) AS Signature,
       BB.Comments 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,CustomerName,CustomerMobile,CustomerEmail,
[Company],[Serial number],[Hours],[Model],[Work to be done],[Parts used],[Are there any issues this month?],[If Yes, What is the issue?],[Attachment of issue],[General comment]
FROM
(SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle AS Question,u.name as UserName,AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2359
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2358
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2356
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=6201 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (52466,52467,52468,52469,52470,52471,52472,52473,52474,52475)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s 
pivot(
Max(Answer)
For  Question In (
[Company],[Serial number],[Hours],[Model],[Work to be done],[Parts used],[Are there any issues this month?],[If Yes, What is the issue?],[Attachment of issue],[General comment]
))p
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,Responseno,
[Do you approve?],[Why don't you approve?],[Signature],[Comments]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 373 and eg.id=6201 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (36927,37626,36928,36929)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Do you approve?],[Why don't you approve?],[Signature],[Comments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

