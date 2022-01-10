
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,InsertOrUpdateIndustry>
-- Call SP    :	InsertOrUpdateIndustry
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateIndustry]
    @Id BIGINT ,
    @IndustryName NVARCHAR(100) ,
    @AboutIndustry NVARCHAR(MAX) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[Industry]
                        ( [IndustryName] ,
                          [AboutIndustry] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @IndustryName ,
                          @AboutIndustry ,
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
                          'Insert record in table Industry' ,
                          'Industry' ,
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
                UPDATE  dbo.[Industry]
                SET     [IndustryName] = @IndustryName ,
                        [AboutIndustry] = @AboutIndustry ,
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
                          'Update record in table Industry' ,
                          'Industry' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END