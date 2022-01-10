-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,InsertOrUpdateContact>
-- Call SP    :	InsertOrUpdateContact
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContact]
    @Id BIGINT ,
    @ContactTitle NVARCHAR(50) ,
    @Description NVARCHAR(250) ,
    @DeletedContactQuestion NVARCHAR(50) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS
    BEGIN
        IF ( @Id = 0 )
            BEGIN
                INSERT  INTO dbo.[Contact]
                        ( [ContactTitle] ,
                          [Description] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @ContactTitle ,
                          @Description ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
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
                VALUES  ( @UserId ,
                          @PageId ,
                          'Insert record in table Contact' ,
                          'Contact' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );

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
            END;
        ELSE
            BEGIN
                ----IF @DeletedContactQuestion = ''
                ----    OR @DeletedContactQuestion IS NULL
                ----    BEGIN
                ----        UPDATE  dbo.ContactMaster
                ----        SET     IsDeleted = 1 ,
                ----                DeletedOn = GETUTCDATE() ,
                ----                DeletedBy = @UserId
                ----        WHERE   ContactId = @Id
                ----                AND IsDeleted = 0;

                ----        UPDATE  Cd
                ----        SET     IsDeleted = 1 ,
                ----                DeletedOn = GETUTCDATE() ,
                ----                DeletedBy = @UserId
                ----        FROM    dbo.ContactDetails AS Cd
                ----                INNER JOIN dbo.ContactMaster AS Cm ON Cm.Id = Cd.ContactMasterId
                ----        WHERE   ContactId = @Id
                ----                AND Cd.IsDeleted = 0;

                ----        UPDATE  Cg
                ----        SET     IsDeleted = 1 ,
                ----                DeletedOn = GETUTCDATE() ,
                ----                DeletedBy = @UserId
                ----        FROM    dbo.ContactGroup AS Cg
                ----                INNER JOIN dbo.[Group] AS G ON G.Id = Cg.GroupId
                ----        WHERE   G.ContactId = @Id
                ----                AND Cg.IsDeleted = 0;

                ----        UPDATE  CGD
                ----        SET     IsDeleted = 1 ,
                ----                DeletedOn = GETUTCDATE() ,
                ----                DeletedBy = @UserId
                ----        FROM    dbo.ContactGroup AS Cg
                ----                INNER JOIN dbo.[Group] AS G ON G.Id = Cg.GroupId
                ----                INNER JOIN dbo.ContactGroupDetails AS CGD ON CGD.ContactGroupId = Cg.Id
                ----        WHERE   G.ContactId = @Id
                ----                AND CGD.IsDeleted = 0;
                ----    END;

                UPDATE  dbo.[Contact]
                SET     [ContactTitle] = @ContactTitle ,
                        [Description] = @Description ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id;


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
                          'Update record in table Contact' ,
                          'Contact' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
            END;
        SELECT  ISNULL(@Id, 0) AS InsertedId;
    END;