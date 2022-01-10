


CREATE view [dbo].[PB_VW_Fact_AustroConsumableFeedback] as

select 
EstablishmentName,
ResponseDate,
ReferenceNo,
SeenClientAnswerMasterId,
IsPositive,
Status,
UserName,
Customer,
Email,
Mobile,
[Service Good],
[Correct Info],
[Make Contact]
from (

select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
	
AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail as Answer,
	Q.ShortName as Question ,
	
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' and CD.contactQuestionId=2834
	) AS UserName,
	(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
	and CD.Detail<>'' and CD.contactQuestionId=2928
) as Customer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' and CD.contactQuestionId=2837
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' and CD.contactQuestionId=2836
) as Mobile
	
from dbo.[Group] G
	
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
	
inner join Establishment E on E.EstablishmentGroupId=EG.Id and EG.Id =3835
	
inner join AnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0 and AM.AppUserId<>3724
	
inner join [Answers] A on A.AnswerMasterId=AM.id
	
inner join Questions Q on Q.id=A.QuestionId and  Q.IsRequiredInBI=1
	
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
/*where (G.Id=462 and EG.Id =3835 and Q.IsRequiredInBI=1
--Q.id in(18128,20194,18127) 
and (AM.IsDeleted=0 or AM.IsDeleted is null) 
	--and (AM.IsDisabled=0 or AM.IsDisabled is null))
	and AM.AppUserId<>3724)*/
) S
Pivot (
Max(Answer)
For  Question In (
[Service Good],
[Correct Info],
[Make Contact]
))p
