CREATE PROC [dbo].[GetAllEstablishmentRemindersTaskTable]
AS
SET NOCOUNT ON;
SELECT [Id],
       [TimeOfReminder],
       [RecurrenceType],
       [RunOn],
       [StartDate],
       [EndDate],
       [IsActive]
FROM EstablishmentRemindersTaskTable
WHERE IsDeleted = 0;
SET NOCOUNT OFF;