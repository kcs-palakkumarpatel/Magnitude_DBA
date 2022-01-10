--GetHeaderSettingByActivityId 5211
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingById>
-- Call SP    :	GetHeaderSettingByActivityId 7345
-- =============================================
CREATE PROCEDURE [dbo].[GetHeaderSettingByActivityId_20Sept2021] @ActivityId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @GroupIds BIGINT = 0;
    SET @GroupIds =
    (
        SELECT GroupId FROM dbo.EstablishmentGroup WHERE Id = @ActivityId
    );
    IF OBJECT_ID('tempdb..#HeaderList', 'U') IS NOT NULL
        DROP TABLE #HeaderList;
    CREATE TABLE #HeaderList
    (
        Id BIGINT IDENTITY(1, 1),
        HeaderId BIGINT,
        GroupId BIGINT,
        EstablishmentGroupId BIGINT,
        HeaderName NVARCHAR(2000),
        HeaderValue NVARCHAR(2000),
        IsLabel BIT,
        LabelColor NVARCHAR(50),
        IsGroupWise INT
    );

    INSERT INTO #HeaderList
    (
        HeaderId,
        GroupId,
        EstablishmentGroupId,
        HeaderName,
        HeaderValue,
        IsLabel,
        LabelColor,
        IsGroupWise
    )
    SELECT TOP 34
        h.[HeaderId] AS HeaderId,
        CAST(EG.GroupId AS BIGINT) AS GroupId,
        h.[EstablishmentGroupId] AS ActivityId,
        ISNULL(h.[HeaderName], '') AS HeaderName,
        ISNULL(h.[HeaderValue], '') AS HeaderValue,
        ISNULL(h.IsLabel, wb.IsLabel) AS IsLabel,
        ISNULL(h.LabelColor, '') AS LabelColor,
        wb.IsGroupWise AS IsGroupWise
    FROM dbo.[HeaderSetting] AS h
        INNER JOIN dbo.EstablishmentGroup AS EG  WITH(NOLOCK)
            ON EG.Id = h.EstablishmentGroupId
        INNER JOIN dbo.WebAppHeaders AS wb  WITH(NOLOCK)
            ON wb.Id = h.HeaderId
               AND wb.IsDeleted = 0
    WHERE h.EstablishmentGroupId = @ActivityId
          AND h.IsDeleted = 0
    ORDER BY h.HeaderSettingId DESC;

    INSERT INTO #HeaderList
    (
        HeaderId,
        GroupId,
        EstablishmentGroupId,
        HeaderName,
        HeaderValue,
        IsLabel,
        LabelColor,
        IsGroupWise
    )
    SELECT wb.Id AS HeaderId,
           @GroupIds AS GroupId,
           @ActivityId AS ActivityId,
           ISNULL(wb.LabelName, '') AS HeaderName,
           wb.LabelName AS HeaderValue,
           'true' AS IsLabel,
           '' AS LabelColor,
           wb.IsGroupWise AS IsGroupWise
    FROM dbo.WebAppHeaders AS wb
    WHERE wb.IsDeleted = 0
          AND wb.Id NOT IN (
                               SELECT HeaderId
                               FROM dbo.HeaderSetting
                               WHERE EstablishmentGroupId = @ActivityId
                           )
          AND wb.IsLabel = 1
    UNION ALL
    SELECT wb.Id AS HeaderId,
           @GroupIds AS GroupId,
           @ActivityId AS ActivityId,
           ISNULL(wb.LabelName, '') AS HeaderName,
           wb.LabelName AS HeaderValue,
           'false' AS IsLabel,
           '' AS LabelColor,
           wb.IsGroupWise AS IsGroupWise
    FROM dbo.WebAppHeaders AS wb  WITH(NOLOCK)
    WHERE wb.IsDeleted = 0
          AND wb.Id NOT IN (
                               SELECT HeaderId
                               FROM dbo.HeaderSetting
                               WHERE EstablishmentGroupId = @ActivityId
                           )
          AND wb.IsLabel = 0;


    SELECT
        HeaderId,
        GroupId,
        EstablishmentGroupId AS ActivityId,
        LTRIM(RTRIM(HeaderName)) AS HeaderName,
        HeaderValue,
        IsLabel,
        ISNULL(LabelColor, '') AS LabelColor,
        ISNULL(IsGroupWise, 0) AS IsGroupWise
    FROM #HeaderList
    GROUP BY HeaderName,
             HeaderValue,
             HeaderId,
             EstablishmentGroupId,
             GroupId,
             IsLabel,
             LabelColor,
             IsGroupWise
    ORDER BY LTRIM(RTRIM(HeaderName)) ASC;
    SET NOCOUNT OFF;
END;
