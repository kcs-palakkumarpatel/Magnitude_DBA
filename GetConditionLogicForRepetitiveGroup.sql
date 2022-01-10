
-- =============================================        
-- Author:  anant bhatt        
-- Create date: 26 Jun 2020           
--SP Call: [GetConditionLogicForRepetitiveGroup] 21789,0
CREATE PROCEDURE [dbo].[GetConditionLogicForRepetitiveGroup]
(
    @QuestionnaireId BIGINT,
    @RepetitiveGroupNo INT,
    @IsAND BIT
)
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Condition NVARCHAR(5),
            @ConditionText NVARCHAR(MAX) = '';
    IF @IsAND = 1
    BEGIN
        SET @Condition = '&&';
    END;
    ELSE
    BEGIN
        SET @Condition = '||';
    END;

    DECLARE @ConditionLogic AS TABLE
    (
        ID INT IDENTITY(1, 1),
        Condition NVARCHAR(MAX)
    );

    INSERT INTO @ConditionLogic
    (
        Condition
    )
    SELECT CONVERT(VARCHAR(20), ConditionQuestionId) + ' ' + CONVERT(NVARCHAR(5), O.Symbol) + ' ' + ''''
           + CONVERT(VARCHAR(MAX), AnswerText) + ''''
    FROM dbo.ConditionLogic CL WITH (NOLOCK)
        INNER JOIN dbo.Operation O WITH (NOLOCK)
            ON CL.OperationId = O.Id
               AND O.IsDeleted = 0
        INNER JOIN dbo.Questions Q WITH (NOLOCK)
            ON CL.ConditionQuestionId = Q.Id
               AND Q.IsActive = 1
    WHERE Q.QuestionnaireId = @QuestionnaireId
          AND CL.IsRoutingOnGroup = 1
          AND CL.ConditionRepetitiveGroupId = @RepetitiveGroupNo
          AND CL.IsAnd = @IsAND
          AND CL.IsDeleted = 0;

    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @ConditionLogic
    );

    WHILE (@Counter <= @TotalCount)
    BEGIN
        DECLARE @RowCondition NVARCHAR(MAX);

        SELECT @RowCondition = Condition
        FROM @ConditionLogic
        WHERE ID = @Counter;

        SET @ConditionText = @ConditionText + COALESCE(@RowCondition + CASE
                                                                           WHEN @Counter < @TotalCount THEN
                                                                               ' ' + @Condition + ' '
                                                                           ELSE
                                                                               ''
                                                                       END, '');

        SET @Counter = @Counter + 1;
        CONTINUE;
    END;
    SELECT @ConditionText AS [Condition];
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
         'dbo.GetConditionLogicForRepetitiveGroup',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionnaireId+','+@RepetitiveGroupNo+','+@IsAND,
         GETUTCDATE(),
         N''
        );
END CATCH
    SET NOCOUNT OFF;
END;
