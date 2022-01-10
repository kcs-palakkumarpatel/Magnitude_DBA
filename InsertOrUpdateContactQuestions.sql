-- =============================================
-- Author:		<Author,,GD>
-- Create date:		03-Mar-2017
-- Description:	<Description,,InsertOrUpdateContactQuestions>
-- Call SP    :	InsertOrUpdateContactQuestions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactQuestions]
    @Id BIGINT,
    @ContactId BIGINT,
    @Position INT,
    @QuestionTypeId INT,
    @QuestionTitle NVARCHAR(250),
    @ShortName NVARCHAR(50),
    @Required BIT,
    @IsDisplayInSummary BIT,
    @IsDisplayInDetail BIT,
    @MaxLength INT,
    @Hint NVARCHAR(100),
    @EscalationRegex INT,
    @KeyName NVARCHAR(100),
    @GroupId NVARCHAR(100),
    @OptionsDisplayType NVARCHAR(10),
    @IsTitleBold BIT,
    @IsTitleItalic BIT,
    @IsTitleUnderline BIT,
    @TitleTextColor NVARCHAR(10),
    @TableGroupName NVARCHAR(50),
    @Margin INT,
    @FontSize INT,
    @ImagePath NVARCHAR(50),
    @IsGroupField BIT,
    @UserId BIGINT,
    @PageId BIGINT,
    @IsCommentCompulsory BIT,
    @AllowDecimal BIT
AS
BEGIN
    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[ContactQuestions]
        (
            [ContactId],
            [Position],
            [QuestionTypeId],
            [QuestionTitle],
            [ShortName],
            [Required],
            [IsDisplayInSummary],
            [IsDisplayInDetail],
            [MaxLength],
            [Hint],
            [EscalationRegex],
            [KeyName],
            [GroupId],
            [OptionsDisplayType],
            [IsTitleBold],
            [IsTitleItalic],
            [IsTitleUnderline],
            [TitleTextColor],
            [TableGroupName],
            [Margin],
            [FontSize],
            [ImagePath],
            [IsGroupField],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [IsCommentCompulsory],
            IsDecimal
        )
        VALUES
        (@ContactId, @Position, @QuestionTypeId, @QuestionTitle, @ShortName, @Required, @IsDisplayInSummary,
         @IsDisplayInDetail, @MaxLength, @Hint, @EscalationRegex, @KeyName, @GroupId, @OptionsDisplayType,
         @IsTitleBold, @IsTitleItalic, @IsTitleUnderline, @TitleTextColor, @TableGroupName, @Margin, @FontSize,
         @ImagePath, @IsGroupField, GETUTCDATE(), @UserId, 0, @IsCommentCompulsory, @AllowDecimal);
        SELECT @Id = SCOPE_IDENTITY();
        UPDATE dbo.ContactQuestions
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
        (@UserId, @PageId, 'Insert record in table ContactQuestions', 'ContactQuestions', @Id, GETUTCDATE(), @UserId, 0);
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
            FROM dbo.ContactQuestions
            WHERE Id = @Id;
        END;

        UPDATE dbo.[ContactQuestions]
        SET --[ContactId] = @ContactId ,
            --[Position] = @Position ,
            --[QuestionTypeId] = @QuestionTypeId ,
            [QuestionTitle] = @QuestionTitle,
            [ShortName] = @ShortName,
            [Required] = @Required,
            [IsDisplayInSummary] = @IsDisplayInSummary,
            [IsDisplayInDetail] = @IsDisplayInDetail,
            [MaxLength] = @MaxLength,
            --[Hint] = @Hint ,
            [EscalationRegex] = @EscalationRegex,
            --[KeyName] = @KeyName ,
            --[GroupId] = @GroupId ,
            [OptionsDisplayType] = @OptionsDisplayType,
            [IsGroupField] = @IsGroupField,
            [IsTitleBold] = @IsTitleBold,
            [IsTitleItalic] = @IsTitleItalic,
            [IsTitleUnderline] = @IsTitleUnderline,
            [TitleTextColor] = @TitleTextColor,
            [TableGroupName] = @TableGroupName,
            [Margin] = @Margin,
            FontSize = @FontSize,
            ImagePath = @ImagePath,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            [IsCommentCompulsory] = @IsCommentCompulsory,
            [IsDecimal] = @AllowDecimal
        WHERE [Id] = @Id;

        UPDATE dbo.Contact
        SET UpdatedOn = GETUTCDATE()
        WHERE Id IN
              (
                  SELECT ContactId FROM dbo.ContactQuestions WHERE Id = @Id
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
        (@UserId, @PageId, 'Update record in table ContactQuestions', 'ContactQuestions', @Id, GETUTCDATE(), @UserId, 0);
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;


