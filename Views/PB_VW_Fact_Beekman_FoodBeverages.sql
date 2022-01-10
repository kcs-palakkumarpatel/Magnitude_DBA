


CREATE View [dbo].[PB_VW_Fact_Beekman_FoodBeverages] as
select
(Case When CharIndex(' at ',E.EstablishmentName) > 0 then substring(E.EstablishmentName,CharIndex(' at ',E.EstablishmentName)+4,1000) 
	  When CharIndex(' Food and Beverages',E.EstablishmentName) > 0 then (case when CharIndex('F&B',E.EstablishmentName) > 0 then substring(E.EstablishmentName,5, CharIndex(' Food and Beverages',E.EstablishmentName)-4) else substring(E.EstablishmentName,1, CharIndex(' Food and Beverages',E.EstablishmentName))end)
	  -- (case when CharIndex('F&B',E.EstablishmentName) > 0 then substring(E.EstablishmentName,CharIndex('F&B',E.EstablishmentName),len(E.EstablishmentName))
Else
E.EstablishmentName
End) as EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail As Answer,
 case when (A.Detail='Poor') then '1' when (A.Detail='Average') then '2' when (A.Detail='Good') then '3' when (A.Detail='Very Good') then '4' when (A.Detail='Excellent' ) then '5' else 6 end as Rating

,Q.ShortName as Question ,--U.id as UserId,-- u.name as UserName,
FAD.FirstActionDate,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,


AM.Longitude, AM.Latitude,case when AM.Narration is null then 0 else 1 end as AutoResolved

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=488 and EG.Id =4815
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
Left Outer Join (
	Select CLA.AnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join answermaster SAM on SAM.Id=CLA.AnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.AnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id


	Left Outer Join (
	Select CLA.AnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join answermaster SAM on SAM.Id=CLA.AnswerMasterId
	where Conversation Not Like '%Resolved%'
	group by CLA.AnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id

/*Where (G.Id=488 and EG.Id =4815)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) 
and Q.IsRequiredInBI=1--Q.id in (23804,23805,23806,23807,23808)--,23754)*/
