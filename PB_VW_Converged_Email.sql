CREATE VIEW PB_VW_Converged_Email AS

select distinct X.*,Y.*
 from
 (
select CapturedDate,ReferenceNo,IsPositive,Status,[Captured By],[Captured For]
from(
select dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer
,Q.ShortName as Question , u.name as [Captured By],AM.Latitude,AM.Longitude,
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
Where (G.Id=712 and EG.Id =8029 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
)S
)X

left JOIN

( 
select ResponseDate,PI,IIF(P.PI=100,'Pass','Fail') AS Result, ResponseReferenceNo, P.[Response User],SeenClientAnswerMasterId,
[Travelled in past],[Exposed],[Cough],[Sore throat],[Breath Shortness],[Body aches],[Loss taste/smell],[Fever ],[Fever or history],[Facilitate Care],[Pneumonia],[Flu Symptoms] ,
[Response Lat],
[Response long]
 from(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,Am.Pi,
AM.SeenClientAnswerMasterId,((SELECT TOP 1 detail FROM
dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=4657)+' '+(SELECT TOP 1 detail FROM
dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=4658)) AS [Response User],
Q.shortname as Question,A.Detail as Answer,AM.Latitude as [Response Lat],AM.Longitude as [Response long]
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)
Where (G.Id=712 and EG.Id =8029 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(61461,61463,61465,61466,61467,61469,61470,61477,61478,61479,61480,61481)
) S
Pivot (
Max(Answer)
For  Question In (
[Travelled in past],[Exposed],[Cough],[Sore throat],[Breath Shortness],[Body aches],[Loss taste/smell],[Fever ],[Fever or history],[Facilitate Care],[Pneumonia],[Flu Symptoms]
))P
)Y on X.ReferenceNo=Y.SeenClientAnswerMasterId and X.[Captured For]=Y.[Response User]


