CREATE VIEW PB_VW_Ultimum_Warehouse AS

SELECT REPLACE(AA.EstablishmentName,'UM Warehouse Capture - ','') AS EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CaptureDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       --AA.CustomerEmail,
       --AA.CustomerMobile,
       --AA.CustomerName,
       AA.Customer,
       AA.Date,
       AA.[Stock Pile Reference number],
       AA.Comity,
       AA.[Client reference],
       AA.[Ultimum Rate (ZAR)],
       AA.Location,
       CAST(BB.ResponseDate AS DATE) AS ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.Type,
       BB.[Truck registration number],
       BB.[Trailer 1],
       BB.[Trailer 2],
       BB.Transporter,
       BB.[Ticket number],
       BB.[Tare weight (Tons)],
       BB.[Net weight (Tons)],
       BB.[Warehouse trans number (if applicable)],
       BB.[Product condition] 
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,--CustomerEmail,CustomerMobile,CustomerName,
[Customer],[Date],[Stock Pile Reference number],[Comity],[Client reference],[Ultimum Rate (ZAR)],[Location]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3252
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3251
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3249
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3250
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5875 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (48426,48427,48428,48429,48430,49699,48431)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Customer],[Date],[Stock Pile Reference number],[Comity],[Client reference],[Ultimum Rate (ZAR)],[Location]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Type],[Truck registration number],[Trailer 1],[Trailer 2],[Transporter],[Ticket number],[Tare weight (Tons)],[Net weight (Tons)],[Warehouse trans number (if applicable)],[Product condition]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=5875 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (32959,32960,32961,32962,32963,32964,32965,32966,32967,33604,34576)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Type],[Truck registration number],[Trailer 1],[Trailer 2],[Transporter],[Ticket number],[Tare weight (Tons)],[Net weight (Tons)],[Warehouse trans number (if applicable)],[Product condition]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

