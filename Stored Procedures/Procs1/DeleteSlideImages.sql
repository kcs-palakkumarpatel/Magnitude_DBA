-- =============================================
-- Author:		GD
-- Create date: 10 Aug 2015
-- Description:	Delete Slide Images
-- Call SP:		DeleteSlideImages
-- =============================================
CREATE PROCEDURE [dbo].[DeleteSlideImages]
    @ActivityId BIGINT ,
    @Resolution NVARCHAR(50) ,
    @FileName NVARCHAR(100)
AS
    BEGIN
        DELETE  FROM dbo.EstablishmentGroupImage
        WHERE   EstablishmentGroupId = @ActivityId
                AND Resolution = @Resolution
                AND [FileName] = @FileName;

        IF NOT EXISTS ( SELECT  *
                        FROM    EstablishmentGroupImage
                        WHERE   EstablishmentGroupId = @ActivityId )
            BEGIN
                PRINT 'All Deleted';
                IF @Resolution = 'ThemeMDPI'
                    UPDATE  dbo.EstablishmentGroup
                    SET     ThemeMDPI = NULL
                    WHERE   Id = @ActivityId;
                ELSE
                    IF @Resolution = 'ThemeHDPI'
                        UPDATE  dbo.EstablishmentGroup
                        SET     ThemeHDPI = NULL
                        WHERE   Id = @ActivityId;
                    ELSE
                        IF @Resolution = 'ThemeXHDPI'
                            UPDATE  dbo.EstablishmentGroup
                            SET     ThemeXHDPI = NULL
                            WHERE   Id = @ActivityId;
                        ELSE
                            IF @Resolution = 'ThemeXXHDPI'
                                UPDATE  dbo.EstablishmentGroup
                                SET     ThemeXXHDPI = NULL
                                WHERE   Id = @ActivityId;
                            ELSE
                                IF @Resolution = 'Theme640x960'
                                    UPDATE  dbo.EstablishmentGroup
                                    SET     Theme640x960 = NULL
                                    WHERE   Id = @ActivityId;
                                ELSE
                                    IF @Resolution = 'Theme640x1136'
                                        UPDATE  dbo.EstablishmentGroup
                                        SET     Theme640x1136 = NULL
                                        WHERE   Id = @ActivityId;
                                    ELSE
                                        IF @Resolution = 'Theme768x1280'
                                            UPDATE  dbo.EstablishmentGroup
                                            SET     Theme768x1280 = NULL
                                            WHERE   Id = @ActivityId;
                                        ELSE
                                            IF @Resolution = 'Theme750x1334'
                                                UPDATE  dbo.EstablishmentGroup
                                                SET     Theme750x1334 = NULL
                                                WHERE   Id = @ActivityId;
                                            ELSE
                                                IF @Resolution = 'Theme1242x2208'
                                                    UPDATE  dbo.EstablishmentGroup
                                                    SET     Theme1242x2208 = NULL
                                                    WHERE   Id = @ActivityId;
            END;

    END;