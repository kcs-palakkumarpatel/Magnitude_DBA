-- =============================================
-- Author:			Mitesh Kachhadiya
-- Create date:		17-DEC-2021
-- Description:		Description,,UpdateAppUsersAccess>
-- Call SP    :		[UpdateAppUsersAccess] '5,15,25', 1,0,1,0,1,0,1,0,1,0,1,0,1,0, null

-- =============================================
CREATE PROCEDURE dbo.UpdateAppUsersAccess
    @AppUserIds NVARCHAR(MAX),
    @IsAreaManager BIT,
    @AccessBulkSMS BIT,
    @AccessRemoveFromStatistics BIT,
    @AllowDeleteFeedback BIT,
    @IsActive BIT,
    @IsDefaultContact BIT,
    @ResolveAllRights BIT,
    @DatabaseReferenceOption BIT,
    @AllowImportContacts BIT,
    @AllowChangeContact BIT,
    @AllowUpdateContact BIT,
    @IsUserActive BIT,
    @AllowExportReports BIT,
    @AllowTaskAllocations BIT,
    @AllowAnalytics BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @Max INT = 0,
                @TempId BIGINT;
        DECLARE @Temp TABLE (Id BIGINT);

        INSERT INTO @Temp
        SELECT Data
        FROM dbo.Split(@AppUserIds, ',');

        SELECT @Max = COUNT(*)
        FROM @Temp;
        ------ While loop for APPuserIds ---------
        WHILE (@Max > 0)
        BEGIN
            SET @TempId =
            (
                SELECT TOP 1 Id FROM @Temp
            );

            ----ALTER TABLE dbo.AppUser DISABLE TRIGGER trg_AppUser_AfterUpdate;
            UPDATE dbo.[AppUser]
            SET [UpdatedOn] = GETUTCDATE(),
                [IsAreaManager] = ISNULL(@IsAreaManager, [IsAreaManager]),
                [AccessBulkSMS] = ISNULL(@AccessBulkSMS, [AccessBulkSMS]),
                [AccessRemoveFromStatistics] = ISNULL(@AccessRemoveFromStatistics, [AccessRemoveFromStatistics]),
                [AllowDeleteFeedback] = ISNULL(@AllowDeleteFeedback, [AllowDeleteFeedback]),
                [IsActive] = ISNULL(@IsActive, [IsActive]),
                [IsDefaultContact] = ISNULL(@IsDefaultContact, [IsDefaultContact]),
                [ResolveAllRights] = ISNULL(@ResolveAllRights, [ResolveAllRights]),
                [DatabaseReferenceOption] = ISNULL(@DatabaseReferenceOption, [DatabaseReferenceOption]),
                [AllowImportContacts] = ISNULL(@AllowImportContacts, [AllowImportContacts]),
                [AllowChangeContact] = ISNULL(@AllowChangeContact, [AllowChangeContact]),
                [AllowUpdateContact] = ISNULL(@AllowUpdateContact, [AllowUpdateContact]),
                [IsUserActive] = ISNULL(@IsUserActive, [IsUserActive]),
                [AllowExportData] = ISNULL(@AllowExportReports, [AllowExportData]),
                [AllowTaskAllocations] = ISNULL(@AllowTaskAllocations, [AllowTaskAllocations]),
                [AllowAnalytics] = ISNULL(@AllowAnalytics, [AllowAnalytics])
            WHERE [Id] = @TempId;
            --IN (
            --                        SELECT Data FROM dbo.Split('173,202,443', ',')
            --                    );


            ----DECLARE @SqlQuery NVARCHAR(MAX) = ' UPDATE dbo.[AppUser] SET ';
            ------DECLARE @IsAreaManager BIT  = 1;  SELECT 
            ----IF (@IsAreaManager IS NOT NULL)
            ----    SET @SqlQuery += '[IsAreaManager] = ' + CONVERT(VARCHAR(5), @IsAreaManager) + ', ';
            ----IF (@AccessBulkSMS IS NOT NULL)
            ----    SET @SqlQuery += '[AccessBulkSMS] = ' + CONVERT(VARCHAR(5), @AccessBulkSMS) + ', ';
            ----IF (@AccessRemoveFromStatistics IS NOT NULL)
            ----    SET @SqlQuery += '[AccessRemoveFromStatistics] = ' + CONVERT(VARCHAR(5), @AccessRemoveFromStatistics)
            ----                     + ', ';
            ----IF (@AllowDeleteFeedback IS NOT NULL)
            ----    SET @SqlQuery += '[AllowDeleteFeedback] = ' + CONVERT(VARCHAR(5), @AllowDeleteFeedback) + ', ';
            ----IF (@IsActive IS NOT NULL)
            ----    SET @SqlQuery += '[IsActive] = ' + CONVERT(VARCHAR(5), @IsActive) + ', ';
            ----IF (@IsDefaultContact IS NOT NULL)
            ----    SET @SqlQuery += '[IsDefaultContact] = ' + CONVERT(VARCHAR(5), @IsDefaultContact) + ', ';
            ----IF (@ResolveAllRights IS NOT NULL)
            ----    SET @SqlQuery += '[ResolveAllRights] = ' + CONVERT(VARCHAR(5), @ResolveAllRights) + ', ';
            ----IF (@DatabaseReferenceOption IS NOT NULL)
            ----    SET @SqlQuery += '[DatabaseReferenceOption] = ' + CONVERT(VARCHAR(5), @DatabaseReferenceOption) + ', ';
            ----IF (@AllowImportContacts IS NOT NULL)
            ----    SET @SqlQuery += '[AllowImportContacts] = ' + CONVERT(VARCHAR(5), @AllowImportContacts) + ', ';
            ----IF (@AllowChangeContact IS NOT NULL)
            ----    SET @SqlQuery += '[AllowChangeContact] = ' + CONVERT(VARCHAR(5), @AllowChangeContact) + ', ';
            ----IF (@AllowUpdateContact IS NOT NULL)
            ----    SET @SqlQuery += '[AllowUpdateContact] = ' + CONVERT(VARCHAR(5), @AllowUpdateContact) + ', ';
            ----IF (@IsUserActive IS NOT NULL)
            ----    SET @SqlQuery += '[IsUserActive] = ' + CONVERT(VARCHAR(5), @IsUserActive) + ', ';
            ----IF (@AllowExportReports IS NOT NULL)
            ----    SET @SqlQuery += '[AllowExportData] = ' + CONVERT(VARCHAR(5), @AllowExportReports) + ', ';
            ----IF (@AllowTaskAllocations IS NOT NULL)
            ----    SET @SqlQuery += '[AllowTaskAllocations] = ' + CONVERT(VARCHAR(5), @AllowTaskAllocations) + ', ';
            ----IF (@AllowAnalytics IS NOT NULL)
            ----    SET @SqlQuery += '[AllowAnalytics] = ' + CONVERT(VARCHAR(5), @AllowAnalytics) + ', ';

            ----SET @SqlQuery += '[UpdatedOn] = GETUTCDATE() WHERE [Id] = ' + CONVERT(VARCHAR(15), @TempId);
            ----PRINT (@SqlQuery);
            ----EXEC (@SqlQuery);



            --ALTER TABLE dbo.AppUser ENABLE TRIGGER trg_AppUser_AfterUpdate;
            PRINT (@TempId);
            SET @Max = @Max - 1;
            DELETE FROM @Temp
            WHERE Id = @TempId;
        END;

        PRINT ('Success');
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
         'dbo.UpdateAppUsersAccess',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'' + @AppUserIds,
         GETUTCDATE(),
         0
        );
    END CATCH;
    SET NOCOUNT OFF;
END;

-- SELECT TOP 20    * FROM dbo.ErrorLog ORDER BY 1 DESC;
