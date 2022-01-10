-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,InsertOrUpdateHowItWorks>
-- Call SP    :	InsertOrUpdateHowItWorks
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateHowItWorks]
    @Id BIGINT ,
    @HowItWorksName NVARCHAR(50) ,
    @HowItWorks NVARCHAR(MAX) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[HowItWorks]
                        ( [HowItWorksName] ,
                          [HowItWorks] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @HowItWorksName ,
                          @HowItWorks ,
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
                          'Insert record in table HowItWorks' ,
                          'HowItWorks' ,
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
                UPDATE  dbo.[HowItWorks]
                SET     [HowItWorksName] = @HowItWorksName ,
                        [HowItWorks] = @HowItWorks ,
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
                          'Update record in table HowItWorks' ,
                          'HowItWorks' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END