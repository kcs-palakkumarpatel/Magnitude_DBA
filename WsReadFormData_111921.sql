
-- =============================================
-- Author:		<Author,,D3>
-- Create date: <Create Date,,30 Oct 2017>
-- Description:	<Description,,>
-- Call SP:		WsReadFormData
-- =============================================
CREATE PROCEDURE [dbo].[WsReadFormData_111921]
    @AppUserId BIGINT,
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN
	
	Declare @EstablishmentID BIGINT = 0,
	@offSet INTEGER;


    IF @IsOut = 1
    BEGIN
        UPDATE dbo.SeenClientAnswerMaster
        SET IsOutStanding = 0,
            ReadBy = @AppUserId
        WHERE Id = @ReportId;
		SET @EstablishmentID = (select EstablishmentId From SeenClientAnswerMaster where Id = @ReportId);
        IF EXISTS
        (
            SELECT *
            FROM dbo.AnswerMaster
            WHERE SeenClientAnswerMasterId = @ReportId
        )
        BEGIN
            UPDATE dbo.AnswerMaster
            SET IsOutStanding = 0,
                ReadBy = @AppUserId
            WHERE SeenClientAnswerMasterId = @ReportId;
        END;

        UPDATE dbo.PendingNotificationWeb
        SET IsRead = 1
        WHERE RefId = @ReportId
              AND AppUserId = @AppUserId
              AND ModuleId = 3;
    END;
    ELSE
    BEGIN
        UPDATE dbo.AnswerMaster
        SET IsOutStanding = 0,
            ReadBy = @AppUserId
        WHERE Id = @ReportId;
		SET @EstablishmentID = (select EstablishmentId From AnswerMaster where Id = @ReportId);
        UPDATE dbo.PendingNotificationWeb
        SET IsRead = 1
        WHERE RefId = @ReportId
              AND AppUserId = @AppUserId
              AND ModuleId = 2;
    END;	

	SET @offSet = (Select TimeOffSet from Establishment where Id = @EstablishmentID)

	IF NOT EXISTS
        (
            SELECT *
            FROM dbo.ReportAuditLog
            WHERE AppUserId = @AppUserId
			AND ReportId = @ReportId
			AND IsOut = @IsOut
        )
		BEGIN
			INSERT INTO ReportAuditLog (AppUserId, EstablishmentId, ReportId, isOut, ReadOn, isDeleted)
			VALUES(@AppUserId, @EstablishmentID, @ReportId, @IsOut, DATEADD(MINUTE, @offSet, GETUTCDATE()), 0);
		END

	  INSERT INTO ReportAuditLog_History (AppUserId, EstablishmentId, ReportId, isOut, ReadOn, isDeleted)
	  VALUES(@AppUserId, @EstablishmentID, @ReportId, @IsOut, DATEADD(MINUTE, @offSet, GETUTCDATE()), 0);

END;
