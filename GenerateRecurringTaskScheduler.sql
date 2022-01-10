-- =============================================
-- Author:		Krishna Panchal
-- Create date: 2-June-2021
-- Description:	Generate Recurring Task Scheduler
-- Call SP:		GenerateRecurringTaskScheduler

-- =============================================
CREATE PROCEDURE dbo.GenerateRecurringTaskScheduler @Date DATETIME = ''
AS
BEGIN
    IF (@Date = '')
    BEGIN
        SET @Date = GETUTCDATE();
    END;
    DECLARE @ServerDate DATETIME = @Date;
    DECLARE @FromTime TIME = DATEADD(MINUTE, -5, @ServerDate),
            @ToTime TIME = DATEADD(MINUTE, 2, @ServerDate);

    DECLARE @Data AS TABLE
    (
        Id INT PRIMARY KEY IDENTITY(1, 1),
        SeenClientAnswerMasterId BIGINT
    );

    -- Daily
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 1
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND CAST(RecurringDate AS DATE) >= CAST(@ServerDate AS DATE);

    -- Weekly
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 2
          AND DATENAME(WEEKDAY, RecurringDate) = DATENAME(WEEKDAY, @ServerDate)
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Monthly fourth
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 3
          AND CAST(
              (
                  SELECT dbo.GetDateofFourthDayMonthWise(DATENAME(WEEKDAY, RecurringDate), @Date, DayNo)
              ) AS DATE) = CAST(@ServerDate AS DATE)
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Last Week Day
    --SELECT SeenClientAnswerMasterId
    --FROM dbo.RecurringSetting
    --WHERE RecurringId = 4
    --      AND CAST(
    --          (
    --              SELECT dbo.GetLastDateByMonth(DATENAME(WEEKDAY, @ServerDate), @Date)
    --          ) AS DATE) = CAST(@ServerDate AS DATE)
    --      AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
    --      AND CAST(RecurringTime AS TIME)
    --      BETWEEN @FromTime AND @ToTime;

    -- Yearly	  
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 4
          AND MONTH(RecurringDate) = MONTH(@ServerDate)
          AND DAY(RecurringDate) = DAY(@ServerDate)
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Weekdays
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 5
          AND DATENAME(dw, @ServerDate) NOT IN ( 'Sunday', 'Saturday' )
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Custom Logic

    -- Day
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 6
          AND RepeateEveryOnId = 1
          AND CAST(ISNULL(DATEADD(DAY, RepeateCount, LastCreatedDate), '') AS DATE) < CAST(@ServerDate AS DATE)
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND ISNULL(CAST(RepeateEndsOnDate AS DATE), DATEADD(DAY, 1, @ServerDate)) >= CAST(@ServerDate AS DATE)
          AND RepeateEndsAfterCount > (CASE
                                           WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                               -1
                                           ELSE
                                               RecuringCount
                                       END
                                      )
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Week
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 6
          AND RepeateEveryOnId = 2
          AND (
                  (CAST(@ServerDate AS DATE)
          BETWEEN (DATEADD(
                              DAY,
                              2
                              - DATEPART(
                                            WEEKDAY,
                                            CAST(ISNULL(DATEADD(WEEK, RepeateCount + 1, LastCreatedDate), '') AS DATE)
                                        ),
                              CAST(CAST(ISNULL(DATEADD(WEEK, RepeateCount + 1, LastCreatedDate), '') AS DATE) AS DATE)
                          )
                  ) AND (DATEADD(
                                    DAY,
                                    8
                                    - DATEPART(
                                                  WEEKDAY,
                                                  CAST(ISNULL(
                                                                 DATEADD(
                                                                            WEEK,
                                                                            RepeateCount + 1,
                                                                            LastCreatedDate
                                                                        ),
                                                                 ''
                                                             ) AS DATE)
                                              ),
                                    CAST(CAST(ISNULL(DATEADD(WEEK, RepeateCount + 1, LastCreatedDate), '') AS DATE) AS DATE)
                                )
                        )
                  )
                  OR ISNULL(LastCreatedDate, '') = ''
                  OR (CAST(@ServerDate AS DATE)
          BETWEEN (DATEADD(
                              DAY,
                              2 - DATEPART(WEEKDAY, CAST(ISNULL(DATEADD(WEEK, 0, LastCreatedDate), '') AS DATE)),
                              CAST(CAST(ISNULL(DATEADD(WEEK, 0, LastCreatedDate), '') AS DATE) AS DATE)
                          )
                  ) AND (DATEADD(
                                    DAY,
                                    8
                                    - DATEPART(
                                                  WEEKDAY,
                                                  CAST(ISNULL(DATEADD(WEEK, 0, LastCreatedDate), '') AS DATE)
                                              ),
                                    CAST(CAST(ISNULL(DATEADD(WEEK, 0, LastCreatedDate), '') AS DATE) AS DATE)
                                )
                        )
                     )
              )
          AND CAST(ISNULL(DATEADD(WEEK, RepeateCount, LastCreatedDate), '') AS DATE) < CAST(@ServerDate AS DATE)
          AND DATENAME(WEEKDAY, @ServerDate) IN (
                                                    SELECT Data FROM dbo.Split(RepeateEveryOnDays, ',')
                                                )
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND ISNULL(CAST(RepeateEndsOnDate AS DATE), DATEADD(DAY, 1, @ServerDate)) >= CAST(@ServerDate AS DATE)
          AND RepeateEndsAfterCount > (CASE
                                           WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                               -1
                                           ELSE
                                               RecuringCount
                                       END
                                      )
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

     -- Month
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 6
          AND RepeateEveryOnId = 3
          AND CustomMonthId = 1
          AND DAY(RecurringDate) = DAY(@ServerDate)
          AND (
                  (ISNULL(DATENAME(MONTH, (DATEADD(MONTH, RepeateCount + 1, LastCreatedDate))), '') = DATENAME(
                                                                                                                  MONTH,
                                                                                                                  @ServerDate
                                                                                                              )
                  )
                  OR ISNULL(LastCreatedDate, '') = ''
              )
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND ISNULL(CAST(RepeateEndsOnDate AS DATE), DATEADD(DAY, 1, @ServerDate)) >= CAST(@ServerDate AS DATE)
          AND RepeateEndsAfterCount > (CASE
                                           WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                               -1
                                           ELSE
                                               RecuringCount
                                       END
                                      )
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Month
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 6
          AND RepeateEveryOnId = 3
          AND CustomMonthId = 2
          AND CAST(
              (
                  SELECT dbo.GetDateofFourthDayMonthWise(DATENAME(WEEKDAY, RecurringDate), @Date, DayNo)
              ) AS DATE) = CAST(@ServerDate AS DATE)
          AND (
                  (ISNULL(DATENAME(MONTH, (DATEADD(MONTH, RepeateCount + 1, LastCreatedDate))), '') = DATENAME(
                                                                                                                  MONTH,
                                                                                                                  @ServerDate
                                                                                                              )
                  )
                  OR ISNULL(LastCreatedDate, '') = ''
              )
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND ISNULL(CAST(RepeateEndsOnDate AS DATE), DATEADD(DAY, 1, @ServerDate)) >= CAST(@ServerDate AS DATE)
          AND RepeateEndsAfterCount > (CASE
                                           WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                               -1
                                           ELSE
                                               RecuringCount
                                       END
                                      )
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    -- Year
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId
    )
    SELECT SeenClientAnswerMasterId
    FROM dbo.RecurringSetting
    WHERE RecurringId = 6
          AND RepeateEveryOnId = 4
          AND MONTH(RecurringDate) = MONTH(@ServerDate)
          AND DAY(RecurringDate) = DAY(@ServerDate)
          AND CAST(ISNULL(DATEADD(YEAR, RepeateCount, LastCreatedDate), '') AS DATE) < CAST(@ServerDate AS DATE)
          AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
          AND CAST(RecurringTime AS TIME)
          BETWEEN @FromTime AND @ToTime
          AND ISNULL(CAST(RepeateEndsOnDate AS DATE), DATEADD(DAY, 1, @ServerDate)) >= CAST(@ServerDate AS DATE)
          AND RepeateEndsAfterCount > (CASE
                                           WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                               -1
                                           ELSE
                                               RecuringCount
                                       END
                                      )
          AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE);

    DECLARE @count INT = 1,
            @TotalRecord INT,
            @SeenClientAnswerMaster BIGINT;

    SELECT @TotalRecord = COUNT(*)
    FROM @Data;


    WHILE @count <= @TotalRecord
    BEGIN
        SELECT @SeenClientAnswerMaster = SeenClientAnswerMasterId
        FROM @Data
        WHERE Id = @count;
        DECLARE @InsertedId INT = 0;
        INSERT INTO dbo.SeenClientAnswerMaster
        (
            EstablishmentId,
            SeenClientId,
            AppUserId,
            IsOutStanding,
            ReadBy,
            Latitude,
            Longitude,
            TimeOffSet,
            IsPositive,
            EI,
            IsResolved,
            IsTransferred,
            SeenClientAnswerMasterId,
            IsActioned,
            SenderCellNo,
            ContactMasterId,
            IsSubmittedForGroup,
            ContactGroupId,
            PI,
            CreatedOn,
            CreatedBy,
            IsDeleted,
            DisabledOn,
            DisabledBy,
            IsDisabled,
            MobileDate,
            EscalationSendDate,
            IsRecursion,
            Narration,
            CopyReferenceID,
            DraftEntry,
            Platform,
            DraftSave,
            IsFlag,
            StatusHistoryId,
            IsUnAllocated,
            ImportFileId
        )
        SELECT EstablishmentId,
               SeenClientId,
               AppUserId,
               IsOutStanding,
               ReadBy,
               Latitude,
               Longitude,
               TimeOffSet,
               IsPositive,
               EI,
               'UnResolved',
               IsTransferred,
               SeenClientAnswerMasterId,
               IsActioned,
               SenderCellNo,
               ContactMasterId,
               IsSubmittedForGroup,
               ContactGroupId,
               PI,
               @ServerDate,
               CreatedBy,
               IsDeleted,
               DisabledOn,
               DisabledBy,
               IsDisabled,
               MobileDate,
               EscalationSendDate,
               IsRecursion,
               Narration,
               CopyReferenceID,
               DraftEntry,
               Platform,
               DraftSave,
               IsFlag,
               StatusHistoryId,
               IsUnAllocated,
               0
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMaster
              AND ISNULL(IsUnAllocated, 0) = 0;

        SET @InsertedId = SCOPE_IDENTITY();

        IF (@InsertedId > 0)
        BEGIN
            INSERT INTO dbo.SeenClientAnswers
            (
                SeenClientAnswerMasterId,
                SeenClientAnswerChildId,
                QuestionId,
                OptionId,
                QuestionTypeId,
                Detail,
                Weight,
                QPI,
                CreatedOn,
                CreatedBy,
                IsDeleted,
                DisabledOn,
                DisabledBy,
                IsDisabled,
                RepetitiveGroupId,
                RepetitiveGroupName,
                RepeatCount,
                IsNA
            )
            SELECT @InsertedId,
                   SC.SeenClientAnswerChildId,
                   SC.QuestionId,
                   SC.OptionId,
                   SC.QuestionTypeId,
                   SC.Detail,
                   SC.Weight,
                   SC.QPI,
                   @ServerDate,
                   SC.CreatedBy,
                   SC.IsDeleted,
                   SC.DisabledOn,
                   SC.DisabledBy,
                   SC.IsDisabled,
                   SC.RepetitiveGroupId,
                   SC.RepetitiveGroupName,
                   SC.RepeatCount,
                   SC.IsNA
            FROM dbo.SeenClientAnswers SC
                INNER JOIN dbo.SeenClientAnswerMaster SCM
                    ON SCM.Id = SC.SeenClientAnswerMasterId
                       AND ISNULL(SCM.IsUnAllocated, 0) = 0
            WHERE SC.SeenClientAnswerMasterId = @SeenClientAnswerMaster;
        END;
        SET @count = @count + 1;
    END;

	UPDATE dbo.RecurringSetting
    SET LastCreatedDate = @ServerDate
    WHERE SeenClientAnswerMasterId IN (
                                          SELECT SeenClientAnswerMasterId
                                          FROM dbo.RecurringSetting
                                          WHERE (DATENAME(DAY, RecurringDate)) IN ( '28', '29', '30', '31' )
                                                AND RecurringId = 6
                                                AND RepeateEveryOnId = 3
												  AND (DATENAME(DAY, @ServerDate)) = '27'
                                                AND CustomMonthId = 1
                                                AND (
                                                        (ISNULL(
                                                                   DATENAME(
                                                                               MONTH,
                                                                               (DATEADD(
                                                                                           MONTH,
                                                                                           RepeateCount + 1,
                                                                                           LastCreatedDate
                                                                                       )
                                                                               )
                                                                           ),
                                                                   ''
                                                               ) = DATENAME(MONTH, @ServerDate)
                                                        )
                                                        OR ISNULL(LastCreatedDate, '') = ''
                                                    )
                                                AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
                                                AND CAST(RecurringTime AS TIME)
                                                BETWEEN @FromTime AND @ToTime
                                                AND ISNULL(
                                                              CAST(RepeateEndsOnDate AS DATE),
                                                              DATEADD(DAY, 1, @ServerDate)
                                                          ) >= CAST(@ServerDate AS DATE)
                                                AND RepeateEndsAfterCount > (CASE
                                                                                 WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                                                                     -1
                                                                                 ELSE
                                                                                     RecuringCount
                                                                             END
                                                                            )
                                                AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE)
                                      );

    UPDATE dbo.RecurringSetting
    SET LastCreatedDate = @Date
    WHERE SeenClientAnswerMasterId IN (
                                          SELECT SeenClientAnswerMasterId
                                          FROM dbo.RecurringSetting
                                          WHERE (DATENAME(DAY, RecurringDate)) IN ( '28', '29', '30', '31' )
                                                AND RecurringId = 6
                                                AND RepeateEveryOnId = 3
                                                AND CustomMonthId = 2
                                                AND (DATENAME(DAY, @ServerDate)) = '27'
                                                AND ISNULL(
                                                    (
                                                        SELECT dbo.GetDateofFourthDayMonthWise(
                                                                                                  DATENAME(
                                                                                                              WEEKDAY,
                                                                                                              RecurringDate
                                                                                                          ),
                                                                                                  @Date,
                                                                                                  5
                                                                                              )
                                                    ),
                                                    ''
                                                          ) = ''
                                                AND (
                                                        (ISNULL(
                                                                   DATENAME(
                                                                               MONTH,
                                                                               (DATEADD(
                                                                                           MONTH,
                                                                                           RepeateCount + 1,
                                                                                           LastCreatedDate
                                                                                       )
                                                                               )
                                                                           ),
                                                                   ''
                                                               ) = DATENAME(MONTH, @ServerDate)
                                                        )
                                                        OR ISNULL(LastCreatedDate, '') = ''
                                                    )
                                                AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <> CAST(@ServerDate AS DATE)
                                                AND ISNULL(
                                                              CAST(RepeateEndsOnDate AS DATE),
                                                              DATEADD(DAY, 1, @ServerDate)
                                                          ) >= CAST(@ServerDate AS DATE)
                                                AND RepeateEndsAfterCount > (CASE
                                                                                 WHEN ISNULL(RepeateEndsAfterCount, 0) = 0 THEN
                                                                                     -1
                                                                                 ELSE
                                                                                     RecuringCount
                                                                             END
                                                                            )
                                                AND CAST(RecurringDate AS DATE) <= CAST(@ServerDate AS DATE)
                                      );

    UPDATE t1
    SET t1.RecuringCount = t1.RecuringCount + 1,
        LastCreatedDate = @ServerDate
    FROM dbo.RecurringSetting t1
        INNER JOIN @Data t2
            ON t2.SeenClientAnswerMasterId = t1.SeenClientAnswerMasterId
    WHERE ISNULL(t1.IsDeleted, 0) = 0;

--Last Updated week
--SELECT SeenClientAnswerMasterId
--FROM dbo.RecurringSetting
--WHERE RecurringId = 7
--      AND DATENAME(WEEKDAY, @ServerDate) = 'Sunday'
--      AND CAST(ISNULL(LastCreatedDate, '') AS DATE) <= CAST(@ServerDate AS DATE);
END;
