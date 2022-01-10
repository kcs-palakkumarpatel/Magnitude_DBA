CREATE VIEW PB_VW_Jupidex_FarmerVisit AS

SELECT m.EstablishmentName,
       m.CapturedDate,
       m.ReferenceNo,
       m.Status,
       m.UserName,
       m.Latitude,
       m.Longitude,
       m.CustomerName,
       m.CustomerMobile,
       m.CustomerEmail,
       m.CustomerCompany,
       m.FarmingType,
       m.[Existing machines],
       m.[Reason For Visit],
       m.[If other, please state],
       a.Data AS Products,
       m.[Specific model],
       m.[Outcome of visit],
       m.[Follow up date],
       m.[Rate the visit (1=Poor/5=Excellent)],
       m.[Attached any photos or documents],
       m.[Next Steps],
       m.ResponseDate,
       m.Refno,
       m.[Have we captured the product information correctly?],
       m.[Are you interested in Finance?],
       m.[Would you like us to call you?],
       m.[Comments or Questions?]
       FROM 
(SELECT y.EstablishmentName,
       y.CapturedDate,
       y.ReferenceNo,
       y.Status,
       y.UserName,
       y.Latitude,
       y.Longitude,
       y.CustomerName,
       y.CustomerMobile,
       y.CustomerEmail,
       y.CustomerCompany,
       y.FarmingType,
       y.[Existing machines],
       z.Data AS [Reason For Visit],
       y.[If other, please state],
       y.Products,
       y.[Specific model],
       y.[Outcome of visit],
       y.[Follow up date],
       y.[Rate the visit (1=Poor/5=Excellent)],
       y.[Attached any photos or documents],
       y.[Next Steps],
       y.ResponseDate,
       y.Refno,
       y.[Have we captured the product information correctly?],
       y.[Are you interested in Finance?],
       y.[Would you like us to call you?],
       y.[Comments or Questions?]
       FROM 
(SELECT W.EstablishmentName,
       W.CapturedDate,
       W.ReferenceNo,
       W.Status,
       W.UserName,
       W.Latitude,
       W.Longitude,
       W.CustomerName,
       W.CustomerMobile,
       W.CustomerEmail,
       W.CustomerCompany,
       x.Data AS FarmingType,
       W.[Existing machines],
       W.[Reason For Visit],
       W.[If other, please state],
       W.Products,
       W.[Specific model],
       W.[Outcome of visit],
       W.[Follow up date],
       W.[Rate the visit (1=Poor/5=Excellent)],
       W.[Attached any photos or documents],
       W.[Next Steps],
       W.ResponseDate,
       W.Refno,
       W.[Have we captured the product information correctly?],
       W.[Are you interested in Finance?],
       W.[Would you like us to call you?],
       W.[Comments or Questions?]
       FROM 
(SELECT 
	   AA.EstablishmentName,
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
       --AA.[Type of Farming],
	   IIF(AA.[Type of Farming] LIKE 'Other (Specify)%',AA.[Specify if needed],IIF(AA.[Type of Farming] LIKE '%Other (Specify)%',CONCAT(AA.[Type of Farming],',',AA.[Specify if needed]),AA.[Type of Farming])) AS FarmingType,
       --AA.[Specify if needed],
       AA.[Existing machines],
       AA.[Reason For Visit],
       AA.[If other, please state],
       AA.Products,
       AA.[Specific model],
       AA.[Outcome of visit],
       AA.[Follow up date],
       AA.[Rate the visit (1=Poor/5=Excellent)],
       IIF(AA.[Attached any photos or documents]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Attached any photos or documents])) AS [Attached any photos or documents],
       AA.[Next Steps],
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Have we captured the product information correctly?],
       BB.[Are you interested in Finance?],
       BB.[Would you like us to call you?],
       BB.[Comments or Questions?] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,CustomerName,CustomerMobile,CustomerEmail,CustomerCompany,
[Type of Farming],[Specify if needed],[Existing machines],[Reason For Visit],[If other, please state],[Products],[Specific model],[Outcome of visit],[Follow up date],[Rate the visit (1=Poor/5=Excellent)],[Attached any photos or documents],[Next Steps]
FROM
(SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
CONVERT(NVARCHAR(MAX),A.Detail) as Answer,
CASE WHEN Q.Id=52852 THEN 'Specify if needed' ELSE Q.Questiontitle END AS Question,U.id as UserId, u.name as UserName,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 373 and eg.id=3017 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (28975,26729,24291,37645,26218,22579,22558,22560,22561,24545,27141,22564,52852,52851)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s 
pivot(
Max(Answer)
For  Question In (
[Type of Farming],[Specify if needed],[Existing machines],[Reason For Visit],[If other, please state],[Products],[Specific model],[Outcome of visit],[Follow up date],[Rate the visit (1=Poor/5=Excellent)],[Attached any photos or documents],[Next Steps]
))p
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Have we captured the product information correctly?],[Are you interested in Finance?],[Would you like us to call you?],[Comments or Questions?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.ShortName as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 373 and eg.id=3017 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (14117,14118,14119,14120)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Have we captured the product information correctly?],[Are you interested in Finance?],[Would you like us to call you?],[Comments or Questions?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
)W CROSS APPLY (select Data from dbo.Split(W.FarmingType,',') ) x
)y CROSS APPLY (select Data from dbo.Split(y.[Reason For Visit],',') ) z 
)m CROSS APPLY (select Data from dbo.Split(m.Products,',') ) a

