create view  PB_VW_AA_Fact_PsychometricReport
as 




select distinct 
CapturedDate,ReferenceNo,[Student Name] ,[Project Name],UserName as[Captured By],[Gender],[Id Number],
[Full Name],
[Email],
iif([Strengths]='' or [Strengths]='NULL','N/A',[Strengths])as [Strengths],
iif([Challenging traits]='' or [Challenging traits]='NULL','N/A',[Challenging traits])as[Challenging traits],
iif([Evaluation and Con]='' or [Evaluation and Con]='NULL','N/A',[Evaluation and Con])as[Evaluation and Con],
iif([Recommendations]='' or [Recommendations]='NULL','N/A',[Recommendations])as[Recommendations]


from(
select 
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)as date) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3064
)as [Student Name],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4669
) as [Project Name],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4529
) as [Gender],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4530
) as [Id Number]


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id

Where (G.Id=507 and EG.Id =7737 and Q.id in (73744,73746,73751,73752,73753,73754) )
)X
pivot(Max(Answer)
for Question in
(
[Full Name],
[Email],
[Strengths],
[Challenging traits],
[Evaluation and Con],
[Recommendations]))P
--where Status='Resolved'
--order by 3 desc


