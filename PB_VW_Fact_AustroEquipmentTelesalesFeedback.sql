



CREATE view [dbo].[PB_VW_Fact_AustroEquipmentTelesalesFeedback] as
select EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,Status,CustomerCompany,CustomerEmail,CustomerMobile,UserName,
[Is the above information correct?],
[What was incorrect?],
[Would you like to be contacted?],
[General comments:]
From(

select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.SeenClientAnswerMasterId,
A.Detail as Answer

,Q.Questiontitle as Question ,
AM.Longitude ,AM.Latitude ,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4853 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and AM.AppUserId<>3724
inner join [Answers] A on A.AnswerMasterId=AM.id 
left join AppUser U on U.id=AM.CreatedBy
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1 --q.id in (23983,23984,23985,23986)
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId 
 
)S
pivot(
Max(Answer)
For  Question In (
[Is the above information correct?],
[What was incorrect?],
[Would you like to be contacted?],
[General comments:]
))P


