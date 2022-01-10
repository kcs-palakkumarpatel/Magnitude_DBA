



CREATE view [dbo].[PB_VW_Fact_AustroOpportunitySummary] as
Select X.*, case when Y.leadreferenceno is null then 0 else 1 end as IsDelegate, Y.LeadCapturedDate,Y.LeadResponseDate,Y.Name as Name_1,Y.[Meeting Set Up],
Y.[If yes, date of me],
Y.[General Comments ],
Y.[Contacted Prospect]
 from
(/*select
Activity,EstablishmentName,CapturedDate,ReferenceNo,
UserId,UserName,Customer,
[Full Name] as Name,
[Email ],
[Mobile],
[Additional Opportu] as [Opportunity],
[If yes, please exp] as [What Opportunity],
[Value of additiona] as [Price],Status,
'N/A' as Industry,
(Select count(Distinct AM.id) from  dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4211
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and  (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
/*Where (G.Id=462 and EG.Id =4211
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))*/) as Total
from
(
select 
EG.EstablishmentGroupName as Activity ,E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude , CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4211
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
Where /*(G.Id=462 and EG.Id =4211
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
--and Q.id in (32829,32830,32831,32858,32859,32860)
and */ U.id<>3724
) S
Pivot (
Max(Answer)
For  Question In (

[Full Name],
[Email ],
[Mobile],
[Additional Opportu],
[If yes, please exp],
[Value of additiona]
))p --where [Additional Opportu]='Yes'

union all
*/
select
Activity,EstablishmentName,CapturedDate,ReferenceNo,
UserId,UserName,
Customer,
[Name],
[Email],
[Mobile],
[Additional Gaps ] as [Opportunity],
[If yes, please out] as [What Opportunity],
[Potential financia] as [Price],Status,
[Industry:] as Industry,
(Select count(Distinct AM.id) from  dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3835
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
/*Where (G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))*/) as Total
from
(
select 
EG.EstablishmentGroupName as Activity,E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude , CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3835
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in (32568,32569,32570,30069,30071,30072,33574)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928


Where /*(G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
--and Q.id in (32568,32569,32570,30069,30071,30072,33574)
and */U.id<>3724
) S
Pivot (
Max(Answer)
For  Question In (
[Name],
[Email],
[Mobile],
[Additional Gaps ] ,
[If yes, please out],
[Potential financia] ,
[Industry:]
))p --where [Additional Gaps ]='Yes'
 /*
 union all

 
select 
Activity,EstablishmentName,CapturedDate,ReferenceNo,
UserId,UserName,Customer,
[Name],
[Email],
[Mobile],
[Opportunities] as [Opportunity],
[If yes, what is it]  as [What Opportunity],
[Price (ZAR) ] as [Price],Status,
[Industry:] as Industry,
(Select count(Distinct AM.id) from  dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
 /*Where(G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))*/) as Total


from(
select 

EG.EstablishmentGroupName as Activity,E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId And Q.Id in(31674,31675,32307,31665,31667,31668,33575)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928


Where /*(G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
--And Q.Id in(31674,31675,32307,31665,31667,31668,33575)
and */U.id<>3724
) S
Pivot (
Max(Answer)
For  Question In (
[Opportunities],
[If yes, what is it] ,
[Price (ZAR) ],
[Name],
[Mobile],
[Email],
[Industry:]
))P --where [Opportunities]='Yes'



*/
)X

Left outer join




(select * from
(
select LeadReferenceno,LeadCapturedDate,Name,[Reference No] as ReferenceNo from
(select
SAM.id as LeadReferenceno,dateadd(MINUTE,SAM.TimeOffSet,SAM.CreatedOn) as LeadCapturedDate,Q.Shortname as Question,SA.Detail as Answer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4023
inner join SeenClientAnswerMaster SAM on SAM.EstablishmentId=E.id and isnull(SAM.IsDeleted,0)=0
inner join [SeenClientAnswers] SA on SA.SeenclientAnswerMasterId=SAM.id
inner join SeenClientQuestions Q on Q.id=SA.QuestionId
left outer join dbo.[Appuser] u on u.id=SAM.CreatedBy
--Where G.Id=462 and EG.Id =4023 ANd (SAM.IsDeleted=0 or SAM.IsDeleted=null) --and Q.id in (33752,31620)
)S
pivot(
max(Answer) For  Question In (
[Name],
[Reference No]
))P
) LeadCaptured
left outer join
(
select SeenclientanswermasterId,LeadResponseDate,[Meeting Set Up],
[If yes, date of me],
[General Comments ],
[Contacted Prospect]
from
(
select
Q.shortname as Question,AM.SeenclientanswermasterId,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as LeadResponseDate, A.detail as Answer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and  G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4023 
inner join AnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.Isdeleted,0)=0
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--Where G.Id=462 and EG.Id =4023 ANd (AM.IsDeleted=0 or AM.IsDeleted=null) --and Q.id in (19257,19258,19259,19256) 
)S

pivot(
max(Answer) For  Question In (
[Meeting Set Up],
[If yes, date of me],
[General Comments ],
[Contacted Prospect]
))P
) LeadResponse on Leadcaptured.LeadReferenceno=LeadResponse.SeenclientanswermasterId)Y

on X.referenceno=Y.Referenceno
