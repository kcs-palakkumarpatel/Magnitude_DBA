


CREATE view [dbo].[PB_VW_Fact_AustroConsumableTelesalesFeedback] as

select 
EstablishmentName,
ResponseDate,
ReferenceNo,
SeenClientAnswerMasterId,
IsPositive,
Status,
CustomerCompany,
CustomerEmail,
CustomerMobile,
UserName,
[Info Correct ],
[Make Contact],
isnull([General Comments ],'') as [General Comments ]
from (

select 
	E.EstablishmentName,
	dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
	AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail as Answer,
Q.ShortName as Question ,
	(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
	and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as UserName

	from dbo.[Group] G
	inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
	inner join Establishment E on E.EstablishmentGroupId=EG.Id and EG.Id =4211 
	inner join AnswerMaster AM on AM.EstablishmentId=E.id and AM.AppUserId<>3724 and isnull(Am.isdeleted,0)=0
	inner join [Answers] A on A.AnswerMasterId=AM.id
	inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
	left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=SAM.Id
/* 	where (G.Id=462 and EG.Id =4211 and Q.IsRequiredInBI=1
	--Q.id in(20579,20580,20581) 
	and (AM.IsDeleted=0 or AM.IsDeleted is null) 
	and AM.AppUserId<>3724) */
) S
Pivot (
Max(Answer)
For  Question In (
[Info Correct ],
[Make Contact],
[General Comments ]
))p



