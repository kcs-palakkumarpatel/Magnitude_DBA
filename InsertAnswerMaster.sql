
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		InsertAnswerMaster
-- =============================================
CREATE PROCEDURE [dbo].[InsertAnswerMaster]
    @EstablishmentId BIGINT,
    @QuestionnaireId BIGINT,
    @AppUserId BIGINT,
    @EI DECIMAL(18, 2),
    @IsPositive NVARCHAR(20),
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientAnswerChildId BIGINT,
    @Latitude NVARCHAR(50),
    @Longitude NVARCHAR(50),
    @OnceHistoryId BIGINT,
    @CreatedOn DATETIME,
    @ContactAppUserId BIGINT = 0
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    IF (
           @CreatedOn IS NULL
           OR @CreatedOn = ''
           OR @CreatedOn = '1970-01-01 00:00:00.000'
           OR CONVERT(TIME(0), @CreatedOn) = '00:00:00'
       )
    BEGIN
        SET @CreatedOn = GETUTCDATE();
    END;
    ELSE
    BEGIN
        SELECT @CreatedOn = @CreatedOn;
    END;

    --SELECT ContactMasterId,* FROM dbo.SeenClientAnswerMaster WHERE Id = 190668

    DECLARE @TimeOffSet INT,
            @IsResolved NVARCHAR(50) = 'Unresolved',
            @AnswerMasterId BIGINT,
            @EmailAddress NVARCHAR(100) = '',
            @ContactMasterID BIGINT = 0,
            @CustomerUserId BIGINT = 0;

    IF (@SeenClientAnswerMasterId > 0)
    BEGIN
        SELECT @ContactMasterID =
        (
            SELECT ContactMasterId
            FROM SeenClientAnswerMaster
            WHERE Id = @SeenClientAnswerMasterId
        );


        IF (@ContactMasterID > 0)
        BEGIN
            SET @EmailAddress =
            (
                SELECT ISNULL(Detail, '')
                FROM ContactDetails
                WHERE ContactMasterId = @ContactMasterID
                      AND QuestionTypeId = 10
            );
        END;


    END;
    --IF @IsPositive <> 'Negative'
    --    SET @IsResolved = 'Resolved';

    IF @Latitude = ''
       OR @Latitude IS NULL
        SET @Latitude = '0.00';

    IF @Longitude = ''
       OR @Longitude IS NULL
        SET @Longitude = '0.00';

    SELECT @TimeOffSet = TimeOffSet
    FROM dbo.Establishment
    WHERE Id = @EstablishmentId;

    IF (@AppUserId = -1)
    BEGIN
        SELECT @AppUserId = AppUserId
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMasterId;
    END;

    IF @SeenClientAnswerMasterId = 0
    BEGIN
        SET @SeenClientAnswerMasterId = NULL;
    END;

    INSERT INTO dbo.AnswerMaster
    (
        EstablishmentId,
        QuestionnaireId,
        AppUserId,
        IsOutStanding,
        ReadBy,
        TimeOffSet,
        IsResolved,
        IsPositive,
        EscalationSendDate,
        ImportTypeId,
        EI,
        SeenClientAnswerMasterId,
        SeenClientAnswerChildId,
        Latitude,
        Longitude,
        ContactAppUserId,
        CreatedBy,
        CreatedOn
    )
    VALUES
    (   @EstablishmentId,         -- EstablishmentId - bigint
        @QuestionnaireId,         -- QuestionnaireId - bigint
        @AppUserId,               -- AppUserId - bigint
        1,                        -- IsOutStanding - bit
        0,                        -- ReadBy - int
        ISNULL(@TimeOffSet, 120), -- TimeOffSet - int
        @IsResolved,              -- AnswerStatus - nvarchar(20)
        @IsPositive,              -- IsPositive - nvarchar(20)
        GETUTCDATE(),             -- EscalationSendDate - datetime
        1,                        -- ImportTypeId - bigint
        @EI,                      -- EI - decimal
        @SeenClientAnswerMasterId,
        @SeenClientAnswerChildId,
        @Latitude,
        @Longitude,
        ISNULL(@ContactAppUserId, 0),
        @AppUserId,               -- CreatedBy - bigint
        @CreatedOn
    );
    SELECT @AnswerMasterId = ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0);

    IF @OnceHistoryId > 0
    BEGIN
        UPDATE dbo.FeedbackOnceHistory
        SET IsFeedBackSubmitted = 1,
            AnswerMasterId = @AnswerMasterId
        WHERE Id = @OnceHistoryId;
    END;
    ELSE IF (
            (
                SELECT FeedbackOnce FROM dbo.Establishment WHERE Id = @EstablishmentId
            ) = 1
            )
    BEGIN
        SELECT @OnceHistoryId = Id
        FROM dbo.FeedbackOnceHistory
        WHERE EstablishmentId = @EstablishmentId
              AND SeenClientAnswerMasterId = @SeenClientAnswerMasterId;
        UPDATE dbo.FeedbackOnceHistory
        SET IsFeedBackSubmitted = 1,
            AnswerMasterId = @AnswerMasterId
        WHERE Id = @OnceHistoryId;
    END;
    SELECT ISNULL(@AnswerMasterId, 0) AS InsertedId;
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
         'dbo.InsertAnswerMaster',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @EstablishmentId+','+@QuestionnaireId+','+@AppUserId+','+@EI+','+@IsPositive+','+@SeenClientAnswerMasterId+','+@SeenClientAnswerChildId+','+@Latitude+','+@Longitude+','+@OnceHistoryId+','+@CreatedOn+','+@ContactAppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
