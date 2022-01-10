-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Apr-2017
-- Description:	Description,,InsertOrUpdateAppUser>
-- Call SP    :		[InsertOrUpdateAppUser]
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateAppUser
    @Id BIGINT,
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Mobile NVARCHAR(15),
    @IsAreaManager BIT,
    @SupplierId BIGINT,
    @UserName NVARCHAR(50),
    @Password NVARCHAR(50),
    @GroupId BIGINT,
    @AppUserImage NVARCHAR(50),
    @UserId BIGINT,
    @PageId BIGINT,
    @AccessBulkSMS BIT,
    @AccessRemoveFromStatistics BIT,
    @IsActive BIT,
    @ContactRole NVARCHAR(500),
    @AllowDeleteFeedback BIT,
    @IsDefaultContact BIT,
    @ResolveAllRights BIT,
    @DatabaseReferenceOption BIT,
    @AllowImportContacts BIT,
    @AllowChangeContact BIT,
    @IsUserActive BIT,
    @AllowExportReports BIT,
    @AllowUpdateContact BIT,
    @IsAllowCreateTemplates BIT = 0
--@AllowUserToAllocateTasks BIT = Null,
--@AllowUserToEditForms BIT = Null,
--@AllowUserToViewTasks BIT = Null
AS
BEGIN
    IF @SupplierId = 0
        SET @SupplierId = NULL;

    IF @AllowExportReports = NULL
        SET @AllowExportReports = 0;

    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[AppUser]
        (
            [Name],
            [Email],
            [Mobile],
            [IsAreaManager],
            [SupplierId],
            [UserName],
            [Password],
            [GroupId],
            [ImageName],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [AccessBulkSMS],
            [AccessRemoveFromStatistics],
            [IsActive],
            [AllowDeleteFeedback],
            [IsDefaultContact],
            [ResolveAllRights],
            [DatabaseReferenceOption],
            [AllowImportContacts],
            [AllowChangeContact],
            [IsUserActive],
            [AllowExportData],
            [AllowUpdateContact],
            [IsAllowCreateTemplates]
        )
        VALUES
        (@Name, @Email, @Mobile, @IsAreaManager, @SupplierId, @UserName, @Password, @GroupId, @AppUserImage,
         GETUTCDATE(), @UserId, 0, @AccessBulkSMS, @AccessRemoveFromStatistics, @IsActive, @AllowDeleteFeedback,
         @IsDefaultContact, @ResolveAllRights, @DatabaseReferenceOption, @AllowImportContacts, @AllowChangeContact,
         @IsUserActive, @AllowExportReports, @AllowUpdateContact, @IsAllowCreateTemplates);
        SELECT @Id = SCOPE_IDENTITY();

        IF (@ContactRole != NULL)
        BEGIN
            INSERT INTO AppUserContactRole
            (
                AppUserId,
                ContactRoleId
            )
            SELECT @Id,
                   Data
            FROM Split(@ContactRole, ',');
        END;


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
        (@UserId, @PageId, 'Insert record in table AppUser', 'AppUser', @Id, GETUTCDATE(), @UserId, 0);

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
    END;
    ELSE
    BEGIN
        UPDATE dbo.[AppUser]
        SET [Name] = @Name,
            [Email] = @Email,
            [Mobile] = @Mobile,
            [IsAreaManager] = @IsAreaManager,
            [SupplierId] = @SupplierId,
            [UserName] = @UserName,
            [Password] = @Password,
            [GroupId] = @GroupId,
            [ImageName] = @AppUserImage,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            [AccessBulkSMS] = @AccessBulkSMS,
            [AccessRemoveFromStatistics] = @AccessRemoveFromStatistics,
            [IsActive] = @IsActive,
            [AllowDeleteFeedback] = @AllowDeleteFeedback,
            [IsDefaultContact] = @IsDefaultContact,
            [ResolveAllRights] = @ResolveAllRights,
            [DatabaseReferenceOption] = @DatabaseReferenceOption,
            [AllowImportContacts] = @AllowImportContacts,
            [AllowChangeContact] = @AllowChangeContact,
            [IsUserActive] = @IsUserActive,
            [AllowExportData] = @AllowExportReports,
            [AllowUpdateContact] = @AllowUpdateContact,
            [IsAllowCreateTemplates] = @IsAllowCreateTemplates
        WHERE [Id] = @Id;

        DELETE FROM AppUserContactRole
        WHERE AppUserId = @Id;
        IF (ISNULL(@ContactRole, '0') != '0')
        BEGIN
            INSERT INTO AppUserContactRole
            (
                AppUserId,
                ContactRoleId
            )
            SELECT @Id,
                   Data
            FROM Split(@ContactRole, ',');
        END;


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
        (@UserId, @PageId, 'Update record in table AppUser', 'AppUser', @Id, GETUTCDATE(), @UserId, 0);

        UPDATE dbo.AppUserModule
        SET IsDeleted = 1,
            DeletedOn = GETUTCDATE(),
            DeletedBy = @UserId
        WHERE AppUserId = @Id
              AND IsDeleted = 0;

        IF (@IsAreaManager = 0)
        BEGIN
            UPDATE AppManagerUserRights
            SET IsDeleted = 1
            WHERE UserId = @Id;
        END;
        --IF (@IsDefaultContact = 0)
        --BEGIN
        --    UPDATE dbo.DefaultContact
        --    SET IsDeleted = 1
        --    WHERE AppUserId = @Id;
        --END;
    END;

    INSERT INTO dbo.AppUserPasswordLog
    (
        UserId,
        [Name],
        [Email],
        UserName,
        [PassWord],
        CreatedOn,
        CreatedBy
    )
    VALUES
    (@Id, @Name, @Email, @UserName, @Password, GETUTCDATE(), @UserId);

    SELECT ISNULL(@Id, 0) AS InsertedId;
END;
