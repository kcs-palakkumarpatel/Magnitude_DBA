-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	24-Apr-2017
-- Description:	Get all active questions by questionnaire id for mobi form
--SP call :[GetConditionLogicRepetitiveBox] 22457,0,1
-- =============================================

CREATE PROCEDURE [dbo].[GetConditionLogicRepetitiveBox]
(
    @QuestionId BIGINT,
    @IsAND BIT,
	@groupId BIGINT
)
AS
BEGIN

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
    FROM dbo.ConditionLogic CL
        INNER JOIN dbo.Operation O
            ON CL.OperationId = O.Id
               AND O.IsDeleted = 0
		INNER JOIN dbo.Questions Q 
		   ON CL.ConditionQuestionId = Q.Id
		AND Q.IsActive = 1
    WHERE CL.QuestionId = @QuestionId
          AND CL.IsAnd = @IsAND
          AND CL.IsDeleted = 0
		  AND CL.IsRoutingonGroup =1
		--  AND Q.QuestionsGroupNo = @groupId
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
END;
