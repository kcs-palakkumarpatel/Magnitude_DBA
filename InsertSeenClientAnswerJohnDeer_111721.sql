
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- SP call:InsertSeenClientAnswerJohnDeer 893221,32135,1,6361,702829
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerJohnDeer_111721]
(
    @lgAnswerMasterId BIGINT, --this is SeenClientAnswerMasterId
    @lgToEstablishmentId BIGINT,
    @workflowMasterID BIGINT,
    @AppUserIds BIGINT,
    @FromRefernceId BIGINT    --this is Answermaster Id
)
AS
BEGIN
    DECLARE @SeenClientAnswerChildId BIGINT = 0;
    DECLARE @ContactMasterId BIGINT;
    DECLARE @IsSubmittedForGroup INT;
    DECLARE @ContactGroupId BIGINT = NULL;
    DECLARE @TempTable TABLE
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
        CreatedOn DateTime
    );
    DECLARE @TempContact TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        ContactMasterId BIGINT
    );

    SELECT @ContactMasterId = ContactMasterId,
           @IsSubmittedForGroup = IsSubmittedForGroup,
           @ContactGroupId = ContactGroupId
    FROM SeenClientAnswerMaster
    WHERE Id = @lgAnswerMasterId;
    IF (@IsSubmittedForGroup > 0)
    BEGIN
        PRINT '1';
        DECLARE @ContactMasterIdChild BIGINT;
        INSERT INTO @TempContact
        (
            ContactMasterId
        )
        SELECT DISTINCT
            Cm.Id
        FROM dbo.ContactGroupRelation AS CGR
            INNER JOIN dbo.ContactMaster AS Cm
                ON CGR.ContactMasterId = Cm.Id
            INNER JOIN dbo.ContactDetails AS Cd
                ON Cm.Id = Cd.ContactMasterId
            INNER JOIN dbo.ContactQuestions AS Cq
                ON Cd.ContactQuestionId = Cq.Id
        WHERE Cd.IsDeleted = 0
              AND CGR.IsDeleted = 0
              AND Cm.IsDeleted = 0
              AND Cq.IsDeleted = 0
              AND ContactGroupId = @ContactGroupId --AND IsDisplayInDetail = 1
        ORDER BY Cm.Id;

        DECLARE @CounterTbl INT;
        DECLARE @TotalCountTbl INT;
        SET @CounterTbl = 1;
        SET @TotalCountTbl =
        (
            SELECT COUNT(*) FROM @TempContact
        );
        WHILE (@CounterTbl <= @TotalCountTbl)
        BEGIN
            SELECT @ContactMasterIdChild = ContactMasterId
            FROM @TempContact
            WHERE Id = @CounterTbl;

            INSERT INTO dbo.SeenClientAnswerChild
            (
                SeenClientAnswerMasterId,
                ContactMasterId,
                SenderCellNo,
                DeletedOn,
                DeletedBy,
                IsDeleted
            )
            VALUES
            (   @lgAnswerMasterId,     -- SeenClientAnswerMasterId - bigint
                @ContactMasterIdChild, -- ContactMasterId - bigint
                N'',                   -- SenderCellNo - nvarchar(50)
                NULL,                  -- DeletedOn - datetime
                NULL,                  -- DeletedBy - bigint
                0                      -- IsDeleted - bit
            );

            SET @SeenClientAnswerChildId = SCOPE_IDENTITY();

            PRINT @SeenClientAnswerChildId;

            INSERT INTO @TempTable
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
            SELECT @lgAnswerMasterId AS AnswerMasterId,
                   @SeenClientAnswerChildId AS SeenClientAnswerChildId,
                   MWFC.ToQuestionId AS QuestionId,
                   A.QuestionTypeId,
                   Detail AS strDetail,
                   A.RepeatCount AS RepeatCount,
                   A.RepetitiveGroupId AS RepetitiveGroupId,
                   ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
                   @AppUserIds AS AppUserId,
                   GETUTCDATE() AS CreatedOn
            FROM Answers A
                LEFT JOIN MapingWorkFlowConfiguration MWFC
                    ON A.QuestionId = MWFC.FromQuestionId
            WHERE QuestionId IN (
                                    SELECT FromQuestionId
                                    FROM MapingWorkFlowConfiguration
                                    WHERE WorkFlowMasterId = @workflowMasterID
                                )
                  AND AnswerMasterId = @FromRefernceId
            UNION
            SELECT @lgAnswerMasterId AS AnswerMasterId,
                   0 AS SeenClientAnswerChildId,
                   ToQuestionId AS QuestionId,
                   MWF.ToQuestionTypeId,
                   '' AS strDetail,
                   0 AS RepeatCount,
                   0 AS RepetitiveGroupId,
                   '' AS RepetitiveGroupName,
                   @AppUserIds AS AppUserId,
                   GETUTCDATE() AS CreatedOn
            FROM dbo.MapingWorkFlowConfiguration AS MWF
            WHERE WorkFlowMasterId = @workflowMasterID
                  AND FromQuestionId = 0;

            SET @CounterTbl = @CounterTbl + 1;
            CONTINUE;
        END;
    END;
    ELSE
    BEGIN
        PRINT '2';
        INSERT INTO @TempTable
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
        SELECT @lgAnswerMasterId AS AnswerMasterId,
               0 AS SeenClientAnswerChildId,
               MWFC.ToQuestionId AS QuestionId,
               A.QuestionTypeId,
               Detail AS strDetail,
               A.RepeatCount AS RepeatCount,
               A.RepetitiveGroupId AS RepetitiveGroupId,
               ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
               @AppUserIds AS AppUserId,
               GETUTCDATE() AS CreatedOn
        FROM Answers A
            LEFT JOIN MapingWorkFlowConfiguration MWFC
                ON A.QuestionId = MWFC.FromQuestionId
        WHERE QuestionId IN (
                                SELECT FromQuestionId
                                FROM MapingWorkFlowConfiguration
                                WHERE WorkFlowMasterId = @workflowMasterID
                            )
              AND AnswerMasterId = @FromRefernceId
        UNION
        SELECT @lgAnswerMasterId AS AnswerMasterId,
               0 AS SeenClientAnswerChildId,
               ToQuestionId AS QuestionId,
               MWF.ToQuestionTypeId,
               '' AS strDetail,
               0 AS RepeatCount,
               0 AS RepetitiveGroupId,
               '' AS RepetitiveGroupName,
               @AppUserIds AS AppUserId,
               GETUTCDATE() AS CreatedOn
        FROM dbo.MapingWorkFlowConfiguration AS MWF
        WHERE WorkFlowMasterId = @workflowMasterID
              AND FromQuestionId = 0;
    END;
    DECLARE @Counter INT;
    DECLARE @TotalCount INT;
    SET @Counter = 1;

    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @TempTable
    );

    WHILE (@Counter <= @TotalCount)
    BEGIN
        DECLARE @SeenClientAnswerMasterId BIGINT;
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
        FROM @TempTable
        WHERE Id = @Counter;

        DECLARE @Id BIGINT;
        DECLARE @OptionId NVARCHAR(MAX) = NULL,
                @FinalWeight DECIMAL(18, 2) = 0,
                @QPI DECIMAL(18, 2) = 0,
                @MaxWeight DECIMAL(18, 2) = 0,
                @IsNA BIT = 0;

        SELECT @MaxWeight = Q.MaxWeight
        FROM dbo.SeenClientQuestions AS Q
        WHERE Q.Id = @QuestionId;

        IF (@CreatedOn = '')
        BEGIN
            SET @CreatedOn = GETUTCDATE();
        END;
        IF (@QuestionTypeId = 26)
            SET @Detail = @FromRefernceId;
        BEGIN
            IF EXISTS
            (
                SELECT Data
                FROM dbo.Split(@Detail, ',')
                WHERE Data NOT IN (
                                      SELECT Name
                                      FROM dbo.SeenClientOptions
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
                SELECT @QuestionId,  -- QuestionId - bigint
                       0,            -- Position - int
                       Data,         -- Name - nvarchar(255)
                       Data,         -- Value - nvarchar(max)
                       0,            -- DefaultValue - bit
                       0,            -- Weight - decimal
                       0,            -- Point - decimal
                       0,            -- QAEnd - bit
                       GETUTCDATE(), -- CreatedOn - datetime
                       @AppUserId,   -- CreatedBy - bigint
                       0             -- IsDeleted - bit
                FROM dbo.Split(@Detail, ',')
                WHERE Data NOT IN (
                                      SELECT Name
                                      FROM dbo.SeenClientOptions
                                      WHERE QuestionId = @QuestionId
                                            AND IsDeleted = 0
                                  )
                      AND Data != '';
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

        IF EXISTS
        (
            SELECT Id
            FROM dbo.SeenClientOptions
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
            [IsNA]
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
         @IsNA
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

    -- New added to resolve copy capture case
    DECLARE @EmailDetail NVARCHAR(MAX),
            @MobileDetail NVARCHAR(MAX);

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

END;
