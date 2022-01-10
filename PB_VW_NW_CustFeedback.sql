CREATE VIEW dbo.PB_VW_NW_CustFeedback AS 

SELECT CC.EstablishmentName,
       CC.CapturedDate,
       CC.ReferenceNo,
       CC.Status,
       CC.UserId,
       CC.UserName,
       CC.Company,
	   CC.[Company name:],
	   CC.[Sales representative on job],
	   CC.PI,
       CC.[Staff satisfaction],
       CC.[Overall service],
       CC.[Response times],
       CC.Pricing,
       CC.[General Comments],
       DD.ResponseDate,
       DD.ReferenceNo AS Refno,
       DD.[What did the problem pertain to?],
       DD.[What was wrong with staff interaction?],
       DD.[What was wrong with the service?],
       DD.[What was wrong with the response times?],
       DD.[What was wrong with our pricing?],
       DD.[Did we face competition?],
       DD.[Which competitors?],
       DD.[Did you know their price?],
       DD.[What was their price (ZAR)],
       DD.[Was the person contacted?],
       DD.[What happened during this point of contact?],
       DD.[Why haven't you contacted the person?],
       DD.[What corrective measures will be implemented to ensure this does not happen again?],
       DD.[Your confidence in the solution?] FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserId,UserName,
--Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Company],[Company name:],NULL AS [Sales representative on job],PI,[Staff interaction] AS [Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,am.PI,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName
--AM.Longitude ,AM.Latitude,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3024
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3023
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3021
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3022
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5263 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (41625,41626,41627,41628,41629,41730,46889)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Company],[Company name:],[Staff interaction],[Overall service],[Response times],[Pricing],[General Comments]
))p

UNION ALL

SELECT BB.EstablishmentName,
       BB.CapturedDate,
       BB.ReferenceNo,
       BB.Status,
       BB.UserId,
       BB.UserName,
	   AA.[Company name],
	   NULL AS [Company name:],
	   AA.[Sales representative on job],
	   BB.PI,
       BB.[Staff satisfaction],
       BB.[Overall service],
       BB.[Response times],
       BB.Pricing,
       BB.[General Comments] FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,[Company name],[Sales representative on job]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
AM.Longitude ,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5039 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (39225,39221)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Sales representative on job]
))p
)AA
RIGHT JOIN 
(
select EstablishmentName,CapturedDate,ReferenceNo,IsResolved AS Status,PI,UserId, UserName,
[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,
am.IsResolved,AM.PI,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5039 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28147,28149,28151,28153,28154)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments]
))P
)BB ON AA.ReferenceNo=BB.ReferenceNo

UNION ALL

SELECT BB.EstablishmentName,
       BB.CapturedDate,
       BB.ReferenceNo,
       BB.Status,
       BB.UserId,
       BB.UserName,
	   AA.[Company name],
	   NULL AS [Company name:],
	   AA.[Sales representative on job],
	   BB.PI,
       BB.[Staff satisfaction],
       BB.[Overall service],
       BB.[Response times],
       BB.Pricing,
       BB.[General Comments] FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,[Company name],[Sales representative on job]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
AM.Longitude ,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5379 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43149,43145)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Company name],[Sales representative on job]
))p
)AA
RIGHT JOIN 
(
select EstablishmentName,CapturedDate,ReferenceNo,IsResolved AS Status,PI,UserId, UserName,
[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as CapturedDate,cam.Id as ReferenceNo,
am.IsResolved,AM.PI,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5379 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28451,28453,28455,28457,28458)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments]
))P
)BB ON AA.ReferenceNo=BB.ReferenceNo
)CC
LEFT JOIN 
(
SELECT QQ.EstablishmentName,
       QQ.ResponseDate,
       QQ.SeenClientAnswerMasterId,
       QQ.ReferenceNo,
       x.Data AS [What did the problem pertain to?],
       QQ.[What was wrong with staff interaction?],
       QQ.[What was wrong with the service?],
       QQ.[What was wrong with the response times?],
       QQ.[What was wrong with our pricing?],
       QQ.[Did we face competition?],
       QQ.[Which competitors?],
       QQ.[Did you know their price?],
       QQ.[What was their price (ZAR)],
       QQ.[Was the person contacted?],
       QQ.[What happened during this point of contact?],
       QQ.[Why haven't you contacted the person?],
       QQ.[What corrective measures will be implemented to ensure this does not happen again?],
       QQ.[Your confidence in the solution?]
       FROM 
(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[What did the problem pertain to?],[What was wrong with staff interaction?],[What was wrong with the service?],[What was wrong with the response times?],[What was wrong with our pricing?],[Did we face competition?],[Which competitors?],[Did you know their price?],[What was their price (ZAR)],[Was the person contacted?],[What happened during this point of contact?],[Why haven't you contacted the person?],[What corrective measures will be implemented to ensure this does not happen again?],[Your confidence in the solution?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 497 and eg.id=5263 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (27561,27562,27563,27564,27565,27566,27567,27568,27569,27571,27572,27573,27574,27575)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[What did the problem pertain to?],[What was wrong with staff interaction?],[What was wrong with the service?],[What was wrong with the response times?],[What was wrong with our pricing?],[Did we face competition?],[Which competitors?],[Did you know their price?],[What was their price (ZAR)],[Was the person contacted?],[What happened during this point of contact?],[Why haven't you contacted the person?],[What corrective measures will be implemented to ensure this does not happen again?],[Your confidence in the solution?]
))P
)QQ 
CROSS apply (select Data from dbo.Split(QQ.[What did the problem pertain to?],',') ) x
)DD ON CC.ReferenceNo=DD.SeenClientAnswerMasterId

