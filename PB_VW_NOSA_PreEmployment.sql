CREATE VIEW PB_VW_NOSA_PreEmployment AS

SELECT 'HDV' AS Activity,
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
	   AA.PI,
	   AA.CustomerName,
	   IIF(AA.Client IS NULL,AA.EstablishmentName,IIF(AA.Client='',AA.EstablishmentName,AA.Client)) AS Client,
       AA.[Date of assessment],
       AA.[Drivers name and surname],
       AA.[Drivers Identity Number],
       IIF(REPLACE(AA.[Type of Driver],'-- Select --','') IS NULL OR REPLACE(AA.[Type of Driver],'-- Select --','')='','Other',REPLACE(AA.[Type of Driver],'-- Select --','')) AS [Type of Driver],
       AA.[PrDP Expiry Date],
       AA.[License Expiry Date],
       AA.[Alternate ID number/Passport number],
       AA.[Written test score (%)],
       AA.[Medical Completed],
       AA.[Any medical conditions noted],
       AA.Make,
       AA.[Model/Trailer],
       AA.[Engine Type],
       IIF(AA.[Gearbox Type] IS NULL OR AA.[Gearbox Type]='','Other',AA.[Gearbox Type]) AS [Gearbox Type],
       IIF(AA.Configuration IS NULL OR	AA.Configuration='','Other',AA.Configuration) AS Configuration,
       AA.[Registration number],
       AA.[Trailer Number],
       AA.[Town/City/Suburb],
       AA.[1. Manipulation of controls],
       AA.[2. Use of gears],
       AA.[3. Use of clutch],
       AA.[4. Use of brakes/Stopping],
       AA.[5. Pedal Balance],
       AA.[6. Steering],
       AA.[7. Acceleration Management],
       AA.[8. Use of retardation devices],
       AA.[9. Coasting],
       AA.[10. Vehicle Sympathy],
       AA.[11. Maneuvering],
       AA.[1. Moving off],
       AA.[2. Intersections and cornering],
       AA.[3. Road observations],
       AA.[4. Positioning and distance],
       AA.[5. Assessment of hazards],
       AA.[6. Lane changing],
       AA.[7. Overtaking],
       AA.[Overall result],
       AA.[End],
       AA.Start,
       AA.Total,
       AA.[Time started],
       AA.[Time ended],
       REPLACE(AA.[Driver Trainer comments],'-','') AS [Driver Trainer comments],
       AA.[Driver Trainer Recommendations],
       CONVERT(DATE,BB.ResponseDate) AS ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Type of training],
       BB.Comments,
       IIF(BB.ReferenceNo<>NULL,IIF(BB.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments)),NULL) AS Attachments
	    FROM (
SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,p.PI,p.CustomerName,
[Client],[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[Type of Driver],[PrDP Expiry Date],[License Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model/Trailer],[Engine Type],[Gearbox Type],[Configuration],[Registration number],[Trailer Number],[Town/City/Suburb],[1. Manipulation of controls],[2. Use of gears],[3. Use of clutch],[4. Use of brakes/Stopping],[5. Pedal Balance],[6. Steering],[7. Acceleration Management],[8. Use of retardation devices],[9. Coasting],[10. Vehicle Sympathy],[11. Maneuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing],[7. Overtaking],[Overall result],[End],[Start],[Total],[Time started],[Time ended],[Driver Trainer comments],[Driver Trainer Recommendations]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2011
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (26968,12382,12383,29109,16603,16604,29583,32009,32011,32012,12386,12387,12388,28797,28798,12393,12394,12506,18298,18299,18300,18301,18302,18303,18304,18305,18306,18307,18308,18310,18311,18312,18313,18314,18315,18316,18317,12508,12509,12510,12511,12512,12516,28376,49791)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Client],[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[Type of Driver],[PrDP Expiry Date],[License Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model/Trailer],[Engine Type],[Gearbox Type],[Configuration],[Registration number],[Trailer Number],[Town/City/Suburb],[1. Manipulation of controls],[2. Use of gears],[3. Use of clutch],[4. Use of brakes/Stopping],[5. Pedal Balance],[6. Steering],[7. Acceleration Management],[8. Use of retardation devices],[9. Coasting],[10. Vehicle Sympathy],[11. Maneuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing],[7. Overtaking],[Overall result],[End],[Start],[Total],[Time started],[Time ended],[Driver Trainer comments],[Driver Trainer Recommendations]
))p
)AA

