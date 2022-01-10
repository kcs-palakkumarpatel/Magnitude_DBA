CREATE VIEW PB_VW_Converged_App AS

select CapturedDate,ReferenceNo,IsPositive,Status,PI,IIF(P.PI=100,'Pass','Fail') AS Result,[Captured By],[Captured For],
[Travelled in past],[Exposed virus],[Cough],[Sore throat],[Breath Shortness],[Redness of eyes],[Body aches],[Loss taste/smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Fever],[Temp. <37.5°C],[Facilitate Care],[Pneumonia],[Flu Symptoms],[Screening Time],
Latitude,Longitude
from(
select 
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,am.pi,
A.Detail as Answer,Q.ShortName as Question ,U.Id as UserId, u.name as [Captured By],AM.Latitude,AM.Longitude,
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
Where (G.Id=712 and EG.Id =8027 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(77767,77769,77771,77772,77773,77774,77775,77776,77777,77778,77779,77780,77783,77784,77785,77786,77787,77788)
) S
Pivot (
Max(Answer)
For  Question In (
[Travelled in past],[Exposed virus],[Cough],[Sore throat],[Breath Shortness],[Redness of eyes],[Body aches],[Loss taste/smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Fever],[Temp. <37.5°C],[Facilitate Care],[Pneumonia],[Flu Symptoms],[Screening Time]
))P 

