CREATE PROCEDURE [dbo].[GetEstablishmentReminderFeedbackTaskByEstablishmentId]       @EstablishmentId BIGINTASSET NOCOUNT ON
SELECT     [RecurrenceType],
		   [IntervalSad],
           [IntervalNeutral],
           [IntervalHappy],
           [IntervalAll],
           [IsActive]
FROM [dbo].[EstablishmentRemindersFeedbackTaskTable]
WHERE EstablishmentId = @EstablishmentId;SET NOCOUNT OFF

