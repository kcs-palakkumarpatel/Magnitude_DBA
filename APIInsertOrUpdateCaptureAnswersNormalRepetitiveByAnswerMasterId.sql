
-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Insert Or Update Capture Answers  Table for Web API Using AnswerMasterId
-- Call:					dbo.APIInsertOrUpdateCaptureAnswersByAnswerMasterId 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateCaptureAnswersNormalRepetitiveByAnswerMasterId]
(
    @CaptureAnswerMasterId BIGINT,
    @CaptureAnswerChildId BIGINT,
    @QuestionId BIGINT = 0,
    @QuestionTypeId BIGINT = 0,
    @Answer NVARCHAR(2000) = NULL,
    @AppUserId BIGINT,
    @CreateDate DATETIME = NULL,
    @RepeatCount INT,
    @RepetitiveGroupId INT,
    @RepetitiveGroupName VARCHAR(100)
)
AS
BEGIN
SET NOCOUNT ON;
SET DEADLOCK_PRIORITY NORMAL
BEGIN TRY
    DECLARE @Id BIGINT;

    DECLARE @OptionId NVARCHAR(MAX) = NULL,
            @FinalWeight DECIMAL(18, 2) = 0,
            @QPI DECIMAL(18, 2) = 0,
            @MaxWeight DECIMAL(18, 2) = 0;

    SELECT @MaxWeight = Q.MaxWeight
    FROM dbo.SeenClientQuestions AS Q WITH (NOLOCK)
    WHERE Q.Id = @QuestionId;

    IF (
           @QuestionTypeId = 5
           OR @QuestionTypeId = 6
           OR @QuestionTypeId = 18
           OR @QuestionTypeId = 21
       )
       AND @Answer <> ''
    BEGIN
        SELECT @OptionId = COALESCE(@OptionId + ',', '') + CONVERT(NVARCHAR(50), Id)
        FROM dbo.SeenClientOptions WITH (NOLOCK)
        WHERE Name IN (
                          SELECT DISTINCT Data FROM dbo.Split(@Answer, ',')
                      )
              AND QuestionId = @QuestionId
        ORDER BY Position;
    END;
    ELSE IF (@QuestionTypeId = 1)
            AND @Answer <> ''
    BEGIN
        SELECT @OptionId = Id
        FROM dbo.SeenClientOptions
        WHERE Value = @Answer
              AND QuestionId = @QuestionId;
    END;

    IF @QuestionTypeId = 19
       AND (
               @Answer = ''
               OR @Answer IS NULL
           )
        SET @Answer = '0';

    IF @QuestionTypeId = 7
       OR @QuestionTypeId = 14
       OR @QuestionTypeId = 15
    BEGIN
        DECLARE @YesNoWeight DECIMAL(18, 2);
        SELECT @YesNoWeight = CASE
                                  WHEN @Answer = 'Yes'
                                       OR @Answer LIKE 'Yes,%' THEN
                                      Q.[WeightForYes]
                                  WHEN @Answer = 'No'
                                       OR @Answer LIKE 'No,%' THEN
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
            AND @Answer <> ''
    BEGIN
        SELECT @FinalWeight = SUM(O.Weight)
        FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
            INNER JOIN
            (SELECT Data FROM dbo.Split(@OptionId, ',') ) AS R
                ON O.Id = R.Data
        WHERE QuestionId = @QuestionId;
    END;
    ELSE IF (@QuestionTypeId = 1)
            AND @Answer <> ''
    BEGIN
        SELECT @FinalWeight = SUM(O.Weight)
        FROM dbo.SeenClientOptions AS O WITH (NOLOCK)
        WHERE QuestionId = @QuestionId
              AND O.Value = @Answer;
    END;
    ELSE IF (@QuestionTypeId = 2)
            AND @Answer <> ''
    BEGIN
        SET @FinalWeight = @Answer;
    END;

    IF @MaxWeight > 0
    BEGIN
        SET @QPI = ISNULL(@FinalWeight, 0) * 100.00 / @MaxWeight;
    END;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.SeenClientQuestions WITH (NOLOCK)
        WHERE Id = @QuestionId
              AND IsDeleted = 0
    )
    BEGIN
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
            [IsDisabled],
            [RepetitiveGroupId],
            [RepetitiveGroupName],
            [RepeatCount]
        )
        VALUES
        (@CaptureAnswerMasterId,
         @CaptureAnswerChildId,
         @QuestionId,
         @OptionId,
         @QuestionTypeId,
         @Answer,
         ISNULL(@FinalWeight, 0),
         @QPI,
         GETUTCDATE(),
         @AppUserId,
         0  ,
         0  ,
         @RepetitiveGroupId  ,
         @RepetitiveGroupName,
         @RepeatCount
        );
        SELECT @Id = SCOPE_IDENTITY();
    END;

    IF @QuestionTypeId = 11
    BEGIN
        IF @CaptureAnswerChildId IS NULL
            UPDATE dbo.SeenClientAnswerMaster
            SET SenderCellNo = @Answer
            WHERE Id = @CaptureAnswerMasterId;
        ELSE
            UPDATE dbo.SeenClientAnswerChild
            SET SenderCellNo = @Answer
            WHERE Id = @CaptureAnswerChildId;
    END;

    SELECT ISNULL(@Id, 0) AS InsertedId;
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
         'dbo.APIInsertOrUpdateCaptureAnswersNormalRepetitiveByAnswerMasterId',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @CaptureAnswerMasterId+','+
		@CaptureAnswerChildId+','+
		@QuestionId+','+
		@QuestionTypeId+','+
		@Answer+','+
		@AppUserId+','+
		@CreateDate+','+
		@RepeatCount+','+
		@RepetitiveGroupId+','+
		@RepetitiveGroupName,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
SET NOCOUNT OFF;
END;
