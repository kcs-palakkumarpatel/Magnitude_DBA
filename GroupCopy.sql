CREATE PROCEDURE [dbo].[GroupCopy]
    @UserId BIGINT,
    @GroupId BIGINT,
    @Activity BIT,
    @Establishment BIT,
    @NewGroupNameList CopyGroupNameTypeTable READONLY
AS
BEGIN
    SET XACT_ABORT ON;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRAN
		BEGIN

    CREATE TABLE #temp
    (
        Id INT IDENTITY(1, 1),
        GroupName VARCHAR(100),
        IndustryName VARCHAR(100),
        AboutIndustry VARCHAR(1000),
        ContactTitle VARCHAR(100),
        [Description] VARCHAR(1000),
        ThemeName NVARCHAR(200),
        ThemeDescription NVARCHAR(500),
        ThemeMDPI NVARCHAR(500),
        ThemeHDPI NVARCHAR(500),
        ThemeXHDPI NVARCHAR(500),
        ThemeXXHDPI NVARCHAR(500),
        Theme640x960 NVARCHAR(500),
        Theme640x1136 NVARCHAR(500),
        Theme768x1280 NVARCHAR(500),
        Theme750x1334 NVARCHAR(50),
        Theme1242x2208 NVARCHAR(50)
    );

    CREATE TABLE #temp2
    (
        Id INT,
        QuestionTitle VARCHAR(1000),
        Name VARCHAR(100),
        QueID INT
    );


    CREATE TABLE #seenClient
    (
        NewSeenClientQuestionId BIGINT,
        OldSeenClientQuestionId BIGINT,
        NewSeenClientId BIGINT,
        OldSeenClientId BIGINT,
        NewEgId BIGINT,
        OldEgId BIGINT
    );
    DECLARE @IndustryId BIGINT,
            @ContactId BIGINT,
            @ThemeId BIGINT;

    SELECT @IndustryId = IndustryId,
           @ContactId = ContactId,
           @ThemeId = ThemeId
    FROM dbo.[Group]
    WHERE Id = @GroupId
          AND IsDeleted = 0;

    DECLARE @Industry VARCHAR(100),
            @AbtIndustry VARCHAR(1000);

    SELECT @Industry = IndustryName,
           @AbtIndustry = AboutIndustry
    FROM dbo.Industry
    WHERE Id = @IndustryId
          AND IsDeleted = 0;

    DECLARE @CntTitle VARCHAR(100),
            @CntDescription VARCHAR(1000);

    SELECT @CntTitle = ContactTitle,
           @CntDescription = Description
    FROM dbo.Contact
    WHERE Id = @ContactId
          AND IsDeleted = 0;

    DECLARE @ThemeName NVARCHAR(200),
            @ThemeDescription NVARCHAR(500),
            @ThemeMDPI NVARCHAR(500),
            @ThemeHDPI NVARCHAR(500),
            @ThemeXHDPI NVARCHAR(500),
            @ThemeXXHDPI NVARCHAR(500),
            @Theme640x960 NVARCHAR(500),
            @Theme640x1136 NVARCHAR(500),
            @Theme768x1280 NVARCHAR(500),
            @Theme750x1334 NVARCHAR(50),
            @Theme1242x2208 NVARCHAR(50);

    SELECT @ThemeName = ThemeName,
           @ThemeDescription = Description,
           @ThemeMDPI = ThemeMDPI,
           @ThemeHDPI = ThemeHDPI,
           @ThemeXHDPI = ThemeXHDPI,
           @ThemeXXHDPI = ThemeXXHDPI,
           @Theme640x960 = Theme640x960,
           @Theme640x1136 = Theme640x1136,
           @Theme768x1280 = Theme768x1280,
           @Theme750x1334 = Theme750x1334,
           @Theme1242x2208 = Theme1242x2208
    FROM dbo.Theme
    WHERE Id = @ThemeId
          AND IsDeleted = 0;

    INSERT INTO #temp
    SELECT new.GroupName,
           REPLACE(new.GroupName,'-','_') + ' - ' + @Industry,
           @AbtIndustry,
           REPLACE(new.GroupName,'-','_') + ' - ' + @CntTitle,
           @CntDescription,
           REPLACE(new.GroupName,'-','_') + ' - ' + @ThemeName,
           @ThemeDescription,
           @ThemeMDPI,
           @ThemeHDPI,
           @ThemeXHDPI,
           @ThemeXXHDPI,
           @Theme640x960,
           @Theme640x1136,
           @Theme768x1280,
           @Theme750x1334,
           @Theme1242x2208
    FROM @NewGroupNameList new;
    --Industry
    INSERT INTO dbo.Industry
    (
        IndustryName,
        AboutIndustry,
        CreatedOn,
        CreatedBy,
        IsDeleted
    )
    SELECT DISTINCT IndustryName,
           AboutIndustry,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT 13,
           i.Id,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.Industry i
        INNER JOIN #temp t
            ON t.IndustryName = i.IndustryName;
    --end Industry
    --contact
    INSERT INTO dbo.[Contact]
    (
        [ContactTitle],
        [Description],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    OUTPUT Inserted.Id,
           Inserted.ContactTitle,
           'Contact',
           -1
    INTO #temp2
    SELECT DISTINCT ContactTitle,
           Description,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT DISTINCT 29,
           c.Id,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.Contact c
        INNER JOIN #temp t
            ON t.ContactTitle = c.ContactTitle;
    --end Contact
    --Contact Question
    INSERT INTO dbo.ContactQuestions
    (
        ContactId,
        Position,
        QuestionTypeId,
        QuestionTitle,
        ShortName,
        Required,
        IsDisplayInSummary,
        IsDisplayInDetail,
        MaxLength,
        Hint,
        EscalationRegex,
        KeyName,
        GroupId,
        OptionsDisplayType,
        IsGroupField,
        IsTitleBold,
        IsTitleItalic,
        IsTitleUnderline,
        TitleTextColor,
        TableGroupName,
        Margin,
        FontSize,
        ImagePath,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        IsCommentCompulsory,
        IsDecimal
    )
    OUTPUT Inserted.Id,
           Inserted.QuestionTitle,
           'ContactQuestions',
           Inserted.ContactId
    INTO #temp2
    SELECT DISTINCT
        t.Id,
        cq.Position,
        cq.QuestionTypeId,
        cq.QuestionTitle,
        cq.ShortName,
        cq.Required,
        cq.IsDisplayInSummary,
        cq.IsDisplayInDetail,
        cq.MaxLength,
        cq.Hint,
        cq.EscalationRegex,
        cq.KeyName,
        cq.GroupId,
        cq.OptionsDisplayType,
        cq.IsGroupField,
        cq.IsTitleBold,
        cq.IsTitleItalic,
        cq.IsTitleUnderline,
        cq.TitleTextColor,
        cq.TableGroupName,
        cq.Margin,
        cq.FontSize,
        cq.ImagePath,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        cq.IsCommentCompulsory,
        cq.IsDecimal
    FROM dbo.ContactQuestions cq
        INNER JOIN dbo.Contact c
            ON c.Id = cq.ContactId
               AND c.Id = @ContactId
               AND cq.IsDeleted = 0
               AND c.IsDeleted = 0
        INNER JOIN #temp2 t
            ON c.ContactTitle = SUBSTRING(t.QuestionTitle, CHARINDEX(' - ', t.QuestionTitle) + 3, LEN(t.QuestionTitle))
               AND t.Name = 'Contact';
    UPDATE t
    SET t.QueID = t2.OldContact
    FROM #temp2 t
        INNER JOIN
        (
            SELECT t.Id AS NewContact,
                   c.Id AS OldContact
            FROM #temp2 t
                INNER JOIN dbo.Contact c
                    ON c.ContactTitle = SUBSTRING(
                                                     t.QuestionTitle,
                                                     CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                     LEN(t.QuestionTitle)
                                                 )
            WHERE t.Name = 'Contact'
        ) t2
            ON t.QueID = t2.NewContact
               AND t.Name = 'ContactQuestions';

			     SELECT OldContact.QueId AS OldContactQuestionId,
           NewContact.QueId AS NewContactQuestionId
    INTO #ContactQuestions
    FROM
    (
        SELECT DISTINCT
            q.Id AS QueId,
            q.Position,
            c.Id AS ContactId,
            c.ContactTitle
        FROM #temp2 t
            INNER JOIN dbo.ContactQuestions q
                ON q.QuestionTitle = t.QuestionTitle
                   AND t.QueID = q.ContactId
                   AND t.Name = 'ContactQuestions'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.Contact c
                ON c.Id = t.QueID
                   AND c.IsDeleted = 0
    ) AS OldContact
        INNER JOIN
        (
            SELECT q.Id AS QueId,
                   q.Position,
                   c.Id AS ContactId,
                   c.ContactTitle
            FROM #temp2 t
                INNER JOIN ContactQuestions q
                    ON q.Id = t.Id
                INNER JOIN dbo.Contact c
                    ON c.Id = q.ContactId
                       AND t.Name = 'ContactQuestions'
        ) AS NewContact
            ON SUBSTRING(
                            NewContact.ContactTitle,
                            CHARINDEX(' - ', NewContact.ContactTitle) + 3,
                            LEN(NewContact.ContactTitle)
                        ) = OldContact.ContactTitle
               AND NewContact.Position = OldContact.Position;

	
    --Contact Question Option
    INSERT INTO dbo.ContactOptions
    (
        ContactQuestionId,
        Position,
        Name,
        Value,
        DefaultValue,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    SELECT DISTINCT
        t.Id,
        o.Position,
        o.Name,
        o.Value,
        o.DefaultValue,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0
    FROM dbo.ContactQuestions cq
        INNER JOIN dbo.Contact c
            ON c.Id = cq.ContactId
               AND c.Id = @ContactId
               AND cq.IsDeleted = 0
        INNER JOIN dbo.ContactOptions o
            ON o.ContactQuestionId = cq.Id
               AND o.IsDeleted = 0
        INNER JOIN #ContactQuestions cqq
            ON cqq.OldContactQuestionId = o.ContactQuestionId
        INNER JOIN #temp2 t
            ON t.Id = cqq.NewContactQuestionId
               AND t.QueID = c.Id
               AND t.QuestionTitle = cq.QuestionTitle
               AND t.Name = 'ContactQuestions';

    --end Contact Question Option
    --Theme
    INSERT INTO dbo.[Theme]
    (
        [ThemeName],
        [Description],
        [ThemeMDPI],
        [ThemeHDPI],
        [ThemeXHDPI],
        [ThemeXXHDPI],
        [Theme640x960],
        [Theme640x1136],
        [Theme768x1280],
        Theme750x1334,
        Theme1242x2208,
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    OUTPUT Inserted.Id,
           Inserted.ThemeName,
           'Theme',
           @ThemeId
    INTO #temp2
    SELECT DISTINCT ThemeName,
           ThemeDescription,
           ThemeMDPI,
           ThemeHDPI,
           ThemeXHDPI,
           ThemeXXHDPI,
           Theme640x960,
           Theme640x1136,
           Theme768x1280,
           Theme750x1334,
           Theme1242x2208,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT 22,
           th.Id,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.Theme th
        INNER JOIN #temp t
            ON t.ThemeName = th.ThemeName;
    --end Theme
    --Group
    INSERT INTO dbo.[Group]
    (
        IndustryId,
        GroupName,
        AboutGroup,
        ThemeId,
        ContactId,
        GroupKeyword,
        SecurityKey,
        CreatedOn,
        CreatedBy,
        IsDeleted
    )
    SELECT DISTINCT i.Id,
           t.GroupName,
           g.AboutGroup,
           th.Id,
           c.Id,
           g.GroupKeyword,
           g.SecurityKey,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp t
        INNER JOIN dbo.Industry i
            ON i.IndustryName = t.IndustryName
        INNER JOIN dbo.Contact c
            ON c.ContactTitle = t.ContactTitle
        INNER JOIN dbo.Theme th
            ON th.ThemeName = t.ThemeName
        LEFT JOIN dbo.[Group] g
            ON g.Id = @GroupId
               AND g.IsDeleted = 0;
    --end Group
    CREATE TABLE #temp1
    (
        Id INT IDENTITY(1, 1),
        GroupId BIGINT,
        GroupName VARCHAR(100)
    );

    INSERT INTO #temp1
    (
        GroupId,
        GroupName
    )
    SELECT gg.Id,
            REPLACE(gg.GroupName,'-','_')
    FROM #temp tt
        INNER JOIN dbo.[Group] gg
            ON gg.GroupName = tt.GroupName
               AND gg.IsDeleted = 0;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT 14,
           t1.GroupId,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp1 t1;

    --Seenclient
    INSERT INTO dbo.SeenClient
    (
        SeenClientTitle,
        SeenClientType,
        Description,
        LastLoadedDate,
        BestWeight,
        FixedBenchMark,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        CompareType,
        EscalationValue,
		IsForTender
    )
    OUTPUT Inserted.Id,
           Inserted.SeenClientTitle,
           'SeenClient',
           -1
    INTO #temp2
    SELECT DISTINCT REPLACE(tt.GroupName,'-','_') + ' - ' + s.SeenClientTitle,
           s.SeenClientType,
           s.Description,
           s.LastLoadedDate,
           s.BestWeight,
           s.FixedBenchMark,
           GETUTCDATE(),
           @UserId,
           NULL,
           NULL,
           NULL,
           NULL,
           0,
           s.CompareType,
           s.EscalationValue,
		   IsForTender
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.SeenClient s
            ON s.Id = eg.SeenClientId
               AND eg.IsDeleted = 0
               AND s.IsDeleted = 0
               AND eg.GroupId = @GroupId
        INNER JOIN #temp1 tt
            ON 1 = 1;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT 17,
           t2.Id,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp2 t2
    WHERE t2.Name = 'SeenClient';
    --end Seenclient
    --SeenClientQuestion
    INSERT INTO dbo.SeenClientQuestions
    (
        SeenClientId,
        Position,
        QuestionTypeId,
        QuestionTitle,
        ShortName,
        IsActive,
        Required,
        IsDisplayInSummary,
        IsDisplayInDetail,
        MaxLength,
        Hint,
        EscalationRegex,
        OptionsDisplayType,
        ContactQuestionId,
        IsTitleBold,
        IsTitleItalic,
        IsTitleUnderline,
        TitleTextColor,
        TableGroupName,
        Margin,
        FontSize,
        Weight,
        WeightForYes,
        WeightForNo,
        MaxWeight,
        ImagePath,
        KeyName,
        GroupId,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        EscalationValue,
        DisplayInGraphs,
        DisplayInTableView,
        IsCommentCompulsory,
        IsRepetitive,
        IsDecimal,
        QuestionsGroupNo,
        QuestionsGroupName,
        IsSignature,
        ImageHeight,
        ImageWidth,
        ImageAlign,
        CalculationOptions,
        SummaryOption,
        IsRoutingOnGroup,
        ChildPosition,
        IsRequireHTTPHeader,
        IsValidateUsingQR,
		IsSingleSelect
    )
    OUTPUT Inserted.Id,
           Inserted.QuestionTitle,
           'SeenClientQuestions',
           Inserted.SeenClientId
    INTO #temp2
    SELECT DISTINCT
        t.Id,
        que.Position,
        que.QuestionTypeId,
        que.QuestionTitle,
        que.ShortName,
        que.IsActive,
        que.Required,
        que.IsDisplayInSummary,
        que.IsDisplayInDetail,
        que.MaxLength,
        que.Hint,
        que.EscalationRegex,
        que.OptionsDisplayType,
        que.ContactQuestionId,
        que.IsTitleBold,
        que.IsTitleItalic,
        que.IsTitleUnderline,
        que.TitleTextColor,
        que.TableGroupName,
        que.Margin,
        que.FontSize,
        que.Weight,
        que.WeightForYes,
        que.WeightForNo,
        que.MaxWeight,
        que.ImagePath,
        que.KeyName,
        que.GroupId,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        que.EscalationValue,
        que.DisplayInGraphs,
        que.DisplayInTableView,
        que.IsCommentCompulsory,
        que.IsRepetitive,
        que.IsDecimal,
        que.QuestionsGroupNo,
        que.QuestionsGroupName,
        que.IsSignature,
        que.ImageHeight,
        que.ImageWidth,
        que.ImageAlign,
        que.CalculationOptions,
        que.SummaryOption,
        que.IsRoutingOnGroup,
        que.ChildPosition,
        que.IsRequireHTTPHeader,
        que.IsValidateUsingQR,
		que.IsSingleSelect
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.SeenClient s
            ON s.Id = eg.SeenClientId
               AND eg.IsDeleted = 0
               AND s.IsDeleted = 0
               AND eg.GroupId = @GroupId
        INNER JOIN #temp2 t
            ON s.SeenClientTitle = SUBSTRING(
                                                t.QuestionTitle,
                                                CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                LEN(t.QuestionTitle)
                                            )
               AND t.Name = 'SeenClient'
        INNER JOIN dbo.SeenClientQuestions que
            ON que.SeenClientId = s.Id
               AND que.IsDeleted = 0;

UPDATE t
    SET t.QueID = a.SeenClientId
    FROM #temp2 t
        INNER JOIN
        (
            SELECT DISTINCT
                t.Id AS InId,
                eg.SeenClientId
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.SeenClient q
                    ON q.Id = eg.SeenClientId
                       AND eg.IsDeleted = 0
                       AND q.IsDeleted = 0
                       AND eg.GroupId = @GroupId
                INNER JOIN #temp2 t
                    ON q.SeenClientTitle = SUBSTRING(
                                                           t.QuestionTitle,
                                                           CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                           LEN(t.QuestionTitle)
                                                       )
                       AND t.Name = 'Seenclient'
        ) a
            ON a.InId = t.QueID
               AND t.Name = 'SeenclientQuestions';


    SELECT DISTINCT
        NewQue.Id AS NewSeenClientQuestionId,
        Oldque.Id AS OldSeenClientQuestionId
    INTO #seenclientQuestions
    FROM
    (
        SELECT que.*,
               q.SeenClientTitle
        FROM dbo.SeenClient q
            INNER JOIN #temp2 t
                ON t.Id = q.Id
                   AND t.Name = 'SeenClient'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.SeenClientQuestions que
                ON que.SeenClientId = q.Id
                   AND que.IsDeleted = 0
    ) NewQue
        INNER JOIN
        (
            SELECT DISTINCT
                que.*,
                q.SeenClientTitle
            FROM #temp2 t
                INNER JOIN dbo.SeenClient q
                    ON q.Id = t.QueID
                       AND t.Name = 'SeenClientQuestions'
                       AND q.IsDeleted = 0
                INNER JOIN dbo.SeenClientQuestions que
                    ON que.SeenClientId = q.Id
                       AND que.IsDeleted = 0
        ) Oldque
            ON Oldque.SeenClientTitle = SUBSTRING(
                                                     NewQue.SeenClientTitle,
                                                     CHARINDEX(' - ', NewQue.SeenClientTitle) + 3,
                                                     LEN(NewQue.SeenClientTitle)
                                                 )
               AND Oldque.Position = NewQue.Position
               AND ISNULL(Oldque.ChildPosition, 0) = ISNULL(NewQue.ChildPosition, 0);

    --end SeenClientQuestion

    --Questionnaire
    INSERT INTO dbo.Questionnaire
    (
        QuestionnaireTitle,
        QuestionnaireType,
        Description,
        LastLoadedDate,
        QuestionnaireFormType,
        BestWeight,
        FixedBenchMark,
        TestTime,
        LastTestDate,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        CompareType,
        EscalationValue,
        IsMultipleRouting,
        ControlStyleId
    )
    OUTPUT Inserted.Id,
           Inserted.QuestionnaireTitle,
           'Questionnaire',
           -1
    INTO #temp2
    SELECT DISTINCT  REPLACE(tt.GroupName,'-','_') + ' - ' + q.QuestionnaireTitle,
           q.QuestionnaireType,
           q.Description,
           q.LastLoadedDate,
           q.QuestionnaireFormType,
           q.BestWeight,
           q.FixedBenchMark,
           q.TestTime,
           q.LastTestDate,
           GETUTCDATE(),
           @UserId,
           NULL,
           NULL,
           NULL,
           NULL,
           0,
           q.CompareType,
           q.EscalationValue,
           q.IsMultipleRouting,
           q.ControlStyleId
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.Questionnaire q
            ON q.Id = eg.QuestionnaireId
               AND eg.IsDeleted = 0
               AND q.IsDeleted = 0
               AND eg.GroupId = @GroupId
        INNER JOIN #temp1 tt
            ON 1 = 1;

    INSERT INTO dbo.[UserRolePermissions]
    (
        [PageID],
        [ActualID],
        [UserID],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    SELECT 17,
           t2.Id,
           @UserId,
           GETUTCDATE(),
           @UserId,
           0
    FROM #temp2 t2
    WHERE t2.Name = 'Questionnaire';
    --end Questionnaire
    --Question
    INSERT INTO dbo.Questions
    (
        QuestionnaireId,
        Position,
        QuestionTypeId,
        QuestionTitle,
        ShortName,
        IsActive,
        Required,
        IsDisplayInSummary,
        IsDisplayInDetail,
        MaxLength,
        Hint,
        EscalationRegex,
        OptionsDisplayType,
        SeenClientQuestionIdRef,
        IsTitleBold,
        IsTitleItalic,
        IsTitleUnderline,
        TitleTextColor,
        TableGroupName,
        Margin,
        FontSize,
        Weight,
        WeightForYes,
        WeightForNo,
        MaxWeight,
        ImagePath,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
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
        ChildPosition,
        IsRequireHTTPHeader,
        IsRequiredInBI,
		IsForReminder,
		IsSingleSelect
    )
    OUTPUT Inserted.Id,
           Inserted.QuestionTitle,
           'Questions',
           Inserted.QuestionnaireId
    INTO #temp2
    SELECT DISTINCT
        t.Id,
        que.Position,
        que.QuestionTypeId,
        que.QuestionTitle,
        que.ShortName,
        que.IsActive,
        que.Required,
        que.IsDisplayInSummary,
        que.IsDisplayInDetail,
        que.MaxLength,
        que.Hint,
        que.EscalationRegex,
        que.OptionsDisplayType,
        sc.NewSeenClientQuestionId,
        que.IsTitleBold,
        que.IsTitleItalic,
        que.IsTitleUnderline,
        que.TitleTextColor,
        que.TableGroupName,
        que.Margin,
        que.FontSize,
        que.Weight,
        que.WeightForYes,
        que.WeightForNo,
        que.MaxWeight,
        que.ImagePath,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        que.EscalationValue,
        que.DisplayInGraphs,
        que.DisplayInTableView,
        que.IsCommentCompulsory,
        que.MultipleRoutingValue,
        que.IsAnonymous,
        cq.NewContactQuestionId,
        que.IsDecimal,
        que.IsRepetitive,
        que.QuestionsGroupNo,
        que.QuestionsGroupName,
        que.IsSignature,
        que.ImageHeight,
        que.ImageWidth,
        que.ImageAlign,
        que.CalculationOptions,
        que.SummaryOption,
        que.IsDefaultDisplay,
        que.IsRoutingOnGroup,
        que.ChildPosition,
        que.IsRequireHTTPHeader,
        que.IsRequiredInBI,
		que.IsForReminder,
		que.IsSingleSelect
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.Questionnaire q
            ON q.Id = eg.QuestionnaireId
               AND eg.IsDeleted = 0
               AND q.IsDeleted = 0
               AND eg.GroupId = @GroupId
        INNER JOIN #temp2 t
            ON q.QuestionnaireTitle = SUBSTRING(
                                                   t.QuestionTitle,
                                                   CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                   LEN(t.QuestionTitle)
                                               )
               AND t.Name = 'Questionnaire'
        INNER JOIN dbo.Questions que
            ON que.QuestionnaireId = q.Id
               AND que.IsDeleted = 0
        LEFT JOIN #seenclientQuestions sc
            ON sc.OldSeenClientQuestionId = que.SeenClientQuestionIdRef
        LEFT JOIN #ContactQuestions cq
            ON cq.OldContactQuestionId = que.ContactQuestionIdRef;


    UPDATE t
    SET t.QueID = a.QuestionnaireId
    FROM #temp2 t
        INNER JOIN
        (
            SELECT DISTINCT
                t.Id AS InId,
                eg.QuestionnaireId
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.Questionnaire q
                    ON q.Id = eg.QuestionnaireId
                       AND eg.IsDeleted = 0
                       AND q.IsDeleted = 0
                       AND eg.GroupId = @GroupId
                INNER JOIN #temp2 t
                    ON q.QuestionnaireTitle = SUBSTRING(
                                                           t.QuestionTitle,
                                                           CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                           LEN(t.QuestionTitle)
                                                       )
                       AND t.Name = 'Questionnaire'
        ) a
            ON a.InId = t.QueID
               AND t.Name = 'Questions';

    SELECT DISTINCT
        NewQue.Id AS NewQueId,
        Oldque.Id AS OldQueId
    INTO #Que
    FROM
    (
        SELECT que.*,
               q.QuestionnaireTitle
        FROM dbo.Questionnaire q
            INNER JOIN #temp2 t
                ON t.Id = q.Id
                   AND t.Name = 'Questionnaire'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.Questions que
                ON que.QuestionnaireId = q.Id
                   AND que.IsDeleted = 0
    ) NewQue
        INNER JOIN
        (
            SELECT DISTINCT
                que.*,
                q.QuestionnaireTitle
            FROM #temp2 t
                INNER JOIN dbo.Questionnaire q
                    ON q.Id = t.QueID
                       AND t.Name = 'Questions'
                       AND q.IsDeleted = 0
                INNER JOIN dbo.Questions que
                    ON que.QuestionnaireId = q.Id
                       AND que.IsDeleted = 0
        ) Oldque
            ON Oldque.QuestionnaireTitle = SUBSTRING(
                                                        NewQue.QuestionnaireTitle,
                                                        CHARINDEX(' - ', NewQue.QuestionnaireTitle) + 3,
                                                        LEN(NewQue.QuestionnaireTitle)
                                                    )
               AND Oldque.Position = NewQue.Position
               AND ISNULL(Oldque.ChildPosition, 0) = ISNULL(NewQue.ChildPosition, 0);
    --end Question
    --Option
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
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        IsNA,
        OptionImagePath,
        FromRef,
        ReferenceQuestionId,
        IsHTTPHeader
    )
    SELECT DISTINCT
        t.Id,
        o.Position,
        o.Name,
        o.Value,
        o.DefaultValue,
        o.Weight,
        o.Point,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        o.IsNA,
        o.OptionImagePath,
        o.ReferenceQuestionId,
        o.FromRef,
        o.IsHTTPHeader
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.Questionnaire q
            ON q.Id = eg.QuestionnaireId
               AND eg.GroupId = @GroupId
               AND eg.IsDeleted = 0
               AND q.IsDeleted = 0
        INNER JOIN dbo.Questions que
            ON que.QuestionnaireId = q.Id
               AND que.IsDeleted = 0
        INNER JOIN dbo.Options o
            ON o.QuestionId = que.Id
               AND o.IsDeleted = 0
        INNER JOIN #Que qu
            ON qu.OldQueId = o.QuestionId
        INNER JOIN #temp2 t
            ON t.QuestionTitle = que.QuestionTitle
               AND t.Name = 'Questions'
               AND t.QueID = q.Id
               AND t.Id = qu.NewQueId;
    --end Option

    --How it works--    
    INSERT INTO dbo.HowItWorks
    (
        HowItWorksName,
        HowItWorks,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    OUTPUT Inserted.Id,
           Inserted.HowItWorksName,
           'HowItWorks',
           -1
    INTO #temp2
    SELECT DISTINCT
         REPLACE(tt.GroupName,'-','_') + ' - ' + h.HowItWorksName,
        h.HowItWorks,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.HowItWorks h
            ON h.Id = eg.HowItWorksId
               AND eg.GroupId = @GroupId
               AND h.IsDeleted = 0
        INNER JOIN #temp1 tt
            ON 1 = 1;
    --end How it works--
    --Establishment Group
    CREATE TABLE #temp3
    (
        Id INT IDENTITY(1, 1),
        GroupId BIGINT,
        GroupType NVARCHAR(100)
    );

    INSERT INTO #temp3
    (
        GroupId,
        GroupType
    )
    SELECT Id,
           EstablishmentGroupType
    FROM dbo.EstablishmentGroup
    WHERE GroupId = @GroupId
          AND IsDeleted = 0;

    DECLARE @cnttemp1 INT,
            @totalcnttemp1 INT;
    SET @cnttemp1 = 1;
    SET @totalcnttemp1 =
    (
        SELECT COUNT(*) FROM #temp1
    );

    DECLARE @cnttemp3 INT,
            @totalcnttemp3 INT;
    SET @cnttemp3 = 1;
    SET @totalcnttemp3 =
    (
        SELECT COUNT(*) FROM #temp3
    );



    WHILE (@cnttemp1 <= @totalcnttemp1)
    BEGIN
        SET @cnttemp3 = 1;
        WHILE (@cnttemp3 <= @totalcnttemp3)
        BEGIN
            DECLARE @ExistEGId BIGINT,
                    @EstaGroupType NVARCHAR(100),
                    @NewGroupId BIGINT,
                    @NewGroupName NVARCHAR(200),
                    @NewQueId BIGINT = NULL,
                    @NewSeenClientId BIGINT = NULL,
                    @NewHTWId BIGINT = NULL;

            SELECT @ExistEGId = GroupId,
                   @EstaGroupType = GroupType
            FROM #temp3
            WHERE Id = @cnttemp3;

            SELECT @NewGroupId = GroupId,
                   @NewGroupName = GroupName
            FROM #temp1
            WHERE Id = @cnttemp1;

            SELECT @NewQueId = t.Id
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.Questionnaire q
                    ON q.Id = eg.QuestionnaireId
                LEFT JOIN #temp2 t
                    ON t.QuestionTitle = @NewGroupName + ' - ' + q.QuestionnaireTitle
                       AND t.Name = 'Questionnaire'
            WHERE eg.Id = @ExistEGId;

            SELECT @NewSeenClientId = t.Id
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.SeenClient s
                    ON s.Id = eg.SeenClientId
                LEFT JOIN #temp2 t
                    ON t.QuestionTitle = @NewGroupName + ' - ' + s.SeenClientTitle
                       AND t.Name = 'SeenClient'
            WHERE eg.Id = @ExistEGId;

            SELECT @NewHTWId = t.Id
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.HowItWorks h
                    ON h.Id = eg.HowItWorksId
                LEFT JOIN #temp2 t
                    ON t.QuestionTitle = @NewGroupName + ' - ' + h.HowItWorksName
                       AND t.Name = 'HowItWorks'
            WHERE eg.Id = @ExistEGId;

            INSERT INTO dbo.EstablishmentGroup
            (
                GroupId,
                EstablishmentGroupName,
                EstablishmentGroupType,
                AboutEstablishmentGroup,
                QuestionnaireId,
                SeenClientId,
                HowItWorksId,
                SMSReminder,
                EmailReminder,
                EstablishmentGroupId,
                AllowToChangeDelayTime,
                DelayTime,
                AllowRecurring,
                ThemeMDPI,
                ThemeHDPI,
                ThemeXHDPI,
                ThemeXXHDPI,
                Theme640x960,
                Theme640x1136,
                Theme768x1280,
                Theme750x1334,
                Theme1242x2208,
                SmileOn,
                SadFrom,
                SadTo,
                NeutralFrom,
                NeutralTo,
                HappyFrom,
                HappyTo,
                ReportingToEmail,
                ContactQuestion,
                AutoReportEnable,
                AutoReportSchedulerId,
                ActivitySmilePeriod,
                CreatedOn,
                CreatedBy,
                UpdatedOn,
                UpdatedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted,
                IsConfugureManualImage,
                ConfigureImagePath,
                BackgroundColor,
                BorderColor,
                ConfigureImageName,
                IsAutoResolved,
                ConfigureImageSequence,
                IsGroupKeyword,
                IsGroupSearch,
                DisplaySequence,
                AttachmentLimit,
                AutoSaveLimit,
                PIStatus,
                PIOutStatus,
                ActivityImagePath,
                CustomerSMSAlert,
                CustomerSMSText,
                CustomerEmailAlert,
                CustomerEmailSubject,
                CustomerEmailText,
                CustomerQuestion,
                ShowQueastionCustomer,
                DirectRespondentForm,
                IncludeEmailAttachments,
                InFormRefNumber,
                ShowHideChatforCustomer,
                InitiatorFormTitle,
				AllowToRefreshTheTaskDaily,
				AllowTaskAllocations
            )
            OUTPUT Inserted.Id,
                   Inserted.EstablishmentGroupName,
                   'EstablishmentGroupName',
                   @ExistEGId
            INTO #temp2
            SELECT DISTINCT @NewGroupId,
                   @NewGroupName + ' - ' + eg.EstablishmentGroupName,
                   eg.EstablishmentGroupType,
                   eg.AboutEstablishmentGroup,
                   @NewQueId,
                   @NewSeenClientId,
                   @NewHTWId,
                   eg.SMSReminder,
                   eg.EmailReminder,
                   eg.EstablishmentGroupId,
                   eg.AllowToChangeDelayTime,
                   eg.DelayTime,
                   eg.AllowRecurring,
                   eg.ThemeMDPI,
                   eg.ThemeHDPI,
                   eg.ThemeXHDPI,
                   eg.ThemeXXHDPI,
                   eg.Theme640x960,
                   eg.Theme640x1136,
                   eg.Theme768x1280,
                   eg.Theme750x1334,
                   eg.Theme1242x2208,
                   eg.SmileOn,
                   eg.SadFrom,
                   eg.SadTo,
                   eg.NeutralFrom,
                   eg.NeutralTo,
                   eg.HappyFrom,
                   eg.HappyTo,
                   eg.ReportingToEmail,
                   eg.ContactQuestion,
                   eg.AutoReportEnable,
                   eg.AutoReportSchedulerId,
                   eg.ActivitySmilePeriod,
                   eg.CreatedOn,
                   eg.CreatedBy,
                   eg.UpdatedOn,
                   eg.UpdatedBy,
                   eg.DeletedOn,
                   eg.DeletedBy,
                   eg.IsDeleted,
                   eg.IsConfugureManualImage,
                   eg.ConfigureImagePath,
                   eg.BackgroundColor,
                   eg.BorderColor,
                   eg.ConfigureImageName,
                   eg.IsAutoResolved,
                   eg.ConfigureImageSequence,
                   eg.IsGroupKeyword,
                   eg.IsGroupSearch,
                   eg.DisplaySequence,
                   eg.AttachmentLimit,
                   eg.AutoSaveLimit,
                   eg.PIStatus,
                   eg.PIOutStatus,
                   eg.ActivityImagePath,
                   eg.CustomerSMSAlert,
                   eg.CustomerSMSText,
                   eg.CustomerEmailAlert,
                   eg.CustomerEmailSubject,
                   eg.CustomerEmailText,
                   eg.CustomerQuestion,
                   eg.ShowQueastionCustomer,
                   eg.DirectRespondentForm,
                   eg.IncludeEmailAttachments,
                   eg.InFormRefNumber,
                   eg.ShowHideChatforCustomer,
                   eg.InitiatorFormTitle,
				   eg.AllowToRefreshTheTaskDaily,
				eg.AllowTaskAllocations
            FROM dbo.EstablishmentGroup eg
            WHERE Id = @ExistEGId;

            DECLARE @NewInsertedEstablishmentGroupId BIGINT = NULL;

            SELECT @NewInsertedEstablishmentGroupId = SCOPE_IDENTITY();



            INSERT INTO dbo.UserRolePermissions
            (
                PageID,
                ActualID,
                UserID,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (   14,                               -- PageID - bigint
                @NewInsertedEstablishmentGroupId, -- ActualID - bigint
                @UserId,                          -- UserID - bigint
                GETDATE(),                        -- CreatedOn - datetime
                @UserId,                          -- CreatedBy - bigint
                0
            );


            --Establishment
            IF (@Establishment = 1)
            BEGIN
                INSERT INTO dbo.Establishment
                (
                    GroupId,
                    EstablishmentGroupId,
                    EstablishmentName,
                    GeographicalLocation,
                    TimeOffSetId,
                    TimeOffSet,
                    IncludedMonthlyReports,
                    UniqueSMSKeyword,
                    CommonSMSKeyword,
                    AutoResponseMessage,
                    SendThankYouSMS,
                    ThankYouMessage,
                    SendSeenClientSMS,
                    SeenClientAutoSMS,
                    SendSeenClientEmail,
                    SeenClientAutoEmail,
                    SeenClientEmailSubject,
                    SeenClientAutoNotification,
                    SeenClientEscalationTime,
                    SeenClientSchedulerTime,
                    SeenClientSchedulerTimeString,
                    ShowIntroductoryOnMobi,
                    IntroductoryMessage,
                    EscalationEmailSubject,
                    EscalationEmails,
                    EscalationMobile,
                    EscalationTime,
                    EscalationSchedulerTime,
                    EscalationSchedulerTimeString,
                    EscalationSchedulerDay,
                    FeedbackTimeSpan,
                    ShowSeenClientDetailsOnMobi,
                    SendNotificationAlertForAll,
                    SendFeedbackSMSAlert,
                    FeedbackSMSAlert,
                    SendFeedbackEmailAlert,
                    FeedbackEmailAlert,
                    FeedbackEmailSubject,
                    FeedbackNotificationAlert,
                    FeedbackRedirectURL,
                    FeedbackOnce,
                    mobiFormDisplayFields,
                    CreatedOn,
                    CreatedBy,
                    UpdatedOn,
                    UpdatedBy,
                    DeletedOn,
                    DeletedBy,
                    IsDeleted,
                    ThankyouPageMessage,
                    OutEscalationEmailSubject,
                    OutEscalationEmails,
                    OutEscalationMobile,
                    OutEscalationTime,
                    OutEscalationSchedulerTime,
                    OutEscalationSchedulerTimeString,
                    OutEscalationSchedulerDay,
                    SendOutNotificationAlertForAll,
                    SendCaptureSMSAlert,
                    CaptureSMSAlert,
                    SendCaptureEmailAlert,
                    CaptureEmailAlert,
                    CaptureEmailSubject,
                    CaptureNotificationAlert,
                    CommonIntroductoryMessage,
                    ResolutionFeedbackQuestion,
                    ResolutionFeedbackSMS,
                    ResolutionFeedbackEmail,
                    ResolutionFeedbackEmailSubject,
                    IsMultipleRouting,
                    MultipleRoutingValue,
                    ThankyoumessageforLessthanPI,
                    ThankyoumessageforGretareThanPI,
                    SendTransferFormEmail,
                    TransferFormEmailSubject,
                    TransferFormEmail,
                    SendTransferFormSMS,
                    TransferFormSMS,
                    DisplayGroupKeyword,
                    EstablishmentSequence,
                    DynamicSaveButtonText,
                    HeaderImage,
                    InEscalationOnce,
                    OutEscalationOnce,
                    ISAdditionalCaptureEmail,
                    AdditionalCaptureEmails,
                    AdditionalCaptureEmailSubject,
                    AdditionalCaptureEmailBody,
                    ISAdditionalCaptureSMS,
                    AdditionalCaptureMobile,
                    AdditionalCaptureSMSBody,
                    ISAdditionalFeedbackEmail,
                    AdditionalFeedbackEmails,
                    AdditionalFeedbackEmailSubject,
                    AdditionalFeedbackEmailBody,
                    ISAdditionalFeedbackSMS,
                    AdditionalFeedbackMobile,
                    AdditionalFeedbackSMSBody,
                    StatusIconEstablishment,
                    ReminderNotificationCapture,
                    ReminderNotificationFeedback,
                    InitiatorAsRespondent,
					ReleaseDateValidationMessage,
					MobiExpiredValidationMessage,
					CaptureReminderAlert,
					FeedBackReminderAlert,
					CaptureUnallocatedNotificationAlert
                )
                OUTPUT Inserted.Id,
                       Inserted.EstablishmentName,
                       'Establishment',
                       -1
                INTO #temp2
                SELECT DISTINCT @NewGroupId,
                       @NewInsertedEstablishmentGroupId,
                       @NewGroupName + ' - ' + e.EstablishmentName,
                       e.GeographicalLocation,
                       e.TimeOffSetId,
                       e.TimeOffSet,
                       e.IncludedMonthlyReports,
                       e.UniqueSMSKeyword,
                       e.CommonSMSKeyword,
                       e.AutoResponseMessage,
                       e.SendThankYouSMS,
                       e.ThankYouMessage,
                       e.SendSeenClientSMS,
                       e.SeenClientAutoSMS,
                       e.SendSeenClientEmail,
                       e.SeenClientAutoEmail,
                       e.SeenClientEmailSubject,
                       e.SeenClientAutoNotification,
                       e.SeenClientEscalationTime,
                       e.SeenClientSchedulerTime,
                       e.SeenClientSchedulerTimeString,
                       e.ShowIntroductoryOnMobi,
                       e.IntroductoryMessage,
                       e.EscalationEmailSubject,
                       e.EscalationEmails,
                       e.EscalationMobile,
                       e.EscalationTime,
                       e.EscalationSchedulerTime,
                       e.EscalationSchedulerTimeString,
                       e.EscalationSchedulerDay,
                       e.FeedbackTimeSpan,
                       e.ShowSeenClientDetailsOnMobi,
                       e.SendNotificationAlertForAll,
                       e.SendFeedbackSMSAlert,
                       e.FeedbackSMSAlert,
                       e.SendFeedbackEmailAlert,
                       e.FeedbackEmailAlert,
                       e.FeedbackEmailSubject,
                       e.FeedbackNotificationAlert,
                       e.FeedbackRedirectURL,
                       e.FeedbackOnce,
                       e.mobiFormDisplayFields,
                       GETUTCDATE(),
                       @UserId,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       0,
                       e.ThankyouPageMessage,
                       e.OutEscalationEmailSubject,
                       e.OutEscalationEmails,
                       e.OutEscalationMobile,
                       e.OutEscalationTime,
                       e.OutEscalationSchedulerTime,
                       e.OutEscalationSchedulerTimeString,
                       e.OutEscalationSchedulerDay,
                       e.SendOutNotificationAlertForAll,
                       e.SendCaptureSMSAlert,
                       e.CaptureSMSAlert,
                       e.SendCaptureEmailAlert,
                       e.CaptureEmailAlert,
                       e.CaptureEmailSubject,
                       e.CaptureNotificationAlert,
                       e.CommonIntroductoryMessage,
                       e.ResolutionFeedbackQuestion,
                       e.ResolutionFeedbackSMS,
                       e.ResolutionFeedbackEmail,
                       e.ResolutionFeedbackEmailSubject,
                       e.IsMultipleRouting,
                       e.MultipleRoutingValue,
                       e.ThankyoumessageforLessthanPI,
                       e.ThankyoumessageforGretareThanPI,
                       e.SendTransferFormEmail,
                       e.TransferFormEmailSubject,
                       e.TransferFormEmail,
                       e.SendTransferFormSMS,
                       e.TransferFormSMS,
                       e.DisplayGroupKeyword,
                       e.EstablishmentSequence,
                       e.DynamicSaveButtonText,
                       e.HeaderImage,
                       e.InEscalationOnce,
                       e.OutEscalationOnce,
                       e.ISAdditionalCaptureEmail,
                       e.AdditionalCaptureEmails,
                       e.AdditionalCaptureEmailSubject,
                       e.AdditionalCaptureEmailBody,
                       e.ISAdditionalCaptureSMS,
                       e.AdditionalCaptureMobile,
                       e.AdditionalCaptureSMSBody,
                       e.ISAdditionalFeedbackEmail,
                       e.AdditionalFeedbackEmails,
                       e.AdditionalFeedbackEmailSubject,
                       e.AdditionalFeedbackEmailBody,
                       e.ISAdditionalFeedbackSMS,
                       e.AdditionalFeedbackMobile,
                       e.AdditionalFeedbackSMSBody,
                       e.StatusIconEstablishment,
                       e.ReminderNotificationCapture,
                       e.ReminderNotificationFeedback,
                       e.InitiatorAsRespondent,
					   e.ReleaseDateValidationMessage,
					e.MobiExpiredValidationMessage,
					e.CaptureReminderAlert,
					e.FeedBackReminderAlert,
					e.CaptureUnallocatedNotificationAlert
                FROM dbo.Establishment e
                WHERE EstablishmentGroupId = @ExistEGId
                      AND e.IsDeleted = 0;

            END;
            --end Establishment

            SET @cnttemp3 = @cnttemp3 + 1;
            CONTINUE;
        END;
        SET @cnttemp1 = @cnttemp1 + 1;
        CONTINUE;
    END;
    --end Establishment Group

    IF (@Establishment = 1)
    BEGIN
        --Establishment UserRole Permission
        INSERT INTO dbo.UserRolePermissions
        (
            PageID,
            ActualID,
            UserID,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        SELECT 26,
               t.Id,
               @UserId,
               GETUTCDATE(),
               @UserId,
               0
        FROM #temp2 t
        WHERE Name = 'Establishment';
        --End EstablishmentUserRole Permission
        --Establishment Status
        INSERT INTO dbo.EstablishmentStatus
        (
            EstablishmentId,
            StatusName,
            StatusIconImageId,
            DefaultStartStatus,
            DefaultEndStatus,
            IsActive,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        SELECT t.Id,
               es.StatusName,
               es.StatusIconImageId,
               es.DefaultStartStatus,
               es.DefaultEndStatus,
               es.IsActive,
               GETUTCDATE(),
               @UserId,
               0
        FROM dbo.EstablishmentGroup eg
            INNER JOIN dbo.Establishment e
                ON e.EstablishmentGroupId = eg.Id
                   AND e.IsDeleted = 0
                   AND eg.IsDeleted = 0
                   AND eg.GroupId = @GroupId
            INNER JOIN dbo.EstablishmentStatus es
                ON es.EstablishmentId = e.Id
                   AND es.IsDeleted = 0
                   AND e.IsDeleted = 0
            INNER JOIN #temp2 t
                ON e.EstablishmentName = SUBSTRING(
                                                      t.QuestionTitle,
                                                      CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                      LEN(t.QuestionTitle)
                                                  )
                   AND t.Name = 'Establishment'
        ORDER BY es.Id ASC;
        --End Establishment status
        --update lmobi form deisplay field
        CREATE TABLE #mobiQuestionResult (datastring NVARCHAR(MAX));
        CREATE TABLE #mobiQuestion
        (
            Id INT IDENTITY(1, 1),
            OldmobiFormDisplayFields VARCHAR(MAX),
            NewEstablishmentId BIGINT,
            OldSeenClientId BIGINT,
            NewSeenClientId BIGINT
        );
        INSERT INTO #mobiQuestion
        (
            OldmobiFormDisplayFields,
            NewEstablishmentId,
            OldSeenClientId,
            NewSeenClientId
        )
        SELECT e.mobiFormDisplayFields,
               t.Id,
               eg.SeenClientId,
               eg1.SeenClientId
        FROM dbo.Establishment e
            INNER JOIN #temp2 t
                ON e.EstablishmentName = SUBSTRING(
                                                      t.QuestionTitle,
                                                      CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                      LEN(t.QuestionTitle)
                                                  )
                   AND e.GroupId = @GroupId
                   AND t.Name = 'Establishment'
            INNER JOIN dbo.EstablishmentGroup eg
                ON eg.Id = e.EstablishmentGroupId
            INNER JOIN dbo.Establishment ee
                ON ee.Id = t.Id
            INNER JOIN dbo.EstablishmentGroup eg1
                ON eg1.Id = ee.EstablishmentGroupId;

        DECLARE @cnttempmobi INT,
                @totalcnttempmobi INT;
        SET @cnttempmobi = 1;
        SET @totalcnttempmobi =
        (
            SELECT COUNT(*) FROM #mobiQuestion
        );
        WHILE (@cnttempmobi <= @totalcnttempmobi)
        BEGIN
            DECLARE @vOldmobiFormDisplayFields NVARCHAR(MAX),
                    @vNewEstablishmentId BIGINT,
                    @vOldSeenClientId BIGINT,
                    @vNewSeenClientId BIGINT;

            SELECT @vOldmobiFormDisplayFields = OldmobiFormDisplayFields,
                   @vNewEstablishmentId = NewEstablishmentId,
                   @vOldSeenClientId = OldSeenClientId,
                   @vNewSeenClientId = NewSeenClientId
            FROM #mobiQuestion
            WHERE Id = @cnttempmobi;

            DECLARE @sql1 NVARCHAR(MAX),
                    @output1 NVARCHAR(MAX);

            SET @sql1
                = 'SELECT STUFF((SELECT '',''+ CONVERT(NVARCHAR(100),c1.Id) 
from SeenClientQuestions c   
inner join SeenClientQuestions c1 on c1.QuestionTitle = c.QuestionTitle 
and c1.SeenClientId = ' + CONVERT(NVARCHAR(200), @vNewSeenClientId) + '
 and c.Id in (' + @vOldmobiFormDisplayFields + ')FOR XML PATH('''')) ,1,1,'''')';

            INSERT INTO #mobiQuestionResult
            EXEC sp_executesql @sql1;

            SELECT TOP 1
                @output1 = datastring
            FROM #mobiQuestionResult;

            UPDATE dbo.Establishment
            SET mobiFormDisplayFields = @output1
            WHERE Id = @vNewEstablishmentId;

            DELETE FROM #mobiQuestionResult;

            SET @cnttempmobi = @cnttempmobi + 1;
        END;
    --end update mobi form display field
    END;

    UPDATE t
    SET t.QueID = a.SeenClientId
    FROM #temp2 t
        INNER JOIN
        (
            SELECT DISTINCT
                t.Id AS InId,
                eg.SeenClientId
            FROM dbo.EstablishmentGroup eg
                INNER JOIN dbo.SeenClient q
                    ON q.Id = eg.SeenClientId
                       AND eg.IsDeleted = 0
                       AND q.IsDeleted = 0
                       AND eg.GroupId = @GroupId
                INNER JOIN #temp2 t
                    ON q.SeenClientTitle = SUBSTRING(
                                                        t.QuestionTitle,
                                                        CHARINDEX(' - ', t.QuestionTitle) + 3,
                                                        LEN(t.QuestionTitle)
                                                    )
                       AND t.Name = 'SeenClient'
        ) a
            ON a.InId = t.QueID
               AND t.Name = 'SeenClientQuestions';


    

    INSERT INTO #seenClient
    SELECT DISTINCT
        NewQue.Id AS NewSeenClientQuestionId,
        Oldque.Id AS OldSeenClientQuestionId,
        NewQue.SeenClientId AS NewSeenClientId,
        Oldque.SeenClientId AS OldSeenClientId,
        NewQue.EgId AS NewEgId,
        Oldque.EgId AS OldEgId
    FROM
    (
        SELECT que.*,
               q.SeenClientTitle,
               eg.Id AS EgId,
               eg.EstablishmentGroupName
        FROM dbo.SeenClient q
            INNER JOIN #temp2 t
                ON t.Id = q.Id
                   AND t.Name = 'SeenClient'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.SeenClientQuestions que
                ON que.SeenClientId = q.Id
                   AND que.IsDeleted = 0
            INNER JOIN dbo.EstablishmentGroup eg
                ON eg.SeenClientId = q.Id
    ) NewQue
        INNER JOIN
        (
            SELECT DISTINCT
                que.*,
                q.SeenClientTitle,
                eg.Id AS EgId,
                eg.EstablishmentGroupName
            FROM #temp2 t
                INNER JOIN dbo.SeenClient q
                    ON q.Id = t.QueID
                       AND t.Name = 'SeenClientQuestions'
                       AND q.IsDeleted = 0
                INNER JOIN dbo.SeenClientQuestions que
                    ON que.SeenClientId = q.Id
                       AND que.IsDeleted = 0
                INNER JOIN dbo.EstablishmentGroup eg
                    ON eg.SeenClientId = q.Id
        ) Oldque
            ON Oldque.SeenClientTitle = SUBSTRING(
                                                     NewQue.SeenClientTitle,
                                                     CHARINDEX(' - ', NewQue.SeenClientTitle) + 3,
                                                     LEN(NewQue.SeenClientTitle)
                                                 )
               AND Oldque.EstablishmentGroupName = SUBSTRING(
                                                                NewQue.EstablishmentGroupName,
                                                                CHARINDEX(' - ', NewQue.EstablishmentGroupName) + 3,
                                                                LEN(NewQue.EstablishmentGroupName)
                                                            )
               AND Oldque.Position = NewQue.Position
               AND ISNULL(Oldque.ChildPosition, 0) = ISNULL(NewQue.ChildPosition, 0);


    

    --SeenClientOption
    INSERT INTO dbo.SeenClientOptions
    (
        QuestionId,
        Position,
        Name,
        Value,
        DefaultValue,
        Weight,
        Point,
        QAEnd,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        IsNA,
        FromRef,
        ReferenceQuestionId,
        IsHTTPHeader
    )
    SELECT DISTINCT
        t.Id,
        o.Position,
        o.Name,
        o.Value,
        o.DefaultValue,
        o.Weight,
        o.Point,
        o.QAEnd,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        o.IsNA,
        o.FromRef,
        o.ReferenceQuestionId,
        o.IsHTTPHeader
    FROM dbo.EstablishmentGroup eg
        INNER JOIN dbo.SeenClient s
            ON s.Id = eg.SeenClientId
               AND eg.IsDeleted = 0
               AND s.IsDeleted = 0
               AND eg.GroupId = @GroupId
        INNER JOIN dbo.SeenClientQuestions que
            ON que.SeenClientId = s.Id
               AND que.IsDeleted = 0
        INNER JOIN dbo.SeenClientOptions o
            ON o.QuestionId = que.Id
               AND o.IsDeleted = 0
        INNER JOIN #seenClient sc
            ON sc.OldSeenClientQuestionId = que.Id
        INNER JOIN #temp2 t
            ON t.Id = sc.NewSeenClientQuestionId
               AND t.QuestionTitle = que.QuestionTitle
               AND t.Name = 'SeenClientQuestions'
               AND t.QueID = s.Id;
    --end SeenClientOption
    --1 SeenClientAutoEmail

    --1 SeenClientAutoEmail  









    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewSeenClientAutoEmail,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.SeenClientAutoEmail,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) Number
            FROM
            (
                SELECT E.Id,
                       SeenClientAutoEmail,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.SeenClientAutoEmail, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewSeenClientAutoEmail
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewSeenClientAutoEmail,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET SeenClientAutoEmail = NewSeenClientAutoEmail
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;



    --2 AdditionalCaptureEmailBody  

















    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewAdditionalCaptureEmailBody,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.AdditionalCaptureEmailBody,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalCaptureEmailBody,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalCaptureEmailBody, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalCaptureEmailBody
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalCaptureEmailBody,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalCaptureEmailBody = NewAdditionalCaptureEmailBody
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --3 AdditionalCaptureEmailSubject  













    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewAdditionalCaptureEmailSubject,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.AdditionalCaptureEmailSubject,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalCaptureEmailSubject,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalCaptureEmailSubject, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalCaptureEmailSubject
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalCaptureEmailSubject,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalCaptureEmailSubject = NewAdditionalCaptureEmailSubject
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --4 AdditionalCaptureSMSBody  













    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewAdditionalCaptureSMSBody,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.AdditionalCaptureSMSBody,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalCaptureSMSBody,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalCaptureSMSBody, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalCaptureSMSBody
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalCaptureSMSBody,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalCaptureSMSBody = NewAdditionalCaptureSMSBody
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --5 CaptureEmailAlert  








    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewCaptureEmailAlert,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.CaptureEmailAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       CaptureEmailAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.CaptureEmailAlert, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewCaptureEmailAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewCaptureEmailAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET CaptureEmailAlert = NewCaptureEmailAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;



    --6 CaptureEmailSubject  

















    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewCaptureEmailSubject,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.CaptureEmailSubject,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       CaptureEmailSubject,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.CaptureEmailSubject, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewCaptureEmailSubject
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewCaptureEmailSubject,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET CaptureEmailSubject = NewCaptureEmailSubject
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;



    --7 CaptureNotificationAlert  

















    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewCaptureNotificationAlert,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.CaptureNotificationAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       CaptureNotificationAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.CaptureNotificationAlert, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewCaptureNotificationAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewCaptureNotificationAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET CaptureNotificationAlert = NewCaptureNotificationAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;




    --8 CaptureSMSAlert  





















    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewCaptureSMSAlert,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.CaptureSMSAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       CaptureSMSAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.CaptureSMSAlert, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewCaptureSMSAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewCaptureSMSAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET CaptureSMSAlert = NewCaptureSMSAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --9 IntroductoryMessage  








    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewIntroductoryMessage,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.IntroductoryMessage,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       IntroductoryMessage,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.IntroductoryMessage, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewIntroductoryMessage
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewIntroductoryMessage,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET IntroductoryMessage = NewIntroductoryMessage
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --10 SeenClientAutoNotification  













    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewSeenClientAutoNotification,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.SeenClientAutoNotification,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       SeenClientAutoNotification,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.SeenClientAutoNotification, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewSeenClientAutoNotification
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewSeenClientAutoNotification,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET SeenClientAutoNotification = NewSeenClientAutoNotification
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --11 SeenClientAutoSMS  












    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewSeenClientAutoSMS,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.SeenClientAutoSMS,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       SeenClientAutoSMS,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.SeenClientAutoSMS, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewSeenClientAutoSMS
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewSeenClientAutoSMS,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET SeenClientAutoSMS = NewSeenClientAutoSMS
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --12 SeenClientEmailSubject  












    ;
    WITH cte
    AS (SELECT CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                   ELSE
                       s.Data
               END AS NewSeenClientEmailSubject,
               s.Id
        FROM
        (
            SELECT E.Id,
                   E.SeenClientEmailSubject,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       SeenClientEmailSubject,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.SeenClientEmailSubject, '#[')
        ) s
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewSeenClientEmailSubject
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewSeenClientEmailSubject,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET SeenClientEmailSubject = NewSeenClientEmailSubject
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    SELECT DISTINCT
        NewQue.Id AS NewQueId,
        Oldque.Id AS OldQueId,
        NewQue.QuestionnaireId AS NewQuestionnaireId,
        Oldque.QuestionnaireId AS OldQuestionnaireId,
        NewQue.egid AS NewEgId,
        Oldque.egid AS OldEgId
    INTO #Questions
    FROM
    (
        SELECT que.*,
               q.QuestionnaireTitle,
               eg.EstablishmentGroupName,
               eg.Id AS egid
        FROM dbo.Questionnaire q
            INNER JOIN #temp2 t
                ON t.Id = q.Id
                   AND t.Name = 'Questionnaire'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.Questions que
                ON que.QuestionnaireId = q.Id
                   AND que.IsDeleted = 0
            INNER JOIN dbo.EstablishmentGroup eg
                ON eg.QuestionnaireId = q.Id
            INNER JOIN dbo.[Group] g
                ON g.Id = eg.GroupId
    ) NewQue
        INNER JOIN
        (
            SELECT DISTINCT
                que.*,
                q.QuestionnaireTitle,
                eg.EstablishmentGroupName,
                eg.Id AS egid
            FROM #temp2 t
                INNER JOIN dbo.Questionnaire q
                    ON q.Id = t.QueID
                       AND t.Name = 'Questions'
                       AND q.IsDeleted = 0
                INNER JOIN dbo.Questions que
                    ON que.QuestionnaireId = q.Id
                       AND que.IsDeleted = 0
                INNER JOIN dbo.EstablishmentGroup eg
                    ON eg.QuestionnaireId = q.Id
                       AND eg.GroupId = @GroupId
        ) Oldque
            ON Oldque.QuestionnaireTitle = SUBSTRING(
                                                        NewQue.QuestionnaireTitle,
                                                        CHARINDEX(' - ', NewQue.QuestionnaireTitle) + 3,
                                                        LEN(NewQue.QuestionnaireTitle)
                                                    )
               AND Oldque.EstablishmentGroupName = SUBSTRING(
                                                                NewQue.EstablishmentGroupName,
                                                                CHARINDEX(' - ', NewQue.EstablishmentGroupName) + 3,
                                                                LEN(NewQue.EstablishmentGroupName)
                                                            )
               AND Oldque.Position = NewQue.Position
               AND ISNULL(Oldque.ChildPosition, 0) = ISNULL(NewQue.ChildPosition, 0);

    --1 FeedbackEmailAlert  






    ;
    WITH cte
    AS (SELECT s.Id,
               s.FeedbackEmailAlert,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewFeedbackEmailAlert
        FROM
        (
            SELECT E.Id,
                   E.FeedbackEmailAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       FeedbackEmailAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.FeedbackEmailAlert, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewFeedbackEmailAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewFeedbackEmailAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET FeedbackEmailAlert = NewFeedbackEmailAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;


    --2 FeedbackEmailSubject  












    ;
    WITH cte
    AS (SELECT s.Id,
               s.FeedbackEmailSubject,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewFeedbackEmailSubject
        FROM
        (
            SELECT E.Id,
                   E.FeedbackEmailSubject,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       FeedbackEmailSubject,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.FeedbackEmailSubject, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewFeedbackEmailSubject
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewFeedbackEmailSubject,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET FeedbackEmailSubject = NewFeedbackEmailSubject
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --3 AdditionalFeedbackEmailBody  









    ;
    WITH cte
    AS (SELECT s.Id,
               s.AdditionalFeedbackEmailBody,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewAdditionalFeedbackEmailBody
        FROM
        (
            SELECT E.Id,
                   E.AdditionalFeedbackEmailBody,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalFeedbackEmailBody,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalFeedbackEmailBody, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalFeedbackEmailBody
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalFeedbackEmailBody,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalFeedbackEmailBody = NewAdditionalFeedbackEmailBody
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --4 AdditionalFeedbackEmailSubject  









    ;
    WITH cte
    AS (SELECT s.Id,
               s.AdditionalFeedbackEmailSubject,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewAdditionalFeedbackEmailSubject
        FROM
        (
            SELECT E.Id,
                   E.AdditionalFeedbackEmailSubject,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalFeedbackEmailSubject,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalFeedbackEmailSubject, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalFeedbackEmailSubject
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalFeedbackEmailSubject,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalFeedbackEmailSubject = NewAdditionalFeedbackEmailSubject
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --5 AdditionalFeedbackSMSBody  









    ;
    WITH cte
    AS (SELECT s.Id,
               s.AdditionalFeedbackSMSBody,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewAdditionalFeedbackSMSBody
        FROM
        (
            SELECT E.Id,
                   E.AdditionalFeedbackSMSBody,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       AdditionalFeedbackSMSBody,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.AdditionalFeedbackSMSBody, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewAdditionalFeedbackSMSBody
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewAdditionalFeedbackSMSBody,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET AdditionalFeedbackSMSBody = NewAdditionalFeedbackSMSBody
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --6 FeedbackNotificationAlert  









    ;
    WITH cte
    AS (SELECT s.Id,
               s.FeedbackNotificationAlert,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewFeedbackNotificationAlert
        FROM
        (
            SELECT E.Id,
                   E.FeedbackNotificationAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       FeedbackNotificationAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.FeedbackNotificationAlert, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewFeedbackNotificationAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewFeedbackNotificationAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET FeedbackNotificationAlert = NewFeedbackNotificationAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;

    --7 FeedbackSMSAlert  










    ;
    WITH cte
    AS (SELECT s.Id,
               s.FeedbackSMSAlert,
               CASE
                   WHEN sc.NewQueId IS NOT NULL THEN
                       REPLACE(s.Data, s.Number, sc.NewQueId)
                   ELSE
                       s.Data
               END NewFeedbackSMSAlert
        FROM
        (
            SELECT E.Id,
                   E.FeedbackSMSAlert,
                   E.EstablishmentGroupId,
                   Split.Id AS SplitId,
                   Data,
                   SUBSTRING(
                                Data,
                                PATINDEX('%[0-9]%', Data),
                                PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                            ) AS Number
            FROM
            (
                SELECT E.Id,
                       FeedbackSMSAlert,
                       E.EstablishmentGroupId
                FROM dbo.Establishment E
                    INNER JOIN #temp2 t
                        ON t.Id = E.Id
                           AND t.Name = 'Establishment'
            ) E
                CROSS APPLY [dbo].[Split]  (E.FeedbackSMSAlert, '#[')
        ) s
            LEFT JOIN #Questions sc
                ON sc.OldQueId = TRY_CAST(s.Number AS BIGINT)
                   AND sc.NewEgId = s.EstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT '#' + cte.NewFeedbackSMSAlert
                            FROM cte
                            WHERE cte1.Id = cte.Id
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewFeedbackSMSAlert,
               Id
        FROM cte cte1
        GROUP BY cte1.Id
       )
    UPDATE e
    SET FeedbackSMSAlert = NewFeedbackSMSAlert
    FROM cte3
        INNER JOIN Establishment e
            ON e.Id = cte3.Id;
    -------------------------------------------------------------------------------------------------------------------------------
	SELECT DISTINCT OldContact.QueId AS OldContactQuestionId,
           NewContact.QueId AS NewContactQuestionId,
		   OldContact.ContactId AS OldContactId,
		   NewContact.ContactId AS NewContactId,
		   OldContact.GroupId AS OlgGrouId,
		   NewContact.GroupId AS NewGroupId
    INTO #ContactQue
    FROM
    (
        SELECT DISTINCT
            q.Id AS QueId,
            q.Position,
            c.Id AS ContactId,
            c.ContactTitle,
			g.Id AS GroupId
        FROM #temp2 t
            INNER JOIN dbo.ContactQuestions q
                ON q.QuestionTitle = t.QuestionTitle
                   AND t.QueID = q.ContactId
                   AND t.Name = 'ContactQuestions'
                   AND q.IsDeleted = 0
            INNER JOIN dbo.Contact c
                ON c.Id = t.QueID
                   AND c.IsDeleted = 0
				   INNER JOIN dbo.[Group] g ON g.ContactId = c.Id

    ) AS OldContact
        INNER JOIN
        (
            SELECT DISTINCT q.Id AS QueId,
                   q.Position,
                   c.Id AS ContactId,
                   c.ContactTitle,
				   g.Id AS GroupId
            FROM #temp2 t
                INNER JOIN ContactQuestions q
                    ON q.Id = t.Id
                INNER JOIN dbo.Contact c
                    ON c.Id = q.ContactId
                       AND t.Name = 'ContactQuestions'
					   INNER JOIN dbo.[Group] g ON g.ContactId = c.Id
        ) AS NewContact
            ON SUBSTRING(
                            NewContact.ContactTitle,
                            CHARINDEX(' - ', NewContact.ContactTitle) + 3,
                            LEN(NewContact.ContactTitle)
                        ) = OldContact.ContactTitle
               AND NewContact.Position = OldContact.Position;

    --CustomerQuestion  
    ;
    WITH cte
    AS (
	SELECT Que.OldEstablishmentGroupId,
	Que.NewEstablishmentGroupId,
               Que.CustomerQuestion,
			   que.data,
			   Que.SplitId,
               CASE
                   WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                       sc.NewSeenClientQuestionId
                   ELSE
                       Que.Data
               END AS NewCustomerQuestion
        FROM
        (
            SELECT OldEst.NewEstablishmentGroupId,
                   OldEst.CustomerQuestion,
				   OldEst.OldEstablishmentGroupId,
                   Split.Id SplitId,
                   Data
            FROM
            (
                SELECT eg.Id AS NewEstablishmentGroupId,
                       eg.CustomerQuestion,
                       QueID AS OldEstablishmentGroupId
                FROM #temp2
                    INNER JOIN dbo.EstablishmentGroup eg
                        ON eg.Id = #temp2.Id
                           AND Name = 'EstablishmentGroupName'
						   AND eg.CustomerQuestion IS NOT NULL
            ) OldEst
                CROSS APPLY [dbo].Split  (CustomerQuestion, ',')
        ) Que
            LEFT JOIN #seenClient sc
                ON sc.OldSeenClientQuestionId = TRY_CAST(Que.Data AS BIGINT)
				AND sc.NewEgId=Que.NewEstablishmentGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT ',' + CAST(cte.NewCustomerQuestion AS VARCHAR(10))
                            FROM cte
                            WHERE cte1.OldEstablishmentGroupId = cte.OldEstablishmentGroupId
							AND cte.NewEstablishmentGroupId=cte1.NewEstablishmentGroupId
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewCustomerQuestion,
               cte1.NewEstablishmentGroupId AS Id
        FROM cte cte1
		GROUP BY cte1.OldEstablishmentGroupId,
		cte1.NewEstablishmentGroupId
		
       )
    UPDATE e
    SET CustomerQuestion= NewCustomerQuestion
    FROM cte3
        INNER JOIN EstablishmentGroup e
            ON e.Id = cte3.Id
--ContactQuestion  
    ;
    WITH cte
    AS (
	SELECT DISTINCT Que.OldEstablishmentGroupId,
	Que.NewEstablishmentGroupId,
               Que.ContactQuestion,
			   que.data,
			   Que.SplitId,
               CASE
                   WHEN sc.NewContactQuestionId IS NOT NULL THEN
                       sc.NewContactQuestionId
                   ELSE
                       Que.Data
               END AS NewContactQuestion,
			   Que.GroupId
        FROM
        (
            SELECT OldEst.NewEstablishmentGroupId,
                   OldEst.ContactQuestion,
				   OldEst.OldEstablishmentGroupId,
                   Split.Id SplitId,
                   Data,
				   OldEst.GroupId
            FROM
            (
                SELECT eg.Id AS NewEstablishmentGroupId,
                       eg.ContactQuestion,
                       QueID AS OldEstablishmentGroupId,
					   eg.GroupId
                FROM #temp2
                    INNER JOIN dbo.EstablishmentGroup eg
                        ON eg.Id = #temp2.Id
                           AND Name = 'EstablishmentGroupName'
						   AND eg.ContactQuestion IS NOT NULL
            ) OldEst
                CROSS APPLY [dbo].Split  (ContactQuestion, ',')
        ) Que
            LEFT JOIN #ContactQue sc
                ON sc.OldContactQuestionId = TRY_CAST(Que.Data AS BIGINT)
			AND Que.GroupId=sc.NewGroupId
       ),
         cte3
    AS (SELECT STUFF(
                        (
                            SELECT ',' + CAST(cte.NewContactQuestion AS VARCHAR(10))
                            FROM cte
                            WHERE cte1.OldEstablishmentGroupId = cte.OldEstablishmentGroupId
							AND cte.NewEstablishmentGroupId=cte1.NewEstablishmentGroupId
                            FOR XML PATH(''), TYPE
                        ).value('.', 'nvarchar(max)'),
                        1,
                        1,
                        ''
                    ) AS NewContactQuestion,
               cte1.NewEstablishmentGroupId AS Id
        FROM cte cte1
		GROUP BY cte1.OldEstablishmentGroupId,
		cte1.NewEstablishmentGroupId
		
       )
    UPDATE e
    SET ContactQuestion= NewContactQuestion
    FROM cte3
        INNER JOIN EstablishmentGroup e
            ON e.Id = cte3.Id;


    INSERT INTO dbo.CloseLoopTemplate
    (
        EstablishmentGroupId,
        TemplateText,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    SELECT DISTINCT t2.Id,
           CLT.TemplateText,
           GETUTCDATE(),
           @UserId,
           NULL,
           NULL,
           NULL,
           NULL,
           0
    FROM dbo.CloseLoopTemplate CLT
        INNER JOIN #temp2 t2
            ON t2.QueID = CLT.EstablishmentGroupId
    WHERE t2.Name = 'EstablishmentGroupName'
          AND CLT.IsDeleted = 0;

    UPDATE cq
    SET cq.GroupId = 'Group' + CAST(New.NewContactQuestionId AS NVARCHAR(100)),
        cq.KeyName = 'Key' + CAST(New.NewContactQuestionId AS NVARCHAR(100))
    FROM #ContactQuestions New
        INNER JOIN dbo.ContactQuestions cq
            ON New.NewContactQuestionId = cq.Id;

    UPDATE old
    SET old.ContactQuestionId = cq.NewContactQuestionId
    FROM dbo.SeenClientQuestions old
        INNER JOIN #seenClient new
            ON new.NewSeenClientQuestionId = old.Id
        INNER JOIN #ContactQuestions cq
            ON cq.OldContactQuestionId = old.ContactQuestionId;

    UPDATE eg
    SET eg.EstablishmentGroupId = t2.Id
    FROM dbo.EstablishmentGroup eg
        INNER JOIN #temp2 t2
            ON t2.QueID = eg.EstablishmentGroupId
        INNER JOIN #temp2 t
            ON t.Id = eg.Id
               AND t.Name = 'EstablishmentGroupName'
    WHERE t2.Name = 'EstablishmentGroupName';

    INSERT INTO dbo.EstablishmentGroupModuleAlias
    (
        EstablishmentGroupId,
        AppModuleId,
        AliasName,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted
    )
    SELECT DISTINCT t2.Id,
           CLT.AppModuleId,
           CLT.AliasName,
           GETUTCDATE(),
           @UserId,
           NULL,
           NULL,
           NULL,
           NULL,
           0
    FROM dbo.EstablishmentGroupModuleAlias CLT
        INNER JOIN #temp2 t2
            ON t2.QueID = CLT.EstablishmentGroupId
    WHERE t2.Name = 'EstablishmentGroupName'
          AND CLT.IsDeleted = 0;


    INSERT INTO dbo.EstablishmentGroupImage
    (
        EstablishmentGroupId,
        Resolution,
        FileName,
        CreatedOn
    )
    SELECT DISTINCT t2.Id,
           CLT.Resolution,
           CLT.FileName,
           GETUTCDATE()
    FROM dbo.EstablishmentGroupImage CLT
        INNER JOIN #temp2 t2
            ON t2.QueID = CLT.EstablishmentGroupId
    WHERE t2.Name = 'EstablishmentGroupName';

    UPDATE t
    SET ThemeMDPI = REPLACE(ThemeMDPI, t2.QueID, t2.Id),
        ThemeHDPI = REPLACE(ThemeHDPI, t2.QueID, t2.Id),
        ThemeXHDPI = REPLACE(ThemeXHDPI, t2.QueID, t2.Id),
        ThemeXXHDPI = REPLACE(ThemeXXHDPI, t2.QueID, t2.Id),
        Theme640x960 = REPLACE(Theme640x960, t2.QueID, t2.Id),
        Theme640x1136 = REPLACE(Theme640x1136, t2.QueID, t2.Id),
        Theme768x1280 = REPLACE(Theme768x1280, t2.QueID, t2.Id),
        Theme750x1334 = REPLACE(Theme750x1334, t2.QueID, t2.Id),
        Theme1242x2208 = REPLACE(Theme1242x2208, t2.QueID, t2.Id)
    FROM dbo.Theme t
        INNER JOIN #temp2 t2
            ON t2.Id = t.Id
               AND t2.Name = 'Theme';

    INSERT INTO dbo.ThemeImage
    (
        ThemeId,
        Resolution,
        FileName,
        CreatedOn
    )
    SELECT DISTINCT t2.Id,
           CLT.Resolution,
           CLT.FileName,
           GETUTCDATE()
    FROM dbo.ThemeImage CLT
        INNER JOIN #temp2 t2
            ON t2.QueID = CLT.ThemeId
    WHERE t2.Name = 'Theme';

    INSERT INTO dbo.HeaderSetting
    (
        GroupId,
        EstablishmentGroupId,
        HeaderId,
        HeaderName,
        HeaderValue,
        CreatedOn,
        CreatedBy,
        IsDeleted,
		LabelColor,
		IsLabel
    )
    SELECT DISTINCT eg.GroupId,
           eg.Id,
           hs.HeaderId,
           hs.HeaderName,
           hs.HeaderValue,
           GETUTCDATE(),
           @UserId,
           0,
		  hs.LabelColor,
		hs.IsLabel
    FROM dbo.EstablishmentGroup eg
        INNER JOIN #temp2 t2
            ON t2.Id = eg.Id
               AND t2.Name = 'EstablishmentGroupName'
        INNER JOIN dbo.HeaderSetting hs
            ON hs.EstablishmentGroupId = t2.QueID
               AND hs.IsDeleted = 0;

			   
--Condition Logic

    INSERT INTO dbo.ConditionLogic
    (
        QuestionId,
        ConditionQuestionId,
        OperationId,
        AnswerId,
        AnswerText,
        IsAnd,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        IsRoutingOnGroup,
        ConditionRepetitiveGroupId
    )
	SELECT DISTINCT 
	qq.NewQueId AS QuetionId,
               q.NewQueId AS ConditionQuestionId,
               cl.OperationId,
               o.Id AS AnswerId,
               ISNULL(o.Name, cl.AnswerText) AS AnswerText,
               cl.IsAnd,
			         GETUTCDATE(),
           @UserId,
           NULL,
           NULL,
           NULL,
           NULL,
           0,
     	
               cl.IsRoutingOnGroup,
               cl.ConditionRepetitiveGroupId
        FROM #Questions q
            INNER JOIN dbo.ConditionLogic cl
                ON cl.ConditionQuestionId = q.OldQueId  AND cl.IsDeleted=0
			INNER JOIN dbo.Questions que ON que.Id = q.OldQueId AND q.OldQuestionnaireId=que.QuestionnaireId AND que.IsDeleted=0
            INNER JOIN #Questions qq
                ON qq.OldQueId = cl.QuestionId AND qq.NewQuestionnaireId = q.NewQuestionnaireId AND qq.NewEgId = q.NewEgId
			INNER JOIN dbo.Questions quec ON quec.Id = qq.OldQueId AND qq.OldQuestionnaireId=quec.QuestionnaireId AND quec.IsDeleted=0
            LEFT JOIN dbo.Options o
                ON o.QuestionId = q.NewQueId
                   AND o.Name = cl.AnswerText
                   AND o.IsDeleted = 0
  
  
    INSERT INTO dbo.ConditionLogic
    (
        QuestionId,
        ConditionQuestionId,
        OperationId,
        AnswerId,
        AnswerText,
        IsAnd,
        CreatedOn,
        CreatedBy,
        UpdatedOn,
        UpdatedBy,
        DeletedOn,
        DeletedBy,
        IsDeleted,
        IsRoutingOnGroup,
        ConditionRepetitiveGroupId
    )
    SELECT DISTINCT
        cl.QuestionId AS QuetionId,
        q.NewQueId AS ConditionQuestionId,
        cl.OperationId,
        o.Id AS AnswerId,
        ISNULL(o.Name, cl.AnswerText) AS AnswerText,
        cl.IsAnd,
        GETUTCDATE(),
        @UserId,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
        cl.IsRoutingOnGroup,
        cl.ConditionRepetitiveGroupId
    FROM #Que q
        INNER JOIN dbo.ConditionLogic cl
            ON cl.ConditionQuestionId = q.OldQueId
               AND cl.IsRoutingOnGroup = 1
			   AND cl.IsDeleted=0
        LEFT JOIN dbo.Options o
            ON o.QuestionId = q.NewQueId
               AND o.Name = cl.AnswerText
               AND o.IsDeleted = 0;

    -- end condition logic

    --RoutingLogic
    INSERT INTO dbo.RoutingLogic
    (
        OptionId,
        QueueQuestionId,
        CreatedOn,
        CreatedBy,
        IsDeleted
    )
    SELECT DISTINCT op.Id,
           que.NewQueId,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.RoutingLogic rl
        INNER JOIN #Questions que
            ON que.OldQueId = rl.QueueQuestionId
               AND rl.IsDeleted = 0
        INNER JOIN dbo.Options o
            ON o.Id = rl.OptionId
               AND o.IsDeleted = 0
        INNER JOIN dbo.Questions q
            ON q.Id = o.QuestionId
               AND q.IsDeleted = 0
			   AND que.OldQuestionnaireId=q.QuestionnaireId
        INNER JOIN #Questions qu
            ON q.Id = qu.OldQueId AND qu.OldQuestionnaireId=q.QuestionnaireId
			AND qu.NewQuestionnaireId = que.NewQuestionnaireId
        INNER JOIN dbo.Options op
            ON op.QuestionId = qu.NewQueId
               AND o.Name = op.Name;

    --end RoutingLogic



    SELECT Id NewDataId,
           Name,
           QueID OldDataId
    FROM #temp2
    WHERE Name = 'Theme'
    UNION
    SELECT Id NewDataId,
           Name,
           QueID OldDataId
    FROM #temp2
    WHERE Name = 'EstablishmentGroupName';
	END
COMMIT;
END;
