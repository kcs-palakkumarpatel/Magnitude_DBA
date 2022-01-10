-- =============================================
-- Author:		<Author,Mitesh>
-- Create date: <Create Date,, 06 Sept 2021>
-- Description:	<Description,,InsertOrUpdateGroup>
-- Call SP    :	SetPwExpireNowByGroupId
-- =============================================
CREATE PROCEDURE [dbo].[SetPwExpireNowByGroupId]
    @Id BIGINT,
    @UserId BIGINT,
    @PageId BIGINT
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Response BIT = 0;
    IF (@Id > 0)
    BEGIN
        UPDATE dbo.[Group]
        SET [PWExpireNowOn] = GETUTCDATE(),
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId
        WHERE [Id] = @Id;

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, @PageId, 'Update record in table Group for [PWExpireNowOn]', 'Group', @Id, GETUTCDATE(), @UserId, 0);
        SET @Response = 1;
    END;
    RETURN @Response;
SET NOCOUNT OFF;
END;
