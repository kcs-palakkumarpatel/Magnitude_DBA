-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 27-May-2021
-- Description: Insert Recurring data
-- SP call : InsertRecurringSetting
-- =============================================
CREATE PROCEDURE dbo.InsertRecurringSetting
    @AppUserId BIGINT,
    @SeenClientAnswerMasterId VARCHAR(MAX),
    @RecurringDate VARCHAR(200) = NULL,
    @RecurringTime VARCHAR(200) = NULL,
    @RecurringId INT = 0,
    @RepeateCount INT = 0,
    @CustomMonthId INT = 0,
    @RepeateEveryOnId INT = 0,
    @RepeateEveryOnDays VARCHAR(200) = 0,
    @RepeateEndsId INT = 0,
    @RepeateEndsOnDate VARCHAR(200) = NULL,
    @RepeateEndsAfterCount INT = 0,
    @DayNo INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    IF (@RecurringDate = '')
    BEGIN
        SET @RecurringDate = NULL;
    END;
    IF (@RepeateEveryOnDays = '')
    BEGIN
        SET @RepeateEveryOnDays = NULL;
    END;

    DECLARE @TblIds AS TABLE (Id BIGINT);
    INSERT INTO @TblIds
    (
        Id
    )
    SELECT Data
    FROM dbo.Split(@SeenClientAnswerMasterId, ',');

	UPDATE t1
    SET t1.IsDeleted = 1,
        t1.DeletedOn = GETUTCDATE()
    FROM dbo.RecurringSetting t1
        INNER JOIN dbo.SeenClientAnswerMaster SCM
            ON SCM.Id = t1.SeenClientAnswerMasterId
    WHERE t1.SeenClientAnswerMasterId IN (
                                             SELECT TB.Id FROM @TblIds TB
                                         )
          AND ISNULL(t1.IsDeleted, 0) = 0;

    INSERT INTO dbo.RecurringSetting
    (
        SeenClientAnswerMasterId,
        RecurringDate,
        RecurringTime,
        RecurringId,
        RecuringCount,
        RepeateCount,
        CustomMonthId,
        RepeateEveryOnId,
        RepeateEveryOnDays,
        RepeateEndsId,
        DayNo,
        RepeateEndsOnDate,
        RepeateEndsAfterCount,
        CreatedOn,
        CreatedBy,
        IsDeleted
    )
    SELECT TB.Id,
           @RecurringDate,                                  -- RecurringDate - datetime
           DATEADD(MINUTE, -SCM.TimeOffSet, @RecurringTime), -- RecurringTime - datetime
           @RecurringId,                                    -- RecurringId - int
           0,                                               -- RecuringCount - int
           @RepeateCount,                                   -- RepeateCount - int
           @CustomMonthId,
           @RepeateEveryOnId,                               -- RepeateEveryOnId - int
           @RepeateEveryOnDays,                             -- RepeateEveryOnDays - varchar(200)
           @RepeateEndsId,                                  -- RepeateEndsId - int
           @DayNo,
           @RepeateEndsOnDate,                              -- RepeateEndsOnDate - datetime
           @RepeateEndsAfterCount,                          -- RepeateEndsAfterCount - int
           GETUTCDATE(),                                    -- CreatedOn - datetime
           @AppUserId,                                      -- CreatedBy - bigint
           0                                                -- IsDeleted - bit
    FROM @TblIds TB
        INNER JOIN dbo.SeenClientAnswerMaster SCM
            ON SCM.Id = TB.Id
    WHERE TB.Id NOT IN (
                           SELECT SeenClientAnswerMasterId
                           FROM dbo.RecurringSetting
                           WHERE ISNULL(IsDeleted, 0) = 0
                       );

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END;
