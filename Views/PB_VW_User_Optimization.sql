CREATE VIEW dbo.PB_VW_User_Optimization as

SELECT d.Id,
       d.GroupName,
	   d.EstablishmentGroupName,
       d.EstablishmentName,
       d.Username,
	   CONCAT(d.Name,' ',d.Surname) AS Respondent,
       d.CreatedOn,
       d.Formtype,
       d.chatid,
       d.chatdate,
       d.Conversation,
	   CASE WHEN d.Conversation LIKE 'Resolved%' THEN 'Resolved'
			WHEN d.Conversation LIKE 'Unresolved%' THEN 'Unresolved'
			WHEN d.Conversation LIKE '%the status from%' THEN 'Status Changed'
			WHEN d.Conversation LIKE '%- Remind Me on%' THEN 'Reminders'
			WHEN d.Conversation IS NULL THEN 'No Chat'
			ELSE 'Physical Chat' END AS chattype
	   FROM
(
SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Captured' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 
and CD.contactQuestionId IN (case when g.id=462 then 2834 when g.id=437 then 2713 when g.id=450 then 2780 when g.id=463 then 2839 when g.id=497 then 3021 when g.id=477 then 2910 when g.id=505 then 3057 when g.id=432 then 2675 when g.id=509 then 3071 when g.id=515 then 3138 when g.id=400 then 2490 when g.id=537 then 3249 when g.id=355 then 2207 when g.id=296 then 1909 when g.id=416 then 2588 when g.id=353 then 2189 when g.id=373 then 2356 when g.id=329 then 2056 when g.id=484 then 2944 when g.id=514 then 3124 when g.id=27 then 265 when g.id=378 then 2385 when g.id=413 then 2721 when g.id=414 then 2578 when g.id=438 then 2721 when g.id=343 then 2128 when g.id=32 then 341 when g.id=234 then 1603 when g.id=196 then 1388 when g.id=392 then 2444 when g.id=422 then 2607 when g.id=366 then 2284 when g.id=655 then 4347 when g.id=669 then 4428 when g.id=667 then 4413 when g.id=622 then 3973 END)
) AS Name,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 
and CD.contactQuestionId IN (case when g.id=437 then 2714 when g.id=450 then 2781 when g.id=463 then 2840 when g.id=497 then 3022 when g.id=477 then 2911 when g.id=505 then 3058 when g.id=432 then 2676 when g.id=509 then 3072 when g.id=515 then 3139 when g.id=400 then 2491 when g.id=537 then 3250 when g.id=355 then 2208 when g.id=296 then 1910 when g.id=353 then 2190 when g.id=329 then 2057 when g.id=484 then 2945 when g.id=514 then 3125 when g.id=27 then 266 when g.id=378 then 2386 when g.id=413 then 2722 when g.id=414 then 2579 when g.id=438 then 2722 when g.id=343 then 2129 when g.id=366 then 2285 when g.id=655 then 4348 when g.id=669 then 4429 when g.id=667 then 4414 when g.id=622 then 3974 END)
) as Surname
FROM 
SeenClientAnswerMaster AM
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,353,373,484,514,27,378,413,414,438,343,32,234,196,392,366,655,669,667,622)
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id

UNION ALL

SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Response' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation,NULL AS Name,NULL AS Surname FROM 
answermaster AM
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,353,373,484,514,27,378,413,414,438,343,32,234,196,392,366,655,669,667,622)
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId 
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id 

UNION ALL

SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,sh.StatusDateTime as CreatedOn,'Captured' AS Formtype,NULL AS chatid,NULL AS chatdate,
CONCAT(u1.Name,' ','changed the status from ',LAG(es.StatusName) OVER (ORDER BY sh.Id),' to ',es.StatusName) AS Conversation,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 
and CD.contactQuestionId IN (case when g.id=462 then 2834 when g.id=437 then 2713 when g.id=450 then 2780 when g.id=463 then 2839 when g.id=497 then 3021 when g.id=477 then 2910 when g.id=505 then 3057 when g.id=432 then 2675 when g.id=509 then 3071 when g.id=515 then 3138 when g.id=400 then 2490 when g.id=537 then 3249 when g.id=355 then 2207 when g.id=296 then 1909 when g.id=416 then 2588 when g.id=353 then 2189 when g.id=373 then 2356 when g.id=329 then 2056 when g.id=484 then 2944 when g.id=514 then 3124 when g.id=27 then 265 when g.id=378 then 2385 when g.id=413 then 2721 when g.id=414 then 2578 when g.id=438 then 2721 when g.id=343 then 2128 when g.id=32 then 341 when g.id=234 then 1603 when g.id=196 then 1388 when g.id=392 then 2444 when g.id=422 then 2607 when g.id=366 then 2284 when g.id=655 then 4347 when g.id=669 then 4428 when g.id=667 then 4413 when g.id=622 then 3973 END)
) AS Name,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 
and CD.contactQuestionId IN (case when g.id=437 then 2714 when g.id=450 then 2781 when g.id=463 then 2840 when g.id=497 then 3022 when g.id=477 then 2911 when g.id=505 then 3058 when g.id=432 then 2676 when g.id=509 then 3072 when g.id=515 then 3139 when g.id=400 then 2491 when g.id=537 then 3250 when g.id=355 then 2208 when g.id=296 then 1910 when g.id=353 then 2190 when g.id=329 then 2057 when g.id=484 then 2945 when g.id=514 then 3125 when g.id=27 then 266 when g.id=378 then 2386 when g.id=413 then 2722 when g.id=414 then 2579 when g.id=438 then 2722 when g.id=343 then 2129 when g.id=366 then 2285 when g.id=655 then 4348 when g.id=669 then 4429 when g.id=667 then 4414 when g.id=622 then 3974 end)
) as Surname
FROM 
StatusHistory sh
INNER JOIN dbo.SeenClientAnswerMaster am ON sh.ReferenceNo=am.Id
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,353,373,484,514,27,378,413,414,438,343,32,234,196,392,366,655,669,667,622)
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId
INNER JOIN dbo.AppUser u1 ON u1.Id=sh.UserId
INNER JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId

)d
WHERE d.Username NOT LIKE '%admin%' AND d.EstablishmentGroupName NOT LIKE '%Tell Us'

