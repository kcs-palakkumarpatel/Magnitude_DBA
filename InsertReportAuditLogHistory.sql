
-- =============================================
-- Author:		Krishna Panchal
-- Create date: 27-Sep-2021
-- Description:	Insert Report Audit Log History
-- Call SP:		InsertReportAuditLogHistory 978954, 6994
-- =============================================
CREATE PROCEDURE dbo.InsertReportAuditLogHistory
    @AppuserId BIGINT,
    @SeenClientAnswerMasterId BIGINT
AS
BEGIN
    DECLARE @EstablishmentID BIGINT,
            @TimeOffSet INT;
    SET @EstablishmentID =
    (
        SELECT EstablishmentId
        FROM SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMasterId
    );
    SET @TimeOffSet =
    (
        SELECT TimeOffSet FROM Establishment WHERE Id = @EstablishmentID
    );

    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.ReportAuditLog
        WHERE AppUserId = @AppuserId
              AND ReportId = @SeenClientAnswerMasterId
              AND isOut = 1
    )
    BEGIN
        INSERT INTO ReportAuditLog
        (
            AppUserId,
            EstablishmentId,
            ReportId,
            isOut,
            ReadOn,
            IsDeleted
        )
        VALUES
        (@AppuserId, @EstablishmentID, @SeenClientAnswerMasterId, 1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), 0);
    END;

    INSERT INTO ReportAuditLog_History
    (
        AppUserId,
        EstablishmentId,
        ReportId,
        isOut,
        ReadOn,
        IsDeleted
    )
    VALUES
    (@AppuserId, @EstablishmentID, @SeenClientAnswerMasterId, 1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), 0);
END;

