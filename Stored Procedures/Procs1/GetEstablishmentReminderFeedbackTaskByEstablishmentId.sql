﻿CREATE PROCEDURE [dbo].[GetEstablishmentReminderFeedbackTaskByEstablishmentId] 
SELECT     [RecurrenceType],
		   [IntervalSad],
           [IntervalNeutral],
           [IntervalHappy],
           [IntervalAll],
           [IsActive]
FROM [dbo].[EstablishmentRemindersFeedbackTaskTable]
WHERE EstablishmentId = @EstablishmentId;
