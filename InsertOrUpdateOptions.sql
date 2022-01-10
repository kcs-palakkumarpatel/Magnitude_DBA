-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 30 May 2015>
-- Description:	<Description,,InsertOrUpdateOptions>
-- Call SP    :	InsertOrUpdateOptions
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateOptions]
    @Id BIGINT,
    @QuestionId BIGINT,
    @Position INT,
    @Name NVARCHAR(1000),
    @Value NVARCHAR(1000),
    @DefaultValue BIT,
    @IsNA BIT,
    @Weight DECIMAL(18, 2),
    @Point DECIMAL(18, 2),
    @UserId BIGINT,
    @PageId BIGINT,
    @OptionImagePath NVARCHAR(MAX) = NULL,
    @FromRef BIT = 0,
    @PreviousQuestionId BIGINT = 0,
    @IsHTTPHeader BIT = 0
AS
BEGIN
    IF (@Id = 0)
    BEGIN
        INSERT INTO dbo.[Options]
        (
            [QuestionId],
            [Position],
            [Name],
            [Value],
            [DefaultValue],
            [Weight],
            [Point],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            [IsNA],
            OptionImagePath,
            FromRef,
            ReferenceQuestionId,
            IsHTTPHeader
        )
        VALUES
        (   @QuestionId, @Position, RTRIM(@Name), RTRIM(@Value), @DefaultValue, @Weight, @Point, GETUTCDATE(), @UserId,
            0, @IsNA, CASE @OptionImagePath
                          WHEN 'undefined' THEN
                              NULL
                          ELSE
                              @OptionImagePath
                      END, @FromRef, @PreviousQuestionId, @IsHTTPHeader);
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
        (@UserId, @PageId, 'Insert record in table Options', 'Options', @Id, GETUTCDATE(), @UserId, 0);
    END;
    ELSE
    BEGIN
        UPDATE dbo.[Options]
        SET [Weight] = @Weight,
            [Point] = @Point,
            --[OptionImagePath] = @OptionImagePath,
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
        (@UserId, @PageId, 'Update record in table Options', 'Options', @Id, GETUTCDATE(), @UserId, 0);

        DECLARE @QuestionId_ BIGINT = 0;
        SELECT @QuestionId_ = QuestionId
        FROM dbo.Options
        WHERE Id = @Id;
        UPDATE dbo.Questionnaire
        SET UpdatedOn = GETUTCDATE()
        WHERE Id IN
              (
                  SELECT QuestionnaireId FROM dbo.Questions WHERE Id = @QuestionId_
              );
    END;
    SELECT ISNULL(@Id, 0) AS InsertedId;
END;
