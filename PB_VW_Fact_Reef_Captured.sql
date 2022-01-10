


CREATE view [dbo].[PB_VW_Fact_Reef_Captured]
as
	select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
	A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
	case when A.Detail='1' then 'Worst' when A.Detail='2' then 'Poor' when A.Detail='3' then 'Average' when A.Detail='4' then 'Good' when A.Detail='5' then 'Best' else 'N/A' end  as Answer,
	case when A.Detail='1' then 1 when A.Detail='2' then 2 when A.Detail='3' then 3 when A.Detail='4' then 4 when A.Detail='5' then 5 else 6 end As RatingSort,Q.Id as QuestionId,
	Q.ShortName as Question , u.name as userName,null as FirstActionDate, --FAD.FirstActionDate,
	 FRD.FirstResponseDate
	,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,
	AM.Longitude,AM.Latitude,case when AM.Narration is null then 0 else 1 end as AutoResolved
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=432 
	inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3475
	inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 and isnull(AM.IsDisabled,0)=0 and AM.PI not in (-1,0)
	inner join [SeenClientAnswers] A on A.SeenClientAnswerMasterId=AM.id
	inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
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

	/*Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	group by CLA.SeenClientAnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id */

	/*Where (G.Id=432 and EG.Id =3475
	and Q.IsRequiredInBI=1--Q.id in(26335,26337,26339,26341,26343,26345) 
	ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and (AM.IsDisabled=0 or AM.IsDisabled is null) ) 
	And AM.PI not in (-1,0) */


