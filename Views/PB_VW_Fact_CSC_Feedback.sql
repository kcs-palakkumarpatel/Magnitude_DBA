


	CREATE view [dbo].[PB_VW_Fact_CSC_Feedback] as


	select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
	AM.SeenClientAnswerMasterId,AM.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
	case when A.Detail='Extremely Likely' then 10 when A.Detail='Extremely Unlikely' then 1 else A.Detail end as Answer
	,Q.Id as QuestionId,
	Q.ShortName as Question ,
	(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAC.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
	and CD.QuestionTypeId = 4
	) AS UserName,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)  when (RD.ResolvedDate is null and AM.IsResolved ='Resolved') then RD1.ResolvedDate else  RD.ResolvedDate end As ResolvedDate,
	AM.Longitude,AM.Latitude
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid
	inner join Establishment E on E.EstablishmentGroupId=EG.Id
	inner join AnswerMaster AM on AM.EstablishmentId=E.id
	inner join [Answers] A on A.AnswerMasterId=AM.id
	inner join Questions Q on Q.id=A.QuestionId
	left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
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
	Select CLA.SeenClientAnswerMasterId as ReferenceNo,max(dateadd(MINUTE,SAM.TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join SeenClientAnswerMaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	left outer join Answermaster AM on AM.SeenClientAnswerMasterId=SAM.Id
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD1 on RD1.ReferenceNo = SAM.Id
	where (G.Id=70 and EG.Id =429 and Q.id =13052 
	and (AM.IsDeleted=0 or AM.IsDeleted is null) 
	and (AM.IsDisabled=0 or AM.IsDisabled is null))
