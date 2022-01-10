﻿CREATE PROCEDURE dbo.GetEstablishmentReminderCaptureTaskByEstablishmentId 

SELECT 
      [TimeOfReminder],
      [RecurrenceType],
      [RunOn],
      [StartDate],
      [EndDate],
      [IsActive],
      [IsDeleted]
FROM [dbo].[EstablishmentRemindersCaptureTaskTable]
WHERE EstablishmentId = @EstablishmentId
