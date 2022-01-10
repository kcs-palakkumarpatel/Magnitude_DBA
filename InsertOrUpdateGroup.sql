-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,InsertOrUpdateGroup>
-- Call SP    :	InsertOrUpdateGroup
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateGroup]
    @Id BIGINT ,
    @IndustryId BIGINT ,
    @GroupName NVARCHAR(100) ,
    @AboutGroup NVARCHAR(MAX) ,
    @ThemeId BIGINT ,
	@ContactId BIGINT,
    @UserId BIGINT ,
    @PageId BIGINT,
	@GroupKeyword NVARCHAR(50),
	@SecurityKey NVARCHAR(200),
	@PWExpiredDays SMALLINT
AS 
    BEGIN
	SET NOCOUNT ON;
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[Group]
                        ( [IndustryId] ,
                          [GroupName] ,
                          [AboutGroup] ,
                          [ThemeId] ,
						  [ContactId],
						  [GroupKeyword],
						  [PWExpiredDays],
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @IndustryId ,
                          @GroupName ,
                          @AboutGroup ,
                          @ThemeId ,
						  @ContactId,
						  @GroupKeyword,
						  @PWExpiredDays,
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
                          'Insert record in table Group' ,
                          'Group' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )

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
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[Group]
                SET     [IndustryId] = @IndustryId ,
                        [GroupName] = @GroupName ,
                        [AboutGroup] = @AboutGroup ,
                        [ThemeId] = @ThemeId ,
						[ContactId] = @ContactId ,
						[GroupKeyword] = @GroupKeyword,
						[SecurityKey] = @SecurityKey,
						[PWExpiredDays] = @PWExpiredDays,
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
                          'Update record in table Group' ,
                          'Group' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
SET NOCOUNT OFF;
    END
