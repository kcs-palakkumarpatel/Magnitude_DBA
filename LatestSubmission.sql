-- =============================================
-- Author:		<Ankit Mistry>
-- Create date: <21 Jan 2019>
-- Description:	<Get Latest Submission>
-- Call : LatestSubmission 200,'','','500','1','DateTime DESC'
-- =============================================
CREATE PROCEDURE [dbo].[LatestSubmission]
    @Id BIGINT,
    @FromDate DATE = '',
    @Todate DATE = '',
    @Rows INT,
    @Page INT,
    @Sort NVARCHAR(50)
AS
BEGIN

    DECLARE @Result AS TABLE
    (
        RowNum INT,
        Activity NVARCHAR(100),
        Establishment NVARCHAR(100),
        ReferenceNo BIGINT,
        [USER] NVARCHAR(50),
        contact NVARCHAR(100),
        [Group] NVARCHAR(100),
        [DateTime] DATETIME,
        formtype NVARCHAR(10)
    );

    DECLARE @Start AS INT,
            @End INT;

    SET @Start = ((@Page * @Rows) - @Rows) + 1;
    SET @End = @Start + @Rows - 1;

    DECLARE @TempAppuserId TABLE (AppUserId BIGINT);
    DECLARE @AppUserId NVARCHAR(MAX);
    INSERT INTO @TempAppuserId
    (
        AppUserId
    )
    SELECT Id
    FROM dbo.AppUser
    WHERE CreatedBy = @Id;
    IF EXISTS (SELECT * FROM @TempAppuserId)
    BEGIN
        SELECT @AppUserId = COALESCE(@AppUserId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(AppUserId, ''))
        FROM @TempAppuserId
        GROUP BY AppUserId;
        SET @AppUserId = CAST(@AppUserId + ', ' + CONVERT(NVARCHAR(MAX), @Id) AS NVARCHAR(MAX));
    END;
    ELSE
    BEGIN
        SELECT @AppUserId = @Id;
    END;

    DECLARE @Query VARCHAR(MAX);

    SELECT @Query
        = 'SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY [DateTime] DESC) AS [RowNum],* FROM(
 SELECT EG.EstablishmentGroupName AS [Activity],E.EstablishmentName AS [Establishment],SAM.Id AS [Reference No],AUSAM.[Name] AS [User],
 C.ContactTitle AS [Contact],G.GroupName AS [Group],  DATEADD(MINUTE, E.TimeOffSet, SAM.CreatedOn) AS [DateTime],''Out'' AS [formtype] FROM SeenClientAnswerMaster SAM
 INNER JOIN dbo.AppUser AUSAM ON SAM.AppUserId = AUSAM.Id INNER JOIN Establishment E ON E.Id = SAM.EstablishmentId INNER JOIN dbo.EstablishmentGroup EG
 ON E.EstablishmentGroupId = EG.Id INNER JOIN dbo.[Group] G ON G.Id = EG.GroupId INNER JOIN dbo.Contact C ON C.Id = G.ContactId WHERE SAM.IsDeleted = 0
 AND AUSAM.Id IN (' + @AppUserId
          + ') GROUP BY SAM.Id, EG.EstablishmentGroupName, E.EstablishmentName, AUSAM.[Name], DATEADD(MINUTE, E.TimeOffSet, SAM.CreatedOn), C.ContactTitle, G.GroupName
        UNION ALL
 SELECT EG.EstablishmentGroupName AS [Activity], E.EstablishmentName AS [Establishment], AM.Id AS [Reference No], AUAM.[Name] AS [User], C.ContactTitle AS [Contact],
 G.GroupName AS [Group],DATEADD(MINUTE, E.TimeOffSet, AM.CreatedOn) AS [DateTime], ''In'' AS [formtype] FROM dbo.AnswerMaster AM INNER JOIN dbo.AppUser AUAM ON AM.AppUserId = AUAM.Id
  INNER JOIN Establishment E ON E.Id = AM.EstablishmentId INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id INNER JOIN dbo.[Group] G
 ON G.Id = EG.GroupId INNER JOIN dbo.Contact C ON C.Id = G.ContactId WHERE AM.IsDeleted = 0 AND AUAM.Id IN ( '
          + @AppUserId
          + ' )
 GROUP BY AM.Id,EG.EstablishmentGroupName,E.EstablishmentName,AUAM.[Name],DATEADD(MINUTE, E.TimeOffSet, AM.CreatedOn),C.ContactTitle,G.GroupName) AS [TABLE]) AS MainTable WHERE MainTable.RowNum
BETWEEN ' + CONVERT(VARCHAR(MAX), @Start) + ' AND ' + CONVERT(VARCHAR(MAX), @End) + '
ORDER BY [DateTime] DESC;';

    --PRINT (@Query)

    INSERT INTO @Result
    (
        RowNum,
        Activity,
        Establishment,
        ReferenceNo,
        [USER],
        contact,
        [Group],
        DateTime,
        formtype
    )
    EXEC (@Query);

    SELECT RowNum,
           Activity,
           Establishment,
           ReferenceNo,
           [USER],
           contact,
           [Group],
           dbo.ChangeDateFormat([DateTime], 'dd/MMM/yyyy hh:mm AM/PM') AS [DateTime],
           formtype
    FROM @Result;

END;
