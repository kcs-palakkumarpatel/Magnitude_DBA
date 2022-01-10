

create view PB_VW_SOG_Fact_VehicleHandover as
select A.*,B.ResponseDate,
B.[Report Accepted],
B.[Comments],
B.[Responsibility],
B.[Comment] as ResponseComment from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Vehicle],
[Odometer (KM)],
[GPS Present],
[OnBoard Camera],
[FLIR Present],
[Hand Radio],
[Two-Way Radio],
[Aura Device ],
[Aura Logged In],
[Existing Issues],
[Vehicle Clean],
[Vehicle Roadworthy],
[Comment],
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
Where (G.Id=487 and EG.Id =4619 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(35259,35260,35261,35262,35263,35586,35587,35809,35810,35266,35264,35265,35267)

) S
Pivot (
Max(Answer)
For  Question In (
[Vehicle],
[Odometer (KM)],
[GPS Present],
[OnBoard Camera],
[FLIR Present],
[Hand Radio],
[Two-Way Radio],
[Aura Device ],
[Aura Logged In],
[Existing Issues],
[Vehicle Clean],
[Vehicle Roadworthy],
[Comment]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Report Accepted],
[Comments],
[Responsibility],
[Comment],
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
Where (G.Id=487 and EG.Id =4619 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(22609,22610,22611,22612)

) S
Pivot (
Max(Answer)
For  Question In (
[Report Accepted],
[Comments],
[Responsibility],
[Comment]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

