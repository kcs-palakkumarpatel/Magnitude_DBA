
CREATE View [dbo].[PB_VW_Fact_Infraset_ReportIssues] 
as
select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude ,
[Name & Surname],
[Customer Company Name],
[Mobile Number],
[Email Address],
[Industry],
[Project Name],
[Project Descriptio],
[If Other, please e],
[Please explain the],
[Please provide you],
[Remedies/Solutions],
[Evaluation],
[Company Name],
[Customer Name],
[Nature of Complain]

from
(

select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
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
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=422 and EG.Id =3355
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and --Q.IsRequiredInBI=1 --
Q.id in (25566,25567,25568,25569,25570,25572,25573,25574,25575,25578,25579,25580,25581,25583,25584,25585,25587,25588,26725,33137,33140,34699)

) S
Pivot (
Max(Answer)
For  Question In (
[Name & Surname],
[Customer Company Name],
[Mobile Number],
[Email Address],
[Industry],
[Project Name],
[Project Descriptio],
[If Other, please e],
[Please explain the],
[Please provide you],
[Remedies/Solutions],
[Evaluation],
[Company Name],
[Customer Name],
[Nature of Complain]
))p

