CREATE VIEW PB_VW_TopTurf_AllScreening AS

SELECT Z.*,IIF(Z.PI=100,'Pass','Fail') AS Result FROM 
(select 'Employee Screening' AS [Type],CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,UserName,
NULL as HostName,
NULL as [Contact Number],
NULL as [E-Mail],
NULL as [Company/Organisation],
P.PI,
[Have you travelled in the last 21 days?],[If Yes, Where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],
NULL AS [Temperature Reading],
[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?],[Date and Time of Screening],
NULL as [Take a picture of the visitor],
NULL as ResponseDate,
NULL as ResponseNo,
NULL as [Did your guest show any symptoms],
NULL as [What was concerning],
NULL as [Was the guest showing any symptoms],
NULL as [What symptoms were they showing]
From(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,U.Name as UserName,AM.PI
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 667 and eg.id=7329
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (69702,69703,69704,69706,69707,69708,69709,69710,69711,69712,69713,69714,69715,69716,69717,69718,69719,69721,69722,69723,69724)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Have you travelled in the last 21 days?],[If Yes, Where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?],[Date and Time of Screening]
))P

UNION ALL

select 'Email/SMS' AS [Type],CAST(ResponseDate AS DATE) AS ResponseDate,ResponseNo,P.UserName,
NULL as HostName,
NULL as [Contact Number],
NULL as [E-Mail],
NULL as [Company/Organisation],
P.PI,
[Have you travelled in the last 21 days?],[Where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],
NULL AS [Temperature Reading],
[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?],NULL AS [Date and Time of Screening],
NULL as [Take a picture of the visitor],
NULL as ResponseDate,
NULL as ResponseNo,
NULL as [Did your guest show any symptoms],
NULL as [What was concerning],
NULL as [Was the guest showing any symptoms],
NULL as [What symptoms were they showing]
from(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseNo,
AM.SeenClientAnswerMasterId,AM.PI,
A.Detail as Answer,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4413
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4414
) as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAm.IsSubmittedForGroup=1 then SAC.ContactMasterId else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4416
) as UserEmail
,Q.QuestionTitle as Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=667 and EG.Id=7351
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (53103,53104,53105,53107,53108,53109,53110,53111,53112,53113,53114,53115,53116,53117,53118,53119,53120,53121,53122,53123)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on SAC.Id=am.SeenClientAnswerChildId
)S
pivot(
Max(Answer)
For  Question In (
[Have you travelled in the last 21 days?],[Where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?]
))P

UNION ALL

SELECT 'Visitor Screening' AS [Type],
	   AA.CapturedDate,
       AA.ReferenceNo,
       --AA.Status,
       CONCAT(AA.Name,' ',AA.Surname) AS [VisitorName],
	   AA.HostName,
       AA.[Contact Number],
       AA.[E-Mail],
       AA.[Company/Organisation],
       AA.PI,
	   AA.[Have you traveled in the last 21 days?],
       AA.[If Yes, where to?],
       AA.[Have you been exposed to someone who has the COVID-19 virus?],
       AA.Cough,
       AA.[Sore Throat],
       AA.[Shortness of breath],
       AA.[Redness of eyes],
       AA.[Body aches],
       AA.[Loss of taste or smell],
       AA.Nausea,
       AA.Vomiting,
       AA.Diarrhoea,
       AA.Fatigue,
       AA.Weakness,
       AA.Tiredness,
       AA.Fever,
       AA.[Is your temperature below 37.5°C?],
       AA.[Temperature Reading],
       AA.[Have you attended a health care facility where patients with COVID-19 infections are being treated?],
       AA.[Have you been hospitalised recently with severe pneumonia?],
       AA.[Do you currently have flu like symptoms?],
	   NULL AS [Date and Time of Screening],
       AA.[Take a picture of the visitor],
	   BB.ResponseDate,
	   BB.ResponseNo,
	   BB.[Did your guest show any symptoms],
	   BB.[What was concerning],
	   BB.[Was the guest showing any symptoms],
	   BB.[What symptoms were they showing]
	   FROM
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.PI,P.HostName,P.HostMobile,P.HostEmail,
[Name],[Surname],[Contact Number],[E-Mail],[Company/Organisation],[Have you traveled in the last 21 days?],[If Yes, where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore Throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],[Temperature Reading],[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?],
IIF([Take a picture of the visitor]='' OR P.[Take a picture of the visitor] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Take a picture of the visitor])) AS [Take a picture of the visitor]
From(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,U.Name as UserName,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4416
) as HostEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4415
) as HostMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4413
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4414
) as HostName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 667 and eg.id=7325
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (69763,69764,69765,69766,69767,69769,69770,69771,69773,69774,69775,69776,69777,69778,69780,69781,69782,69783,69784,69785,69786,69787,69788,69789,69790,69791,69800)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Name],[Surname],[Contact Number],[E-Mail],[Company/Organisation],[Have you traveled in the last 21 days?],[If Yes, where to?],[Have you been exposed to someone who has the COVID-19 virus?],[Cough],[Sore Throat],[Shortness of breath],[Redness of eyes],[Body aches],[Loss of taste or smell],[Nausea],[Vomiting],[Diarrhoea],[Fatigue],[Weakness],[Tiredness],[Fever],[Is your temperature below 37.5°C?],[Temperature Reading],[Have you attended a health care facility where patients with COVID-19 infections are being treated?],[Have you been hospitalised recently with severe pneumonia?],[Do you currently have flu like symptoms?],[Take a picture of the visitor]
))P
)AA

LEFT JOIN 

(select ResponseDate,ResponseNo,SeenClientAnswerMasterId,
[Did your guest show any symptoms],[What was concerning],[Was the guest showing any symptoms],[What symptoms were they showing]
from(
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseNo,AM.SeenClientAnswerMasterId,A.Detail as Answer,Q.QuestionTitle as Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=667 and EG.Id=7325
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (53035,53036,53037,53038)
left Outer join SeenclientAnswerMaster SAM on SAM.id=AM.SeenclientAnswermasterid
left outer join SeenclientAnswerChild SAC on SAC.Id=am.SeenClientAnswerChildId
)S
pivot(
Max(Answer)
For  Question In (
[Did your guest show any symptoms],[What was concerning],[Was the guest showing any symptoms],[What symptoms were they showing]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
)Z

