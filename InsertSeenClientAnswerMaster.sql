
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 22 Jun 2015>
-- Description:	<Description,,InsertOrUpdateSeenClientAnswerMaster>
-- Call SP    :	InsertSeenClientAnswerMaster
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerMaster]
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
    @AutoReportId BIGINT = NULL,
    @AllocatedAppUserId BIGINT = 0,
	@InUnAllocated BIT = 0
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @TimeOffSet INT,
            @Id BIGINT,
            @IsDelete BIT = 0,
            @IsResolved NVARCHAR(50) = 'Unresolved';
    IF (@DraftSave IS NULL)
    BEGIN
        SET @DraftSave = 0;
    END;
    IF (@Platform = 'Web')
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

    SELECT @TimeOffSet = TimeOffSet
    FROM dbo.Establishment
    WHERE Id = @EstablishmentId;
    IF (@CreatedOn IS NULL OR @CreatedOn = '')
    BEGIN
        SET @CreatedOn = GETUTCDATE();
    END;
    ELSE
    BEGIN
        SELECT @CreatedOn = @CreatedOn;
    END;
	DECLARE @LastUsedOn DATETIME
	SET @LastUsedOn =ISNULL(DATEADD(MINUTE, @TimeOffSet, @CreatedOn), GETUTCDATE())
    IF @ContactGroupId > 0
       OR @ContactGroupId IS NOT NULL
    BEGIN
        SET @IsSubmittedForGroup = 1;
        UPDATE ContactGroup
        SET LastUsedOn = @LastUsedOn
        WHERE Id = @ContactGroupId;
    END;
    ELSE
    BEGIN
        IF @ContactMasterId > 0
           OR @ContactMasterId IS NOT NULL
        BEGIN
            UPDATE ContactMaster
            SET LastUsedOn =@LastUsedOn
            WHERE Id = @ContactMasterId;
        END;
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
        [DraftSave],
        IsUnAllocated
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
     @DraftSave,
     @InUnAllocated
    );
    SELECT @Id = SCOPE_IDENTITY();
    IF EXISTS
    (
        SELECT StatusIconEstablishment
        FROM dbo.Establishment
        WHERE Id = @EstablishmentId
    )
    BEGIN
        INSERT INTO dbo.StatusHistory
        (
            ReferenceNo,
            EstablishmentStatusId,
            UserId,
            StatusDateTime,
            Latitude,
            IsOut,
            Longitude,
            CreatedOn,
            CreatedBy,
            UpdatedOn,
            UpdatedBy,
            DeletedOn,
            DeletedBy,
            IsDeleted
        )
        VALUES
        (   @Id,                                        -- ReferenceNo - bigint
            (
                SELECT TOP 1 Id
                FROM dbo.EstablishmentStatus
                WHERE EstablishmentId = @EstablishmentId
                      AND DefaultStartStatus = 1
                      AND IsDeleted = 0
            ),                                          -- EstablishmentStautId - bigint
            @AppUserId,                                 -- UserId - bigint
            DATEADD(MINUTE, @TimeOffSet, @CreatedOn), --StatusDateTime   
            @Latitude,                                  -- Latitude - nvarchar(50)
            1,                                          -- IsOut - bit
            @Longitude,                                 -- Longitude - nvarchar(50)
            @CreatedOn,                               -- CreatedOn - datetime
            @AppUserId,                                 -- CreatedBy - bigint
            NULL,                                       -- UpdatedOn - datetime
            0,                                          -- UpdatedBy - bigint
            NULL,                                       -- DeletedOn - datetime
            0,                                          -- DeletedBy - bigint
            0                                           -- IsDeleted - bit		
        );
		
		UPDATE dbo.SeenClientAnswerMaster 
		SET StatusHistoryId = (SELECT MAX(Id)
		FROM dbo.StatusHistory WITH(NOLOCK)
		WHERE ReferenceNo = @Id)
		WHERE Id = @Id;
    END;
	
    --code FOR reminder schedule
    IF EXISTS
    (
        SELECT Id
        FROM dbo.PendingEstablishmentReminder
        WHERE EstablishmentId = @EstablishmentId
              AND AppUserId = @AppUserId
    )
    BEGIN
        UPDATE PendingEstablishmentReminder
        SET FormCapturedbyUser = 1
        WHERE EstablishmentId = @EstablishmentId
              AND AppUserId = @AppUserId;
    END;

    SELECT ISNULL(@Id, 0) AS InsertedId;
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
         'dbo.InsertSeenClientAnswerMaster',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @CopyReferenceId+','+
		 @DraftEntry+','+
		 @EstablishmentId+','+
		 @SeenClientId+','+
		 @AppUserId+','+
		 @Latitude+','+
		 @Longitude+','+
		 @ContactMasterId+','+
		 @IsSubmittedForGroup+','+
		 @ContactGroupId+','+
		 @EI+','+
		 @IsPositive+','+
		 @MobileDate+','+
		 @CreatedOn+','+
		 @Platform+','+
		 @DraftSave+','+
		 @AutoReportId+','+
		 @AllocatedAppUserId+','+
		 @InUnAllocated,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
