

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,CountUser>
-- Call SP    :	CountUser
-- =============================================
CREATE PROCEDURE [dbo].[CountUser]
AS 
    BEGIN
        SELECT  COUNT(1) AS Result
        FROM    dbo.[User]
        WHERE   IsDeleted = 0
    END