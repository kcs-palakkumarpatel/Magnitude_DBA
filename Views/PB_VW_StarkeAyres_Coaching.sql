CREATE VIEW PB_VW_StarkeAyres_Coaching AS

SELECT DISTINCT t.*, r.* 

FROM 
(SELECT  Region,EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status AS [Status1],ContactName,Email,MobileNumber,UserName,
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],[Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],[Graden Care Attachment],
[Chemical Score],[Comment on Chemical Score], [Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
IIF(xxxx.data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',xxxx.data)) AS [Cross Merchandising Attachment],[General Comments],
Latitude,
Longitude

FROM 
(SELECT Region, EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,ContactName,Email,MobileNumber,UserName,
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],[Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],[Graden Care Attachment],
[Chemical Score],[Comment on Chemical Score],
IIF(xxx.data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',xxx.data)) AS [Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
[Cross Merchandising Attachment],[General Comments],
Latitude,
Longitude

FROM 
(SELECT Region,EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,ContactName,Email,MobileNumber,UserName,
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],[Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],
IIF(xx.data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',xx.data)) AS [Graden Care Attachment],
[Chemical Score],[Comment on Chemical Score],[Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
[Cross Merchandising Attachment],[General Comments],
Latitude,
Longitude

FROM 
(SELECT Region,EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,ContactName,Email,MobileNumber,UserName,
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],
IIF(x.data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.data)) AS [Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],
[Graden Care Attachment],[Chemical Score],[Comment on Chemical Score],[Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
[Cross Merchandising Attachment],[General Comments],
Latitude,
Longitude

From
(SELECT iif(EstablishmentName like 'CENTRAL%', 'CENTRAL',IIF(EstablishmentName like 'NORTHERN%','NORTHERN',IIF(EstablishmentName like 'EASTERN%','EASTERN',IIF(EstablishmentName like 'SOUTHERN%','SOUTHERN','Other')))) AS Region,EstablishmentName, CapturedDate,ReferenceNo,IsPositive,Status,P.ContactName,P.Email,P.MobileNumber,P.UserName,
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],[Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],
[Graden Care Attachment],[Chemical Score],[Comment on Chemical Score],[Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
[Cross Merchandising Attachment],[General Comments],
Latitude,
Longitude

from(
SELECT REPLACE(REPLACE(E.EstablishmentName,'COACHING - ',''),'COACHING- ','') AS EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer , u.name as UserName,AM.Latitude,AM.Longitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2721

)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2722
) as ContactName,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2724
) as Email,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2723
) as MobileNumber,


CASE WHEN Q.Id = 75067  then 'Store Name'
     WHEN Q.Id = 75098    then 'Rep Present'
     WHEN Q.Id = 75099    then 'Seed Score'
     WHEN Q.Id = 75100    then 'Comment on Seed Score'
     WHEN Q.Id =75069    then 'Seed Score Attachment'
     WHEN Q.Id =75104    then 'Graden Care Score'
     WHEN Q.Id =75101    then 'Comment on Garden Care Score'
     WHEN Q.Id =75072    then 'Graden Care Attachment'
     WHEN Q.Id =75103    then 'Chemical Score'
     WHEN Q.Id =75102    then 'Comment on Chemical Score'
     WHEN Q.Id =75074    then 'Chemical Attachment'
     WHEN Q.Id =75105    then 'Cross Merchandising Score'
     WHEN Q.Id =75107    then 'Comment on Cross Merchandising'
     WHEN Q.Id =75106    then 'Cross Merchandising Attachment'
     WHEN Q.Id =75115    then 'General Comments'
     
END AS Question 

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id


Where (G.Id=438 and EG.Id =7861
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in(75067,75098,75099,75100,75069,75104,75101,75072,75103,75102,75074,75105,75107,75106,75115)

) S
Pivot (
Max(Answer)

For  Question In (
[Store Name],[Rep Present],[Seed Score],[Comment on Seed Score],[Seed Score Attachment],[Graden Care Score],[Comment on Garden Care Score],
[Graden Care Attachment],[Chemical Score],[Comment on Chemical Score],[Chemical Attachment],[Cross Merchandising Score],[Comment on Cross Merchandising],
[Cross Merchandising Attachment],[General Comments]
))P 
)W CROSS APPLY (select Data from dbo.Split(W.[Seed Score Attachment],','))x
)WW CROSS APPLY (select Data from dbo.Split(WW.[Graden Care Attachment],','))xx
)WWW CROSS APPLY (select Data from dbo.Split(WWW.[Chemical Attachment],','))xxx
)WWWW CROSS APPLY (select Data from dbo.Split(WWWW.[Cross Merchandising Attachment],','))xxxx
)t

LEFT JOIN(

SELECT P.ResponseDate,P.ResponseReferenceNo,ResponseBy, SeenClientAnswerMasterId,
[Status],[Actions to be taken],[Expected date of action],[Photo of action],[Date of action]

from(
select E.EstablishmentName,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,am.SeenClientAnswerMasterId,
AM.IsPositive,AM.IsResolved as [ form Status],
A.Detail as Answer
,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,AM.Latitude,AM.Longitude,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>''
and CD.contactQuestionId=2721
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>''
and CD.contactQuestionId=2722
) as ResponseBy

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT JOIN dbo.SeenClientAnswerMaster sam ON sam.Id = am.SeenClientAnswerMasterId 
LEFT JOIN dbo.SeenClientAnswerChild SAC ON  sac.Id=am.SeenClientAnswerChildId
Where (G.Id=438 and EG.Id =7861 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id IN(60523,59870,60536,59872,598716)

) S
Pivot (
Max(Answer)
For  Question In (
[Status],[Actions to be taken],[Expected date of action],[Photo of action],[Date of action]
))P
)r ON t.ReferenceNo = r.SeenClientAnswerMasterId 
WHERE t.UserName<>'MoxieStark Admin'
-- contact name = regional sales managers

