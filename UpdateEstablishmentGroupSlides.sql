-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,25 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateEstablishmentGroupSlides
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEstablishmentGroupSlides]
    @Id BIGINT ,
    @ThemeMDPI NVARCHAR(50) ,
    @ThemeHDPI NVARCHAR(50) ,
    @ThemeXHDPI NVARCHAR(50) ,
    @ThemeXXHDPI NVARCHAR(50) ,
    @Theme640x960 NVARCHAR(50) ,
    @Theme640x1136 NVARCHAR(50) ,
    @Theme768x1280 NVARCHAR(50) ,
    @Theme750x1334 NVARCHAR(50) ,
    @Theme1242x2208 NVARCHAR(50)
AS
    BEGIN
        SET @ThemeMDPI = NULL;
        SET @ThemeHDPI = NULL;
        SET @ThemeXHDPI = NULL; 
        SET @ThemeXXHDPI = NULL; 
        SET @Theme640x960 = NULL;
        SET @Theme640x1136 = NULL;
        SET @Theme768x1280 = NULL;
        SET @Theme750x1334 = NULL;
        SET @Theme1242x2208 = NULL;

        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'ThemeMDPI' )
            BEGIN
                SET @ThemeMDPI = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/ThemeMDPI';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'ThemeHDPI' )
            BEGIN
                SET @ThemeHDPI = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/ThemeHDPI';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'ThemeXHDPI' )
            BEGIN
                SET @ThemeXHDPI = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/ThemeXHDPI';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'ThemeXXHDPI' )
            BEGIN
                SET @ThemeXXHDPI = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/ThemeXXHDPI';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'Theme640x960' )
            BEGIN
                SET @Theme640x960 = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/Theme640x960';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'Theme640x1136' )
            BEGIN
                SET @Theme640x1136 = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/Theme640x1136';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'Theme768x1280' )
            BEGIN
                SET @Theme768x1280 = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/Theme768x1280';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'Theme750x1334' )
            BEGIN
                SET @Theme750x1334 = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/Theme750x1334';
            END;
        IF EXISTS ( SELECT  *
                    FROM    dbo.EstablishmentGroupImage
                    WHERE   EstablishmentGroupId = @Id
                            AND Resolution = 'Theme1242x2208' )
            BEGIN
                SET @Theme1242x2208 = '/' + CONVERT(NVARCHAR(10), @Id)
                    + '/Theme1242x2208';
            END;
        UPDATE  dbo.[EstablishmentGroup]
        SET     [ThemeMDPI] = @ThemeMDPI ,
                [ThemeHDPI] = @ThemeHDPI ,
                [ThemeXHDPI] = @ThemeXHDPI ,
                [ThemeXXHDPI] = @ThemeXXHDPI ,
                [Theme640x960] = @Theme640x960 ,
                [Theme640x1136] = @Theme640x1136 ,
                [Theme768x1280] = @Theme768x1280 ,
                [Theme750x1334] = @Theme750x1334 ,
                [Theme1242x2208] = @Theme1242x2208
        WHERE   [Id] = @Id;
    END;