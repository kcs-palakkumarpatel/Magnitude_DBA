
-- =============================================        
-- Author:  anant bhatt        
-- Create date: 26 Jun 2020           
--SP Call: [GetConditionLogicForRepetitiveGroup] 21789,0
CREATE PROCEDURE [dbo].[GetConditionLogicForRepetitiveGroup_111721]
(
    @QuestionnaireId BIGINT,
    @RepetitiveGroupNo INT,
    @IsAND BIT
)
AS
BEGIN
    SET NOCOUNT ON;
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
    SET NOCOUNT OFF;
END;
