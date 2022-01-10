CREATE PROCEDURE dbo.WsGetContactDetailsByGroupId_04042017
    @GroupId BIGINT ,
    @AppUserId BIGINT
AS
    BEGIN
        DECLARE @top INT = 50;
        DECLARE @Count INT;
        DECLARE @SeenclinetContact AS TABLE
            (
              Id BIGINT ,
              SeenClientId BIGINT ,
              Name NVARCHAR(MAX) ,
              IsGroup BIT
            );

        DECLARE @FinalResult AS TABLE
            (
              Id BIGINT ,
              Name NVARCHAR(MAX) ,
              IsGroup BIT ,
              s INT
            );

		DECLARE @Result AS TABLE
		(
		   Id BIGINT ,
           Name NVARCHAR(MAX) ,
           IsGroup BIT 
		)

	DECLARE @RoleDetails AS TABLE
			(
				ContactRoleId BIGINT,
				appEstablishmentUserId BIGINT
			)

   	INSERT INTO @RoleDetails
			        ( ContactRoleId ,
			          appEstablishmentUserId
			        )
		SELECT  ContactRoleId ,
				AppUserId
                         FROM  dbo.AppUserEstablishment
                INNER JOIN dbo.ContactRoleEstablishment ON ContactRoleEstablishment.EstablishmentId = AppUserEstablishment.EstablishmentId
        WHERE   ContactRoleId IN (SELECT ContactRoleId FROM dbo.AppUserContactRole WHERE AppUserId = @AppUserId) AND AppUserEstablishment.IsDeleted = 0
        GROUP BY AppUserId,ContactRoleId;



        IF EXISTS ( SELECT  1
                    FROM    dbo.AppUserContactRole
                    WHERE   AppUserId = @AppUserId )
            BEGIN
                INSERT  INTO @SeenclinetContact
                        SELECT  DISTINCT
                                R.ContactMasterOrGroupId ,
                                R.SeenClientId ,
                                R.ContactGropName ,
                                R.IsGroup
                        FROM    ( SELECT TOP 50
                                            ISNULL(SAM.ContactMasterId,
                                                   SAM.ContactGroupId) AS ContactMasterOrGroupId ,
                                            SAM.SeenClientId ,
                                            ( CASE WHEN SAM.IsSubmittedForGroup = 1
                                                        AND SAM.ContactMasterId IS NULL
                                                   THEN CG.ContactGropName
                                                   WHEN SAM.ContactMasterId IS NOT NULL
                                                   THEN dbo.ConcateString('ContactSummary',
                                                              SAM.ContactMasterId)
                                              END ) AS ContactGropName ,
                                            CASE WHEN SAM.ContactMasterId IS NULL
                                                 THEN 1
                                                 ELSE 0
                                            END AS IsGroup ,
                                            CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) AS CreatedOn
                                  FROM      SeenClientAnswerMaster SAM
                                            INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                            INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
                                            LEFT OUTER JOIN dbo.ContactMaster
                                            AS CM ON CM.Id = SAM.ContactMasterId
                                            LEFT OUTER JOIN dbo.ContactGroup
                                            AS CG ON CG.Id = SAM.ContactGroupId
                                            INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                            INNER JOIN @RoleDetails
                                            AS crd ON crd.ContactRoleId = c.Id
                                                      AND ( crd.AppEstablishmentUserId = CM.CreatedBy
                                                            OR CM.CreatedBy = 0
                                                          )
                                            INNER JOIN dbo.AppUserContactRole
                                            AS ac ON ac.ContactRoleId = c.Id
                                                     AND ac.AppUserId = @AppUserId
                                  WHERE     SAM.SeenClientId = EG.SeenClientId
                                            AND ( ISNULL(CM.GroupId, 0) = @GroupId
                                                  OR ISNULL(CG.GroupId, 0) = @GroupId
                                                )
                                            AND ISNULL(CM.IsDeleted, 0) = 0
                                            AND ISNULL(CG.IsDeleted, 0) = 0
                                  GROUP BY  SAM.SeenClientId ,
                                            ISNULL(SAM.ContactMasterId,
                                                   SAM.ContactGroupId) ,
                                            SAM.ContactMasterId ,
                                            SAM.IsSubmittedForGroup ,
                                            CG.ContactGropName ,
                                            CONVERT(NVARCHAR(50), SAM.CreatedOn, 121)
                                  ORDER BY  CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) DESC
                                ) AS R  /* Disha - 21-OCT-2016 - Changes for sorting by CreatedOn DESC */
                        /* ORDER BY ISNULL(SAM.ContactMasterId,
                                        SAM.ContactGroupId); */

                SELECT  @Count = COUNT(*)
                FROM    @SeenclinetContact;
                PRINT @Count
                IF ( @Count < @top )
                    BEGIN
                        INSERT  INTO @FinalResult
                                ( Id ,
                                  Name ,
                                  IsGroup ,
                                  s
                                )
                                SELECT  S.Id ,
                                        Name ,
                                        IsGroup ,
                                        0 AS s
                                FROM    @SeenclinetContact AS S
                                        LEFT JOIN dbo.ContactMaster CM ON S.Id = CM.Id
                                                              AND CM.IsDeleted = 0
                                        INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                        INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
                                                              AND ( crd.AppEstablishmentUserId = CM.CreatedBy
                                                              OR CM.CreatedBy = 0
                                                              )
                                        INNER JOIN dbo.AppUserContactRole AS ac ON ac.ContactRoleId = c.Id
                                                              AND ac.AppUserId = @AppUserId
                                WHERE   S.Id IS NOT NULL
                                UNION
                                SELECT TOP ( @top - @Count )
                                        CM.Id ,
                                        dbo.ConcateString('ContactSummary',
                                                          CM.Id) AS ContactGropName ,
                                        0 AS t ,
                                        0 AS s
                                FROM    dbo.ContactMaster AS CM
                                        INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                        INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
                                                              AND ( crd.AppEstablishmentUserId = CM.CreatedBy
                                                              OR CM.CreatedBy = 0
                                                              )
                                        INNER JOIN dbo.AppUserContactRole AS ac ON ac.ContactRoleId = c.Id
                                                              AND ac.AppUserId = @AppUserId
                                WHERE   CM.GroupId = @GroupId
                                        AND CM.IsDeleted = 0
                                        AND CM.Id NOT IN (
                                        SELECT  Id
                                        FROM    @SeenclinetContact )
                                UNION
                                SELECT  ISNULL(CM.Id, 0) ,
                                        ContactGropName ,
                                        1 ,
                                        1 AS s
                                FROM    dbo.ContactGroup AS CM
                                        INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                        INNER JOIN @RoleDetails AS crd ON crd.ContactRoleId = c.Id
                                                              AND ( crd.AppEstablishmentUserId = CM.CreatedBy
                                                              OR CM.CreatedBy = 0
                                                              )
                                        INNER JOIN dbo.AppUserContactRole AS ac ON ac.ContactRoleId = c.Id
                                                              AND ac.AppUserId = @AppUserId
                                WHERE   CM.IsDeleted = 0
                                        AND CM.Id NOT IN (
                                        SELECT  Id
                                        FROM    @SeenclinetContact )
                                        AND CM.GroupId = @GroupId;

