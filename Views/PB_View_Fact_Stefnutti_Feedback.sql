

Create view PB_View_Fact_Stefnutti_Feedback
as
	select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
	AM.SeenClientAnswerMasterId,AM.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
	A.detail as Answer
	,Q.Id as QuestionId,
	Q.ShortName as Question ,
	(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.Questiontypeid=4) AS UserName
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid
	inner join Establishment E on E.EstablishmentGroupId=EG.Id
	inner join AnswerMaster AM on AM.EstablishmentId=E.id
	inner join [Answers] A on A.AnswerMasterId=AM.id
	inner join Questions Q on Q.id=A.QuestionId
	left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
	where (G.Id=213 and EG.Id =2575 --and Q.id in(11261,11262,11263,11264,11265,11266,11347) 
	and (AM.IsDeleted=0 or AM.IsDeleted is null) 
	and (AM.IsDisabled=0 or AM.IsDisabled is null)) 

