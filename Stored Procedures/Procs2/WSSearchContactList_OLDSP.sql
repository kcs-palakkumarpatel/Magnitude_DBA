-- =============================================
-- Author:			
-- Create date:	14-June-2017
-- Description:	Get Contact List of this Group by App User.
-- Call:					
-- =============================================
CREATE PROCEDURE dbo.WSSearchContactList_OLDSP
    @GroupId BIGINT ,
    @WithGroup BIT ,
    @Search NVARCHAR(100) ,
    @Page INT ,
    @Rows INT ,
    @IsWeb BIT ,
    @AppUserId BIGINT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT;
        DECLARE @Result TABLE
            (
              Id BIGINT ,
              Name NVARCHAR(MAX) ,
              IsGroup BIT
            );
        IF @IsWeb = 0
            BEGIN
                SET @Rows = 50;
            END;
	IF @Search = NULL
            BEGIN
                SET @Search = '';
            END;

        IF EXISTS ( SELECT  ( 1 )
                    FROM    dbo.AppUserContactRole
                    WHERE   AppUserId = @AppUserId )
            BEGIN
                SET @Search = ISNULL(@Search, '');
                SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
                SET @End = @Start + @Rows - 1;

                INSERT  INTO @Result ( Id, Name, IsGroup )
				SELECT MD.Id,  dbo.ConcateStringContactDetails(MD.Id) AS Name, 0 AS IsGroup FROM  ( SELECT DISTINCT CM.Id , CM.GroupId
				FROM  ( SELECT    Id , CreatedBy, GroupId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0
								UNION ALL 
								SELECT    Id , UpdatedBy, GroupId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0 AND UpdatedBy IS NOT NULL
                        ) AS CM
						INNER JOIN ( SELECT ISNULL(CRD.AppEstablishmentUserId, 0)  AS AppUserId FROM dbo.ContactRole 
						 INNER JOIN dbo.AppUserContactRole	AS ACR ON ACR.ContactRoleId = ContactRole.Id AND ACR.IsDeleted = 0
						 INNER JOIN dbo.ContactRoleDetails AS CRD ON CRD.ContactRoleId = ContactRole.Id
						 WHERE GroupId=@GroupId AND ACR.AppUserId = @AppUserId
						 GROUP BY ISNULL(CRD.AppEstablishmentUserId, 0) ) AS CRR ON CRR.AppUserId = CM.CreatedBy ) AS MD;

                IF @WithGroup = 1
                    BEGIN
                        INSERT  INTO @Result ( Id, Name, IsGroup )
                        SELECT DISTINCT
                                cm.Id ,
                                ContactGropName ,
                                1
                        FROM    dbo.ContactGroup AS cm
                                INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                INNER JOIN dbo.ContactRoleDetails AS crd ON crd.ContactRoleId = c.Id AND ( crd.AppEstablishmentUserId = cm.CreatedBy OR cm.CreatedBy = 0 OR crd.AppEstablishmentUserId = cm.UpdatedBy OR cm.UpdatedBy = 0)
                                INNER JOIN dbo.AppUserContactRole AS ac ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId AND ac.IsDeleted = 0
                        WHERE   cm.IsDeleted = 0
                                AND cm.GroupId = @GroupId;
                    END;

                SELECT  CASE Total / @Rows
                          WHEN 0 THEN 1
                          ELSE ( Total / @Rows ) + 1
                        END AS Total ,
                        RowNum ,
                        Id ,
                        Name ,
                        IsGroup ,
                        Total AS TotalRows
                FROM    ( SELECT    COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                                    ROW_NUMBER() OVER ( ORDER BY Name ) AS RowNum ,
                                    *
                          FROM      @Result
                        ) AS R
               WHERE  R.Name LIKE '%' + @Search + '%' 
			   AND RowNum BETWEEN @Start AND IIF(@Search = '', @End, 100000);

            END;
        ELSE
            BEGIN
			--- IF APP USER DON’T HAVE ANY CONTACT ROLES.
                SET @Search = ISNULL(@Search, '');
                SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
                SET @End = @Start + @Rows - 1;

                INSERT  INTO @Result
                        ( Id ,
                          Name ,
                          IsGroup
                        )
                        SELECT  CM.Id ,
                                dbo.ConcateStringContactDetails(CM.Id) ,
                                0
                        FROM    dbo.ContactMaster AS CM
                        WHERE   CM.IsDeleted = 0
                                AND CM.GroupId = @GroupId
                        GROUP BY CM.Id;

                IF @WithGroup = 1
                    BEGIN
                        INSERT  INTO @Result
                                ( Id ,
                                  Name ,
                                  IsGroup
                                )
                                SELECT  cm.Id ,
                                        ContactGropName ,
                                        1
                                FROM    dbo.ContactGroup AS cm
                                WHERE   cm.IsDeleted = 0
                                        AND cm.GroupId = @GroupId
                                GROUP BY cm.Id ,
                                        cm.ContactGropName;

                    END;
        
                SELECT  CASE Total / @Rows
                          WHEN 0 THEN 1
                          ELSE ( Total / @Rows ) + 1
                        END AS Total ,
                        RowNum ,
                        Id ,
                        Name ,
                        IsGroup ,
                        Total AS TotalRows
                FROM    ( SELECT    COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                                    ROW_NUMBER() OVER ( ORDER BY Name ) AS RowNum ,
                                    *
                          FROM      @Result
                        ) AS R
                WHERE   R.Name LIKE '%' + @Search + '%' 
			   AND RowNum BETWEEN @Start AND IIF(@Search = '', @End, 100000);

            END;
    END;
