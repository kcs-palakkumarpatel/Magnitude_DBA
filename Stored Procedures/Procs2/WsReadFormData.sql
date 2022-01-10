
-- =============================================
-- Author:		<Author,,D3>
-- Create date: <Create Date,,30 Oct 2017>
-- Description:	<Description,,>
-- Call SP:		WsReadFormData
-- =============================================
CREATE PROCEDURE [dbo].[WsReadFormData]
    @AppUserId BIGINT,
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
	  END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WsReadFormData',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppuserId+','+@ReportId+','+@IsOut,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
