
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	25-Apr-2017
-- Description:	Insert Feedback form/Mobi Fom Data
-- Call SP:			dbo.InsertAnswers 0,0,0,'',0,0
-- =============================================
CREATE PROCEDURE [dbo].[InsertAnswers_111721]
    @AnswerMasterId BIGINT,
    @QuestionId BIGINT,
    @QuestionTypeId BIGINT,
    @Detail NVARCHAR(MAX),
    @AppUserId BIGINT,
    @RepeatCount INT,
    @RepetitiveGroupId INT,
    @RepetitiveGroupName VARCHAR(100),
    @CreatedOn DATETIME
AS
BEGIN
    DECLARE @OptionId NVARCHAR(MAX) = NULL,
            @FinalWeight DECIMAL(18, 2) = 0,
            @QPI DECIMAL(18, 2) = 0,
            @MaxWeight DECIMAL(18, 2) = 0,
            @IsNA BIT = 0,
            @IsArithMetic BIT = 0;


    SELECT @MaxWeight = Q.MaxWeight
    FROM dbo.Questions AS Q
    WHERE Q.Id = @QuestionId;

    SELECT @IsArithMetic = ISNULL(Q.AllowArithmeticOperation, 0)
    FROM dbo.Questions AS Q
    WHERE Q.Id = @QuestionId;

    IF (@QuestionTypeId = 26 AND @Detail <> '')
    BEGIN
        IF EXISTS
        (
            SELECT Data
            FROM dbo.Split(RTRIM(LTRIM(@Detail)), ',')
            WHERE Data NOT IN (
                                  SELECT Name
                                  FROM dbo.Options
                                  WHERE QuestionId = @QuestionId
                                        AND IsDeleted = 0
                              )
        )
        BEGIN
            INSERT INTO dbo.Options
            (
                QuestionId,
                Position,
                Name,
                Value,
                DefaultValue,
                Weight,
                Point,
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
                   GETUTCDATE(),       -- CreatedOn - datetime
                   @AppUserId,         -- CreatedBy - bigint
                   0                   -- IsDeleted - bit
            FROM dbo.Split(RTRIM(LTRIM(@Detail)), ',')
            WHERE Data NOT IN (
                                  SELECT Name
                                  FROM dbo.Options
                                  WHERE QuestionId = @QuestionId
                                        AND IsDeleted = 0
                              )
                  AND Data != '';
            UPDATE dbo.Questions
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
        FROM dbo.Options
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
        FROM dbo.Options
        WHERE Value = @Detail
              AND QuestionId = @QuestionId;
    END;

    IF EXISTS
    (
        SELECT Id
        FROM dbo.Options
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
        SET @Detail = '0';
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
                              END,
               @MaxWeight = Q.MaxWeight
        FROM dbo.Questions AS Q
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
        FROM dbo.Options AS O
            INNER JOIN
            (SELECT Data FROM dbo.Split(@OptionId, ',') ) AS R
                ON O.Id = R.Data
        WHERE QuestionId = @QuestionId;
    END;
    ELSE IF (@QuestionTypeId = 1)
            AND @Detail <> ''
    BEGIN
        SELECT @FinalWeight = SUM(O.Weight)
        FROM dbo.Options AS O
        WHERE QuestionId = @QuestionId
              AND O.Value = @Detail;
    END;
    ELSE IF (@QuestionTypeId = 2)
            AND @Detail <> ''
    BEGIN
        SET @FinalWeight = @Detail;
    END;

    IF @QuestionTypeId = 11
       AND @AnswerMasterId > 0
    BEGIN
        UPDATE dbo.AnswerMaster
        SET SenderCellNo = @Detail
        WHERE Id = @AnswerMasterId;
    END;

    IF @MaxWeight > 0
    BEGIN
        SET @QPI = ISNULL(@FinalWeight, 0) * 100.00 / @MaxWeight;
    END;

    INSERT INTO dbo.Answers
    (
        AnswerMasterId,
        QuestionId,
        OptionId,
        QuestionTypeId,
        Detail,
        [Weight],
        [QPI],
        CreatedBy,
        RepeatCount,
        RepetitiveGroupId,
        RepetitiveGroupName,
        IsNA,
        CreatedOn
    )
    VALUES
    (@AnswerMasterId,
     @QuestionId,
     @OptionId,
     @QuestionTypeId,
     @Detail,
     ISNULL(@FinalWeight, 0),
     @QPI,
     @AppUserId,
     @RepeatCount,
     @RepetitiveGroupId,
     @RepetitiveGroupName,
     @IsNA,
     @CreatedOn
    );

    SELECT ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0) AS InsertedId;
END;
