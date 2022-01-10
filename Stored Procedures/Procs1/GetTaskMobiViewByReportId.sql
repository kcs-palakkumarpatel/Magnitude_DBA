-- =============================================
-- Author:				Sunil Vaghasiya
-- Create date:		21-June-2017
-- Description:	Get feedback IN by SeenClientAnswerMasterId
-- Call SP:			dbo.GetTaskMobiViewByReportId 976333, 1246
-- =============================================
CREATE PROCEDURE [dbo].[GetTaskMobiViewByReportId]
    @ReportId BIGINT,
    @AppuserId BIGINT,
    @Page INT = 1, /* Select Page No  */
    @Rows INT = 20
AS
BEGIN

    DECLARE @TotalPageCount INT;

    IF @Rows <> ''
       AND @Rows IS NULL
    BEGIN
        SET @Rows = 20;
    END;

    IF @Page <> ''
       AND @Page IS NULL
    BEGIN
        SET @Page = 1;
    END;

    SELECT @TotalPageCount = 1 + COUNT(1) / @Rows
    FROM dbo.AnswerMaster
    WHERE SeenClientAnswerMasterId = @ReportId
          AND IsDeleted = 0;

    SELECT AM.Id AS MobiId,
           AM.EstablishmentId,
           AM.PI AS PI,
           E.EstablishmentName AS EstablishmentName,
           Eg.EstablishmentGroupName AS ActivityName,
           Eg.Id AS ActivityId,
           Eg.SeenClientId,
           Eg.SadTo,
           Eg.NeutralTo,
           '' AS PIColourCode,
           U.Name AS CapturedBy,
           dbo.ChangeDateFormat(DATEADD(MINUTE, AM.TimeOffSet, AM.CreatedOn), 'dd/MMM/yy HH:mm') AS CaptureDate,
           CAST(0 AS BIGINT) AS RowNum,
           @TotalPageCount AS Total,
		   ISNULL(AM.IsFlag,0) AS IsFlag,
		   ISNULL(AM.IsDisabled,0) AS IsDisabled,
		   ISNULL(U.AllowDeleteFeedback,0) AS AllowDeleteFeedback,
		   ISNULL(U.AllowExportData,0) AS AllowExportData
    FROM dbo.AnswerMaster AS AM
        INNER JOIN dbo.Establishment AS E
            ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        LEFT OUTER JOIN dbo.AppUser AS U
            ON AM.AppUserId = U.Id
    WHERE AM.SeenClientAnswerMasterId = @ReportId
          AND ISNULL(AM.IsDeleted, 0) = 0
    ORDER BY AM.CreatedOn ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

    SELECT TOP 1
           ISNULL(Conversation, '') AS LastChat,
           ISNULL(CustomerName, '') AS LastChatBy,
           (
               SELECT ISNULL(
                      (
                          SELECT TOP 1
                                 SUM(   CASE
                                            WHEN IsRead = 0 THEN
                                                1
                                            ELSE
                                                0
                                        END
                                    ) OVER () AS Unread
                          FROM dbo.PendingNotificationWeb
                          WHERE RefId = @ReportId
                                AND AppUserId = @AppuserId
                                AND ModuleId IN ( 11, 12 )
                      ),
                      0
                            )
           ) AS ChatCount
    FROM ChatDetails
    WHERE SeenClientAnswerMasterId = @ReportId
    ORDER BY ChatId DESC;
END;


