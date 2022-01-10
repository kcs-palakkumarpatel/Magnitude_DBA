Create view PB_VW_LG_Fact_GreenHouseRequestCaptured as
with cte as(
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,RepeatCount,
[Client Name],
[Site Address],
[Approx Date Req],
[Request type],
[Full Name],
[Role],
[Delivery Team],
[No of plants?],
[Total Returns],
[Plant type],
[If other plant],
[Plant Size],
[Quantity],
[Additional comment],
[What needs Replaci],
[Quantity (bags)],
[MR Additional comment],
[Description],
[Ornament Quantity],
[Image],
[Comment],
[Returning items],
[Return Plant type],
[Return Plant Size],
[Return Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id in (46222,46224,46274,47380,46230,46277,46278,46236,46237,46239,46240,46279,46242,46243,46280,46246,46247,
46249,46250,46251,46252,46254,46255,46281,46257)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Client Name],
[Site Address],
[Approx Date Req],
[Request type],
[Full Name],
[Role],
[Delivery Team],
[No of plants?],
[Total Returns],
[Plant type],
[If other plant],
[Plant Size],
[Quantity],
[Additional comment],
[What needs Replaci],
[Quantity (bags)],
[MR Additional comment],
[Description],
[Ornament Quantity],
[Image],
[Comment],
[Returning items],
[Return Plant type],
[Return Plant Size],
[Return Quantity]))P

)

select
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,B.Status,
B.UserName,A.RepeatCount,
B.[Client Name],
B.[Site Address],
B.[Approx Date Req],
B.[Request type],
A.[Full Name],
A.[Role],
B.[Delivery Team],
B.[No of plants?],
B.[Total Returns],
A.[Plant type],
A.[If other plant],
A.[Plant Size],
A.[Quantity],
A.[Additional comment],
A.[What needs Replaci],
A.[Quantity (bags)],
A.[MR Additional comment],
A.[Description],
A.[Ornament Quantity],
A.[Image],
A.[Comment],
A.[Returning items],
A.[Return Plant type],
A.[Return Plant Size],
A.[Return Quantity]

 from

(select * from cte where RepeatCount=0)B left Outer join (select * from cte where Repeatcount<>0)A on A.ReferenceNo=B.ReferenceNo


