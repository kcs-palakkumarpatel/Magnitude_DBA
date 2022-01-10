-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,InsertOrUpdateEstablishmentGroup>
-- Call SP    :	InsertOrUpdateEstablishmentGroup
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateEstablishmentGroup]
    @Id BIGINT,
    @GroupId BIGINT,
    @EstablishmentGroupName NVARCHAR(100),
    @EstablishmentGroupType NVARCHAR(20),
    @AboutEstablishmentGroup NVARCHAR(MAX),
    @QuestionnaireId BIGINT,
    @SeenClientId BIGINT,
    @HowItWorksId BIGINT,
    @SMSReminder BIT,
    @EmailReminder BIT,
    @TellUsQuestionnaireId BIGINT,
    @AllowToChangeDelayTime BIT,
    @DelayTime NVARCHAR(10),
    @AllowRecurring BIT,
    @SmileOn INT,
    @SadFrom DECIMAL(18, 2),
    @SadTo DECIMAL(18, 2),
    @NeutralFrom DECIMAL(18, 2),
    @NeutralTo DECIMAL(18, 2),
    @HappyFrom DECIMAL(18, 2),
    @HappyTo DECIMAL(18, 2),
    @ReportingToEmail NVARCHAR(MAX),
    @ContactQuestion NVARCHAR(MAX),
    @AutoReportEnable BIT,
    @AutoReportSchedulerId BIGINT,
    @ActivitySmilePeriod INT,
    @UserId BIGINT,
    @PageId BIGINT,
    @IsConfugureManualImage BIT,
    @ImagePath NVARCHAR(MAX),
    @BackgroundColor NVARCHAR(MAX),
    @BorderColor NVARCHAR(MAX),
    @ImageName NVARCHAR(MAX),
    @IsAutoResolved BIT,
    @ConfigureImageSequence INT,
    @DisplaySequence INT,
    @IsGroupKeyword BIT,
    @IsGroupSearch BIT,
    @AttachmentLimit INT,
    @AutoSaveLimit INT,
    @blPIDisplayEnable BIT,
    @blPIOUTDisplayEnable BIT,
    @ActivityImagePath NVARCHAR(MAX),
    @CustomerSMSAlert BIT,
    @CustomerSMSText NVARCHAR(MAX),
    @CustomerEmailAlert BIT,
    @CustomerEmailSubject NVARCHAR(MAX),
    @CustomerEmailText NVARCHAR(MAX),
    @CustomerShow BIT,
    @CustomerInQuestionList NVARCHAR(MAX),
    @directrespondentform BIT,
    @blIncludeAattechment BIT,
    @blInRefNumberHideshow BIT,
    @showHideChat BIT,
    @InitiatorFormTitle NVARCHAR(255),
    @AllowToRefreshTheTaskDaily BIT = 0,
    @AllowTaskAllocations BIT = 0
