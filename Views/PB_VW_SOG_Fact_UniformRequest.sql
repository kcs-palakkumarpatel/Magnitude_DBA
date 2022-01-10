
create view PB_VW_SOG_Fact_UniformRequest as
with cte as(
select A.*,B.ResponseDate,
B.[In Stock | Ordered],
B.[Uniform Issued],
B.[Submitted Payroll],
B.[Comments] as ResponseComments
from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
RepeatCount,
[Co No],
[Name & Surname],
[Item],
[Size],
[Comments],
ResolvedDate
from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,Rd.ResolvedDate,
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
Where (G.Id=487 and EG.Id =4959 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(37801,37802,37810,37811,37812)

) S
Pivot (
Max(Answer)
For  Question In (
[Co No],
[Name & Surname],
[Item],
[Size],
[Comments]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[In Stock | Ordered],
[Uniform Issued],
[Submitted Payroll],
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
Where (G.Id=487 and EG.Id =4959 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(25190,25191,25192,25193)

) S
Pivot (
Max(Answer)
For  Question In (
[In Stock | Ordered],
[Uniform Issued],
[Submitted Payroll],
[Comments]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId
)


select 
B.EstablishmentName,
B.CapturedDate,
B.Status,
B.ReferenceNo,
B.UserName,
A.RepeatCount,
B.[Co No],
B.[Name & Surname],
A.[Item],
A.[Size],
A.[Comments],
A.ResolvedDate,
B.ResponseDate,
B.[In Stock | Ordered],
B.[Uniform Issued],
B.[Submitted Payroll],
B.ResponseComments

 from 
(select * from cte where RepeatCount<>0 )A inner join (select * from cte where repeatcount=0)B on A.ReferenceNo=B.ReferenceNo
