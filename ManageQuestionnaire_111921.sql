
-- =============================================
-- Author:      Bhavik Patel
-- Create Date: 22-02-2021
-- Description: Insert Task by Import Excel file
-- SP call:[ManageQuestionnaire]
-- =============================================
--drop PROCEDURE [dbo].[ManageQuestionnaire]

CREATE PROCEDURE [dbo].[ManageQuestionnaire_111921]
(
    @SaveQuestionnaireTypeTableType SaveQuestionnaireTypeTableType READONLY,
    @SaveQuestionnaireQuestionsTypeTableType SaveQuestionnaireQuestionsTypeTableType READONLY,
    @SaveQuestionsOptionsTypeTableType SaveQuestionsOptionsTypeTableType READONLY
)
AS
BEGIN

    IF OBJECT_ID('tempdb..#TempSaveQuestionnaire', 'U') IS NOT NULL
        DROP TABLE #TempSaveQuestionnaire;
    CREATE TABLE #TempSaveQuestionnaire
    (
        RowNumber INT NULL,
        lgId BIGINT,
        strQuestionnaireTitle NVARCHAR(MAX) NULL,
        strQuestionnaireType NVARCHAR(MAX) NULL,
        strDescription NVARCHAR(MAX) NULL,
        strQuestionnaireFormType NVARCHAR(MAX) NULL,
        strDeletedQuestionId NVARCHAR(1000) NULL,
        UserId BIGINT NULL,
        PageMaster BIGINT NULL,
        strCompareType NVARCHAR(MAX) NULL,
        dcFixedBenchMark DECIMAL(18, 2) NULL,
        strTestTime NVARCHAR(MAX) NULL,
        dtLastTestDate DATETIME NULL,
        lgEscalationValue BIGINT NULL,
        blIsMultipleRouting BIT NULL,
        lgControlStyleId BIGINT NULL
    );

    IF OBJECT_ID('tempdb..#TempQuestionOptions', 'U') IS NOT NULL
        DROP TABLE #TempQuestionOptions;
    CREATE TABLE #TempQuestionOptions
    (
        Id BIGINT,
        QuestionId BIGINT,
        Position INT,
        Name NVARCHAR(1000),
        Value NVARCHAR(1000),
        DefaultValue BIT,
        IsNA BIT,
        Weight DECIMAL(18, 2),
        Point DECIMAL(18, 2),
        UserId BIGINT,
        PageId BIGINT,
        OptionImagePath NVARCHAR(MAX),
        FromRef BIT,
        PreviousQuestionId BIGINT,
        IsHTTPHeader BIT
    );
    DECLARE @TOTALCount INT = 0;
    DECLARE @Counter INT = 1;
    DECLARE @ChecklgQuestionId INT;
    DECLARE @TableName NVARCHAR(20) = 'Questionnaire';
    DECLARE @FKID INT;
    DECLARE @currentQuestionId BIGINT = 0;

    SET @TOTALCount =
    (
        SELECT COUNT(*) FROM @SaveQuestionnaireQuestionsTypeTableType
    );

    IF OBJECT_ID('tempdb..#TempQuestions', 'U') IS NOT NULL
        DROP TABLE #TempQuestions;
    CREATE TABLE #TempQuestions
    (
        MainTablePKId INT,
        RowNumber INT,
        lgQuestionId BIGINT NULL,
        lgQuestionnaireId BIGINT NULL,
        inPosition INT NULL,
        inQuestionTypeId INT NULL,
        strQuestionTitle NVARCHAR(1000) NULL,
        strShortName NVARCHAR(1000) NULL,
        blIsActive BIT NULL,
        blRequired BIT NULL,
        blIsForReminder BIT NULL,
        HasRepetitive BIT NULL,
        blDisplayInSummary BIT NULL,
        blDisplayInDetail BIT NULL,
        inMaxLength INT NULL,
        strHint NVARCHAR(1000) NULL,
        inEscalationRegex INT NULL,
        strOptionDisplayType NVARCHAR(1000) NULL,
        lgSeenClientQuestionId BIGINT NULL,
        blIsTitleBold BIT NULL,
        blIsTitleItalic BIT NULL,
        blIsTitleUnderline BIT NULL,
        strTitleTextColor NVARCHAR(200) NULL,
        strTableGroupName NVARCHAR(200) NULL,
        inMargin INT NULL,
        inFontSize INT NULL,
        strImagePath NVARCHAR(MAX) NULL,
        Weight INT NULL,
        WeightForYes INT NULL,
        WeightForNo INT NULL,
        UserId INT NULL,
        Questionnaire BIGINT NULL,
        lgEscalationValue BIGINT NULL,
        blDisplayInGraphs BIT NULL,
        blDisplayInTableView BIT NULL,
        blIsCommentCompulsory BIT NULL,
        lgMultipleRoutingValue BIGINT NULL,
        blIsAnonymous BIT NULL,
        lgContactQuestionId BIGINT NULL,
        AllowDecimal BIT NULL,
        RepetitiveQuestionsGroupNo INT NULL,
        RepetitiveQuestionsGroupName NVARCHAR(MAX) NULL,
        blIsSignature BIT NULL,
        Imageheight NVARCHAR(100) NULL,
        Imagewidth NVARCHAR(100) NULL,
        Imagealign NVARCHAR(100) NULL,
        CalculationOptionId INT NULL,
        SummaryOptionId INT NULL,
        blDefaultQuestion BIT NULL,
        IsRoutingOnGroup BIT NULL,
        blIsHTTPHeader BIT NULL,
        blIsValidateUsingQR BIT NULL,
        CurrentQuestionOptions NVARCHAR(MAX) NULL,
        DeleteQuestions NVARCHAR(MAX) NULL,
        blIsSingleSelect BIT NULL,
        blIsArithmeticOperator BIT NULL
    );

    INSERT INTO #TempQuestions
    SELECT *
    FROM @SaveQuestionnaireQuestionsTypeTableType;

    --
    DECLARE @CurrentQuestionOptions NVARCHAR(MAX);
    DECLARE @DeleteQuestions NVARCHAR(MAX);
    --variable declaration
    DECLARE @Id BIGINT;
    DECLARE @QuestionnaireId BIGINT;
    DECLARE @Position INT;
    DECLARE @QuestionTypeId INT;
    DECLARE @QuestionTitle NVARCHAR(MAX);
    DECLARE @ShortName NVARCHAR(MAX);
    DECLARE @IsActive BIT;
    DECLARE @Required BIT;
    DECLARE @IsForReminder BIT;
    DECLARE @IsRepetitive BIT;
    DECLARE @IsDisplayInSummary BIT;
    DECLARE @IsDisplayInDetail BIT;
    DECLARE @MaxLength INT;
    DECLARE @Hint NVARCHAR(MAX);
    DECLARE @EscalationRegex INT;
    DECLARE @OptionsDisplayType NVARCHAR(10);
    DECLARE @SeenClientQuestionIdRef BIGINT;
    DECLARE @IsTitleBold BIT;
    DECLARE @IsTitleItalic BIT;
    DECLARE @IsTitleUnderline BIT;
    DECLARE @TitleTextColor NVARCHAR(10);
    DECLARE @TableGroupName NVARCHAR(50);
    DECLARE @Margin INT;
    DECLARE @FontSize INT;
    DECLARE @ImagePath NVARCHAR(50);
    DECLARE @Weight INT;
    DECLARE @WeightForYes INT;
    DECLARE @WeightForNo INT;
    DECLARE @UserId BIGINT;
    DECLARE @PageId BIGINT;
    DECLARE @EscalationValue BIGINT;
    DECLARE @DisplayInGraphs BIT;
    DECLARE @DisplayInTableView BIT;
    DECLARE @IsCommentCompulsory BIT;
    DECLARE @MultipleRoutingValue BIGINT;
    DECLARE @IsAnonymous BIT;
    DECLARE @ContactQuestionIdRef BIGINT;
    DECLARE @AllowDecimal BIT;
    DECLARE @QuestionsGroupNo INT;
    DECLARE @QuestionsGroupName VARCHAR(100);
    DECLARE @IsSignature BIT;
    DECLARE @ImageHeight NVARCHAR(100);
    DECLARE @ImageWidth NVARCHAR(100);
    DECLARE @ImageAlign NVARCHAR(100);
    DECLARE @CalculationOptionId INT;
    DECLARE @SummarayOptionId INT;
    DECLARE @DefaultQuestion BIT;
    DECLARE @IsRoutingOnGroup BIT = 0;
    DECLARE @IsRequireHTTPHeader BIT = 0;
    DECLARE @IsValidateUsingQR BIT = 0;
    DECLARE @blIsSingleSelect BIT = 0;
	DECLARE @blIsArithmeticOperator BIT = 0;
	
    --end delcare to insert in [InsertOrUpdateQuestions]
    --variable declaration

    --pptions variable
    DECLARE @optionId BIGINT;
    DECLARE @optionQuestionId BIGINT;
    DECLARE @OptionsPosition INT;
    DECLARE @Name NVARCHAR(1000);
    DECLARE @Value NVARCHAR(1000);
    DECLARE @DefaultValue BIT;
    DECLARE @IsNA BIT = 0;
    DECLARE @OptionWeight DECIMAL(18, 2);
    DECLARE @Point DECIMAL(18, 2);
    DECLARE @OptionUserId BIGINT;
    DECLARE @OptionPageId BIGINT;
    DECLARE @OptionImagePath [NVARCHAR](MAX);
    DECLARE @FromRef BIT = 0;
    DECLARE @PreviousQuestionId BIGINT;
    DECLARE @IsHTTPHeader BIT = 0;
    --options vaiables


    IF OBJECT_ID('tempdb..#TempQuestionsCommaIds', 'U') IS NOT NULL
        DROP TABLE #TempQuestionsCommaIds;
    CREATE TABLE #TempQuestionsCommaIds (Id NVARCHAR(MAX));

    DECLARE @lgQuestionnaireId BIGINT;
    --SET @lgQuestionnaireId = (select TOP 1 lgQuestionnaireId from #TempQuestions tmp)


    DECLARE @strDeleteQuestions NVARCHAR(MAX);
    SET @strDeleteQuestions =
    (
        SELECT TOP 1 DeleteQuestions FROM #TempQuestions tmp
    );

    DECLARE @strUserId BIGINT;
    SET @strUserId =
    (
        SELECT TOP 1 UserId FROM #TempQuestions tmp
    );

    DECLARE @strPageMaster BIGINT;
    SET @strPageMaster =
    (
        SELECT TOP 1 Questionnaire FROM #TempQuestions tmp
    );

    --DECLARE @lgQuestionnaireId BIGINT;

    INSERT INTO #TempSaveQuestionnaire
    SELECT *
    FROM @SaveQuestionnaireTypeTableType tmps;

    DECLARE @RowNumber INT;
    DECLARE @lgId BIGINT = (
                               SELECT lgId FROM #TempSaveQuestionnaire
                           );
    DECLARE @strQuestionnaireTitle NVARCHAR(MAX) = (
                                                       SELECT strQuestionnaireTitle FROM #TempSaveQuestionnaire
                                                   );
    DECLARE @strQuestionnaireType NVARCHAR(MAX) = (
                                                      SELECT strQuestionnaireType FROM #TempSaveQuestionnaire
                                                  );
    DECLARE @strDescription NVARCHAR(MAX) = (
                                                SELECT strDescription FROM #TempSaveQuestionnaire
                                            );
    DECLARE @strQuestionnaireFormType NVARCHAR(MAX) = (
                                                          SELECT strQuestionnaireFormType FROM #TempSaveQuestionnaire
                                                      );
    DECLARE @strDeletedQuestionId NVARCHAR(1000) = (
                                                       SELECT strDeletedQuestionId FROM #TempSaveQuestionnaire
                                                   );
    DECLARE @lgUserId BIGINT = (
                                   SELECT UserId FROM #TempSaveQuestionnaire
                               );
    DECLARE @PageMaster BIGINT = (
                                     SELECT PageMaster FROM #TempSaveQuestionnaire
                                 );
    DECLARE @strCompareType NVARCHAR(MAX) = (
                                                SELECT strCompareType FROM #TempSaveQuestionnaire
                                            );
    DECLARE @dcFixedBenchMark DECIMAL(18, 2) = (
                                                   SELECT dcFixedBenchMark FROM #TempSaveQuestionnaire
                                               );
    DECLARE @strTestTime NVARCHAR(MAX) = (
                                             SELECT strTestTime FROM #TempSaveQuestionnaire
                                         );
    DECLARE @dtLastTestDate DATETIME = (
                                           SELECT dtLastTestDate FROM #TempSaveQuestionnaire
                                       );
    DECLARE @lgEscalationValue BIGINT = (
                                            SELECT lgEscalationValue FROM #TempSaveQuestionnaire
                                        );
    DECLARE @blIsMultipleRouting BIT = (
                                           SELECT blIsMultipleRouting FROM #TempSaveQuestionnaire
                                       );
    DECLARE @lgControlStyleId BIGINT = (
                                           SELECT lgControlStyleId FROM #TempSaveQuestionnaire
                                       );


    EXEC [InsertOrUpdateQuestionnaireWithoutput] @lgId,
                                                 @strQuestionnaireTitle,
                                                 @strQuestionnaireType,
                                                 @strDescription,
                                                 @strQuestionnaireFormType,
                                                 @strDeletedQuestionId,
                                                 @lgUserId,
                                                 @PageMaster,
                                                 @strCompareType,
                                                 @dcFixedBenchMark,
                                                 @strTestTime,
                                                 @dtLastTestDate,
                                                 @lgEscalationValue,
                                                 @blIsMultipleRouting,
                                                 @lgControlStyleId,
                                                 @lgQuestionnaireId OUTPUT;

    IF @lgQuestionnaireId > 0
    BEGIN
        WHILE @Counter <= @TOTALCount
        BEGIN

            SET @ChecklgQuestionId =
            (
                SELECT lgQuestionId FROM #TempQuestions tmp WHERE RowNumber = @Counter
            );

            IF @ChecklgQuestionId = 0
            BEGIN

                SET @Id =
                (
                    SELECT lgQuestionId FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @QuestionnaireId = @lgQuestionnaireId; --(select lgQuestionnaireId from #TempQuestions  where RowNumber = @Counter);
                SET @Position =
                (
                    SELECT inPosition FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @QuestionTypeId =
                (
                    SELECT inQuestionTypeId FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @QuestionTitle =
                (
                    SELECT strQuestionTitle FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ShortName =
                (
                    SELECT strShortName FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsActive =
                (
                    SELECT blIsActive FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @Required =
                (
                    SELECT blRequired FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsForReminder =
                (
                    SELECT blIsForReminder FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsRepetitive =
                (
                    SELECT HasRepetitive FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsDisplayInSummary =
                (
                    SELECT blDisplayInSummary FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsDisplayInDetail =
                (
                    SELECT blDisplayInDetail FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @MaxLength =
                (
                    SELECT inMaxLength FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @Hint =
                (
                    SELECT strHint FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @EscalationRegex =
                (
                    SELECT inEscalationRegex FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @OptionsDisplayType =
                (
                    SELECT strOptionDisplayType FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @SeenClientQuestionIdRef =
                (
                    SELECT CASE
                               WHEN lgSeenClientQuestionId = 0 THEN
                                   NULL
                               ELSE
                                   lgSeenClientQuestionId
                           END AS SeenClientQuestionIdRef
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @IsTitleBold =
                (
                    SELECT blIsTitleBold FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsTitleItalic =
                (
                    SELECT blIsTitleItalic FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsTitleUnderline =
                (
                    SELECT blIsTitleUnderline FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @TitleTextColor =
                (
                    SELECT strTitleTextColor FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @TableGroupName =
                (
                    SELECT strTableGroupName FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @Margin =
                (
                    SELECT inMargin FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @FontSize =
                (
                    SELECT inFontSize FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ImagePath =
                (
                    SELECT strImagePath FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @Weight =
                (
                    SELECT Weight FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @WeightForYes =
                (
                    SELECT WeightForYes FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @WeightForNo =
                (
                    SELECT WeightForNo FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @UserId =
                (
                    SELECT UserId FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @PageId =
                (
                    SELECT Questionnaire FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @EscalationValue =
                (
                    SELECT lgEscalationValue FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @DisplayInGraphs =
                (
                    SELECT blDisplayInGraphs FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @DisplayInTableView =
                (
                    SELECT blDisplayInTableView FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsCommentCompulsory =
                (
                    SELECT blIsCommentCompulsory
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @MultipleRoutingValue =
                (
                    SELECT lgMultipleRoutingValue
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @IsAnonymous =
                (
                    SELECT blIsAnonymous FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ContactQuestionIdRef =
                (
                    SELECT CASE
                               WHEN lgContactQuestionId = 0 THEN
                                   NULL
                               WHEN lgContactQuestionId > 0 THEN
                                   lgContactQuestionId
                           END AS ContactQuestionIdRef
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @AllowDecimal =
                (
                    SELECT AllowDecimal FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @QuestionsGroupNo =
                (
                    SELECT RepetitiveQuestionsGroupNo
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @QuestionsGroupName =
                (
                    SELECT RepetitiveQuestionsGroupName
                    FROM #TempQuestions
                    WHERE RowNumber = @Counter
                );
                SET @IsSignature =
                (
                    SELECT blIsSignature FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ImageHeight =
                (
                    SELECT Imageheight FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ImageWidth =
                (
                    SELECT Imagewidth FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @ImageAlign =
                (
                    SELECT Imagealign FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @CalculationOptionId =
                (
                    SELECT CalculationOptionId FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @SummarayOptionId =
                (
                    SELECT SummaryOptionId FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @DefaultQuestion =
                (
                    SELECT blDefaultQuestion FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsRoutingOnGroup =
                (
                    SELECT IsRoutingOnGroup FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsRequireHTTPHeader =
                (
                    SELECT blIsHTTPHeader FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @IsValidateUsingQR =
                (
                    SELECT blIsValidateUsingQR FROM #TempQuestions WHERE RowNumber = @Counter
                );
                SET @blIsSingleSelect =
                (
                    SELECT blIsSingleSelect FROM #TempQuestions WHERE RowNumber = @Counter
                );
				SET @blIsArithmeticOperator=
				 (
                    SELECT blIsArithmeticOperator FROM #TempQuestions WHERE RowNumber = @Counter
                );
				

                --exec [InsertOrUpdateQuestions] 
                EXEC dbo.[InsertOrUpdateQuestionsWithoutput] @Id,
                                                             @QuestionnaireId,
                                                             @Position,
                                                             @QuestionTypeId,
                                                             @QuestionTitle,
                                                             @ShortName,
                                                             @IsActive,
                                                             @Required,
                                                             @IsForReminder,
                                                             @IsRepetitive,
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
                                                             @UserId,
                                                             @PageId,
                                                             @EscalationValue,
                                                             @DisplayInGraphs,
                                                             @DisplayInTableView,
                                                             @IsCommentCompulsory,
                                                             @MultipleRoutingValue,
                                                             @IsAnonymous,
                                                             @ContactQuestionIdRef,
                                                             @AllowDecimal,
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
															 @blIsArithmeticOperator,
                                                             @currentQuestionId OUTPUT;


                SET @FKID =
                (
                    SELECT MainTablePKId FROM #TempQuestions tmp WHERE RowNumber = @Counter
                );

                DECLARE @TotalOptions INT;
                DECLARE @OptionsCount INT;
                SET @TotalOptions =
                (
                    SELECT COUNT(*)
                    FROM @SaveQuestionsOptionsTypeTableType
                    WHERE MainTableFKId = @FKID
                );
                SET @OptionsCount = 1;
                WHILE @OptionsCount <= @TotalOptions
                BEGIN
                    SET @optionId =
                    (
                        SELECT Id
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @OptionsPosition =
                    (
                        SELECT Position
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @Name =
                    (
                        SELECT Name
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @Value =
                    (
                        SELECT Value
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @DefaultValue =
                    (
                        SELECT DefaultValue
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @IsNA =
                    (
                        SELECT IsNA
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @OptionWeight =
                    (
                        SELECT Weight
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @Point =
                    (
                        SELECT Point
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @OptionImagePath =
                    (
                        SELECT OptionImagePath
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @FromRef =
                    (
                        SELECT FromRef
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @PreviousQuestionId =
                    (
                        SELECT PreviousQuestionId
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @IsHTTPHeader =
                    (
                        SELECT IsHTTPHeader
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @OptionUserId =
                    (
                        SELECT UserId
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );
                    SET @OptionPageId =
                    (
                        SELECT PageId
                        FROM @SaveQuestionsOptionsTypeTableType
                        WHERE MainTableFKId = @FKID
                              AND RowNumber = @OptionsCount
                    );


                    IF @OptionWeight IS NULL
                    BEGIN
                        SET @OptionWeight = 0.00;
                    END;
                    EXEC [dbo].[InsertOrUpdateOptions] 0,
                                                       @currentQuestionId,
                                                       @OptionsPosition,
                                                       @Name,
                                                       @Value,
                                                       @DefaultValue,
                                                       @IsNA,
                                                       @OptionWeight,
                                                       @Point,
                                                       @OptionUserId,
                                                       @OptionPageId,
                                                       @OptionImagePath,
                                                       @FromRef,
                                                       @PreviousQuestionId,
                                                       @IsHTTPHeader;

                    --exec [dbo].[InsertOrUpdateOptions] 0,59971,1,'tttk1','tttk1',0,0,0.00,0.00,2,21,NULL,0,0,0

                    SET @OptionsCount = @OptionsCount + 1;
                    CONTINUE;
                END;

                --exec UpdatePositionForQuestions  @currentQuestionId,@TableName
                INSERT INTO #TempQuestionsCommaIds
                VALUES (@currentQuestionId);
            END;
            ELSE
            BEGIN
                IF @ChecklgQuestionId = 0
                BEGIN
                    INSERT INTO #TempQuestionsCommaIds
                    VALUES (@currentQuestionId);
                --exec UpdatePositionForQuestions  @currentQuestionId,@TableName
                END;
                ELSE
                BEGIN
                    --exec UpdatePositionForQuestions @ChecklgQuestionId,@TableName
                    INSERT INTO #TempQuestionsCommaIds
                    VALUES (@ChecklgQuestionId);
                END;
            END;
            SET @Counter = @Counter + 1;
            CONTINUE;

        END;
        --Start Update Posistion
        DECLARE @strCommasId NVARCHAR(MAX);
        SET @strCommasId =
        (
            SELECT STUFF(
                   (
                       SELECT ',' + Id FROM #TempQuestionsCommaIds E FOR XML PATH('')
                   ),
                   1,
                   1,
                   ''
                        ) AS listStr
        );
        EXEC UpdatePositionForQuestions @strCommasId, @TableName;
        --End Update Posistion

        ---Start CalculatebestWeight
        EXEC CalculateBestWeightForQuestionnaire @lgQuestionnaireId;
        ---End CalculatebestWeight

        ---Start Delete Questions
        IF @strDeleteQuestions <> ''
        BEGIN
            EXEC DeleteQuestions @strDeleteQuestions, @strUserId, @strPageMaster;
        END;
        ---End Delete Questions

        --Start ExportReportSettings
        EXEC ExportReportSetting @lgQuestionnaireId, 0;
    --End ExportReportSettings
    END;
    ELSE
    BEGIN
        SELECT 0 AS ReturnValue;
    END;
    SELECT @lgQuestionnaireId AS ReturnValue;
END;
