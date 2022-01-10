
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WsGetDefaultSettings
-- =============================================
CREATE PROCEDURE [dbo].[WsGetDefaultSettings]
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	DECLARE @LoginFlag BIGINT 
	DECLARE @AzureClientId VARCHAR(100)
	DECLARE @AzureRedirectURL VARCHAR(100)
	SELECT @LoginFlag = LoginFlag, @AzureClientId = AzureClientId, @AzureRedirectURL = AzureRedirectURL FROM dbo.ClientInfo

        SELECT TOP 1
                VideoUrl ,
                SignupUrl ,
                TNCUrl AS TermsAndCondition ,
                TimeoffSet ,
                GETUTCDATE() AS ServerDate,
				@LoginFlag AS Azureflag,
				@AzureClientId AS AzureClientId,
				@AzureRedirectURL AS AzureRedirectURL
        FROM    dbo.AboutUs
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
         'dbo.WsGetDefaultSettings',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
        @AzureClientId,
        @AzureClientId,
	    GETUTCDATE(),
         N''
        );
END CATCH
    END
