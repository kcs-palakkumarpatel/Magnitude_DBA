

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,InsertOrUpdateRole>
-- Call SP    :	InsertOrUpdateRole
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateRole]
    @Id BIGINT ,
    @RoleName NVARCHAR(50) ,
    @Description NVARCHAR(500) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[Role]
                        ( [RoleName] ,
                          [Description] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted] 
                        )
                VALUES  ( @RoleName ,
                          @Description ,
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
                          @PageId ,
                          'Insert record in table Role' ,
                          'Role' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0 
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[Role]
                SET     [RoleName] = @RoleName ,
                        [Description] = @Description ,
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
                          @PageId ,
                          'Update record in table Role' ,
                          'Role' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0 
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END