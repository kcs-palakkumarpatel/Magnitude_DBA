-- Stored Procedure

-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,InsertOrUpdateSeenClientQuestions>
-- Call SP    :		dbo.InsertOrUpdateSeenClientQuestions
-- =============================================
CREATE PROC [dbo].[InsertOrUpdateSeenClientQuestions]
    @Id BIGINT,
    @SeenClientId BIGINT,
    @Position INT,
    @QuestionTypeId INT,
    @QuestionTitle NVARCHAR(2000),
    @ShortName NVARCHAR(2000),
    @IsActive BIT,
    @Required BIT,
    @IsRepetitive BIT,
    @IsDisplayInSummary BIT,
    @IsDisplayInDetail BIT,
    @MaxLength INT,
    @Hint NVARCHAR(100),
    @EscalationRegex INT,
    @KeyName NVARCHAR(100),
    @GroupId NVARCHAR(100),
    @OptionsDisplayType NVARCHAR(10),
    @ContactQuestionId BIGINT,
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
    @AllowDecimal BIT,
    @QuestionsGroupNo INT,
    @QuestionsGroupName VARCHAR(100),
    @IsSignature BIT,
    @ImageHeight NVARCHAR(100),
    @ImageWidth NVARCHAR(100),
    @ImageAlign NVARCHAR(100),
    @CalculationOptionId INT,
    @SummarayOptionId INT,
    @IsRequireHTTPHeader BIT = 0,
    @IsValidateUsingQR BIT = 0,
    @TenderQuestionType INT = 0,
    @IsSingleSelect BIT = 0,
    @AllowArithmeticOperation BIT = 0,
    @ArithMeticFormula NVARCHAR(MAX) = '',
    @IsSection BIT = 0,
    @SectionNo INT = 0,
    @SectionName VARCHAR(100) = ''
