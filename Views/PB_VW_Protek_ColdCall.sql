CREATE VIEW PB_VW_Protek_ColdCall AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
	   AA.Latitude,
	   AA.Longitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.[Store name],
       AA.[Time check in],
       AA.[Check Out Time],
       AA.[Suggested order],
       AA.[Credit application],
       AA.[Orders placed],
       AA.[If no, follow up date],
       AA.[Who is the opposition?],
	   CONCAT(AA.Name,' ',AA.Surname) AS [Contact person],
       --AA.Name,
       --AA.Surname,
       AA.Mobile AS [Contact number],
       AA.Email AS [Contact email],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ReferenceNo AS Refno,
       BB.[Where you happy with the services provided by the salesman?],
       BB.[How can we be better?],
       BB.[Do you see you value in our products in your store?],
       BB.[What can we do to show you value?],
       BB.[Would you like to be contacted?] FROM 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Latitude,Longitude,CustomerName,CustomerMobile,CustomerEmail,
[Store name],[Time check in],[Check Out Time],[Suggested order],[Credit application],[Orders placed],[If no, follow up date],[Who is the opposition?],[Name],[Surname],[Mobile],[Email]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3060
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3059
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3057
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3058
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5375
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44245,43050,44706,43054,43056,43057,43058,44708,44709,44710,44711,43059)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Store name],[Time check in],[Check Out Time],[Suggested order],[Credit application],[Orders placed],[If no, follow up date],[Who is the opposition?],[Name],[Surname],[Mobile],[Email]
))p
)AA

LEFT JOIN 

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Where you happy with the services provided by the salesman?],[How can we be better?],[Do you see you value in our products in your store?],[What can we do to show you value?],[Would you like to be contacted?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 505 and eg.id=5375 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28435,28436,28437,28438,28439)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Where you happy with the services provided by the salesman?],[How can we be better?],[Do you see you value in our products in your store?],[What can we do to show you value?],[Would you like to be contacted?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

