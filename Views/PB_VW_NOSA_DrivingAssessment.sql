CREATE VIEW dbo.PB_VW_NOSA_DrivingAssessment AS 

SELECT z.Activity,
       z.EstablishmentName,
       z.CapturedDate,
       z.ReferenceNo,
       z.Status,
       z.UserName,
       z.Latitude,
       z.Longitude,
	   z.PI,
	   z.CustomerName,
	   REPLACE(IIF(z.Client IS NULL,z.EstablishmentName,IIF(z.Client='',z.EstablishmentName,z.Client)),'Defensive Driving Assessment','') AS Client,
       z.[Date of assessment],
       z.[Drivers Name and Surname],
       z.[Drivers Identity Number],
       IIF(z.[Type of Driver] IS NULL OR z.[Type of Driver]='','Other',z.[Type of Driver]) AS [Type of Driver],
       z.[License Expiry Date],
       z.[PrDP Expiry Date],
       z.[Alternate ID number/Passport number],
       z.[Written test score (%)],
       z.[Medical Completed],
       z.[Any medical conditions noted],
       z.Make,
       z.[Model/Trailer],
       IIF(z.[Engine Type] IS NULL OR z.[Engine Type]='','Other',z.[Engine Type]) AS [Engine Type],
       IIF(z.[Gearbox Type] IS NULL OR z.[Gearbox Type]='','Other',z.[Gearbox Type]) AS [Gearbox Type],
       IIF(z.Configuration IS NULL OR	z.Configuration='','Other',z.Configuration) AS Configuration,
       z.[Registration number],
       z.[Trailer Number],
       z.[Town/City/Suburb],
       z.[1. Use of gears],
	   CASE WHEN RTRIM(LTRIM([1. Use of gears])) ='' THEN NULL else CAST(z.[1. Use of gears] AS DECIMAL)/20 END AS [Gear %],
       z.[2. Use of clutch],
	   CASE WHEN RTRIM(LTRIM([z].[2. Use of clutch])) ='' THEN NULL ELSE CAST(z.[2. Use of clutch] AS DECIMAL)/14 END AS [Clutch %],
       z.[3. Use of brakes / stopping],
	   CASE WHEN RTRIM(LTRIM([z].[3. Use of brakes / stopping])) ='' THEN NULL ELSE CAST(z.[3. Use of brakes / stopping] AS DECIMAL)/28 END AS [Brakes %],
       z.[4. Steering],
	   CASE WHEN RTRIM(LTRIM([z].[4. Steering])) ='' THEN NULL ELSE CAST(z.[4. Steering] AS DECIMAL)/5 END AS [Steering %],
       z.[5. Acceleration management],
	   CASE WHEN RTRIM(LTRIM([z].[5. Acceleration management])) ='' THEN NULL ELSE CAST(z.[5. Acceleration management] AS DECIMAL)/11 END AS [Acceleration %],
       z.[6. Use of retardation devices],
	   CASE WHEN RTRIM(LTRIM([z].[6. Use of retardation devices])) ='' THEN NULL ELSE CAST(z.[6. Use of retardation devices] AS DECIMAL)/5 END AS [Retardation %],
       z.[7. Vehicle Sympathy],
	   CASE WHEN RTRIM(LTRIM([z].[7. Vehicle Sympathy])) ='' THEN NULL ELSE CAST(z.[7. Vehicle Sympathy] AS DECIMAL)/6 END AS [Vehicle %],
       z.[8. Manoeuvering],
	   CASE WHEN RTRIM(LTRIM([z].[8. Manoeuvering])) ='' THEN NULL ELSE CAST(z.[8. Manoeuvering] AS DECIMAL)/9 END AS [Manoeuvering %],
       z.Parking,
	   0.00 AS [Parking %],
       z.[1. Moving off],
	   CASE WHEN RTRIM(LTRIM([z].[1. Moving off])) ='' THEN NULL ELSE CAST(z.[1. Moving off] AS DECIMAL)/8 END AS [Moving %],
       z.[2. Intersections and cornering],
	   CASE WHEN RTRIM(LTRIM([z].[2. Intersections and cornering])) ='' THEN NULL ELSE CAST(z.[2. Intersections and cornering] AS DECIMAL)/34 END AS [Intersections %],
       z.[3. Road observations],
	   CASE WHEN RTRIM(LTRIM(REPLACE([z].[3. Road observations],',','.'))) ='' THEN NULL ELSE CAST(REPLACE([z].[3. Road observations],',','.') AS DECIMAL)/16 END AS [Road %],
       z.[4. Positioning and distance],
	   CASE WHEN RTRIM(LTRIM([z].[4. Positioning and distance])) ='' THEN NULL ELSE CAST(z.[4. Positioning and distance] AS DECIMAL)/8 END AS [Positioning %],
       z.[5. Assessment of hazards],
	   CASE WHEN RTRIM(LTRIM([z].[5. Assessment of hazards])) ='' THEN NULL ELSE CAST(z.[5. Assessment of hazards] AS DECIMAL)/10 END AS [Hazards %],
       z.[6. Lane changing and Overtaking],
	   CASE WHEN RTRIM(LTRIM(REPLACE([z].[6. Lane changing and Overtaking],',','.'))) ='' THEN NULL ELSE CAST(REPLACE([z].[6. Lane changing and Overtaking],',','.') AS DECIMAL)/20 END AS [Lane %],
       z.[Driver Trainer comments],
       z.[Driver Trainer Recommendations],
       z.ResponseDate,
       z.Refno,
       z.[Type of training],
       z.Comments,
       IIF(z.Refno<>NULL,IIF(z.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',z.Attachments)),NULL) AS Attachments
	  
	   FROM 
(SELECT 'HDV' AS Activity,
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
	   AA.Latitude,
	   AA.Longitude,
	   AA.PI,
	   AA.CustomerName,
	   AA.Client,
       AA.[Date of assessment],
       AA.[Drivers Name and Surname],
       AA.[Drivers Identity Number],
       REPLACE(AA.[Type of Driver],'-- Select --','') AS [Type of Driver],
       AA.[License Expiry Date],
       AA.[PrDP Expiry Date],
       AA.[Alternate ID number/Passport number],
       AA.[Written test score (%)],
       AA.[Medical Completed],
       AA.[Any medical conditions noted],
       AA.Make,
       AA.[Model/Trailer],
       AA.[Engine Type],
       AA.[Gearbox Type],
       AA.Configuration,
       AA.[Registration number],
       AA.[Trailer Number],
       AA.[Town/City/Suburb],
       REPLACE(AA.[1. Use of gears],'-- Select --','') AS [1. Use of gears],
       REPLACE(AA.[2. Use of clutch],'-- Select --','') AS [2. Use of clutch],
       REPLACE(AA.[3. Use of brakes / stopping],'-- Select --','') AS [3. Use of brakes / stopping],
       REPLACE(AA.[4. Steering],'-- Select --','') AS [4. Steering],
       REPLACE(AA.[5. Acceleration management],'-- Select --','') AS [5. Acceleration management],
       REPLACE(AA.[6. Use of retardation devices],'-- Select --','') AS [6. Use of retardation devices],
       REPLACE(AA.[7. Vehicle Sympathy],'-- Select --','') AS [7. Vehicle Sympathy],
       REPLACE(AA.[8. Manoeuvering],'-- Select --','') AS [8. Manoeuvering],
	   '-1' AS [Parking],
       REPLACE(AA.[1. Moving off],'-- Select --','') AS [1. Moving off],
       REPLACE(AA.[2. Intersections and cornering],'-- Select --','') AS [2. Intersections and cornering],
       REPLACE(AA.[3. Road observations],'-- Select --','') AS [3. Road observations],
       REPLACE(AA.[4. Positioning and distance],'-- Select --','') AS [4. Positioning and distance],
       REPLACE(AA.[5. Assessment of hazards],'-- Select --','') AS [5. Assessment of hazards],
       REPLACE(AA.[6. Lane changing and Overtaking],'-- Select --','') AS [6. Lane changing and Overtaking],
       REPLACE(AA.[Driver Trainer comments],'-','') AS [Driver Trainer comments],
       AA.[Driver Trainer Recommendations],
	   CONVERT(DATE,BB.ResponseDate) AS ResponseDate,
	   BB.ReferenceNo AS Refno,
	   BB.[Type of training],
	   BB.[Comments],
	   BB.[Attachments]
	    FROM (
SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,p.PI,p.CustomerName,
[Client],[Date of assessment],[Drivers Name and Surname],[Drivers Identity Number],[Type of Driver],[License Expiry Date],[PrDP Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model/Trailer],[Engine Type],[Gearbox Type],[Configuration],[Registration number],[Trailer Number],[Town/City/Suburb],[1. Use of gears],[2. Use of clutch],[3. Use of brakes / stopping],[4. Steering],[5. Acceleration management],[6. Use of retardation devices],[7. Vehicle Sympathy],[8. Manoeuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing and Overtaking],[Driver Trainer comments],[Driver Trainer Recommendations]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,CAST(A.Detail AS VARCHAR(8000)) as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2527
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (26969,17462,17592,29111,50672,17599,17598,29584,32013,32015,32016,28827,28828,28829,28830,28831,28832,28833,28834,17362,17363,17364,17365,17366,17367,17368,17369,17371,17372,17405,17406,17407,17408,17595,28374,49788)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy	
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Client],[Date of assessment],[Drivers Name and Surname],[Drivers Identity Number],[Type of Driver],[License Expiry Date],[PrDP Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model/Trailer],[Engine Type],[Gearbox Type],[Configuration],[Registration number],[Trailer Number],[Town/City/Suburb],[1. Use of gears],[2. Use of clutch],[3. Use of brakes / stopping],[4. Steering],[5. Acceleration management],[6. Use of retardation devices],[7. Vehicle Sympathy],[8. Manoeuvering],[1. Moving off],[2. Intersections and cornering],[3. Road observations],[4. Positioning and distance],[5. Assessment of hazards],[6. Lane changing and Overtaking],[Driver Trainer comments],[Driver Trainer Recommendations]
))p

UNION ALL

/*OLD HDV-Defensive Driving Data*/
SELECT d.EstablishmentName,
       d.[Capture Date],
       d.ReferenceNo,
       d.IsResolved AS Status,
       d.UserName,
	   d.Latitude,
	   d.Longitude,
       d.PI,
	   d.CustomerName,
	   REPLACE(d.EstablishmentName,' DDA','') AS Client,
       d.[Capture Date] AS [Date of assessment],
       d.[Drivers name and surname],
       d.[Drivers Identity Number],
	   'Other' AS [Type of Driver],
       d.[License Expiry Date],
	   d.[PDP Expiry Date] AS [PrDP Expiry Date],
	   'N/A' AS [Alternate ID number/Passport number],
	   '' AS [Written test score (%)],
	   '' AS [Medical Completed],
	   '' AS [Any medical conditions noted],
       d.Make,
       d.[Model/Trailer],
       d.[Engine Type],
       d.[Gearbox make] AS [Gearbox Type],
       d.Configuration,
       d.[Registration Number (ST Number)] AS [Registration number],
       d.[Trailer Number (TT Number)] AS [Trailer Number],
       d.[Town/City/Suburb],
	   CAST(d.PI*20/100 AS NVARCHAR(20)) AS [1. Use of gears],
	   CAST(d.PI*14/100 AS NVARCHAR(20)) AS [2. Use of clutch],
	   CAST(d.PI*28/100 AS NVARCHAR(20)) AS [3. Use of brakes / stopping],
	   CAST(d.PI*5/100 AS NVARCHAR(20)) AS [4. Steering],
	   CAST(d.PI*11/100 AS NVARCHAR(20)) AS [5. Acceleration management],
	   CAST(d.PI*5/100 AS NVARCHAR(20)) AS [6. Use of retardation devices],
	   CAST(d.PI*6/100 AS NVARCHAR(20)) AS [7. Vehicle Sympathy],
	   CAST(d.PI*9/100 AS NVARCHAR(20)) AS [8. Manoeuvering],
	   CAST(d.PI*8/100 AS NVARCHAR(20)) AS [1. Moving off],
	   CAST(d.PI*34/100 AS NVARCHAR(20)) AS [2. Intersections and cornering],
	   CAST(d.PI*16/100 AS NVARCHAR(20)) AS [3. Road observations],
	   CAST(d.PI*8/100 AS NVARCHAR(20)) AS [4. Positioning and distance],
	   CAST(d.PI*10/100 AS NVARCHAR(20)) AS [5. Assessment of hazards],
	   CAST(d.PI*20/100 AS NVARCHAR(20)) AS [6. Lane changing and Overtaking],
	   'N/A' AS [Driver Trainer comments],
       d.[Trainers Recommendations for further training] AS [Driver Trainer Recommendations]
	   FROM 
(SELECT EstablishmentName,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,UserName,p.Latitude,p.Longitude,p.PI,p.CustomerName,
[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[PDP Expiry Date],[License Expiry Date],[Make],[Model/Trailer],[Engine Type],[Gearbox make],[Gearbox speed],[Mesh Type],[Configuration],[Registration Number (ST Number)],[Trailer Number (TT Number)],[Town/City/Suburb],[Body work, bonnet, grill and bumper],[Windscreen wipers],[Lenses and reflectors],[Front number plate],[License, permits & certificates of fitness],[Side mirrors],[Doors and windows],[Wheels & tyres, dust capsa and wheel nuts],[Batteries and holders],[Air tanks],[Spare wheel],[Rear Chevron, number plate],[Rear lenses and reflectors],[Fuel tank and fuel cap],[2 Chock Blocks],[Have the 2 Chock Blocks been used correctly],[Exterior Inspection Comments],[Parking brake must be applied],[Gear lever (or selector)],[Driver’s cab],[Emergency triangles],[Jack, wheel spanner & fire extinguisher],[Seat],[Steering],[Mirrors],[Ignition in “ON” position – check instruments],[Start engine - Instruments],[Head and brake lights, indicators, hooter and wiper],[Brake and clutch pedals],[Doors],[Interior Inspection and Startup Procedure comments],[Body work],[License discs and number plates],[Information plates],[Couplings and service lines],[Lights],[Front and rear reflectors],[Fifth wheel],[Towbar and pins],[Rear Chevron],[Wheels and tyres],[Spare wheels],[Locks],[Doors and hinges],[Drawbar/Semi Trailer Inspection Comments],[Place the gear shift lever into the neutral position],[Check around the vehicle to see if it was safe to start],[Pre-heat the engine (if applicable)],[Crank the starter motor for less than 30 seconds],[Allow starter to cool before trying again (if applicable)],[Allow engine to warm up without revving the engine],[Allow the brake air pressure to build up gradually],[Check all the gauges and instruments for functionality],[Vehicle Start Up Procedures Comments],[1.1 Changes excessively],[1.2 Grates gears],[1.3 Slips gears],[1.4 Hand rests on top of gear lever],[1.5 Eyes on gears],[1.6 Fails to change up / down],[1.7 Select neutral while driving],[2.1 Slips clutch],[2.2 Rides clutch],[2.3 De-clutch too early],[2.4 Keeps clutch depressed while stopped],[2.5 Selects neutral too early],[3.1 Planning ahead],[3.2 Mirror / Blind Spot],[3.3 Brakes too early],[3.4 Brakes too late],[3.5 Brakes not smooth],[3.6 No clear space in front],[3.7 Handbrake not properly utilised],[3.8 Brake used unnecessarily],[3.9 Incorrect negotiation of the decline],[4.1 Wanders],[4.2 Positioning/seating],[5.1 Planning ahead],[5.2 Does not maintain constant speed],[5.3 Too fast],[5.4 Too slow],[5.5 Greenband driving],[6.1 Not according to specification],[6.2 Not used when required],[7.1 Not vehicle friendly/too hard],[7.2 Mounts the kerb],[7.3 Bump objects],[8.1 Alley docking from left],[8.2 Reversing in a straight line],[1.1 Observations/left and right],[1.2 Wrong gear],[1.3 Stalls],[1.4 Waits too long],[2.1 Planning ahead],[2.2 Mirror],[2.3 Blind spots],[2.4 Rolling back],[2.5 Indicators],[2.6 Indicator not cancelled],[2.7 Fails to check trailer],[2.8 Position for turn/wheels straight],[2.9 Brake while cornering],[2.10 Too fast],[2.11 Cuts corners],[2.12 Too wide],[2.13 Changing gears on corners],[3.1 Ignore change in road surface and conditions],[3.2 Ignores actions of other road users],[3.3 Ignores weather conditions],[3.4 No observations],[3.5 Use of mirrors],[3.6 Ignores road signs / markings],[3.7 Moves into blind spots of other drivers],[4.1 Travels Too close to crown of road],[4.2 Fails to maintain following distance],[4.3 Straddling],[5.1 Fails to notice hazards],[5.2 Fails to react to hazards],[5.3 Incorrect use of hooter],[6.1 Mirror],[6.2 Blind spots],[6.3 Indicators],[6.4 Indicators not cancelled],[6.5 Fails to check safety ahead/rear],[6.6 Fails to back down],[6.7 Accelerates when being overtaken],[6.8 Fails to check safety ahead/rear],[6.9 Entry and Exit onto freeways],[Start],[End],[Total],[Time started],[Time ended],[Trainers Recommendations for further training]
from (
SELECT
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,CAST(A.Detail AS VARCHAR(8000)) as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI,AM.Latitude,AM.Longitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2231 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (26967,13869,13870,13871,13872,13874,13875,13876,13877,13878,13879,14181,13881,13882,14046,13891,13892,13893,13894,13895,13896,13897,13898,13899,13900,13901,13902,13903,13904,17600,17601,13905,14182,14183,14184,14185,14186,14187,14188,14189,14190,14191,14192,14193,14194,13920,14195,14196,14197,14198,14199,14200,14201,14202,14203,14204,14205,14206,14207,13935,13938,13939,13940,13941,13942,13943,13944,13945,13946,13952,13953,13954,13955,13956,13957,13958,14056,13961,13962,13963,13964,14057,13967,13968,13969,13970,13971,13972,13973,13974,13976,13977,13979,13980,13981,13982,13983,13985,13986,13988,13989,13990,13992,13993,13996,13997,13998,13999,14001,14002,14003,14004,14010,14006,14007,14008,14009,14011,14012,14013,14014,14016,14017,14018,14019,14020,14021,14022,14024,14025,14026,14028,14029,14030,14032,14033,14034,14035,14036,14037,14038,14039,14040,14043,14044,14045,14047,14048,14041)
LEFT outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Date of assessment],[Drivers name and surname],[Drivers Identity Number],[PDP Expiry Date],[License Expiry Date],[Make],[Model/Trailer],[Engine Type],[Gearbox make],[Gearbox speed],[Mesh Type],[Configuration],[Registration Number (ST Number)],[Trailer Number (TT Number)],[Town/City/Suburb],[Body work, bonnet, grill and bumper],[Windscreen wipers],[Lenses and reflectors],[Front number plate],[License, permits & certificates of fitness],[Side mirrors],[Doors and windows],[Wheels & tyres, dust capsa and wheel nuts],[Batteries and holders],[Air tanks],[Spare wheel],[Rear Chevron, number plate],[Rear lenses and reflectors],[Fuel tank and fuel cap],[2 Chock Blocks],[Have the 2 Chock Blocks been used correctly],[Exterior Inspection Comments],[Parking brake must be applied],[Gear lever (or selector)],[Driver’s cab],[Emergency triangles],[Jack, wheel spanner & fire extinguisher],[Seat],[Steering],[Mirrors],[Ignition in “ON” position – check instruments],[Start engine - Instruments],[Head and brake lights, indicators, hooter and wiper],[Brake and clutch pedals],[Doors],[Interior Inspection and Startup Procedure comments],[Body work],[License discs and number plates],[Information plates],[Couplings and service lines],[Lights],[Front and rear reflectors],[Fifth wheel],[Towbar and pins],[Rear Chevron],[Wheels and tyres],[Spare wheels],[Locks],[Doors and hinges],[Drawbar/Semi Trailer Inspection Comments],[Place the gear shift lever into the neutral position],[Check around the vehicle to see if it was safe to start],[Pre-heat the engine (if applicable)],[Crank the starter motor for less than 30 seconds],[Allow starter to cool before trying again (if applicable)],[Allow engine to warm up without revving the engine],[Allow the brake air pressure to build up gradually],[Check all the gauges and instruments for functionality],[Vehicle Start Up Procedures Comments],[1.1 Changes excessively],[1.2 Grates gears],[1.3 Slips gears],[1.4 Hand rests on top of gear lever],[1.5 Eyes on gears],[1.6 Fails to change up / down],[1.7 Select neutral while driving],[2.1 Slips clutch],[2.2 Rides clutch],[2.3 De-clutch too early],[2.4 Keeps clutch depressed while stopped],[2.5 Selects neutral too early],[3.1 Planning ahead],[3.2 Mirror / Blind Spot],[3.3 Brakes too early],[3.4 Brakes too late],[3.5 Brakes not smooth],[3.6 No clear space in front],[3.7 Handbrake not properly utilised],[3.8 Brake used unnecessarily],[3.9 Incorrect negotiation of the decline],[4.1 Wanders],[4.2 Positioning/seating],[5.1 Planning ahead],[5.2 Does not maintain constant speed],[5.3 Too fast],[5.4 Too slow],[5.5 Greenband driving],[6.1 Not according to specification],[6.2 Not used when required],[7.1 Not vehicle friendly/too hard],[7.2 Mounts the kerb],[7.3 Bump objects],[8.1 Alley docking from left],[8.2 Reversing in a straight line],[1.1 Observations/left and right],[1.2 Wrong gear],[1.3 Stalls],[1.4 Waits too long],[2.1 Planning ahead],[2.2 Mirror],[2.3 Blind spots],[2.4 Rolling back],[2.5 Indicators],[2.6 Indicator not cancelled],[2.7 Fails to check trailer],[2.8 Position for turn/wheels straight],[2.9 Brake while cornering],[2.10 Too fast],[2.11 Cuts corners],[2.12 Too wide],[2.13 Changing gears on corners],[3.1 Ignore change in road surface and conditions],[3.2 Ignores actions of other road users],[3.3 Ignores weather conditions],[3.4 No observations],[3.5 Use of mirrors],[3.6 Ignores road signs / markings],[3.7 Moves into blind spots of other drivers],[4.1 Travels Too close to crown of road],[4.2 Fails to maintain following distance],[4.3 Straddling],[5.1 Fails to notice hazards],[5.2 Fails to react to hazards],[5.3 Incorrect use of hooter],[6.1 Mirror],[6.2 Blind spots],[6.3 Indicators],[6.4 Indicators not cancelled],[6.5 Fails to check safety ahead/rear],[6.6 Fails to back down],[6.7 Accelerates when being overtaken],[6.8 Fails to check safety ahead/rear],[6.9 Entry and Exit onto freeways],[Start],[End],[Total],[Time started],[Time ended],[Trainers Recommendations for further training]
))p 
)d
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
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 296 and eg.id=2527 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (35061,34863,34864)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Type of training],[Comments],[Attachments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
)z