AS
BEGIN
    BEGIN TRY
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
            INSERT INTO dbo.[SeenClientQuestions]
            (
                [SeenClientId],
                [Position],
                [QuestionTypeId],
                [QuestionTitle],
                [ShortName],
                [IsActive],
                [Required],
                [IsDisplayInSummary],
                [IsRepetitive],
                [IsDisplayInDetail],
                [MaxLength],
                [Hint],
                [EscalationRegex],
                [KeyName],
                [GroupId],
                [OptionsDisplayType],
                [ContactQuestionId],
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
                IsDecimal,
                QuestionsGroupNo,
                QuestionsGroupName,
                IsSignature,
                ImageHeight,
                ImageWidth,
                ImageAlign,
                CalculationOptions,
                SummaryOption,
                IsRequireHTTPHeader,
                IsValidateUsingQR,
                TenderQuestionType,
                IsSingleSelect,
                AllowArithmeticOperation,
                IsSection,
                SectionNo,
                SectionName
            )
            VALUES
            (@SeenClientId, @Position, @QuestionTypeId, @QuestionTitle, @ShortName, @IsActive, @Required,
             @IsDisplayInSummary, @IsRepetitive, @IsDisplayInDetail, @MaxLength, @Hint, @EscalationRegex, @KeyName,
             @GroupId, @OptionsDisplayType, @ContactQuestionId, @IsTitleBold, @IsTitleItalic, @IsTitleUnderline,
             @TitleTextColor, @TableGroupName, @Margin, @FontSize, @ImagePath, @Weight, @WeightForYes, @WeightForNo,
             GETUTCDATE(), @UserId, 0, @EscalationValue, @DisplayInGraphs, @DisplayInTableView, @IsCommentCompulsory,
             @AllowDecimal, @QuestionsGroupNo, @QuestionsGroupName, @IsSignature, @ImageHeight, @ImageWidth,
             @ImageAlign, @CalculationOptionId, @SummarayOptionId, @IsRequireHTTPHeader, @IsValidateUsingQR,
             @TenderQuestionType, @IsSingleSelect, @AllowArithmeticOperation, @IsSection, @SectionNo, @SectionName);
            SELECT @Id = SCOPE_IDENTITY();
            UPDATE dbo.SeenClientQuestions
            SET KeyName = 'Key' + CONVERT(NVARCHAR(50), @Id),
                GroupId = 'Group' + CONVERT(NVARCHAR(50), @Id)
            WHERE Id = @Id;

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
            (@UserId, @PageId, 'Insert record in table SeenClientQuestions', 'SeenClientQuestions', @Id, GETUTCDATE(),
             @UserId, 0);
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
                FROM dbo.SeenClientQuestions
                WHERE Id = @Id;
            END;

            UPDATE dbo.[SeenClientQuestions]
            SET --[SeenClientId] = @SeenClientId ,
                --[Position] = @Position ,
                --[QuestionTypeId] = @QuestionTypeId ,
                [QuestionTitle] = @QuestionTitle,
                [ShortName] = @ShortName,
                [IsActive] = @IsActive,
                [Required] = @Required,
                [IsDisplayInSummary] = @IsDisplayInSummary,
                [IsRepetitive] = @IsRepetitive,
                [IsDisplayInDetail] = @IsDisplayInDetail,
                [MaxLength] = @MaxLength,
                --[Hint] = @Hint ,
                [EscalationRegex] = @EscalationRegex,
                --[KeyName] = @KeyName ,
                --[GroupId] = @GroupId ,
                [OptionsDisplayType] = @OptionsDisplayType,
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
                IsCommentCompulsory = @IsCommentCompulsory,
                IsDecimal = @AllowDecimal,
                QuestionsGroupNo = @QuestionsGroupNo,
                QuestionsGroupName = @QuestionsGroupName,
                IsSignature = @IsSignature,
                ImageHeight = @ImageHeight,
                ImageWidth = @ImageWidth,
                ImageAlign = @ImageAlign,
                IsValidateUsingQR = @IsValidateUsingQR,
                IsSingleSelect = @IsSingleSelect,
                AllowArithmeticOperation = @AllowArithmeticOperation,
                IsSection = @IsSection,
                SectionNo = @SectionNo,
                SectionName = @SectionName
            WHERE [Id] = @Id;

            SELECT @SeenClientId = SeenClientId,
                   @QuestionTypeId = QuestionTypeId
            FROM dbo.SeenClientQuestions
            WHERE [Id] = @Id;

            UPDATE dbo.SeenClientQuestions
            SET QuestionsGroupName = @QuestionsGroupName
            WHERE SeenClientId = @SeenClientId
                  AND QuestionsGroupNo = @QuestionsGroupNo;

            UPDATE dbo.SeenClientQuestions
            SET SectionName = @SectionName
            WHERE SeenClientId = @SeenClientId
                  AND SectionNo = @SectionNo;

            UPDATE dbo.SeenClient
            SET UpdatedOn = GETUTCDATE()
            WHERE Id IN
                  (
                      SELECT SeenClientId FROM dbo.SeenClientQuestions WHERE Id = @Id
                  );

            IF @QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18, 21 )
                EXEC dbo.CalculateBestWeightForSeenClient @SeenClientId = @SeenClientId; -- bigint

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
            (@UserId, @PageId, 'Update record in table SeenClientQuestions', 'SeenClientQuestions', @Id, GETUTCDATE(),
             @UserId, 0);

            IF (@QuestionTypeId IN ( 19 ))
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM QuestionCalculationItem
                    WHERE QuestionId = @Id
                          AND IsCapture = 1
                )
                BEGIN
                    UPDATE dbo.QuestionCalculationItem
                    SET Formula = @ArithMeticFormula,
                        UpdatedOn = GETUTCDATE(),
                        UpdatedBy = @UserId
                    WHERE QuestionId = @Id
                          AND IsCapture = 1;
                END;
                ELSE
                BEGIN
                    INSERT INTO dbo.QuestionCalculationItem
                    (
                        QuestionId,
                        Formula,
                        IsCapture,
                        CreatedOn,
                        CreatedBy,
                        UpdatedOn,
                        UpdatedBy,
                        IsDeleted,
                        DeletedOn,
                        DeletedBy,
                        IsRepetative
                    )
                    VALUES
                    (   @Id,                -- QuestionId - bigint
                        @ArithMeticFormula, -- Formula - varchar(150)
                        1,                  -- IsCapture - bit
                        GETDATE(),          -- CreatedOn - datetime
                        @UserId,            -- CreatedBy - bigint
                        NULL,               -- UpdatedOn - datetime
                        NULL,               -- UpdatedBy - bigint
                        0,                  -- IsDeleted - bit
                        NULL,               -- DeletedOn - datetime
                        NULL,               -- DeletedBy - bigint
                        @IsRepetitive);
                END;
            END;
        END;
        SELECT ISNULL(@Id, 0) AS InsertedId;


        UPDATE dbo.SeenClientQuestions
        SET IsSection = 1
        WHERE SeenClientId = @SeenClientId
              AND ISNULL(IsDeleted, 0) = 0
              AND QuestionsGroupNo IN
                  (
                      SELECT QuestionsGroupNo
                      FROM dbo.SeenClientQuestions
                      WHERE SeenClientId = @SeenClientId
                            AND IsRepetitive = 1
                            AND IsSection = 1
                  );


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
        (ERROR_LINE(), 'dbo.InsertOrUpdateSeenClientQuestions', N'Database', ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(), @UserId, N'', GETUTCDATE(), @UserId);
    END CATCH;
END;
