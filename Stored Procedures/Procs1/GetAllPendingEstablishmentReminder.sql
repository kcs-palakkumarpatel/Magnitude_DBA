CREATE PROC [dbo].[GetAllPendingEstablishmentReminder]
AS
SET NOCOUNT ON;
SELECT [Id],
       [AppUserId],
       [UserDeviceId],
       [EstablishmentRemindersTaskId],
       [EstablishmentId],
       [IsOut],
       [Message],
       [SentDate],
       [IsSent],
	   [FormCapturedbyUser]
FROM PendingEstablishmentReminder
WHERE IsDeleted = 0;

SET NOCOUNT OFF;