

CREATE view  [dbo].[Temp_FA_Captured] as
with capturedcte as(
select EstablishmentName,CapturedDate,ReferenceNo,UserName,RepeatCount,FirstResponseDate,[Short Title],
[Project leader],[Deadline],[Description & goal],[Desired outcomes],[Overall purpose],[Revenue or Cost],
[Milestone Number],[Description],[Planned Start Date],[Finish Date] as[Plan Finish Date]
from(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer

,Q.shortname as Question , u.name as UserName ,A.RepeatCount,FirstResponseDate

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select AM.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
	AnswerMaster AM 
	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
	group by AM.SeenClientAnswerMasterId
	) as FRD on FRD.ReferenceNo = AM.Id
Where (G.Id=512 and EG.Id in(5403,5507,5509,5511,5513,5515,5519,5521,5523,5525,5527,5529,5531,5533,5535,5537,5969,6211,6303,7169,7183,7309,8681,8683,8689,8691,8693)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
--and Q.id in (44322,43543,43545,43910,43546,43547,43548,43549,44323,44324,44325,44326)

)S
pivot(
Max(Answer)
For  Question In (
[Short Title],
[Project leader],
[Deadline],
[Description & goal],
[Desired outcomes],
[Overall purpose],
[Revenue or Cost],
[Milestone Number],
[Description],
[Planned Start Date],
[Finish Date]))P
--select * from Establishmentgroup where groupid=512
)
select 
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,
B.UserName ,A.RepeatCount,B.FirstResponseDate,
B.[Short Title],
B.[Project leader],
B.[Deadline],
B.[Description & goal],
B.[Desired outcomes],
B.[Overall purpose],
B.[Revenue or Cost],
A.[Milestone Number],
A.[Description],
A.[Planned Start Date],
A.[Plan Finish Date]

  from (select * from capturedcte where Repeatcount<>0)A inner join (select * from capturedcte where repeatcount=0)B on A.referenceno=B.referenceNo
