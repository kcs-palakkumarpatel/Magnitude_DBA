

--select [Name] as UnitNumber from seenclientoptions where questionid=36373 and id<>289686
CREATE View [dbo].[PB_VW_Fact_OTISCaptured]
as
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserId,
UserName,
case when [Building]='-- Select --' then '' else [Building] end as [Building],
isnull([Unit Number],'') as [Unit Number],
[Visit Type],
[Unit in good working order],
[Any other notes or comments about this visit],
[A possible T-Lead opportunity?],
[If YES, give the brief and key details]
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=453 and EG.Id =4107
inner join Establishment E on  E.EstablishmentGroupId=EG.Id  
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId And Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy


/*Where (G.Id=453 and EG.Id =4107
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1--Q.Id in(32319,34202,32312,31313,32314,32315,32316,36373,32310)*/
) S
Pivot (
Max(Answer)
For  Question In (
[Building],
[Unit Number],
[Visit Type],
[Unit in good working order],
[Any other notes or comments about this visit],
[A possible T-Lead opportunity?],
[If YES, give the brief and key details]
))P
