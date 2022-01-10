CREATE PROCEDURE [dbo].[InsertOrUpdateEstablishmentRemindersCaptureTaskTable]
    @Id BIGINT,
    @TimeOfReminder DATETIME,
    @RecurrenceType SMALLINT,
    @RunOn NVARCHAR(50) = '0',
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsActive BIT,
    @UserID BIGINT,
    @IsDeleted BIT,
    @EstablishmentID BIGINT
AS
SET NOCOUNT ON;
IF NOT EXISTS
(
    SELECT EstablishmentId
    FROM EstablishmentRemindersCaptureTaskTable
    WHERE EstablishmentId = @EstablishmentID
)
BEGIN
    INSERT INTO EstablishmentRemindersCaptureTaskTable
    (
        [TimeOfReminder],
        [RecurrenceType],
        [RunOn],
        [StartDate],
        [EndDate],
        [IsActive],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted],
        [EstablishmentId]
    )
    VALUES
    (@TimeOfReminder,
     @RecurrenceType,
     @RunOn,
     @StartDate,
     @EndDate,
     @IsActive,
     GETDATE(),
     @UserID,
     @IsDeleted,
     @EstablishmentID
    );
END;
ELSE
BEGIN
    IF (@IsActive = '1')
    BEGIN
        UPDATE EstablishmentRemindersCaptureTaskTable
        SET [TimeOfReminder] = @TimeOfReminder,
            [RecurrenceType] = @RecurrenceType,
            [RunOn] = @RunOn,
            [StartDate] = @StartDate,
            [EndDate] = @EndDate,
            [IsActive] = @IsActive,
            [UpdatedOn] = GETDATE(),
            [UpdatedBy] = @UserID,
			[IsDeleted] = @IsDeleted,
            [DeletedOn] = NULL,
            [DeletedBy] = NULL
        WHERE [EstablishmentId] = @EstablishmentID;
    END;
    ELSE
    BEGIN
        UPDATE EstablishmentRemindersCaptureTaskTable
        SET [IsActive] = '0',
            [IsDeleted] = @IsDeleted,
            [DeletedOn] = GETDATE(),
            [DeletedBy] = @UserID
        WHERE [EstablishmentId] = @EstablishmentID;
    END;
END;
SELECT CAST(@EstablishmentID AS BIGINT) AS InsertedID;
SET NOCOUNT OFF;