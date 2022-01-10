CREATE VIEW PB_VW_UCT_PendingEmail AS 

SELECT Id,EmailId,IsSent,SentDate,RefId,ScheduleDateTime,CAST(ScheduleDateTime AS DATE) AS ScheduleDate,ReplyTo,CreatedOn FROM dbo.PendingEmail WHERE RefId IN (
SELECT AM.Id FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=655 and EG.Id=7205
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenclientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
)

