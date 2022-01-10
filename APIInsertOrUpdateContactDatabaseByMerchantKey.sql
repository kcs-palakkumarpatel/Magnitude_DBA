
-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Contact Database from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIInsertOrUpdateContactDatabaseByMerchantKey 293
-- =============================================
CREATE PROCEDURE [dbo].[APIInsertOrUpdateContactDatabaseByMerchantKey]
    (
      @MerchantKey BIGINT = 0 ,
      @Id BIGINT = 0 ,
      @ContactId BIGINT ,
      @AppUserId BIGINT
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        IF @Id = 0
            BEGIN
                INSERT  INTO dbo.ContactMaster
                        ( ContactId ,
                          GroupId ,
                          CreatedOn ,
                          CreatedBy
	                    )
                VALUES  ( @ContactId , -- ContactId - bigint
                          @MerchantKey ,
                          GETUTCDATE() , -- CreatedOn - datetime
                          @AppUserId 
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
                VALUES  ( @AppUserId ,
                          1 ,
                          'Insert record in table ContactMaster' ,
                          'ContactMaster' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        );
            END;
        ELSE
            BEGIN
                UPDATE  dbo.ContactMaster
                SET     UpdatedOn = GETUTCDATE() ,
                        UpdatedBy = @AppUserId
                WHERE   Id = @Id;
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
                VALUES  ( @AppUserId ,
                          1 ,
                          'Update record in table ContactMaster' ,
                          'ContactMaster' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        );
            END;
        SELECT  ISNULL(@Id, 0) AS InsertedId;

       
    END;