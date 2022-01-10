/****** Object:  StoredProcedure [dbo].[GetReadEmailAuditLogByReportId]    Script Date: 7/15/2021 3:17:47 PM ******/
-- GetReadEmailAuditLogByReportId 933902,1,'','','','','','',0
-- GetReadEmailAuditLogByReportId 208736,1,'','','','','',0,1,10

CREATE PROCEDURE dbo.GetReadEmailAuditLogByReportId
    @ReportId BIGINT,
    @isOut BIT,
    @FromDate VARCHAR(50) = NULL,
    @ToDate VARCHAR(50) = NULL,
    @SearchText VARCHAR(1000) = '',
    @SortExpression VARCHAR(100) = '',
    @SortOrder VARCHAR(10) = '',
    @isFromMobile BIT = 0,
    @Page INT = 1,
    @Rows INT = 50
AS
SET NOCOUNT ON;
BEGIN

    DECLARE @EstablishmentID BIGINT;
    IF (@isOut = 0)
    BEGIN
        SET @EstablishmentID =
        (
            SELECT TOP 1
                EstablishmentId
            FROM dbo.AnswerMaster WITH (NOLOCK)
            WHERE Id = @ReportId
                  AND IsDeleted = 0
        );
    END;
    ELSE
        SET @EstablishmentID =
    (
        SELECT TOP 1
            EstablishmentId
        FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
        WHERE Id = @ReportId
              AND IsDeleted = 0
    )   ;
    DECLARE @TimeOffSet BIGINT;
    SET @TimeOffSet =
    (
        SELECT TOP 1
            TimeOffSet
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = @EstablishmentID
              AND IsDeleted = 0
    );

    SELECT *
    FROM
    (
        SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                               WHEN @SortExpression = '' THEN
                                                   TimeStampDate
                                           END DESC,
                                           CASE
                                               WHEN @SortExpression = 'Name'
                                                    AND @SortOrder = 'ASC' THEN
                                                   Name
                                           END ASC,
                                           CASE
                                               WHEN @SortExpression = 'Name'
                                                    AND @SortOrder = 'DESC' THEN
                                                   Name
                                           END DESC,
                                           CASE
                                               WHEN @SortExpression = 'Email'
                                                    AND @SortOrder = 'ASC' THEN
                                                   Email
                                           END ASC,
                                           CASE
                                               WHEN @SortExpression = 'Email'
                                                    AND @SortOrder = 'DESC' THEN
                                                   Email
                                           END DESC,
                                           CASE
                                               WHEN @SortExpression = 'Date'
                                                    AND @SortOrder = 'ASC' THEN
                                                   TimeStampDate
                                           END ASC,
                                           CASE
                                               WHEN @SortExpression = 'Date'
                                                    AND @SortOrder = 'DESC' THEN
                                                   TimeStampDate
                                           END DESC
                                 ) AS RowNum,
               *
        FROM
        (
            SELECT DISTINCT
                RefID,
                [Name],
                Email,
                [Event],
                FORMAT(dDate, 'dd/MMM/yy HH:mm') AS dDate,
                FORMAT(rDate, 'dd/MMM/yy HH:mm') AS rDate,
                FORMAT(TimeStampDate, 'dd/MMM/yy HH:mm') AS TimeStampDate
            FROM
            (
                SELECT DISTINCT
                    EH.RefID,
                    EH.[Name],
                    EH.Email,
                    EH.[Event],
                    EH.dDate,
                    EH.rDate,
                    DATEADD(MINUTE, @TimeOffSet, (DATEADD(SECOND, CAST(EH.TimeStamp AS INT), '1/1/1970'))) AS TimeStampDate
                FROM
                (
                    SELECT i1.*,
                           (
                               SELECT TOP 1
                                   DATEADD(MINUTE, @TimeOffSet, (DATEADD(SECOND, CAST(TimeStamp AS INT), '1/1/1970')))
                               FROM dbo.EmailHistory
                               WHERE RefID = @ReportId
                                     AND SG_message_id = i1.SG_message_id
                                     AND Event = 'delivered'
                               ORDER BY CAST(TimeStamp AS INT) DESC
                           ) AS dDate,
                           (IIF(
                                EXISTS
                                (
                                    SELECT TOP 1
                                        DATEADD(
                                                   MINUTE,
                                                   @TimeOffSet,
                                                   (DATEADD(SECOND, CAST(TimeStamp AS INT), '1/1/1970'))
                                               )
                                    FROM dbo.EmailHistory
                                    WHERE RefID = @ReportId
                                          AND SG_message_id = i1.SG_message_id
                                          AND Event = 'open'
                                    ORDER BY CAST(TimeStamp AS INT) DESC
                                ),
                            (
                                SELECT TOP 1
                                    DATEADD(MINUTE, @TimeOffSet, (DATEADD(SECOND, CAST(TimeStamp AS INT), '1/1/1970')))
                                FROM dbo.EmailHistory
                                WHERE RefID = @ReportId
                                      AND SG_message_id = i1.SG_message_id
                                      AND Event = 'open'
                                ORDER BY CAST(TimeStamp AS INT) DESC
                            ),
                            (
                                SELECT TOP 1
                                    DATEADD(MINUTE, @TimeOffSet, (DATEADD(SECOND, CAST(TimeStamp AS INT), '1/1/1970')))
                                FROM dbo.EmailHistory
                                WHERE RefID = @ReportId
                                      AND SG_message_id = i1.SG_message_id
                                      AND Event = 'click'
                                ORDER BY CAST(TimeStamp AS INT)
                            ))
                           ) AS rDate
                    FROM
                    (SELECT * FROM EmailHistory WHERE RefID = @ReportId) AS i1
                        LEFT JOIN
                        (SELECT * FROM EmailHistory WHERE RefID = @ReportId) AS i2
                            ON (
                                   i1.SG_message_id = i2.SG_message_id
                                   AND CAST(i1.[TimeStamp] AS INT) < CAST(i2.[TimeStamp] AS INT)
                               )
                    WHERE i2.[TimeStamp] IS NULL
                ) AS EH
                WHERE EH.RefID = @ReportId
                      AND EH.Event IN ( 'delivered', 'open', 'processed', 'click' )
                      AND EH.IsOut = @isOut
                      AND (
                              @SearchText = ''
                              OR (EH.Name LIKE '%' + @SearchText + '%')
                              OR (EH.Email LIKE '%' + @SearchText + '%')
                              OR (EH.Event LIKE '%' + @SearchText + '%')
                          )
            ) AS RowConstrainedResult
            WHERE @FromDate IS NULL
                  OR @FromDate = ''
                  OR (TimeStampDate
                  BETWEEN CAST(@FromDate AS DATETIME) AND CAST(@ToDate AS DATETIME)
                     )
        ) AS RowConstrainedResult1
    ) AS RowConstrainedResult2
    WHERE RowNum > (@Page - 1) * @Rows
          AND RowNum < ((@Page - 1) * @Rows + @Rows + 1);
END;
SET NOCOUNT OFF;
