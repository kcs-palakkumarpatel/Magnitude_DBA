-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <20 Dec 2016>
-- Description:	<Search Establishment.>
-- Exec: dbo.WSSearchEstablishmentList 651,7157,18484,'',1,1000
-- =============================================
CREATE PROCEDURE dbo.WSSearchEstablishmentList
    @GroupId BIGINT,
    @ActivityId BIGINT,
    @AppUserId BIGINT,
    @Search NVARCHAR(100),
    @Page INT,
    @Rows INT
AS
BEGIN


    IF OBJECT_ID('dbo.TEST_ESTABLISHMENTLIST', 'U') IS NOT NULL
        DROP TABLE dbo.TEST_ESTABLISHMENTLIST;

    CREATE TABLE dbo.TEST_ESTABLISHMENTLIST
    (
        Total INT,
        RowNum BIGINT,
        Id BIGINT,
        Name NVARCHAR(MAX),
        ContactId BIGINT,
        IsGroup BIT,
        TotalRows INT, 
		CreatedOn DATETIME
    );
    SET NOCOUNT ON;

    DECLARE @Start AS INT;
    DECLARE @End INT;
    DECLARE @Result TABLE
    (
        Id BIGINT,
        Name NVARCHAR(MAX),
        ContactId BIGINT,
        IsGroup BIT,
		CreatedOn DATETIME
    );

    SET @Search = ISNULL(@Search, '');
    SET @Start = ((@Page * @Rows) - @Rows) + 1;
    SET @End = @Start + @Rows - 1;

    INSERT INTO @Result
    (
        Id,
        Name,
        ContactId,
        IsGroup,
		CreatedOn
    )
    SELECT DISTINCT
        E.Id,
        E.EstablishmentName,
        --CASE ISNULL(U.IsDefaultContact,0)
        --WHEN 0 THEN 0 ELSE 
        CASE ISNULL(DCE.ContactId, 0)
            WHEN 0 THEN
                CASE ISNULL(DCA.ContactId, 0)
                    WHEN 0 THEN
                        CASE ISNULL(DCG.ContactId, 0)
                            WHEN 0 THEN
                                0
                            ELSE
                                ISNULL(DCG.ContactId, 0)
                        END
                    ELSE
                        ISNULL(DCA.ContactId, 0)
                END
            ELSE
                ISNULL(DCE.ContactId, 0)
        END
        --END
        AS ContactId,
        ISNULL(DCE.IsGroup, ISNULL(DCA.IsGroup, ISNULL(DCG.IsGroup, 0))),
		DCE.CreatedOn
    FROM dbo.Establishment AS E
        INNER JOIN dbo.EstablishmentGroup AS EG
            ON EG.Id = E.EstablishmentGroupId
               AND E.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment AS AE
            ON AE.EstablishmentId = E.Id
               AND AE.AppUserId = @AppUserId
               AND AE.IsDeleted = 0
        LEFT JOIN dbo.DefaultContact AS DCE
            ON DCE.AppUserId = @AppUserId
               AND DCE.EstablishmentId = E.Id
               AND DCE.IsDeleted = 0
               AND DCE.ContactId != 0
        LEFT JOIN dbo.DefaultContact AS DCA
            ON DCA.AppUserId = @AppUserId
               AND DCA.ActivityId = E.EstablishmentGroupId
               AND DCA.ContactId != 0
               AND DCA.IsDeleted = 0
        LEFT JOIN dbo.DefaultContact AS DCG
            ON DCG.AppUserId = @AppUserId
               AND DCG.GroupId = E.GroupId
               AND DCG.ContactId != 0
               AND DCG.IsDeleted = 0
        LEFT JOIN dbo.AppUser U
            ON U.Id = @AppUserId
    WHERE EG.GroupId = @GroupId
          AND EG.Id = @ActivityId
          AND E.EstablishmentName LIKE '%' + @Search + '%'
          AND EG.EstablishmentGroupType = 'Sales'
          OR EG.EstablishmentGroupType = 'Task'
             AND EG.IsDeleted = 0;

  INSERT INTO TEST_ESTABLISHMENTLIST  SELECT CASE Total / @Rows
               WHEN 0 THEN
                   1
               ELSE
        (Total / @Rows) + 1
           END AS Total,
           RowNum,
           Id,
           Name,
           ContactId,
           IsGroup,
           Total AS TotalRows,
		   CreatedOn 
    FROM
    (
        SELECT COUNT(1) OVER (PARTITION BY 1) AS Total,
               ROW_NUMBER() OVER (ORDER BY Name) AS RowNum,
               *
        FROM @Result
    ) AS R
    WHERE RowNum
    BETWEEN @Start AND @End;

	SELECT * FROM dbo.VW_TEST_ESTABLISHMENTLIST

    SET NOCOUNT OFF;
END;
