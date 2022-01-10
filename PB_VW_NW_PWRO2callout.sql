CREATE VIEW dbo.PB_VW_NW_PWRO2callout AS

SELECT EstablishmentName,CapturedDate,CAST(p.CapturedDate AS DATE) AS [Capture Date],ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerCompany,CustomerMobile,CustomerEmail,
[Is this a new or exiting ..],[Time in],[Customer],[Did you receive an order from this visit?],[What transpired in this meeting?],[Time out],[Date for next session]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,AM.IsResolved as Status,
A.Detail as Answer,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3024
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3023
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3021
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3022
) as CustomerName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3047
) as CustomerCompany
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 497 and eg.id=5881 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (48551,48552,48553,48554,48555,48556,49112)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Is this a new or exiting ..],[Time in],[Customer],[Did you receive an order from this visit?],[What transpired in this meeting?],[Time out],[Date for next session]
))p

