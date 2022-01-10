-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,InsertOrUpdateSeenClient>
-- Call SP    :	InsertOrUpdateSeenClient
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateSeenClient
    @Id BIGINT,
    @SeenClientTitle NVARCHAR(500),
    @Description NVARCHAR(MAX),
    @DeletedContactQuestion NVARCHAR(50),
    @UserId BIGINT,
    @PageId BIGINT,
    @CompareType BIGINT,
    @FixedBanchmark DECIMAL(18, 2),
    @EscalationValue BIGINT,
	@IsForTender BIT = 0
AS
BEGIN

    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[SeenClient]
        (
            [SeenClientTitle],
            [Description],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [CompareType],
            FixedBenchMark,
            EscalationValue,
			IsForTender
        )
        VALUES
        (@SeenClientTitle, @Description, GETUTCDATE(), @UserId, 0, @CompareType, @FixedBanchmark, @EscalationValue,@IsForTender);
        SELECT @Id = SCOPE_IDENTITY();

        
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
        (@UserId, @PageId, 'Insert record in table SeenClient', 'SeenClient', @Id, GETUTCDATE(), @UserId, 0);


        INSERT INTO dbo.[UserRolePermissions]
        (
            [PageID],
            [ActualID],
            [UserID],
            [CreatedOn],
            [CreatedBy],
            [UpdatedOn],
            [UpdatedBy],
            [DeletedOn],
            [DeletedBy],
            [IsDeleted]
        )
        VALUES
        (@PageId, @Id, @UserId, GETUTCDATE(), @UserId, NULL, NULL, NULL, NULL, 0);
    END;
    ELSE
    BEGIN
        UPDATE dbo.[SeenClient]
        SET [SeenClientTitle] = @SeenClientTitle,
            [Description] = @Description,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId,
            [CompareType] = @CompareType,
            [FixedBenchMark] = @FixedBanchmark,
            EscalationValue = @EscalationValue,
			IsForTender = @IsForTender
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
        (@UserId, @PageId, 'Update record in table SeenClient', 'SeenClient', @Id, GETUTCDATE(), @UserId, 0);
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;
