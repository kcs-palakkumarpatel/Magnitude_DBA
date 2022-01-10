
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		InsertOrUpdateThemeImage
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateThemeImage]
    @ThemeId BIGINT ,
    @Resolution NVARCHAR(50) ,
    @ImageName NVARCHAR(50)
AS 
    BEGIN
        INSERT  INTO dbo.ThemeImage
                ( ThemeId, Resolution, FileName )
        VALUES  ( @ThemeId, -- ThemeId - bigint
                  @Resolution, -- Resolution - nvarchar(50)
                  @ImageName -- FileName - nvarchar(50)
                  )
    END