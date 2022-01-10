
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,InsertOrUpdateSupplier>
-- Call SP    :	InsertOrUpdateSupplier
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateSupplier]
    @Id BIGINT ,
    @SupplierTypeId BIGINT ,
    @SupplierName NVARCHAR(50) ,
    @SupplierAddress NVARCHAR(200) ,
    @SupplierEmail NVARCHAR(50) ,
    @SupplierMobile NVARCHAR(15) ,
    @AboutSupplier NVARCHAR(MAX) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[Supplier]
                        ( [SupplierTypeId] ,
                          [SupplierName] ,
                          [SupplierAddress] ,
                          [SupplierEmail] ,
                          [SupplierMobile] ,
                          [AboutSupplier] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @SupplierTypeId ,
                          @SupplierName ,
                          @SupplierAddress ,
                          @SupplierEmail ,
                          @SupplierMobile ,
                          @AboutSupplier ,
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
                          'Insert record in table Supplier' ,
                          'Supplier' ,
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
                UPDATE  dbo.[Supplier]
                SET     [SupplierTypeId] = @SupplierTypeId ,
                        [SupplierName] = @SupplierName ,
                        [SupplierAddress] = @SupplierAddress ,
                        [SupplierEmail] = @SupplierEmail ,
                        [SupplierMobile] = @SupplierMobile ,
                        [AboutSupplier] = @AboutSupplier ,
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
                          'Update record in table Supplier' ,
                          'Supplier' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END