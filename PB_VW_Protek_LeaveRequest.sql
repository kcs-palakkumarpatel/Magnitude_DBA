CREATE VIEW PB_VW_Protek_LeaveRequest AS

WITH DateRange
AS 
(SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.[Leave type],
       CONVERT(DATE,AA.[Leave Date]) AS [Leave Date],
       CONVERT(DATE,AA.[Return date]) AS [Return date],
       AA.[Total days leave],
       AA.[Reason for leave],
       AA.[I, the undersigned],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ReferenceNo AS Refno,
       BB.[Do you approve or deny the leave request?],
       BB.[Why did you deny the leave request?] FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,
[Leave type],[Leave Date],[Return date],[Total days leave],[Reason for leave],[I, the undersigned]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.ShortName as Question,u.name as UserName,
AM.Longitude ,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5215
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41215,41216,41217,41218,41219,41225)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy	
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Leave type],[Leave Date],[Return date],[Total days leave],[Reason for leave],[I, the undersigned]
))p
)AA

LEFT JOIN

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Do you approve or deny the leave request?],[Why did you deny the leave request?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 505 and eg.id=5215 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (27287,27288)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Do you approve or deny the leave request?],[Why did you deny the leave request?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName!='Protek Admin' AND AA.[Leave Date]!=''

UNION ALL
SELECT EstablishmentName,
       CapturedDate,
       ReferenceNo,
       Status,
       UserName,
       Longitude,
       Latitude,
       [Leave type],
       DATEADD(DAY,1,[Leave Date]),
       [Return date],
       [Total days leave],
       [Reason for leave],
       [I, the undersigned],
       ResponseDate,
       Refno,
       [Do you approve or deny the leave request?],
       [Why did you deny the leave request?] FROM DateRange WHERE DateRange.[Leave Date] < DATEADD(DAY,-1,DateRange.[Return date])
)
SELECT Distinct *
FROM DateRange

