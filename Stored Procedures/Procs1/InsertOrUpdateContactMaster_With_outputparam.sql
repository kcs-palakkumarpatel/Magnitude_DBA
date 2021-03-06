-- =============================================
-- Author:		<Author,bhavik,GD>
-- Create date: <Create Date,,02 04 21>
-- Description:	<Description,,>
-- Call SP:		[InsertOrUpdateContactMaster_With_outputparam]
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactMaster_With_outputparam]
    @Id BIGINT =0,
    @ContactId BIGINT ,
    @GroupId BIGINT ,
    @AppUserId BIGINT , 
	@PageId BIGINT = 0,
	@CurrentContactId BIGINT OUTPUT
AS 
    BEGIN
	--  DECLARE @Id BIGINT=0 , @PageId BIGINT=0;

        IF @Id = 0 
            BEGIN
                INSERT  INTO dbo.ContactMaster
                        ( ContactId ,
                          GroupId ,
                          CreatedOn ,
                          CreatedBy
	                    )						
                VALUES  ( @ContactId , -- ContactId - bigint
                          @GroupId ,
                          GETUTCDATE() , -- CreatedOn - datetime
                          @AppUserId 
	                    )
						
				--select @Id =  SCOPE_IDENTITY()
                set @CurrentContactId =  SCOPE_IDENTITY()
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
                          @PageId ,
                          'Insert record in table ContactMaster' ,
                          'ContactMaster' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.ContactMaster
                SET     UpdatedOn = GETUTCDATE() ,
                        UpdatedBy = @AppUserId
                WHERE   Id = @Id
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
                          @PageId ,
                          'Update record in table ContactMaster' ,
                          'ContactMaster' ,
                          @Id ,
                          GETUTCDATE() ,
                          @AppUserId ,
                          0
                        )

                        INSERT  INTO appusercontactRole
                                ( appuserid ,
                                  contactroleid
                                )
                                SELECT DISTINCT @AppUserId ,
                                        contactroleid
                                FROM    AppUserContactRole
                                WHERE   Appuserid = ( SELECT  CreatedBy
                                                      FROM    ContactMaster
                                                      WHERE   Id = @Id
                                                    ) AND ContactRoleId NOT IN (SELECT contactroleid FROM AppUserContactRole WHERE   Appuserid = @AppUserId AND IsDeleted = 0 GROUP BY contactroleid )
													AND IsDeleted = 0

				set @CurrentContactId = @Id
												
            END
			
       -- SELECT  ISNULL(@Id, 0) AS InsertedId
		
    END