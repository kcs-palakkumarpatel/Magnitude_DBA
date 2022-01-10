
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WsGetDefaultSettings
-- =============================================
CREATE PROCEDURE [dbo].[WsGetDefaultSettings_111921]
AS 
    BEGIN

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
    END
