create view  PB_VW_Fact_Otis_AppxSupport as
select X.*,Y.ResponseDate,isnull(Y.Name,'') as ResponseUser,
isnull(Y.[Root cause],'') as [Root cause],
isnull(Y.[Root Cause Type],'') as [Root Cause Type],
isnull(Y.[Type of Fix],'') as [Type of Fix],
isnull(Y.[Time Taken],'') as [Time Taken] from(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserId,
UserName,ResolvedDate,
[Submitting for],
[Colleagues],
[Details],
[Title],
[Category],
[Recurring],
[Severity Assess]
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.Shortname as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
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

Where (G.Id=453 and EG.Id =4043
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.Id in(31860,44518,31810,31809,40950,32216,40951,44425)
) S
Pivot (
Max(Answer)
For  Question In (
[Submitting for],
[Colleagues],
[Details],
[Title],
[Category],
[Recurring],
[Severity Assess]
))P
)X
left outer join 
(
select 
EstablishmentName,ResponseDate,ReferenceNo,Name,
[Root cause],
[Root Cause Type],
[Type of Fix],
[Time Taken],
SeenClientAnswerMasterId
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,Am.SeenClientAnswerMasterId,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.Shortname as Question ,U.Id as UserId, u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2794
) +' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2795
) as Name
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.seenclientanswermasterid
left outer join SeenClientAnswerchild SAC on SAM.id=SAC.Seenclientanswermasterid


Where (G.Id=453 and EG.Id =4043
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.Id in(19406,27603,19738,19428)
) S
Pivot (
Max(Answer)
For  Question In (
[Root cause],
[Root Cause Type],
[Type of Fix],
[Time Taken]
))P


)Y on X.referenceno=Y.seenclientanswermasterid
