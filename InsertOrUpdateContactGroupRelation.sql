-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 20 Jun 2015>
-- Description:	<Description,,InsertOrUpdateContactGroupRelation>
-- Call SP    :	InsertOrUpdateContactGroupRelation
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactGroupRelation]
    @ContactMasterId BIGINT ,
    @ContactGroupId BIGINT ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        DECLARE @Id BIGINT = 0
        SELECT  @Id = Id
        FROM    dbo.ContactGroupRelation
        WHERE   ContactGroupId = @ContactGroupId
                AND ContactMasterId = @ContactMasterId
                AND IsDeleted = 0
        
		IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[ContactGroupRelation]
                        ( [ContactMasterId] ,
                          [ContactGroupId] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @ContactMasterId ,
                          @ContactGroupId ,
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
                          'Insert record in table ContactGroupRelation' ,
                          'ContactGroupRelation' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[ContactGroupRelation]
                SET     --[ContactMasterId] = @ContactMasterId ,
                        --[ContactGroupId] = @ContactGroupId ,
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
                          'Update record in table ContactGroupRelation' ,
                          'ContactGroupRelation' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END