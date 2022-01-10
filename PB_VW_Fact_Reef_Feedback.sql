


	CREATE view [dbo].[PB_VW_Fact_Reef_Feedback]

	as
	select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
	AM.SeenClientAnswerMasterId,AM.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail as Answer,Q.Id as QuestionId,
	Q.ShortName as Question ,
	(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=SAC.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
	and CD.QuestionTypeId = 4
	) AS UserName
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=432 
	inner join Establishment E on E.EstablishmentGroupId=EG.Id and EG.Id =3475
	inner join AnswerMaster AM on AM.EstablishmentId=E.id and (AM.IsDisabled=0 or AM.IsDisabled is null)
	inner join [Answers] A on A.AnswerMasterId=AM.id
	inner join Questions Q on Q.id=A.QuestionId
	left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
	/*where (G.Id=432 and EG.Id =3475 --and Q.id in(11261,11262,11263,11264,11265,11266,11347) and (AM.IsDeleted=0 or AM.IsDeleted is null) 
	and (AM.IsDisabled=0 or AM.IsDisabled is null))*/

