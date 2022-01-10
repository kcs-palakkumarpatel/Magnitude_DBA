create View PB_VW_Toyota_Fact_ClientUtilization as

SELECT 
       X.GroupName,
	   X.EstablishmentGroupName,
       X.EstablishmentName,
	   X.ReferenceNo,
       X.Username,
       X.CreatedOn,
       X.Formtype,
       X.ChatId,
       X.ChatDate,
       X.Conversation,
	   CASE WHEN X.Conversation LIKE 'Resolved%' THEN 'Resolved'
			WHEN X.Conversation LIKE 'Unresolved%' THEN 'Unresolved'
			WHEN X.Conversation LIKE '%the status from%' THEN 'Status Changed'
			WHEN X.Conversation LIKE '%- Remind Me on%' THEN 'Reminders'
			WHEN X.Conversation IS NULL THEN 'No Chat'
			ELSE 'Physical Chat' END AS chattype
	   FROM
(
SELECT G.GroupName,EG.EstablishmentGroupName,E.EstablishmentName,AM.Id as ReferenceNo,U.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,
'Captured' AS Formtype,CLA.Id AS ChatId,dateadd(MINUTE,120,CLA.CreatedOn) AS ChatDate,CLA.Conversation From
dbo.[Group] G 
INNER JOIN dbo.EstablishmentGroup EG ON G.Id=eg.GroupId AND G.Id =509 and establishmentgrouptype='Sales'
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
INNER JOIN SeenClientAnswerMaster AM on AM.EstablishmentId=E.Id
INNER JOIN dbo.AppUser U ON U.Id=AM.AppUserId and U.id<>5201
LEFT JOIN dbo.CloseLoopAction CLA ON CLA.SeenClientAnswerMasterId = AM.Id 

UNION ALL

SELECT G.GroupName,EG.EstablishmentGroupName,E.EstablishmentName,AM.Id as ReferenceNo,U.Name AS Username,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CreatedOn,
'Response' AS Formtype,CLA.Id AS ChatId,dateadd(MINUTE,120,CLA.CreatedOn) AS ChatDate,CLA.Conversation FROM
dbo.[Group] G 
INNER JOIN dbo.EstablishmentGroup EG ON G.Id=eg.GroupId AND G.Id =509 and establishmentgrouptype='Sales'
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
INNER JOIN AnswerMaster AM on AM.EstablishmentId=E.Id
INNER JOIN dbo.AppUser U ON U.Id=AM.AppUserId and U.id<>5201
LEFT JOIN dbo.CloseLoopAction CLA ON CLA.AnswerMasterId = AM.Id 
)X

union all
select GroupName  ,
	   EstablishmentGroupName,
       EstablishmentName,
	   ReferenceNo,
       Name as Username,
       CreatedOn,
       'Captured' as FormType,
       id as ChatId,
       Statustime as ChatDate,
       StatusName as Conversation,'Status Changed' as chattype from (

select A.Groupname,A.EstablishmentGroupName,A.EstablishmentName,A.createdon, Sh.id, sh.ReferenceNo,sh.StatusDateTime as Statustime,es.StatusName,AU.Name from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
inner join Appuser AU on AU.id=userid and AU.id<>5201
inner join (select Am.id,G.GroupName,EG.EstablishmentGroupName,E.EstablishmentName,Am.createdon from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join Appuser U on U.id=AM.Appuserid and U.id<>5201 Where (G.Id=509  and establishmentgrouptype='Sales'
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)))A on A.id=Sh.referenceno and Sh.isdeleted=0) B



