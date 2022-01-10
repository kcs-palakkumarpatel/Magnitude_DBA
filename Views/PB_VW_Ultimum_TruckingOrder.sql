CREATE VIEW dbo.PB_VW_Ultimum_TruckingOrder AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       --AA.IsPositive,
       --AA.Status,
       AA.UserName,
       --AA.CustomerEmail,
       --AA.CustomerMobile,
       --AA.CustomerName,
       AA.[Client Name],
       AA.[Job Reference Number],
       AA.Route,
       AA.[Total Tonnage],
       AA.[Ultimum rate (ZAR)],
       AA.[Expected start date],
       AA.[Expected completion date],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Update],
       BB.Route AS Route1,
       BB.Tonnage,
       BB.[Start Date],
       BB.[End Date],
       BB.[Ultimum rate (ZAR)] AS Rate 
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,CustomerEmail,CustomerMobile,CustomerName,
[Client Name],[Job Reference Number],[Route],[Total Tonnage],[Ultimum rate (ZAR)],[Expected start date],[Expected completion date]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3252
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3251
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3249
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3250
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=6183 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (51909,51910,51911,51912,51913,51914,66320)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Client Name],[Job Reference Number],[Route],[Total Tonnage],[Ultimum rate (ZAR)],[Expected start date],[Expected completion date]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Update],[Route],[Tonnage],[Start Date],[End Date],[Ultimum rate (ZAR)]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=6183 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (49142,48022,48023,48024,48025,49143)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Update],[Route],[Tonnage],[Start Date],[End Date],[Ultimum rate (ZAR)]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

