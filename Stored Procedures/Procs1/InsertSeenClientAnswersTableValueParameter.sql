
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Apr-2017
-- Description:	<Description,,InsertOrUpdateSeenClientAnswers>
-- Call SP    : dbo.InsertSeenClientAnswers '<ClsAnswers><row><Id>1</Id><lgAnswerMasterId>240515</lgAnswerMasterId><lgChildId>73138</lgChildId><lgQuestionId>0</lgQuestionId><inQuestionTypeId>10</inQuestionTypeId><strDetail></strDetail><RepeatCount>0</RepeatCount><RepetitiveGroupId>0</RepetitiveGroupId><RepetitiveGroupName></RepetitiveGroupName><lgAppUserId>2896</lgAppUserId></row><row><Id>2</Id><lgAnswerMasterId>240515</lgAnswerMasterId><lgChildId>73138</lgChildId><lgQuestionId>0</lgQuestionId><inQuestionTypeId>11</inQuestionTypeId><strDetail>447393448427</strDetail><RepeatCount>0</RepeatCount><RepetitiveGroupId>0</RepetitiveGroupId><RepetitiveGroupName></RepetitiveGroupName><lgAppUserId>2896</lgAppUserId></row><row><Id>3</Id><lgAnswerMasterId>240515</lgAnswerMasterId><lgChildId>73138</lgChildId><lgQuestionId>0</lgQuestionId><inQuestionTypeId>4</inQuestionTypeId><strDetail>test</strDetail><RepeatCount>0</RepeatCount><RepetitiveGroupId>0</RepetitiveGroupId><RepetitiveGroupName></RepetitiveGroupName><lgAppUserId>2896</lgAppUserId></row></ClsAnswers>'
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswersTableValueParameter] @SeenclintAnswerlist SeenclintAnswer READONLY
AS
BEGIN
SET DEADLOCK_PRIORITY NORMAL;
	
BEGIN TRY
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
        SELECT COUNT(*) FROM @TempTable
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
        IF (@QuestionTypeId = 26 AND @Detail <> '')
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
    SELECT 1 AS Id;
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
         'dbo.InsertSeenClientAnswersTableValueParameter',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         N'',
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
