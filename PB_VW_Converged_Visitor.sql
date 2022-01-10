CREATE VIEW PB_VW_Converged_Visitor AS

select CapturedDate,ReferenceNo,IsPositive,Status,PI,IIF(P.PI=100,'Pass','Fail') AS Result,[Captured By],[Captured For],
[Visitor Name],[Visitor Surname],[Contact Number],[Email],[Company/Organisati],[traveled 21 days],[Exposed],[Cough],[Sore Throat],[Short of breath],[Redness of eyes],[Body aches],[Loss of taste or s],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Fever],[Temp. <37.5°C],[Temperature ],[C-19 Facility],[Severe Pneumonia],[Flu like Symptoms],
Latitude,Longitude
from(
select 
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,am.pi,
A.Detail as Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as [Captured By],AM.Latitude,AM.Longitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4657
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4658
) as [Captured for]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
Where (G.Id=712 and EG.Id =8025 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(77723,77724,77725,77726,77727,77729,77731,77733,77734,77735,77736,77737,77738,77739,77740,77741,77742,77745,77746,77747,77748,77749,77750)
) S
Pivot (
Max(Answer)
For  Question In (
[Visitor Name],[Visitor Surname],[Contact Number],[Email],[Company/Organisati],[traveled 21 days],[Exposed],[Cough],[Sore Throat],[Short of breath],[Redness of eyes],[Body aches],[Loss of taste or s],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Fever],[Temp. <37.5°C],[Temperature ],[C-19 Facility],[Severe Pneumonia],[Flu like Symptoms]
))P 

