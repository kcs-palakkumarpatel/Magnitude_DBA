
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	09-June-2017
-- Description:	InsertOrUpdateSeenClientAnswers
-- Call SP    :		dbo.UpdateSeenClientAnswers
-- =============================================
/*
Drop procedure UpdateSeenClientAnswers
*/
CREATE PROCEDURE  [dbo].[UpdateSeenClientAnswers]
    @SeenclintAnswerlist XML
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @TempTable TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        SeenClientAnswerMasterId VARCHAR(100),
        SeenClientAnswerChildId VARCHAR(100),
        QuestionId VARCHAR(100),
        QuestionTypeId VARCHAR(100),
        Detail NVARCHAR(MAX),
        RepeatCount VARCHAR(100),
        RepetitiveGroupId VARCHAR(100),
        RepetitiveGroupName VARCHAR(100),
        AppUserId VARCHAR(100),
        CreatedOn DateTime
    );

    INSERT INTO @TempTable
    (
        SeenClientAnswerMasterId,
        SeenClientAnswerChildId,
        QuestionId,
        QuestionTypeId,
        Detail,
        RepeatCount,
        RepetitiveGroupId,
        RepetitiveGroupName,
        AppUserId,
        CreatedOn
    )
    SELECT SeenClientAnswerMasterId = XTbl.XCol.value('(answerMasterId)[1]', 'varchar(25)'),
           SeenClientAnswerChildId = XTbl.XCol.value('(SeenClientAnswerChildId)[1]', 'varchar(100)'),
           QuestionId = XTbl.XCol.value('(lgQuestionId)[1]', 'varchar(100)'),
           QuestionTypeId = XTbl.XCol.value('(inQuestionTypeId)[1]', 'varchar(100)'),
           Detail = XTbl.XCol.value('(strDetail)[1]', 'NVARCHAR(MAX)'),
           RepeatCount = XTbl.XCol.value('(RepeatCount)[1]', 'varchar(100)'),
           RepetitiveGroupId = XTbl.XCol.value('(RepetitiveGroupId)[1]', 'varchar(100)'),
           RepetitiveGroupName = XTbl.XCol.value('(RepetitiveGroupName)[1]', 'varchar(100)'),
           AppUserId = XTbl.XCol.value('(lgAppUserId)[1]', 'varchar(100)'),
           CreatedOn = XTbl.XCol.value('(CreatedOn)[1]', 'DateTime')
    FROM @SeenclintAnswerlist.nodes('/ClsAnswers/row') AS XTbl(XCol);
    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @TempTable
    );
    WHILE (@Counter <= @TotalCount)
    BEGIN
        DECLARE @Id BIGINT;
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
        SELECT @SeenClientAnswerMasterId = SeenClientAnswerMasterId,
               @SeenClientAnswerChildId = SeenClientAnswerChildId,
               @QuestionId = QuestionId,
               @Detail = Detail,
               @AppUserId = AppUserId,
               @QuestionTypeId = QuestionTypeId,
               @RepeatCount = RepeatCount,
               @RepetitiveGroupId = RepetitiveGroupId,
               @RepetitiveGroupName = RepetitiveGroupName,
               @CreatedOn = CreatedOn
        FROM @TempTable
        WHERE Id = @Counter;
        DECLARE @OptionId NVARCHAR(MAX) = NULL,
                @FinalWeight DECIMAL(18, 2) = 0,
                @QPI DECIMAL(18, 2) = 0,
                @MaxWeight DECIMAL(18, 2) = 0;

        SELECT @MaxWeight = Q.MaxWeight
        FROM dbo.SeenClientQuestions AS Q
        WHERE Q.Id = @QuestionId;

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
            FROM dbo.SeenClientOptions
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
            FROM dbo.SeenClientOptions
            WHERE Value = @Detail
                  AND QuestionId = @QuestionId;
        END;

        IF @QuestionTypeId = 19
           AND (
                   @Detail = ''
                   OR @Detail IS NULL
               )
            SET @Detail = '0';

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
            FROM dbo.SeenClientQuestions AS Q
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
            FROM dbo.SeenClientOptions AS O
                INNER JOIN
                (SELECT Data FROM dbo.Split(@OptionId, ',') ) AS R
                    ON O.Id = R.Data
            WHERE QuestionId = @QuestionId;
        END;
        ELSE IF (@QuestionTypeId = 1)
                AND @Detail <> ''
        BEGIN
            SELECT @FinalWeight = SUM(O.Weight)
            FROM dbo.SeenClientOptions AS O
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
        END;

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
            [RepetitiveGroupName]
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
         GETUTCDATE(),
         @AppUserId,
         0  ,
         @RepeatCount,
         @RepetitiveGroupId,
         @RepetitiveGroupName
        );
        SET @Id = @SeenClientAnswerMasterId;
        SELECT ISNULL(@Id, 0) AS UpdatedID;
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;

    -- New added to resolve copy capture case
    DECLARE @ContactMasterId BIGINT,
            @EmailDetail NVARCHAR(MAX),
            @MobileDetail NVARCHAR(MAX);

    SELECT @ContactMasterId = ContactMasterId
    FROM dbo.SeenClientAnswerMaster
    WHERE Id = @SeenClientAnswerMasterId;

    IF @ContactMasterId IS NOT NULL
    BEGIN
        SELECT sq.ContactQuestionId,
               @SeenClientAnswerMasterId AS SeenClientAnswerMasterId,
               c.Detail,
               sq.Id
        INTO #temp
        FROM dbo.SeenClientQuestions sq
            INNER JOIN dbo.ContactDetails c
                ON c.ContactQuestionId = sq.ContactQuestionId
                   AND ContactMasterId = @ContactMasterId
        WHERE sq.Id IN (
                           SELECT QuestionId
                           FROM dbo.SeenClientAnswers
                           WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                       )
        ORDER BY sq.Id;

        UPDATE s
        SET s.Detail = t.Detail
        FROM #temp t
            INNER JOIN dbo.SeenClientAnswers s
                ON s.QuestionId = t.Id
                   AND s.SeenClientAnswerMasterId = @SeenClientAnswerMasterId;
    END;
    --end 
    SELECT ISNULL(@Id, 0) AS UpdatedID;
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
         'dbo.UpdateSeenClientAnswers',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @Id,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
