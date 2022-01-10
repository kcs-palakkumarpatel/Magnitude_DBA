-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	25-Oct-2017
-- Description:	Get Contact List of this Group by App User.
-- Call:	WSSearchContactList_24102018 234,0,'',1,1000,1,2611				
-- =============================================
CREATE PROCEDURE dbo.WSSearchContactList_ForExport
    @GroupId BIGINT ,
    @WithGroup BIT ,
    @Search NVARCHAR(100) ,
    @Page INT ,
    @Rows INT ,
    @IsWeb BIT ,
    @AppUserId BIGINT
AS
    BEGIN
	DECLARE @Start AS INT , @End INT;
	IF @IsWeb = 0
    BEGIN
        SET @Rows = 50;
    END;
	SET @Search = ISNULL(@Search, '');

	IF EXISTS ( SELECT  ( 1 ) FROM    dbo.AppUserContactRole WHERE   AppUserId = @AppUserId )
	BEGIN
	IF @WithGroup = 1
	BEGIN
		SELECT 
				CASE ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows
                  WHEN 0 THEN 1
                  ELSE ( ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows ) + 1
                END AS Total,
				ROW_NUMBER() OVER ( ORDER BY MAIN.ContactName ASC ) AS RowNum ,
                MAIN.ContactMasterId AS Id ,
                MAIN.ContactName AS Name ,
                MAIN.IsGroup AS IsGroup ,
                ( COUNT(1) OVER ( PARTITION BY 1 ) ) AS TotalRows				
				 FROM (
				SELECT 
				MD.Id AS ContactMasterId,
				( STUFF(( SELECT    '|' + CD.Detail
                                      FROM      dbo.ContactDetails AS CD
                                                INNER JOIN dbo.ContactQuestions
                                                AS CQ ON CQ.Id = CD.ContactQuestionId
                                      WHERE     CD.ContactMasterId =  MD.Id
                                                AND CQ.ContactId = MD.ContactId
                                                AND CQ.IsDeleted = 0
                                                AND CQ.IsDisplayInSummary = 1
                                      ORDER BY  CQ.Position ASC
                                    FOR
                                      XML PATH('')
                                    ), 1, 1, '') ) AS ContactName, 
									 CAST(0 AS BIT) AS IsGroup
									
									FROM  ( 
									SELECT DISTINCT CM.Id , CM.GroupId, CM.ContactId
								FROM  ( SELECT    Id , CreatedBy, GroupId, ContactId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0
								UNION ALL 
								SELECT    Id , UpdatedBy, GroupId, ContactId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0 AND UpdatedBy IS NOT NULL
                        ) AS CM
						INNER JOIN ( SELECT ISNULL(CRD.AppEstablishmentUserId, 0)  AS AppUserId FROM dbo.ContactRole 
						 INNER JOIN dbo.AppUserContactRole	AS ACR ON ACR.ContactRoleId = ContactRole.Id AND ACR.IsDeleted = 0
						 INNER JOIN dbo.ContactRoleDetails AS CRD ON CRD.ContactRoleId = ContactRole.Id
						 WHERE GroupId=@GroupId AND ACR.AppUserId = @AppUserId
						 GROUP BY ISNULL(CRD.AppEstablishmentUserId, 0) ) AS CRR ON CRR.AppUserId = CM.CreatedBy ) AS MD
						 UNION ALL
						         SELECT DISTINCT
                                cm.Id ,
                                ContactGropName ,
                                CAST(1 AS BIT) AS IsGroup
                        FROM    dbo.ContactGroup AS cm
                                INNER JOIN ContactRole AS c ON c.GroupId = @GroupId
                                INNER JOIN dbo.ContactRoleDetails AS crd ON crd.ContactRoleId = c.Id AND ( crd.AppEstablishmentUserId = cm.CreatedBy OR cm.CreatedBy = 0 OR crd.AppEstablishmentUserId = cm.UpdatedBy OR cm.UpdatedBy = 0)
                                INNER JOIN dbo.AppUserContactRole AS ac ON ac.ContactRoleId = c.Id AND ac.AppUserId = @AppUserId AND ac.IsDeleted = 0
                        WHERE   cm.IsDeleted = 0
                                AND cm.GroupId = @GroupId					 
						 
						  ) AS MAIN
						 WHERE MAIN.ContactName LIKE '%'+@Search+'%'
        ORDER BY MAIN.ContactName ASC
                OFFSET ( ( @Page - 1 ) * @Rows ) ROWS FETCH NEXT @Rows ROWS
                ONLY; 
                
                    END
	ELSE
		BEGIN
		SELECT 
				CASE ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows
                  WHEN 0 THEN 1
                  ELSE ( ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows ) + 1
                END AS Total,
				ROW_NUMBER() OVER ( ORDER BY MAIN.ContactName ASC ) AS RowNum ,
                MAIN.ContactMasterId AS Id ,
                MAIN.ContactName AS Name ,
                MAIN.IsGroup AS IsGroup ,
                ( COUNT(1) OVER ( PARTITION BY 1 ) ) AS TotalRows				
				 FROM (
				SELECT 
				MD.Id AS ContactMasterId,
				( STUFF(( SELECT    '|' + CD.Detail
                                      FROM      dbo.ContactDetails AS CD
                                                INNER JOIN dbo.ContactQuestions
                                                AS CQ ON CQ.Id = CD.ContactQuestionId
                                      WHERE     CD.ContactMasterId =  MD.Id
                                                AND CQ.ContactId = MD.ContactId
                                                AND CQ.IsDeleted = 0
                                                AND CQ.IsDisplayInSummary = 1
                                      ORDER BY  CQ.Position ASC
                                    FOR
                                      XML PATH('')
                                    ), 1, 1, '') ) AS ContactName, 
									 CAST(0 AS BIT) AS IsGroup
									
									FROM  ( SELECT DISTINCT CM.Id , CM.GroupId, CM.ContactId
				FROM  ( SELECT    Id , CreatedBy, GroupId, ContactId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0
								UNION ALL 
								SELECT    Id , UpdatedBy, GroupId, ContactId FROM      dbo.ContactMaster WHERE GroupId = @GroupId AND IsDeleted = 0 AND UpdatedBy IS NOT NULL
                        ) AS CM
						INNER JOIN ( SELECT ISNULL(CRD.AppEstablishmentUserId, 0)  AS AppUserId FROM dbo.ContactRole 
						 INNER JOIN dbo.AppUserContactRole	AS ACR ON ACR.ContactRoleId = ContactRole.Id AND ACR.IsDeleted = 0
						 INNER JOIN dbo.ContactRoleDetails AS CRD ON CRD.ContactRoleId = ContactRole.Id
						 WHERE GroupId=@GroupId AND ACR.AppUserId = @AppUserId
						 GROUP BY ISNULL(CRD.AppEstablishmentUserId, 0) ) AS CRR ON CRR.AppUserId = CM.CreatedBy ) AS MD ) AS MAIN
						 WHERE MAIN.ContactName LIKE '%'+@Search+'%'
        ORDER BY MAIN.ContactName ASC
                OFFSET ( ( @Page - 1 ) * @Rows ) ROWS FETCH NEXT @Rows ROWS
                ONLY; 
		END
	END;
	ELSE
	BEGIN
	--- IF APP USER DON’T HAVE ANY CONTACT ROLES.
		IF @WithGroup = 1
		BEGIN
		SELECT  
				CASE ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows
                  WHEN 0 THEN 1
                  ELSE ( ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows ) + 1
                END AS Total,
				ROW_NUMBER() OVER ( ORDER BY MAIN.ContactName ASC ) AS RowNum ,
                MAIN.ContactMasterId AS Id ,
                MAIN.ContactName AS Name ,
                MAIN.IsGroup AS IsGroup ,
                ( COUNT(1) OVER ( PARTITION BY 1 ) ) AS TotalRows
        FROM    ( SELECT    CM.Id AS ContactMasterId ,
                            ( STUFF(( SELECT    '|' + CD.Detail
                                      FROM      dbo.ContactDetails AS CD
                                                INNER JOIN dbo.ContactQuestions
                                                AS CQ ON CQ.Id = CD.ContactQuestionId
                                      WHERE     CD.ContactMasterId = CM.Id
                                                AND CQ.ContactId = CM.ContactId
                                                AND CQ.IsDeleted = 0
                                                AND CQ.IsDisplayInSummary = 1
                                      ORDER BY  CQ.Position ASC
                                    FOR
                                      XML PATH('')
                                    ), 1, 1, '') ) AS ContactName ,
                            CAST(0 AS BIT) AS IsGroup
                  FROM      dbo.ContactMaster AS CM
                  WHERE     GroupId = @GroupId
                            AND CM.IsDeleted = 0
                  UNION	 ALL
                  SELECT    cm.Id ,
                            ContactGropName ,
                            CAST(1 AS BIT) AS IsGroup
                  FROM      dbo.ContactGroup AS cm
                  WHERE     cm.IsDeleted = 0
                            AND cm.GroupId = @GroupId
                  GROUP BY  cm.Id ,
                            cm.ContactGropName
                ) AS MAIN
				WHERE MAIN.ContactName LIKE '%'+@Search+'%'
        ORDER BY MAIN.ContactName ASC
                OFFSET ( ( @Page - 1 ) * @Rows ) ROWS FETCH NEXT @Rows ROWS
                ONLY; 
		END
		ELSE
		BEGIN
		SELECT 
				CASE ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows
                  WHEN 0 THEN 1
                  ELSE ( ( COUNT(1) OVER ( PARTITION BY 1 ) ) / @Rows ) + 1
                END AS Total,
				ROW_NUMBER() OVER ( ORDER BY MAIN.ContactName ASC ) AS RowNum ,
                MAIN.ContactMasterId AS Id ,
                MAIN.ContactName AS Name ,
                MAIN.IsGroup AS IsGroup ,
                ( COUNT(1) OVER ( PARTITION BY 1 ) ) AS TotalRows
        FROM    ( SELECT    CM.Id AS ContactMasterId ,
                            ( STUFF(( SELECT    '|' + CD.Detail
                                      FROM      dbo.ContactDetails AS CD
                                                INNER JOIN dbo.ContactQuestions
                                                AS CQ ON CQ.Id = CD.ContactQuestionId
                                      WHERE     CD.ContactMasterId = CM.Id
                                                AND CQ.ContactId = CM.ContactId
                                                AND CQ.IsDeleted = 0
                                                AND CQ.IsDisplayInSummary = 1
                                      ORDER BY  CQ.Position ASC
                                    FOR
                                      XML PATH('')
                                    ), 1, 1, '') ) AS ContactName ,
                            CAST(0 AS BIT) AS IsGroup
                  FROM      dbo.ContactMaster AS CM
                  WHERE     GroupId = @GroupId
                            AND CM.IsDeleted = 0
                ) AS MAIN
				WHERE MAIN.ContactName LIKE '%'+@Search+'%'
        ORDER BY MAIN.ContactName ASC
                OFFSET ( ( @Page - 1 ) * @Rows ) ROWS FETCH NEXT @Rows ROWS
                ONLY; 
		END
       END;

    END;
