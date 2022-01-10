
CREATE view [dbo].[PB_VW_UM_FactResponses]
as

select 
	isnull(G.Id,0) As GroupId,G.GroupName ,isnull(EG.ID,0) as ActivityId,EG.EstablishmentGroupName As Activity ,isnull(E.id,0) As EstablishmentId,E.EstablishmentName,AM.CreatedOn as ResponseDate,
	AM.SeenclientAnswermasterid,Isnull(AM.id,0) as Id,--SAM.IsSubmittedforgroup,case when SAm.Issubmittedforgroup=1 then SAC.ContactMasterId else SAM.ContactMasterid end  as
	0 as IsSubmittedforgroup,0 as ContactMasterid, 'N/A' as UserEmail, 0 as UserId
	--,(SELECT top 1 detail FROM ContactDetails CD WHERE  CD.ContactMasterId=(case when SAm.Issubmittedforgroup=1 then SAC.ContactMasterId else SAM.ContactMasterid end) and CD.IsDeleted = 0 and CD.Detail<>'' 
	--and CD.QuestionTypeId = 10) as UserEmail
	--,Isnull((Select top 1 id from Appuser a where a.email=(SELECT top 1 detail FROM ContactDetails CD WHERE  CD.ContactMasterId=(case when SAm.Issubmittedforgroup=1 then SAC.ContactMasterId else SAM.ContactMasterid end) and CD.IsDeleted = 0 and CD.Detail<>'' 
	--and CD.QuestionTypeId = 10)
	--),0) AS UserId
	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid
	inner join Establishment E on E.EstablishmentGroupId=EG.Id
	inner join AnswerMaster AM on AM.EstablishmentId=E.id and AM.IsDeleted=0 or AM.IsDeleted is null 
	--left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	--left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
	--left outer join ContactMaster CM on CM.id=SAC.contactMasterid
	--where AM.IsDeleted=0 or AM.IsDeleted is null 


