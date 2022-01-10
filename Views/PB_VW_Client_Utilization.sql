CREATE VIEW dbo.PB_VW_Client_Utilization as

SELECT d.Id,
       d.GroupName,
	   d.EstablishmentGroupName,
       d.EstablishmentName,
       d.Username,
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
SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Captured' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation
FROM 
SeenClientAnswerMaster AM
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.IsDeleted=0 AND g.GroupName NOT LIKE '%demo%' AND g.GroupName NOT LIKE '%test%' AND g.GroupName NOT LIKE '%kcs%' AND g.GroupName NOT LIKE '%magnitude%'
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id

UNION ALL

SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Response' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation--,NULL AS Name,NULL AS Surname 
FROM 
answermaster AM
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.IsDeleted=0 AND g.GroupName NOT LIKE '%demo%' AND g.GroupName NOT LIKE '%test%' AND g.GroupName NOT LIKE '%kcs%' AND g.GroupName NOT LIKE '%magnitude%'
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId 
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id 

UNION ALL

SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,sh.StatusDateTime as CreatedOn,'Captured' AS Formtype,NULL AS chatid,NULL AS chatdate,
CONCAT(u1.Name,' ','changed the status from ',' to ',es.StatusName) AS Conversation
FROM 
StatusHistory sh
INNER JOIN dbo.SeenClientAnswerMaster am ON sh.ReferenceNo=am.Id
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.IsDeleted=0 AND g.GroupName NOT LIKE '%demo%' AND g.GroupName NOT LIKE '%test%' AND g.GroupName NOT LIKE '%kcs%' AND g.GroupName NOT LIKE '%magnitude%'
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId
INNER JOIN dbo.AppUser u1 ON u1.Id=sh.UserId
INNER JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId

)d
WHERE d.Username NOT LIKE '%admin%' AND d.EstablishmentGroupName NOT LIKE '%Tell Us'

