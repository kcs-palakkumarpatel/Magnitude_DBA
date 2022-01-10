CREATE VIEW dbo.PB_VW_Jupidex_LeadDelegation AS

SELECT --AA.CapturedDate,
	   AA.[Captured Date],
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.CustomerName,
       AA.[Type of lead],
       AA.[Company name],
       AA.Name,
       AA.Surname,
       AA.Mobile,
       AA.Email,
       AA.[Source of lead],
       AA.[About this lead],
       BB.ResponseDate,
       BB.ResponseNo,
       BB.[Have you made contact with the lead ?],
       BB.[How did you contact the lead ?],
       BB.[Why have you not set up a meeting?],
       BB.[What was discussed?],
       BB.[What are the next steps ?],
	   DATEDIFF(MINUTE,AA.CapturedDate,BB.ResponseDate) AS [Response Time]
	   FROM 
(SELECT CapturedDate,CAST(CapturedDate AS DATE) AS [Captured Date],ReferenceNo,Status,UserName,CustomerName,--CustomerMobile,CustomerEmail,CustomerCompany,
REPLACE([Type of lead],'-- Select --','') AS [Type of lead],
[Company name],[Name],[Surname],[Mobile],[Email],REPLACE([Source of lead],'-- Select --','') AS [Source of lead],[About this lead]
FROM
(SELECT
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle AS Question,U.id as UserId, u.name as UserName,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2359
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2358
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2360
--) AS CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2356
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=6393 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70477,70162,55210,55212,55213,55214,55215,55218,55219)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s 
pivot(
Max(Answer)
For  Question In (
[Type of lead],[Company name],[Name],[Surname],[Mobile],[Email],[Source of lead],[About this lead]
))p
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Have you made contact with the lead ?],[How did you contact the lead ?],[Why have you not set up a meeting?],[What was discussed?],[What are the next steps ?]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 373 and eg.id=6393 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (40022,40024,40027,44641,44642)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Have you made contact with the lead ?],[How did you contact the lead ?],[Why have you not set up a meeting?],[What was discussed?],[What are the next steps ?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

