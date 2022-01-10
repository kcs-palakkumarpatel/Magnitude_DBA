





CREATE View [dbo].[PB_VW_Clifton_Fact_SelfReportQR]
As

SELECT *
from(

select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,
AM.Isresolved as Status,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3272
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3276
) as UserName

,Q.shortname as Question ,
Am.Longitude,Am.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=557 and EG.Id =6295
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (38617,38618,38619,38620,38621,38624,38625,38626,38627,38628,38629,38630,38631,38632,38633,38634,38635,38636,38637,38638,38639)
LEFT Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
)S
pivot(
Max(Answer)
For  Question In (
[First Name],
[Last Name],
[Location],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
[[Runny Nose],
[Repeated Shaking],
[Chills],
[Nausea],
[Muscle Pain],
[Loss of Taste],
[Household Sick],
[Comments]))P




