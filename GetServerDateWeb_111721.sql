
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,23 Dec 2014>
-- Description:	<Description,,>
-- Call SP:		GetServerDateWeb
-- =============================================
CREATE PROCEDURE [dbo].[GetServerDateWeb_111721]
AS 
    BEGIN
        SELECT  GETDATE() AS CurrentDate ,
                GETUTCDATE() AS UTCDate ,
                dbo.ChangeDateFormat(GETDATE(), 'dd/MM/yyyy') AS DateString ,
                dbo.ChangeDateFormat(GETUTCDATE(), 'yyyy-MM-dd HH:MM:ss') AS UTCDateString
    END
