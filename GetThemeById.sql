
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 02 Jun 2015>
-- Description:	<Description,,GetThemeById>
-- Call SP    :	GetThemeById
-- =============================================
CREATE PROCEDURE [dbo].[GetThemeById] @Id BIGINT
AS
    BEGIN
        SELECT  [Id] AS Id ,
                [ThemeName] AS ThemeName ,
                [Description] AS Description ,
                [ThemeMDPI] AS ThemeMDPI ,
                [ThemeHDPI] AS ThemeHDPI ,
                [ThemeXHDPI] AS ThemeXHDPI ,
                [ThemeXXHDPI] AS ThemeXXHDPI ,
                [Theme640x960] AS Theme640x960 ,
                [Theme640x1136] AS Theme640x1136 ,
                [Theme768x1280] AS Theme768x1280 ,
                Theme750x1334 ,
                Theme1242x2208
        FROM    dbo.[Theme]
        WHERE   [Id] = @Id;
    END;