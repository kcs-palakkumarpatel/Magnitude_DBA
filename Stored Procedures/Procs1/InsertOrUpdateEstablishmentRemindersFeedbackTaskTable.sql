

CREATE PROC [dbo].[InsertOrUpdateEstablishmentRemindersFeedbackTaskTable]
         @EstablishmentId BIGINT,
@RecurrenceType SMALLINT,
@IntervalSad SMALLINT,
@IntervalNeutral SMALLINT,
@IntervalHappy SMALLINT,
@IntervalAll SMALLINT,
@IsActive BIT,
@UserID BIGINT
AS
SET NOCOUNT ON;
IF NOT EXISTS(SELECT EstablishmentId FROM EstablishmentRemindersFeedbackTaskTable WHERE EstablishmentId = @EstablishmentID)
BEGIN
    INSERT INTO EstablishmentRemindersFeedbackTaskTable 
    (       
		   [EstablishmentId],
		   [RecurrenceType],
           [IntervalSad],
           [IntervalNeutral],
           [IntervalHappy],
           [IntervalAll],
           [IsActive],
           [CreatedOn],
           [CreatedBy]
    )
    VALUES
    (@EstablishmentID ,@RecurrenceType, @IntervalSad, @IntervalNeutral, @IntervalHappy,@IntervalAll, @IsActive, GETDATE(), @UserID);
END
ELSE
BEGIN
	IF (@IsActive = '1') BEGIN
		UPDATE EstablishmentRemindersFeedbackTaskTable
		SET [RecurrenceType] = @RecurrenceType,
		    [IntervalSad] = @IntervalSad,
            [IntervalNeutral] = @IntervalNeutral,
            [IntervalHappy] = @IntervalHappy,
            [IntervalAll] = @IntervalAll,
			[IsActive] = @IsActive,
			[UpdatedOn] = GETDATE(),
			[UpdatedBy] = @UserID
	WHERE [EstablishmentID] = @EstablishmentID
	END
	ELSE
	BEGIN
		UPDATE EstablishmentRemindersFeedbackTaskTable
		SET 
		[IsActive] = '0',
		[DeletedOn] = GETDATE(),
		[DeletedBy] = @UserID
		WHERE [EstablishmentID] = @EstablishmentID;	
	END
END;
SET NOCOUNT OFF;