CREATE VIEW PB_VW_Jupidex_StockTake AS 

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       AA.CustomerCompany,
       AA.Dealer,
       AA.Area,
       AA.[Machine description],
       AA.[Machine List],
       AA.[Serial Number],
       AA.Fields,
       AA.[Left Front],
       AA.[Right Front],
       AA.[Back Left],
       AA.[Back Right],
       AA.[Serial Plate],
       AA.[Other/ Accessory],
       AA.[Condition & Storage],
       AA.[Condition Rating ( 1 = Poor / 5 = Excellent],
       AA.Extras,
       AA.[Dealer Signature],
       AA.Name,
       AA.Date,
       AA.[Jupidex (Sign) Representative],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Do you agree with the above information?],
       BB.Comments,
       BB.Attachments,
       BB.Sign 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,
[Dealer],[Area],[Machine description],[Machine List],[Serial Number],[Fields],
IIF([Left Front]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Left Front])) AS [Left Front],
IIF(p.[Right Front]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Right Front])) AS [Right Front],
IIF(p.[Back Left]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Back Left])) AS [Back Left],
IIF(p.[Back Right]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Back Right])) AS [Back Right],
IIF(p.[Serial Plate]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Serial Plate])) AS [Serial Plate],
IIF(p.[Other/ Accessory]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Other/ Accessory])) AS [Other/ Accessory],
[Condition & Storage],[Condition Rating ( 1 = Poor / 5 = Excellent],[Extras],
IIF(p.[Dealer Signature]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Dealer Signature])) AS [Dealer Signature],
[Name],[Date],
IIF(p.[Jupidex (Sign) Representative]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',p.[Jupidex (Sign) Representative])) AS [Jupidex (Sign) Representative]
FROM
(SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
CONVERT(NVARCHAR(MAX),A.Detail) as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2359
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2358
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2360
) AS CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2356
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=2961 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (21705,21706,21670,21716,21671,22526,22527,22528,22529,22530,22531,21717,21707,25083,21714,21709,21710,21711,21712)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s 
pivot(
Max(Answer)
For  Question In (
[Dealer],[Area],[Machine description],[Machine List],[Serial Number],[Fields],[Left Front],[Right Front],[Back Left],[Back Right],[Serial Plate],[Other/ Accessory],[Condition & Storage],[Condition Rating ( 1 = Poor / 5 = Excellent],[Extras],[Dealer Signature],[Name],[Date],[Jupidex (Sign) Representative]
))p
)AA

LEFT JOIN 


(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Do you agree with the above information?],[Comments],
IIF(P.Attachments IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[Attachments])) AS [Attachments],
IIF(P.[Sign] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[Sign])) AS [Sign]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 373 and eg.id=2961 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (13715,13716,13717,13718)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Do you agree with the above information?],[Comments],[Attachments],[Sign]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

