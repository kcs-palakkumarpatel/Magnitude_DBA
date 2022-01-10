
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 02 Jun 2015>
-- Description:	<Description,,InsertOrUpdateTheme>
-- Call SP    :	InsertOrUpdateTheme
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateTheme]
    @Id BIGINT ,
    @ThemeName NVARCHAR(200) ,
    @Description NVARCHAR(500) ,
    @ThemeMDPI NVARCHAR(500) ,
    @ThemeHDPI NVARCHAR(500) ,
    @ThemeXHDPI NVARCHAR(500) ,
    @ThemeXXHDPI NVARCHAR(500) ,
    @Theme640x960 NVARCHAR(500) ,
    @Theme640x1136 NVARCHAR(500) ,
    @Theme768x1280 NVARCHAR(500) ,
    @Theme750x1334 NVARCHAR(50) ,
    @Theme1242x2208 NVARCHAR(50) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS
    BEGIN
        IF ( @Id = 0 )
            BEGIN
                INSERT  INTO dbo.[Theme]
                        ( [ThemeName] ,
                          [Description] ,
                          [ThemeMDPI] ,
                          [ThemeHDPI] ,
                          [ThemeXHDPI] ,
                          [ThemeXXHDPI] ,
                          [Theme640x960] ,
                          [Theme640x1136] ,
                          [Theme768x1280] ,
                          Theme750x1334 ,
                          Theme1242x2208 ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @ThemeName ,
                          @Description ,
                          @ThemeMDPI ,
                          @ThemeHDPI ,
                          @ThemeXHDPI ,
                          @ThemeXXHDPI ,
                          @Theme640x960 ,
                          @Theme640x1136 ,
                          @Theme768x1280 ,
                          @Theme750x1334 ,
                          @Theme1242x2208 ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
                SELECT  @Id = SCOPE_IDENTITY();
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Insert record in table Theme' ,
                          'Theme' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );

				INSERT INTO dbo.[UserRolePermissions]
				(  [PageID]   ,
				  [ActualID]  ,
				  [UserID]	  ,
				  [CreatedOn] ,
				  [CreatedBy] ,
				  [UpdatedOn] ,
				  [UpdatedBy] ,
				  [DeletedOn] ,
				  [DeletedBy] ,
				  [IsDeleted] 
				)
				VALUES ( @PageId ,
						 @Id ,
						 @UserId ,
						 GETUTCDATE() ,
						 @UserId ,
						 NULL,
						 NULL,
						 NULL,
						 NULL,
						 0
				);
            END;
        ELSE
            BEGIN
                UPDATE  dbo.[Theme]
                SET     [ThemeName] = @ThemeName ,
                        [Description] = @Description ,
                        [ThemeMDPI] = @ThemeMDPI ,
                        [ThemeHDPI] = @ThemeHDPI ,
                        [ThemeXHDPI] = @ThemeXHDPI ,
                        [ThemeXXHDPI] = @ThemeXXHDPI ,
                        [Theme640x960] = @Theme640x960 ,
                        [Theme640x1136] = @Theme640x1136 ,
                        [Theme768x1280] = @Theme768x1280 ,
                        [Theme750x1334] = @Theme750x1334 ,
                        [Theme1242x2208] = @Theme1242x2208 ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id;
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted 
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Update record in table Theme' ,
                          'Theme' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
            END;
        SELECT  ISNULL(@Id, 0) AS InsertedId;
    END;