
Create view PB_VW_LG_Fact_GreenHouseRequestFeedback as


with cte as(
 select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
RepeatCount,
Isnull([Select the Process],'')as [Select the Process],
Isnull([Changes to Request],'') as [Changes to Request],
Isnull([Would you like:],'') as [Would you like:],
[Add More],
Isnull([Add Plant type],'') as [Add Plant type],
Isnull([Add Plant Size],'') as [Add Plant Size],
[Add Quantity],
[Less Add More],
Isnull([Less Plant Type],'') as [Less Plant Type],
Isnull([Less Plant Size],'') as [Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
Isnull([What is missing],'') as [What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
Isnull([Ret Plant Type],'') as [Ret Plant Type],
Isnull([Ret Plant Size],'') as [Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
Isnull([Missing item],'') as [Missing item],
[Mis Add More],
Isnull([Mis Plant Type],'') as [Mis Plant Type],
Isnull([Mis Plant Size],'') as [Mis Plant Size],
[Mis Quantity] from(

select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
1 as RepeatCount,
[Select the Process],
[Changes to Request],
[Would you like:],
'Yes' as [Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
'Yes' as [Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
'Yes' as [Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
'Yes' as [Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseRef,AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (31235,31236,31309, 31112,31252,31114, 31133,31257,31135,31292,31154,31184,31293,31294,31160,31163,31164,31188, 
31190,31262,31192, 31209, 31211,31431, 31215,31267,31217)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
))P )A
/*
union all

select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
2 as RepaetCount,
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseRef,AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (31235,31236,31309, 31272,31116,31253,31118, 31276,31137,31258,31139,31292,31154,31184,31293,31294,31160,31163,31164,31188, 
31280,31194,31263,31196, 31209, 31211,31431, 31284,31219,31268,31221)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
))P

union all

select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
3 as RepeatCount,
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseRef,AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (31235,31236,31309,31273,31120,31254,31122,31277,31140,31259,31142,31292,31154,31184,31293,31294,31160,31163,31164,31188, 
31281,31198,31264,31200, 31209, 31211,31431, 31285,31223,31269,31225)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
))P

union all
select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
4 as RepeatCount,
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseRef,AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (31235,31236,31309,31274,31124,31255,31127, 31278,31145,31260,31147,31292,31154,31184,31293,31294,31160,31163,31164,31188, 
31282,31201,31265,31203,31209, 31211,31431, 31286,31227,31271,31229)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
))P

union all
select 
EstablishmentName,ResponseDate,ResponseRef,SeenClientAnswerMasterId,
5 as RepeatCount,
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseRef,AM.SeenClientAnswerMasterId,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=514 and EG.Id =5677
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (31235,31236,31309,31275,31128,31256,31130,31279,31149,31261,31151,31292,31154,31184,31293,31294,31160,31163,31164,31188, 
31283,31205,31266,31207, 31209, 31211,31431, 31288,31231,31270,31233)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

)S
pivot(
Max(Answer)
For  Question In (
[Select the Process],
[Changes to Request],
[Would you like:],
[Add More],
[Add Plant type],
[Add Plant Size],
[Add Quantity],
[Less Add More],
[Less Plant Type],
[Less Plant Size],
[Less Quantity],
[Collection Assign],
[Estimated Pickup],
[Date and Time],
[Is the collection],
[Items accounted],
[What is missing],
[Full Name],
[Signature],
[No of Return Plant],
[Ret Add More],
[Ret Plant Type],
[Ret Plant Size],
[Ret Quantity],
[Date and Time Return],
[Missing item],
[Mis Add More],
[Mis Plant Type],
[Mis Plant Size],
[Mis Quantity]
))P

) A where A.[Add More]='Yes' or A.[Less Add More]='Yes'  or A.[Ret Add More]='Yes' or A.[Mis Add More]='Yes' 
*/
)
SELECT * from cte AS a
WHERE ResponseDate=(
    SELECT max(responsedate) 
    FROM cte AS b
    WHERE a.SeenClientAnswerMasterId = b.SeenClientAnswerMasterId
      AND a.[Select the Process] = b.[Select the Process]
)

/*
SELECT * from cte
WHERE ResponseDate=(
SELECT SeenClientAnswerMasterId,[Select the Process],max(responsedate) as ResponseDate from cte group by SeenClientAnswerMasterId,[Select the Process]);
*/

