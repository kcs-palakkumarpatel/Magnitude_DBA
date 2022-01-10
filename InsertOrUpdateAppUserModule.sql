
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 09 Jun 2015>
-- Description:	<Description,,InsertOrUpdateAppUserModule>
-- Call SP    :	InsertOrUpdateAppUserModule
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateAppUserModule]
    @Id BIGINT ,
    @AppUserId BIGINT ,
    @AppModuleId BIGINT ,
    @AliasName NVARCHAR(50) ,
    @IsSelected BIT ,
    @AvtivityId BIGINT ,
    @UserId BIGINT ,
    @PageId BIGINT
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        IF ( @Id = 0 )
            BEGIN
                INSERT  INTO dbo.[AppUserModule]
                        ( [AppUserId] ,
                          [AppModuleId] ,
                          [AliasName] ,
                          [IsSelected] ,
                          [EstablishmentGroupId] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @AppUserId ,
                          @AppModuleId ,
                          @AliasName ,
                          @IsSelected ,
                          @AvtivityId ,
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
                          'Insert record in table AppUserModule' ,
                          'AppUserModule' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
            END;
		ELSE IF NOT EXISTS ((SELECT * FROM dbo.AppUserModule WHERE AppUserId = @AppUserId AND AppModuleId = @AppModuleId AND EstablishmentGroupId = @AvtivityId))
		BEGIN
			  INSERT  INTO dbo.[AppUserModule]
                        ( [AppUserId] ,
                          [AppModuleId] ,
                          [AliasName] ,
                          [IsSelected] ,
                          [EstablishmentGroupId] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @AppUserId ,
                          @AppModuleId ,
                          @AliasName ,
                          @IsSelected ,
                          @AvtivityId ,
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
                          'Insert record in table AppUserModule' ,
                          'AppUserModule' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
		END
        ELSE
            BEGIN
                UPDATE  dbo.[AppUserModule]
                SET     [AppUserId] = @AppUserId ,
                        [AppModuleId] = @AppModuleId ,
                        [AliasName] = @AliasName ,
                        [IsSelected] = @IsSelected ,
                        [EstablishmentGroupId] = @AvtivityId ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId ,
                        IsDeleted = 0 ,
                        DeletedBy = NULL ,
                        DeletedOn = NULL
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
                          'Update record in table AppUserModule' ,
                          'AppUserModule' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
            END;
        SELECT  ISNULL(@Id, 0) AS InsertedId;
		END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.InsertOrUpdateAppUserModule',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @Id+','+@AppUserId+','+@AppModuleId+','+@AliasName+','+@IsSelected+','+@AvtivityId+','+@UserId+','+@PageId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    END;
