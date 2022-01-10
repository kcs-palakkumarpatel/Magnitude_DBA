CREATE PROC [dbo].[InsertOrUpdateLagoonBeachHotelRooms]
    @Id BIGINT,
    @RoomNumber SMALLINT,
    @GuestName NVARCHAR(500),
    @RoomStatus NVARCHAR(50),
    @CheckInDate DATETIME,
    @CheckOutDate DATETIME,
    @Bed NVARCHAR(50),
    @IsDeleted BIT,
    @CreatedBy BIGINT,
    @UpdatedBy BIGINT
AS
SET NOCOUNT ON;
IF @Id = 0
BEGIN
    INSERT INTO LagoonBeachHotelRooms
    (
        [RoomNumber],
        [GuestName],
        [RoomStatus],
        [CheckInDate],
        [CheckOutDate],
        [Bed],
        [IsDeleted],
        [CreatedOn],
        [CreatedBy]
    )
    VALUES
    (@RoomNumber, @GuestName, @RoomStatus, @CheckInDate, @CheckOutDate, @Bed, @IsDeleted, GETDATE(), @CreatedBy);
    SELECT SCOPE_IDENTITY() AS InsertedID;
END;
ELSE
BEGIN
    UPDATE LagoonBeachHotelRooms
    SET [RoomNumber] = @RoomNumber,
        [GuestName] = @GuestName,
        [RoomStatus] = @RoomStatus,
        [CheckInDate] = @CheckInDate,
        [CheckOutDate] = @CheckOutDate,
        [Bed] = @Bed,
        [IsDeleted] = @IsDeleted,
        [UpdatedOn] = GETDATE(),
        [UpdatedBy] = @UpdatedBy
    WHERE [Id] = @Id;
    SELECT CAST(@Id AS DECIMAL) AS InsertedID;
END;

-- Insert Data into LagoonBeachHotelRoomsHistory table
INSERT INTO LagoonBeachHotelRoomsHistory
(
    [RoomNumber],
    [GuestName],
    [RoomStatus],
    [CheckInDate],
    [CheckOutDate],
    [Bed],
    [IsDeleted],
    [CreatedOn],
    [CreatedBy]
)
VALUES
(@RoomNumber, @GuestName, @RoomStatus, @CheckInDate, @CheckOutDate, @Bed, @IsDeleted, GETDATE(), @CreatedBy);

SET NOCOUNT OFF;