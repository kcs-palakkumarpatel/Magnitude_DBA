-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	25-Oct-2017
-- Description:	Get Contact List of this Group by App User.
-- Call: dbo.WSSearchContactList_Mittal 509,1,'',1,50000,1,5201
-- =============================================
CREATE PROCEDURE [dbo].[WSSearchContactList_Mittal]
    @GroupId BIGINT,
    @WithGroup BIT,
    @Search NVARCHAR(100),
    @Page INT,
    @Rows INT,
    @IsWeb BIT,
    @AppUserId BIGINT
AS
BEGIN
    DECLARE @Start AS INT,
            @End INT;
    IF @IsWeb = 0
    BEGIN
        SET @Rows = 50;
    END;
    SET @Search = ISNULL(@Search, '');

   

        --- IF APP USER DON’T HAVE ANY CONTACT ROLES.
        IF @WithGroup = 1
        BEGIN
		PRINT 3
            SELECT CAST(0 AS INT) AS Total,
                   CAST(0 AS BIGINT) AS RowNum,
                   MAIN.ContactMasterId AS Id,
                   MAIN.ContactName AS Name,
                   MAIN.IsGroup AS IsGroup,
                   (COUNT(1) OVER (PARTITION BY 1)) AS TotalRows,
				   CONVERT(varchar, MAIN.LastUsedOn, 20) AS LastUsedOn
            FROM
            (
                SELECT
				CM.Id AS ContactMasterId,C.ContactName,C.ContactAllName,CAST(0 AS BIT) AS IsGroup,
				CM.LastUsedOn AS LastUsedOn
                FROM dbo.ContactMaster AS CM  With (NoLock)
				Join dbo.tblContact C  With (NoLock) on CM.Id = C.ContactMasterId And CM.ContactId = C.ContactId
				--And C.ContactName LIKE '%' + @Search + '%'
                WHERE GroupId = @GroupId
                      AND CM.IsDeleted = 0
				
                UNION ALL
                SELECT cm.Id,
                       ContactGropName,
                       ContactGropName AS ContactAllName,
                       CAST(1 AS BIT) AS IsGroup,
					   LastUsedOn AS LastUsedOn
                FROM dbo.ContactGroup AS cm  With (NoLock)
                WHERE cm.IsDeleted = 0
                      AND cm.GroupId = @GroupId
                GROUP BY cm.Id,
                         cm.ContactGropName,
						 cm.lastusedon
            ) AS MAIN
            WHERE MAIN.ContactName LIKE '%' + @Search + '%'
            ORDER BY MAIN.ContactName ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
        END;
        ELSE
        BEGIN
		PRINT 4
            SELECT CAST(0 AS INT) AS Total,
                   CAST(0 AS BIGINT) AS RowNum,
                   MAIN.ContactMasterId AS Id,
                   MAIN.ContactName AS Name,
                   --MAIN.ContactAllName AS AllName ,
                   MAIN.IsGroup AS IsGroup,
                   (COUNT(1) OVER (PARTITION BY 1)) AS TotalRows,
				   CONVERT(varchar, MAIN.LastUsedOn, 20) AS LastUsedOn
            FROM
            (
                SELECT CM.Id AS ContactMasterId,C.ContactName,C.ContactAllName,CAST(0 AS BIT) AS IsGroup,
				CM.LastUsedOn as LastUsedOn
                FROM dbo.ContactMaster AS CM  With (NoLock)
				Join dbo.tblContact C  With (NoLock) on CM.Id = C.ContactMasterId And CM.ContactId = C.ContactId
                WHERE GroupId = @GroupId
                      AND CM.IsDeleted = 0
            ) AS MAIN
            WHERE MAIN.ContactAllName LIKE '%' + @Search + '%'
            ORDER BY MAIN.ContactName ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
        END;
    
END;
