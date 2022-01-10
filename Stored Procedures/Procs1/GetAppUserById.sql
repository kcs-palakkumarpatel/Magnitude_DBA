-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Apr-2017
-- Description:	<Description,,GetAppUserById>
-- Call SP    :	GetAppUserById
-- =============================================
CREATE PROCEDURE dbo.GetAppUserById @Id BIGINT
AS
BEGIN
    BEGIN TRY
        DECLARE @ContactRoleId VARCHAR(500);
        SELECT @ContactRoleId
            = COALESCE(@ContactRoleId + ',', '') + CONVERT(NVARCHAR(10), dbo.AppUserContactRole.ContactRoleId)
        FROM dbo.AppUserContactRole
        WHERE AppUserId = @Id;

        SELECT [Id] AS Id,
               [Name] AS Name,
               [LastName] AS LastName,
               [Email] AS Email,
               [Mobile] AS Mobile,
               [IsAreaManager] AS IsAreaManager,
               ISNULL([SupplierId], 0) AS SupplierId,
               [UserName] AS UserName,
               [Password] AS Password,
               [GroupId] AS GroupId,
               [ImageName],
               [AccessBulkSMS],
               [AccessRemoveFromStatistics],
               [IsActive],
               @ContactRoleId AS ContactRoleId,
               AllowDeleteFeedback,
               ISNULL(IsDefaultContact, 0) AS IsDefaultContact,
               ISNULL(ResolveAllRights, 1) AS ResolveAllRights,
               ISNULL(DatabaseReferenceOption, 0) AS DatabaseReferenceOption,
               ISNULL(AllowImportContacts, 0) AS AllowImportContacts,
               ISNULL(AllowChangeContact, 0) AS AllowChangeContact,
               ISNULL(IsUserActive, 0) AS IsUserActive,
               ISNULL(AllowExportData, 0) AS AllowExportData,
               ISNULL(AllowUpdateContact, 0) AS AllowUpdateContact,
               ISNULL(IsAllowCreateTemplates, 0) AS IsAllowCreateTemplate,
               ISNULL(AllowTaskAllocations, 0) AS AllowTaskAllocations,
               ISNULL(AllowAnalytics, 0) AS AllowAnalytics
        FROM dbo.[AppUser]
        WHERE [Id] = @Id;

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
        (ERROR_LINE(),
         'dbo.GetAppUserById',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @Id,
         N'',
         GETUTCDATE(),
         @Id
        );
    END CATCH;
END;
