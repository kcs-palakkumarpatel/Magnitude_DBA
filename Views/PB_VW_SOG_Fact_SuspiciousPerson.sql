
create view PB_VW_SOG_Fact_SuspiciousPerson as
select A.*,B.ResponseDate,
B.[Action Required],
B.[Action Taken],
B.[Client Informed],
B.[Additional Comment]from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Site Name],
[Site Address],
[Name of Suspect],
[Surname of Suspect],
[ID No/DOB],
[Reason],
[Accomplice Name],
[Banning Order],
[Time Period],
[Incident Reported],
[Charges Laid],
[Charges],
[SAPS Station],
[SAPS CAS No],
ResolvedDate
from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
AM.Longitude,AM.Latitude,A.RepeatCount


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
Where (G.Id=487 and EG.Id =4851 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36590,36591,36592,36593,36594,36595,36599,36600,36601,36602,36603,36604,36605,36606)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[Site Address],
[Name of Suspect],
[Surname of Suspect],
[ID No/DOB],
[Reason],
[Accomplice Name],
[Banning Order],
[Time Period],
[Incident Reported],
[Charges Laid],
[Charges],
[SAPS Station],
[SAPS CAS No]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Action Required],
[Action Taken],
[Client Informed],
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
Where (G.Id=487 and EG.Id =4851 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(23937,23938,23939,23940)

) S
Pivot (
Max(Answer)
For  Question In (
[Action Required],
[Action Taken],
[Client Informed],
[Additional Comment]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

