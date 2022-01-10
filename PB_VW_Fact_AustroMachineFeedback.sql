


CREATE View [dbo].[PB_VW_Fact_AustroMachineFeedback] as
select * from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.QuestionTitle as Question ,U.Id as UserId, (SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2834
) AS UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as Customer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) --and CD.IsDeleted = 0 
and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as Mobile


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join AnswerMaster AM on AM.EstablishmentId=E.id and isnull(Am.IsDeleted,0)=0
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.id in(19701,19284,19285,19286,21021,21020)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where /*(G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and */U.id<>3724
)S
pivot (
Max(Answer)
For  Question In (
[Do you see value?],
[Are we on the same page?],
[General Comments],
[Were you happy with the service of the salesman?]
))P


