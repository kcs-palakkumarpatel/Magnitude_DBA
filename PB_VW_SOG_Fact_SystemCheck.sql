

create view PB_VW_SOG_Fact_SystemCheck as
select A.*,B.ResponseDate,
B.[Happy],
B.[Additional Comment]from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Pre-Paid],
[Unit Reading],
[Generator Test Run],
[Generator Full],
[Generator Power],
[Two Jerry Cans],
[UPS Input Voltage ],
[UPS Output Voltage],
[UPS Input Frequenc],
[Inverter Input Vol],
[Inverter Output ],
[Inverter Input ],
[Inverter Output Freq],
[Inverter Battery],
[Battery Bank Clear],
[All Batteries Cool],
[Batteries In Good],
[Comments],
ResolvedDate
from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude,A.RepeatCount,RD.ResolvedDate


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
Where (G.Id=487 and EG.Id =4695 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(35644,35645,35646,35647,35648,35649,35650,35651,35652,35653,35654,35655,35656,35657,35658,35659,35660,35661)

) S
Pivot (
Max(Answer)
For  Question In (
[Pre-Paid],
[Unit Reading],
[Generator Test Run],
[Generator Full],
[Generator Power],
[Two Jerry Cans],
[UPS Input Voltage ],
[UPS Output Voltage],
[UPS Input Frequenc],
[Inverter Input Vol],
[Inverter Output ],
[Inverter Input ],
[Inverter Output Freq],
[Inverter Battery],
[Battery Bank Clear],
[All Batteries Cool],
[Batteries In Good],
[Comments]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Happy],
[Additional Comment],
SeenClientAnswerMasterId


from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=487 and EG.Id =4695 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(22964,22965)

) S
Pivot (
Max(Answer)
For  Question In (
[Happy],
[Additional Comment]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

