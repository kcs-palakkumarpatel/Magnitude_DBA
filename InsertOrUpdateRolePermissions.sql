

-- =============================================
-- Author:		<Author,,Admin>
-- Create date: <Create Date,, 03 Nov 2014>
-- Description:	<Description,,InsertOrUpdateRolePermissions>
-- Call SP    :	InsertOrUpdateRolePermissions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateRolePermissions]
    @Id BIGINT ,
    @RoleId BIGINT ,
    @PageId BIGINT ,
    @View_Right BIT ,
    @Add_Right BIT ,
    @Edit_Right BIT ,
    @Delete_Right BIT ,
    @Export_Right BIT ,
    @UserId BIGINT ,
    @PPageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[RolePermissions]
                        ( [RoleId] ,
                          [PageId] ,
                          [View_Right] ,
                          [Add_Right] ,
                          [Edit_Right] ,
                          [Delete_Right] ,
                          [Export_Right] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @RoleId ,
                          @PageId ,
                          @View_Right ,
                          @Add_Right ,
                          @Edit_Right ,
                          @Delete_Right ,
                          @Export_Right ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
                SELECT  @Id = SCOPE_IDENTITY()
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
                          @PPageId ,
                          'Insert record in table RolePermissions' ,
                          'RolePermissions' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[RolePermissions]
                SET     [RoleId] = @RoleId ,
                        [PageId] = @PageId ,
                        [View_Right] = @View_Right ,
                        [Add_Right] = @Add_Right ,
                        [Edit_Right] = @Edit_Right ,
                        [Delete_Right] = @Delete_Right ,
                        [Export_Right] = @Export_Right ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id
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
                          @PPageId ,
                          'Update record in table RolePermissions' ,
                          'RolePermissions' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END