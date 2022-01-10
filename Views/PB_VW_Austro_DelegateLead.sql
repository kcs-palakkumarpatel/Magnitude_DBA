CREATE VIEW PB_VW_Austro_DelegateLead AS

SELECT AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.Company,
       AA.[Industry:],
       AA.[Type of lead:],
       AA.[Full Name],
       AA.[Contact Number],
       AA.[Contact Email],
       AA.Topic,
       AA.[About the lead:],
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       BB.[Have you contacted the prospect?],
       BB.[Lead qualified],
       BB.[If yes, date of meeting],
       BB.[General Comments],
       BB.[Outcome of lead],
       BB.[Reason for loosing lead] FROM 
(select CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Company],[Industry:],[Type of lead:],[Full Name],[Contact Number],[Contact Email],[Topic],[About the lead:]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,q.QuestionTitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4023
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (31707,33753,33755,31709,31710,31711,31714,31630)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Company],[Industry:],[Type of lead:],[Full Name],[Contact Number],[Contact Email],[Topic],[About the lead:]
))P
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,Responseno,
[Have you contacted the prospect?],[Lead qualified],[If yes, date of meeting],[General Comments],[Outcome of lead],[Reason for loosing lead]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 462 and eg.id=4023 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted IS NULL)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN (19256,53869,19258,19259,54426,54427)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted IS NULL)
) s
pivot(
Max(Answer)
For  Question In (
[Have you contacted the prospect?],[Lead qualified],[If yes, date of meeting],[General Comments],[Outcome of lead],[Reason for loosing lead]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

