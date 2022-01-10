
-- =============================================
-- Author:		<Author,,Sunil Vaghasiya>
-- Create date: <Create Date,, 06 Jan 2017>
-- Description:	<Description,,InsertOrUpdateSeenClientAnswerMaster>
-- Call SP    :		UpdateSeenClientAnswerMaster 364033, 23997,605,1243,23.0293504,72.5794816,226281,false,null,0,Neutral,null,true,0
-- =============================================
/*
Drop procedure UpdateSeenClientAnswerMaster
*/
CREATE PROCEDURE [dbo].[UpdateSeenClientAnswerMaster]
    @Id BIGINT,
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
    @DraftEntry BIT = 0,
    @DraftSave INT = NULL,
    @AllocatedAppUserId BIGINT = 0
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    IF (@DraftSave IS NULL)
    BEGIN
        SET @DraftSave = 0;
    END;

    DELETE FROM dbo.SeenClientAnswers
    WHERE SeenClientAnswerMasterId = @Id;

    DECLARE @TimeOffSet INT,
            @IsDeleted BIT = 1,
            @IsResolved NVARCHAR(50) = 'Unresolved',
            @InUnAllocated BIT;
    IF @DraftEntry = 0
        SET @IsDeleted = 0;

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
    BEGIN
        SET @IsSubmittedForGroup = 1;
        UPDATE ContactGroup
        SET LastUsedOn = GETUTCDATE()
        WHERE Id = @ContactGroupId;
    END;
    ELSE
    BEGIN
        IF @ContactMasterId > 0
           OR @ContactMasterId IS NOT NULL
        BEGIN
            UPDATE ContactMaster
            SET LastUsedOn = GETUTCDATE()
            WHERE Id = @ContactMasterId;
        END;
    END;


    SELECT @TimeOffSet = TimeOffSet
    FROM dbo.Establishment
    WHERE Id = @EstablishmentId;
    DECLARE @CreateOn DATETIME = GETUTCDATE();

    IF (@DraftEntry = 1)
    BEGIN
        SELECT @CreateOn = CreatedOn
        FROM dbo.SeenClientAnswerMaster
        WHERE IsDeleted = 1
              AND DraftEntry = 1
              AND Id = @Id;
    END;

    IF EXISTS
    (
        SELECT Id
        FROM dbo.SeenClientAnswerMaster
        WHERE IsDeleted = 1
              AND DraftEntry = 1
              AND Id = @Id
    )
    BEGIN
        UPDATE dbo.SeenClientAnswerMaster
        SET UpdatedOn = GETUTCDATE(),
            CreatedOn = @CreateOn,
            UpdatedBy = @AppUserId,
            TimeOffSet = @TimeOffSet,
            ContactMasterId = @ContactMasterId,
            IsSubmittedForGroup = @IsSubmittedForGroup,
            ContactGroupId = @ContactGroupId,
            EI = @EI,
            IsPositive = @IsPositive,
            IsResolved = @IsResolved,
            DraftEntry = @DraftEntry,
            IsDeleted = @IsDeleted,
            DraftSave = @DraftSave,
            IsUnAllocated = @InUnAllocated
        WHERE Id = @Id;
    END;

    SELECT ISNULL(@Id, 0) AS UpdatedID;
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
         'dbo.UpdateSeenClientAnswerMaster',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @Id+','+@EstablishmentId+','+@SeenClientId+','+@AppUserId+','+@Latitude+','+@Longitude+','+@ContactMasterId+','+@IsSubmittedForGroup+','+@ContactGroupId+','+@EI+','+@IsPositive+','+@MobileDate+','+@DraftEntry+','+@DraftSave+','+@AllocatedAppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
