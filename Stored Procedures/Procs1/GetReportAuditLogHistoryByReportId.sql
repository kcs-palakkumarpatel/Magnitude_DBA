-- =============================================
-- Author:		Krishna Panchal
-- Create date: 18-March-2021
-- Description:	Get Report Audit Log History by ReportId
-- Call SP:		GetReportAuditLogHistoryByReportId 979255, 1,'29/Apr/21 08:50','29/Apr/21 08:54','','',NULL,1
-- =============================================
CREATE PROCEDURE dbo.GetReportAuditLogHistoryByReportId
    @ReportId BIGINT,
    @isOut BIT,
    @FromDate VARCHAR(50) = NULL,
    @ToDate VARCHAR(50) = NULL,
    @AppUserId VARCHAR(1000) = '',
    @SearchText VARCHAR(1000) = '',
    @CurrenDateTime DATETIME = NULL,
    @isFromMobile BIT = 0
AS
SET NOCOUNT ON;
BEGIN
    DECLARE @EstablishmentID BIGINT,
            @IsFilterApplyed BIT = 0;
    IF (@isOut = 0)
    BEGIN
        SET @EstablishmentID =
        (
            SELECT TOP 1
                   EstablishmentId
            FROM dbo.AnswerMaster
            WHERE Id = @ReportId
                  AND IsDeleted = 0
        );
    END;
    ELSE
        SET @EstablishmentID =
    (
        SELECT TOP 1
               EstablishmentId
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @ReportId
              AND IsDeleted = 0
    )   ;
END;
IF (@CurrenDateTime IS NULL)
BEGIN
    SET @CurrenDateTime = GETDATE();
END;

DECLARE @TimeOffSet BIGINT,
        @DateDiff INT = 0;
SET @TimeOffSet =
(
    SELECT TOP 1
           TimeOffSet
    FROM dbo.Establishment
    WHERE Id = @EstablishmentID
          AND IsDeleted = 0
);
IF (@isFromMobile = 0)
BEGIN
    SELECT @DateDiff = DATEDIFF(MINUTE, @CurrenDateTime, GETUTCDATE());
END;

IF (@FromDate IS NULL AND @ToDate IS NULL)
BEGIN
    SELECT @FromDate = DATEADD(MONTH, -1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()));
    SET @ToDate = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());
END;
ELSE
BEGIN
    SET @IsFilterApplyed = 1;
    IF (@isFromMobile = 0)
    BEGIN
        SET @FromDate = DATEADD(MINUTE, 330, @FromDate);
        SET @ToDate = DATEADD(MINUTE, 330, @ToDate);
    END;
    ELSE
    BEGIN
        SET @FromDate = DATEADD(MINUTE, 0, @FromDate);
        SET @ToDate = DATEADD(MINUTE, 0, @ToDate);
    END;
END;
BEGIN
    SELECT DISTINCT
           AU.Name AS ReadBy,
           ISNULL(FORMAT(CAST(RAL.ReadOn AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us'), '-') AS ReadOn
    FROM dbo.AppUserEstablishment AUE
        LEFT JOIN dbo.ReportAuditLog_History RAL
            ON RAL.AppUserId = AUE.AppUserId
               AND RAL.ReportId = @ReportId
        LEFT JOIN dbo.AppUser AU
            ON AU.Id = AUE.AppUserId
    WHERE AUE.IsDeleted = 0
          AND AUE.EstablishmentId = @EstablishmentID
          AND AU.IsActive = 1
          AND AU.IsDeleted = 0
          AND
          (
              (RAL.AppUserId IN
               (
                   SELECT Data FROM dbo.Split(@AppUserId, ',')
               )
              )
              OR @AppUserId = ''
          )
          AND
          (
              (FORMAT(CAST(RAL.ReadOn AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
          BETWEEN CAST(@FromDate AS DATETIME) AND CAST(@ToDate AS DATETIME)
              )
              OR @FromDate IS NULL
          )
          AND
          (
              (AU.Name LIKE '%' + @SearchText + '%')
              OR @SearchText = ''
          )
         
    ORDER BY ReadOn DESC;
END;
SET NOCOUNT OFF;
