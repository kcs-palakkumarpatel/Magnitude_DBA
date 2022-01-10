CREATE VIEW PB_VW_Protek_Promoters AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       IIF(AA.[Store name]='','N/A',AA.[Store name]) AS [Store name],
       AA.[Time arrived],
       BB.[Time out],
       AA.[Opposition promoters on store],
       AA.[Any issues in store],
       AA.[If yes, what is the problem],
       AA.[Any products out of stock],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ReferenceNo AS Refno,
       --BB.RepeatCount,
       BB.[Product Sold],
       BB.[Quantity Sold],
       BB.[Orders placed],
       BB.[Order Quantity]       
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,
[Store name],[Time arrived],[Time out],[Opposition promoters on store],[Any issues in store],[If yes, what is the problem],[Any products out of stock]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.QuestionTitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5369
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43077,43078,43079,43081,43082,43086,43088)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy	
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Store name],[Time arrived],[Time out],[Opposition promoters on store],[Any issues in store],[If yes, what is the problem],[Any products out of stock]
))p
)AA

LEFT JOIN

(
SELECT K.EstablishmentName,
       K.ResponseDate,
       K.SeenClientAnswerMasterId,
       K.ReferenceNo,
       J.RepeatCount,
       K.[Time out],
       J.[Product Sold],
       J.[Quantity Sold],
       J.[Orders placed],
       J.[Order Quantity]
        FROM 
(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,RepeatCount,
[Time out],[Product Sold],[Quantity Sold],[Orders placed],[Order Quantity]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.ShortName as Question,a.RepeatCount
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 505 and eg.id=5369 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (32105,32107,32108,29540,29541)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount=0
) s
pivot(
Max(Answer)
For  Question In (
[Time out],[Product Sold],[Quantity Sold],[Orders placed],[Order Quantity]
))P
)K

FULL JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,RepeatCount,
[Time out],[Product Sold],[Quantity Sold],[Orders placed],[Order Quantity]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.ShortName as Question,a.RepeatCount
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 505 and eg.id=5369 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (32105,32107,32108,29540,29541)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount<>0
) s
pivot(
Max(Answer)
For  Question In (
[Time out],[Product Sold],[Quantity Sold],[Orders placed],[Order Quantity]
))P
)J ON J.ReferenceNo = K.ReferenceNo
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

