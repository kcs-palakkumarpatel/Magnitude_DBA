create view PB_VW_Fact_Austro_Complaints as
select A.*,B.ResponseDate,
Isnull(B.[Are you satisfied ],'') as[Are you satisfied ],
Isnull(B.[Issue Resolution],'') as[Issue Resolution],
Isnull(B.[Type of fix],'') as[Type of fix],
Isnull(B.[Have you contacted],'') as[Have you contacted],
Isnull(B.[Was the outcome],'') as[Was the outcome],
Isnull(B.[What outcome],'') as [What outcome],
isnull(B.[Time taken on fix ],'') as [Time taken on fix ] from(


select EstablishmentName,CapturedDate,
ReferenceNo,
UserName,
ContactName,
Status,
[Issue Title],
[Issue Description],
[Customer],
[Full name:],
[Mobile:],
[Email:],
[Topic],
[If other],
[Is this a critical]

 from
(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,Am.IsResolved as Status,
 u.name as UserName,Q.ShortName as Question,A.Detail as Answer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=DF.Contactid  --and CD.IsDeleted = 0 and CD.Detail<>'' and CD.contactQuestionId=2834
) AS ContactName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =5145
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id  and Isnull(AM.IsDeleted,0)=0 and isnull(AM.IsDisabled,0)=0
inner join [SeenClientAnswers] A on A.SeenClientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join defaultcontact DF on DF.establishmentid=E.id
--left outer join ContactDetails CD on CD.ContactMasterId=AM.ContactMasterId and CD.ContactQuestionId=
/*Where (G.Id=462 and EG.Id =5145
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null))-- And Am.istransferred=0 and Q.IsDeleted=0) */
) S
Pivot (
	Max(Answer)
	For  Question In (
	[Issue Title],
[Issue Description],
[Customer],
[Full name:],
[Mobile:],
[Email:],
[Topic],
[If other],
[Is this a critical]

	))P

)A

left outer join 
(

select ResponseDate,
[Are you satisfied ],
[Issue Resolution],
[Type of fix],
[Have you contacted],
[Was the outcome],
[What outcome],
[Time taken on fix ],
Seenclientanswermasterid

 from
(
select 
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,
Q.ShortName as Question,A.Detail as Answer,AM.SeenClientAnswerMasterId
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =5145
inner join AnswerMaster AM on AM.EstablishmentId=E.id and  Isnull(AM.IsDeleted,0)=0 and isnull(AM.IsDisabled,0)=0
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join ContactDetails CD on CD.ContactMasterId=AM.ContactMasterId and CD.ContactQuestionId=
/*Where (G.Id=462 and EG.Id =5145
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null))-- And Am.istransferred=0 and Q.IsDeleted=0) */
) S
Pivot (
	Max(Answer)
	For  Question In (
[Are you satisfied ],
[Issue Resolution],
[Type of fix],
[Have you contacted],
[Was the outcome],
[What outcome],
[Time taken on fix ]
	))P
) B on A.ReferenceNo=B.SeenClientAnswermasterId

