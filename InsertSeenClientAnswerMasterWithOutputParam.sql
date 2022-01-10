-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 22 Jun 2015>
-- Description:	<Description,,InsertOrUpdateSeenClientAnswerMaster>
-- Call SP    :	InsertSeenClientAnswerMaster
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerMasterWithOutputParam]
    @CopyReferenceId BIGINT = NULL,
    @DraftEntry BIT = 0,
    @EstablishmentId BIGINT,
    @SeenClientId BIGINT,
    @AppUserId BIGINT,
    @Latitude NVARCHAR(50) = NULL,
    @Longitude NVARCHAR(50) = NULL,
    @ContactMasterId BIGINT = NULL,
    @IsSubmittedForGroup BIT,
    @ContactGroupId BIGINT = NULL,
    @EI DECIMAL(18, 2),
    @IsPositive NVARCHAR(50),
    @MobileDate DATETIME = NULL,
    @CreatedOn DATETIME = NULL,
    @Platform NVARCHAR(50),
    @DraftSave INT = NULL,
    @CheckDuplicateValue NVARCHAR(200)
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.SeenClientAnswers
        WHERE QuestionId = 35573
              AND Detail = @CheckDuplicateValue
              AND IsDeleted = 0
    )
    BEGIN

        DECLARE @TimeOffSet INT,
                @Id BIGINT,
                @IsDelete BIT = 0,
                @IsResolved NVARCHAR(50) = 'Unresolved';

        --IF @IsPositive <> 'Negative'
        --    SET @IsResolved = 'Resolved';
        IF (@DraftSave IS NULL)
        BEGIN
            SET @DraftSave = 0;
        END;

        IF (@Platform = 'Web' OR @Platform = 'Beekman Olery API')
        BEGIN
            SET @CreatedOn = GETUTCDATE();
        END;

        IF @CopyReferenceId = 0
            SET @CopyReferenceId = NULL;

        IF @DraftEntry = 1
            SET @IsDelete = 1;

        IF @Latitude = ''
           OR @Latitude IS NULL
            SET @Latitude = '0.00';

        IF @Longitude = ''
           OR @Longitude IS NULL
            SET @Longitude = '0.00';


        IF @AppUserId = ''
           OR @AppUserId IS NULL
            SET @AppUserId = 0;

        IF @ContactGroupId > 0
           OR @ContactGroupId IS NOT NULL
            SET @IsSubmittedForGroup = 1;


        SELECT @TimeOffSet = TimeOffSet
        FROM dbo.Establishment
        WHERE Id = @EstablishmentId;
        SELECT @TimeOffSet = TimeOffSet
        FROM dbo.Establishment
        WHERE Id = @EstablishmentId;

        IF (@CreatedOn IS NULL OR @CreatedOn = '')
        BEGIN
            SET @CreatedOn = GETUTCDATE();
        END;
        ELSE
        BEGIN
            SELECT @CreatedOn = DATEADD(MINUTE, -@TimeOffSet, @CreatedOn);
        END;

        IF (@Platform = 'Web' OR @Platform = 'Beekman Olery API')
        BEGIN
            SET @CreatedOn = GETUTCDATE();
        END;

        INSERT INTO dbo.[SeenClientAnswerMaster]
        (
            [EstablishmentId],
            [SeenClientId],
            [AppUserId],
            [Latitude],
            [Longitude],
            [TimeOffSet],
            [ContactMasterId],
            [IsSubmittedForGroup],
            [ContactGroupId],
            [CreatedBy],
            [EI],
            [IsPositive],
            [IsResolved],
            [MobileDate],
            [CopyReferenceID],
            [DraftEntry],
            [IsDeleted],
            [CreatedOn],
            [Platform],
            [DraftSave]
        )
        VALUES
        (@EstablishmentId,
         @SeenClientId,
         @AppUserId,
         @Latitude,
         @Longitude,
         @TimeOffSet,
         @ContactMasterId,
         @IsSubmittedForGroup,
         @ContactGroupId,
         @AppUserId,
         @EI,
         @IsPositive,
         @IsResolved,
         @MobileDate,
         @CopyReferenceId,
         @DraftEntry,
         @IsDelete,
         @CreatedOn,
         @Platform,
         @DraftSave
        );
        SELECT @Id = SCOPE_IDENTITY();
        SELECT ISNULL(@Id, 0) AS InsertedId;
    END;
	ELSE
	BEGIN
	SET @Id = 0
	SELECT @Id AS InsertedId;
	END
END;