AS
BEGIN
    DECLARE @Color NVARCHAR(50) = '';
    IF (@EstablishmentGroupType = 'Task')
    BEGIN
        SET @Color = N'#' + CONVERT(VARCHAR(MAX), CRYPT_GEN_RANDOM(3), 2);
    END;

    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[EstablishmentGroup]
        (
            [GroupId],
            [EstablishmentGroupName],
            [EstablishmentGroupType],
            [AboutEstablishmentGroup],
            [QuestionnaireId],
            [SeenClientId],
            [HowItWorksId],
            [SMSReminder],
            [EmailReminder],
            [EstablishmentGroupId],
            [AllowToChangeDelayTime],
            [DelayTime],
            [AllowRecurring],
            [SmileOn],
            SadFrom,
            SadTo,
            NeutralFrom,
            NeutralTo,
            HappyFrom,
            HappyTo,
            [ReportingToEmail],
            [ContactQuestion],
            AutoReportEnable,
            AutoReportSchedulerId,
            ActivitySmilePeriod,
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            IsConfugureManualImage,
            ConfigureImagePath,
            BackgroundColor,
            BorderColor,
            ConfigureImageName,
            IsAutoResolved,
            ConfigureImageSequence,
            DisplaySequence,
            IsGroupKeyword,
            IsGroupSearch,
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
            ShowQueastionCustomer,
            CustomerQuestion,
            DirectRespondentForm,
            IncludeEmailAttachments,
            InFormRefNumber,
            ShowHideChatforCustomer,
            InitiatorFormTitle,
            Color,
            AllowToRefreshTheTaskDaily,
            AllowTaskAllocations
        )
        VALUES
        (@GroupId,
         @EstablishmentGroupName,
         @EstablishmentGroupType,
         @AboutEstablishmentGroup,
         @QuestionnaireId,
         @SeenClientId,
         @HowItWorksId,
         @SMSReminder,
         @EmailReminder,
         NULL,
         @AllowToChangeDelayTime,
         @DelayTime,
         @AllowRecurring,
         @SmileOn,
         @SadFrom,
         @SadTo,
         @NeutralFrom,
         @NeutralTo,
         @HappyFrom,
         @HappyTo,
         @ReportingToEmail,
         @ContactQuestion,
         @AutoReportEnable,
         @AutoReportSchedulerId,
         @ActivitySmilePeriod,
         GETUTCDATE(),
         @UserId,
         0  ,
         @IsConfugureManualImage,
         @ImagePath,
         @BackgroundColor,
         @BorderColor,
         @ImageName,
         @IsAutoResolved,
         @ConfigureImageSequence,
         @DisplaySequence,
         @IsGroupKeyword,
         @IsGroupSearch,
         @AttachmentLimit,
         @AutoSaveLimit,
         @blPIDisplayEnable,
         @blPIOUTDisplayEnable,
         @ActivityImagePath,
         @CustomerSMSAlert,
         @CustomerSMSText,
         @CustomerEmailAlert,
         @CustomerEmailSubject,
         @CustomerEmailText,
         @CustomerShow,
         @CustomerInQuestionList,
         @directrespondentform,
         @blIncludeAattechment,
         @blInRefNumberHideshow,
         @showHideChat,
         @InitiatorFormTitle,
         @Color,
         @AllowToRefreshTheTaskDaily,
         @AllowTaskAllocations
        );
        SELECT @Id = SCOPE_IDENTITY();
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
        (@UserId,
         @PageId,
         'Insert record in table EstablishmentGroup',
         'EstablishmentGroup',
         @Id,
         GETUTCDATE(),
         @UserId,
         0
        );
        DECLARE @TellUsId BIGINT;
        INSERT INTO dbo.[EstablishmentGroup]
        (
            [GroupId],
            [EstablishmentGroupName],
            [EstablishmentGroupType],
            [AboutEstablishmentGroup],
            [QuestionnaireId],
            [SeenClientId],
            [HowItWorksId],
            [SMSReminder],
            [EmailReminder],
            [EstablishmentGroupId],
            [AllowToChangeDelayTime],
            [DelayTime],
            [AllowRecurring],
            [SmileOn],
            SadFrom,
            SadTo,
            NeutralFrom,
            NeutralTo,
            HappyFrom,
            HappyTo,
            ActivitySmilePeriod,
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [AllowToRefreshTheTaskDaily],
            AllowTaskAllocations
        )
        VALUES
        (@GroupId,
         @EstablishmentGroupName + ' Tell Us',
         'Customer',
         @AboutEstablishmentGroup,
         @TellUsQuestionnaireId,
         NULL,
         @HowItWorksId,
         @SMSReminder,
         @EmailReminder,
         NULL,
         @AllowToChangeDelayTime,
         @DelayTime,
         @AllowRecurring,
         @SmileOn,
         @SadFrom,
         @SadTo,
         @NeutralFrom,
         @NeutralTo,
         @HappyFrom,
         @HappyTo,
         @ActivitySmilePeriod,
         GETUTCDATE(),
         @UserId,
         0  ,
         @AllowToRefreshTheTaskDaily,
         @AllowTaskAllocations
        );
        SELECT @TellUsId = SCOPE_IDENTITY();

        UPDATE dbo.EstablishmentGroup
        SET EstablishmentGroupId = @TellUsId
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
        (@UserId,
         @PageId,
         'Insert record in table EstablishmentGroup',
         'EstablishmentGroup',
         @TellUsId,
         GETUTCDATE(),
         @UserId,
         0
        );

        INSERT INTO dbo.[UserRolePermissions]
        (
            [PageID],
            [ActualID],
            [UserID],
            [CreatedOn],
            [CreatedBy],
            [UpdatedOn],
            [UpdatedBy],
            [DeletedOn],
            [DeletedBy],
            [IsDeleted]
        )
        VALUES
        (@PageId, @Id, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);

        INSERT INTO dbo.[UserRolePermissions]
        (
            [PageID],
            [ActualID],
            [UserID],
            [CreatedOn],
            [CreatedBy],
            [UpdatedOn],
            [UpdatedBy],
            [DeletedOn],
            [DeletedBy],
            [IsDeleted]
        )
        VALUES
        (@PageId, @TellUsId, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);

        /* Disha - 24-OCT-2016 - Add modules for Establishment Group  */
        IF (LOWER(@EstablishmentGroupType) = 'customer')
        BEGIN
            INSERT INTO dbo.EstablishmentGroupModuleAlias
            (
                EstablishmentGroupId,
                AppModuleId,
                AliasName,
                CreatedOn,
                CreatedBy
            )
            SELECT @Id,
                   Id,
                   ModuleName,
                   GETUTCDATE(),
                   @UserId
            FROM dbo.AppModule
            WHERE IsDeleted = 0
                  AND Id <> 4;
        END;
        ELSE
        BEGIN
            INSERT INTO dbo.EstablishmentGroupModuleAlias
            (
                EstablishmentGroupId,
                AppModuleId,
                AliasName,
                CreatedOn,
                CreatedBy
            )
            SELECT @Id,
                   Id,
                   ModuleName,
                   GETUTCDATE(),
                   @UserId
            FROM dbo.AppModule
            WHERE IsDeleted = 0;
        END;
        /* Disha - 24-OCT-2016 - Add only 2 modules for Tell Us Establishment Group  */
        INSERT INTO dbo.EstablishmentGroupModuleAlias
        (
            EstablishmentGroupId,
            AppModuleId,
            AliasName,
            CreatedOn,
            CreatedBy
        )
        SELECT @TellUsId,
               Id,
               ModuleName,
               GETUTCDATE(),
               @UserId
        FROM dbo.AppModule
        WHERE IsDeleted = 0
              AND Id <> 4;


    END;
    ELSE
    BEGIN
        UPDATE dbo.[EstablishmentGroup]
        SET [GroupId] = @GroupId,
            [EstablishmentGroupName] = @EstablishmentGroupName,
            [EstablishmentGroupType] = @EstablishmentGroupType,
            [AboutEstablishmentGroup] = @AboutEstablishmentGroup,
            [QuestionnaireId] = @QuestionnaireId,
            [SeenClientId] = @SeenClientId,
            [HowItWorksId] = @HowItWorksId,
            [SMSReminder] = @SMSReminder,
            [EmailReminder] = @EmailReminder,
            --[EstablishmentGroupId] = @EstablishmentGroupId ,
            [AllowToChangeDelayTime] = @AllowToChangeDelayTime,
            [DelayTime] = @DelayTime,
            [AllowRecurring] = @AllowRecurring,
            [SmileOn] = @SmileOn,
            SadFrom = @SadFrom,
            SadTo = @SadTo,
            NeutralFrom = @NeutralFrom,
            NeutralTo = @NeutralTo,
            HappyFrom = @HappyFrom,
            HappyTo = @HappyTo,
            [ReportingToEmail] = @ReportingToEmail,
            ContactQuestion = @ContactQuestion,
            AutoReportEnable = @AutoReportEnable,
            AutoReportSchedulerId = @AutoReportSchedulerId,
            ActivitySmilePeriod = @ActivitySmilePeriod,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            IsConfugureManualImage = @IsConfugureManualImage,
            ConfigureImagePath = @ImagePath,
            BackgroundColor = @BackgroundColor,
            BorderColor = @BorderColor,
            ConfigureImageName = @ImageName,
            IsAutoResolved = @IsAutoResolved,
            ConfigureImageSequence = @ConfigureImageSequence,
            DisplaySequence = @DisplaySequence,
            IsGroupKeyword = @IsGroupKeyword,
            IsGroupSearch = @IsGroupSearch,
            AttachmentLimit = @AttachmentLimit,
            AutoSaveLimit = @AutoSaveLimit,
            PIStatus = @blPIDisplayEnable,
            PIOutStatus = @blPIOUTDisplayEnable,
            ActivityImagePath = @ActivityImagePath,
            CustomerSMSAlert = @CustomerSMSAlert,
            CustomerSMSText = @CustomerSMSText,
            CustomerEmailAlert = @CustomerEmailAlert,
            CustomerEmailSubject = @CustomerEmailSubject,
            CustomerEmailText = @CustomerEmailText,
            ShowQueastionCustomer = @CustomerShow,
            CustomerQuestion = @CustomerInQuestionList,
            DirectRespondentForm = @directrespondentform,
            IncludeEmailAttachments = @blIncludeAattechment,
            InFormRefNumber = @blInRefNumberHideshow,
            ShowHideChatforCustomer = @showHideChat,
            InitiatorFormTitle = @InitiatorFormTitle,
            AllowToRefreshTheTaskDaily = @AllowToRefreshTheTaskDaily,
            AllowTaskAllocations = @AllowTaskAllocations
        WHERE [Id] = @Id;
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
        (@UserId,
         @PageId,
         'Update record in table EstablishmentGroup',
         'EstablishmentGroup',
         @Id,
         GETUTCDATE(),
         @UserId,
         0
        );


        /* Disha - 24-OCT-2016 - Add modules for Establishment Group  */
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.EstablishmentGroupModuleAlias
            WHERE EstablishmentGroupId = @Id
        )
        BEGIN
            IF (LOWER(@EstablishmentGroupType) = 'customer')
            BEGIN
                INSERT INTO dbo.EstablishmentGroupModuleAlias
                (
                    EstablishmentGroupId,
                    AppModuleId,
                    AliasName,
                    CreatedOn,
                    CreatedBy
                )
                SELECT @Id,
                       Id,
                       ModuleName,
                       GETUTCDATE(),
                       @UserId
                FROM dbo.AppModule
                WHERE IsDeleted = 0
                      AND Id <> 4;
            END;
            ELSE
            BEGIN
                INSERT INTO dbo.EstablishmentGroupModuleAlias
                (
                    EstablishmentGroupId,
                    AppModuleId,
                    AliasName,
                    CreatedOn,
                    CreatedBy
                )
                SELECT @Id,
                       Id,
                       ModuleName,
                       GETUTCDATE(),
                       @UserId
                FROM dbo.AppModule
                WHERE IsDeleted = 0;
            END;
        END;
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId,
           ISNULL(@TellUsId, 0) AS InsertedTellUsId;
END;
