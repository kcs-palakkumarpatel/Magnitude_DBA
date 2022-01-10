CREATE VIEW PB_VW_Matola_SlabInspection AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.CustomerCompany,
	   AA.Contractname,
       AA.Date,
       AA.Time,
       AA.Location,
       AA.[Stockpile reference number],
       AA.[Slab allocation],
       AA.[Product type],
       AA.[Total quantity (Tonnage)],
       AA.[Temperature (°C)],
       AA.[Weather conditions],
       AA.[If other, please state],
       AA.[Is cargo stockpile labeled?],
       AA.Comments,
       AA.[Stockpile photos and label],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Date & time],
       BB.[Is the cargo in a responsible order to customer?],
       BB.Comment,
       BB.[Photo of cargo],
       BB.[Is slot/slab kept in a neat order?],
       BB.Comment1,
       BB.[Photo of slot/slab],
       BB.[Have you taken a picture of the slab today?],
       BB.Comment2,
       BB.[Photo of slab],
       BB.[Is the cargo tonnage received in line with the customer arrival target?],
       BB.Comment3,
       BB.Attachments,
       IIF(BB.Signature='' OR BB.Signature IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Signature)) AS Signature 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,Contractname,
[Date],[Time],[Location],[Stockpile reference number],[Slab allocation],[Product type],[Total quantity (Tonnage)],[Temperature (°C)],[Weather conditions],[If other, please state],[Is cargo stockpile labeled?],[Comments],[Stockpile photos and label]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,cg.ContactGropName AS Contractname,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3141
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3140
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3142
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3138
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=3139
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 515 and eg.id=5551
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (45488,46907,45490,45491,45492,45493,45494,45495,45496,45497,45499,45500,45501)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id = AM.ContactGroupId
)s
pivot(
Max(Answer)
For  Question In (
[Date],[Time],[Location],[Stockpile reference number],[Slab allocation],[Product type],[Total quantity (Tonnage)],[Temperature (°C)],[Weather conditions],[If other, please state],[Is cargo stockpile labeled?],[Comments],[Stockpile photos and label]
))p
)AA

LEFT JOIN 

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Date & time],[Is the cargo in a responsible order to customer?],[Comment],[Photo of cargo],[Is slot/slab kept in a neat order?],[Comment1],[Photo of slot/slab],[Have you taken a picture of the slab today?],[Comment2],[Photo of slab],[Is the cargo tonnage received in line with the customer arrival target?],[Comment3],[Attachments],[Signature]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.Id=31801 THEN 'Comment'
	 WHEN q.Id=31804 THEN 'Comment1'
	 WHEN q.Id=31807 THEN 'Comment2'
	 WHEN q.Id=31810 THEN 'Comment3' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 515 and eg.id=5551 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (31799,31815,31800,31801,31802,31803,31804,31805,31806,31807,31808,31809,31810,31811,31812,31814)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Date & time],[Is the cargo in a responsible order to customer?],[Comment],[Photo of cargo],[Is slot/slab kept in a neat order?],[Comment1],[Photo of slot/slab],[Have you taken a picture of the slab today?],[Comment2],[Photo of slab],[Is the cargo tonnage received in line with the customer arrival target?],[Comment3],[Attachments],[Signature]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

