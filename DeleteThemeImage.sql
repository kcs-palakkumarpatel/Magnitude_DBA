
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		DeleteThemeImage
-- =============================================
CREATE PROCEDURE [dbo].[DeleteThemeImage]
    @ThemeId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
        DELETE  FROM dbo.ThemeImage
        WHERE   ThemeId = @ThemeId
                AND Resolution = @Resolution
    END