-- =============================================
-- Author:			bhavik patel
-- Create date:		12-03-21
-- Description:	<Description,,InsertOrUpdateQuestionsWithOutput>
-- Call SP    :	InsertOrUpdateQuestions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateQuestionsWithoutput]
(
    @Id BIGINT,
    @QuestionnaireId BIGINT,
    @Position INT,
    @QuestionTypeId INT,
    @QuestionTitle NVARCHAR(MAX),
    @ShortName NVARCHAR(MAX),
    @IsActive BIT,
    @Required BIT,
    @IsForReminder BIT = 0,
    @IsRepetitive BIT,
    @IsDisplayInSummary BIT,
    @IsDisplayInDetail BIT,
    @MaxLength INT,
    @Hint NVARCHAR(MAX),
    @EscalationRegex INT,
    @OptionsDisplayType NVARCHAR(10),
    @SeenClientQuestionIdRef BIGINT,
    @IsTitleBold BIT,
    @IsTitleItalic BIT,
    @IsTitleUnderline BIT,
    @TitleTextColor NVARCHAR(10),
    @TableGroupName NVARCHAR(50),
    @Margin INT,
    @FontSize INT,
    @ImagePath NVARCHAR(50),
    @Weight INT,
    @WeightForYes INT,
    @WeightForNo INT,
    @UserId BIGINT,
    @PageId BIGINT,
    @EscalationValue BIGINT,
    @DisplayInGraphs BIT,
    @DisplayInTableView BIT,
    @IsCommentCompulsory BIT,
    @MultipleRoutingValue BIGINT,
    @IsAnonymous BIT,
    @ContactQuestionIdRef BIGINT,
    @AllowDecimal BIT,
    @QuestionsGroupNo INT,
    @QuestionsGroupName VARCHAR(100),
    @IsSignature BIT,
    @ImageHeight NVARCHAR(100),
    @ImageWidth NVARCHAR(100),
    @ImageAlign NVARCHAR(100),
    @CalculationOptionId INT,
    @SummarayOptionId INT,
    @DefaultQuestion BIT,
    @IsRoutingOnGroup BIT = 0,
    @IsRequireHTTPHeader BIT = 0,
    @IsValidateUsingQR BIT = 0,
    @blIsSingleSelect BIT = 0,
    @blIsArithmeticOperator BIT = 0,	
    @ReturnValue BIGINT OUTPUT
)
AS
BEGIN

    IF (@QuestionTypeId NOT IN ( 1, 5, 6, 7, 18, 21 ))
    BEGIN
        SET @DisplayInGraphs = 0;
        SET @DisplayInTableView = 0;
    END;
    IF (@QuestionTypeId = 1)
    BEGIN
        SET @DisplayInTableView = 0;
    END;
    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[Questions]
        (
            [QuestionnaireId],
            [Position],
            [QuestionTypeId],
            [QuestionTitle],
            [ShortName],
            [IsActive],
            [Required],
            [IsForReminder],
            [IsDisplayInSummary],
            [IsDisplayInDetail],
            [MaxLength],
            [Hint],
            [EscalationRegex],
            [OptionsDisplayType],
            [SeenClientQuestionIdRef],
            [IsTitleBold],
            [IsTitleItalic],
            [IsTitleUnderline],
            [TitleTextColor],
            [TableGroupName],
            [Margin],
            [FontSize],
            [ImagePath],
            [Weight],
            [WeightForYes],
            [WeightForNo],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            EscalationValue,
            DisplayInGraphs,
            DisplayInTableView,
            IsCommentCompulsory,
            MultipleRoutingValue,
            IsAnonymous,
            ContactQuestionIdRef,
            IsDecimal,
            IsRepetitive,
            QuestionsGroupNo,
            QuestionsGroupName,
            IsSignature,
            ImageHeight,
            ImageWidth,
            ImageAlign,
            CalculationOptions,
            SummaryOption,
            IsDefaultDisplay,
            IsRoutingOnGroup,
            IsRequireHTTPHeader,
            IsValidateUsingQR,
            IsSingleSelect,
            AllowArithmeticOperation
        )
        VALUES
        (@QuestionnaireId,
         @Position,
         @QuestionTypeId,
         @QuestionTitle,
         @ShortName,
         @IsActive,
         @Required,
         @IsForReminder,
         @IsDisplayInSummary,
         @IsDisplayInDetail,
         @MaxLength,
         @Hint,
         @EscalationRegex,
         @OptionsDisplayType,
         @SeenClientQuestionIdRef,
         @IsTitleBold,
         @IsTitleItalic,
         @IsTitleUnderline,
         @TitleTextColor,
         @TableGroupName,
         @Margin,
         @FontSize,
         @ImagePath,
         @Weight,
         @WeightForYes,
         @WeightForNo,
         GETUTCDATE(),
         @UserId,
         0  ,
         @EscalationValue,
         @DisplayInGraphs,
         @DisplayInTableView,
         @IsCommentCompulsory,
         @MultipleRoutingValue,
         @IsAnonymous,
         @ContactQuestionIdRef,
         @AllowDecimal,
         @IsRepetitive,
         @QuestionsGroupNo,
         @QuestionsGroupName,
         @IsSignature,
         @ImageHeight,
         @ImageWidth,
         @ImageAlign,
         @CalculationOptionId,
         @SummarayOptionId,
         @DefaultQuestion,
         @IsRoutingOnGroup,
         @IsRequireHTTPHeader,
         @IsValidateUsingQR,
         @blIsSingleSelect,
         @blIsArithmeticOperator
        );
        SELECT @Id = SCOPE_IDENTITY();
        SET @ReturnValue = SCOPE_IDENTITY();
        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, @PageId, 'Insert record in table Questions', 'Questions', @Id, GETUTCDATE(), @UserId, 0);
    END;
    ELSE
    BEGIN
        IF (
               @ImagePath IS NULL
               OR @ImagePath = ''
           )
           AND @QuestionTypeId = 23
        BEGIN
            SELECT @ImagePath = ImagePath
            FROM dbo.Questions
            WHERE Id = @Id;
        END;

        UPDATE dbo.[Questions]
        SET --[QuestionnaireId] = @QuestionnaireId ,
            --[Position] = @Position ,
            --[QuestionTypeId] = @QuestionTypeId ,
            [QuestionTitle] = @QuestionTitle,
            [ShortName] = @ShortName,
            [IsActive] = @IsActive,
            [Required] = @Required,
            [IsDisplayInSummary] = @IsDisplayInSummary,
            [IsDisplayInDetail] = @IsDisplayInDetail,
                                          --[MaxLength] = @MaxLength ,
                                          --[Hint] = @Hint ,
            [EscalationRegex] = @EscalationRegex,
            [OptionsDisplayType] = @OptionsDisplayType,
                                          --[SeenClientQuestionIdRef] = @SeenClientQuestionIdRef ,
            [IsTitleBold] = @IsTitleBold,
            [IsTitleItalic] = @IsTitleItalic,
            [IsTitleUnderline] = @IsTitleUnderline,
            [TitleTextColor] = @TitleTextColor,
            [TableGroupName] = @TableGroupName,
            [Margin] = @Margin,
            FontSize = @FontSize,
            ImagePath = @ImagePath,
            [Weight] = @Weight,
            [WeightForYes] = @WeightForYes,
            [WeightForNo] = @WeightForNo,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            EscalationValue = @EscalationValue,
            DisplayInGraphs = @DisplayInGraphs,
            DisplayInTableView = @DisplayInTableView,
            [IsCommentCompulsory] = @IsCommentCompulsory,
            [MultipleRoutingValue] = @MultipleRoutingValue,
            [IsAnonymous] = @IsAnonymous, --,ContactQuestionIdRef = @ContactQuestionIdRef
            [IsDecimal] = @AllowDecimal,
            [IsRepetitive] = @IsRepetitive,
            QuestionsGroupNo = @QuestionsGroupNo,
            QuestionsGroupName = @QuestionsGroupName,
            IsSignature = @IsSignature,
            ImageHeight = @ImageHeight,
            ImageWidth = @ImageWidth,
            ImageAlign = @ImageAlign,
            IsDefaultDisplay = @DefaultQuestion,
            IsValidateUsingQR = @IsValidateUsingQR,
            IsSingleSelect = @blIsSingleSelect,
            AllowArithmeticOperation = @blIsArithmeticOperator,
			IsForReminder = @IsForReminder
        WHERE [Id] = @Id;

        SELECT @QuestionnaireId = QuestionnaireId,
               @QuestionTypeId = QuestionTypeId
        FROM dbo.[Questions]
        WHERE [Id] = @Id;

        UPDATE dbo.Questions
        SET QuestionsGroupName = @QuestionsGroupName
        WHERE QuestionnaireId = @QuestionnaireId
              AND QuestionsGroupNo = @QuestionsGroupNo;

        IF @QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18, 21 )
        BEGIN
            EXEC dbo.CalculateBestWeightForQuestionnaire @QuestionnaireId; -- bigint
        END;

        IF (@QuestionTypeId IN ( 1, 6, 21 ))
        BEGIN
            UPDATE dbo.Questions
            SET MaxWeight =
                (
                    SELECT CASE
                               WHEN QuestionTypeId IN ( 1, 6, 21 ) THEN
                                   MAX(O.Weight)
                               ELSE
                                   SUM(O.Weight)
                           END
                    FROM dbo.Options AS O
                    WHERE QuestionId = Questions.Id
                )
            WHERE QuestionnaireId = @QuestionnaireId
                  AND QuestionTypeId IN ( 1, 5, 6, 18, 21 )
                  AND IsDeleted = 0;

        END;

        IF @IsActive = 0
           OR @DefaultQuestion = 1
        BEGIN
            UPDATE dbo.ConditionLogic
            SET IsDeleted = 1,
                DeletedBy = @UserId,
                DeletedOn = GETUTCDATE()
            WHERE QuestionId = @Id;
        END;

        UPDATE dbo.Questionnaire
        SET UpdatedOn = GETUTCDATE()
        WHERE Id IN (
                        SELECT QuestionnaireId FROM dbo.Questions WHERE Id = @Id
                    );

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, @PageId, 'Update record in table Questions', 'Questions', @Id, GETUTCDATE(), @UserId, 0);
    END;
    SET @ReturnValue = @Id;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;


