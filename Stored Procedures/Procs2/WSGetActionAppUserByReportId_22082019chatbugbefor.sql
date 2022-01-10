-- =============================================        
-- Author:  Vasu Patel        
-- Create date: 26 Jun 2017       
-- Description: WSGetActionAppUserByReportId  1941,111289,1,2182          
-- =============================================        
create PROCEDURE [dbo].[WSGetActionAppUserByReportId_22082019chatbugbefor]
    @ActivityId BIGINT,
    @ReportId BIGINT,
    @Isout BIT,
    @AppUserId BIGINT
AS
BEGIN
    DECLARE @ContactDetails INT;
    DECLARE @ContactName INT;
    DECLARE @Conatct BIGINT;
    DECLARE @MobileNumber NVARCHAR(MAX);
    DECLARE @FinalName NVARCHAR(MAX);
    DECLARE @Name NVARCHAR(MAX);
    DECLARE @ContactMasterId NVARCHAR(MAX);
    DECLARE @EmailId NVARCHAR(MAX);
    DECLARE @IsCustomreId NVARCHAR(MAX);
    IF (@Isout = '1')
    BEGIN
        DECLARE @CustomerDetails AS TABLE
        (
            Name NVARCHAR(MAX),
            ContactMasterId VARCHAR(MAX),
            UserName NVARCHAR(MAX),
            Email VARCHAR(MAX),
            flag INT
        );
        DECLARE @CustomerDetailsGroup AS TABLE
        (
            Name NVARCHAR(MAX),
            ContactMasterId VARCHAR(MAX),
            UserName NVARCHAR(MAX),
            Email VARCHAR(MAX),
            flag INT
        );
        SET @IsCustomreId =
        (
            SELECT ContactMasterId
            FROM dbo.SeenClientAnswerMaster
            WHERE Id = @ReportId
        );
        IF (@IsCustomreId IS NOT NULL)
        BEGIN
            --PRINT 'Singal Conatct'  
            PRINT 'Singal Conatct 1';
            SET @Name =
            (
                SELECT TOP 1
                    Detail
                FROM ContactDetails
                WHERE ContactMasterId IN (
                                             SELECT ContactMasterId
                                             FROM dbo.SeenClientAnswerMaster
                                             WHERE Id = @ReportId
                                         )
                      AND QuestionTypeId = 4
                      AND IsDeleted = 0
                      AND Detail NOT IN (
                                            SELECT DISTINCT
                                                U.Email
                                            FROM dbo.AppUserEstablishment AS AUE
                                                INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                    ON SCA.Id = @ReportId
                                                LEFT JOIN dbo.AppManagerUserRights AS amu
                                                    ON amu.EstablishmentId = SCA.EstablishmentId
                                                       AND amu.EstablishmentId = AUE.EstablishmentId
                                                       AND amu.ManagerUserId = SCA.CreatedBy
                                                       AND amu.IsDeleted = 0
                                                INNER JOIN dbo.AppUser AS U
                                                    ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                       AND AUE.EstablishmentId = SCA.EstablishmentId
                                            WHERE AUE.IsDeleted = 0
                                                  AND U.IsDeleted = 0
                                                  AND U.IsActive = 1
                                                  AND (
                                                          SCA.CreatedBy = U.Id
                                                          OR U.IsAreaManager = 1
                                                      )
                                                  AND U.Id != @AppUserId
                                        )
                      AND Detail NOT IN (
                                            SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                        )
                      AND Detail <> ''
            );
            SET @EmailId =
            (
                SELECT Detail
                FROM ContactDetails
                WHERE ContactMasterId IN (
                                             SELECT ContactMasterId
                                             FROM dbo.SeenClientAnswerMaster
                                             WHERE Id = @ReportId
                                         )
                      AND QuestionTypeId = 10
                      AND IsDeleted = 0
                      AND Detail NOT IN (
                                            SELECT DISTINCT
                                                U.Email
                                            FROM dbo.AppUserEstablishment AS AUE
                                                INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                    ON SCA.Id = @ReportId
                                                LEFT JOIN dbo.AppManagerUserRights AS amu
                                                    ON amu.EstablishmentId = SCA.EstablishmentId
                                                       AND amu.EstablishmentId = AUE.EstablishmentId
                                                       AND amu.ManagerUserId = SCA.CreatedBy
                                                       AND amu.IsDeleted = 0
                                                INNER JOIN dbo.AppUser AS U
                                                    ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                       AND AUE.EstablishmentId = SCA.EstablishmentId
                                            WHERE AUE.IsDeleted = 0
                                                  AND U.IsDeleted = 0
                                                  AND U.IsActive = 1
                                                  AND (
                                                          SCA.CreatedBy = U.Id
                                                          OR U.IsAreaManager = 1
                                                      )
                                                  AND U.Id != @AppUserId
                                        )
                      AND Detail NOT IN (
                                            SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                        )
                      AND Detail <> ''
            );
            SET @MobileNumber =
            (
                SELECT TOP 1
                    Detail
                FROM ContactDetails
                WHERE ContactMasterId IN (
                                             SELECT ContactMasterId
                                             FROM dbo.SeenClientAnswerMaster
                                             WHERE Id = @ReportId
                                         )
                      AND QuestionTypeId = 11
                      AND IsDeleted = 0
                      AND Detail NOT IN (
                                            SELECT DISTINCT
                                                U.Mobile
                                            FROM dbo.AppUserEstablishment AS AUE
                                                INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                    ON SCA.Id = @ReportId
                                                LEFT JOIN dbo.AppManagerUserRights AS amu
                                                    ON amu.EstablishmentId = SCA.EstablishmentId
                                                       AND amu.EstablishmentId = AUE.EstablishmentId
                                                       AND amu.ManagerUserId = SCA.CreatedBy
                                                       AND amu.IsDeleted = 0
                                                INNER JOIN dbo.AppUser AS U
                                                    ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                       AND AUE.EstablishmentId = SCA.EstablishmentId
                                            WHERE AUE.IsDeleted = 0
                                                  AND U.IsDeleted = 0
                                                  AND U.IsActive = 1
                                                  AND (
                                                          SCA.CreatedBy = U.Id
                                                          OR U.IsAreaManager = 1
                                                      )
                                                  AND U.Id != @AppUserId
                                        )
                      AND Detail NOT IN (
                                            SELECT Mobile FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                        )
                      AND Detail <> ''
            );
            IF ((@Name IS NULL) AND (@MobileNumber IS NULL))
            BEGIN
                SET @FinalName = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + @EmailId + ')';
            END;
            ELSE IF (@Name IS NULL AND @EmailId IS NULL)
            BEGIN
                SET @FinalName = ISNULL(RTRIM(LTRIM(@MobileNumber)), '');
            END;
            ELSE IF (@EmailId IS NULL AND @MobileNumber IS NULL)
            BEGIN
                SET @FinalName = NULL;
            END;
            ELSE IF (@MobileNumber IS NULL)
            BEGIN
                SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ')');
            END;
            ELSE IF (@EmailId IS NULL)
            BEGIN
                SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')');
            END;
            ELSE IF (@Name IS NULL)
            BEGIN
                SET @FinalName
                    = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + ISNULL(@EmailId + ',', '') + ' '
                      + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')';
            END;
            ELSE
            BEGIN
                SET @FinalName
                    = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ','
                       + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ') '
                      );
            END;
            PRINT @Name;
            PRINT @EmailId;
            PRINT @MobileNumber;
            SET @ContactMasterId =
            (
                SELECT TOP 1
                    ContactMasterId
                FROM ContactDetails
                WHERE ContactMasterId IN (
                                             SELECT ContactMasterId
                                             FROM dbo.SeenClientAnswerMaster
                                             WHERE Id = @ReportId
                                         )
            );
            IF (@FinalName IS NOT NULL)
            BEGIN
                INSERT INTO @CustomerDetails
                (
                    Name,
                    ContactMasterId,
                    UserName,
                    Email,
                    flag
                )
                VALUES
                (   @FinalName,       -- Name - nvarchar(max)  
                    @ContactMasterId, -- ContactMasterId - varchar(50)  
                    @FinalName,       -- UserName - nvarchar(500)  
                    @FinalName,       -- Email - varchar(50)  
                    2                 -- flag - bit  
                );
            END;
        END;
        ELSE
        BEGIN
            ---PRINT 'Group Conatct'  
            PRINT 'Group Conatct 1';
            DECLARE @GroupConatctMasterId AS TABLE
            (
                Id BIGINT IDENTITY(1, 1),
                ContactMasterId BIGINT
            );
            DECLARE @Countrecord INT;
            INSERT INTO @GroupConatctMasterId
            (
                ContactMasterId
            )
            SELECT ContactMasterId
            FROM dbo.SeenClientAnswerChild
            WHERE SeenClientAnswerMasterId = @ReportId; -- ContactMasterId - bigint  
            SET @Countrecord =
            (
                SELECT COUNT(*) FROM @GroupConatctMasterId
            );
            DECLARE @cnt INT = 1;
            WHILE @cnt <= @Countrecord
            BEGIN
                SET @Name =
                (
                    SELECT TOP 1
                        Detail
                    FROM ContactDetails
                    WHERE ContactMasterId IN (
                                                 SELECT ContactMasterId FROM @GroupConatctMasterId WHERE Id = @cnt
                                             )
                          AND QuestionTypeId = 4
                          AND IsDeleted = 0
                          AND Detail NOT IN (
                                                SELECT DISTINCT
                                                    U.Email
                                                FROM dbo.AppUserEstablishment AS AUE
                                                    INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                        ON SCA.Id = @ReportId
                                                    LEFT JOIN dbo.AppManagerUserRights AS amu
                                                        ON amu.EstablishmentId = SCA.EstablishmentId
                                                           AND amu.EstablishmentId = AUE.EstablishmentId
                                                           AND amu.ManagerUserId = SCA.CreatedBy
                                                           AND amu.IsDeleted = 0
                                                    INNER JOIN dbo.AppUser AS U
                                                        ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                           AND AUE.EstablishmentId = SCA.EstablishmentId
                                                WHERE AUE.IsDeleted = 0
                                                      AND U.IsDeleted = 0
                                                      AND U.IsActive = 1
                                                      AND (
                                                              SCA.CreatedBy = U.Id
                                                              OR U.IsAreaManager = 1
                                                          )
                                                      AND U.Id != @AppUserId
                                            )
                          AND Detail NOT IN (
                                                SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                            )
                          AND Detail <> ''
                );
                SET @EmailId =
                (
                    SELECT Detail
                    FROM ContactDetails
                    WHERE ContactMasterId IN (
                                                 SELECT ContactMasterId FROM @GroupConatctMasterId WHERE Id = @cnt
                                             )
                          AND QuestionTypeId = 10
                          AND IsDeleted = 0
                          AND Detail NOT IN (
                                                SELECT DISTINCT
                                                    U.Email
                                                FROM dbo.AppUserEstablishment AS AUE
                                                    INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                        ON SCA.Id = @ReportId
                                                    LEFT JOIN dbo.AppManagerUserRights AS amu
                                                        ON amu.EstablishmentId = SCA.EstablishmentId
                                                           AND amu.EstablishmentId = AUE.EstablishmentId
                                                           AND amu.ManagerUserId = SCA.CreatedBy
                                                           AND amu.IsDeleted = 0
                                                    INNER JOIN dbo.AppUser AS U
                                                        ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                           AND AUE.EstablishmentId = SCA.EstablishmentId
                                                WHERE AUE.IsDeleted = 0
                                                      AND U.IsDeleted = 0
                                                      AND U.IsActive = 1
                                                      AND (
                                                              SCA.CreatedBy = U.Id
                                                              OR U.IsAreaManager = 1
                                                          )
                                                      AND U.Id != @AppUserId
                                            )
                          AND Detail NOT IN (
                                                SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                            )
                          AND Detail <> ''
                );
                SET @MobileNumber =
                (
                    SELECT LTRIM(RTRIM(Detail)) AS 'Detail'
                    FROM ContactDetails
                    WHERE ContactMasterId IN (
                                                 SELECT ContactMasterId FROM @GroupConatctMasterId WHERE Id = @cnt
                                             )
                          AND QuestionTypeId = 11
                          AND IsDeleted = 0
                          AND Detail NOT IN (
                                                SELECT DISTINCT
                                                    U.Mobile
                                                FROM dbo.AppUserEstablishment AS AUE
                                                    INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                        ON SCA.Id = @ReportId
                                                    LEFT JOIN dbo.AppManagerUserRights AS amu
                                                        ON amu.EstablishmentId = SCA.EstablishmentId
                                                           AND amu.EstablishmentId = AUE.EstablishmentId
                                                           AND amu.ManagerUserId = SCA.CreatedBy
                                                           AND amu.IsDeleted = 0
                                                    INNER JOIN dbo.AppUser AS U
                                                        ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                           AND AUE.EstablishmentId = SCA.EstablishmentId
                                                WHERE AUE.IsDeleted = 0
                                                      AND U.IsDeleted = 0
                                                      AND U.IsActive = 1
                                                      AND (
                                                              SCA.CreatedBy = U.Id
                                                              OR U.IsAreaManager = 1
                                                          )
                                                      AND U.Id != @AppUserId
                                            )
                          AND Detail NOT IN (
                                                SELECT Mobile FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                            )
                          AND Detail <> ''
                );

                IF ((@Name IS NULL) AND (@MobileNumber IS NULL))
                BEGIN
                    SET @FinalName = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + '(' + @EmailId + ')';
                END;
                ELSE IF (@Name IS NULL AND @EmailId IS NULL)
                BEGIN
                    SET @FinalName = ISNULL(RTRIM(LTRIM(@MobileNumber)), '');
                END;
                ELSE IF (@EmailId IS NULL AND @MobileNumber IS NULL)
                BEGIN
                    SET @FinalName = NULL;
                END;
                ELSE IF (@MobileNumber IS NULL)
                BEGIN
                    SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ')');
                END;
                ELSE IF (@EmailId IS NULL)
                BEGIN
                    SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')');
                END;
                ELSE IF (@Name IS NULL)
                BEGIN
                    SET @FinalName
                        = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + '(' + ISNULL(@EmailId + ',', '') + ''
                    + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')';
                END;
                ELSE
                BEGIN
                    --PRINT 'Group Conatc2'  
                    SET @FinalName
                        = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ','
                           + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')'
                          );
                END;
                SET @ContactMasterId =
                (
                    SELECT TOP 1
                        ContactMasterId
                    FROM ContactDetails
                    WHERE ContactMasterId IN (
                                                 SELECT ContactMasterId FROM @GroupConatctMasterId WHERE Id = @cnt
                                             )
                );
                IF (@FinalName IS NOT NULL)
                BEGIN
                    INSERT INTO @CustomerDetailsGroup
                    (
                        Name,
                        ContactMasterId,
                        UserName,
                        Email,
                        flag
                    )
                    VALUES
                    (   @FinalName,       -- Name - nvarchar(max)  
                        @ContactMasterId, -- ContactMasterId - varchar(50)  
                        @FinalName,       -- UserName - nvarchar(500)  
                        @FinalName,       -- Email - varchar(50)  
                        2                 -- flag - bit  
                    );
                END;
                SET @cnt = @cnt + 1;
            END;
        END;
        SELECT 'EveryOne' AS Name,
               0 AS UserId,
               'EveryOne' AS UserName,
               '' AS Email,
               0 AS flag
        UNION ALL
        SELECT 'Me' AS Name,
               @AppUserId AS UserId,
               'Me' AS UserName,
               '' AS Email,
               0 AS flag
        UNION ALL
        SELECT A.Name AS Name,
               A.Id,
               A.UserName AS UserName,
               A.Email,
               1 AS flag
        FROM dbo.SeenClientAnswerMaster SA
            INNER JOIN dbo.AppUser A
                ON SA.CreatedBy = A.Id
                   AND SA.CreatedBy != @AppUserId
                   AND SA.Id = @ReportId
        UNION ALL
        SELECT *
        FROM @CustomerDetails
        UNION ALL
        SELECT *
        FROM @CustomerDetailsGroup
        UNION
        SELECT U.Name AS Name,
               U.Id AS UserId,
               U.UserName AS UserName,
               U.Email,
               1 AS flag
        FROM dbo.AppUserEstablishment AS AUE
            INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                ON SCA.Id = @ReportId
            LEFT JOIN dbo.AppManagerUserRights AS amu
                ON amu.EstablishmentId = SCA.EstablishmentId
                   AND amu.EstablishmentId = AUE.EstablishmentId
                   AND amu.ManagerUserId = SCA.CreatedBy
                   AND amu.IsDeleted = 0
            INNER JOIN dbo.AppUser AS U
                ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                   AND AUE.EstablishmentId = SCA.EstablishmentId
        WHERE AUE.IsDeleted = 0
              AND U.IsDeleted = 0
              AND U.IsActive = 1
              AND (
                      SCA.CreatedBy = U.Id
                      OR U.IsAreaManager = 1
                  )
              AND U.Id != @AppUserId
        --AND AUE.NotificationStatus = 1        
        GROUP BY U.Name,
                 U.Id,
                 U.UserName,
                 U.Email
        ORDER BY flag;
    END;
    ELSE
    BEGIN
        PRINT 'Conatct 1';
        SET @Conatct =
        (
            SELECT Id
            FROM dbo.ContactMaster
            WHERE Remarks = 'Inserted From Feedback Id = ' + CONVERT(VARCHAR(10), @ReportId)
        );
        PRINT 1;
        PRINT @Conatct;
        PRINT 2;
        IF (@Conatct IS NULL)
        BEGIN
            PRINT 3;
            DECLARE @TempExistsTable AS TABLE
            (
                ContactMasterId BIGINT,
                Details NVARCHAR(500),
                Email NVARCHAR(50),
                Mobile NVARCHAR(20),
                RoleName VARCHAR(500),
                UserName VARCHAR(500)
            );

            DECLARE @TempTable TABLE
            (
                ContactId BIGINT,
                GroupId BIGINT,
                ContactQuestionId BIGINT,
                ContactOptionId BIGINT,
                QuestionTypeId BIGINT,
                Detail NVARCHAR(500)
            );
            INSERT INTO @TempTable
            (
                ContactId,
                GroupId,
                ContactQuestionId,
                ContactOptionId,
                QuestionTypeId,
                Detail
            )
            SELECT CQ.ContactId,
                   E.GroupId,
                   CQ.Id,
                   CO.Id,
                   CQ.QuestionTypeId,
                   A.Detail
            FROM dbo.Questions AS Q
                INNER JOIN dbo.Answers AS A
                    ON A.QuestionId = Q.Id
                INNER JOIN dbo.ContactQuestions AS CQ
                    ON CQ.Id = Q.ContactQuestionIdRef
                INNER JOIN dbo.AnswerMaster AS AM
                    ON AM.Id = A.AnswerMasterId
                INNER JOIN dbo.Establishment AS E
                    ON E.Id = AM.EstablishmentId
                LEFT OUTER JOIN dbo.ContactOptions AS CO
                    ON CO.ContactQuestionId = CQ.Id
                LEFT OUTER JOIN dbo.Options AS o
                    ON o.Id = A.OptionId
            WHERE A.AnswerMasterId = @ReportId
                  AND Q.ContactQuestionIdRef IS NOT NULL
                  AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0);
            DECLARE @GroupId BIGINT,
                    @EmailIdCustomer NVARCHAR(50),
                    @Mobile NVARCHAR(20),
                    @Count BIGINT;

            SELECT TOP 1
                @GroupId = GroupId
            FROM @TempTable;
            SELECT @EmailIdCustomer = Detail
            FROM @TempTable
            WHERE QuestionTypeId = 10;
            SELECT @Mobile = Detail
            FROM @TempTable
            WHERE QuestionTypeId = 11;

            IF (
                   (
                       @EmailIdCustomer <> ''
                       AND @EmailIdCustomer IS NOT NULL
                   )
                   OR (
                          @Mobile <> ''
                          AND @Mobile IS NOT NULL
                      )
               )
            BEGIN
                IF @EmailIdCustomer IS NULL
                    SET @EmailIdCustomer = '';
                IF @Mobile IS NULL
                    SET @Mobile = '';


                --      EXEC dbo.IsContactMasterExists @GroupId, 0, @EmailIdCustomer, @Mobile;  
                INSERT INTO @TempExistsTable
                SELECT CM.Id AS ContactMasterId,
                       dbo.ConcateString('DuplicateContact', CM.Id) AS Detail,
                       CASE
                           WHEN QuestionTypeId = 10 THEN
                               ISNULL(Detail, '')
                           ELSE
                               ''
                       END AS Email,
                       CASE
                           WHEN QuestionTypeId = 11 THEN
                               ISNULL(Detail, '')
                           ELSE
                               ''
                       END AS Mobile,
                       ISNULL(
                       (
                           SELECT STUFF(
                                  (
                                      SELECT DISTINCT
                                          ', ' + CR.RoleName
                                      FROM dbo.AppUserContactRole AS AUCR
                                          INNER JOIN dbo.ContactRole AS CR
                                              ON CR.Id = AUCR.ContactRoleId
                                      WHERE AUCR.AppUserId = CM.CreatedBy
                                            AND CR.GroupId = @GroupId
                                      FOR XML PATH('')
                                  ),
                                  1,
                                  1,
                                  ''
                                       )
                       ),
                       ''
                             ) AS RoleName,
                       ISNULL(AU.Name, 'Contact Created From Feedback.') AS UserName
                FROM dbo.ContactMaster AS CM
                    INNER JOIN dbo.ContactDetails AS CD
                        ON CD.ContactMasterId = CM.Id
                    LEFT JOIN dbo.AppUser AS AU
                        ON AU.Id = CM.CreatedBy
                WHERE CM.GroupId = @GroupId
                      AND CM.Id <> 0
                      AND CM.IsDeleted = 0
                      AND CD.QuestionTypeId IN ( 10, 11 )
                      AND (
                              CD.Detail = @Mobile
                              OR CD.Detail = @EmailIdCustomer
                          )
                      AND CD.Detail <> '';
            END;



            SET @Conatct =
            (
                SELECT TOP 1 ContactMasterId FROM @TempExistsTable
            );
        END;
        SET @Name =
        (
            SELECT TOP 1
                Detail
            FROM ContactDetails
            WHERE ContactMasterId = @Conatct
                  AND QuestionTypeId = 4
                  AND IsDeleted = 0
                  AND Detail NOT IN (
                                        SELECT DISTINCT
                                            U.Email
                                        FROM dbo.AppUserEstablishment AS AUE
                                            INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                ON SCA.Id = @ReportId
                                            LEFT JOIN dbo.AppManagerUserRights AS amu
                                                ON amu.EstablishmentId = SCA.EstablishmentId
                                                   AND amu.EstablishmentId = AUE.EstablishmentId
                                                   AND amu.ManagerUserId = SCA.CreatedBy
                                                   AND amu.IsDeleted = 0
                                            INNER JOIN dbo.AppUser AS U
                                                ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                   AND AUE.EstablishmentId = SCA.EstablishmentId
                                        WHERE AUE.IsDeleted = 0
                                              AND U.IsDeleted = 0
                                              AND U.IsActive = 1
                                              AND (
                                                      SCA.CreatedBy = U.Id
                                                      OR U.IsAreaManager = 1
                                                  )
                                              AND U.Id != @AppUserId
                                    )
                  AND Detail NOT IN (
                                        SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                    )
                  AND Detail <> ''
        );
        SET @EmailId =
        (
            SELECT Detail
            FROM ContactDetails
            WHERE ContactMasterId = @Conatct
                  AND QuestionTypeId = 10
                  AND IsDeleted = 0
                  AND Detail NOT IN (
                                        SELECT DISTINCT
                                            U.Email
                                        FROM dbo.AppUserEstablishment AS AUE
                                            INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                ON SCA.Id = @ReportId
                                            LEFT JOIN dbo.AppManagerUserRights AS amu
                                                ON amu.EstablishmentId = SCA.EstablishmentId
                                                   AND amu.EstablishmentId = AUE.EstablishmentId
                                                   AND amu.ManagerUserId = SCA.CreatedBy
                                                   AND amu.IsDeleted = 0
                                            INNER JOIN dbo.AppUser AS U
                                                ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                   AND AUE.EstablishmentId = SCA.EstablishmentId
                                        WHERE AUE.IsDeleted = 0
                                              AND U.IsDeleted = 0
                                              AND U.IsActive = 1
                                              AND (
                                                      SCA.CreatedBy = U.Id
                                                      OR U.IsAreaManager = 1
                                                  )
                                              AND U.Id != @AppUserId
                                    )
                  AND Detail NOT IN (
                                        SELECT Email FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                    )
                  AND Detail <> ''
        );
        SET @MobileNumber =
        (
            SELECT Detail
            FROM ContactDetails
            WHERE ContactMasterId = @Conatct
                  AND QuestionTypeId = 11
                  AND IsDeleted = 0
                  AND Detail NOT IN (
                                        SELECT DISTINCT
                                            U.Mobile
                                        FROM dbo.AppUserEstablishment AS AUE
                                            INNER JOIN dbo.SeenClientAnswerMaster AS SCA
                                                ON SCA.Id = @ReportId
                                            LEFT JOIN dbo.AppManagerUserRights AS amu
                                                ON amu.EstablishmentId = SCA.EstablishmentId
                                                   AND amu.EstablishmentId = AUE.EstablishmentId
                                                   AND amu.ManagerUserId = SCA.CreatedBy
                                                   AND amu.IsDeleted = 0
                                            INNER JOIN dbo.AppUser AS U
                                                ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                                                   AND AUE.EstablishmentId = SCA.EstablishmentId
                                        WHERE AUE.IsDeleted = 0
                                              AND U.IsDeleted = 0
                                              AND U.IsActive = 1
                                              AND (
                                                      SCA.CreatedBy = U.Id
                                                      OR U.IsAreaManager = 1
                                                  )
                                              AND U.Id != @AppUserId
                                    )
                  AND Detail NOT IN (
                                        SELECT Mobile FROM dbo.AppUser WHERE Id = @AppUserId AND IsDeleted = 0
                                    )
                  AND Detail <> ''
        );
        IF ((@Name IS NULL) AND (@MobileNumber IS NULL))
        BEGIN
            SET @FinalName = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + @EmailId + ')';
        END;
        ELSE IF (@Name IS NULL AND @EmailId IS NULL)
        BEGIN
            PRINT 2;
            SET @FinalName = ISNULL(RTRIM(LTRIM(@MobileNumber)), '');
        END;
        ELSE IF (@EmailId IS NULL AND @MobileNumber IS NULL)
        BEGIN
            SET @FinalName = NULL;
        END;
        ELSE IF (@MobileNumber IS NULL)
        BEGIN
            PRINT 3;
            SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ')');
        END;
        ELSE IF (@EmailId IS NULL)
        BEGIN
            PRINT 4;
            SET @FinalName = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')');
        END;
        ELSE IF (@Name IS NULL)
        BEGIN
            PRINT 5;
            SET @FinalName
                = LEFT(@EmailId, (CHARINDEX('@', @EmailId) - 1)) + ' ' + ' (' + ISNULL(@EmailId + ',', '') + ' '
                  + ISNULL(RTRIM(LTRIM(@MobileNumber)), '') + ')';
        END;
        ELSE
        BEGIN
            SET @FinalName
                = (ISNULL(@Name, '') + ' ' + '(' + ISNULL(@EmailId, '') + ',' + ISNULL(RTRIM(LTRIM(@MobileNumber)), '')
                   + ') '
                  );
            PRINT @FinalName;
        END;
        SET @ContactMasterId =
        (
            SELECT TOP 1
                ContactMasterId
            FROM ContactDetails
            WHERE ContactMasterId = @Conatct
        );
        IF (@FinalName IS NOT NULL)
        BEGIN
            INSERT INTO @CustomerDetails
            (
                Name,
                ContactMasterId,
                UserName,
                Email,
                flag
            )
            VALUES
            (   @FinalName,       -- Name - nvarchar(max)  
                @ContactMasterId, -- ContactMasterId - varchar(50)  
                @FinalName,       -- UserName - nvarchar(500)  
                @FinalName,       -- Email - varchar(50)  
                2                 -- flag - bit  
            );
        END;
        SELECT 'EveryOne' AS Name,
               0 AS UserId,
               'EveryOne' AS UserName,
               '' AS Email,
               0 AS flag
        UNION ALL
        SELECT 'Me' AS Name,
               @AppUserId AS UserId,
               'Me' AS UserName,
               '' AS Email,
               0 AS flag
        UNION ALL
        SELECT *
        FROM @CustomerDetails
        UNION
        SELECT CASE @AppUserId
                   WHEN U.Id THEN
                       'Me'
                   ELSE
                       U.Name
               END AS Name,
               U.Id AS UserId,
               CASE @AppUserId
                   WHEN U.Id THEN
                       'Me'
                   ELSE
                       U.UserName
               END AS UserName,
               '' AS Email,
               0 AS flag
        FROM dbo.AppUserEstablishment AS AUE
            INNER JOIN dbo.AppUser AS U
                ON U.Id = AUE.AppUserId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = AUE.EstablishmentId
            LEFT OUTER JOIN dbo.Supplier AS S
                ON S.Id = U.SupplierId
        WHERE E.EstablishmentGroupId = @ActivityId
              AND AUE.IsDeleted = 0
              AND E.IsDeleted = 0
              AND U.IsDeleted = 0
              AND U.IsActive = 1
        GROUP BY U.Name,
                 U.Id,
                 U.UserName,
                 U.SupplierId,
                 AUE.EstablishmentType,
                 S.SupplierName,
                 AUE.EstablishmentId,
                 E.EstablishmentName;
    END;
END;