UNION ALL

SELECT q.Activity,
       q.EstablishmentName,
       q.CapturedDate,
       q.ReferenceNo,
       q.Status,
       q.UserName,
       q.Latitude,
       q.Longitude,
	   q.PI,
	   q.CustomerName,
	   REPLACE(IIF(q.Client IS NULL,q.EstablishmentName,IIF(q.Client='',q.EstablishmentName,q.Client)),'Defensive Driving Assessment','') AS Client,
       q.[Date of assessment],
       q.[Drivers Name and Surname],
       q.[Drivers Identity Number],
       IIF(q.[Type of Driver] IS NULL OR q.[Type of Driver]='','Other',q.[Type of Driver]) AS [Type of Driver],
       q.[License Expiry Date],
       q.[PrDP Expiry Date],
       q.[Alternate ID number/Passport number],
       q.[Written test score (%)],
       q.[Medical Completed],
       q.[Any medical conditions noted],
       q.Make,
       q.Model,
       q.[Engine Type],
       IIF(q.Gearbox IS NULL OR q.Gearbox='','Other',q.Gearbox) AS Gearbox,
       q.Configuration,
       q.[Registration Number],
       q.[Trailer Number],
       q.[Town/City/Suburb],
       q.[1. Use of gears],
	   CASE WHEN RTRIM(LTRIM([1. Use of gears])) ='' THEN NULL ELSE CAST(q.[1. Use of gears] AS DECIMAL)/20 END AS [Gear %],
       q.[2. Use of clutch],
	   CASE WHEN RTRIM(LTRIM([q].[2. Use of clutch])) ='' THEN NULL ELSE CAST(q.[2. Use of clutch] AS DECIMAL)/14 END AS [Clutch %],
       q.[3. Use of brakes / stopping],
	   CASE WHEN RTRIM(LTRIM([q].[3. Use of brakes / stopping])) ='' THEN NULL ELSE CAST(q.[3. Use of brakes / stopping] AS DECIMAL)/28 END AS [Brakes %],
       q.[4. Steering],
	   CASE WHEN RTRIM(LTRIM([q].[4. Steering])) ='' THEN NULL ELSE CAST(q.[4. Steering] AS DECIMAL)/5 END AS [Steering %],
       q.[5. Acceleration management],
	   CASE WHEN RTRIM(LTRIM([q].[5. Acceleration management])) ='' THEN NULL ELSE CAST(q.[5. Acceleration management] AS DECIMAL)/11 END AS [Acceleration %],
       q.[Use of retardation devices],
	   0.00 AS [Retardation %],
       q.[6. Vehicle Sympathy],
	   CASE WHEN RTRIM(LTRIM([q].[6. Vehicle Sympathy])) ='' THEN NULL ELSE CAST(q.[6. Vehicle Sympathy] AS DECIMAL)/6 END AS [Vehicle %],
       q.Manoeuvering,
	   0.00 AS [Manoeuvering %],
       q.[7. Parking],
	   CASE WHEN RTRIM(LTRIM([q].[7. Parking])) ='' THEN NULL ELSE CAST(q.[7. Parking] AS DECIMAL)/12 END AS [Parking %],
       q.[1. Moving off],
	   CASE WHEN RTRIM(LTRIM([q].[1. Moving off])) ='' THEN NULL ELSE CAST(q.[1. Moving off] AS DECIMAL)/8 END AS [Moving %],
       q.[2. Intersections and cornering],
	   CASE WHEN RTRIM(LTRIM([q].[2. Intersections and cornering])) ='' THEN NULL ELSE CAST(q.[2. Intersections and cornering] AS DECIMAL)/31 END AS [Intersections %],
       q.[3. Road observations],
	   CASE WHEN RTRIM(LTRIM([q].[3. Road observations])) ='' THEN NULL ELSE CAST(q.[3. Road observations] AS DECIMAL)/16 END AS [Road %],
       q.[4. Positioning and distance],
	   CASE WHEN RTRIM(LTRIM([q].[4. Positioning and distance])) ='' THEN NULL ELSE CAST(q.[4. Positioning and distance] AS DECIMAL)/10 END AS [Positioning %],
       q.[5. Assessment of hazards],
	   CASE WHEN RTRIM(LTRIM([q].[5. Assessment of hazards])) ='' THEN NULL ELSE CAST(q.[5. Assessment of hazards] AS DECIMAL)/10 END AS [Hazards %],
       q.[6. Lane changing & Overtaking],
	   CASE WHEN RTRIM(LTRIM([q].[6. Lane changing & Overtaking])) ='' THEN NULL ELSE CAST(q.[6. Lane changing & Overtaking] AS DECIMAL)/20 END AS [Lane %],
       q.[Driver Trainer comments],
       q.[Driver Trainer Recommendations],
       q.ResponseDate,
       q.Refno,
       q.[Type of training],
       q.[Comments],
       IIF(q.Refno<>NULL,IIF(q.Attachments='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',q.Attachments)),NULL) AS Attachments
	   FROM 
