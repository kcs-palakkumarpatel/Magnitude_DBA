CREATE view [dbo].[Temp_FA_Response] as

with Responsecte as(
select * from(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
A.Detail as Answer

,Q.shortname as Question , u.name as UserName ,A.RepeatCount,Am.SeenClientAnswerMasterId

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=512 and EG.Id in(5403,5507,5509,5511,5513,5515,5519,5521,5523,5525,5527,5529,5531,5533,5535,5537,5969,6211,6303,7169,7183,7309)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
--and Q.id in (28887,29358,28784,28785,28787,28788,28791,28790)

)S
pivot(
Max(Answer)
For  Question In (
[OVERALL average],
[Milestone #],
[PROGRESS],
[BENEFITS],
[ISSUES to report],
[Describe the issue],
[Issue Category],
[Who can assist you]))P
--select * from Establishmentgroup where groupid=512
)


 select 
B.ResponseDate,B.SeenclientAnswerMasterId,A.RepeatCount,
B.[OVERALL average],
A.[Milestone #],
isnull(A.[PROGRESS],'') as[PROGRESS],
isnull(A.[BENEFITS],'') as[BENEFITS],
isnull(A.[ISSUES to report],'') as[ISSUES to report],
isnull(A.[Describe the issue],'') as[Describe the issue],
isnull(A.[Issue Category],'') as [Issue Category],
isnull(A.[Who can assist you],'') as [Who can assist you]
  from (select * from Responsecte where Repeatcount<>0)A inner join (select * from Responsecte where repeatcount=0)B on A.referenceno=B.referenceNo
  

