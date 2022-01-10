--SELECT TOP 1 * FROM dbo.SeenClient ORDER BY Id DESC
--SELECT * FROM dbo.SeenClientQuestions WHERE SeenClientId = 3076
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Apr-2017
-- Description:	Description,,InsertOrUpdateAppUser>
-- Call SP    :		[InsertOrUpdateAppUser_New]
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateAppUser_New
    @Id BIGINT,
    @Name NVARCHAR(100),
	@LastName NVARCHAR(100),
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
    @AllowTaskAllocations BIT,
    @AllowAnalytics BIT
AS
BEGIN
SET NOCOUNT ON;
    BEGIN TRY
        IF @SupplierId = 0
            SET @SupplierId = NULL;

        IF @AllowExportReports = NULL
            SET @AllowExportReports = 0;


        DECLARE @oldPW VARCHAR(100) =
                (
                    SELECT [Password] FROM dbo.[AppUser] WHERE [Id] = @Id
                );

        IF (@Id = 0)
        BEGIN
            INSERT INTO dbo.[AppUser]
            (
                [Name],
                [LastName],
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
                [AllowTaskAllocations],
                [AllowAnalytics]
            )
            VALUES
            (@Name, @LastName, @Email, @Mobile, @IsAreaManager, @SupplierId, @UserName, @Password, @GroupId, @AppUserImage,
             GETUTCDATE(), @UserId, 0, @AccessBulkSMS, @AccessRemoveFromStatistics, @IsActive, @AllowDeleteFeedback,
             @IsDefaultContact, @ResolveAllRights, @DatabaseReferenceOption, @AllowImportContacts, @AllowChangeContact,
             @IsUserActive, @AllowExportReports, @AllowUpdateContact, @AllowTaskAllocations, @AllowAnalytics);
            SELECT @Id = SCOPE_IDENTITY();

            IF (@ContactRole != NULL)
            BEGIN
                INSERT INTO dbo.AppUserContactRole
                (
                    AppUserId,
                    ContactRoleId
                )
                SELECT @Id,
                       Data
                FROM dbo.Split(@ContactRole, ',');
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
				[LastName] = @LastName,
                [Email] = @Email,
                [Mobile] = @Mobile,
                [IsAreaManager] = @IsAreaManager,
                [SupplierId] = @SupplierId,
                [UserName] = @UserName,
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
                [AllowTaskAllocations] = @AllowTaskAllocations,
                [AllowAnalytics] = @AllowAnalytics
            WHERE [Id] = @Id;

            DELETE FROM dbo.AppUserContactRole
            WHERE AppUserId = @Id;
            IF (ISNULL(@ContactRole, '0') != '0')
            BEGIN
                INSERT INTO dbo.AppUserContactRole
                (
                    AppUserId,
                    ContactRoleId
                )
                SELECT @Id,
                       Data
                FROM dbo.Split(@ContactRole, ',');
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
                UPDATE dbo.AppManagerUserRights
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

        SELECT ISNULL(@Id, 0) AS InsertedId;

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
         GETUTCDATE(), @Id, N'', GETUTCDATE(), @Id);
    END CATCH;
SET NOCOUNT OFF;
END;

