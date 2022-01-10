CREATE PROC [dbo].[InsertOrUpdateEstablishmentRemindersTaskTable]
    @Id BIGINT,
	@EstablishmentID BIGINT,
    @TimeOfReminder TIME,
    @RecurrenceType SMALLINT,
    @RunOn NVARCHAR(50),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsActive BIT,
    @UserID BIGINT,
    @IsDeleted BIT
AS
SET NOCOUNT ON;
IF @Id = 0
BEGIN
    INSERT INTO EstablishmentRemindersTaskTable
    (
		[EstablishmentID],
        [TimeOfReminder],
        [RecurrenceType],
        [RunOn],
        [StartDate],
        [EndDate],
        [IsActive],
        [CreatedOn],
        [CreatedBy],
        [IsDeleted]
    )
    VALUES
    (@EstablishmentID,@TimeOfReminder, @RecurrenceType, @RunOn, @StartDate, @EndDate, 1, GETDATE(), @UserID, @IsDeleted);
    SELECT SCOPE_IDENTITY() AS InsertedID;
END;
ELSE
BEGIN
    UPDATE EstablishmentRemindersTaskTable
    SET [TimeOfReminder] = @TimeOfReminder,
        [RecurrenceType] = @RecurrenceType,
        [RunOn] = @RunOn,
        [StartDate] = @StartDate,
        [EndDate] = @EndDate,
        [IsActive] = @IsActive,
        [UpdatedOn] = GETDATE(),
        [UpdatedBy] = @UserID,
        [IsDeleted] = @IsDeleted
    WHERE [Id] = @Id AND [EstablishmentID] = @EstablishmentID;
    SELECT CAST(@Id AS DECIMAL) AS InsertedID;
END;
SET NOCOUNT OFF;








