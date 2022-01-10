-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 08-Aug-2021
-- Description: Get Recurring Setting
-- SP call: GetRecurringSetting 1003541
-- =============================================
CREATE PROCEDURE [dbo].[GetRecurringSetting] @SeenClientAnswerMasterId BIGINT
AS
BEGIN
    SELECT RS.SeenClientAnswerMasterId,
           RS.RecurringDate,
           CONVERT(VARCHAR(5),DATEADD(MINUTE, SCM.TimeOffSet, RS.RecurringTime)  , 108) AS RecurringTime,
           RS.RecurringId,
           RS.RecuringCount,
           RS.RepeateCount,
           RS.RepeateEveryOnId,
           RS.CustomMonthId,
           RS.RepeateEveryOnDays,
           RS.RepeateEndsId,
           RS.RepeateEndsOnDate,
           RS.RepeateEndsAfterCount,
           RS.LastCreatedDate,
           RS.LastRepeatedWeek,
           RS.CreatedOn,
           RS.CreatedBy,
           RS.UpdatedOn,
           RS.UpdatedBy,
           RS.DeletedOn,
           RS.IsDeleted,
           RS.DayNo
    FROM dbo.RecurringSetting RS WITH (NOLOCK)
        INNER JOIN dbo.SeenClientAnswerMaster SCM
            ON SCM.Id = RS.SeenClientAnswerMasterId
    WHERE RS.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ISNULL(RS.IsDeleted, 0) = 0;
END;
