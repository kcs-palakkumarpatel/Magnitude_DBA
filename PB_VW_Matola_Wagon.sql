CREATE VIEW PB_VW_Matola_Wagon AS

SELECT --AA.EstablishmentName,
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
       IIF(AA.[Picture of the wagon]='' OR AA.[Picture of the wagon] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Picture of the wagon])) AS [Picture of the wagon],
       AA.[Wagon registration],
       AA.[Wagon Reg 1],
       AA.[Tonnage],
       AA.[Consignment note],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       REPLACE(BB.[Please select the weigh bridge the Wagon has arrived at …],'MPDC/MICD Weigh Bridge','MPDC / MICD Weigh Bridge') AS [Please select the weigh bridge the Wagon has arrived at …],
       BB.[Ticket number],
	   BB.[Net weight],
       BB.[Gross weight],
       BB.[Tare weight],
       BB.Date,
       BB.Time,
       BB.[Load reference number],
       IIF(BB.Attachments='' OR BB.Attachments IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments)) AS Attachments,
       BB.[Date & time],
       BB.[Seal number],
       BB.Comments,
       IIF(BB.[Wagon seal Photo]='' OR BB.[Wagon seal Photo] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Wagon seal Photo])) AS [Wagon seal Photo]
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,Contractname,
IIF([Picture of the wagon] LIKE '%,%',LEFT([Picture of the wagon],CHARINDEX(',',[Picture of the wagon])-1),[Picture of the wagon]) AS [Picture of the wagon],
[Wagon registration],[Wagon Reg 1],[Tonnage],[Consignment note]
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 515 and eg.id=6175
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (51736,51737,51740,51813,51742)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id = AM.ContactGroupId
)s
pivot(
Max(Answer)
For  Question In (
[Picture of the wagon],[Wagon registration],[Wagon Reg 1],[Tonnage],[Consignment note]
))p
)AA

LEFT JOIN 

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Please select the weigh bridge the Wagon has arrived at …],[Ticket number],[Net weight],[Gross weight],[Tare weight],[Date],[Time],[Load reference number],
IIF([Attachments] LIKE '%,%',LEFT([Attachments],CHARINDEX(',',[Attachments])-1),[Attachments]) AS [Attachments],
[Date & time],[Seal number],[Comments],
IIF([Wagon seal Photo] LIKE '%,%',LEFT([Wagon seal Photo],CHARINDEX(',',[Wagon seal Photo])-1),[Wagon seal Photo]) AS [Wagon seal Photo]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 515 and eg.id=6175 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (36647,36648,36649,36650,36651,36652,36653,36654,36655,36667,36668,36669,36670,36671,36672,36673,36674,36675,36676,36677,36678,36679,36680,36681,36682,36683,59697)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Please select the weigh bridge the Wagon has arrived at …],[Ticket number],[Net weight],[Gross weight],[Tare weight],[Date],[Time],[Load reference number],[Attachments],[Date & time],[Seal number],[Comments],[Wagon seal Photo]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

