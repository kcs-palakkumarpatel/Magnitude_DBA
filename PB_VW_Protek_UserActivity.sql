CREATE VIEW PB_VW_Protek_UserActivity AS

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
SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Captured' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation FROM 
SeenClientAnswerMaster AM
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.Id=505
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id 

UNION ALL

SELECT am.id,g.GroupName,eg.EstablishmentGroupName,e.EstablishmentName,u.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,'Response' AS Formtype,cla.Id AS chatid,cla.CreatedOn AS chatdate,cla.Conversation FROM 
answermaster AM
inner join Establishment E on  E.Id=am.EstablishmentId
INNER JOIN dbo.AppUser u ON u.Id=am.AppUserId
INNER JOIN dbo.[Group] g ON g.Id=e.GroupId AND g.Id=505
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id=e.EstablishmentGroupId 
LEFT JOIN dbo.CloseLoopAction cla ON cla.SeenClientAnswerMasterId = AM.Id 
)d

