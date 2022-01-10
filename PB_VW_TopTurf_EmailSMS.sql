CREATE VIEW PB_VW_TopTurf_EmailSMS AS

SELECT 'Email' AS [Type],Id,EmailId,IsSent,SentDate,RefId,ScheduleDateTime,CAST(ScheduleDateTime AS DATE) AS ScheduleDate,CreatedOn,Counter,0 AS [Amount]
FROM dbo.PendingEmail WHERE RefId IN (SELECT AM.Id FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=667 and EG.Id=7351
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null))
UNION ALL
SELECT 'SMS' AS [Type],Id,MobileNo,IsSent,SentDate,RefId,ScheduleDateTime,CAST(ScheduleDateTime AS DATE) AS ScheduleDate,CreatedOn,Counter,Counter*0.20 AS [Amount]
FROM dbo.PendingSMS WHERE RefId IN (SELECT AM.Id FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=667 and EG.Id=7351
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null))

