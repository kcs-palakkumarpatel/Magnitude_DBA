-- =============================================
-- Author:		<Author,,Mittal>
-- Create date: <Create Date,,9, jan 2020>
-- Description:	<Description,, Get all type of data for dropdownbind>
-- Call SP:		GetQuestionnaireDataForDropDown 'en',2,1359,0
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireDataForDropDown]
    @language VARCHAR(5),
    @userId INT,
    @seenClientId BIGINT,
    @contactId BIGINT
AS
BEGIN
    DECLARE @AdminRole BIGINT,
            @UserRole BIGINT,
            @PageID BIGINT;
    DECLARE @Url NVARCHAR(150);

    -- GetAllQuestionTypeForDropDown
    SELECT Id,
           CASE @language
               WHEN 'en' THEN
                   QuestionTypeName
               ELSE
                   QuestionTypeName_es
           END AS QuestionTypeName
    FROM dbo.QuestionType
    WHERE IsDeleted = 0
    ORDER BY Position,
             Id;

    -- GetSeenClientAll
    SELECT TOP 1
        @AdminRole = Id
    FROM [dbo].[Role]
    WHERE RoleName = 'Admin';
    SELECT TOP 1
        @UserRole = RoleId
    FROM dbo.[User]
    WHERE Id = @userId;
    SELECT TOP 1
        @PageID = Id
    FROM dbo.Page
    WHERE PageName = 'SeenClient';
    IF @AdminRole = @UserRole
    BEGIN
        SELECT dbo.[SeenClient].[Id] AS Id,
               dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle,
               dbo.[SeenClient].[Description] AS Description
        FROM dbo.[SeenClient]
        WHERE dbo.[SeenClient].IsDeleted = 0
        ORDER BY SeenClientTitle;
    END;
    ELSE
    BEGIN
        SELECT dbo.[SeenClient].[Id] AS Id,
               dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle,
               dbo.[SeenClient].[Description] AS Description
        FROM dbo.[SeenClient]
            INNER JOIN dbo.UserRolePermissions
                ON dbo.UserRolePermissions.PageID = @PageID
                   AND dbo.UserRolePermissions.ActualID = dbo.SeenClient.Id
                   AND dbo.UserRolePermissions.UserID = @userId
        WHERE dbo.[SeenClient].IsDeleted = 0
        ORDER BY SeenClientTitle;

    END;

    --GetSeenClientQuestionsBySeenClientId
    SELECT @Url = KeyValue + 'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT dbo.[SeenClientQuestions].[Id] AS Id,
           dbo.[SeenClientQuestions].[SeenClientId] AS SeenClientId,
           dbo.[SeenClientQuestions].[Position] AS Position,
           dbo.[SeenClientQuestions].[QuestionTypeId] AS QuestionTypeId,
           dbo.[SeenClientQuestions].[QuestionTitle] AS QuestionTitle,
           dbo.[SeenClientQuestions].[ShortName] AS ShortName,
           dbo.[SeenClientQuestions].[Required] AS Required,
           dbo.[SeenClientQuestions].[IsDisplayInSummary] AS IsDisplayInSummary,
           dbo.[SeenClientQuestions].[IsRepetitive] AS IsRepetitive,
           dbo.[SeenClientQuestions].QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
           dbo.[SeenClientQuestions].QuestionsGroupName AS RepetitiveQuestionsGroupName,
           dbo.[SeenClientQuestions].[IsDisplayInDetail] AS IsDisplayInDetail,
           dbo.[SeenClientQuestions].[MaxLength] AS MaxLength,
           dbo.[SeenClientQuestions].[Hint] AS Hint,
           dbo.[SeenClientQuestions].[EscalationRegex] AS EscalationRegex,
           dbo.[SeenClientQuestions].[KeyName] AS KeyName,
           dbo.[SeenClientQuestions].[GroupId] AS GroupId,
           dbo.[SeenClientQuestions].[OptionsDisplayType] AS OptionsDisplayType,
           dbo.[SeenClientQuestions].IsTitleBold,
           dbo.[SeenClientQuestions].IsTitleItalic,
           dbo.[SeenClientQuestions].IsTitleUnderline,
           dbo.[SeenClientQuestions].TitleTextColor,
           dbo.[SeenClientQuestions].ContactQuestionId,
           dbo.[SeenClientQuestions].TableGroupName,
           dbo.[SeenClientQuestions].[EscalationValue] AS EscalationValue,
           dbo.[SeenClientQuestions].[DisplayInGraphs] AS DisplayInGraphs,
           dbo.[SeenClientQuestions].[DisplayInTableView] AS DisplayInTableView,
           ISNULL(   CASE
                         WHEN QuestionTypeId IN ( 5, 6, 18, 21 ) THEN
                         (
                             SELECT SUM([Weight])
                             FROM dbo.SeenClientOptions
                             WHERE QuestionId = dbo.[SeenClientQuestions].Id
                                   AND IsDeleted = 0
                         )
                         ELSE
                             [Weight]
                     END,
                     0
                 ) [Weight],
           WeightForYes,
           WeightForNo,
           Qt.QuestionTypeName,
           dbo.[SeenClientQuestions].Margin,
           dbo.[SeenClientQuestions].FontSize,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM Questions
               WHERE SeenClientQuestionIdRef = SeenClientQuestions.Id
                     AND IsDeleted = 0
           ),
           0
                 ) AS ReferenceId,
           ISNULL(ImagePath, '') AS ImagePath,
           IsActive,
           IsCommentCompulsory AS IsCommentCompulsory,
           IsDecimal AS AllowDecimal,
           IsSignature AS IsSignature,
           dbo.[SeenClientQuestions].ImageHeight AS ImageHeight,
           dbo.[SeenClientQuestions].ImageWidth AS ImageWidth,
           dbo.[SeenClientQuestions].ImageAlign AS ImageAlign,
           dbo.[SeenClientQuestions].CalculationOptions AS CalculationOptions,
           dbo.[SeenClientQuestions].SummaryOption AS SummaryOption
    FROM dbo.[SeenClientQuestions]
        INNER JOIN dbo.[SeenClient]
            ON dbo.[SeenClient].Id = dbo.[SeenClientQuestions].SeenClientId
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
    WHERE dbo.[SeenClientQuestions].IsDeleted = 0
          AND [SeenClientId] = @seenClientId
          AND dbo.SeenClientQuestions.QuestionTypeId != 16
          AND dbo.SeenClientQuestions.QuestionTypeId != 23
          AND dbo.SeenClientQuestions.IsRepetitive != 1
    ORDER BY Position;

    --GetContactAll
    SELECT TOP 1
        @AdminRole = Id
    FROM [dbo].[Role]
    WHERE RoleName = 'Admin';
    SELECT TOP 1
        @UserRole = RoleId
    FROM dbo.[User]
    WHERE Id = @userId;
    SELECT TOP 1
        @PageID = Id
    FROM dbo.Page
    WHERE PageName = 'Contact';

    IF @AdminRole = @UserRole
    BEGIN
        SELECT dbo.[Contact].[Id] AS Id,
               dbo.[Contact].[ContactTitle] AS ContactTitle,
               dbo.[Contact].[Description] AS Description
        FROM dbo.[Contact]
        WHERE dbo.[Contact].IsDeleted = 0
        ORDER BY ContactTitle;
    END;
    ELSE
    BEGIN
        SELECT dbo.[Contact].[Id] AS Id,
               dbo.[Contact].[ContactTitle] AS ContactTitle,
               dbo.[Contact].[Description] AS Description
        FROM dbo.[Contact]
            INNER JOIN dbo.UserRolePermissions
                ON dbo.UserRolePermissions.PageID = @PageID
                   AND dbo.UserRolePermissions.ActualID = dbo.Contact.Id
                   AND dbo.UserRolePermissions.UserID = @userId
        WHERE dbo.[Contact].IsDeleted = 0
        ORDER BY ContactTitle;
    END;

    --GetContactQuestionsByContactId
    SELECT @Url = KeyValue + 'ContactQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT dbo.[ContactQuestions].[Id] AS Id,
           dbo.[ContactQuestions].[ContactId] AS ContactId,
           dbo.[ContactQuestions].[Position] AS Position,
           dbo.[ContactQuestions].[QuestionTypeId] AS QuestionTypeId,
           dbo.[QuestionType].QuestionTypeName,
           dbo.[ContactQuestions].[QuestionTitle] AS QuestionTitle,
           dbo.[ContactQuestions].[ShortName] AS ShortName,
           dbo.[ContactQuestions].[Required] AS Required,
           dbo.[ContactQuestions].[IsDisplayInSummary] AS IsDisplayInSummary,
           dbo.[ContactQuestions].[IsDisplayInDetail] AS IsDisplayInDetail,
           dbo.[ContactQuestions].[MaxLength] AS MaxLength,
           dbo.[ContactQuestions].[Hint] AS Hint,
           dbo.[ContactQuestions].[EscalationRegex] AS EscalationRegex,
           dbo.[ContactQuestions].[KeyName] AS KeyName,
           dbo.[ContactQuestions].[GroupId] AS GroupId,
           dbo.[ContactQuestions].[OptionsDisplayType] AS OptionsDisplayType,
           dbo.[ContactQuestions].[IsGroupField] AS IsGroupField,
           dbo.[ContactQuestions].IsTitleBold,
           dbo.[ContactQuestions].IsTitleItalic,
           dbo.[ContactQuestions].IsTitleUnderline,
           dbo.[ContactQuestions].TitleTextColor,
           dbo.[ContactQuestions].TableGroupName,
           dbo.[ContactQuestions].Margin,
           dbo.[ContactQuestions].FontSize,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM SeenClientQuestions
               WHERE ContactQuestionId = ContactQuestions.Id
                     AND IsDeleted = 0
           ),
           0
                 ) AS ReferenceId,
           ISNULL(ImagePath, '') AS ImagePath,
           IsCommentCompulsory AS IsCommentCompulsory,
           IsDecimal AS AllowDecimal
    FROM dbo.[ContactQuestions]
        INNER JOIN dbo.[Contact]
            ON dbo.[Contact].Id = dbo.[ContactQuestions].ContactId
        INNER JOIN dbo.[QuestionType]
            ON dbo.[QuestionType].Id = dbo.[ContactQuestions].QuestionTypeId
    WHERE dbo.[ContactQuestions].IsDeleted = 0
          AND [ContactId] = @contactId
          AND [ContactQuestions].QuestionTypeId != 16
          AND [ContactQuestions].QuestionTypeId != 23
    ORDER BY Position;

    --GetControlStyle
    SELECT Id,
           ControlStyleName,
           QuestionTypeId
    FROM dbo.ControlStyle;
END;
