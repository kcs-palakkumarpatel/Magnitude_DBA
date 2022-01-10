create view Pb_VW_Fact_Covid as
Select A.*,ResponseDate,ResponseReferenceNo,
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Household Members],
[Comments] from
(select
AM.id as ReferenceNo,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3281
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3282
) as ResponsibleUser
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=541 and EG.Id =5959
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
)A

left outer join 
(
select 
Convert(date,ResponseDate) as ResponseDate,ResponseReferenceNo,SeenClientAnswerMasterId,
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Household Members],
[Comments]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,--AM.Isresolved as Status,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3281
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3282
) as UserName

,Q.shortname as Question 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=541 and EG.Id =5959
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (34009,34011,34012,34013,34014,34015,34016)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
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
) B on A.referenceno=B.SeenclientAnswermasterid

