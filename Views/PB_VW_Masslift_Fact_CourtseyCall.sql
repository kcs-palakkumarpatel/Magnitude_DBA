

CREATE view [dbo].[PB_VW_Masslift_Fact_CourtseyCall]
as

select X.*,Y.CapturedDate as ResponseDate,
Y.Name as CustomerName,
Y.Company as CustomerCompany,
Y.Email as CustomerEmail,Y.Mobile as CustomerMobile,
Y.[Are you happy with the service of the salesman?],
Y.[Why not?],
Y.[Are we on the same page?],
Y.[Please correct us:],
Y.[Comments:] from(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Company name:],
[Reason for visit:],
[Any issues with this client?],
[If yes, please describe what the issue(s):],
[How is your current relationship with this client?],
[What transpired in the meeting?],
[Wh have you spoken with?]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =4933
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and  (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
Where --(G.Id=463 and EG.Id =4933 and 
u.id not in (3722,3973)
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and convert(date,Am.CreatedOn,104)>=convert(date,'19-09-2019',104)
--and Q.id in(37362,37363,37364,37365,37366,37368,37607)



) S
Pivot (
Max(Answer)
For  Question In (
[Company name:],
[Reason for visit:],
[Any issues with this client?],
[If yes, please describe what the issue(s):],
[How is your current relationship with this client?],
[What transpired in the meeting?],
[Wh have you spoken with?]
))P
)X
left outer join



(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,SeenClientAnswerMasterId,
Company, Name,Email,Mobile,
[Are you happy with the service of the salesman?],
[Why not?],
[Are we on the same page?],
[Please correct us:],
[Comments:]
from(

select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,
A.Detail as Answer,Q.Questiontitle as Question,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as Company,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as Mobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
) +' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as Name,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 and EG.Id =4933
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId  and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*Where (G.Id=463 and EG.Id =4933
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(24903,24904,24905,24906,24907)*/

)s
Pivot (
Max(Answer)
For  Question In (
[Are you happy with the service of the salesman?],
[Why not?],
[Are we on the same page?],
[Please correct us:],
[Comments:]
))p



)Y on X.ReferenceNo=Y.SeenClientAnswerMasterId