(SELECT 'LMV' AS Activity,
	   AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
	   AA.Latitude,
	   AA.Longitude,
	   AA.PI,
	   AA.CustomerName,
	   AA.Client,
       AA.[Date of assessment],
       AA.[Drivers Name and Surname],
       AA.[Drivers Identity Number],
       REPLACE(AA.[Type of Driver],'-- Select --','') AS [Type of Driver],
       AA.[License Expiry Date],
       AA.[PrDP Expiry Date],
       AA.[Alternate ID number/Passport number],
       AA.[Written test score (%)],
       AA.[Medical Completed],
       AA.[Any medical conditions noted],
       AA.Make,
       AA.Model,
	   'Other' AS [Engine Type],
       AA.Gearbox,
	   'Other' AS Configuration,
       AA.[Registration number],
	   'Other' AS [Trailer Number],
       AA.[Town/City/Suburb],
       REPLACE(AA.[1. Use of gears],'-- Select --','') AS [1. Use of gears],
       REPLACE(AA.[2. Use of clutch],'-- Select --','') AS [2. Use of clutch],
       REPLACE(AA.[3. Use of brakes/stopping],'-- Select --','') AS [3. Use of brakes / stopping],
       REPLACE(AA.[4. Steering],'-- Select --','') AS [4. Steering],
       REPLACE(AA.[5. Acceleration management],'-- Select --','') AS [5. Acceleration management],
	   '-1' AS [Use of retardation devices],
       REPLACE(AA.[6. Vehicle Sympathy],'-- Select --','') AS [6. Vehicle Sympathy],
	   '-1' AS [Manoeuvering],
       REPLACE(AA.[7. Parking],'-- Select --','') AS [7. Parking],
       REPLACE(AA.[1. Moving off],'-- Select --','') AS [1. Moving off],
       REPLACE(AA.[2. Intersections and cornering],'-- Select --','') AS [2. Intersections and cornering],
       REPLACE(AA.[3. Road observations],'-- Select --','') AS [3. Road observations],
       REPLACE(AA.[4. Positioning and distance],'-- Select --','') AS [4. Positioning and distance],
       REPLACE(AA.[5. Assessment of hazards],'-- Select --','') AS [5. Assessment of hazards],
       REPLACE(AA.[6. Lane changing & Overtaking],'-- Select --','') AS [6. Lane changing & Overtaking],
       REPLACE(AA.[Driver Trainer comments],'-','') AS [Driver Trainer comments],
       AA.[Driver Trainer Recommendations],
	   CONVERT(DATE,BB.ResponseDate) AS ResponseDate,
	   BB.ReferenceNo AS Refno,
	   BB.[Type of training],
	   BB.[Comments],
	   BB.[Attachments]
	    FROM (
SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,p.Latitude,p.Longitude,p.PI,p.CustomerName,
[Client],[Date of assessment],[Drivers Name and Surname],[Drivers Identity Number],[Type of Driver],[License Expiry Date],[PrDP Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model],[Gearbox],[Registration Number],[Town/City/Suburb],[1. Use of gears],[2. Use of clutch],[3. Use of brakes/Stopping],[4. Steering],[5. Acceleration Management],[6. Vehicle Sympathy],[7. Parking],[1. Moving Off],[2. Intersections and Cornering],[3. Road Observations],[4. Positioning and Distance],[5. Assessment of Hazards],[6. Lane changing & overtaking],[Driver Trainer comments],[Driver Trainer Recommendations]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,am.Latitude,am.Longitude,CAST(A.Detail AS VARCHAR(8000)) as Answer,Q.QuestionTitle as Question,u.name as UserName,AM.PI,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1909
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=1910
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 296 and eg.id=2605
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (26966,17922,17923,29110,17924,17925,29585,32000,31998,31999,28837,28838,28839,28840,28841,18208,18209,18210,18211,18212,18213,18214,18215,18216,18217,18218,18219,18220,17942,28375,49789)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy	
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Client],[Date of assessment],[Drivers Name and Surname],[Drivers Identity Number],[Type of Driver],[License Expiry Date],[PrDP Expiry Date],[Alternate ID number/Passport number],[Written test score (%)],[Medical Completed],[Any medical conditions noted],[Make],[Model],[Gearbox],[Registration Number],[Town/City/Suburb],[1. Use of gears],[2. Use of clutch],[3. Use of brakes/Stopping],[4. Steering],[5. Acceleration Management],[6. Vehicle Sympathy],[7. Parking],[1. Moving Off],[2. Intersections and Cornering],[3. Road Observations],[4. Positioning and Distance],[5. Assessment of Hazards],[6. Lane changing & overtaking],[Driver Trainer comments],[Driver Trainer Recommendations]
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
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 296 and eg.id=2605 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (35060,34860,34861)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Type of training],[Comments],[Attachments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
)q

