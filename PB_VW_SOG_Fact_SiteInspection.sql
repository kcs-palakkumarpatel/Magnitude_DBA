
create view PB_VW_SOG_Fact_SiteInspection as
select A.*,B.ResponseDate,
B.[Issues],
[Resolved],
[How was it resolve],
[What is your plan],
[Comments]from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Site Name],
[Radio],
[Radio Serial No],
[Torch],
[Torch Serial No],
[Patrol Baton],
[Patrol Baton Serial No],
[CCTV System],
[Panic Pack],
[SOG Locker],
[Set Of Keys],
[OB Present],
[Access Register],
[AC Supply Good],
[Guard Room Neat],
[SOG Board],
[Additional Comment],
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
Where (G.Id=487 and EG.Id =4813 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36311,36312,36313,36314,36315,36316,36317,36318,36319,36320,36321,36322,36323,36324,36325,36327,36328)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[Radio],
[Radio Serial No],
[Torch],
[Torch Serial No],
[Patrol Baton],
[Patrol Baton Serial No],
[CCTV System],
[Panic Pack],
[SOG Locker],
[Set Of Keys],
[OB Present],
[Access Register],
[AC Supply Good],
[Guard Room Neat],
[SOG Board],
[Additional Comment]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Issues],
[Resolved],
[How was it resolve],
[What is your plan],
[Comments],
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
Where (G.Id=487 and EG.Id =4813 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(23738,23739,23740,23741,23742)

) S
Pivot (
Max(Answer)
For  Question In (
[Issues],
[Resolved],
[How was it resolve],
[What is your plan],
[Comments]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

