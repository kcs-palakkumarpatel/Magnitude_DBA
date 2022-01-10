-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,InsertOrUpdateContactOptions>
-- Call SP    :	InsertOrUpdateContactOptions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateContactOptions]
    @Id BIGINT,
    @ContactQuestionId BIGINT,
    @Position INT,
    @Name NVARCHAR(50),
    @Value NVARCHAR(50),
    @DefaultValue BIT,
    @UserId BIGINT,
    @PageId BIGINT
AS
BEGIN
    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[ContactOptions]
        (
            [ContactQuestionId],
            [Position],
            [Name],
            [Value],
            [DefaultValue],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted]
        )
        VALUES
        (@ContactQuestionId, @Position, @Name, @Value, @DefaultValue, GETUTCDATE(), @UserId, 0);
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
        (@UserId, @PageId, 'Insert record in table ContactOptions', 'ContactOptions', @Id, GETUTCDATE(), @UserId, 0);
    END;
    ELSE
    BEGIN
        UPDATE dbo.[ContactOptions]
        SET [ContactQuestionId] = @ContactQuestionId,
            [Position] = @Position,
            [Name] = @Name,
            [Value] = @Value,
            [DefaultValue] = @DefaultValue,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId
        WHERE [Id] = @Id;

        UPDATE dbo.Contact
        SET UpdatedOn = GETUTCDATE()
        WHERE Id IN
              (
                  SELECT ContactId FROM dbo.ContactQuestions WHERE Id = @ContactQuestionId
              );

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
        (@UserId, @PageId, 'Update record in table ContactOptions', 'ContactOptions', @Id, GETUTCDATE(), @UserId, 0);
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;
