-- =============================================
-- Author:		<Author,,Gd>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,InsertOrUpdateCloseLoopTemplate>
-- Call SP    :	InsertOrUpdateCloseLoopTemplate
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateCloseLoopTemplate]
    @Id BIGINT ,
    @EstablishmentGroupId BIGINT ,
    @TemplateText NVARCHAR(500) ,
    @UserId BIGINT ,
    @PageId BIGINT
AS 
    BEGIN
        IF ( @Id = 0 ) 
            BEGIN
                INSERT  INTO dbo.[CloseLoopTemplate]
                        ( [EstablishmentGroupId] ,
                          [TemplateText] ,
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]
                        )
                VALUES  ( @EstablishmentGroupId ,
                          @TemplateText ,
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
                          'Insert record in table CloseLoopTemplate' ,
                          'CloseLoopTemplate' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        ELSE 
            BEGIN
                UPDATE  dbo.[CloseLoopTemplate]
                SET     [EstablishmentGroupId] = @EstablishmentGroupId ,
                        [TemplateText] = @TemplateText ,
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
                          'Update record in table CloseLoopTemplate' ,
                          'CloseLoopTemplate' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0
                        )
            END
        SELECT  ISNULL(@Id, 0) AS InsertedId
    END