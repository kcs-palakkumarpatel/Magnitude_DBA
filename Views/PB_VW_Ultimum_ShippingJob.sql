CREATE VIEW PB_VW_Ultimum_ShippingJob AS

SELECT AA.EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CaptureDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.CustomerName,
       AA.[Job Reference Number],
       AA.Date,
       AA.Client,
       AA.Route,
       AA.[Shipping Line],
       AA.[Rate type],
       AA.[Shipping Line Rate ($)],
       AA.[Shipping Commission ($) %],
       AA.[Number of Units],
       AA.[Total Tons],
       AA.[Port Agent Name],
       AA.[Port of Load],
       AA.[ETA Load Port],
       AA.[ETD Load Port],
       AA.[Vessel Name],
       AA.[Port of Offload],
       AA.[ETA Destination],
       AA.[Laycan/ Stack Start Date],
       AA.[Laycan/ Stack End Date],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Update],
       BB.Route AS Route1,
       BB.[Shipping Line] AS [Shipping Line1],
       BB.[Rate Type] AS [Rate Type1],
       BB.[Shipping Line Rate ($)] AS [Shipping Line Rate ($)1],
       BB.[Number of Units] AS [Number of Units1],
       BB.[Total Tons] AS [Total Tons1],
       BB.[Port Agent Name] AS [Port Agent Name1],
       BB.[ETA Load Port] AS [ETA Load Port1],
       BB.[ETD Load Port] AS [ETD Load Port1],
       BB.[Vessel Name] AS [Vessel Name1],
       BB.[Port of Offload] AS [Port of Offload1],
       BB.[ETA Destination] AS [ETA Destination1],
       BB.[Lycan/ Stack Start Date] AS [Lycan/ Stack Start Date1],
       BB.[Laycan/ Stack End Date] AS [Laycan/ Stack End Date1],
       BB.[App/Job Reference Number #],
	   BB.[Client Rate $] 
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,Longitude,Latitude,CustomerEmail,CustomerMobile,CustomerName,
[Job Reference Number],[Date],[Client],[Route],[Shipping Line],[Rate type],[Shipping Line Rate ($)],[Shipping Commission ($) %],[Number of Units],[Total Tons],[Port Agent Name],[Port of Load],[ETA Load Port],[ETD Load Port],[Vessel Name],[Port of Offload],[ETA Destination],[Laycan/ Stack Start Date],[Laycan/ Stack End Date]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5847 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (49738,47843,47844,47845,47846,48465,47847,47848,47849,47850,47851,47852,47853,47854,47855,47856,47857,47858,47859,52757)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Job Reference Number],[Date],[Client],[Route],[Shipping Line],[Rate type],[Shipping Line Rate ($)],[Shipping Commission ($) %],[Number of Units],[Total Tons],[Port Agent Name],[Port of Load],[ETA Load Port],[ETD Load Port],[Vessel Name],[Port of Offload],[ETA Destination],[Laycan/ Stack Start Date],[Laycan/ Stack End Date]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Update],[Route],[Shipping Line],[Rate Type],[Shipping Line Rate ($)],[Number of Units],[Total Tons],[Port Agent Name],[ETA Load Port],[ETD Load Port],[Vessel Name],[Port of Offload],[ETA Destination],[Lycan/ Stack Start Date],[Laycan/ Stack End Date],[App/Job Reference Number #],[Client Rate $]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.Id=33486 THEN 'Update' 
	 WHEN q.Id=34641 THEN 'Update' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=5847 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (38867,34641,33420,33421,33422,33423,33424,33425,33426,33427,33428,33429,33430,33431,33432,33433,33434,34642,33486,35424,35457,38868)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Update],[Route],[Shipping Line],[Rate Type],[Shipping Line Rate ($)],[Number of Units],[Total Tons],[Port Agent Name],[ETA Load Port],[ETD Load Port],[Vessel Name],[Port of Offload],[ETA Destination],[Lycan/ Stack Start Date],[Laycan/ Stack End Date],[App/Job Reference Number #],[Client Rate $]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

