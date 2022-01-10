
Create View PB_VW_Topbet_Fact_CustomerExperience  as

select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
[Friendliness],
[Helpfulness],
[Cleanliness],
[Betting Stations],
[Sports fixtures],
[Betting Products],
[Placing Your Bet],
[Time Taken],
[Comfort],
[Anything to Add],
[Respond to you]
from( 
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI
--A.Detail as Answer
,Q.shortname as Question ,
case when A.detail='Excellent' then '  Excellent' when A.detail='Good' then ' Good' when A.detail='Average' then 'Average' when A.Detail='Poor' then 'Poor' else A.Detail end as Answer

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=484 and EG.Id =4591
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(22505,22506,22508,22512,22514,22515,22516,22517,22509,22518,26657)

)S
pivot(
Max(Answer)
For  Question In (
[shortname],
[Friendliness],
[Helpfulness],
[Cleanliness],
[Betting Stations],
[Sports fixtures],
[Betting Products],
[Placing Your Bet],
[Time Taken],
[Comfort],
[Anything to Add],
[Respond to you]))P
