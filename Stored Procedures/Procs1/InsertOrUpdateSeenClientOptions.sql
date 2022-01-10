-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,InsertOrUpdateSeenClientOptions>
-- Call SP    :	InsertOrUpdateSeenClientOptions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateSeenClientOptions]
    @Id BIGINT,
    @QuestionId BIGINT,
    @Position INT,
    @Name NVARCHAR(255),
    @Value NVARCHAR(MAX),
    @DefaultValue BIT,
    @NAValue BIT,
    @Weight DECIMAL(18, 2),
    @Point DECIMAL(18, 2),
    @QAEnd BIT,
    @UserId BIGINT,
    @PageId BIGINT,
    @FromRef BIT = 0,
    @PreviousQuestionId BIGINT = 0,
    @IsHTTPHeader BIT = 0
AS
BEGIN
    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[SeenClientOptions]
        (
            [QuestionId],
            [Position],
            [Name],
            [Value],
            [DefaultValue],
            [Weight],
            [Point],
            [QAEnd],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [IsNA],
            FromRef,
            ReferenceQuestionId,
            IsHTTPHeader
        )
        VALUES
        (@QuestionId, @Position, @Name, @Value, @DefaultValue, @Weight, @Point, @QAEnd, GETUTCDATE(), @UserId, 0,
         @NAValue, @FromRef, @PreviousQuestionId, @IsHTTPHeader);
        SELECT @Id = SCOPE_IDENTITY();
        INSERT INTO dbo.[SeenClientOptionsTemp]
        (
            [QuestionId],
            [Position],
            [Name],
            [Value],
            [DefaultValue],
            [Weight],
            [Point],
            [QAEnd],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [IsNA],
            FromRef,
            ReferenceQuestionId,
            IsHTTPHeader
        )
        VALUES
        (@QuestionId, @Position, @Name, @Value, @DefaultValue, @Weight, @Point, @QAEnd, GETUTCDATE(), @UserId, 0,
         @NAValue, @FromRef, @PreviousQuestionId, @IsHTTPHeader);
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
        (@UserId, @PageId, 'Insert record in table SeenClientOptions', 'SeenClientOptions', @Id, GETUTCDATE(), @UserId,
         0  );
    END;
    ELSE
    BEGIN
        UPDATE dbo.[SeenClientOptions]
        SET [QuestionId] = @QuestionId,
            [Weight] = @Weight,
            [Point] = @Point,
            [QAEnd] = @QAEnd,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId
        WHERE [Id] = @Id;
        UPDATE dbo.[SeenClientOptionsTemp]
        SET [QuestionId] = @QuestionId,
            [Weight] = @Weight,
            [Point] = @Point,
            [QAEnd] = @QAEnd,
            [UpdatedOn] = GETUTCDATE(),
            [UpdatedBy] = @UserId
        WHERE [Id] = @Id;
        UPDATE dbo.SeenClient
        SET UpdatedOn = GETUTCDATE()
        WHERE Id IN
              (
                  SELECT SeenClientId FROM dbo.SeenClientQuestions WHERE Id = @QuestionId
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
        (@UserId, @PageId, 'Update record in table SeenClientOptions', 'SeenClientOptions', @Id, GETUTCDATE(), @UserId,
         0  );
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;
