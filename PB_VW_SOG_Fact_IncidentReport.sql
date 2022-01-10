
create view PB_VW_SOG_Fact_IncidentReport as
select A.*,B.ResponseDate,
[SOG Corrective Act],
[Client Corrective ],
[Security Upgrades ] from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Site Name],
[Site Address],
[Date & Time ],
[Type],
[Summary],
[Value (ZAR)],
[Victim Name],
[Victim Cell],
[Witness 1 Name],
[Witness 1 Cell],
[Witness 2 Name],
[Witness 2 Cell],
[SAPS Vehicle],
[SAPS Member],
[SAPS Station],
[CAS Number],
[SOG Officer],
[If Yes - Who ],
[Firearm Discharged],
[Firearm Make & Mod],
[Serial No],
[Firearm Serial Num],
[Number of Rounds],
[Report],
[Corrective Action ],
[Action Required By]

from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude,A.RepeatCount


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=487 and EG.Id =4849 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36545,36546,36547,36548,36549,36550,36551,36552,36553,36554,36555,36556,36557,36558,36559,36560,36561,36562,36563,36564,42218,36565,36566,36567,36568,36569)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[Site Address],
[Date & Time ],
[Type],
[Summary],
[Value (ZAR)],
[Victim Name],
[Victim Cell],
[Witness 1 Name],
[Witness 1 Cell],
[Witness 2 Name],
[Witness 2 Cell],
[SAPS Vehicle],
[SAPS Member],
[SAPS Station],
[CAS Number],
[SOG Officer],
[If Yes - Who ],
[Firearm Discharged],
[Firearm Make & Mod],
[Serial No],
[Firearm Serial Num],
[Number of Rounds],
[Report],
[Corrective Action ],
[Action Required By]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Site Name],
[SOG Corrective Act],
[Client Corrective ],
[Security Upgrades ],
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
Where (G.Id=487 and EG.Id =4849 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(23913,23914,23915,23916)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[SOG Corrective Act],
[Client Corrective ],
[Security Upgrades ]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

