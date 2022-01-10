
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,23 Dec 2014>
-- Description:	<Description,,>
-- Call SP:		GetServerDateWeb
-- =============================================
CREATE PROCEDURE [dbo].[GetServerDateWeb]
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        SELECT  GETDATE() AS CurrentDate ,
                GETUTCDATE() AS UTCDate ,
                dbo.ChangeDateFormat(GETDATE(), 'dd/MM/yyyy') AS DateString ,
                dbo.ChangeDateFormat(GETUTCDATE(), 'yyyy-MM-dd HH:MM:ss') AS UTCDateString
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
         'dbo.GetServerDateWeb',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         N'',
         GETUTCDATE(),
         N''
        );
END CATCH
    END
