

CREATE view [dbo].[PB_VW_Nosa_Fact_Covid] as

Select A.EstablishmentName,ReferenceNo,CapturedDate,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,
[Location],
[Fever],
[Cough],
[Sore Throat],
[Headache],
[Tiredness],
[Breathe Shortness],
[Aches and Pains],
[Diarrhoea],
[Nausea],
[Runny Nose],
[Repeated Shaking],
[Chills ],
[Muscle Pain ],
[Loss Taste/Smell],
[Household Members],
[underlying medical],
[What is condition],
[Comments],
Longitude,Latitude,isnull([Your temperature],'')as [Your temperature],A.EmployeeId from
(select E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
AM.id as ReferenceNo,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as ResponsibleUser,SH.StatusDateTime, case when es.StatusName is null then 'Covid Status Unknown 'else es.StatusName end as StatusName,isnull(SAC.id,0) as SACID
,(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3343
) as EmployeeId
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=296 and EG.Id=6047
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
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
[Dry Cough]as[Cough],
[Sore Throat],
[Headache],
[Tiredness],
[Breathe Shortness],
[Aches and Pains],
[Diarrhoea],
[Nausea],
[Runny Nose],
[Repeated Shaking],
[Chills ],
[Muscle Pain ],
[Loss Taste/Smell],
[Household Members],
[underlying medical],
[What is condition],
[Comments],
[Your temperature],Longitude,Latitude,SACID
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,--AM.Isresolved as Status,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as UserName

,Q.shortname as Question ,Am.Longitude,Am.Latitude,AM.SeenClientAnswerChildId as SACID
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=296 and EG.Id =6047
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId AND Q.ID IN (34962,34963,34964,34965,34966,34967,34968,34969,34980,34981,34982,34983,34984,34985,34986,35254,35255,36735,39497,39498,39499,39500,53057)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on SAC.id =(case when SAM.IsSubmittedForGroup=1 then AM.SeenclientAnswerChildId else null end)
)S
pivot(
Max(Answer)
For  Question In (
[Location],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Tiredness],
[Breathe Shortness],
[Aches and Pains],
[Diarrhoea],
[Nausea],
[Runny Nose],
[Repeated Shaking],
[Chills ],
[Muscle Pain ],
[Loss Taste/Smell],
[Household Members],
[underlying medical],
[What is condition],
[Comments],
[Your temperature]
))P
) B on A.referenceno=B.SeenclientAnswermasterid and A.SACID=B.SACID

