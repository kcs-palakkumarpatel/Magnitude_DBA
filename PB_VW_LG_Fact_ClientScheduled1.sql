CREATE view [dbo].[PB_VW_LG_Fact_ClientScheduled1]
as
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
[Company Name],
[Site Address],
[Contact Person],
[Contact Person mob],
replace([Scheduled Week],';',',') as [Scheduled Week],
replace([Scheduled Day],';',',') as[Scheduled Day],
[Lead Technician]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status

,Q.shortname as Question ,U.id as UserId, u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3124
) as [Company Name]

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =6783
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
	left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 

left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=514 and EG.Id =6783
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (60775,60776,60777,60778,60779,60780,60781,65280)
And AM.IsResolved='Unresolved'
)S
pivot(
Max(Answer)
For  Question In (
--[Company Name],
[Site Address],
[Contact Person],
[Contact Person mob],
[Scheduled Week],
[Scheduled Day],
[Lead Technician]

))P




