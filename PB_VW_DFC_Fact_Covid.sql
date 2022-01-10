Create view PB_VW_DFC_Fact_Covid as

Select A.EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Household Members],
[Comments],
Longitude,Latitude from
(select E.EstablishmentName,
AM.id as ReferenceNo,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as ResponsibleUser,SH.StatusDateTime, case when es.StatusName is null then 'Covid Status Unknown 'else es.StatusName end as StatusName,SAC.Id as SACID

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=366 and EG.Id=5975
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
left outer join SeenclientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
)A

left outer join 
(
select 
ResponseDate,ResponseReferenceNo,SeenClientAnswerMasterId,
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Household Members],
[Comments],Longitude,Latitude,SACID
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,--AM.Isresolved as Status,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as UserName

,Q.shortname as Question ,Am.Longitude,Am.Latitude,AM.SeenClientAnswerChildId as SACID
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=366 and EG.Id =5975
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId --and  Q.id in (34009,34011,34012,34013,34014,34015,34016)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)S
pivot(
Max(Answer)
For  Question In (
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Household Members],
[Comments]
))P
) B on A.referenceno=B.SeenclientAnswermasterid and A.SACID=B.SACID

