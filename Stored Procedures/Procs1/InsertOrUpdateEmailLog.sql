

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,InsertOrUpdateEmailLog>
-- Call SP    :	InsertOrUpdateEmailLog
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateEmailLog]
    @Id BIGINT ,
    @RelaventId BIGINT ,
    @ModuleId BIGINT ,
    @MailContent NVARCHAR(MAX) ,
    @MailTo NVARCHAR(MAX) ,
    @CC NVARCHAR(MAX) ,
    @BCC NVARCHAR(MAX) ,
    @SentOn DATETIME ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[EmailLog]
                        ( [RelaventId] ,
                          [ModuleId] ,
                          [MailContent] ,
                          [MailTo] ,
                          [CC] ,
                          [BCC] ,
                          [SentOn] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted] 
                        )
                VALUES  ( @RelaventId ,
                          @ModuleId ,
                          @MailContent ,
                          @MailTo ,
                          @CC ,
                          @BCC ,
                          @SentOn ,
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
                          'Insert record in table EmailLog' ,
                          'EmailLog' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0 
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[EmailLog]
                SET     [RelaventId] = @RelaventId ,
                        [ModuleId] = @ModuleId ,
                        [MailContent] = @MailContent ,
                        [MailTo] = @MailTo ,
                        [CC] = @CC ,
                        [BCC] = @BCC ,
                        [SentOn] = @SentOn ,
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
                          'Update record in table EmailLog' ,
                          'EmailLog' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0 
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END