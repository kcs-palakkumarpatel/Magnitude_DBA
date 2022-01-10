


-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,InsertOrUpdateErrorLog>
-- Call SP    :	InsertOrUpdateErrorLog
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateErrorLog]
    @Id BIGINT ,
    @PageId BIGINT ,
    @MethodName NVARCHAR(200) ,
    @ErrorType NVARCHAR(MAX) ,
    @ErrorMessage NVARCHAR(MAX) ,
    @ErrorDetails NVARCHAR(MAX) ,
    @ErrorDate DATETIME ,
    @UserId BIGINT ,
    @Solution NVARCHAR(MAX) ,
    @LoginUserId BIGINT ,
    @PPageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[ErrorLog]
                        ( [PageId] ,
                          [MethodName] ,
                          [ErrorType] ,
                          [ErrorMessage] ,
                          [ErrorDetails] ,
                          [ErrorDate] ,
                          [UserId] ,
                          [Solution] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted] 
                        )
                VALUES  ( @PageId ,
                          @MethodName ,
                          @ErrorType ,
                          @ErrorMessage ,
                          @ErrorDetails ,
                          @ErrorDate ,
                          @UserId ,
                          @Solution ,
                          GETUTCDATE() ,
                          @LoginUserId ,
                          0 
                        )
                SELECT  @Id = SCOPE_IDENTITY()
                --INSERT  INTO dbo.ActivityLog
                --        ( UserId ,
                --          PageId ,
                --          AuditComments ,
                --          TableName ,
                --          RecordId ,
                --          CreatedOn ,
                --          CreatedBy ,
                --          IsDeleted 
                --        )
                --VALUES  ( @LoginUserId ,
                --          @PPageId ,
                --          'Insert record in table ErrorLog' ,
                --          'ErrorLog' ,
                --          @Id ,
                --          GETUTCDATE() ,
                --          @LoginUserId ,
                --          0 
                --        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[ErrorLog]
                SET     [PageId] = @PageId ,
                        [MethodName] = @MethodName ,
                        [ErrorType] = @ErrorType ,
                        [ErrorMessage] = @ErrorMessage ,
                        [ErrorDetails] = @ErrorDetails ,
                        [ErrorDate] = @ErrorDate ,
                        [UserId] = @UserId ,
                        [Solution] = @Solution ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @LoginUserId
                WHERE   [Id] = @Id
                --INSERT  INTO dbo.ActivityLog
                --        ( UserId ,
                --          PageId ,
                --          AuditComments ,
                --          TableName ,
                --          RecordId ,
                --          CreatedOn ,
                --          CreatedBy ,
                --          IsDeleted 
                --        )
                --VALUES  ( @LoginUserId ,
                --          @PPageId ,
                --          'Update record in table ErrorLog' ,
                --          'ErrorLog' ,
                --          @Id ,
                --          GETUTCDATE() ,
                --          @LoginUserId ,
                --          0 
                --        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END