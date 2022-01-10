
CREATE View [dbo].[PB_VW_Hilton_Fact_SelftAssessment]
As



Select A.EstablishmentName,ReferenceNo,CapturedDate,UserName,PrimaryContactName,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,
[Student Name],
[Location],
 [Other Location],
[How do you Feel],
[Fever],
[Cough],
[Sore Throat],
[Headache],
--[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
--[Nausea],
--[Runny Nose],
--[Repeated Shaking],
--[Chills],
--[Muscle Pain],
-- [Loss of taste or smell],
[Household Members],
 [Comments],IsPositive,[Temperature (],[Heart racing] from
(select E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
AM.id as ReferenceNo,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3445
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when Am.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3446
) as PrimaryContactName,SH.StatusDateTime, es.StatusName ,isnull(SAC.id,0) as SACID
,U.Name as UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=564 and EG.Id=6307
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
left outer join SeenclientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
left outer join AppUser U on U.id=AM.CreatedBy
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
)A

left outer join 
(
select 
ResponseDate,ResponseReferenceNo,SeenClientAnswerMasterId,[Student Name],
[Location],
[If other, Let us k] as [Other Location],
[How do you feel ri] as [How do you Feel],
[Fever],
[Dry Cough]as[Cough],
[Sore Throat],
[Headache],
--[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
--[Nausea],
--[Runny Nose],
--[Repeated Shaking],
--[Chills],
--[Muscle Pain],
--[Loss of taste or s] as [Loss of taste or smell],
[Do any of your hou] as[Household Members],
[Anything to tell u] as [Comments],IsPositive,
[Temperature (]
,SACID,[Heart racing]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.IsPositive,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3445
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3446
) as UserName

,Q.shortname as Question ,Am.Longitude,Am.Latitude,AM.SeenClientAnswerChildId as SACID
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=564 and EG.Id =6307
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId AND Q.ID IN (38942,38943,38944,38956,38957,38958,38959,38960,38961,38962,38963,38964,38965,38966,38967,38968,38969,38970,38971,38972,38973,38974,39501,39502,40050,53864)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on SAC.id =(case when SAM.IsSubmittedForGroup=1 then AM.SeenclientAnswerChildId else null end)
)S
pivot(
Max(Answer)
For  Question In (
[Student Name],
[Location],
[If other, Let us k],
[How do you feel ri],
[Fever],
[Dry Cough],
[Sore Throat],
[Headache],
--[Extreme Tiredness],
[Shortness of Breat],
[Aches and Pains],
[Diarrhoea],
--[Nausea],
--[Runny Nose],
--[Repeated Shaking],
--[Chills],
--[Muscle Pain],
--[Loss of taste or s],
[Do any of your hou],
[Anything to tell u],
[Temperature (],
[Heart racing]
))P
) B on A.referenceno=B.SeenclientAnswermasterid and A.SACID=B.SACID

