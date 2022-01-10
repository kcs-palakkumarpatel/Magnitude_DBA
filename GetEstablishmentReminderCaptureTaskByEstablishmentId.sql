CREATE PROCEDURE dbo.GetEstablishmentReminderCaptureTaskByEstablishmentId       @EstablishmentId BIGINTASSET NOCOUNT ON

SELECT 
      [TimeOfReminder],
      [RecurrenceType],
      [RunOn],
      [StartDate],
      [EndDate],
      [IsActive],
      [IsDeleted]
FROM [dbo].[EstablishmentRemindersCaptureTaskTable]
WHERE EstablishmentId = @EstablishmentId AND ISDeleted = 0SET NOCOUNT OFF