LEFT JOIN

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Type of training],[Comments],[Attachments]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 296 and eg.id=2011 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (35062,34854,34855)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Type of training],[Comments],[Attachments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 'LMV' AS Activity,
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
	   AA.PI,
	   AA.CustomerName,
	   IIF(AA.Client IS NULL,AA.EstablishmentName,IIF(AA.Client='',AA.EstablishmentName,AA.Client)) AS Client,
       AA.[Date of assessment],
       AA.[Drivers name and surname],
       AA.[Drivers Identity Number],
       IIF(REPLACE(AA.[Type of Driver],'-- Select --','') IS NULL OR REPLACE(AA.[Type of Driver],'-- Select --','')='','Other',REPLACE(AA.[Type of Driver],'-- Select --','')) AS [Type of Driver],
       AA.[PrDP Expiry Date],
       AA.[License Expiry Date],
       AA.[Alternate ID number/Passport number],
       AA.[Written test score (%)],
       AA.[Medical Completed],
       AA.[Any medical conditions noted],
       AA.Make,
       AA.Model,
	   'Other' AS [Engine Type],
       IIF(AA.Gearbox IS NULL OR AA.Gearbox='','Other',AA.Gearbox) AS [Gearbox Type],
	   'Other' AS Configuration,
       AA.[Registration Number],
	   'Other' AS [Trailer Number],
       AA.[Town/City/Suburb],
       AA.[1. Manipulation of controls],
       AA.[2. Use of gears],
       AA.[3. Use of clutch],
       AA.[4. Use of brakes / stopping],
       AA.[5. Pedal balance],
       AA.[6. Steering],
       AA.[7. Acceleration management],
	   'N/A' AS [Use of retardation devices],
       AA.[8. Coasting],
       AA.[9. Vehicle Sympathy],
       AA.[10. Maneuvering],
       AA.[1. Moving off],
       AA.[2. Intersections and cornering],
       AA.[3. Road observations],
       AA.[4. Positioning and distance],
       AA.[5. Assessment of hazards],
       AA.[6. Lane changing],
       AA.[7. Overtaking],
       AA.[OVERALL RESULT],
       AA.[End],
       AA.Start,
       AA.Total,
       AA.[Time started],
       AA.[Time ended],
       AA.[Driver Trainer comments],
       AA.[Driver Trainer Recommendations],
       CONVERT(DATE,BB.ResponseDate) AS ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Type of training],
       BB.Comments,
       IIF(BB.ReferenceNo<>NULL,IIF(BB.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.Attachments)),NULL) AS Attachments
	    FROM (
SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,p.PI,p.CustomerName,
[Client],[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[Type of Driver],[PrDP Expiry Date],[License Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model],[Gearbox],[Registration Number],[Town/City/Suburb],[1. Manipulation of controls],[2. Use of gears],[3. Use of clutch],[4. Use of brakes / stopping],[5. Pedal balance],[6. Steering],[7. Acceleration management],[8. Coasting],[9. Vehicle Sympathy],[10. Maneuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing],[7. Overtaking],[OVERALL RESULT],[End],[Start],[Total],[Time started],[Time ended],[Driver Trainer comments],[Driver Trainer Recommendations]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2653
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (26965,18358,18359,29108,18360,18361,29586,32005,32007,32008,18366,18367,18368,18369,18511,18489,18490,18491,18492,18493,18494,18495,18496,18497,18498,18500,18501,18502,18503,18504,18505,18506,18507,18475,18476,18477,18478,18479,18480,28377,49790)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Client],[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[Type of Driver],[PrDP Expiry Date],[License Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model],[Gearbox],[Registration Number],[Town/City/Suburb],[1. Manipulation of controls],[2. Use of gears],[3. Use of clutch],[4. Use of brakes / stopping],[5. Pedal balance],[6. Steering],[7. Acceleration management],[8. Coasting],[9. Vehicle Sympathy],[10. Maneuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing],[7. Overtaking],[OVERALL RESULT],[End],[Start],[Total],[Time started],[Time ended],[Driver Trainer comments],[Driver Trainer Recommendations]
))p
)AA

LEFT JOIN

(
select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Type of training],[Comments],[Attachments]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 296 and eg.id=2653 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (35059,34857,34858)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Type of training],[Comments],[Attachments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

