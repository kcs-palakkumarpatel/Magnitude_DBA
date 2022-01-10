/*
 =============================================
 Author:	  Disha Patel
 Create date: 24-OCT-2016
 Description: Update module aliases for particular activity by ModuleId. 
			  Also check if users exists with the activity, if found - update alias names for all users in AppUserModule table
 Call SP    : InsertOrUpdateAppUserModule
 =============================================
*/
CREATE PROCEDURE [dbo].[UpdateEstablishmentGroupModuleAlias]
    @Id BIGINT ,
    @EstablishmentGroupId BIGINT ,
    @AppModuleId BIGINT ,
    @AliasName NVARCHAR(50) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS
    BEGIN
        UPDATE  dbo.EstablishmentGroupModuleAlias
        SET     AliasName = @AliasName ,
                UpdatedOn = GETUTCDATE() ,
                UpdatedBy = @UserId
        WHERE   EstablishmentGroupId = @EstablishmentGroupId
                AND AppModuleId = @AppModuleId

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
                  'Update record in table EstablishmentGroupModuleAlias. ActivityId= '
                  + CAST(@EstablishmentGroupId AS VARCHAR(20))
                  + ' and ModuleId=' + CAST(@AppModuleId AS VARCHAR(10)) ,
                  'EstablishmentGroupModuleAlias' ,
                  @Id ,
                  GETUTCDATE() ,
                  @UserId ,
                  0
                );

        IF EXISTS ( SELECT  1
                    FROM    dbo.AppUserModule
                    WHERE   EstablishmentGroupId = @EstablishmentGroupId
                            AND AppModuleId = @AppModuleId )
            BEGIN
                UPDATE  dbo.[AppUserModule]
                SET     [AliasName] = @AliasName ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   EstablishmentGroupId = @EstablishmentGroupId
                        AND AppModuleId = @AppModuleId
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
                          'Update record in table AppUserModule. ActivityId= '
                          + CAST(@EstablishmentGroupId AS VARCHAR(20))
                          + ' and ModuleId='
                          + CAST(@AppModuleId AS VARCHAR(10)) ,
                          'AppUserModule' ,
                          0 ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        );
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId;
    END