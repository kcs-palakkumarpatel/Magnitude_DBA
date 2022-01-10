CREATE VIEW dbo.PB_VW_Masslift_Fact_Area as
select ReferenceNo,
RepeatCount,
[Area],
[Target annual],
[Used sales YTD],
[Proposals],
[Lost sales shelved],
[Lost sales actual],
[Orders for the month],
[Enquires],
[Trucks/Area],
[% of the Market],
[Year],
[Month] from Masslift_Area_Summary
--union all

--select 
--ReferenceNo,
--RepeatCount,
--[Area],
--[Target annual],
--[Used sales YTD],
--[Proposals],
--[Lost sales shelved],
--[Lost sales actual],
--[Orders for the month],
--[Enquires],
--[Trucks/Area],
--[% of the Market],
--[Year],
--[Month]


--from(
--select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
--AM.IsPositive,AM.IsResolved as Status,AM.PI,
--A.Detail as Answer
--,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
--AM.Longitude,AM.Latitude,A.RepeatCount


--from dbo.[Group] G
--inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463
--inner join Establishment E on  E.EstablishmentGroupId=EG.Id  and EG.Id =5135
--inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 and isnull(AM.IsDisabled,0)=0
--inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
--inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
--left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
----left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2839
--Left Outer Join (
--	Select AM.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
--	AnswerMaster AM 
--	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
--	group by AM.SeenClientAnswerMasterId
--) as FRD on FRD.ReferenceNo = AM.Id
--/*Where (G.Id=463 and EG.Id =5135 --and u.id not in (3722,3973)
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
--and Q.IsRequiredInBI=1--Q.id in(40510,40511,40512,40513,40900,40514,40515,40516,40517,40735,40901,40902,44684,44683)*/

--) S
--Pivot (
--Max(Answer)
--For  Question In (
--[Area],
--[Target annual],
--[Used sales YTD],
--[Proposals],
--[Lost sales shelved],
--[Lost sales actual],
--[Orders for the month],
--[Enquires],
--[Trucks/Area],
--[% of the Market],
--[Year],
--[Month]))P
