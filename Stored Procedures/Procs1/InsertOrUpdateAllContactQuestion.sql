-- =============================================
-- Author:		<Mittal,,GD>
-- Create date: <Create Date,, 15 Mar 2021>
-- Description:	<Description,,InsertOrUpdateAllContactQuestion>
-- Call SP    :	InsertOrUpdateAllContactQuestion
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateAllContactQuestion
    @ContactQuestionTableType ContactQuestionTableType READONLY,
    @AppUserId BIGINT
AS
BEGIN
    DECLARE @TempTable TABLE
    (
        Id INT IDENTITY(1, 1),
        QuestionId BIGINT,
        Answer NVARCHAR(MAX),
        ContactMasterId BIGINT
    );
    INSERT INTO @TempTable
    (
        QuestionId,
        Answer,
        ContactMasterId
    )
    SELECT QuestionId,
           Answer,
           ContactMasterId
    FROM @ContactQuestionTableType;

    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @TempTable
    );

    WHILE (@Counter <= @TotalCount)
    BEGIN
        DECLARE @QuestionId BIGINT,
                @QuestionTypeId BIGINT,
                @Answer NVARCHAR(500),
                @ContactMasterId BIGINT = 0;
        SELECT @QuestionId = QuestionId,
               @Answer = Answer,
               @ContactMasterId = ContactMasterId
        FROM @TempTable
        WHERE Id = @Counter;

        SELECT @QuestionTypeId = QuestionTypeId
        FROM dbo.ContactQuestions
        WHERE Id = @QuestionId;

        DECLARE @Id BIGINT = 0;
        DECLARE @OptionId NVARCHAR(MAX);
        IF (
               @QuestionTypeId = 5
               OR @QuestionTypeId = 6
               OR @QuestionTypeId = 18
               OR @QuestionTypeId = 21
           )
           AND @Answer <> ''
        BEGIN
            SET @OptionId = NULL;
            SELECT @OptionId = COALESCE(@OptionId + ',', '') + CONVERT(NVARCHAR(50), Id)
            FROM dbo.ContactOptions
            WHERE Name IN (
                              SELECT DISTINCT Data FROM dbo.Split(@Answer, ',')
                          )
                  AND ContactQuestionId = @QuestionId
            ORDER BY Position;

        END;

        SELECT @Id = Id
        FROM dbo.ContactDetails
        WHERE ContactMasterId = @ContactMasterId
              AND ContactQuestionId = @QuestionId
              AND IsDeleted = 0;

        IF @Id = 0
        BEGIN
            INSERT INTO dbo.ContactDetails
            (
                ContactMasterId,
                ContactQuestionId,
                ContactOptionId,
                QuestionTypeId,
                Detail,
                CreatedBy,
                CreatedOn
            )
            VALUES
            (   @ContactMasterId,      -- ContactMasterId - bigint
                @QuestionId,           -- ContactQuestionId - bigint
                @OptionId,             -- ContactOptionId - nvarchar(max)
                @QuestionTypeId,       -- QuestionTypeId - int
                RTRIM(LTRIM(@Answer)), -- Detail - nchar(10)
                @AppUserId,            -- CreatedBy - bigint
                GETUTCDATE()
            );
        END;
        ELSE
        BEGIN
            UPDATE dbo.ContactDetails
            SET ContactOptionId = @OptionId,
                Detail = RTRIM(LTRIM(@Answer)),
                UpdatedBy = @AppUserId,
                UpdatedOn = GETUTCDATE()
            WHERE Id = @Id;
            SET @OptionId = NULL;
        END;

        SET @Counter = @Counter + 1;
        CONTINUE;
    END;
END;

