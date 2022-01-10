CREATE View [dbo].[PB_VW_Clifton_Fact_SelftAssessment]
As

Select A.*,ResponseDate,ResponseReferenceNo,
[Student Name],
[Location],
[If other, Let us k],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
[Runny Nose],
[Repeated Shaking],
[Chills],
[Muscle Pain],
[Loss of taste or s],
[Household Members],
[Anything to tell u],
[Anything to Attach],
[Nausea],
[Temperature (],
Longitude,Latitude,
Status,IsPositive

FROM

(select E.EstablishmentName,
AM.id as ReferenceNo,
SH.StatusDateTime, 
u.name as CapturedBy,
es.StatusName,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3410
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3411
) as ResponsibleUser

FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=557 and EG.Id =6215
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and E.id = 28254
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1

)A

left outer join 
(
select 
ResponseDate,ResponseReferenceNo,SeenClientAnswerMasterId,P.Status,
[Student Name],
[Location],
[If other, Let us k],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
[Runny Nose],
[Repeated Shaking],
[Chills],
[Muscle Pain],
[Loss of taste or s],
[Household Members],
[Anything to tell u],
[Anything to Attach],
[Nausea],
[Temperature (],
Longitude,Latitude,IsPositive

from(

select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,AM.IsPositive,
A.Detail as Answer,
AM.IsPositive as Status,
Q.shortname as Question ,
Am.Longitude,Am.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=557 and EG.Id =6215
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and E.id = 28254
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (37335,37336,37338,37339,37340,37341,37342,37343,37344,37345,37347,37348,37349,37350,37351,37352,37353,37354,37742,38256,38846)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
)S
pivot(
Max(Answer)
For  Question In (
[Student Name],
[Location],
[If other, Let us k],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
[Runny Nose],
[Repeated Shaking],
[Chills],
[Muscle Pain],
[Loss of taste or s],
[Household Members],
[Anything to tell u],
[Anything to Attach],
[Nausea],
[Temperature (]
))P
) B on A.referenceno=B.SeenclientAnswermasterid

