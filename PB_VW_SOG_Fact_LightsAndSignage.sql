
create view PB_VW_SOG_Fact_LightsAndSignage as
select A.*,B.ResponseDate,
B.Agrees,
B.[Will Take Care] from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,

[Sector A - Lights],
[Sector A - Sign],
[Sector A Comments],
[Sector B - Lights],
[Sector B - All Sig],
[Sector B Comments],
[Sector C - Lights],
[Sector C - Sign],
[Sector C Comments],
[Sector D - Lights],
[Sector D - Sign],
[Sector D Comments],
[Sector E - Lights],
[Sector E - All Sig],
[Sector E Comments],
[Sector F - All Lig],
[Sector F - All Sig],
[Sector F Comments],
[Sector G - Lights],
[Sector G - Sign],
[Sector G Comments],
[General Site Comme],
ResolvedDate

from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id
Where (G.Id=487 and EG.Id =4847 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36496,36497,36498,36500,36501,36502,36504,36505,36506,36508,36509,36510,36512,36513,36514,36516,36517,36518,36520,36521,36522,36524)

) S
Pivot (
Max(Answer)
For  Question In (

[Sector A - Lights],
[Sector A - Sign],
[Sector A Comments],
[Sector B - Lights],
[Sector B - All Sig],
[Sector B Comments],
[Sector C - Lights],
[Sector C - Sign],
[Sector C Comments],
[Sector D - Lights],
[Sector D - Sign],
[Sector D Comments],
[Sector E - Lights],
[Sector E - All Sig],
[Sector E Comments],
[Sector F - All Lig],
[Sector F - All Sig],
[Sector F Comments],
[Sector G - Lights],
[Sector G - Sign],
[Sector G Comments],
[General Site Comme]
))P
) A
left outer join 
(
select EstablishmentName,ResponseDate,

[Agrees],
[Will Take Care],SeenClientAnswerMasterId

from(

select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as Answer,Q.Shortname as Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
Where (G.Id=487 and EG.Id =4847 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (23903,23905)

) S
Pivot (
Max(Answer)
For  Question In (

[Agrees],
[Will Take Care]))P

) B on A.ReferenceNo=B.SeenClientAnswerMasterId

