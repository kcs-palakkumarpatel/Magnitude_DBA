CREATE VIEW PB_VW_Afgri_FirstContact AS

SELECT REPLACE(AA.EstablishmentName,'FIRST CONTACT ','') AS Area,
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
       IIF(AA.Products='' OR AA.Products IS NULL,'N/A',REPLACE(AA.Products,'[]','N/A')) AS Products,
       AA.[If other, please specify],
       AA.Comments,
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.Belangstelling,
       BB.[Stel u belang in die volgende?],
       BB.[Indien Ander, spesifiseer asseblief],
       BB.[Wil jy inteken op ons nuusbrief?],
       BB.[(1 = Swak ; 5 = Uitstekend)] AS [Gradeer u ondervinding van my besoek],
       BB.[Versoek u enige verdere hulp of inligting?],
       BB.inligting FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,CustomerCompany,
[Products],[If other, please specify],[Comments]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,U.Name as UserName,AM.Latitude,AM.Longitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=961
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (49384,6014,5486,6013)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Products],[If other, please specify],[Comments]
))P
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Belangstelling],[Stel u belang in die volgende?],[Indien Ander, spesifiseer asseblief],[Wil jy inteken op ons nuusbrief?],[(1 = Swak ; 5 = Uitstekend)],
IIF(P.[Versoek u enige verdere hulp of inligting?] LIKE '%,%',SUBSTRING([Versoek u enige verdere hulp of inligting?],1,CHARINDEX(',',P.[Versoek u enige verdere hulp of inligting?])-1),P.[Versoek u enige verdere hulp of inligting?]) AS [Versoek u enige verdere hulp of inligting?],
IIF(P.[Versoek u enige verdere hulp of inligting?] LIKE '%,%',SUBSTRING(P.[Versoek u enige verdere hulp of inligting?],CHARINDEX(',',P.[Versoek u enige verdere hulp of inligting?])+1,LEN(P.[Versoek u enige verdere hulp of inligting?])),'') AS inligting
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=961
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (5310,5311,5313,5312,4925,4926,4927)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Belangstelling],[Stel u belang in die volgende?],[Indien Ander, spesifiseer asseblief],[Wil jy inteken op ons nuusbrief?],[(1 = Swak ; 5 = Uitstekend)],[Versoek u enige verdere hulp of inligting?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

