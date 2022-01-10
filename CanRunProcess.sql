-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		CanRunProcess 1
-- =============================================
CREATE PROCEDURE [dbo].[CanRunProcess] @ProcessId BIGINT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        UPDATE  dbo.ProcessStatus
        SET     IsRunning = 0
        WHERE   DATEDIFF(MINUTE, LastUpdatedTime, GETUTCDATE()) > 10
                AND IsRunning = 1

		DECLARE @Result BIT
        IF EXISTS ( SELECT  *
                    FROM    dbo.ProcessStatus
                    WHERE   ProcessId = @ProcessId
                            AND IsRunning = 0
                            AND IsEnabled = 1 ) 
            BEGIN
                DECLARE @LastUpdatedDate DATETIME ,
                    @Interval INT ,
                    @StartTime DATETIME ,
                    @EndTime DATETIME
                SELECT  @LastUpdatedDate = LastUpdatedTime ,
                        @Interval = Interval ,
                        @StartTime = StartTime ,
                        @EndTime = EndTime
                FROM    dbo.ProcessStatus
                WHERE   ProcessId = @ProcessId
                IF ( DATEDIFF(MINUTE, @LastUpdatedDate, GETUTCDATE()) >= @Interval ) 
                    BEGIN
                        IF ( CAST(dbo.ChangeDateFormat(GETUTCDATE(),
                                                       'hh:mm AM/PM') AS DATETIME) BETWEEN @StartTime
                                                              AND
                                                              @EndTime ) 
                            BEGIN
                                SET @Result = 1
                            END
                    END
            END
            
        SELECT  ISNULL(@Result, 0) AS CanStartProcess ,
                ModuleId
        FROM    dbo.ProcessStatus
        WHERE   ProcessId = @ProcessId
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
         'dbo.CanRunProcess',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ProcessId,
         GETUTCDATE(),
         N''
        );
END CATCH

   END