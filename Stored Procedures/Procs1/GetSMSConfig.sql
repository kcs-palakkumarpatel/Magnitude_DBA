-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,08 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		GetSMSConfig
-- =============================================
CREATE PROCEDURE [dbo].[GetSMSConfig]
AS
    BEGIN
        SELECT  *
        FROM    dbo.SMSConfig;
    END;