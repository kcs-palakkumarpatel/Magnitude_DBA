




CREATE View [dbo].[PB_VW_Fact_AustroEquipmentOpportunity] as
select X.*,
Y.CapturedDate as ResponseDate,
Y.ReferenceNo as ResponseReferenceNo,
Y.PI as ResponsePI,
isnull(Y.[Reason for lost sale:],'') as[Reason for lost sale:],
Y.[Status:],
isnull(Y.[What can you do better?],'') as [What can you do better?],
isnull(Y.[Who did we loose the deal to?],'') as [Who did we loose the deal to?],
0 as DummyRow,
case when [Status:]='Send quote' then 2 when  [Status:]='Acceptance of quote or positive feedback' then 3 when  [Status:]='Deposit paid' then 5 
when  [Status:]='Received customer order' then 6 when  [Status:]='Lost sale' then 6 else 4  end as Sort
from
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,
Longitude,Latitude,
CustomerEmail,
isnull(CustomerCompany,'') as CustomerCompany,
CustomerMobile,
CustomerName,
[Are you logging an opportunity:],
[Company name:],
[What is the opportunity spotted?],
[What is the customer interested in?],
replace([Price of total opportunity (ZAR):],',','.') as [Price of total opportunity (ZAR):],
[Expected date of delivery:],
[Name:],
[Surname:],
[Mobile:],
isnull([Is this a Biesse opportunity?],'') [Is this a Biesse opportunity?],
isnull([Company Tier],'') as [Company Tier],
isnull([Confidence],'') as [Confidence],
isnull([Brands Presented],'') as [Brands Presented],
isnull([Short Feedback],'') as [Short Feedback],
isnull([Long Feedback],'') as [Long Feedback]

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,

Q.Questiontitle as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4525
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and Isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId And Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenclientAnswerChild SAC on AM.id=SAC.SeenclientAnswerMasterId
Where /*(G.Id=462 and EG.Id =4525
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1
--Q.Id in(36625,35745,36626,36627,36628,36629,36631,36632,36633,36634,37212,45331,45332,45333,45334,45335)

and */U.id<>3724

) S
Pivot (
Max(Answer)
For  Question In (
[Are you logging an opportunity:],
[Company name:],
[What is the opportunity spotted?],
[What is the customer interested in?],
[Price of total opportunity (ZAR):],
[Expected date of delivery:],
[Name:],
[Surname:],
[Mobile:],
[Is this a Biesse opportunity?],
[Company Tier],
[Confidence],
[Brands Presented],
[Short Feedback],
[Long Feedback]
))P
)X

left join
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserName,

[Reason for lost sale:],
[Status:],
[What can you do better?],
[Who did we loose the deal to?],
SeenClientAnswerMasterId
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,
Q.QuestionTitle as Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as UserName ,AM.SeenClientAnswerMasterId

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4525
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id and Am.Appuserid<>3724
inner join Questions Q on Q.id=A.QuestionId and isnull(AM.isdeleted,0)=0 And Q.IsRequiredInBI=1
left join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
left join SeenclientAnswerChild SAC on AM.id=SAC.SeenclientAnswerMasterId
/*Where (G.Id=462 and EG.Id =4525
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1
--Q.Id in(23978,24478,23979,24012)
and Am.Appuserid<>3724*/




) S
Pivot (
Max(Answer)
For  Question In (
[Reason for lost sale:],
[Status:],
[What can you do better?],
[Who did we loose the deal to?]
))P

)Y on X.referenceno=Y.seenclientanswermasterid 
where [Are you logging an opportunity:]='Yes'


union all 

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,
Longitude,Latitude,
CustomerEmail,
isnull(CustomerCompany,'') as CustomerCompany,
CustomerMobile,
CustomerName,
[Are you logging an opportunity:],
[Company name:],
[What is the opportunity spotted?],
[What is the customer interested in?],
replace([Price of total opportunity (ZAR):],',','.') as [Price of total opportunity (ZAR):],
[Expected date of delivery:],
[Name:],
[Surname:],
[Mobile:],
isnull([Is this a Biesse opportunity?],'') as [Is this a Biesse opportunity?],
isnull([Company Tier],'') as [Company Tier],
isnull([Confidence],'') as [Confidence],
isnull([Brands Presented],'') as [Brands Presented],
isnull([Short Feedback],'') as [Short Feedback],
isnull([Long Feedback],'') as [Long Feedback],
null as ResponseDate,
NULL as ResponseReferenceNo,
'10.00' as ResponsePI,
'' as [Reason for lost sale:],
'Captured' as [Status:],
'' as [What can you do better?],
'' as [Who did we loose the deal to?],
1 as DummyRow,
1 as Sort

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,

Q.Questiontitle as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4525
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenclientAnswerChild SAC on AM.id=SAC.SeenclientAnswerMasterId
Where /*(G.Id=462 and EG.Id =4525
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1
--Q.Id in(36625,35745,36626,36627,36628,36629,36631,36632,36633,36634,37212,45331,45332,45333,45334,45335)
and */ U.id<>3724

) S
Pivot (
Max(Answer)
For  Question In (
[Are you logging an opportunity:],
[Company name:],
[What is the opportunity spotted?],
[What is the customer interested in?],
[Price of total opportunity (ZAR):],
[Expected date of delivery:],
[Name:],
[Surname:],
[Mobile:],
[Is this a Biesse opportunity?],
[Company Tier],
[Confidence],
[Brands Presented],
[Short Feedback],
[Long Feedback]
))P


where [Are you logging an opportunity:]='Yes'
