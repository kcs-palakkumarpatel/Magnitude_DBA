-- =============================================
-- Author:			Mittal Patel
-- Create date:	08-Jun-2021
-- Description:	<Description,InsertSeenClientAnswers_New>
-- =============================================
CREATE PROCEDURE dbo.InsertSeenClientAnswers_New @SeenclintAnswerlist SeenclintAnswer READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET DEADLOCK_PRIORITY NORMAL;
    BEGIN TRY
        IF OBJECT_ID('tempdb..#TempTable', 'U') IS NOT NULL
            DROP TABLE #TempTable;
        CREATE TABLE #TempTable
        (
            Id BIGINT IDENTITY(1, 1),
            lgAnswerMasterId VARCHAR(100),
            lgChildId VARCHAR(100),
            lgQuestionId VARCHAR(100),
            inQuestionTypeId VARCHAR(100),
            strDetail NVARCHAR(MAX),
            RepeatCount VARCHAR(100),
            RepetitiveGroupId VARCHAR(100),
            RepetitiveGroupName VARCHAR(100),
            lgAppUserId VARCHAR(100),
            CreatedOn DATETIME NULL
        );

        INSERT INTO #TempTable
        (
            lgAnswerMasterId,
            lgChildId,
            lgQuestionId,
            inQuestionTypeId,
            strDetail,
            RepeatCount,
            RepetitiveGroupId,
            RepetitiveGroupName,
            lgAppUserId,
            CreatedOn
        )
        SELECT lgAnswerMasterId,
               lgChildId,
               lgQuestionId,
               inQuestionTypeId,
               strDetail,
               RepeatCount,
               RepetitiveGroupId,
               RepetitiveGroupName,
               lgAppUserId,
               CreatedOn
        FROM @SeenclintAnswerlist;

        DECLARE @Counter INT,
                @TotalCount INT;
        SET @Counter = 1;
        SET @TotalCount =
        (
            SELECT COUNT(1) FROM #TempTable
        );
        WHILE (@Counter <= @TotalCount)
        BEGIN
            DECLARE @SeenClientAnswerMasterId BIGINT;
            DECLARE @SeenClientAnswerChildId BIGINT = NULL;
            DECLARE @QuestionId BIGINT;
            DECLARE @QuestionTypeId BIGINT;
            DECLARE @Detail NVARCHAR(MAX);
            DECLARE @RepeatCount INT;
            DECLARE @RepetitiveGroupId INT;
            DECLARE @RepetitiveGroupName VARCHAR(100);
            DECLARE @AppUserId BIGINT;
            DECLARE @CreatedOn DATETIME;
            SELECT @SeenClientAnswerMasterId = lgAnswerMasterId,
                   @SeenClientAnswerChildId = lgChildId,
                   @QuestionId = lgQuestionId,
                   @Detail = strDetail,
                   @AppUserId = lgAppUserId,
                   @QuestionTypeId = inQuestionTypeId,
                   @RepeatCount = RepeatCount,
                   @RepetitiveGroupId = RepetitiveGroupId,
                   @RepetitiveGroupName = RepetitiveGroupName,
                   @CreatedOn = CreatedOn
            FROM #TempTable
            WHERE Id = @Counter;

            DECLARE @Id BIGINT;
            DECLARE @OptionId NVARCHAR(MAX) = NULL,
                    @FinalWeight DECIMAL(18, 2) = 0,
                    @QPI DECIMAL(18, 2) = 0,
                    @MaxWeight DECIMAL(18, 2) = 0,
                    @IsNA BIT = 0,
                    @IsArithMetic BIT = 0,
                    @IsQuestionPassed NVARCHAR(10) = 'NA';

            SELECT @MaxWeight = Q.MaxWeight
            FROM dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            WHERE Q.Id = @QuestionId;

            SELECT @IsArithMetic = ISNULL(Q.AllowArithmeticOperation, 0)
            FROM dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            WHERE Q.Id = @QuestionId;

            IF (@CreatedOn = NULL)
            BEGIN
                SET @CreatedOn = GETUTCDATE();
            END;
            IF (@QuestionTypeId = 26 AND @Detail <> '')
            BEGIN
                IF EXISTS
                (
                    SELECT Data
                    FROM dbo.Split(RTRIM(LTRIM(@Detail)), ',')
                    WHERE Data NOT IN (
                                          SELECT Name
                                          FROM dbo.SeenClientOptions WITH (NOLOCK)
                                          WHERE QuestionId = @QuestionId
                                                AND IsDeleted = 0
                                      )
                )
                BEGIN
                    INSERT INTO dbo.SeenClientOptions
                    (
                        QuestionId,
                        Position,
                        Name,
                        Value,
                        DefaultValue,
                        [Weight],
                        Point,
                        QAEnd,
                        CreatedOn,
                        CreatedBy,
                        IsDeleted
                    )
                    SELECT @QuestionId,        -- QuestionId - bigint
                           0,                  -- Position - int
                           RTRIM(LTRIM(Data)), -- Name - nvarchar(255)
                           RTRIM(LTRIM(Data)), -- Value - nvarchar(max)
                           0,                  -- DefaultValue - bit
                           0,                  -- Weight - decimal
                           0,                  -- Point - decimal
                           0,                  -- QAEnd - bit
                           GETUTCDATE(),       -- CreatedOn - datetime
                           @AppUserId,         -- CreatedBy - bigint
                           0                   -- IsDeleted - bit
                    FROM dbo.Split(RTRIM(LTRIM(@Detail)), ',')
                    WHERE Data NOT IN (
                                          SELECT Name
                                          FROM dbo.SeenClientOptions WITH (NOLOCK)
                                          WHERE QuestionId = @QuestionId
                                                AND IsDeleted = 0
                                      )
                          AND Data != '';
                    UPDATE dbo.SeenClientQuestions
                    SET UpdatedOn = GETUTCDATE()
                    WHERE Id = @QuestionId;
                END;
            END;

            IF (
                   @QuestionTypeId = 5
                   OR @QuestionTypeId = 6
                   OR @QuestionTypeId = 18
                   OR @QuestionTypeId = 21
               )
               AND @Detail <> ''
            BEGIN
                SELECT @OptionId = COALESCE(@OptionId + ',', '') + CONVERT(NVARCHAR(50), Id)
                FROM dbo.SeenClientOptions WITH (NOLOCK)
                WHERE Name IN (
                                  SELECT DISTINCT Data FROM dbo.Split(@Detail, ',')
                              )
                      AND QuestionId = @QuestionId
                ORDER BY Position;
            END;
            ELSE IF (@QuestionTypeId = 1)
                    AND @Detail <> ''
            BEGIN
                SELECT @OptionId = Id
                FROM dbo.SeenClientOptions WITH (NOLOCK)
                WHERE Value = @Detail
                      AND QuestionId = @QuestionId;
            END;

            IF EXISTS
            (
                SELECT Id
                FROM dbo.SeenClientOptions WITH (NOLOCK)
                WHERE Id IN (
                                SELECT Data FROM dbo.Split(@OptionId, ',')
                            )
                      AND IsNA = 1
                      AND IsDeleted = 0
            )
            BEGIN
                SET @IsNA = 1;
            END;

            IF @QuestionTypeId = 19
               AND (
                       @Detail = ''
                       OR @Detail IS NULL
                   )
               AND @IsArithMetic = 0
            BEGIN
                SET @Detail = N'0';
            END;

            IF @QuestionTypeId = 7
               OR @QuestionTypeId = 14
               OR @QuestionTypeId = 15
            BEGIN
                DECLARE @YesNoWeight DECIMAL(18, 2);
                SELECT @YesNoWeight = CASE
                                          WHEN @Detail = 'Yes'
                                               OR @Detail LIKE 'Yes,%' THEN
                                              Q.[WeightForYes]
                                          WHEN @Detail = 'No'
                                               OR @Detail LIKE 'No,%' THEN
                                              Q.WeightForNo
                                          ELSE
                                              0
                                      END
                FROM dbo.SeenClientQuestions AS Q WITH (NOLOCK)
                WHERE Q.Id = @QuestionId;

                SET @FinalWeight = @YesNoWeight;
            END;
            ELSE IF (
                        @QuestionTypeId = 5
                        OR @QuestionTypeId = 6
                        OR @QuestionTypeId = 18
                        OR @QuestionTypeId = 21
                    )
                    AND @Detail <> ''
            BEGIN
                SELECT @FinalWeight = SUM(O.Weight)
                FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@OptionId, ',') ) AS R
                        ON O.Id = R.Data
                WHERE QuestionId = @QuestionId;
            END;
            ELSE IF (@QuestionTypeId = 1)
                    AND @Detail <> ''
            BEGIN
                SELECT @FinalWeight = SUM(O.Weight)
                FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
                WHERE QuestionId = @QuestionId
                      AND O.Value = @Detail;
            END;
            ELSE IF (@QuestionTypeId = 2)
                    AND @Detail <> ''
            BEGIN
                SET @FinalWeight = @Detail;
            END;

            IF @MaxWeight > 0
            BEGIN
                SET @QPI = ISNULL(@FinalWeight, 0) * 100.00 / @MaxWeight;
                IF (ISNULL(@Detail, '') != '')
                BEGIN
                    IF (@MaxWeight >= @QPI)
                    BEGIN
                        SET @IsQuestionPassed = 'Fail';
                    END;
                    ELSE
                    BEGIN
                        SET @IsQuestionPassed = 'Pass';
                    END;
                END;
            END;

            INSERT INTO dbo.[SeenClientAnswers]
            (
                [SeenClientAnswerMasterId],
                [SeenClientAnswerChildId],
                [QuestionId],
                [OptionId],
                [QuestionTypeId],
                [Detail],
                [Weight],
                [QPI],
                [CreatedOn],
                [CreatedBy],
                [IsDeleted],
                [RepeatCount],
                [RepetitiveGroupId],
                [RepetitiveGroupName],
                [IsNA],
                [IsQuestionPassed]
            )
            VALUES
            (@SeenClientAnswerMasterId,
             @SeenClientAnswerChildId,
             @QuestionId,
             @OptionId,
             @QuestionTypeId,
             @Detail,
             ISNULL(@FinalWeight, 0),
             @QPI,
             @CreatedOn,
             @AppUserId,
             0  ,
             @RepeatCount,
             @RepetitiveGroupId,
             @RepetitiveGroupName,
             @IsNA,
             @IsQuestionPassed
            );

            IF @QuestionTypeId = 11
            BEGIN
                IF @SeenClientAnswerChildId IS NULL
                    UPDATE dbo.SeenClientAnswerMaster
                    SET SenderCellNo = @Detail
                    WHERE Id = @SeenClientAnswerMasterId;
                ELSE
                    UPDATE dbo.SeenClientAnswerChild
                    SET SenderCellNo = @Detail
                    WHERE Id = @SeenClientAnswerChildId;
            END;
            SET @Counter = @Counter + 1;
            CONTINUE;

        END;
        DECLARE @ReturnChildId BIGINT = 0;
        -- New added to resolve copy capture case
        DECLARE @ContactMasterId BIGINT,
                @EmailDetail NVARCHAR(MAX),
                @MobileDetail NVARCHAR(MAX);

        SELECT @ContactMasterId = ContactMasterId
        FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
        WHERE Id = @SeenClientAnswerMasterId;

        IF @ContactMasterId IS NOT NULL
        BEGIN
            SELECT sq.ContactQuestionId,
                   @SeenClientAnswerMasterId AS SeenClientAnswerMasterId,
                   c.Detail,
                   sq.Id
            INTO #temp
            FROM dbo.SeenClientQuestions sq WITH (NOLOCK)
                INNER JOIN dbo.ContactDetails c WITH (NOLOCK)
                    ON c.ContactQuestionId = sq.ContactQuestionId
                       AND ContactMasterId = @ContactMasterId
            WHERE sq.Id IN (
                               SELECT DISTINCT
                                   QuestionId
                               FROM dbo.SeenClientAnswers WITH (NOLOCK)
                               WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                           )
                  AND c.Detail LIKE ''
            ORDER BY sq.Id;

            UPDATE t
            SET t.Detail = s.Detail
            FROM #temp t
                INNER JOIN dbo.SeenClientAnswers s WITH (NOLOCK)
                    ON s.QuestionId = t.Id
                       AND s.SeenClientAnswerMasterId = @SeenClientAnswerMasterId;


            --UPDATE s
            --SET s.Detail = t.Detail
            --FROM #temp t
            --    INNER JOIN dbo.SeenClientAnswers s WITH (NOLOCK)
            --        ON s.QuestionId = t.Id
            --           AND s.SeenClientAnswerMasterId = @SeenClientAnswerMasterId;

            UPDATE C
            SET C.Detail = t.Detail
            FROM #temp t
                INNER JOIN dbo.ContactDetails C
                    ON C.ContactQuestionId = t.ContactQuestionId
                       AND C.ContactMasterId = @ContactMasterId;
        END;
        ELSE
        BEGIN
            DECLARE @Contact BIGINT = 0;

            SELECT @Contact = CD.ContactMasterId
            FROM dbo.AppUser AP
                INNER JOIN dbo.ContactDetails CD
                    ON CD.Detail = AP.Email
                       AND ISNULL(CD.IsDeleted, 0) = 0
                       AND AP.Id = @AppUserId
                       AND CD.QuestionTypeId = 10
                INNER JOIN dbo.ContactMaster CM
                    ON CM.Id = CD.ContactMasterId
                       AND AP.GroupId = CM.GroupId
                       AND ISNULL(CM.IsDeleted, 0) = 0;

            SELECT @ReturnChildId = Id
            FROM dbo.SeenClientAnswerChild
            WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                  AND ContactMasterId = @Contact
                  AND ISNULL(IsDeleted, 0) = 0
            ORDER BY Id DESC;
        END;
        SELECT @ReturnChildId;
    --end 
    --SELECT 1 AS Id;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.InsertSeenClientAnswers_New',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId, 0),
         N'',
         GETUTCDATE(),
         ISNULL(@AppUserId, 0)
        );
    END CATCH;
    SET NOCOUNT OFF;
END;
