-- =============================================
-- Author:      Bhavik Patel
-- Create Date: 22-02-2021
-- Description: Insert Task by Import Excel file
-- SP call:[InsertAppUserByExcelImport]
-- =============================================
CREATE PROCEDURE dbo.InsertAppUserByExcelImport (@ImportAppUserTable ImportAppUserTypeTableType READONLY)
AS
BEGIN
    IF OBJECT_ID('tempdb..#TempUserValidation', 'U') IS NOT NULL
        DROP TABLE #TempUserValidation;
    CREATE TABLE #TempUserValidation
    (
        Name NVARCHAR(500),
        Email NVARCHAR(500),
        Mobile NVARCHAR(500),
        UserName NVARCHAR(500),
        Message NVARCHAR(2000),
        ErrorMessage NVARCHAR(MAX)
    );
    DECLARE @TotalRecords BIGINT = 0;
    DECLARE @Counter BIGINT = 1;
    DECLARE @GroupID BIGINT = 0;
    DECLARE @UserName VARCHAR(100);
    DECLARE @AppUserId BIGINT;
    DECLARE @UserId BIGINT;
    DECLARE @Email VARCHAR(100);
    DECLARE @ErrorMessage VARCHAR(MAX);
    SET @TotalRecords =
    (
        SELECT COUNT(*) FROM @ImportAppUserTable
    );
    --DECLARE @TempAppUser AS TABLE
    IF OBJECT_ID('tempdb..#TempAppUser', 'U') IS NOT NULL
        DROP TABLE #TempAppUser;
    CREATE TABLE #TempAppUser
    (
        Id INT,
        UserId INT,
        Name NVARCHAR(100),
        Email NVARCHAR(100),
        Mobile NVARCHAR(100),
        IsManager BIT,
        AccessBulkSMS BIT,
        RemoveFromStatistics BIT,
        AllowDeletingFeedback BIT,
        IsActive BIT,
        AllowDefaultContact BIT,
        AllowResolveThread BIT,
        AllowImportOptions BIT,
        AllowImportContacts BIT,
        AllowViewContact BIT,
        AllowChangeContact BIT,
        ActiveUser BIT,
        AllowExportReports BIT,
        Allowusertoeditupdateforms BIT,
        SupplierId BIGINT,
        ImageName NVARCHAR(100),
        UserName NVARCHAR(100),
        Password NVARCHAR(100),
        GroupId BIGINT,
        ActivityName NVARCHAR(MAX),
        SalesEstablishment NVARCHAR(MAX),
        CustomerEstablishment NVARCHAR(MAX),
        ModuleName NVARCHAR(MAX),
        AllowAnalytics BIT,
        AllowTaskAllocations BIT
    );

    INSERT INTO #TempAppUser
    (
        Id,
        UserId,
        Name,
        Email,
        Mobile,
        IsManager,
        UserName,
        Password,
        GroupId,
        ImageName,
        AccessBulkSMS,
        RemoveFromStatistics,
        IsActive,
        AllowDeletingFeedback,
        AllowDefaultContact,
        AllowResolveThread,
        AllowImportOptions,
        AllowImportContacts,
        AllowViewContact,
        AllowChangeContact,
        ActiveUser,
        AllowExportReports,
        Allowusertoeditupdateforms,
        SalesEstablishment,
        CustomerEstablishment,
        ActivityName,
        ModuleName,
        AllowAnalytics,
        AllowTaskAllocations
    --ModuleAliasName 
    )
    SELECT Id,
           UserId,
           Name,
           Email,
           Mobile,
           IsManager,
           UserName,
           Password,
           (
               SELECT Id
               FROM [Group]
               WHERE LOWER(dbo.TRIM(GroupName)) = LOWER(dbo.TRIM(tmpImport.GroupName))
           ) AS GroupName,
           NULL,
           AccessBulkSMS,
           RemoveFromStatistics,
           IsActive,
           AllowDeletingFeedback,
           AllowDefaultContact,
           AllowResolveThread,
           AllowImportOptions,
           AllowImportContacts,
           AllowViewContact,
           AllowChangeContact,
           ActiveUser,
           AllowExportReports,
           Allowusertoeditupdateforms,
           SalesEstablishment,
           CustomerEstablishment,
           ActivityName,
           ModuleName,
           (CASE
                WHEN ISNULL(IsManager,0) = 0 THEN
                    0
                ELSE
                    AllowAnalytics
            END
           ),
           (CASE
                WHEN ISNULL(IsManager,0) = 0 THEN
                    0
                ELSE
                    AllowTaskAllocations
            END
           )
    FROM @ImportAppUserTable tmpImport;

    SET @UserId =
    (
        SELECT TOP 1 UserId FROM #TempAppUser
    );

    DECLARE @activitiycounter BIGINT;
    DECLARE @TotalActivityCounter BIGINT;

    DECLARE @modulecounter BIGINT;
    DECLARE @totalmodule BIGINT;



    --End

    DECLARE @TempActivityName NVARCHAR(MAX);
    DECLARE @TempSalesEstablishment NVARCHAR(MAX);
    DECLARE @TempCustomerEstablishment NVARCHAR(MAX);
    DECLARE @TempModuleName NVARCHAR(MAX);
    WHILE (@Counter <= @TotalRecords)
    BEGIN
        SET @UserName =
        (
            SELECT UserName FROM #TempAppUser WHERE Id = @Counter
        );
        SET @Email =
        (
            SELECT Email FROM #TempAppUser WHERE Id = @Counter
        );
        SET @GroupID =
        (
            SELECT GroupId FROM #TempAppUser WHERE Id = @Counter
        );

        IF NOT EXISTS
        (
            SELECT *
            FROM AppUser appuser
            WHERE LOWER(appuser.UserName) = LOWER(dbo.TRIM(@UserName))
                  OR LOWER(appuser.Email) = LOWER(dbo.TRIM(@Email))
        )
        BEGIN
            BEGIN TRY


                --start Insert records in AppUser
                INSERT INTO AppUser
                (
                    Name,
                    Email,
                    Mobile,
                    IsAreaManager,
                    UserName,
                    Password,
                    GroupId,
                    ImageName,
                    AccessBulkSMS,
                    AccessRemoveFromStatistics,
                    IsActive,
                    AllowDeleteFeedback,
                    IsDefaultContact,
                    ResolveAllRights,
                    DatabaseReferenceOption,
                    AllowImportContacts,
                    AllowChangeContact,
                    IsUserActive,
                    AllowExportData,
                    AllowUpdateContact,
                    IsAllowCreateTemplates,
                    AllowAnalytics,
                    AllowTaskAllocations,
                    CreatedBy,
                    CreatedOn
                )
                SELECT Name,
                       Email,
                       Mobile,
                       IsManager,
                       UserName,
                       Password,
                       GroupId,
                       ImageName,
                       AccessBulkSMS,
                       RemoveFromStatistics,
                       IsActive,
                       AllowDeletingFeedback,
                       AllowDefaultContact,
                       AllowResolveThread,
                       AllowImportOptions,
                       AllowImportContacts,
                       AllowChangeContact,
                       ActiveUser,
                       AllowExportReports,
                       AllowViewContact,
                       1,
                       AllowAnalytics,
                       AllowTaskAllocations,
                       UserId,
                       GETUTCDATE()
                FROM #TempAppUser tmpuser
                WHERE tmpuser.Id = @Counter;
                SET @AppUserId = SCOPE_IDENTITY();
                --End Insert records in appuser

                --Insert data in activity log from Import excel when import data from excel
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
                 1  ,
                 'Insert record in table AppUser from Import Excel',
                 'AppUser',
                 @AppUserId,
                 GETUTCDATE(),
                 @UserId,
                 0
                );
                --Insert data in activity log from and when import data from excel

                --Start Insert Into RolePermission
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
                (1, @AppUserId, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);
                --End Insert Into Role Permission


                --Start AppModule for activity name


                SELECT @TempActivityName = tmpuser.ActivityName
                FROM #TempAppUser tmpuser
                WHERE tmpuser.Id = @Counter;


                IF OBJECT_ID('tempdb..#TempActivityName', 'U') IS NOT NULL
                    DROP TABLE #TempActivityName;
                CREATE TABLE #TempActivityName
                (
                    RowNumber BIGINT,
                    Id BIGINT,
                    EstablishmentGroupName NVARCHAR(MAX)
                );
                INSERT INTO #TempActivityName
                SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                       Id,
                       EstablishmentGroupName
                FROM EstablishmentGroup
                WHERE LOWER(dbo.TRIM(EstablishmentGroupName)) IN (
                                                                     SELECT Data FROM dbo.Split(
                                                                                                   LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                   ','
                                                                                               )
                                                                 );
                --end AppModule for activity name

                --start Sales Establishment
                SELECT @TempSalesEstablishment = tmpuser.SalesEstablishment
                FROM #TempAppUser tmpuser
                WHERE tmpuser.Id = @Counter;
                --End Sales




                IF OBJECT_ID('tempdb..#NewTempSalesEstablishment', 'U') IS NOT NULL
                    DROP TABLE #NewTempSalesEstablishment;
                CREATE TABLE #NewTempSalesEstablishment
                (
                    RowNumber BIGINT,
                    Id BIGINT,
                    GroupId BIGINT,
                    EstablishmentGroupName NVARCHAR(MAX),
                    EstablishmentGroupType NVARCHAR(MAX),
                    EstablishmentId BIGINT,
                    EstablishmentGroupId BIGINT,
                    EstablishmentName NVARCHAR(MAX)
                );
                INSERT INTO #NewTempSalesEstablishment
                SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                       G.Id AS Id,
                       G.GroupId AS GroupId,
                       G.EstablishmentGroupName,
                       G.EstablishmentGroupType,
                       E.Id AS EstablishmentId,
                       E.EstablishmentGroupId,
                       E.EstablishmentName
                FROM EstablishmentGroup G
                    INNER JOIN Establishment E
                        ON G.Id = E.EstablishmentGroupId
                WHERE G.GroupId = @GroupID
                      AND LOWER(G.EstablishmentGroupName) IN (
                                                                 SELECT Data FROM dbo.Split(
                                                                                               LOWER(dbo.TRIM(@TempActivityName)),
                                                                                               ','
                                                                                           )
                                                             )
                      AND G.GroupId = @GroupID
                      AND LOWER(E.EstablishmentName) IN (
                                                            SELECT Data
                                                            FROM dbo.Split(
                                                                              LOWER(dbo.TRIM(@TempSalesEstablishment)),
                                                                              ','
                                                                          )
                                                        )
					  AND ISNULL(E.IsDeleted,0) = 0
					  AND ISNULL(G.IsDeleted,0) = 0;


                DECLARE @Appcounter INT = 1;
                DECLARE @TOTALESTABLISHMENT INT = 0;
                SET @TOTALESTABLISHMENT =
                (
                    SELECT COUNT(*) FROM #NewTempSalesEstablishment
                );
                WHILE @Appcounter <= @TOTALESTABLISHMENT
                BEGIN
                    DECLARE @EstablishmentId BIGINT;
                    SET @EstablishmentId =
                    (
                        SELECT EstablishmentId
                        FROM #NewTempSalesEstablishment
                        WHERE RowNumber = @Appcounter
                    );
                    IF NOT EXISTS
                    (
                        SELECT EstablishmentId
                        FROM AppUserEstablishment
                        WHERE EstablishmentId = @EstablishmentId
                              AND AppUserId = @AppUserId AND ISNULL(IsDeleted,0) = 0
                    )
                    BEGIN
                        INSERT INTO [AppUserEstablishment]
                        (
                            AppUserId,
                            EstablishmentId,
                            EstablishmentType,
                            UpdatedBy,
                            UpdatedOn
                        )
                        SELECT @AppUserId,
                               EstablishmentId,
                               EstablishmentGroupType,
                               @UserId,
                               GETUTCDATE()
                        FROM #NewTempSalesEstablishment
                        WHERE RowNumber = @Appcounter;
                    END;
                    SET @Appcounter = @Appcounter + 1;
                    CONTINUE;
                END;
                --end Sales Establishment

                --start Customer Establishment
                SELECT @TempCustomerEstablishment = tmpuser.CustomerEstablishment
                FROM #TempAppUser tmpuser
                WHERE tmpuser.Id = @Counter;


                IF OBJECT_ID('tempdb..#NewTempCustomersEstablishment', 'U') IS NOT NULL
                    DROP TABLE #NewTempCustomersEstablishment;
                CREATE TABLE #NewTempCustomersEstablishment
                (
                    RowNumber BIGINT,
                    Id BIGINT,
                    GroupId BIGINT,
                    EstablishmentGroupName NVARCHAR(MAX),
                    EstablishmentGroupType NVARCHAR(MAX),
                    EstablishmentId BIGINT,
                    EstablishmentGroupId BIGINT,
                    EstablishmentName NVARCHAR(MAX)
                );
                INSERT INTO #NewTempCustomersEstablishment
                SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                       G.Id AS Id,
                       G.GroupId AS GroupId,
                       G.EstablishmentGroupName,
                       G.EstablishmentGroupType,
                       E.Id AS EstablishmentId,
                       E.EstablishmentGroupId,
                       E.EstablishmentName
                FROM EstablishmentGroup G
                    INNER JOIN Establishment E
                        ON G.Id = E.EstablishmentGroupId
                WHERE G.GroupId = @GroupID
                      AND LOWER(G.EstablishmentGroupName) IN (
                                                                 SELECT Data FROM dbo.Split(
                                                                                               LOWER(dbo.TRIM(@TempActivityName)),
                                                                                               ','
                                                                                           )
                                                             )
                      AND LOWER(E.EstablishmentName) IN (
                                                            SELECT Data
                                                            FROM dbo.Split(
                                                                              LOWER(dbo.TRIM(@TempCustomerEstablishment)),
                                                                              ','
                                                                          )
                                                        )
					  AND ISNULL(E.IsDeleted,0) = 0
					  AND ISNULL(G.IsDeleted,0) = 0;



                DECLARE @Appcustomercounter INT = 1;
                DECLARE @TOTALcustomerESTABLISHMENT INT = 0;
                SET @TOTALcustomerESTABLISHMENT =
                (
                    SELECT COUNT(*) FROM #NewTempCustomersEstablishment
                );
                WHILE @Appcustomercounter <= @TOTALcustomerESTABLISHMENT
                BEGIN
                    DECLARE @forEstablishmentId BIGINT;
                    SET @forEstablishmentId =
                    (
                        SELECT EstablishmentId
                        FROM #NewTempCustomersEstablishment
                        WHERE RowNumber = @Appcustomercounter
                    );
                    IF NOT EXISTS
                    (
                        SELECT EstablishmentId
                        FROM AppUserEstablishment
                        WHERE EstablishmentId = @forEstablishmentId
                              AND AppUserId = @AppUserId
							  AND ISNULL(IsDeleted,0) = 0
                    )
                    BEGIN
                        INSERT INTO [AppUserEstablishment]
                        (
                            AppUserId,
                            EstablishmentId,
                            EstablishmentType,
                            UpdatedBy,
                            UpdatedOn
                        )
                        SELECT @AppUserId,
                               EstablishmentId,
                               EstablishmentGroupType,
                               @UserId,
                               GETUTCDATE()
                        FROM #NewTempCustomersEstablishment
                        WHERE RowNumber = @Appcustomercounter;
                    END;
                    --SELECT Id,Id , GroupId ,EstablishmentGroupName ,EstablishmentGroupType ,EstablishmentId ,EstablishmentGroupId ,EstablishmentName  FROM #NewTempSalesEstablishment WHERE RowNumber = @Appcounter						
                    SET @Appcustomercounter = @Appcustomercounter + 1;
                    CONTINUE;
                END;

                --end customer establishment 			    


                --Start AppModule


                --Start AppModule for Module Name


                SELECT @TempModuleName = tmpuser.ModuleName
                FROM #TempAppUser tmpuser
                WHERE tmpuser.Id = @Counter;


                IF OBJECT_ID('tempdb..#TempAppModuleName', 'U') IS NOT NULL
                    DROP TABLE #TempAppModuleName;
                CREATE TABLE #TempAppModuleName
                (
                    RowNumber BIGINT,
                    Id BIGINT,
                    ModuleName NVARCHAR(MAX),
                    AliasName NVARCHAR(MAX)
                );
                INSERT INTO #TempAppModuleName
                SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                       Id,
                       ModuleName,
                       ''
                FROM AppModule
                WHERE LOWER(dbo.TRIM(ModuleName)) IN (
                                                         SELECT Data FROM dbo.Split(
                                                                                       LOWER(dbo.TRIM(@TempModuleName)),
                                                                                       ','
                                                                                   )
                                                     )
                     
				 AND ISNULL(IsDeleted,0) = 0;


                --end AppModule for Module Name

                SET @activitiycounter = 1;
                SET @TotalActivityCounter =
                (
                    SELECT COUNT(*) FROM #TempActivityName
                );
                WHILE @activitiycounter <= @TotalActivityCounter
                BEGIN
                    SET @modulecounter = 1;
                    SET @totalmodule =
                    (
                        SELECT COUNT(*) FROM #TempAppModuleName
                    );
                    DECLARE @EstablishmentGroupId BIGINT;
                    SET @EstablishmentGroupId =
                    (
                        SELECT Id FROM #TempActivityName WHERE RowNumber = @activitiycounter
                    );
                    WHILE @modulecounter <= @totalmodule
                    BEGIN

                        DECLARE @AliasName VARCHAR(500);
                        DECLARE @moduleid INT = 0;
                        SET @moduleid =
                        (
                            SELECT Id FROM #TempAppModuleName WHERE RowNumber = @modulecounter
                        );
                        SET @AliasName =
                        (
                            SELECT AliasName
                            FROM EstablishmentGroupModuleAlias
                            WHERE EstablishmentGroupId = @EstablishmentGroupId
                                  AND AppModuleId = @moduleid
                        );

                        IF @AliasName <> ''
                        BEGIN
                            IF NOT EXISTS
                            (
                                SELECT Id
                                FROM AppUserModule
                                WHERE AppUserId = @AppUserId
                                      AND EstablishmentGroupId = @EstablishmentGroupId
                                      AND AppModuleId = @moduleid
									  AND ISNULL(IsDeleted,0) = 0
                            )
                            BEGIN

                                INSERT INTO AppUserModule
                                (
                                    AppUserId,
                                    AppModuleId,
                                    AliasName,
                                    IsSelected,
                                    EstablishmentGroupId,
                                    CreatedBy,
                                    CreatedOn
                                )
                                VALUES
                                (@AppUserId, @moduleid, @AliasName, 1, @EstablishmentGroupId, @UserId, GETUTCDATE());
                            END;
                            ELSE
                            BEGIN
                                UPDATE AppUserModule
                                SET IsSelected = 1
                                WHERE AppUserId = @AppUserId
                                      AND EstablishmentGroupId = @EstablishmentGroupId
                                      AND AppModuleId = @moduleid;
                            END;
                        END;
                        UPDATE AppUserModule
                        SET IsSelected = 1
                        WHERE AppUserId = @AppUserId
                              AND AppModuleId = @moduleid;
                        --where AppUserId = @AppUserId  AND EstablishmentGroupId = @EstablishmentGroupId AND AppModuleId = @moduleid




                        SET @modulecounter = @modulecounter + 1;
                        CONTINUE;
                    END;


                    SET @activitiycounter = @activitiycounter + 1;
                    CONTINUE;
                END;
            END TRY
            BEGIN CATCH
                --SELECT
                --ERROR_NUMBER() AS ErrorNumber,
                --ERROR_STATE() AS ErrorState,
                --ERROR_SEVERITY() AS ErrorSeverity,
                --ERROR_PROCEDURE() AS ErrorProcedure,
                --ERROR_LINE() AS ErrorLine,
                --ERROR_MESSAGE() AS ErrorMessage;
                SET @ErrorMessage = 'User not Imported Successfully.';
            END CATCH;
            DECLARE @IsUserName VARCHAR(500);
            SET @IsUserName =
            (
                SELECT UserName FROM #TempAppUser tmpuser WHERE Id = @Counter
            );
            IF NOT EXISTS
            (
                SELECT Name
                FROM #TempUserValidation
                WHERE UserName = @IsUserName
            )
            BEGIN
                INSERT INTO #TempUserValidation
                (
                    Name,
                    Email,
                    Mobile,
                    UserName,
                    Message,
                    ErrorMessage
                )
                SELECT Name,
                       Email,
                       Mobile,
                       UserName,
                       CASE
                           WHEN @ErrorMessage <> '' THEN
                               ''
                           ELSE
                               'Record Inserted'
                       END,
                       @ErrorMessage
                FROM #TempAppUser tmpuser
                WHERE Id = @Counter
                      AND UserName = @IsUserName;
            END;
        -- print 1
        END;
        ELSE
        BEGIN
            DECLARE @ExistingAppUserId BIGINT;
            SET @ExistingAppUserId =
            (
                SELECT Id
                FROM AppUser appuser
                WHERE LOWER(appuser.UserName) = LOWER(dbo.TRIM(@UserName))
                      AND LOWER(appuser.Email) = LOWER(dbo.TRIM(@Email))
					  AND appuser.IsDeleted = 0
            );
            IF @ExistingAppUserId > 0
            BEGIN
                BEGIN TRY
                    IF EXISTS
                    (
                        SELECT Id
                        FROM AppUser
                        WHERE Id = @ExistingAppUserId
                              AND GroupId = @GroupID
                    )
                    BEGIN
                        UPDATE t1
                        SET GroupId = tmp.GroupId,
                            UpdatedBy = tmp.UserId,
                            UpdatedOn = GETUTCDATE()
                        FROM AppUser t1
                            INNER JOIN #TempAppUser tmp
                                ON t1.UserName = tmp.UserName
                                   AND t1.Email = tmp.Email
                        WHERE t1.Id = @ExistingAppUserId;

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
                         1  ,
                         'Update record in table AppUser from when Import Excel',
                         'AppUser',
                         @ExistingAppUserId,
                         GETUTCDATE(),
                         @UserId,
                         0
                        );



                        --Start AppModule for activity name

                        SELECT @TempActivityName = tmpuser.ActivityName
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;


                        IF OBJECT_ID('tempdb..#TempActivityName1', 'U') IS NOT NULL
                            DROP TABLE #TempActivityName1;
                        CREATE TABLE #TempActivityName1
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX)
                        );
                        INSERT INTO #TempActivityName1
                        SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                               Id,
                               EstablishmentGroupName
                        FROM EstablishmentGroup
                        WHERE LOWER(dbo.TRIM(EstablishmentGroupName)) IN (
                                                                             SELECT Data FROM dbo.Split(
                                                                                                           LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                           ','
                                                                                                       )
                                                                         )
						AND ISNULL(IsDeleted,0) = 0;
                        --end AppModule for activity name

                        --start Sales Establishment

                        SELECT @TempSalesEstablishment = tmpuser.SalesEstablishment
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;
                        --End Sales


                        --Start Sales Establishment
                        IF OBJECT_ID('tempdb..#NewTempSalesEstablishment1', 'U') IS NOT NULL
                            DROP TABLE #NewTempSalesEstablishment1;
                        CREATE TABLE #NewTempSalesEstablishment1
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            GroupId BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX),
                            EstablishmentGroupType NVARCHAR(MAX),
                            EstablishmentId BIGINT,
                            EstablishmentGroupId BIGINT,
                            EstablishmentName NVARCHAR(MAX)
                        );
                        INSERT INTO #NewTempSalesEstablishment1
                        SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                               G.Id AS Id,
                               G.GroupId AS GroupId,
                               G.EstablishmentGroupName,
                               G.EstablishmentGroupType,
                               E.Id AS EstablishmentId,
                               E.EstablishmentGroupId,
                               E.EstablishmentName
                        FROM EstablishmentGroup G
                            INNER JOIN Establishment E
                                ON G.Id = E.EstablishmentGroupId
                        WHERE G.GroupId = @GroupID
                              AND LOWER(G.EstablishmentGroupName) IN (
                                                                         SELECT Data FROM dbo.Split(
                                                                                                       LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                       ','
                                                                                                   )
                                                                     )
                              AND LOWER(E.EstablishmentName) IN (
                                                                    SELECT Data
                                                                    FROM dbo.Split(
                                                                                      LOWER(dbo.TRIM(@TempSalesEstablishment)),
                                                                                      ','
                                                                                  )
                                                                )
							  AND ISNULL(E.IsDeleted,0) = 0
							  AND ISNULL(G.IsDeleted,0) = 0;


                        DECLARE @Appcounter1 INT = 1;
                        DECLARE @TOTALESTABLISHMENT1 INT = 0;
                        SET @TOTALESTABLISHMENT1 =
                        (
                            SELECT COUNT(*) FROM #NewTempSalesEstablishment1
                        );
                        WHILE @Appcounter1 <= @TOTALESTABLISHMENT1
                        BEGIN
                            DECLARE @EstablishmentId1 BIGINT;
                            SET @EstablishmentId1 =
                            (
                                SELECT EstablishmentId
                                FROM #NewTempSalesEstablishment1
                                WHERE RowNumber = @Appcounter1
                            );
                            IF NOT EXISTS
                            (
                                SELECT EstablishmentId
                                FROM AppUserEstablishment
                                WHERE EstablishmentId = @EstablishmentId1
                                      AND AppUserId = @ExistingAppUserId
									  AND ISNULL(IsDeleted,0) = 0
                            )
                            BEGIN
                                INSERT INTO [AppUserEstablishment]
                                (
                                    AppUserId,
                                    EstablishmentId,
                                    EstablishmentType,
                                    UpdatedBy,
                                    UpdatedOn
                                )
                                SELECT @ExistingAppUserId,
                                       EstablishmentId,
                                       EstablishmentGroupType,
                                       @UserId,
                                       GETUTCDATE()
                                FROM #NewTempSalesEstablishment1
                                WHERE RowNumber = @Appcounter1;
                            END;
                            SET @Appcounter1 = @Appcounter1 + 1;
                            CONTINUE;
                        END;
                        --end Sales Establishment


                        --start customer establishment
                        --start Customer Establishment
                        SELECT @TempCustomerEstablishment = tmpuser.CustomerEstablishment
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;
                        --end Customer Establishment

                        IF OBJECT_ID('tempdb..#NewTempCustomersEstablishment1', 'U') IS NOT NULL
                            DROP TABLE #NewTempCustomersEstablishment1;
                        CREATE TABLE #NewTempCustomersEstablishment1
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            GroupId BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX),
                            EstablishmentGroupType NVARCHAR(MAX),
                            EstablishmentId BIGINT,
                            EstablishmentGroupId BIGINT,
                            EstablishmentName NVARCHAR(MAX)
                        );
                        INSERT INTO #NewTempCustomersEstablishment1
                        SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                               G.Id AS Id,
                               G.GroupId AS GroupId,
                               G.EstablishmentGroupName,
                               G.EstablishmentGroupType,
                               E.Id AS EstablishmentId,
                               E.EstablishmentGroupId,
                               E.EstablishmentName
                        FROM EstablishmentGroup G
                            INNER JOIN Establishment E
                                ON G.Id = E.EstablishmentGroupId
                        WHERE G.GroupId = @GroupID
                              AND LOWER(G.EstablishmentGroupName) IN (
                                                                         SELECT Data FROM dbo.Split(
                                                                                                       LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                       ','
                                                                                                   )
                                                                     )
                              AND LOWER(E.EstablishmentName) IN (
                                                                    SELECT Data
                                                                    FROM dbo.Split(
                                                                                      LOWER(dbo.TRIM(@TempCustomerEstablishment)),
                                                                                      ','
                                                                                  )
                                                                )
							  AND ISNULL(E.IsDeleted,0) = 0
							  AND ISNULL(G.IsDeleted,0) = 0;



                        DECLARE @Appcustomercounter1 INT = 1;
                        DECLARE @TOTALcustomerESTABLISHMENT1 INT = 0;
                        SET @TOTALcustomerESTABLISHMENT1 =
                        (
                            SELECT COUNT(*) FROM #NewTempCustomersEstablishment1
                        );
                        WHILE @Appcustomercounter1 <= @TOTALcustomerESTABLISHMENT1
                        BEGIN
                            DECLARE @forEstablishmentId1 BIGINT;
                            SET @forEstablishmentId1 =
                            (
                                SELECT EstablishmentId
                                FROM #NewTempCustomersEstablishment1
                                WHERE RowNumber = @Appcustomercounter1
                            );
                            IF NOT EXISTS
                            (
                                SELECT EstablishmentId
                                FROM AppUserEstablishment
                                WHERE EstablishmentId = @forEstablishmentId1
                                      AND AppUserId = @ExistingAppUserId
									  AND ISNULL(IsDeleted,0) = 0
                            )
                            BEGIN
                                INSERT INTO [AppUserEstablishment]
                                (
                                    AppUserId,
                                    EstablishmentId,
                                    EstablishmentType,
                                    UpdatedBy,
                                    UpdatedOn
                                )
                                SELECT @ExistingAppUserId,
                                       EstablishmentId,
                                       EstablishmentGroupType,
                                       @UserId,
                                       GETUTCDATE()
                                FROM #NewTempCustomersEstablishment1
                                WHERE RowNumber = @Appcustomercounter1;
                            END;
                            SET @Appcustomercounter1 = @Appcustomercounter1 + 1;
                            CONTINUE;
                        END;

                        --end customer establishment 			     


                        --Start AppModule   


                        SELECT @TempModuleName = tmpuser.ModuleName
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;


                        IF OBJECT_ID('tempdb..#TempAppModuleName1', 'U') IS NOT NULL
                            DROP TABLE #TempAppModuleName1;
                        CREATE TABLE #TempAppModuleName1
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            ModuleName NVARCHAR(MAX),
                            AliasName NVARCHAR(MAX)
                        );
                        INSERT INTO #TempAppModuleName1
                        SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                               Id,
                               ModuleName,
                               ''
                        FROM AppModule
                        WHERE LOWER(dbo.TRIM(ModuleName)) IN (
                                                                 SELECT Data FROM dbo.Split(
                                                                                               LOWER(dbo.TRIM(@TempModuleName)),
                                                                                               ','
                                                                                           )
                                                             )
						 AND ISNULL(IsDeleted,0) = 0;


                        SET @activitiycounter = 1;
                        SET @TotalActivityCounter =
                        (
                            SELECT COUNT(*) FROM #TempActivityName1
                        );
                        WHILE @activitiycounter <= @TotalActivityCounter
                        BEGIN
                            SET @modulecounter = 1;
                            SET @totalmodule =
                            (
                                SELECT COUNT(*) FROM #TempAppModuleName1
                            );
                            DECLARE @EstablishmentGroupId1 BIGINT;
                            SET @EstablishmentGroupId1 =
                            (
                                SELECT Id FROM #TempActivityName1 WHERE RowNumber = @activitiycounter
                            );
                            WHILE @modulecounter <= @totalmodule
                            BEGIN

                                DECLARE @AliasName1 VARCHAR(500);
                                DECLARE @moduleid1 INT = 0;
                                SET @moduleid1 =
                                (
                                    SELECT Id FROM #TempAppModuleName1 WHERE RowNumber = @modulecounter
                                );
                                SET @AliasName1 =
                                (
                                    SELECT AliasName
                                    FROM EstablishmentGroupModuleAlias
                                    WHERE EstablishmentGroupId = @EstablishmentGroupId1
                                          AND AppModuleId = @moduleid1
                                );

                                IF @AliasName1 <> ''
                                BEGIN

                                    IF NOT EXISTS
                                    (
                                        SELECT Id
                                        FROM AppUserModule
                                        WHERE AppUserId = @ExistingAppUserId
                                              AND EstablishmentGroupId = @EstablishmentGroupId1
                                              AND AppModuleId = @moduleid1
											  AND ISNULL(IsDeleted,0) = 0
                                    )
                                    BEGIN

                                        INSERT INTO AppUserModule
                                        (
                                            AppUserId,
                                            AppModuleId,
                                            AliasName,
                                            IsSelected,
                                            EstablishmentGroupId,
                                            UpdatedBy,
                                            UpdatedOn
                                        )
                                        VALUES
                                        (@ExistingAppUserId,
                                         @moduleid1,
                                         @AliasName1,
                                         1  ,
                                         @EstablishmentGroupId1,
                                         @UserId,
                                         GETUTCDATE()
                                        );
                                    END;
                                    ELSE
                                    BEGIN
                                        UPDATE AppUserModule
                                        SET IsSelected = 1
                                        WHERE AppUserId = @ExistingAppUserId
                                              AND EstablishmentGroupId = @EstablishmentGroupId1
                                              AND AppModuleId = @moduleid1;
                                    END;
                                END;
                                UPDATE AppUserModule
                                SET IsSelected = 1
                                WHERE AppUserId = @ExistingAppUserId
                                      AND AppModuleId = @moduleid1;
                                --where AppUserId = @ExistingAppUserId  AND EstablishmentGroupId = @EstablishmentGroupId1 AND AppModuleId = @moduleid1


                                SET @modulecounter = @modulecounter + 1;
                                CONTINUE;
                            END;


                            SET @activitiycounter = @activitiycounter + 1;
                            CONTINUE;
                        END;


                    END;
                    ELSE
                    BEGIN

                        UPDATE t1
                        SET GroupId = tmp.GroupId,
                            UpdatedBy = tmp.UserId,
                            UpdatedOn = GETUTCDATE()
                        FROM AppUser t1
                            INNER JOIN #TempAppUser tmp
                                ON t1.UserName = tmp.UserName
                                   AND t1.Email = tmp.Email
                        WHERE t1.Id = @ExistingAppUserId;

                        --Insert data in activity log from Import excel when import data from excel
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
                         1  ,
                         'Update record in table AppUser from when Import Excel',
                         'AppUser',
                         @ExistingAppUserId,
                         GETUTCDATE(),
                         @UserId,
                         0
                        );
                        --Insert data in activity log from and when import data from excel

                        --Delete Existing AppUserEstablishment
                        --DELETE FROM [AppUserModule] where AppUserId = @ExistingAppUserId;
                        --DELETE FROM [AppUserEstablishment] where AppUserId = @ExistingAppUserId;
                        UPDATE AppUserModule
                        SET IsDeleted = 1
                        WHERE AppUserId = @ExistingAppUserId;

                        UPDATE AppUserEstablishment
                        SET IsDeleted = 1
                        WHERE AppUserId = @ExistingAppUserId;

                        --Start AppModule for activity name

                        SELECT @TempActivityName = tmpuser.ActivityName
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;


                        IF OBJECT_ID('tempdb..#TempActivityName3', 'U') IS NOT NULL
                            DROP TABLE #TempActivityName3;
                        CREATE TABLE #TempActivityName3
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX)
                        );
                        INSERT INTO #TempActivityName3
                        SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                               Id,
                               EstablishmentGroupName
                        FROM EstablishmentGroup
                        WHERE LOWER(dbo.TRIM(EstablishmentGroupName)) IN (
                                                                             SELECT Data FROM dbo.Split(
                                                                                                           LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                           ','
                                                                                                       )
                                                                         )
																		 AND ISNULL(IsDeleted,0) = 0;
                        --end AppModule for activity name

                        --start Sales Establishment

                        SELECT @TempSalesEstablishment = tmpuser.SalesEstablishment
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;

                        IF OBJECT_ID('tempdb..#NewTempSalesEstablishment2', 'U') IS NOT NULL
                            DROP TABLE #NewTempSalesEstablishment2;
                        CREATE TABLE #NewTempSalesEstablishment2
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            GroupId BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX),
                            EstablishmentGroupType NVARCHAR(MAX),
                            EstablishmentId BIGINT,
                            EstablishmentGroupId BIGINT,
                            EstablishmentName NVARCHAR(MAX)
                        );
                        INSERT INTO #NewTempSalesEstablishment2
                        SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                               G.Id AS Id,
                               G.GroupId AS GroupId,
                               G.EstablishmentGroupName,
                               G.EstablishmentGroupType,
                               E.Id AS EstablishmentId,
                               E.EstablishmentGroupId,
                               E.EstablishmentName
                        FROM EstablishmentGroup G
                            INNER JOIN Establishment E
                                ON G.Id = E.EstablishmentGroupId
                        WHERE G.GroupId = @GroupID
                              AND LOWER(G.EstablishmentGroupName) IN (
                                                                         SELECT Data FROM dbo.Split(
                                                                                                       LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                       ','
                                                                                                   )
                                                                     )
                              AND LOWER(E.EstablishmentName) IN (
                                                                    SELECT Data
                                                                    FROM dbo.Split(
                                                                                      LOWER(dbo.TRIM(@TempSalesEstablishment)),
                                                                                      ','
                                                                                  )
                                                                )
							  AND ISNULL(E.IsDeleted,0) = 0
							  AND ISNULL(G.IsDeleted,0) = 0;


                        DECLARE @Appcounter2 INT = 1;
                        DECLARE @TOTALESTABLISHMENT2 INT = 0;
                        SET @TOTALESTABLISHMENT2 =
                        (
                            SELECT COUNT(*) FROM #NewTempSalesEstablishment2
                        );
                        WHILE @Appcounter2 <= @TOTALESTABLISHMENT2
                        BEGIN
                            DECLARE @EstablishmentId2 BIGINT;
                            SET @EstablishmentId2 =
                            (
                                SELECT EstablishmentId
                                FROM #NewTempSalesEstablishment2
                                WHERE RowNumber = @Appcounter2
                            );
                            INSERT INTO [AppUserEstablishment]
                            (
                                AppUserId,
                                EstablishmentId,
                                EstablishmentType,
                                UpdatedBy,
                                UpdatedOn
                            )
                            SELECT @ExistingAppUserId,
                                   EstablishmentId,
                                   EstablishmentGroupType,
                                   @UserId,
                                   GETUTCDATE()
                            FROM #NewTempSalesEstablishment2
                            WHERE RowNumber = @Appcounter2;
                            SET @Appcounter2 = @Appcounter2 + 1;
                            CONTINUE;
                        END;
                        --end Sales Establishment


                        --start customer establishment
                        SELECT @TempCustomerEstablishment = tmpuser.CustomerEstablishment
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;

                        IF OBJECT_ID('tempdb..#NewTempCustomersEstablishment2', 'U') IS NOT NULL
                            DROP TABLE #NewTempCustomersEstablishment2;
                        CREATE TABLE #NewTempCustomersEstablishment2
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            GroupId BIGINT,
                            EstablishmentGroupName NVARCHAR(MAX),
                            EstablishmentGroupType NVARCHAR(MAX),
                            EstablishmentId BIGINT,
                            EstablishmentGroupId BIGINT,
                            EstablishmentName NVARCHAR(MAX)
                        );
                        INSERT INTO #NewTempCustomersEstablishment2
                        SELECT ROW_NUMBER() OVER (ORDER BY E.Id ASC) AS RowNumber,
                               G.Id AS Id,
                               G.GroupId AS GroupId,
                               G.EstablishmentGroupName,
                               G.EstablishmentGroupType,
                               E.Id AS EstablishmentId,
                               E.EstablishmentGroupId,
                               E.EstablishmentName
                        FROM EstablishmentGroup G
                            INNER JOIN Establishment E
                                ON G.Id = E.EstablishmentGroupId
                        WHERE G.GroupId = @GroupID
                              AND LOWER(G.EstablishmentGroupName) IN (
                                                                         SELECT Data FROM dbo.Split(
                                                                                                       LOWER(dbo.TRIM(@TempActivityName)),
                                                                                                       ','
                                                                                                   )
                                                                     )
                              AND LOWER(E.EstablishmentName) IN (
                                                                    SELECT Data
                                                                    FROM dbo.Split(
                                                                                      LOWER(dbo.TRIM(@TempCustomerEstablishment)),
                                                                                      ','
                                                                                  )
                                                                )
							  AND ISNULL(E.IsDeleted,0) = 0
							  AND ISNULL(G.IsDeleted,0) = 0;



                        DECLARE @Appcustomercounter2 INT = 1;
                        DECLARE @TOTALcustomerESTABLISHMENT2 INT = 0;
                        SET @TOTALcustomerESTABLISHMENT2 =
                        (
                            SELECT COUNT(*) FROM #NewTempCustomersEstablishment2
                        );
                        WHILE @Appcustomercounter2 <= @TOTALcustomerESTABLISHMENT2
                        BEGIN
                            DECLARE @forEstablishmentId2 BIGINT;
                            SET @forEstablishmentId2 =
                            (
                                SELECT EstablishmentId
                                FROM #NewTempCustomersEstablishment2
                                WHERE RowNumber = @Appcustomercounter2
                            );
                            INSERT INTO [AppUserEstablishment]
                            (
                                AppUserId,
                                EstablishmentId,
                                EstablishmentType,
                                UpdatedBy,
                                UpdatedOn
                            )
                            SELECT @ExistingAppUserId,
                                   EstablishmentId,
                                   EstablishmentGroupType,
                                   @UserId,
                                   GETUTCDATE()
                            FROM #NewTempCustomersEstablishment2
                            WHERE RowNumber = @Appcustomercounter2;
                            SET @Appcustomercounter2 = @Appcustomercounter2 + 1;
                            CONTINUE;
                        END;

                        --end customer establishment 			     


                        --Start AppModule   

                        SELECT @TempModuleName = tmpuser.ModuleName
                        FROM #TempAppUser tmpuser
                        WHERE tmpuser.Id = @Counter;


                        IF OBJECT_ID('tempdb..#TempAppModuleName3', 'U') IS NOT NULL
                            DROP TABLE #TempAppModuleName3;
                        CREATE TABLE #TempAppModuleName3
                        (
                            RowNumber BIGINT,
                            Id BIGINT,
                            ModuleName NVARCHAR(MAX),
                            AliasName NVARCHAR(MAX)
                        );
                        INSERT INTO #TempAppModuleName3
                        SELECT ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNumber,
                               Id,
                               ModuleName,
                               ''
                        FROM AppModule
                        WHERE LOWER(dbo.TRIM(ModuleName)) IN (
                                                                 SELECT Data FROM dbo.Split(
                                                                                               LOWER(dbo.TRIM(@TempModuleName)),
                                                                                               ','
                                                                                           )
                                                             )
															  AND ISNULL(IsDeleted,0) = 0;

                        SET @activitiycounter = 1;
                        SET @TotalActivityCounter =
                        (
                            SELECT COUNT(*) FROM #TempActivityName3
                        );
                        WHILE @activitiycounter <= @TotalActivityCounter
                        BEGIN
                            SET @modulecounter = 1;
                            SET @totalmodule =
                            (
                                SELECT COUNT(*) FROM #TempAppModuleName3
                            );
                            DECLARE @EstablishmentGroupId2 BIGINT;
                            SET @EstablishmentGroupId2 =
                            (
                                SELECT Id FROM #TempActivityName3 WHERE RowNumber = @activitiycounter
                            );
                            WHILE @modulecounter <= @totalmodule
                            BEGIN

                                DECLARE @AliasName2 VARCHAR(500);
                                DECLARE @moduleid2 INT = 0;
                                SET @moduleid2 =
                                (
                                    SELECT Id FROM #TempAppModuleName3 WHERE RowNumber = @modulecounter
                                );
                                SET @AliasName2 =
                                (
                                    SELECT AliasName
                                    FROM EstablishmentGroupModuleAlias
                                    WHERE EstablishmentGroupId = @EstablishmentGroupId2
                                          AND AppModuleId = @moduleid2
                                );


                                IF NOT EXISTS
                                (
                                    SELECT Id
                                    FROM AppUserModule
                                    WHERE AppUserId = @ExistingAppUserId
                                          AND EstablishmentGroupId = @EstablishmentGroupId2
                                          AND AppModuleId = @moduleid2
										  AND ISNULL(IsDeleted,0) = 0
                                )
                                BEGIN

                                    INSERT INTO AppUserModule
                                    (
                                        AppUserId,
                                        AppModuleId,
                                        AliasName,
                                        IsSelected,
                                        EstablishmentGroupId,
                                        UpdatedBy,
                                        UpdatedOn
                                    )
                                    VALUES
                                    (@ExistingAppUserId,
                                     @moduleid2,
                                     @AliasName2,
                                     1  ,
                                     @EstablishmentGroupId2,
                                     @UserId,
                                     GETUTCDATE()
                                    );
                                END;
                                ELSE
                                BEGIN
                                    UPDATE AppUserModule
                                    SET IsSelected = 1
                                    WHERE AppUserId = @ExistingAppUserId
                                          AND EstablishmentGroupId = @EstablishmentGroupId2
                                          AND AppModuleId = @moduleid2;
                                END;

                                SET @modulecounter = @modulecounter + 1;
                                CONTINUE;
                            END;


                            SET @activitiycounter = @activitiycounter + 1;
                            CONTINUE;
                        END;


                    --End app module
                    END;
                END TRY
                BEGIN CATCH
                    --SELECT
                    --ERROR_NUMBER() AS ErrorNumber,
                    --ERROR_STATE() AS ErrorState,
                    --ERROR_SEVERITY() AS ErrorSeverity,
                    --ERROR_PROCEDURE() AS ErrorProcedure,
                    --ERROR_LINE() AS ErrorLine,
                    --ERROR_MESSAGE() AS ErrorMessage;
                    SET @ErrorMessage = 'User not Imported Successfully.';
                END CATCH;

            END;

            --Insert for check record update
            DECLARE @IsUserName1 VARCHAR(500);
            SET @IsUserName1 =
            (
                SELECT UserName FROM #TempAppUser tmpuser WHERE Id = @Counter
            );
            IF NOT EXISTS
            (
                SELECT Name
                FROM #TempUserValidation
                WHERE UserName = @IsUserName1
            )
            BEGIN
                INSERT INTO #TempUserValidation
                (
                    Name,
                    Email,
                    Mobile,
                    UserName,
                    Message,
                    ErrorMessage
                )
                SELECT Name,
                       Email,
                       Mobile,
                       UserName,
                       CASE
                           WHEN @ErrorMessage <> '' THEN
                               ''
                           ELSE
                               'Record Updated'
                       END,
                       @ErrorMessage
                FROM #TempAppUser tmpuser
                WHERE Id = @Counter
                      AND UserName = @IsUserName1;
            END;
        --Insert for check record update

        END;
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;

    SELECT DISTINCT
        *
    FROM #TempUserValidation
    ORDER BY UserName ASC;

END;