INSERT INTO @Result
        ( Id, Name, IsGroup )
             SELECT TOP 50
                                Id ,
                                Name ,
                                IsGroup
                        FROM    @FinalResult
                        GROUP BY Id ,
                                Name ,
                                IsGroup ,
                                s
                        ORDER BY s; 
                    END;
                ELSE
                    BEGIN
					INSERT INTO @Result
						( Id, Name, IsGroup )
                        SELECT  S.Id ,
                                Name ,
                                IsGroup
                        FROM    @SeenclinetContact AS S
                                INNER JOIN dbo.ContactMaster CM ON CM.Id = S.Id
                        WHERE   S.Id IS NOT NULL
                                AND CM.IsDeleted = 0;
                    END;
            END
        ELSE
            BEGIN
                INSERT  INTO @SeenclinetContact
                        SELECT  DISTINCT
                                R.ContactMasterOrGroupId ,
                                R.SeenClientId ,
                                R.ContactGropName ,
                                R.IsGroup
                        FROM    ( SELECT TOP 50
                                            ISNULL(SAM.ContactMasterId,
                                                   SAM.ContactGroupId) AS ContactMasterOrGroupId ,
                                            SAM.SeenClientId ,
                                            ( CASE WHEN SAM.IsSubmittedForGroup = 1
                                                        AND SAM.ContactMasterId IS NULL
                                                   THEN CG.ContactGropName
                                                   WHEN SAM.ContactMasterId IS NOT NULL
                                                   THEN dbo.ConcateString('ContactSummary',
                                                              SAM.ContactMasterId)
                                              END ) AS ContactGropName ,
                                            CASE WHEN SAM.ContactMasterId IS NULL
                                                 THEN 1
                                                 ELSE 0
                                            END AS IsGroup ,
                                            CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) AS CreatedOn
                                  FROM      SeenClientAnswerMaster SAM
                                            INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                            INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
                                            LEFT OUTER JOIN dbo.ContactMaster
                                            AS CM ON CM.Id = SAM.ContactMasterId
                                            LEFT OUTER JOIN dbo.ContactGroup
                                            AS CG ON CG.Id = SAM.ContactGroupId
                                  WHERE     SAM.SeenClientId = EG.SeenClientId
                                            AND ( ISNULL(CM.GroupId, 0) = @GroupId
                                                  OR ISNULL(CG.GroupId, 0) = @GroupId
                                                )
                                            AND ISNULL(CM.IsDeleted, 0) = 0
                                            AND ISNULL(CG.IsDeleted, 0) = 0
                                  GROUP BY  SAM.SeenClientId ,
                                            ISNULL(SAM.ContactMasterId,
                                                   SAM.ContactGroupId) ,
                                            SAM.ContactMasterId ,
                                            SAM.IsSubmittedForGroup ,
                                            CG.ContactGropName ,
                                            CONVERT(NVARCHAR(50), SAM.CreatedOn, 121)
                                  ORDER BY  CONVERT(NVARCHAR(50), SAM.CreatedOn, 121) DESC
                                ) AS R  /* Disha - 21-OCT-2016 - Changes for sorting by CreatedOn DESC */


                SELECT  @Count = COUNT(*)
                FROM    @SeenclinetContact;
                PRINT @Count
                IF ( @Count < @top )
                    BEGIN
                        INSERT  INTO @FinalResult
                                ( Id ,
                                  Name ,
                                  IsGroup ,
                                  s
                                )
                                SELECT  S.Id ,
                                        Name ,
                                        IsGroup ,
                                        0 AS s
                                FROM    @SeenclinetContact AS S
                                        LEFT JOIN dbo.ContactMaster CM ON S.Id = CM.Id
                                                              AND CM.IsDeleted = 0
						--INNER join contactrole as c on c.groupid = @GroupId
						--inner join dbo.contactroledetails as crd ON crd.ContactRoleId = c.Id and (crd.appEstablishmentUserId = cm.createdby  or cm.createdby = 0)
						--inner join dbo.appusercontactrole as ac on ac.contactroleid = c.id and ac.appuserid = @AppUserId
                                WHERE   S.Id IS NOT NULL
                                UNION
                                SELECT TOP ( @top - @Count )
                                        CM.Id ,
                                        dbo.ConcateString('ContactSummary',
                                                          CM.Id) AS ContactGropName ,
                                        0 AS t ,
                                        0 AS s
                                FROM    dbo.ContactMaster AS CM
						--INNER join contactrole as c on c.groupid = @GroupId
						--inner join dbo.contactroledetails as crd ON crd.ContactRoleId = c.Id and (crd.appEstablishmentUserId = cm.createdby  or cm.createdby = 0)
						--inner join dbo.appusercontactrole as ac on ac.contactroleid = c.id and ac.appuserid = @AppUserId
                                WHERE   CM.GroupId = @GroupId
                                        AND CM.IsDeleted = 0
                                        AND CM.Id NOT IN (
                                        SELECT  Id
                                        FROM    @SeenclinetContact )
                                UNION
                                SELECT  ISNULL(CM.Id, 0) ,
                                        ContactGropName ,
                                        1 ,
                                        1 AS s
                                FROM    dbo.ContactGroup AS CM
					 --   INNER join contactrole as c on c.groupid = @GroupId
						--inner join dbo.contactroledetails as crd ON crd.ContactRoleId = c.Id and (crd.appEstablishmentUserId = cm.createdby  or cm.createdby = 0)
						--inner join dbo.appusercontactrole as ac on ac.contactroleid = c.id and ac.appuserid = @AppUserId
                                WHERE   CM.IsDeleted = 0
                                        AND CM.Id NOT IN (
                                        SELECT  Id
                                        FROM    @SeenclinetContact )
                                        AND CM.GroupId = @GroupId;
						INSERT INTO @Result
						( Id, Name, IsGroup )
                        SELECT TOP 50
                                Id ,
                                Name ,
                                IsGroup
                        FROM    @FinalResult
                        GROUP BY Id ,
                                Name ,
                                IsGroup ,
                                s
                        ORDER BY s; 
                    END;
                ELSE
                    BEGIN
					INSERT INTO @Result
						( Id, Name, IsGroup )
                        SELECT  S.Id ,
                                Name ,
                                IsGroup
                        FROM    @SeenclinetContact AS S
                                INNER JOIN dbo.ContactMaster CM ON CM.Id = S.Id
                        WHERE   S.Id IS NOT NULL
                                AND CM.IsDeleted = 0;
                    END;
            END

			SELECT Id,Name,IsGroup FROM @Result
			UNION
			SELECT ContactId,
			CASE IsGroup WHEN 1 THEN (SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = ContactId)
			ELSE
             dbo.ConcateString('ContactSummary',
			dbo.DefaultContact.ContactId) end AS ContactGropName ,IsGroup FROM dbo.DefaultContact 
			WHERE ContactId NOT IN (SELECT Id FROM @Result) AND IsDeleted = 0 AND AppUserId = @AppUserId
			ORDER BY IsGroup,Id

    END;
