CREATE VIEW dbo.PB_VW_Matola_Truck AS

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
       IIF(AA.[Picture of truck]='' OR AA.[Picture of truck] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Picture of truck])) AS [Picture of truck],
       AA.[Truck registation],
       AA.Transporter,
       AA.[Driver name],
       AA.[Driver ID],
       AA.[Trailer Reg.1],
       AA.[Trailer Reg.2],
       AA.[Consignment note],
       AA.Tonnage,
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       REPLACE(BB.[Please select the weigh bridge the truck has arrived at ...],'MPDC/MICD Weigh Bridge','MPDC / MICD Weigh Bridge') AS [Please select the weigh bridge the truck has arrived at ...],
       BB.[Ticket number],
	   BB.[Net weight],
       BB.[Gross weight],
       BB.[Tare Weight],
       BB.Date,
       BB.Time,
       BB.[Load reference number],
       IIF(BB.Attachments='' OR BB.Attachments IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments)) AS Attachments,
       BB.[Date & time],
       BB.[Seal number (Number and letter) x6],
       BB.Comments,
       IIF(BB.[Truck seal Photo]='' OR BB.[Truck seal Photo] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Truck seal Photo])) AS [Truck seal Photo]
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,Contractname,
IIF([Picture of truck] LIKE '%,%',LEFT([Picture of truck],CHARINDEX(',',[Picture of truck])-1),[Picture of truck]) AS [Picture of truck],
[Truck registation],[Transporter],[Driver name],[Driver ID],[Trailer Reg.1],[Trailer Reg.2],[Consignment note],[Tonnage]
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 515 and eg.id=5549
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (45471,45472,45473,45474,45475,45476,45477,45478,45479)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id = AM.ContactGroupId
)s
pivot(
Max(Answer)
For  Question In (
[Picture of truck],[Truck registation],[Transporter],[Driver name],[Driver ID],[Trailer Reg.1],[Trailer Reg.2],[Consignment note],[Tonnage]
))p
)AA

LEFT JOIN 

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Please select the weigh bridge the truck has arrived at ...],[Ticket number],[Net weight],[Gross weight],[Tare Weight],[Date],[Time],[Load reference number],
IIF([Attachments] LIKE '%,%',LEFT([Attachments],CHARINDEX(',',[Attachments])-1),[Attachments]) AS [Attachments],
[Date & time],[Seal number (Number and letter) x6],[Comments],
IIF([Truck seal Photo] LIKE '%,%',LEFT([Truck seal Photo],CHARINDEX(',',[Truck seal Photo])-1),[Truck seal Photo]) AS [Truck seal Photo]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 515 and eg.id=5549 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (32090,32083,30542,30543,30544,56324,30545,30546,30547,30548,30549,32084,32085,32086,32087)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Please select the weigh bridge the truck has arrived at ...],[Ticket number],[Net weight],[Gross weight],[Tare Weight],[Date],[Time],[Load reference number],[Attachments],[Date & time],[Seal number (Number and letter) x6],[Comments],[Truck seal Photo]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

