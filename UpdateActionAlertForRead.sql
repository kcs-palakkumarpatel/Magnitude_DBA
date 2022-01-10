
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateActionAlertForRead] 
	@AppuserId BIGINT,
	@ReportId BIGINT
AS
 BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @REfId AS TABLE ( refid BIGINT );
            BEGIN
                INSERT  INTO @REfId
                        ( refid )
                VALUES  ( @ReportId  -- refid - bigint
                          );
                INSERT  INTO @REfId
                        ( refid
                        )
                      SELECT ISNULL(SeenClientAnswerMasterId, 0)
                        FROM    dbo.AnswerMaster
                        WHERE   Id = @ReportId
						UNION
						SELECT Id FROM dbo.AnswerMaster WHERE (SeenClientAnswerMasterId = 
						(SELECT ISNULL(SeenClientAnswerMasterId, 0)
												FROM    dbo.AnswerMaster
												WHERE   Id = @ReportId) OR SeenClientAnswerMasterId = @ReportId)
            END;
      
        UPDATE  dbo.PendingNotificationWeb
        SET     IsRead = 1
        WHERE   RefId IN ( SELECT   refid
                           FROM     @REfId )
                AND AppUserId = @AppuserId
                AND IsDeleted = 0
                AND IsRead = 0
                AND ModuleId IN (7,8, 11, 12,6 );
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
         'dbo.UpdateActionAlertForRead',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppuserId+','+@ReportId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    END;
----BEGIN
----    UPDATE  dbo.PendingNotificationWeb
----    SET     IsRead = 1
----    WHERE   RefId = @ReportId
----            AND AppUserId = @AppuserId
----            AND IsDeleted = 0
----            AND IsRead = 0
----            AND ModuleId IN ( 11, 12 );
----END
