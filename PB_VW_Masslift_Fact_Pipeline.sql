

CREATE view [dbo].[PB_VW_Masslift_Fact_Pipeline]
as
select X.*,
Y.CapturedDate as ResponseDate,
Y.ReferenceNo as ResponseReferenceNo,
Y.PI as ResponsePI,
isnull([Are you speaking to the same person?],'') as [Are you speaking to the same person?],
isnull([Who are you speaking to?],'') as [Who are you speaking to?],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status:],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) as[Status:],
isnull([Describe the follow up:],'')as [Describe the follow up:],
isnull([Reason for lost sale:],'') as [Reason for lost sale:],
isnull([Please state other:],'')as [Please state other:],
isnull([Who are the competitors?],'') as [Who are the competitors?],
isnull([What was the competitors price (ZAR)?],'') as [What was the competitors price (ZAR)?],
isnull([Type of contract:],'') as [Type of contract:],
isnull([Has the client financed?],'') as [Has the client financed?],
isnull([Who has the client financed with?],'') as [Who has the client financed with?],
isnull([Size of client:],'') as [Size of client:],
isnull([Has this prospect become hot?],'') as [Has this prospect become hot?],
isnull([Value of deal (ZAR)],'')as [Value of deal (ZAR)],
0 as DummyRow,
case when [Status:]='Send quote' then 1 when  [Status:]='Positive Feedback' then 2 when  [Status:]='Acceptance of quote' then 3 
when  [Status:]='Signed documentation and complete sales stack' then 4 when  [Status:]='Lost sale' then 5 when  [Status:]='Deal Made' then 6 else 0  end as Sort
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
[Are you logging an opportunity?],
[Company name:],
[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
replace([Price of the opportunity (ZAR):],',','.') as [Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],
[Industry]

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,

Q.Questiontitle as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
)  + ' ' +
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as CustomerName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=4931 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1 --q.id in (50676,37343,37344,37345,37346,37347,37348,37349,37351,37352,37353,40501,40502,40503)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy 
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
where convert(date,Am.CreatedOn,104)>=convert(date,'19-09-2019',104)and u.id not in (3722,3973)
) S
Pivot (
Max(Answer)
For  Question In (
[Are you logging an opportunity?],
[Company name:],
[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
[Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],
[Industry]
))P
)X

left join
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserName,

[Are you speaking to the same person?],
[Who are you speaking to?],
Ltrim(RTrim(Replace(Replace(Replace(Replace(Replace(Replace([Status:],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) as[Status:],
[Describe the follow up:],
[Reason for lost sale:],
[Please state other:],
[Who are the competitors?],
[What was the competitors price (ZAR)?],
[Type of contract:],
[Has the client financed?],
[Who has the client financed with?],
[Size of client:],SeenClientAnswerMasterId,
[Has this prospect become hot?],
replace([Value of deal (ZAR)],',','.') as[Value of deal (ZAR)]
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,
Q.QuestionTitle as Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as UserName ,AM.SeenClientAnswerMasterId

from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 463 and eg.id=4931 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and  Q.IsRequiredInBI=1--q.id in (24888,24889,24890,24891,24892,24893,24894,24895,24896,24897,24898,24899,26210,26267,28198)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster SAM on SAM.Id=am.SeenClientAnswerMasterId and (SAM.IsDeleted=0 or SAM.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId 


) S
Pivot (
Max(Answer)
For  Question In (
[Are you speaking to the same person?],
[Who are you speaking to?],
[Status:],
[Describe the follow up:],
[Reason for lost sale:],
[Please state other:],
[Who are the competitors?],
[What was the competitors price (ZAR)?],
[Type of contract:],
[Has the client financed?],
[Who has the client financed with?],
[Size of client:],
[Has this prospect become hot?],
[Value of deal (ZAR)]

))P

)Y on X.referenceno=Y.seenclientanswermasterid 



union all 

select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,
Longitude,Latitude,
CustomerEmail,
isnull(CustomerCompany,'') as CustomerCompany,
CustomerMobile,
CustomerName,
[Are you logging an opportunity?],
[Company name:],
[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
replace([Price of the opportunity (ZAR):],',','.') as [Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],

[Industry],
null as ResponseDate,
NULL as ResponseReferenceNo,
'10.00' as ResponsePI,
'' as [Are you speaking to the same person?],
'' as [Who are you speaking to?],
'Captured' as[Status:],
'' as[Describe the follow up:],
'' as [Reason for lost sale:],
''as [Please state other:],
'' as [Who are the competitors?],
'' as [What was the competitors price (ZAR)?],
'' as [Type of contract:],
'' as [Has the client financed?],
'' as [Who has the client financed with?],
'' as [Size of client:],
'' as [Has this prospect become hot?],
'' as [Value of deal (ZAR)],
1 as DummyRow,
1 as Sort

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer,

Q.Questiontitle as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
)  + ' ' +
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as CustomerName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=4931 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.IsRequiredInBI=1--q.id in (37343,37344,37345,37346,37347,37348,37349,37351,37352,37353,40501,40502,40503)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
where convert(date,Am.CreatedOn,104)>=convert(date,'19-09-2019',104)and u.id not in (3722,3973)
) S
Pivot (
Max(Answer)
For  Question In (
[Are you logging an opportunity?],
[Company name:],
[Is this a hot prospect?],
[What is the opportunity spotted?],
[What model is the customer interested in?],
[Price of the opportunity (ZAR):],
[Are you speaking to ..],
[Name:],
[Surname:],
[Mobile:],
[Number of units?],
[Model type],
[If other, please specify],
[Industry]
))P



