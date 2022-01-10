-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,CountHeaderSetting>
-- Call SP    :	CountHeaderSetting
-- =============================================
CREATE PROCEDURE [dbo].[CountHeaderSetting]
AS
    BEGIN        SELECT  COUNT(1) AS Result
        FROM    dbo.[HeaderSetting]
        WHERE   IsDeleted = 0;    END;