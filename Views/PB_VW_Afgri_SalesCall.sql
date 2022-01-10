CREATE VIEW PB_VW_Afgri_SalesCall AS

SELECT REPLACE(AA.EstablishmentName,'SALES CALL ','') AS Area,
       CAST(AA.CapturedDate AS DATE) AS CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.[Watter produkte was bespreek?],
       AA.[(1 = Swak ; 5 = Uitstekend)] AS [Wat is die waarskynlikheid van die sluiting van die transaksie?],
       AA.[As ander, besryf asseblief],
       AA.[Wat was die uiteinde van u besoek?],
       AA.[Enige mededingende kwotasies?],
       AA.[Oor mededingende kwotasies],
       AA.[Send customer a BELOW PRIME John Deere Financial Quote (No Obligations)],
       AA.[If yes, via:],
       AA.[If other financial solutions are required, please select below:],
       AA.Urgency,
       REPLACE(REPLACE(AA.[Total Quote Amount],' ',''),',','.') AS [Total Quote Amount],
       IIF(AA.[Picture of quote]='' OR AA.[Picture of quote] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Picture of quote])) AS [Picture of quote],
       AA.[Comments (No Confidential Information)],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.[Was die kwotasie duidelik en verstaanbaar?],
       BB.kommentaar,
       BB.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief],
       BB.[watter hulp het jy nodig],
       BB.[Is daar enige ander produk wat u inligting oor wil he?],
       BB.[Indien Ander, spesifiseer asseblief],
       BB.[Wil jy gekontak word deur enige van die volgende ?],
       BB.[Gradeer asseblief u verkoops persoon se produk kennis] FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,CustomerCompany,
[Watter produkte was bespreek?],[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Wat was die uiteinde van u besoek?],
IIF([Enige mededingende kwotasies?] LIKE '%,%',SUBSTRING(P.[Enige mededingende kwotasies?],1,CHARINDEX(',',P.[Enige mededingende kwotasies?])-1),P.[Enige mededingende kwotasies?]) AS [Enige mededingende kwotasies?],
IIF(P.[Enige mededingende kwotasies?] LIKE '%,%',SUBSTRING(P.[Enige mededingende kwotasies?],CHARINDEX(',',P.[Enige mededingende kwotasies?])+1,LEN(P.[Enige mededingende kwotasies?])),'') AS [Oor mededingende kwotasies],
[Send customer a BELOW PRIME John Deere Financial Quote (No Obligations)],[If yes, via:],[If other financial solutions are required, please select below:],[Urgency],[Total Quote Amount],[Picture of quote],[Comments (No Confidential Information)]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,
CASE WHEN q.id=14770 THEN 'If other financial solutions are required, please select below:' ELSE Q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=269
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=268
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=267
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=265
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=266
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=963
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (19972,5496,5495,5497,5493,6015,6016,17459,17591,17460,14770,14771,14773,14772,6017,5498)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Watter produkte was bespreek?],[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Wat was die uiteinde van u besoek?],[Enige mededingende kwotasies?],[Send customer a BELOW PRIME John Deere Financial Quote (No Obligations)],[If yes, via:],[If other financial solutions are required, please select below:],[Urgency],[Total Quote Amount],[Picture of quote],[Comments (No Confidential Information)]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,
IIF([Was die kwotasie duidelik en verstaanbaar?] LIKE '%,%',SUBSTRING(P.[Was die kwotasie duidelik en verstaanbaar?],1,CHARINDEX(',',P.[Was die kwotasie duidelik en verstaanbaar?])-1),P.[Was die kwotasie duidelik en verstaanbaar?]) AS [Was die kwotasie duidelik en verstaanbaar?],
IIF(P.[Was die kwotasie duidelik en verstaanbaar?] LIKE '%,%',SUBSTRING(P.[Was die kwotasie duidelik en verstaanbaar?],CHARINDEX(',',P.[Was die kwotasie duidelik en verstaanbaar?])+1,LEN(P.[Was die kwotasie duidelik en verstaanbaar?])),'') AS kommentaar,
IIF([Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief] LIKE '%,%',SUBSTRING(P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief],1,CHARINDEX(',',P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief])-1),P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief]) AS [Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief],
IIF(P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief] LIKE '%,%',SUBSTRING(P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief],CHARINDEX(',',P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief])+1,LEN(P.[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief])),'') AS [watter hulp het jy nodig],
REPLACE(REPLACE([Is daar enige ander produk wat u inligting oor wil he?],'-- Select --',''),'- Select -','') AS [Is daar enige ander produk wat u inligting oor wil he?],
[Indien Ander, spesifiseer asseblief],[Wil jy gekontak word deur enige van die volgende ?],[Gradeer asseblief u verkoops persoon se produk kennis]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.id=4935 THEN 'Is daar enige ander produk wat u inligting oor wil he?' 
WHEN q.id=4934 THEN 'Gradeer asseblief u verkoops persoon se produk kennis' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=963
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (4931,4932,5354,5355,5356,4935,4933,4934)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Was die kwotasie duidelik en verstaanbaar?],[Het u enige verdere hulp nodig? Indien ja, verduidelik asseblief],[Is daar enige ander produk wat u inligting oor wil he?],[Indien Ander, spesifiseer asseblief],[Wil jy gekontak word deur enige van die volgende ?],[Gradeer asseblief u verkoops persoon se produk kennis]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

