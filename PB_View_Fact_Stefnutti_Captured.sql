Create View PB_View_Fact_Stefnutti_Captured
as

	select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
	A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
	case when (Q.id=17619 or Q.id=32019) then (case when A.Detail like '%Cat%' then 'Caterpillar' when A.Detail like '%bell%' then 'Bell' when A.Detail like '%volvo%' then 'Volvo' when A.Detail like '%Excavator%' then 'Volvo' when A.Detail like '%merc%' then 'Mercedes'  when A.Detail like '%hitachi%' then 'Hitachi' when A.Detail like '%test%' then 'Test' else A.detail end ) else A.Detail end as Answer,
	Q.Id as QuestionId,
	Q.ShortName as Question , u.name as UserName,FAD.FirstActionDate, FRD.FirstResponseDate
	,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,
	AM.Longitude,AM.Latitude as Lattitude, case when AM.narration is null then 0 else 1 end as AutoResolved
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid
	inner join Establishment E on  E.EstablishmentGroupId=EG.Id
	inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
	inner join [SeenClientAnswers] A on A.SeenClientAnswerMasterId=AM.id
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

	Left Outer Join (
	Select AM.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
	AnswerMaster AM 
	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
	group by AM.SeenClientAnswerMasterId
	) as FRD on FRD.ReferenceNo = AM.Id

	Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	group by CLA.SeenClientAnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id

	Where (G.Id=213 and EG.Id =2575
	--and Q.id in(26335,26337,26339,26341,26343,26345) 
	ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) ) 


