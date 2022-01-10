CREATE PROCEDURE dbo.GroupCopy_Original
    @UserId BIGINT,
    @GroupId BIGINT,
    @Activity BIT,
    @Establishment BIT,
    @NewGroupNameList CopyGroupNameTypeTable READONLY
AS
BEGIN
    SET XACT_ABORT ON;


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
        QuestionTitle VARCHAR(500),
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
           new.GroupName + ' - ' + @Industry,
           @AbtIndustry,
           new.GroupName + ' - ' + @CntTitle,
           @CntDescription,
           new.GroupName + ' - ' + @ThemeName,
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
    SELECT IndustryName,
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
    SELECT ContactTitle,
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
    SELECT 29,
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
    SELECT ThemeName,
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
    SELECT i.Id,
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
           gg.GroupName
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
    OUTPUT Inserted.Id,
           Inserted.SeenClientTitle,
           'SeenClient',
           -1
    INTO #temp2
    SELECT DISTINCT tt.GroupName + ' - ' + s.SeenClientTitle,
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
           s.EscalationValue
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
        IsValidateUsingQR
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
        que.IsValidateUsingQR
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
    OUTPUT Inserted.Id,
           Inserted.QuestionnaireTitle,
           'Questionnaire',
           -1
    INTO #temp2
    SELECT DISTINCT tt.GroupName + ' - ' + q.QuestionnaireTitle,
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
    INSERT INTO Questions
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
        que.IsRequiredInBI,
        que.IsRoutingOnGroup,
        que.ChildPosition,
        que.IsRequireHTTPHeader
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
    OUTPUT Inserted.Id,
           Inserted.HowItWorksName,
           'HowItWorks',
           -1
    INTO #temp2
    SELECT DISTINCT
        tt.GroupName + ' - ' + h.HowItWorksName,
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
            OUTPUT Inserted.Id,
                   Inserted.EstablishmentGroupName,
                   'EstablishmentGroupName',
                   @ExistEGId
            INTO #temp2
            SELECT @NewGroupId,
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
                   eg.InitiatorFormTitle
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
                OUTPUT Inserted.Id,
                       Inserted.EstablishmentName,
                       'Establishment',
                       -1
                INTO #temp2
                SELECT @NewGroupId,
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
                       e.InitiatorAsRespondent
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

    --Condition Logic


    INSERT INTO dbo.ConditionLogic
    SELECT ISNULL(qq.NewQueId, cl.QuestionId) AS QuetionId,
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
    FROM dbo.ConditionLogic cl
        INNER JOIN #Que q
            ON q.OldQueId = cl.ConditionQuestionId
               AND cl.IsDeleted = 0
        LEFT JOIN #Que qq
            ON qq.OldQueId = cl.QuestionId
        LEFT JOIN dbo.Options o
            ON o.QuestionId = q.NewQueId
               AND o.Name = cl.AnswerText;
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
    SELECT op.Id,
           que.NewQueId,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.RoutingLogic rl
        INNER JOIN #Que que
            ON que.OldQueId = rl.QueueQuestionId
               AND rl.IsDeleted = 0
        INNER JOIN dbo.Options o
            ON o.Id = rl.OptionId
               AND o.IsDeleted = 0
        INNER JOIN dbo.Questions q
            ON q.Id = o.QuestionId
               AND q.IsDeleted = 0
        INNER JOIN #Que qu
            ON q.Id = qu.OldQueId
        INNER JOIN dbo.Options op
            ON op.QuestionId = qu.NewQueId
               AND o.Name = op.Name;

    --end RoutingLogic
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


    PRINT '123';

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


    PRINT '456';


    --SeenClientOption
    INSERT INTO dbo.SeenClientOptions
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

    UPDATE e
    SET e.SeenClientAutoEmail = new.NewSeenClientAutoEmail
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.SeenClientAutoEmail,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewSeenClientAutoEmail
            FROM
            (
                --Palak
                SELECT E.Id,
                       E.SeenClientAutoEmail,
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
                           SeenClientAutoEmail,
                           E.EstablishmentGroupId
                    FROM dbo.Establishment E
                        INNER JOIN #temp2 t
                            ON t.Id = E.Id
                               AND t.Name = 'Establishment'
                ) E
                    CROSS APPLY dbo.Split(E.SeenClientAutoEmail, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.SeenClientAutoEmail,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;




    --2 AdditionalCaptureEmailBody
    UPDATE e
    SET e.AdditionalCaptureEmailBody = new.NewAdditionalCaptureEmailBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalCaptureEmailBody,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewAdditionalCaptureEmailBody
            FROM
            (
                --Palak
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
                    CROSS APPLY dbo.Split(E.AdditionalCaptureEmailBody, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.AdditionalCaptureEmailBody,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;
    --3 AdditionalCaptureEmailSubject
    UPDATE e
    SET e.AdditionalCaptureEmailSubject = new.NewAdditionalCaptureEmailSubject
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalCaptureEmailSubject,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewAdditionalCaptureEmailSubject
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
                    CROSS APPLY dbo.Split(E.AdditionalCaptureEmailSubject, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.AdditionalCaptureEmailSubject,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

    --4 AdditionalCaptureSMSBody

    UPDATE e
    SET e.AdditionalCaptureSMSBody = new.NewAdditionalCaptureSMSBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalCaptureSMSBody,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewAdditionalCaptureSMSBody
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
                    CROSS APPLY dbo.Split(E.AdditionalCaptureSMSBody, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.AdditionalCaptureSMSBody,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;



    --5 CaptureEmailAlert

    UPDATE e
    SET e.CaptureEmailAlert = new.NewCaptureEmailAlert
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.CaptureEmailAlert,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewCaptureEmailAlert
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
                    CROSS APPLY dbo.Split(E.CaptureEmailAlert, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.CaptureEmailAlert,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

    --6 CaptureEmailSubject

    UPDATE e
    SET e.CaptureEmailSubject = new.NewCaptureEmailSubject
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.CaptureEmailSubject,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewCaptureEmailSubject
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
                    CROSS APPLY dbo.Split(E.CaptureEmailSubject, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.CaptureEmailSubject,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;


    --7 CaptureNotificationAlert

    UPDATE e
    SET e.CaptureNotificationAlert = new.NewCaptureNotificationAlert
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.CaptureNotificationAlert,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewCaptureNotificationAlert
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
                    CROSS APPLY dbo.Split(E.CaptureNotificationAlert, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.CaptureNotificationAlert,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;


    --8 CaptureSMSAlert

    UPDATE e
    SET e.CaptureSMSAlert = new.NewCaptureSMSAlert
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.CaptureSMSAlert,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewCaptureSMSAlert
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
                    CROSS APPLY dbo.Split(E.CaptureSMSAlert, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.CaptureSMSAlert,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

    --9 IntroductoryMessage

    UPDATE e
    SET e.IntroductoryMessage = new.NewIntroductoryMessage
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.IntroductoryMessage,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewIntroductoryMessage
            FROM
            (
                --Palak
                SELECT E.Id,
                       E.IntroductoryMessage,
                       E.EstablishmentGroupId,
                       Split.Id AS SplitId,
                       Data,
                       CASE
                           WHEN Data LIKE '#%' THEN
                               SUBSTRING(
                                            Data,
                                            PATINDEX('%[0-9]%', Data),
                                            PATINDEX('%[0-9][^0-9]%', Data + 't') - PATINDEX('%[0-9]%', Data) + 1
                                        )
                       END AS Number
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
                    CROSS APPLY dbo.Split(E.IntroductoryMessage, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.IntroductoryMessage,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

    --10 SeenClientAutoNotification

    UPDATE e
    SET e.SeenClientAutoNotification = new.NewSeenClientAutoNotification
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.SeenClientAutoNotification,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewSeenClientAutoNotification
            FROM
            (
                --Palak
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
                    CROSS APPLY dbo.Split(E.SeenClientAutoNotification, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.SeenClientAutoNotification,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;


    --11 SeenClientAutoSMS

    UPDATE e
    SET e.SeenClientAutoSMS = new.NewSeenClientAutoSMS
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.SeenClientAutoSMS,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewSeenClientAutoSMS
            FROM
            (
                --Palak
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
                    CROSS APPLY dbo.Split(E.SeenClientAutoSMS, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.SeenClientAutoSMS,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

    --12 SeenClientEmailSubject

    UPDATE e
    SET e.SeenClientEmailSubject = new.NewSeenClientEmailSubject
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.SeenClientEmailSubject,
                   s.EstablishmentGroupId,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewSeenClientQuestionId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewSeenClientEmailSubject
            FROM
            (
                --Palak
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
                    CROSS APPLY dbo.Split(E.SeenClientEmailSubject, '##[')
            ) s
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.SeenClientEmailSubject,
                     s.EstablishmentGroupId
        ) New
            ON e.id = new.id;

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
    UPDATE e
    SET e.FeedbackEmailAlert = new.NewFeedbackEmailAlert
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.FeedbackEmailAlert,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewFeedbackEmailAlert
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
                    CROSS APPLY dbo.Split(E.FeedbackEmailAlert, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.FeedbackEmailAlert
        ) New
            ON e.id = new.id;

    --2 FeedbackEmailSubject
    UPDATE e
    SET e.FeedbackEmailSubject = new.NewFeedbackEmailSubject
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.FeedbackEmailSubject,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewFeedbackEmailSubject
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
                    CROSS APPLY dbo.Split(E.FeedbackEmailSubject, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.FeedbackEmailSubject
        ) New
            ON e.id = new.id;

    --3 AdditionalFeedbackEmailBody

    UPDATE e
    SET e.AdditionalFeedbackEmailBody = new.NewAdditionalFeedbackEmailBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalFeedbackEmailBody,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewAdditionalFeedbackEmailBody
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
                    CROSS APPLY dbo.Split(E.AdditionalFeedbackEmailBody, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.AdditionalFeedbackEmailBody
        ) New
            ON e.id = new.id;

    --4 AdditionalFeedbackEmailSubject

    UPDATE e
    SET e.AdditionalFeedbackEmailSubject = new.NewAdditionalFeedbackEmailSubject
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalFeedbackEmailSubject,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) NewAdditionalFeedbackEmailSubject
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
                    CROSS APPLY dbo.Split(E.AdditionalFeedbackEmailSubject, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.AdditionalFeedbackEmailSubject
        ) New
            ON e.id = new.id;

    --5 AdditionalFeedbackSMSBody

    UPDATE e
    SET e.AdditionalFeedbackSMSBody = new.NewAdditionalFeedbackSMSBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.AdditionalFeedbackSMSBody,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ']'
                             ) NewAdditionalFeedbackSMSBody
            FROM
            (
                SELECT E.Id,
                       E.AdditionalFeedbackSMSBody,
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
                           AdditionalFeedbackSMSBody
                    FROM dbo.Establishment E
                        INNER JOIN #temp2 t
                            ON t.Id = E.Id
                               AND t.Name = 'Establishment'
                ) E
                    CROSS APPLY dbo.Split(E.AdditionalFeedbackSMSBody, ']')
            ) s
                LEFT JOIN #Que sc
                    ON sc.OldQueId = s.Number
            GROUP BY s.Id,
                     s.AdditionalFeedbackSMSBody
        ) New
            ON e.id = new.id;

    --6 FeedbackNotificationAlert

    UPDATE e
    SET e.FeedbackNotificationAlert = new.AdditionalFeedbackSMSBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.FeedbackNotificationAlert,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) AdditionalFeedbackSMSBody
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
                    CROSS APPLY dbo.Split(E.FeedbackNotificationAlert, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.FeedbackNotificationAlert
        ) New
            ON e.id = new.id;

    --7 FeedbackSMSAlert


    UPDATE e
    SET e.FeedbackSMSAlert = new.AdditionalFeedbackSMSBody
    FROM dbo.Establishment e
        INNER JOIN
        (
            SELECT s.Id,
                   s.FeedbackSMSAlert,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewQueId IS NOT NULL THEN
                                          REPLACE(s.Data, s.Number, sc.NewQueId)
                                      ELSE
                                          s.Data
                                  END
                                 ),
                                 ' #'
                             ) AdditionalFeedbackSMSBody
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
                    CROSS APPLY dbo.Split(E.FeedbackSMSAlert, '##[')
            ) s
                LEFT JOIN #Questions sc
                    ON sc.OldQueId = s.Number
                       AND sc.NewEgId = s.EstablishmentGroupId
            GROUP BY s.Id,
                     s.FeedbackSMSAlert
        ) New
            ON e.id = new.id;

    -------------------------------------------------------------------------------------------------------------------------------
    UPDATE eg
    SET eg.CustomerQuestion = new.NewCustomerQuestion
    FROM dbo.EstablishmentGroup eg
        INNER JOIN
        (
            SELECT Que.Id,
                   Que.CustomerQuestion,
                   STRING_AGG(   (CASE
                                      WHEN sc.NewSeenClientQuestionId IS NOT NULL THEN
                                          sc.NewSeenClientQuestionId
                                      ELSE
                                          Que.Data
                                  END
                                 ),
                                 ','
                             ) NewCustomerQuestion
            FROM
            (
                SELECT OldEst.Id,
                       OldEst.CustomerQuestion,
                       Split.Id SplitId,
                       Data
                FROM
                (
                    SELECT eg.Id,
                           eg.CustomerQuestion
                    FROM #temp2
                        INNER JOIN dbo.EstablishmentGroup eg
                            ON eg.Id = #temp2.Id
                               AND Name = 'EstablishmentGroupName'
                ) OldEst
                    CROSS APPLY dbo.Split(CustomerQuestion, ',')
            ) Que
                LEFT JOIN #seenClient sc
                    ON sc.OldSeenClientQuestionId = que.Data
            GROUP BY que.Id,
                     que.CustomerQuestion
        ) New
            ON new.id = eg.id;

    UPDATE eg
    SET eg.ContactQuestion = new.NewContactQuestion
    FROM dbo.EstablishmentGroup eg
        INNER JOIN
        (
            SELECT Que.Id,
                   Que.ContactQuestion,
                   STRING_AGG(   (CASE
                                      WHEN sc.newContactQuestionId IS NOT NULL THEN
                                          sc.NewContactQuestionId
                                      ELSE
                                          Que.Data
                                  END
                                 ),
                                 ','
                             ) NewContactQuestion
            FROM
            (
                SELECT OldEst.Id,
                       OldEst.ContactQuestion,
                       Split.Id SplitId,
                       Data
                FROM
                (
                    SELECT eg.Id,
                           eg.ContactQuestion
                    FROM #temp2
                        INNER JOIN dbo.EstablishmentGroup eg
                            ON eg.Id = #temp2.Id
                               AND Name = 'EstablishmentGroupName'
                ) OldEst
                    CROSS APPLY dbo.Split(ContactQuestion, ',')
            ) Que
                LEFT JOIN #ContactQuestions sc
                    ON sc.OldContactQuestionId = que.Data
            GROUP BY que.Id,
                     que.ContactQuestion
        ) New
            ON new.id = eg.id;

    INSERT INTO dbo.CloseLoopTemplate
    SELECT t2.Id,
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
    SELECT t2.Id,
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
    SELECT t2.Id,
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
    SELECT t2.Id,
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
        IsDeleted
    )
    SELECT eg.GroupId,
           eg.Id,
           hs.HeaderId,
           hs.HeaderName,
           hs.HeaderValue,
           GETUTCDATE(),
           @UserId,
           0
    FROM dbo.EstablishmentGroup eg
        INNER JOIN #temp2 t2
            ON t2.Id = eg.Id
               AND t2.Name = 'EstablishmentGroupName'
        INNER JOIN dbo.HeaderSetting hs
            ON hs.EstablishmentGroupId = t2.QueID
               AND hs.IsDeleted = 0;

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
END;
